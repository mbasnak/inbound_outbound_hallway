
function stopF(src, event)
  
     if  (mode(event.Data(:,5)) > 1.26 && mode(event.Data(:,5)) < 7.5)

       if isnan(src.UserData.time)
           src.UserData.time = clock;
           
       elseif (sum(clock-src.UserData.time) > 0.5 && sum(clock-src.UserData.time) < 1.0)
           Panel_com('stop');
           Panel_com('all_off');            
           
       elseif sum(clock-src.UserData.time) > 1.0          
           src.stop()
           
       end
       
    end

    
end