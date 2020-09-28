function stopOpto(src, event)
  
     if (mean(event.Data(:,8)) > 2 & isnan(src.UserData.time))
           src.UserData.time = clock;
     end
       
     if sum(clock-src.UserData.time) > 1.0 
         Panel_com('stop');
         Panel_com('all_off');
         src.stop() 
     end
    
end