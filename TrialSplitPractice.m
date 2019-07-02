function [calibration_sequence] = TrialSplitPractice()
    
    spider_start_times = [2;9];
    spider_vids = ["Spider_6.mov";"Spider_19.mov"];
    spider_condition = ones(2,1) * 3;
    
    heights_start_times = [9;14];
    heights_vids = ["Heights_6.mp4";"Heights_19.m4v";];
    heights_condition = ones(2,1);
    
    pain_low = 2;
    pain_high = 6;
    pain_stim = [pain_high;pain_low;];
    pain_stim = string(pain_stim);
    pain_start_time = nan(2,1);
    pain_condition = ones(2,1) * 2;
    
    table_name_list = {'stimulus','start_times','condition'};
    
    spider_vids = table(spider_vids, spider_start_times, spider_condition,'VariableNames',table_name_list);
    heights_vids = table(heights_vids, heights_start_times, heights_condition,'VariableNames', table_name_list);
    pain_stim = table(pain_stim, pain_start_time, pain_condition,'VariableNames', table_name_list);
    
    %need to concatenate video start times

    calibration_sequence = OrderTrials(spider_vids, heights_vids, pain_stim);

end

function calibration_sequence = OrderTrials(spider_vids, heights_vids, pain_stim)
    
    stim = vertcat(pain_stim,spider_vids);
    stim = vertcat(stim,heights_vids);
    
    calibration_sequence = struct;
    for i=1:height(stim)
        calibration_sequence(i).stimulus = stim{i,1};
        calibration_sequence(i).start = stim{i,2};
        calibration_sequence(i).condition = stim{i,3};
        calibration_sequence(i).video_trial = contains(stim{i,1}, 'm');%all movies are mov,mp4,m4v pain is not  
    end
end

