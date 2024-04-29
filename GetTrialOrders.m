function [trials] = GetTrialOrders(spider_videos,height_videos,pain_stims,n_trials)
    % sort to distribute intesity level (col 3) accordingly
    spider_videos = sortrows(spider_videos,3);
    height_videos = sortrows(height_videos,3);
    pain_stims = sortrows(pain_stims,2);
    % trials in this script refer to runs
    num_stimuli_per_category = size(spider_videos,1);
    stimuli_per_cat_per_trial = num_stimuli_per_category/n_trials;

    stim_in_trial = ones(n_trials,stimuli_per_cat_per_trial);
    for stim_rank_in_trial=1:stimuli_per_cat_per_trial
        for trial_index=1:n_trials
            stim_overall_idx = (stim_rank_in_trial-1)*n_trials + trial_index; %for each next ranked stim in trial move over 
            stim_in_trial(trial_index,stim_rank_in_trial) = stim_overall_idx;
        end
    end

    %we have a matrix with 4 rows (trials) and 5 columns stim rank in trial
    %for each stimulus type we want to grab the corresponding stimulus then
    %alternatively we can make a randomized block design
    trials = [];
    for trial=1:n_trials
        trial_stim_idx = stim_in_trial(trial,:);
        current_trial = CreateTrialOrder(...
                    spider_videos,...
                    height_videos,...
                    pain_stims,...
                    trial_stim_idx,...
                    stimuli_per_cat_per_trial,...
                    3 ...number of categories
                );
         trials = [trials;current_trial];

    end
end

function trial_order = CreateTrialOrder(...
                                        spider_videos,...
                                        height_videos,...
                                        sorted_pain,...
                                        trial_stim_idx,...
                                        stimuli_per_cat_per_trial,...
                                        num_cat)

    spider_vids = spider_videos(trial_stim_idx, :);
    height_vids = height_videos(trial_stim_idx, :);
    pain_stims = sorted_pain(trial_stim_idx, :);

    %order of stimuli in each category for each trial - randomized
    spider_order = randperm(stimuli_per_cat_per_trial);
    pain_order = randperm(stimuli_per_cat_per_trial);
    height_order = randperm(stimuli_per_cat_per_trial);
    

    trial_order = [];
    for i=1:stimuli_per_cat_per_trial
        
        spider.stimulus= spider_vids(spider_order(i),1);
        spider.start = spider_vids(spider_order(i),2);
        spider.level = spider_vids(spider_order(i),3);
        spider.video_trial = true;
        spider.condition = 2;
        
        height.stimulus = height_vids(height_order(i),1);
        height.start = height_vids(height_order(i),2);
        height.level = height_vids(height_order(i),3);
        height.video_trial = true;
        height.condition = 1;
        
        pain.stimulus = pain_stims(pain_order(i),1);
        pain.start = str2num(pain_stims(pain_order(i),3));
        pain.level = pain_stims(pain_order(i),2);
        pain.video_trial = false;
        pain.condition = 3;

        block_stim = [spider height pain];
        randomized_block_stim = block_stim(randperm(num_cat));
        trial_order = [trial_order randomized_block_stim];
    end

end

