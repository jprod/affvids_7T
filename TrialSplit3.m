function [spider_vids, heights_vids, pain_stim, intensity_levels] = TrialSplit3()

    spider_start_times = [  
        1;
        1;
        1;
        1;
        1;
        1;
        1;
        1;
        1;
        % 1;
        1;
        1;
        1;
        1;
        % 1;
        1;
        % 1;
        % 1;
        1;
        1;
        1;
        1;
        1;
        1 ...
        ];

    spider_vids = [ % NOTE MISSING SPIDERS_37 (rep with 68)
        "Spiders_25.mov";...
        "Spiders_26.m4v";...
        "Spiders_27.mov";...
        "Spiders_28.m4v";...
        "Spiders_29.m4v";...
        "Spiders_30.mov";...
        "Spiders_31.m4v";...
        "Spiders_32.mov";...
        "Spiders_33.m4v";...
        % "Spiders_34.m4v";...
        "Spiders_35.mov";...
        "Spiders_36.m4v";...
        "Spiders_61.mp4";...
        "Spiders_62.mp4";...
        % "Spiders_63.mp4";...
        "Spiders_64.mp4";...
        % "Spiders_65.mp4";...
        % "Spiders_66.mp4";...
        "Spiders_67.mp4";...
        "Spiders_68.mp4";...
        "Spiders_69.mp4";...
        "Spiders_70.mp4";...
        "Spiders_71.mp4";...
        "Spiders_72.mp4";...  
        ];
    
    spider_levels = [
        0;
        1;
        1;
        1;
        1;
        1;
        1;
        0;
        0;
        0;
        0;
        1;
        1;
        1;
        0;
        0;
        0;
        1;
        0;
        0;
    ];

    heights_start_times = [ 
        1;
        1;
        % 1;
        1;
        1;
        1;
        1;
        1;
        1;
        1;
        1;
        1;
        % 1;
        % 1;
        1;
        1;
        % 1;
        1;
        1;
        1;
        1;
        1;
        1;
        1 ...
        ];
    heights_vids = [
        "Heights_01.m4v";...
        "Heights_02.mov";...
        % "Heights_03.m4v";...
        "Heights_04.m4v";...
        "Heights_05.mov";...
        "Heights_06.mov";...
        "Heights_07.m4v";...
        "Heights_08.m4v";...
        "Heights_09.mov";...
        "Heights_10.m4v";...
        "Heights_11.m4v";...
        "Heights_12.m4v";...
        % "Heights_37.mp4";...
        % "Heights_38.mp4";...
        "Heights_39.mp4";...
        "Heights_40.mp4";...
        % "Heights_41.mp4";...
        "Heights_42.mp4";...
        "Heights_43.mp4";...
        "Heights_44.mp4";...
        "Heights_45.mp4";...
        "Heights_46.mp4";...
        "Heights_47.mp4";...
        "Heights_48.mp4";...
        ];

    heights_levels = [
        1;
        1;
        1;
        1;
        1;
        0;
        0;
        0;
        0;
        0;
        0;
        0;
        1;
        1;
        0;
        1;
        0;
        0;
        1;
        1;
    ];

    spider_vids = horzcat(spider_vids, spider_start_times, spider_levels);
    heights_vids = horzcat(heights_vids, heights_start_times, heights_levels);
    
    %need to concatenate video start times
    % pain_low  = [2;2;2;2;3;3;3;3;4;4;4;4];
    % pain_high = [5;5;5;5;6;6;6;6;7;7;7;7];
    pain_low  = [0.5;0.5;0.5;0.5;0.5;0.5;0.5;0.5;0.5;0.5];
    pain_high = [1;1;1;1;1;1;1;1;1;1];
    pain_stim = sort([pain_low;pain_high]);
    pain_stim = string(pain_stim);
    pain_level  = [0;0;0;0;0;0;0;0;0;0;1;1;1;1;1;1;1;1;1;1];
    pain_stim = horzcat(pain_stim, pain_level);

    heights_vids = flip(heights_vids);
    spider_vids = flip(spider_vids);

end