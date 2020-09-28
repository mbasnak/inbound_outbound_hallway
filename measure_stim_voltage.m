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
s.DurationInSeconds = 100;

lh = addlistener(s,'DataAvailable',@plotData);
startBackground(s);
wait(s)

function plotData(src,event)
    %2P room
%     if  (mode(event.Data(:,6)) < 7.5)
%          plot(event.TimeStamps,event.Data(:,6))
%     end
%     
    %behavior room
    if  (mode(event.Data(:,5)) < 7.5)
         plot(event.TimeStamps,event.Data(:,4))
    end    
    
end



