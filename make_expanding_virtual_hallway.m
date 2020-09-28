%Make virtual hallway that is always on the front of the animal, and it
%expands with y dimensions, but doesn't move in ya (stays constant in x for
%every y value)


pattern.x_num = 96; % number of pixels in the x axis (there are 8 pixels per panel, and 12 panels)
pattern.y_num = 92; 
pattern.num_panels = 36; % there are 16 panels
pattern.gs_val = 3; % we are setting the grayscale value at 2. This is the intensity
Pats = zeros(24, 96, pattern.x_num, pattern.y_num);



stripe_pattern{1} = [ones(24, 68),zeros(24,1),ones(24,27)];
stripe_pattern{2} = [ones(24, 67),zeros(24,3),ones(24,26)];
stripe_pattern{3} = [ones(24, 66),zeros(24,5),ones(24,25)];
stripe_pattern{4} = [ones(24, 65),zeros(24,7),ones(24,24)];
stripe_pattern{5} = [ones(24, 64),zeros(24,9),ones(24,23)];
stripe_pattern{6} = [ones(24, 63),zeros(24,11),ones(24,22)];
stripe_pattern{7} = [ones(24, 62),zeros(24,13),ones(24,21)];
stripe_pattern{8} = [ones(24, 61),zeros(24,15),ones(24,20)];
stripe_pattern{9} = [ones(24, 60),zeros(24,17),ones(24,19)];
stripe_pattern{10} = [ones(24, 59),zeros(24,19),ones(24,18)];
stripe_pattern{11} = [ones(24, 58),zeros(24,21),ones(24,17)];
stripe_pattern{12} = [ones(24, 57),zeros(24,23),ones(24,16)];

for i = 13:52
    stripe_pattern{i} = stripe_pattern{12};
end

for i = 53:92
    stripe_pattern{i} = stripe_pattern{1};
end

for j = 1:pattern.y_num %for every y dimension
    
    for i = 1:96
        Pats(:,:,i,j) = stripe_pattern{1,j};
    end

end

pattern.Pats = Pats;

pattern.Panel_map = [12 8 4 11 7 3 10 6 2 9 5 1;...
                     24 20 16 23 19 15 22 18 14 21 17 13;...
                     36 32 28 35 31 27 34 30 26 33 29 25];

pattern.Panel_map = pattern.Panel_map;
pattern.BitMapIndex = process_panel_map(pattern);
pattern.data = Make_pattern_vector(pattern);

%% Save data

directory_name = 'C:\Users\Wilson\Desktop\panels-matlab_071618\Patterns\mel360_36panels';
str = [directory_name '\Pattern034_expanding_vhallway'];
save(str, 'pattern'); % save the file in the specified directory