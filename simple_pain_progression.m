%% simple pain demo two
clear
%%Test pain script
addpath('pressure_pain-master')

%% set up ports - taken directly from setupPPD
delete(instrfindall) %clear out old channels

%localhost
t=udp('localhost',61557); % creates a local host with this ID - interacts with lab view
%- this is the port that is written to
%where do these hard coded numbers comes from how do they relate to lab
%view

%udp(RemoteHost,RemotePort) creates a UDP object with the specified remote port value, RemotePort. If not specified, the default remote port is 9090.
r=udp('localhost',61158,'localport', 61556); % this is the port that seems to be read from



fopen(t);
fopen(r);
fwrite(t, '0005,0010,o'); % open the remote channel

%% duration arrays
duration_arr = [3,3,5,7,9,3, 7];

%% intensity_arr
intensity_arr = [1,2,3,4,5,6,7];


%% set up psych toolbox screen
exp_screen=max(Screen('Screens'));%get screen for displaying videos
[windowptr, window_rect] = Screen('OpenWindow', exp_screen); %debugging mode,[], [0 0 640 480]); %open window
grayLevel = [0 0 0];

Screen('FillRect',windowptr,grayLevel);
Screen('TextSize', windowptr, 60); %Set textsize
Screen('TextFont',windowptr, 'Helvetica'); %Set text font
Screen('TextColor',windowptr,255); %Set text color

DrawFormattedText(windowptr, 'Pain will begin in 3 seconds :)', 'center', 'center');
Screen('Flip',windowptr); %show instruction
%% Stimulation administration

for i=1:numel(intensity_arr)
    
    intensity = intensity_arr(i);
    duration = duration_arr(i);
    
    screen_pain_string = sprintf('pain intensity %1.3f for %1.3f seconds in three seconds', intensity, duration);
    DrawFormattedText(windowptr, screen_pain_string, 'center', 'center');
    Screen('Flip',windowptr);
    WaitSecs(3);
    
    DrawFormattedText(windowptr, 'PAIN DEPLOYED', 'center', 'center');
    Screen('Flip',windowptr);
    %eval(['fwrite(t, ''' sprintf('%04d',intensity) ',' sprintf('%04d',duration) ',t'');']);
    WaitSecs(duration);
    
    DrawFormattedText(windowptr, '+', 'center', 'center');
    Screen('Flip',windowptr);
    WaitSecs(5);
    
    %% only time I see that R is used
    message_1 = deblank(fscanf(r));
    if strcmp(message_1,'Read Error')
        error(message_1);
    end
    
end
%why is it inside eval?
%fwrite writes a binary file
%I think this may actually just be two arguments t and ''' sprintf('%04d',int(2)) ',' sprintf('%04d',dur) ',t''
% with int(2) = 4 and dur = 3sca

%'fwrite(t, '0004,0003,t');'
% the first t will be converted as it is a variable (not a string)
% not so sure about the second t

Screen('CloseAll');
      
fclose(t);
fclose(r);