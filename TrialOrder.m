%Affective Videos
%Trial Order Script
%Purpose: To organize stimuli and onset times. Output them as fprintf
%can put video start and stop times in here as well
function [trials_struct] = TrialOrder(run)
    for i=1:numel(run)
        trial = run(i);
        if (contains(trial,'Height'))
            trials_struct(i).video_trial=true;
            trials_struct(i).condition=1;
        elseif (contains(trial,'Spider'))
            trials_struct(i).video_trial=true;
            trials_struct(i).condition=2;
        else
            trials_struct(i).video_trial=false;
            trials_struct(i).condition=3;
        end
            
        trials_struct(i).stimulus = trial;
    end
    
end
%visualize design? imagesc([vidCond, imVal, predVal])


