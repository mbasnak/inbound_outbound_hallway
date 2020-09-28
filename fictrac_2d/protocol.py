from __future__ import print_function
from . import utils
import math
import matplotlib.path as path
import matplotlib.transforms as transforms
import numpy as np
import matplotlib.pyplot
import random
import time

class Protocol(object):
    """
    Implements experimental protocol
        1 - spontaneous
        2 - menotaxis
        3 - conditioned menotaxis
    """
    default_param = {
        'experiment': 1,
        'experiment_time': 1800,
        'jump_time': 120,
        'goal_change': 180,
        'goal_window': 90,
        'pre_training': 600,
        'training': 600,
        'hold_time': 3
    }

    def __init__(self, param=default_param):
        self.param = param
        self.reset()  # set initial values
        self.jump_time = param['jump_time']
        self.hold_time = param['hold_time']
        self.goal_change = param['goal_change']
        self.goal_window = param['goal_window']
        self.pre_training = param['pre_training']
        self.training = param['training']
        self.center_panel_position = 44
        order = [1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, 1, 1, -1, 1, -1, -1, 1, -1, 1]
        self.jumps_order = [90*x for x in order]
        self.trip_type = 'left'
        self.tripType = 1
        self.the_gain = [-1,1]
        self.turn = False
        self.time_turn = 0
        self.total_time_turn = 3
        self.trial_counter = 0
        

    def reset(self):
        self.panel_jump = 0
        self.open_loop = 0
        self.open_loop_value = 0
        self.open_loop_x = 0
        self.open_loop_value_x = 0
        self.pulse_value = 0
        self.time_last_jump = 0
        order = [1, -1, -1, -1, 1, 1, -1, -1, 1, -1, 1, 1, 1, -1, 1, -1, -1, 1, -1, 1] #random order of jumps
        self.jumps_order = [90 * x for x in order] #make those jumps be either 90 or -90 deg in value
        self.jump_count = 0
        self.training_start = False
        self.new_goal_heading = 0
        self.jump_hold_start = False
        self.end_sequence_virtualHallway = False
        self.reward_sequence_virtualHallway = False
        self.end_reward_virtualHallway = False
        self.turn = False
        self.numericTurn = 0
        self.time_turn = 0
        self.start_sequence_virtualHallway = False
        self.trip_type = 'left'
        self.the_gain = [-1,1]
        self.total_time_turn = 3
        self.trial_counter = 1

    def update_panel(self, t, data, voltage_out, probe_status): #updates the position of the stimulus according to the experiment type
        if self.param['experiment'] == 1:
            self.panel_jump = 0
            self.open_loop = 0
        elif self.param['experiment'] == 2: #if you've pressed button 2 in the matlab GUI, it's menotaxis
            self.panel_jump = self.menotaxis(t) #update the panel value by the jump magnitude
            self.open_loop = 0
        elif self.param['experiment'] == 3:
            self.panel_jump = self.menotaxis(t)
            self.open_loop = 0
        elif self.param['experiment'] == 4:
            self.panel_jump = self.jump_hold(t)
            self.hold(t, data)
        elif self.param['experiment'] == 5:
            self.panel_jump = 0
            self.hallway(data)
        elif self.param['experiment'] == 6:
            self.panel_jump = 0
            self.open_loop = 0
            # I'm adding this to run virtualHallway - MB 20190805
        elif self.param['experiment'] == 7:
            self.panel_jump = 0
            self.open_loop = 0
            self.open_loop_x = self.virtualHallwayPanels(voltage_out, data, probe_status)
        elif self.param['experiment'] == 9:
            self.panel_jump = 0
            [self.open_loop, self.open_loop_value, self.open_loop_x, self.open_loop_value_x] = self.inboundOutboundPanels(voltage_out, data)        
        else:
            self.panel_jump = 0

    def update_opto(self, t, data, voltage_out,reward_voltage):
        if self.param['experiment'] == 1:
            self.pulse_value = 0
        elif self.param['experiment'] == 2:
            self.pulse_value = 0
        elif self.param['experiment'] == 3:
            self.pulse_value = self.conditioned_menotaxis(t, data)
        elif self.param['experiment'] == 4:
            self.pulse_value = 0
        elif self.param['experiment'] == 5:
            self.pulse_value = 0
        elif self.param['experiment'] == 6:
            self.pulse_value = 0
            # I'm adding this to deliver opto stimuli in virtualHallway
        elif self.param['experiment'] == 7:
            self.pulse_value = self.virtualHallway(voltage_out)
        elif self.param['experiment'] == 9:
            self.pulse_value = self.inboundOutbound(voltage_out,reward_voltage)
        else:
            self.pulse_value = 0    


    def menotaxis(self, t):
        if (t - self.time_last_jump) > self.jump_time: #If you've reached the previously defined time between jumps
            # select random between +90 and -90
            self.jump_count += 1 #add one more jump to the count
            self.time_last_jump = t #restart the counter for the time until the next jump
            return self.jumps_order[self.jump_count%10] #gives back the value of the corresponding jump in the list
        else:
            return 0

    def jump_hold(self, t):
        if (t - self.time_last_jump) > self.jump_time + self.hold_time:
            # select random between +90 and -90
            self.jump_count += 1
            self.time_last_jump = t
            self.jump_hold_start = True
            return self.jumps_order[self.jump_count%10]
        else:
            return 0

    def hold(self, t, data):
        if self.jump_count > 0 and (t - self.time_last_jump) < self.hold_time:
            if self.jump_hold_start:
                self.open_loop = 0
                self.jump_hold_start = False
            elif self.open_loop == 0:
                self.open_loop = 1
                self.open_loop_value = data.panel_heading
        elif (t - self.time_last_jump) > self.hold_time:
            self.open_loop = 0
            self.open_loop_value = 0
        else:
            self.open_loop = 0
            self.open_loop_value = 0

    def hallway(self, data):
        angle_width = 45
        side_one_angle = (self.center_panel_position * 360 / 96) % 360
        side_two_angle = ((self.center_panel_position + 48) * 360 / 96) % 360

        if (data.panel_heading -  side_one_angle) % 360 < angle_width/2 or (data.panel_heading -  side_two_angle) % 360 < angle_width/2:
            self.open_loop_x = 0
            self.open_loop_value_x = 0
        elif self.open_loop == 0:
            self.open_loop_x = 1
            self.open_loop_value_x = data.panel_x

    def conditioned_menotaxis(self, t, data):
        if t < self.pre_training or t > (self.pre_training + self.training):
            return 0
        elif not self.training_start:
            self.training_start = True
            self.new_goal_heading = (data.goal_heading + self.goal_change)%360
            return self.is_inside_theta(data)
        else:
            return self.is_inside_theta(data)

    #I'm generating a function to deliver opto when the fly has run the appropriate distance in the virtual hallway - MB 20190805
    def virtualHallway(self, voltage_out):
        if (voltage_out > 1.28 and voltage_out < 7.5): #when the fly has reached dimension 12 [i.e., the middle of the hallway]
            return 7
        else:
            return 0
            ##########

    def inboundOutbound(self, voltage_out, reward_voltage):
        if (voltage_out > reward_voltage and voltage_out < 7.5) and (self.trip_type == 'left') and (not self.turn): #when the fly has reached the middle of the hallway in a left trip
            self.reward_sequence_virtualHallway = True
            return 7 #give her an opto pulse
        #I'm adding the reward for the 360 turn trips during the first half.
        if (voltage_out > reward_voltage and voltage_out < 7.5) and (self.trip_type == 'left_360_turn_first_half') and (not self.turn): #when the fly has reached the middle of the hallway in an inbound trip
            self.reward_sequence_virtualHallway = True
            return 7 #give her an opto pulse           
        elif (voltage_out < reward_voltage) and (self.trip_type == 'right') and (not self.turn):
            self.reward_sequence_virtualHallway = True
            return 7 #give her an opto pulse
        else:
            self.reward_sequence_virtualHallway = False
            return 0


    def virtualHallwayPanels(self, voltage_out, data, probe_status):
        # if we reach end of the hallway, then we are in the end sequence state
        # record what that value is for the panels x OR just set it to that voltage of the cutoff
        # switch to open loop
        if (not self.end_sequence_virtualHallway) and (2.56 < voltage_out < 7.5):  # the stimulus has expanded fully when voltage_out=1.28, but I'm adding a little more. I've added the other end of the condition in case the animal walks backwards.
            self.end_sequence_virtualHallway = True
            return 0

        elif (not self.reward_sequence_virtualHallway) and (
                2.56 < voltage_out < 7.5) and (
                not self.end_reward_virtualHallway) and (not probe_status): #if you have just reached dimension 7
            self.reward_sequence_virtualHallway = True
            self.open_loop_value_x = data.panel_x
            return 1 #open the loop
        elif not self.reward_sequence_virtualHallway:
            return 0
        elif probe_status:
            return 0
        elif self.end_reward_virtualHallway: #if the time of the reward has elapsed, open the loop
            return 0
        elif self.end_sequence_virtualHallway:
            return 0
        else:
            return 1


    def inboundOutboundPanels(self, voltage_out, data):

        # Are we starting a turn
        if self.trip_type == 'left':
            if (not self.turn) and (5.1 < voltage_out < 7.5): #if the animal has reached the end of the hallway.
                self.turn = True
                self.numericTurn = 1 #set turn to quantitative variable for logging
                self.turn_type = random.choice([-1,1])
                self.time_turn = time.time()
                self.trial_counter = self.trial_counter + 1

            elif self.turn and (time.time()-self.time_turn > self.total_time_turn):
                self.turn = False
                self.numericTurn = 0 #set turn to quantitative variable for logging
                self.the_gain[1] = -1*self.the_gain[1]
                self.trip_type = 'right'
                self.tripType = 2 #numeric equivalent of the trip type

        elif self.trip_type == 'right':
            if (not self.turn) and (0.1 > voltage_out): #if the animal has reached the end of the hallway.
                self.turn = True
                self.numericTurn = 1 #set turn to quantitative variable for logging
                self.turn_type = random.choice([-1,1])
                self.time_turn = time.time()
                self.trial_counter = self.trial_counter + 1

            elif self.turn and (time.time()-self.time_turn > self.total_time_turn):
                self.turn = False
                self.numericTurn = 0 #set turn to quantitative variable for logging
                #I'm adding the following distinction between regular left and 360 left trips - MB 20200805
                if (self.trial_counter == 15 or self.trial_counter == 23 or self.trial_counter == 33 or self.trial_counter == 43 or self.trial_counter == 53): #if this is one of the pre-specified 360 turn trip number
                    self.the_gain[1] = -1*self.the_gain[1]
                    self.trip_type = 'left_360_turn_first_half' #set the trip type to 360 turn
                    self.tripType = 3
                else:
                    self.the_gain[1] = -1*self.the_gain[1]                         
                    self.trip_type = 'left'
                    self.tripType = 1                   

        #I'm adding the following lines to add 360 probe trials - MB 20200805
        elif self.trip_type == 'left_360_turn_first_half':
            if (not self.turn) and (5.1 < voltage_out < 7.5): #if the animal has reached the end of the hallway.
                self.turn = True
                self.numericTurn = 1 #set turn to quantitative variable for logging
                self.turn_type = random.choice([-1,1])
                self.time_turn = time.time()

            elif self.turn and (time.time()-self.time_turn > self.total_time_turn*2): #I'm doubling the total time turn to keep the turning rate constant
                self.turn = False
                self.numericTurn = 0 #set turn to quantitative variable for logging
                self.the_gain[1] = 1*self.the_gain[1]
                self.trip_type = 'left_360_turn_second_half' #after a 360 turn, continue that type of trial, moving on to its second half
                self.tripType = 4

        elif self.trip_type == 'left_360_turn_second_half':
            if (not self.turn) and (9.5 < voltage_out < 9.7): #if the animal has reached the end of the hallway.
                self.turn = True
                self.numericTurn = 1 #set turn to quantitative variable for logging
                self.turn_type = random.choice([-1,1])
                self.time_turn = time.time()
                self.trial_counter = self.trial_counter + 1

            elif self.turn and (time.time()-self.time_turn > self.total_time_turn):
                self.turn = False
                self.numericTurn = 0 #set turn to quantitative variable for logging
                self.the_gain[1] = -1*self.the_gain[1]
                self.trip_type = 'right' #at the end of the 360 trial, we move on to a right trial
                self.tripType = 2
                


        if self.turn:
            if self.trip_type == 'left': #if this is a left trip, our panels current yaw will be 0 deg
                return [1,(self.turn_type*180*((time.time()-self.time_turn)/(self.total_time_turn)))%360,1,data.panel_x]
            if self.trip_type == 'right': #if this is a right trip, our panels current yaw will be 180 deg
                return [1,(180+self.turn_type*180*((time.time()-self.time_turn)/(self.total_time_turn)))%360,1,data.panel_x]
            if self.trip_type == 'left_360_turn_first_half': #if this is a left trip, our panels current yaw will be 0 deg
                return [1,(self.turn_type*360*((time.time()-self.time_turn)/(self.total_time_turn*2)))%360,1,data.panel_x]
            if self.trip_type == 'left_360_turn_second_half': #if this is a left trip, our panels current yaw will be 0 deg
                return [1,(self.turn_type*180*((time.time()-self.time_turn)/(self.total_time_turn)))%360,1,data.panel_x]
        elif self.trip_type == 'right':
            return [1,180,0,data.panel_x] 
        elif self.trip_type == 'left':
            return [1,0,0,data.panel_x]
        elif self.trip_type == 'left_360_turn_first_half':
            return [1,0,0,data.panel_x]
        elif self.trip_type == 'left_360_turn_second_half':
            return [1,0,0,data.panel_x]


    def is_inside_theta(self, data):
        angle_test = data.panel_heading
        difference = (angle_test - self.new_goal_heading) % 360
        return 7*int(difference < (self.goal_window/2) or difference > 360 - (self.goal_window/2))

    def gradient_opto_value(self, data):
        angle_test = data.panel_heading
        difference = (angle_test - self.new_goal_heading) % 360
        if (difference < (self.goal_window / 2) or difference > 360 - (self.goal_window / 2)):
            if difference > 180:
                new_difference = 360 - difference
            else:
                new_difference = difference
            ratio = 1 - new_difference/(self.goal_window / 2)
            return round(ratio*10)
        else:
            return 0
