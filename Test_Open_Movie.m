%testing video dimensions

exp_screen=max(Screen('Screens'));
windowptr = Screen('OpenWindow', exp_screen)
studydir= pwd;
try
    movie = Screen('OpenMovie', windowptr, [pwd,'/test_crop_affVids_1.mp4']);
catch
    Screen('CloseAll');
    error('movie crashed')
end
%{Screen('PlayMovie', movie, 1);

% Playback loop: Runs until end of movie or keypress
ctex = false;
while ~ctex
    % Wait for next movie frame, retrieve texture handle to it
    tex = Screen('GetMovieImage', windowptr, movie);
    % Valid texture returned? A negative value means end of movie reached:
    if tex<=0
        % We're done, break out of loop:
        break;
    end;
    
    %Draw the new texture immediately to screen:
    Screen('DrawTexture', windowptr, tex);
    
    % Update display:
    Screen('Flip', windowptr);
    
    %Release texture:
    Screen('Close', tex);
    
end;

% Stop playback:
Screen('PlayMovie', movie, 0);

% Close movie:
Screen('CloseMovie', movie);

clear all;