%This function stops the panels and the data acquisition when the time
%reaches the trial time from the GUI

function outOfTime(src, event)
  
     if  mean(event.TimeStamps) > mean(src.UserData.TrialTime)
         Panel_com('stop')
         Panel_com('all_off')
         src.stop()
     end
          
end