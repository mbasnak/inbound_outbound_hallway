function stopExp(src, event, fidTrial)
  
   
%LEFT TRIP    
    %If this is an left trip and the animal has reached the end of the
    %hallway
     if (mode(event.Data(:,5)) > 4.9 && mode(event.Data(:,5)) < 7.5) && (strcmp(src.UserData.trip_type, 'left') == 1)

         % change the trip_type to right
       if src.UserData.trip_counter < (src.UserData.trip_number - 1)
           src.UserData.trip_type = 'right';
           src.UserData.trip_counter = src.UserData.trip_counter + 1;
           disp([src.UserData.trip_type, ' trip# '])
           disp(src.UserData.trip_counter)
           
           tripType = 2;
           % make matrix for data to be written in
           trial_data = [0,median(event.TimeStamps),tripType,src.UserData.trip_counter];
           % precision is only single
           fwrite(fidTrial,trial_data,'double');
           
            
       %otherwise, if you've reached the desired trip number, stop panels and the experiment    
       else
            Panel_com('stop');
            Panel_com('all_off');  
                       
            %stop the NiDaq
            src.stop()

       end  
     
     %I'm adding changes for the 360 loops - MB 20200805
     %For the 360 loop trips, where left trips will reach 10 V
     elseif (mode(event.Data(:,5)) < 9.7 && mode(event.Data(:,5)) > 9.3) && (strcmp(src.UserData.trip_type, 'left360') == 1)
        src.UserData.trip_type = 'right';
        src.UserData.trip_counter = src.UserData.trip_counter + 1;
        disp([src.UserData.trip_type, ' trip# '])
        disp(src.UserData.trip_counter)
        tripType = 2;
        %         % make matrix for data to be written in
        trial_data = [0,median(event.TimeStamps),tripType,src.UserData.trip_counter];
        %         % precision is only single
        fwrite(fidTrial,trial_data,'double');

       
%RIGHT TRIP       
       %If this is an right trip and the animal has reached the start of the
    %hallway
     elseif (mode(event.Data(:,5)) < 0.3) && (strcmp(src.UserData.trip_type, 'right') == 1)

       %if there have been less than the total trip number, keep going, change the
       %trip_type to left and add a trip to the trip_counter
       if src.UserData.trip_counter < (src.UserData.trip_number - 1)
           if (src.UserData.trip_counter ~= 14) && (src.UserData.trip_counter ~= 22) && (src.UserData.trip_counter ~= 32) && (src.UserData.trip_counter ~= 42) && (src.UserData.trip_counter ~= 52)
                src.UserData.trip_type = 'left';
                src.UserData.trip_counter = src.UserData.trip_counter + 1;
                disp([src.UserData.trip_type, ' trip# '])
                disp(src.UserData.trip_counter)
                tripType = 1;
                %         % make matrix for data to be written in
                trial_data = [0,median(event.TimeStamps),tripType,src.UserData.trip_counter];
                %         % precision is only single
                fwrite(fidTrial,trial_data,'double');

           else
                src.UserData.trip_type = 'left360'; %If we're about to start trips 9 or 17, set the trip type of left360
                src.UserData.trip_counter = src.UserData.trip_counter + 1; 
                disp([src.UserData.trip_type, ' trip# '])
                disp(src.UserData.trip_counter)
                tripType = 3;
                %         % make matrix for data to be written in
                trial_data = [0,median(event.TimeStamps),tripType,src.UserData.trip_counter];
                %         % precision is only single
                fwrite(fidTrial,trial_data,'double');

           end
           
       %otherwise, if you've reached the total number of trips, stop the panels and the experiment    
       else
           Panel_com('stop');
           Panel_com('all_off');                    
           src.stop()

       end  
       
     else
              
     end
    
end