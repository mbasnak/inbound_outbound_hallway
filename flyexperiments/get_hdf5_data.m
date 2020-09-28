%code to get the data from the hdf5 file

file_name = 'hdf5_inbound_outbound_Closed_Loop_X_Closed_Loop_Y_20200922_121240_sid_4_tid_1000001';

trial_counter = h5read([file_name,'.hdf5'],'/trial_counter');
timestamp = h5read([file_name,'.hdf5'],'/time');
trip_type = h5read([file_name,'.hdf5'],'/trip_type');
turn = h5read([file_name,'.hdf5'],'/turn');
gain = h5read([file_name,'.hdf5'],'/gain');
voltage_out = h5read([file_name,'.hdf5'],'/output_voltage_x_gain');
panel_x = h5read([file_name,'.hdf5'],'/panel x');
first_frame = h5read([file_name,'.hdf5'],'/first_frame');
velx = h5read([file_name,'.hdf5'],'/velx');
 

figure,
subplot(5,1,1)
plot(timestamp,trial_counter)
subplot(5,1,2)
plot(timestamp,turn)
subplot(5,1,3)
plot(timestamp,trip_type)
subplot(5,1,4)
plot(timestamp,gain(2,:))
subplot(5,1,5)
plot(timestamp,voltage_out)

figure,
plot(timestamp,trial_counter)
hold on
plot(timestamp,turn)
plot(timestamp,trip_type)
plot(timestamp,gain(2,:))
plot(timestamp,voltage_out)
plot(timestamp,panel_x/100)

figure,
plot(timestamp,panel_x)

figure,
plot(first_frame)
hold on
plot(trial_counter)

figure,
plot(timestamp,voltage_out)
hold on
plot(timestamp,trial_counter)
plot(timestamp,panel_x/10)
