%I'm making a new function to run the trial based on the distance travelled
%and not the time

function [ trial_data, trial_time ] = run_trial_vHallway(tid, task, run_obj, scanimage_client, trial_core_name, probe_status )
cd('C:\Users\Wilson\Desktop\conditioned_menotaxis-master\experiment');

% Currently v2
disp(['About to start trial task: ' task]);

% Setup data structures for read / write on the daq board
s = daq.createSession('ni');

% This channel is for external triggering of scanimage 5.1
%s.addDigitalChannel('Dev1', 'port0/line0', 'OutputOnly');
%s.addAnalogOutputChannel('Dev1', 0, 'Voltage');
s.addDigitalChannel('Dev1', 'port0/line2', 'OutputOnly');

%  
ai_channels_used = [1:8];

aI = s.addAnalogInputChannel('Dev1', ai_channels_used, 'Voltage');
for i=1:length(ai_channels_used)
    aI(i).InputType = 'SingleEnded';
end

settings = sensor_settings;
SAMPLING_RATE = settings.sampRate;
s.Rate = SAMPLING_RATE;
s.Rate = int64(s.Rate);
total_duration = run_obj.trial_t;
total_duration = int64(total_duration);

camera_rate = 30;
camera_trigger= zeros(s.Rate*total_duration,1);
camera_trigger(1:s.Rate/camera_rate:end) = 1;

output_data = [camera_trigger];
queueOutputData(s, output_data);

% Trigger scanimage run if using 2p.
if(run_obj.using_2p == 1)
    scanimage_file_str = ['cdata_' trial_core_name '_tt_' num2str(total_duration) '_'];
    fprintf(scanimage_client, [scanimage_file_str]);
    disp(['Wrote: ' scanimage_file_str ' to scanimage server' ]);
    acq = fscanf(scanimage_client, '%s');
    disp(['Read acq: ' acq ' from scanimage server' ]);    
end

experiment_type = classify_opto(run_obj.experiment_number);
arduino = double(~(run_obj.experiment_number == 1));

cur_trial_corename = [experiment_type '_' task '_' datestr(now, 'yyyymmdd_HHMMSS') '_sid_' num2str(run_obj.session_id) '_tid_' num2str(tid)];
cur_trial_file_name = [ run_obj.experiment_ball_dir '\hdf5_' cur_trial_corename '.hdf5' ];

hdf_file = cur_trial_file_name;
    

system(['python run_experiment.py ' num2str(run_obj.experiment_number) ' ' num2str(run_obj.trial_t) ' ' num2str(run_obj.bar_jump_time) ' '...
    num2str(run_obj.hold_time) ' ' num2str(run_obj.pre_training) ' ' num2str(run_obj.training) ' ' num2str(run_obj.goal_change) ' ' num2str(run_obj.goal_window) ' '...
    num2str(arduino) ' "' hdf_file '" ' num2str(probe_status) ' 1 &']);

% I'm changing this to make the trial go until the animal reaches the end
% of the hallway, instead of doing it a certain length - MB 20190806

% Begin Panels 
Panel_com('set_pattern_id', run_obj.pattern_number);
Panel_com('set_mode', [3, 3]);
Panel_com('set_position', [1, 1]);
Panel_com('quiet_mode_on');
Panel_com('start');

%Run with the background instead
fid = fopen('log.dat','w+');
s.UserData.time = NaN;
lh = s.addlistener('DataAvailable',@(src,event)logDaqData(fid,event));
lh2 = s.addlistener('DataAvailable', @(src,event)stopF(src,event));
s.IsContinuous = true;

%I'm adding a third listener to kill the acquisition if the trial has
%reached the trial time that we determined in the GUI
s.UserData.TrialTime = repelem(run_obj.trial_t,1,20);
lh3 = s.addlistener('DataAvailable',@(src,event)outOfTime(src,event));

%run the acquisition while trial_time is empty
s.startBackground(); %start the acquisition

while ~s.IsDone
    pause(.05)
end

trial_time = loadTimeFromLogFile('log.dat',8);
trial_data = loadFromLogFile('log.dat',8); %save the trial data and output as trial_data
trial_data = trial_data';

%stop the panels in case they were left on
Panel_com('stop')
Panel_com('all_off')

%delete the handlers
delete(lh);
delete(lh2);
delete(lh3);

system('exit');
release(s);

end

function experiment_name = classify_opto(experiment_number)
    if experiment_number == 2
        experiment_name = 'menotaxis';
    elseif experiment_number == 3
        experiment_name = 'conditionedmenotaxis';
    elseif experiment_number == 4
        experiment_name = 'jump_hold';
    elseif experiment_number == 5
        experiment_name = 'hallway';
    elseif experiment_number == 6
        experiment_name = 'fictivesugar';
    elseif experiment_number == 7
        experiment_name = 'virtualHallway';
    else
        experiment_name = 'spontaneous';
    end
end


function closedClosedLoop(pattern, startPosition)
%% begins closedLoop setting in panels
freq = 50;
Panel_com('stop');
Panel_com('g_level_7');
%set pattern number
Panel_com('set_pattern_id', pattern);
%set closed loop for x and y
Panel_com('set_mode', [3, 3]);
Panel_com('set_position', [startPosition, 1]);
%quiet mode on
Panel_com('quiet_mode_on');
end
