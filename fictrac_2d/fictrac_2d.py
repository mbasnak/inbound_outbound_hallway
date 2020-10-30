from __future__ import print_function

import time
import redis
import json
import signal
import numpy as np

from . import utils
from .fly_data import FlyData
from .trigger_device import TriggerDevice
from .protocol import Protocol
from .h5_logger import H5Logger
from .analogout import FicTracAout

class FicTrac2D(object):

    """
    Implements the experiment. Take input via PUB/SUB fictrac output channel.
    Updates fly data.
    Uses protocol to determine the appropriate panels out and if opto is on.
    Calls analogout to output parameters.

    Jenny Lu 5-9-2019

    """

    default_param = {
        'experiment': 1,
        'experiment_time': 30,
        'jump_time': 120,
        'hold_time': 3,
        'goal_change': 180,
        'goal_window': 90,
        'pre_training': 600,
        'training': 600,
        'logfile_name': 'Z:/Wilson Lab/Mel/FlyOnTheBall/data',
        'logfile_auto_incr': True,
        'logfile_auto_incr_format': '{0:06d}',
        'logfile_dt': 0.01,
        'trigger_device_port': '/./COM6', #I changed this port -MB 20190813
        'arduino': False,
        'analog_out': False,
        'gain_yaw': 1,
        'gain_x': 1,
        'probe_status': False,
        'probe_trials': 1000,
        'outbound_360_trials': 1000,
        'inbound_360_trials': 1000,
        'trip_number': 10000,
        'reward_voltage': 2.56
    }

    def __init__(self, param = default_param):
        self.param = param
        self.data = FlyData() #get the data from fictrac through FlyData's module, in fly_data.py
        self.protocol = Protocol(self.param) #get the protocol paramteres through Protocol, in protocol.py
        self.analog_out = self.param['analog_out']
        self.gain_yaw = self.param['gain_yaw']
        self.gain_x = self.param['gain_x']
        if self.analog_out: #if the parameter analog_out is defined as true (which it is in run_experiment.py)
            self.aout = FicTracAout() #define the output as the one given in the alaogout.py code.
        parameter_copy = self.param.copy()
        del parameter_copy['probe_trials']
        del parameter_copy['inbound_360_trials']
        del parameter_copy['outbound_360_trials']
        self.logger = H5Logger(
                filename = self.param['logfile_name'],
                auto_incr = self.param['logfile_auto_incr'],
                auto_incr_format = self.param['logfile_auto_incr_format'],
                param_attr = parameter_copy
                )
        self.experiment_time = self.param['experiment_time']
        self.reset()

        #I'm adding this variable to get the voltage output - MB 20190806
        self.voltage_out = 0
        #I'm adding a parameter that will be the time when the fly reaches the end of the hallway - MB 20190805
        self.final_time = 10000000000
        self.reward_time = 10000000000
        self.experiment = self.param['experiment']
        self.probe_status = self.param['probe_status']
        self.probe_trials = self.param['probe_trials'] #This is if I read it from matlab, but I can also generate it here using the random2 module and then export the vector
        self.outbound_360_trials = self.param['outbound_360_trials']
        self.inbound_360_trials = self.param['inbound_360_trials']
        self.trip_number = self.param['trip_number']
        self.reward_voltage = self.param['reward_voltage']

        if self.param['arduino']:
            self.trigger_device = TriggerDevice(self.param['trigger_device_port'])

        # Setup message queue, redis and worker thread
        self.redis_client = redis.StrictRedis()
        self.pubsub = self.redis_client.pubsub()
        self.pubsub.subscribe('fictrac')

        if self.experiment == 7 or self.experiment == 9:
            self.end_sequence = False
            self.reward_sequence = False

        self.done = False
        signal.signal(signal.SIGINT,self.sigint_handler)

        self.x_gain_v = np.array([0,0,0])
        self.x_gain_v_2 = np.array([0,0,0])


    def reset(self):
        self.data.reset()
        self.protocol.reset()
        self.time_start = time.time()
        self.time_now = self.time_start
        self.time_log = None
        self.end_sequence = False
        self.reward_sequence = False

    @property
    def time_elapsed(self):
        return self.time_now - self.time_start

    def run(self):
        if self.param['arduino']: 
            self.trigger_device.set_low()  #Set the trigger device (arduino COM port defined in trigger_device.py) to low
        while not self.done: #while the time elapsed is less than the experiment time

            #pre-allocating an array to filter the x gain voltage

            # Pull latest redis message from queue
            for item in self.pubsub.listen(): #listen to the redis channel

                # GET TIME
                self.time_now = time.time()
                utils.flush_print('time listened         = {0:1.3f}'.format(self.time_elapsed))

                # New message from fictrac - convert from json to python dictionary
                message = item['data']
                try:
                    data = json.loads(message)
                except TypeError:
                    continue
                if data['type'] == 'reset':
                    # This is a reset message which indicates that FicTrac has been restarted
                    self.on_reset_message(data)
                else:
                    # UPDATE DATA
                    self.data.add(self.time_elapsed, data) #add to the data matrix defined in fly_data the incoming data points
                    utils.flush_print('time data          = {0:1.3f}'.format(self.time_elapsed))


                    # UPDATE ANALOG OUT
                    if self.analog_out:
                        #self.x_gain_v = self.aout.output_voltage(self.data, self.protocol.the_gain, self.protocol.trip_type, self.protocol.trial_counter, self.x_gain_v) #send the analog output through the phidgets device (using analogout.py code)
                        self.aout.output_voltage(self.data, self.protocol.the_gain, self.protocol.trip_type, self.protocol.trial_counter, self.x_gain_v) #send the analog output through the phidgets device (using analogout.py code)
                        
                        #I'm adding the line below to get the voltage output from the x gain channel-MB 20190806
                        #I'm adding the trip type to the function such that we can block the voltage out from 'goign backwards' (MB 20200811)
                        #[self.voltage_out,self.x_gain_v_2] = self.aout.voltage_out(self.data, self.protocol.the_gain, self.protocol.trip_type, self.protocol.trial_counter, self.x_gain_v_2)
                        self.voltage_out = self.aout.voltage_out(self.data, self.protocol.the_gain, self.protocol.trip_type, self.protocol.trial_counter, self.x_gain_v_2)

                        # UPDATE PROTOCOL
                        self.protocol.update_panel(self.time_elapsed,
                                                   self.data, self.voltage_out, self.probe_status)  # update the pannel values with the apropriate jump magnitudes
                        self.data.update_panel_heading(self.time_elapsed, self.protocol.panel_jump, self.gain_yaw,
                                                       self.protocol.open_loop,
                                                       self.protocol.open_loop_value)  # update the yaw movement of the pattern in the panels
                        self.data.update_panel_x(self.gain_x, self.protocol.open_loop_x,
                                                 self.protocol.open_loop_value_x, self.protocol.trial_counter, self.protocol.the_gain, self.protocol.trip_type,self.data)  # update the x movement of the pattern in the panels
                        utils.flush_print('time protocol         = {0:1.3f}'.format(self.time_elapsed))

                        self.protocol.update_opto(self.time_elapsed, self.data, self.voltage_out, self.reward_voltage)

                        #I'm moving the pulse triggering here so that it only happens at the beginning - MB 20190903
                        if self.param['arduino'] and not self.param['probe_status'] and not self.reward_sequence and all(item != self.protocol.trial_counter for item in self.probe_trials):  # if the arduino is defined and this is not a probe trial
                            self.trigger_device.set_value(self.protocol.pulse_value)  # this sends the trigger signals to the arduino, although I think now they're always set at 0
                            utils.flush_print('pulse value        = {0:1.3f}'.format(self.protocol.pulse_value))
                        utils.flush_print('time pulse         = {0:1.3f}'.format(self.time_elapsed))



                        #I'm adding a conditional statement such that if the stimulus has expanded fully, then the final time should be set to the current time-MB 20190806
                        if (not self.end_sequence) and (self.protocol.end_sequence_virtualHallway):
                            self.final_time = self.time_elapsed
                            self.end_sequence = True
                        elif not self.end_sequence:
                            self.final_time = 10000000000

                        if (not self.reward_sequence) and (self.protocol.reward_sequence_virtualHallway):
                            self.reward_time = self.time_elapsed
                            self.reward_sequence = True
                        #elif not self.reward_sequence:
                            #self.reward_time = 10000000000

                    utils.flush_print('time aout         = {0:1.3f}'.format(self.time_elapsed))
                    utils.flush_print('output_voltage_x_gain         = {0:1.3f}'.format(self.voltage_out))
                    utils.flush_print('reward_time         = {0:1.3f}'.format(self.reward_time))
                    utils.flush_print('reward_sequence         = {0:1.3f}'.format(self.reward_sequence))
                    utils.flush_print('reward_voltage         = {0:1.3f}'.format(self.reward_voltage))
                    utils.flush_print('trial_counter         = {0:1.3f}'.format(self.protocol.trial_counter))
                    utils.flush_print('trip type         = {0}'.format(self.protocol.trip_type))
                    utils.flush_print('turn         = {0:1.3f}'.format(self.protocol.turn))
                    utils.flush_print('panelx         = {0:1.3f}'.format(self.data.panel_x))
                    #utils.flush_print(self.x_gain_v)
                    #utils.flush_print(self.x_gain_v_2)
                    utils.flush_print()

                    # LOG FILE
                    self.write_logfile() #save all the data in a log file


                # END EXPERIMENT IF TIME ELAPSED
                #I'm changing this so that it only works for experiments 1-6
                if self.experiment != 7 and self.experiment != 9:
                    if self.time_elapsed > self.experiment_time:
                        self.done = True
                        break

                #added this to make the trial end when the fly reaches the reward location - added by MB 20190805
                elif self.experiment == 7:
                    # if the animal has reached the reward, wait 0.5 s and turn off the pulse
                    if self.reward_sequence and self.time_elapsed > self.reward_time + 0.5:
                        self.trigger_device.set_value(0)  # turn the LED off
                        self.protocol.end_reward_virtualHallway = True

                    # if animal has reached the end of the experiment, keep acquiring for 1 s
                    if self.end_sequence and self.time_elapsed > self.final_time + 1.0:
                        self.done = True
                        break

                    # also end the trial if you've run out of time
                    if self.time_elapsed > self.experiment_time:
                        self.done = True
                        break

                else:
                    # if the animal has reached the reward, wait 0.5 s and turn off the pulse
                    if self.reward_sequence and self.time_elapsed > self.reward_time + 0.5:
                        self.trigger_device.set_value(0)  # turn the LED off
                        self.protocol.end_reward_virtualHallway = True
                    
                    if self.reward_sequence and self.protocol.turn:
                        self.reward_sequence = False

                    # if animal has reached the end of the experiment (max trial_counter), keep acquiring for 1 s
                    if self.protocol.trial_counter == self.trip_number:
                        self.done = True
                        break

                    # also end the trial if you've run out of time
                    if self.time_elapsed > self.experiment_time:
                        self.done = True
                        break



        # END OF EXPERIMENT
        utils.flush_print()
        utils.flush_print('Run finshed - quiting!')
        self.clean_up()

    def on_reset_message(self,message):
        utils.flush_print('reset')
        self.reset()

#I'm saving some additional variables to the h5 file to be able to troubleshoot the hallway.
    def write_logfile(self):
        if self.time_log is None or ((self.time_elapsed - self.time_log) >  self.param['logfile_dt']):
            self.time_log = self.time_elapsed
            log_data = {
                'time': self.time_elapsed,
                'frame': self.data.frame,
                'posx': self.data.posx,
                'posy': self.data.posy,
                'velx': self.data.velx,
                'vely': self.data.vely,
                'intx': self.data.intx,
                'inty': self.data.inty,
                'heading': self.data.heading,
                'panel heading': self.data.panel_heading,
                'goal heading': self.data.goal_heading,
                'new goal heading': self.protocol.new_goal_heading,
                'panel jump': self.protocol.panel_jump,
                'open loop': self.protocol.open_loop,
                'open loop value': self.protocol.open_loop_value,
                'panel x': self.data.panel_x,
                'open loop x': self.protocol.open_loop_x,
                'open loop value x': self.protocol.open_loop_value_x,
                'pulse_on': self.protocol.pulse_value,
                'output_voltage_x_gain': self.voltage_out,
                'trial_counter': self.protocol.trial_counter,
                'trip_type': self.protocol.tripType,
                'turn': self.protocol.numericTurn,
                'gain': self.protocol.the_gain,
                'first_frame': int(self.data.first_frame == True),
                'test': self.aout.test
            }
            self.logger.add(log_data)

    def sigint_handler(self, signum, frame):
        self.done = True

    def clean_up(self):
        self.logger.reset()
        if self.param['arduino'] and self.trigger_device.isOpen():
            self.trigger_device.set_value(0)