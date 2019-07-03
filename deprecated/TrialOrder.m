%Affective Videos
%Trial Order Script
%Purpose: To organize stimuli and onset times. Output them as fprintf
%can put video start and stop times in here as well
function [trials_struct] = TrialOrder(run)
    for i=1:numel(run)
        trial = run(i);
        trial_stim = trial(1);
        
        if (contains(trial_stim,'Height'))
            
            trials_struct(i).video_trial=true;
            trials_struct(i).condition=1;
            
        elseif (contains(trial_stim,'Spider'))
            
            trials_struct(i).video_trial=true;
            trials_struct(i).condition=3;
            
        else
            
            trials_struct(i).video_trial=false;
            trials_struct(i).condition=2;
            
        end
            
        trials_struct(i).stimulus = trial_stim;
        trials_struct(i).start_time = trial(2);
    end
    
end


