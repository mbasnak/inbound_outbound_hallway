import os
import sys
sys.path.insert(0, os.path.abspath('C:/Users/Wilson/Desktop/inbound_outbound_hallway'))
from fictrac_2d import OptoPulses

def opto_pulses_code(experiment_time = 300, time_between_pulses = 10, pulse_duration = 1):
    experiment_param = {
        'experiment_time': int(experiment_time), #this is the trial length    
        'time_between_pulses': int(time_between_pulses), #the experiment number determines the experiment type, with
        'pulse_duration': int(pulse_duration), #for menotaxis, time between bar jumps
        'trigger_device_port': '/./COM6'
    }
    client2 = OptoPulses(experiment_param) #use the parameters to run FicTrac2D, found in fictrac_2d.py
    client2.run()

if __name__ == '__main__':

    if len(sys.argv) > 1:    #from the list of arguments given to the system by the matlab code run_trial
        experiment_time = int(sys.argv[1]) #make the first argument be the experiment...
        time_between_pulses = float(sys.argv[2]) #...etc
        pulse_duration = float(sys.argv[3])
        opto_pulses_code(experiment_time,time_between_pulses, pulse_duration)
    else:
        opto_pulses_code()