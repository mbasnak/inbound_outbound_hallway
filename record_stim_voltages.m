%code to measure voltage of stimuli in the behavior room

%set the NiDaq session
s = daq.createSession('ni');
%ai_channels_used = [1:3,11:15]; %2P room
ai_channels_used = [1:8]; %behavior room
aI = s.addAnalogInputChannel('Dev1', ai_channels_used, 'Voltage');
for i=1:length(ai_channels_used)
    aI(i).InputType = 'SingleEnded';
end
%aI(9) = s.addAnalogInputChannel('Dev1', 12, 'Voltage'); %2P room
%aI(9).InputType = 'SingleEnded'; %2P room

settings = sensor_settings;
SAMPLING_RATE = settings.sampRate;
s.Rate = SAMPLING_RATE; 

voltages = {};

for i = 1:92
    s.DurationInSeconds = 3;
    Panel_com('set_pattern_id', 38); %set the bar
    Panel_com('set_mode', [0 0]); %set it to closed-loop mode in the x dimension and to be controlled by a function in the y dimension 
    pause(0.03)
    Panel_com('set_position',[1 i]);
    pause(0.03)
    Panel_com('start');
    voltages{i} = s.startForeground(); %this will acquire the channels described above for the length of time also defined
    pause(2);    
    Panel_com('stop');
end


medianVoltages = [];

for i = 1:92
    medianVoltages(i) = median(voltages{i}(:,5));
end

save('C:\Users\Wilson\Desktop\inbound_outbound_hallway\stimulusVoltages.mat','medianVoltages')
