function logTrialData(fid,evt,trip_type,trip_counter)
%This function logs trial data to a txt file.

    % Code trip types as numbers for simplicity
    if strcmp(trip_type,'left') == 1
        tripType = 1;
    elseif strcmp (trip_type,'right') == 1
        tripType = 2;
    else
        tripType = 3;
    end
    
    % make matrix for data to be written in
    trial_data = [evt.TimeStamps, evt.Data, tripType, trip_counter]';
       
    % precision is only single
    fwrite(fid,trial_data,'double');
end