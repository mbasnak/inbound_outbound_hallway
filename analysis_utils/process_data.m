function [ t, disp_for, disp_side, disp_yaw, fr, angle, vel_for, vel_side, vel_yaw, opto] = process_data( trial_time, trial_data, num_frames)

settings = sensor_settings;
settings.fictrac_x_DAQ_AI = 3;
%settings.fictrac_yaw_DAQ_AI = 1;
settings.fictrac_yaw_gain_DAQ_AI = 1;
settings.fictrac_x_gain_DAQ_AI = 7; 
settings.fictrac_y_DAQ_AI = 2;

settings.panels_x_DAQ_AI = 4;
settings.panels_y_DAQ_AI = 5;
settings.panels_ON_DAQ_AI = 6;
settings.opto_DAQ_AI = 8; %this is not true


ft_for = trial_data( :, settings.fictrac_x_DAQ_AI );
ft_yaw = trial_data( :, settings.fictrac_yaw_gain_DAQ_AI );
ft_side = trial_data( :, settings.fictrac_y_DAQ_AI );
panels = trial_data( :, settings.panels_x_DAQ_AI );
raw_opto = trial_data( :, settings.opto_DAQ_AI );


[ vel_for, disp_for ] = ficTracSignalDecoding(ft_for, settings.sampRate, settings.sensorPollFreq, 20); 
[ vel_yaw, disp_yaw ] = ficTracSignalDecoding(ft_yaw, settings.sampRate, settings.sensorPollFreq, 20);
[ vel_side, disp_side ] = ficTracSignalDecoding(ft_side, settings.sampRate, settings.sensorPollFreq, 20);
[ fr, angle] = process_panel_360( panels, num_frames );
[ t ] = process_time( trial_time );
[ opto ] = process_opto( raw_opto );

end

