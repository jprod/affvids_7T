videoFilename='AffVids_videos/Height/Height_high_1.mp4';
myVideoObj=VideoReader(videoFilename);

whichScreen=max(Screen('Screens')); % use highest available display # for stimuli
backLum=127; % background greyscale level
Screen('Preference', 'SkipSyncTests', 1); % skip timing tests for demo
[windowPtr, winRect] = Screen('OpenWindow', whichScreen, [], [0 0 640 480]); % open a window with required luminance
ifi=Screen('GetFlipInterval', windowPtr);
flipTime = Screen('Flip', windowPtr);

imMagnification=1;

PlayVideo(myVideoObj, windowPtr, winRect, ifi, flipTime, imMagnification);

Screen('CloseAll'); 

function PlayVideo(video_obj, window_ptr, win_rect,ifi, flip_time, img_scale)
    frame_delay = 1/video_obj.FrameRate;
    off_screen_rect=[0 0 video_obj.Width video_obj.Height];
    on_screen_rect=CenterRect(off_screen_rect*img_scale,win_rect);
    while and(hasFrame(video_obj), ~KbCheck) % while there are frames to read
        video_frame = readFrame(video_obj); % read next frame from video file
        tex = Screen('MakeTexture', window_ptr, video_frame);
        Screen('DrawTexture', window_ptr, tex, off_screen_rect, on_screen_rect);
        flip_time = Screen('Flip', window_ptr, flip_time + frame_delay-ifi/2); % update at closest next frame
        Screen('Close', tex);
    end
end