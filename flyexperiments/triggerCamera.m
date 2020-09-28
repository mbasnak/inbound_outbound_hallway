%short code to trigger the camera to film proboscis extension for tests

for count = 1:3

s = daq.createSession('ni');
s.addDigitalChannel('Dev1', 'port0/line2', 'OutputOnly');
ai_channels_used = [1:8];
aI = s.addAnalogInputChannel('Dev1', ai_channels_used, 'Voltage');
for i=1:length(ai_channels_used)
aI(i).InputType = 'SingleEnded';
end
s.Rate = 1500;
s.Rate = int64(s.Rate);
t_duration = 30;
t_duration = int64(t_duration);
camera_rate = 30;
camera_trigger{count} = zeros(s.Rate*t_duration,1);
camera_trigger{count}(1:s.Rate/camera_rate:end) = 1;
queueOutputData(s, camera_trigger{count});
s.startForeground(); %start the acquisition


end


