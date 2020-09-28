function [fr, angle] = process_panel_360(rawData, frames)
%% 360 arena July 2018
% Proceel panel 360: take input raw voltage data from DAQ from panels and
% number of frames and returns the frame number and angle of the bar. This
% is given the setup of JL pattern and panel positions in the physical
% arena.

% Initial variables
settings = sensor_settings;
maxVal = 10;
minVal = 0;
initialAngle = -27;
barWidth = 2;
voltsPerStep = (maxVal-minVal)./(frames-1);

rate = 2*(50/settings.sampRate);
[kb, ka] = butter(2,rate);

% Set limits on voltage; then filter
rawData(rawData < minVal) = minVal;
rawData(rawData > maxVal) = maxVal;

smoothedData = filtfilt(kb, ka, rawData);

% Calculate the frame number (round to nearest integer), calculate the
% pixel angle of the bar given the grame number.
fr = round((smoothedData - minVal)./voltsPerStep);
pixelAngle = 360./96;
arenaAngle = frames*pixelAngle;
angle = (initialAngle-((fr-1)+barWidth/2).*pixelAngle); % accounts for the bar width
%angle = (fr+1+initialAngle).*pixelAngle;

% Wrap to 180 
angle = wrapTo180(angle);
if arenaAngle < 360
    halfArena = arenaAngle./2;
    indexOver = angle < -halfArena;
    angle = angle + indexOver.*arenaAngle;
end

%% 4-5-19 downsampling
settings = sensor_settings;

n = floor(settings.sampRate/settings.sensorPollFreq);

% dt = settings.sampRate/settings.sensorPollFreq;
% x = floor(length(angle)/dt);
% cut_length = x*dt;
% angle = deg2rad(angle);
% angle_downsampled = squeeze(circ_mean(reshape(angle(1:cut_length), [n, x])));
% angle_downsampled = rad2deg(angle_downsampled);

angle_downsampled = downsample(angle, n);
angle = angle_downsampled;

% fr_to_rad = 2*pi.*fr/96;
% fr_downsampled = squeeze(circ_mean(reshape(fr_to_rad(1:cut_length), [n, x])));
% fr_downsampled = round(fr_downsampled*96./(2*pi));

fr_downsampled = downsample(fr, n);
fr = fr_downsampled;