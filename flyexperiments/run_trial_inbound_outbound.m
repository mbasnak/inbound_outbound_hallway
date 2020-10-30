%This matlab code runs the panels for the 'inbound/outbound' experiment,
%and trigger the python code that will run that as well

function [ trial_data, trial_time, probe_trials, trip_counter, trialData, flyData] = run_trial_inbound_outbound(tid, task, run_obj, scanimage_client, trial_core_name)
cd('C:\Users\Wilson\Desktop\inbound_outbound_hallway\experiment');

disp(['About to start trial task: ' task]);

% Setup data structures for read / write on the daq board
s = daq.createSession('ni');

% This channel is for external triggering of the camera
s.addDigitalChannel('Dev1', 'port0/line2', 'OutputOnly');
% This channel is for external triggering of scanimage 5.1
s.addDigitalChannel('Dev1', 'port0/line6', 'OutputOnly');

ai_channels_used = [1:9];
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

%setting up the camera trigger
camera_rate = 1

0; %set the frame rate to be 10 hz
camera_trigger= zeros(s.Rate*total_duration,1); %pre-allocate the number of frames needed according to the max trial duration
camera_trigger(1:s.Rate/camera_rate:end) = 1;
imaging_trigger= zeros(s.Rate*total_duration,1);

output_data = [camera_trigger,imaging_trigger];
%output_data = imaging_trigger;
queueOutputData(s, output_data);

%I'm now making the probe trials not random, but rather have a pattern such
%that there is the same number of left and right 
trialPattern = [ones(1,3),0,ones(1,2),0];
allTrials = repmat(trialPattern,1,ceil(run_obj.trip_number/7));
allTrials = [repelem(0,6),allTrials];
allTrials = allTrials(1:run_obj.trip_number);
all_probe_trials = find(allTrials==0);
all_probe_trials = all_probe_trials(all_probe_trials > 6);
all_probe_trials = [1:6,all_probe_trials]';%I'm making the first 6 trials be probe to later compare the flies' behavior during those probe trials vs the following probe trials
all_probe_trials = sort([all_probe_trials;36;40;50]);


%for now (20191231)
probe_trials = mat2str(all_probe_trials);
inbound_360 = mat2str(0);
outbound_360 = mat2str(0);

% Trigger scanimage run if using 2p.clc
if(run_obj.using_2p == 1)
    scanimage_file_str = ['cdata_' trial_core_name '_tt_' num2str(total_duration) '_'];
    fprintf(scanimage_client, [scanimage_file_str]);
    disp(['Wrote: ' scanimage_file_str ' to scanimage server' ]);
    acq = fscanf(scanimage_client, '%s');
    disp(['Read acq: ' acq ' from scanimage server' ]);    
end

experiment_type = 'inbound_outbound';
arduino = double(~(run_obj.experiment_number == 1));

cur_trial_corename = [experiment_type '_' task '_' datestr(now, 'yyyymmdd_HHMMSS') '_sid_' num2str(run_obj.session_id) '_tid_' num2str(tid)];
cur_trial_file_name = [ run_obj.experiment_ball_dir '\hdf5_' cur_trial_corename '.hdf5' ];

hdf_file = cur_trial_file_name;
    
%Import stimulus voltage file and convert reward distance to that voltage
load('C:\Users\Wilson\Desktop\inbound_outbound_hallway\stimulusVoltages.mat');
reward_voltage = medianVoltages(round((run_obj.reward_distance*46)/100)); %I think this should be 46, because that's half of the y dimensions, so I'm setting it to that value, MB 20200805

%ask you information about the fly
flyData = getFlyInfo();
%flyData = [];

system(['python run_experiment.py ' num2str(run_obj.experiment_number) ' ' num2str(run_obj.trial_t) ' ' num2str(run_obj.bar_jump_time) ' '...
    num2str(run_obj.hold_time) ' ' num2str(run_obj.pre_training) ' ' num2str(run_obj.training) ' ' num2str(run_obj.goal_change) ' ' num2str(run_obj.goal_window) ' '...
    num2str(arduino) ' "' hdf_file '" ' probe_trials ' ' outbound_360 ' ' inbound_360 ' ' num2str(run_obj.trip_number) ' ' num2str(reward_voltage) ' ' num2str(run_obj.gain_x) ' 1 &']);


% Begin Panels 
Panel_com('set_pattern_id', run_obj.pattern_number);
Panel_com('set_mode', [3, 3]); %set both dimensions to closed-loop
Panel_com('set_position', [1, 1]);
Panel_com('quiet_mode_on');
Panel_com('start');

%Run with the background
fid = fopen('log.dat','w+');
s.UserData.trip_type = 'left'; %define the first trial type as 'left'
s.UserData.trip_counter = 1; %define the start of the trip_counter as 0
s.UserData.trip_number = run_obj.trip_number;
lh = s.addlistener('DataAvailable',@(src,event)logDaqData(fid,event)); %save the data

%Open log file to write the trial data on
fidTrial = fopen('logTrial.dat','w+');

lh2 = s.addlistener('DataAvailable', @(src,event)stopExp(src,event,fidTrial)); %stop the acquisition
s.IsContinuous = true;

%This kills the acquisition if the experiment has
%reached the trial time that we determined in the GUI
s.UserData.TrialTime = repelem(run_obj.trial_t,1,20);
lh3 = s.addlistener('DataAvailable',@(src,event)outOfTime(src,event));
%session_data = read(s, seconds(30));

%run the acquisition while trial_time is empty
s.startBackground(); %start the acquisition

while ~s.IsDone
    pause(.05)
end

trial_time = loadTimeFromLogFile('log.dat',9);
trial_data = loadFromLogFile('log.dat',9); %save the trial data and output as trial_data
trial_data = trial_data';
trip_counter = s.UserData.trip_counter;
trialData = loadFromLogFile('logTrial.dat',3);

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