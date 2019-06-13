num_stimuli_per_category = 20;
num_trials = 4;
num_cat = 3;

high_intensity = normrnd(5,1,num_stimuli_per_category/2,1);
low_intensity = normrnd(2.5,1,num_stimuli_per_category/2,1);
all_pain = [high_intensity;low_intensity];
sorted_pain = string(sort(all_pain));

%dummy spider
spider_vid_indexes = linspace(1,num_stimuli_per_category,num_stimuli_per_category);
spider_videos = string(spider_vid_indexes);
spider_videos =strcat(spider_videos,'spider');
%dummy heights
height_vid_indexes = linspace(1,num_stimuli_per_category,num_stimuli_per_category);
height_videos = string(height_vid_indexes);
height_videos =strcat(height_videos,'heights');

[trials] = GetTrialOrders(spider_videos,height_videos, sorted_pain,4)

%make a random block