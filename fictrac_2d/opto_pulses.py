#code to send an arduino pulse every 10 sec
from __future__ import print_function
import time
from .trigger_device import TriggerDevice
from . import utils

class OptoPulses(object):

    default_param = {
        'experiment_time': 300,
        'time_between_pulses': 10,
        'pulse_duration': 1,
        'trigger_device_port': '/./COM6' #I changed this port -MB 20190813
    }


    def __init__(self,param = default_param):
        self.param = param
        self.trigger_device = TriggerDevice(self.param['trigger_device_port'])
        self.trigger_device.set_low()
        self.reset()
        self.reward_time = 10000000000
        self.done = False
        self.reward = False
        self.experiment_time = self.param['experiment_time']
        self.time_between_pulses = self.param['time_between_pulses']
        self.pulse_duration = self.param['pulse_duration']

    def reset(self):
        self.time_start = time.time()
        self.time_now = self.time_start

    @property
    def time_elapsed(self):
        return self.time_now - self.time_start

    def run(self):
        self.trigger_device.set_low()
        while not self.done:
            self.time_now = time.time()
            if (round(self.time_elapsed) % self.time_between_pulses == 0) and (self.time_elapsed > 2) and (self.reward == False): #when you reach the desired time_between_pulses
                #turn the pulse on 
                self.trigger_device.set_value(7)
                self.reward = True
                self.reward_time = self.time_elapsed
            if self.time_elapsed > self.reward_time + self.pulse_duration: #if the pulse has been on for the desired duration
                self.trigger_device.set_value(0)  #turn the LED off
                self.reward = False

            utils.flush_print('time elapsed= {0:1.3f}'.format(self.time_elapsed))
            utils.flush_print('reward_time= {0:1.3f}'.format(self.reward_time))
            utils.flush_print('reward         = {0}'.format(self.reward))
            utils.flush_print()

            if self.time_elapsed > self.experiment_time:
                self.done = True
                self.trigger_device.set_value(0)
                break