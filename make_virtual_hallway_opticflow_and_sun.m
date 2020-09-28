%Make pattern that has low contrast gratings with front to back
%optic flow to the sides as the animal moves forward and a constant 'Sun'
%cue to the side

clear all; close all;

pattern.x_num = 96; % number of pixels in the x axis (there are 8 pixels per panel, and 12 panels)
pattern.y_num = 92; 
pattern.num_panels = 36; % there are 36 panels
pattern.gs_val = 4; % we are setting the grayscale value at 3 for defining the intensity of the blue LEDs.
%The blue bars of the gratings will be gs_val = 1, and the sun will be
%gs_val = 3;
Pats = zeros(24, 96, pattern.x_num, pattern.y_num);

%Because of how my LED panels are arranged, the right side of the stimulus
%goes from px 71 in the front to px 22 in the back, and the left side of
%the stimulus goes from px 70 in the front to px 23 in the back
%My stim pattern will then have a structure where I separate in sections
%what happens with pxs 1-22, 23-70 and 71-96.

stripe_pattern{1} = [zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,2),zeros(24,1)                               ,zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,2),zeros(24,1)          ,zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,2),zeros(24,1)];
stripe_pattern{2} = [zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,2)                                           ,repmat([ones(24,2),zeros(24,2)],1,12)                                             ,zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,2)];
stripe_pattern{3} = [ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,1)                                ,ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,1)           ,ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,1)];
stripe_pattern{4} = [repmat([ones(24,2),zeros(24,2)],1,5)                                                                  ,zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,2)                      ,repmat([ones(24,2),zeros(24,2)],1,7)];
stripe_pattern{5} = [zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,2),zeros(24,1)                               ,zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,2),zeros(24,1)          ,zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,2),zeros(24,1)];
stripe_pattern{6} = [zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,2)                                           ,repmat([ones(24,2),zeros(24,2)],1,12)                                             ,zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,2)];
stripe_pattern{7} = [ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,1)                                ,ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,1)           ,ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,1)];
stripe_pattern{8} = [repmat([ones(24,2),zeros(24,2)],1,5)                                                                  ,zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,2)                      ,repmat([ones(24,2),zeros(24,2)],1,7)];
stripe_pattern{9} = [zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,2),zeros(24,1)                               ,zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,2),zeros(24,1)          ,zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,2),zeros(24,1)];
stripe_pattern{10} = [zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,2)                                           ,repmat([ones(24,2),zeros(24,2)],1,12)                                             ,zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,2)];
stripe_pattern{11} = [ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,1)                                ,ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,1)           ,ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,1)];
stripe_pattern{12} = [repmat([ones(24,2),zeros(24,2)],1,5)                                                                  ,zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,2)                      ,repmat([ones(24,2),zeros(24,2)],1,7)];
stripe_pattern{13} = [zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,2),zeros(24,1)                               ,zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,2),zeros(24,1)          ,zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,2),zeros(24,1)];
stripe_pattern{14} = [zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,2)                                           ,repmat([ones(24,2),zeros(24,2)],1,12)                                             ,zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,2)];
stripe_pattern{15} = [ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,1)                                ,ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,1)           ,ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,1)];
stripe_pattern{16} = [repmat([ones(24,2),zeros(24,2)],1,5)                                                                  ,zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,2)                      ,repmat([ones(24,2),zeros(24,2)],1,7)];
stripe_pattern{17} = [zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,2),zeros(24,1)                               ,zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,2),zeros(24,1)          ,zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,2),zeros(24,1)];
stripe_pattern{18} = [zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,2)                                           ,repmat([ones(24,2),zeros(24,2)],1,12)                                             ,zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,2)];
stripe_pattern{19} = [ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,1)                                ,ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,1)           ,ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,1)];
stripe_pattern{20} = [repmat([ones(24,2),zeros(24,2)],1,5)                                                                  ,zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,2)                      ,repmat([ones(24,2),zeros(24,2)],1,7)];
stripe_pattern{21} = [zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,2),zeros(24,1)                               ,zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,2),zeros(24,1)          ,zeros(24,1),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,2),zeros(24,1)];
stripe_pattern{22} = [zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,2)                                           ,repmat([ones(24,2),zeros(24,2)],1,12)                                             ,zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,2)];
stripe_pattern{23} = [ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,4),ones(24,1)                                ,ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,1)           ,ones(24,1),zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,6),ones(24,1)];
stripe_pattern{24} = [repmat([ones(24,2),zeros(24,2)],1,5)                                                                  ,zeros(24,2),repmat([ones(24,2),zeros(24,2)],1,11),ones(24,2)                      ,repmat([ones(24,2),zeros(24,2)],1,7)];



for i = 25:58
    stripe_pattern{i} = stripe_pattern{24};
end

for i = 59:92
    stripe_pattern{i} = stripe_pattern{1};
end

for y = 1:pattern.y_num %for every y dimension
    
    Pats(:,:,1,y) = stripe_pattern{1,y}; %the x dim = 1 will be the stripe pattern for that dimension
    Pats(:,45:46,1,y) = 3; %add the Sun stimulus
    
    for x = 2:pattern.x_num
        Pats(:,:,x,y) = circshift(Pats(:,:,x-1,y),[0,1]); %the other x dims will be shifting one px in yaw per 1 dim shift
    end

end


% map = [0 0 0; 0 0 1];
% 
% video = VideoWriter('hallway.avi'); %create the video object
% open(video); %open the file for writing
% for i=1:13 %where N is the number of images
%   hAxes = gca;
%   imagesc(hAxes, Pats(:,:,1,i))
%   colormap(hAxes , map)
%   set(gca,'XTick',[], 'YTick', [])
%   saveas(gcf,['pattern',num2str(i),'.jpg'])
%   I = imread(['pattern',num2str(i),'.jpg']); %read the next image
%   writeVideo(video,I); %write the image to file
%   pause(1)
% end
% close(video); %close the file



pattern.Pats = Pats;


pattern.Panel_map = [36 32 28 35 31 27 34 30 26 33 29 25;...
                     24 20 16 23 19 15 22 18 14 21 17 13;...
                     12 8 4 11 7 3 10 6 2 9 5 1];

pattern.Panel_map = pattern.Panel_map;
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);



%% Save data

directory_name = 'C:\Users\Wilson\Desktop\panels-matlab_071618\Patterns\mel360_36panels';
str = [directory_name '\Pattern038_vhallway_with_opticflow_and_sun'];
save(str, 'pattern'); % save the file in the specified directory