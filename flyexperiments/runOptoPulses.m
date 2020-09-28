
function runOptoPulses(experiment_time, time_between_pulses, pulse_duration)

%function to run short trial at the end with opto pulses at fixed intervals
cd('C:\Users\Wilson\Desktop\inbound_outbound_hallway\experiment');

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
total_duration = experiment_time;
total_duration = int64(total_duration);


%setting up the camera trigger
camera_rate = 10; %set the frame rate to be 10 hz
camera_trigger= zeros(s.Rate*total_duration,1); %pre-allocate the number of frames needed according to the max trial duration
camera_trigger(1:s.Rate/camera_rate:end) = 1;
imaging_trigger= zeros(s.Rate*total_duration,1);

output_data = [camera_trigger,imaging_trigger];
queueOutputData(s, output_data);

%run the python code
system(['python run_opto_pulses.py ' num2str(total_duration) ' ' num2str(time_between_pulses) ' ' num2str(pulse_duration) ' 1 &']);

%start the NiDaq Acquisition and camera triggering
rawData = s.startForeground();

system('exit');
release(s);

%save the data
%select folder to save the data
path = uigetdir();
save([path,'\dataOptoPulses.mat'],'rawData'); %save as dataExpNum

end

