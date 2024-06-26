clear all;
clc;
usetrigger = 0;
AssertOpenGL; %checks if psychtoolbox is properly installed.
Screen('Preference', 'SkipSyncTests', 1);
showmovs = true;
rand('twister',sum(100*clock)); %reset random number gen.

studydir = pwd;%make sure you're in the right directory!
cd(studydir);


% TODO: Why are these 4? Instead of 10? -- ANSWER: 4 for each type of
% stimuli per category per run
%% Timing variables
mvfac = 125;%mouse sensitivity
response_duration = 5;%how long do people get to respond to the questions
stimulus_duration = 20; %how long do pain and videos last
pain_subtracter = 0;

pre_stim_jitter_pain    = [1,1,2,2];%time for after trial jitter
pre_stim_jitter_spiders = [1,1,2,2];
pre_stim_jitter_heights = [1,1,2,2];
pre_stim_jitter_pain    = pre_stim_jitter_pain(randperm(length(pre_stim_jitter_pain)));%randomize w/ each run
pre_stim_jitter_spiders = pre_stim_jitter_spiders(randperm(length(pre_stim_jitter_spiders)));
pre_stim_jitter_heights = pre_stim_jitter_heights(randperm(length(pre_stim_jitter_heights)));

mid_stim_jitter_pain    = [1,1,2,3];%time for after trial jitter
mid_stim_jitter_spiders = [1,1,2,3];
mid_stim_jitter_heights = [1,1,2,3];
mid_stim_jitter_pain    = mid_stim_jitter_pain(randperm(length(mid_stim_jitter_pain)));%randomize w/ each run
mid_stim_jitter_spiders = mid_stim_jitter_spiders(randperm(length(mid_stim_jitter_spiders)));
mid_stim_jitter_heights = mid_stim_jitter_heights(randperm(length(mid_stim_jitter_heights)));

post_stim_jitter_pain    = [1,2,2,3];%time for after trial jitter
post_stim_jitter_spiders = [1,2,2,3];
post_stim_jitter_heights = [1,2,2,3];
post_stim_jitter_pain    = post_stim_jitter_pain(randperm(length(post_stim_jitter_pain)));%randomize w/ each run
post_stim_jitter_spiders = post_stim_jitter_spiders(randperm(length(post_stim_jitter_spiders)));
post_stim_jitter_heights = post_stim_jitter_heights(randperm(length(post_stim_jitter_heights)));


jitter_shock_timings = [0.9,0.925,0.95,0.975];
jitter_shock_timings = jitter_shock_timings(randperm(length(jitter_shock_timings)));

hePlace = 1;%index of heights cue time
painPlace = 1;% index of pain cue time
spPlace = 1;%index of spiders cue time


%% set up subject and run info
video_dir = '/finalVideos/%s';

subject_code = input('Enter subject code: ','s');
subject_code = str2num(subject_code);

run = input('Enter run number: ','s');
run = str2num(run);

%create log files
logfile = sprintf('data/AffVids_logfile_%d.txt',subject_code);


%check if log file already exists
if subject_code ~= 999,
    if exist(logfile,'file'),
        fprintf('DATAFILE EXISTS!\n');
        fprintf(['A datafile of name ' logfile ' already exists!\n']);
        foo = input('Continue [y/n]? ','s');
        if strcmp(foo,'y'),
        elseif strcmp(foo,'n'),
            clear all;
            clc;
            return;
        end
    end
end

HideCursor; %ShowCursor;

%initialize key press variables...
KbName('UnifyKeyNames');
kb_spillover_time = .1; %to prevent spillover of responses.
[keyIsDown, secs, keyCode] = KbCheck;

%open log file 
fid = fopen(logfile,'a+');
fprintf(fid,'Date: %s Subject: %d Run: %d ',datestr(now), subject_code, run);
%set up instruction screens
instscrns = {'Beginning_Slide.jpg'};


%% set up psych tool box and get dimensions for later display
exp_screen=max(Screen('Screens'));%get screen for displaying videos
[windowptr, window_rect] = Screen('OpenWindow', exp_screen);%,[], [0 0 1280 960]); %open window
ifi=Screen('GetFlipInterval', windowptr);%get flip interval for play video methods
grayLevel = [0 0 0];
yellow = [255 255 0];
markercolor = 255;%marker color = white

Screen('FillRect',windowptr,grayLevel);
Screen('TextSize', windowptr, 60); %Set textsize
Screen('TextFont',windowptr, 'Helvetica'); %Set text font
Screen('TextColor',windowptr,255); %Set text color

[wWidth, wHeight] = Screen('WindowSize', windowptr); %returns dimensions of screen
xcenter=wWidth/2;
ycenter=wHeight/2;   

%used for instructions
mindim = min([wWidth wHeight]);
resize_cols = round(.8*mindim);
resize_rows = round(.8*mindim);

[nBR_A] = Screen('TextBounds',windowptr,'Fear?');%Gets boundary of rectangle containing text.
[nBR_F] = Screen('TextBounds',windowptr,'Fear?');%Gets boundary of rectangle containing text.     
% [nBR_Proximity] = Screen('TextBounds',windowptr,'Proximity?');%Gets boundary of rectangle containing text.
% [nBR_Pain] = Screen('TextBounds',windowptr,'Pain?');%Gets boundary of rectangle containing text.
[nBR_Ar] = Screen('TextBounds',windowptr,'Aroused?');%Gets boundary of rectangle containing text.
[nBR_UP] = Screen('TextBounds',windowptr,'Valence?');%Gets boundary of rectangle containing text.

[nBR_low] = Screen('TextBounds',windowptr,'Low');%nBR 
[nBR_high] = Screen('TextBounds',windowptr,'High');%nBR
[nBR_U] = Screen('TextBounds',windowptr,'Unpleasant');%nBR
[nBR_P] = Screen('TextBounds',windowptr,'Pleasant');%nBR

pre_stimulus_questions = {'Fear?'};
pre_stimulus_poles = {{'Low','High'}};
poststimqs_video = {'Fear?','Arousal?','Valence?'};
% poststimqs_video = {'Fear?','Proximity?','Arousal?','Valence?'};
poststimqs_pain = {'Fear?','Arousal?','Valence?'};
% poststimqs_pain = {'Fear?','Pain?','Arousal?','Valence?'};
poststimqs_poles = {{'Low','High'}, {'Low','High'}, {'Unpleasant','Pleasant'}};

topq = round(.03*wHeight);%top of question phrase
bottomq = topq + nBR_A(4);%bottom of question phrase

bottom_all = wHeight*(.95);%bottom
top_all = bottom_all - nBR_low(4);%top 
text_bb = .9*wHeight;

%Use longest end points, nBR_U and nBR_P to defined ends...
left_U = (.05)*wWidth;%left edge
left_P = wWidth - nBR_P(3)-(.05)*wWidth;%right

left_Low = (.05)*wWidth + nBR_U(3)-nBR_low(3);%left edge for "Low"
left_High = left_P;

left_LineEdge = left_U + nBR_U(3); %line, left point given word "low"
% left_lineEdge_Anx = left_U + nBR_Proximity(3);
right_LineEdge = left_P; %line, left point given word "low"
line_vert = top_all + (nBR_low(4)/2);

%setup marker bar properties
size_marker = 20;%width of marker
markercenter = size_marker/2;   

%Position of centered marker %centered wrt line
xcen = (right_LineEdge-left_LineEdge)/2+left_LineEdge; 
left_marker = xcen-(size_marker*.5);
right_marker = xcen+(size_marker*.5);

% poststimqs_pos = xcen-[fix(nBR_F(3)/2), fix(nBR_Proximity(3)/2), fix(nBR_UP(3)/2), fix(nBR_Ar(3)/2)];
% poststimqs_pos_pain = xcen-[fix(nBR_F(3)/2), fix(nBR_Pain(3)/2), fix(nBR_UP(3)/2), fix(nBR_Ar(3)/2)];
poststimqs_pos = xcen-[fix(nBR_F(3)/2), fix(nBR_UP(3)/2), fix(nBR_Ar(3)/2)];
poststimqs_pos_pain = xcen-[fix(nBR_F(3)/2), fix(nBR_UP(3)/2), fix(nBR_Ar(3)/2)];
poststimqs_poles_pos = [left_Low, left_Low, left_U];
pre_stimulus_questions_pos = xcen-[fix(nBR_A(3)/2), fix(nBR_A(3)/2)];
pre_stimulus_poles_pos = [left_Low, left_Low];


%% get trials or trial order info
if run == 1, 
    % get trial order info
    [spider_videos, heights_videos, pain_stims] = TrialSplit3();%get stimuluslistssc
    run_trial_list = GetTrialOrders(spider_videos, heights_videos, pain_stims, 5);
    vidlogfile = sprintf('data/AffVids_vidlogfile_%d.mat',subject_code);%and save here
    save(vidlogfile,'run_trial_list');
else
    vidlogfile = sprintf('data/AffVids_vidlogfile_%d.mat',subject_code);%make sure loading is correct
    load(vidlogfile);
end

trials_struct = run_trial_list(run,:);

%% load videos
for i = 1:numel(trials_struct)      %length(VIDEO_ID),
    try
        if(trials_struct(i).video_trial)
            video_path = [studydir,sprintf('/7T_SHOCK_VIDS/%s', trials_struct(i).stimulus)];
            trials_struct(i).movie_object = VideoReader(video_path);
        end
    catch e
        sca
        Screen('CloseAll');
        fprintf(1,'There was an error! The message was:\n%s',e.message);
        fprintf('\n\n %s \n\n', trials_struct(i).stimulus);
        break;
    end
end
%Set up stimulus presentation order
ntrials = numel(trials_struct); %length(movie);   %VIDEO_ID);
%% begin task
DrawFormattedText(windowptr, 'The task is about to begin', 'center', 'center'); %,[image_lb image_tb image_rb image_bb]
Screen('Flip',windowptr); %show instruction
DrawFormattedText(windowptr, '+', 'center', 'center');

trigged = 0;
wait_onset = GetSecs();

key.ttl = KbName('=+');

keycode(key.ttl) = 0;
while keycode(key.ttl) == 0
    [presstime, keycode, delta] = KbWait(-1);
end

%first_flip_unix = now();
%[first_flip] = Screen('Flip', windowptr);
anchor = presstime;

ccc = [];

DrawFormattedText(windowptr, '+', 'center', 'center');
[StimulusOffset] = Screen('Flip',windowptr); %ITI blank screen
WaitSecs(1.5); %delay before movie.
%print start time to file...
fprintf(fid,'START TIME: %1.3f\n',GetSecs - anchor);

%% ============================================================================
%% TRIAL LOOP
%% ============================================================================
%% BEGIN trials for this run
for i = 1:ntrials %iterate through movies...
    % Set up condition vars
    current_trial = trials_struct(i);
    condition = current_trial.condition;
    if condition == 1
        post_trial_jitter = post_stim_jitter_heights(hePlace);
        pre_stim_jitter   = pre_stim_jitter_heights(hePlace);
        mid_trial_jitter  = mid_stim_jitter_heights(hePlace);
        hePlace           = hePlace + 1;
        
    elseif condition == 2
        post_trial_jitter = post_stim_jitter_spiders(spPlace);
        pre_stim_jitter   = pre_stim_jitter_spiders(spPlace);
        mid_trial_jitter  = mid_stim_jitter_spiders(spPlace);
        spPlace           = spPlace + 1;
 
    else
        start = current_trial.start;
        post_trial_jitter = post_stim_jitter_pain(painPlace);
        pre_stim_jitter   = pre_stim_jitter_pain(painPlace);
        mid_trial_jitter  = mid_stim_jitter_pain(painPlace);
        trial_jitter_timings = jitter_shock_timings(painPlace);
        if start == 0
            pre_shock_jitter = trial_jitter_timings * 20;
            post_shock_jitter = (1-trial_jitter_timings) * 20;
        end
        painPlace         = painPlace + 1;
    end
    
    %% add inter trial jitter
    DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5
    [pre_stim_jitter_begin] = Screen('Flip',windowptr); %ITI blank screen
    WaitSecs(pre_stim_jitter); %delay after movie.
    
    % <===================================== SLIDE 1 - VIDEO or SHOCK CUE ====================================================>
    vidstart = GetSecs - anchor;
    if(current_trial.video_trial)
        %% play videos
        video_start_time = str2double(current_trial.start);
        video_duration   = stimulus_duration;
        questions        = poststimqs_video;
        post_stim_positions = poststimqs_pos;
        flip_time = Screen('Flip',windowptr);
        
        PlayVideo(...
            current_trial.movie_object,...
            windowptr, ...
            window_rect,...
            ifi,...
            flip_time,...
            1,...
            video_start_time,...
            video_duration);
    else
        %% set up pain task
        questions = poststimqs_pain;
        post_stim_positions = poststimqs_pos_pain;

        if(str2num(current_trial.stimulus) == 1)
            DrawFormattedText(windowptr, 'High', 'center', 'center');
        else
            DrawFormattedText(windowptr, 'Low', 'center', 'center');
        end
        [PainCueOnset] = Screen('Flip',windowptr);
        if start == 0
            WaitSecs(pre_shock_jitter);
            painonset = GetSecs - anchor;
            pain_value = convertStringsToChars(current_trial.stimulus);
            pyrunfile(['.\shock.py ' pain_value]);
            WaitSecs(post_shock_jitter);
        else
            WaitSecs(20);
        end  
    end
    vidend = GetSecs - anchor;

    % <===================================== SLIDE 2 - JITTER ==========================================================>
    % DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5
    [StimulusOffset] = Screen('Flip',windowptr); %ITI blank screen
    WaitSecs(mid_trial_jitter); %delay after movie.

    % <===================================== SLIDE 3 - RATINGS  ========================================================>
    %% ask post stim qs
    qonset = GetSecs - anchor;
    [RESP_psqs,RT_psqs]= AskQs(...
                questions,...
                post_stim_positions,...
                poststimqs_poles,...
                poststimqs_poles_pos,...
                ycenter,...
                xcen,...
                right_LineEdge,...
                left_LineEdge,...
                line_vert,...
                top_all,...
                bottom_all,...
                markercolor,...
                markercenter,...
                size_marker,...
                windowptr,...
                mvfac, ...
                left_High,...
                response_duration);



    % <===================================== SLIDE 4 - JITTER ==========================================================>
    jitteronset = GetSecs - anchor;
    DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5
    [StimulusOffset] = Screen('Flip',windowptr); %ITI blank screen
    if condition == 3
        if start == 1
            painonset = -1.0;
        end
        WaitSecs(post_trial_jitter); %delay after movie.
        logstim = strcat('Pain_', current_trial.stimulus);
    else
        painonset = -1.0;
        WaitSecs(post_trial_jitter); %delay after movie.
        logstim = current_trial.stimulus;
    end
    
    % %% log values
    fprintf(fid,'%s %s %d ',logstim,current_trial.level,condition);
    %log expected fear rating and rt
    fprintf(fid,'%1.3f %1.3f %1.3f %1.3f %1.3f ',vidstart,vidend,qonset,jitteronset,painonset);
    %log post stimulus questions and reaction times
    fprintf(fid,[strdupe('%1.3f ', numel(questions) * 2) '\n'], RESP_psqs,RT_psqs);
end  


%% end task
DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5
[StimulusOffset] = Screen('Flip',windowptr); %ITI blank screen
WaitSecs(1.5);


fclose(fid);
DrawFormattedText(windowptr, 'This part is complete.', 'center', 'center');%Draw text
Screen('Flip', windowptr);%Displays screen
WaitSecs(5);
Screen('CloseAll');

clear all;


%% helper methods


function PresentBlinkingText(...
    text,...
    total_duration,...
    per_blink_duration,...
    window)
    
    start_time = GetSecs();
    
    while GetSecs - start_time < total_duration
        DrawFormattedText(window, text, 'center', 'center');
        Screen(window, 'Flip');
        WaitSecs(per_blink_duration);
        Screen(window, 'Flip');
        WaitSecs(per_blink_duration);
    end
    
end

function PlayVideo(...
    video_obj,...
    window_ptr,...
    win_rect,...
    ifi,...
    flip_time,...
    img_scale,...
    start_time,...
    play_time)

    frame_delay = 1/video_obj.FrameRate;
    video_obj.CurrentTime = start_time;
    off_screen_rect=[0 0 video_obj.Width video_obj.Height];
    on_screen_rect=CenterRect(off_screen_rect*img_scale,win_rect);
    
    video_started = GetSecs();
    duration_up = false;
    while (hasFrame(video_obj) && ~KbCheck && ~duration_up) % while there are frames to read
        
        video_frame = readFrame(video_obj); % read next frame from video file
        tex = Screen('MakeTexture', window_ptr, video_frame);
        Screen('DrawTexture', window_ptr, tex, off_screen_rect, on_screen_rect);
        flip_time = Screen('Flip', window_ptr, flip_time + frame_delay-ifi/2); % update at closest next frame
        Screen('Close', tex);
        
        duration_up = GetSecs() - video_started > play_time;
    end
end

function [RESP_psqs, RT_psqs] = AskQs(...
                questions,...
                questions_pos,...
                questions_poles,...
                questions_poles_pos,...
                ycenter,...
                xcen,...
                right_LineEdge,...
                left_LineEdge,...
                line_vert,...
                top_all,...
                bottom_all,...
                markercolor,...
                markercenter,...
                size_marker,...
                windowptr,...
                mvfac, ...
                left_High,...
                response_duration)
            
    RESP_psqs = NaN(1,numel(questions));
    RT_psqs = NaN(1,numel(questions));
    rate_onset_psqs = NaN(1,numel(questions));
    for ii = 1:numel(questions),

        SetMouse(xcen,ycenter,windowptr);
        [x,y,mouseclick] = GetMouse();%checks position of mouse
        mouseclick = [0,0,0];
        keyIsDown = 0;
        [RateOnset] = Screen('Flip', windowptr); %Flips to rating screen

        [reaction_time,q_resp] = DrawQuestion(...
                questions{ii},...
                questions_pos(ii),...
                questions_poles{ii},...
                questions_poles_pos(ii),...
                ycenter,...
                right_LineEdge,...
                left_LineEdge,...
                line_vert,...
                top_all,...
                bottom_all,...
                markercolor,...
                markercenter,...
                size_marker,...
                windowptr,...
                RateOnset,...
                mvfac, ...
                left_High,...
                response_duration);

        RESP_psqs(ii) = q_resp;
        RT_psqs(ii) = reaction_time;
        % rat

        WaitSecs(.25); %prevent keyboard spillover
    end
end