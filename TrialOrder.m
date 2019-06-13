%Affective Videos
%Trial Order Script
%Purpose: To organize stimuli and onset times. Output them as fprintf

function [trials_struct] = TrialOrder(run)
    for i=1:numel(run)
        trial = run(i)
        if (contains(trial,'height'))
            trials_struct(i).video_trial=true;
            trials_struct(i).condition=1;
        elseif (contains(trial,'spider'))
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


