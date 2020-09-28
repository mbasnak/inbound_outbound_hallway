function FlyData = getFlyInfo(varargin)
%{
GETFLYINFO Used in the case of a new fly to get information from the user about this
fly/experimental parameters/particulars of the dissection

OUTPUT

FlyData (struct)
.line (genotype/Gal4/effector...)
.eclosionDate
.starvation time

All of these subfields are obtained from the user and saved
%}

%% Ask user for input
FlyData.line = inputdlg('Genotype: ');

% Get eclosion date
FlyData.eclosionDate = inputdlg('Ecclosion date: ');

% Get starvation time
FlyData.starvationTime = inputdlg('Starvation time (h): ');

% Get temperature
FlyData.temperature = inputdlg('Temperature (C): ');

% Get humidity
FlyData.humidity = inputdlg('Humidity (%): ');

% Save
end
