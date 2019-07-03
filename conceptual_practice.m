clear all;
clc;
usetrigger = 0;
AssertOpenGL; %checks if psychtoolbox is properly installed.
Screen('Preference', 'SkipSyncTests', 1);
showmovs = true;
rand('twister',sum(100*clock)); %reset random number gen.

studydir = pwd;%make sure you're in the right directory!
cd(studydir);

%% Timing variables
mvfac = 120;%mouse sensitivity
response_duration = 4;%how long do people get to respond to the questions
stimulus_duration = 5; %how long do pain and videos last

cue_durationArraySp = [8,8.5,9.5,10];%cue time for spiders
cue_durationArrayPain = [8,8.5,9.5,10];%cue time for pains
cue_durationArrayHe = [8,8.5,9.5,10];%cue time for heights

cue_durationArraySp = cue_durationArraySp(randperm(length(cue_durationArraySp)));%randomize w/ each run
cue_durationArrayPain = cue_durationArraySp(randperm(length(cue_durationArrayPain)));
cue_durationArrayHe = cue_durationArraySp(randperm(length(cue_durationArrayHe)));

pre_stim_jitter_pain    = [1,1,2,2];%time for after trial jitter
pre_stim_jitter_spiders = [1,1,2,2];
pre_stim_jitter_heights = [1,1,2,2];

pre_stim_jitter_pain    = pre_stim_jitter_pain(randperm(length(pre_stim_jitter_pain)));%randomize w/ each run
pre_stim_jitter_spiders = pre_stim_jitter_spiders(randperm(length(pre_stim_jitter_spiders)));
pre_stim_jitter_heights = pre_stim_jitter_heights(randperm(length(pre_stim_jitter_heights)));

post_stim_jitter_pain    = [1,2,2,3];%time for after trial jitter
post_stim_jitter_spiders = [1,2,2,3];
post_stim_jitter_heights = [1,2,2,3];

post_stim_jitter_pain    = post_stim_jitter_pain(randperm(length(post_stim_jitter_pain)));%randomize w/ each run
post_stim_jitter_spiders = post_stim_jitter_spiders(randperm(length(post_stim_jitter_spiders)));
post_stim_jitter_heights = post_stim_jitter_heights(randperm(length(post_stim_jitter_heights)));

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
logfile = sprintf('data/AffVids_conceptual_practice_logfile_%d.txt',subject_code);


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
[windowptr, window_rect] = Screen('OpenWindow', exp_screen,[], [0 0 1280 960]); %open window
ifi=Screen('GetFlipInterval', windowptr);%get flip interval for play video methods
grayLevel = [0 0 0];
markercolor = 255;%marker color

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

[nBR_A] = Screen('TextBounds',windowptr,'How much fear do you feel?');%Gets boundary of rectangle containing text.
[nBR_F] = Screen('TextBounds',windowptr,'Fear?');%Gets boundary of rectangle containing text.     
[nBR_Proximity] = Screen('TextBounds',windowptr,'Proximity?');%Gets boundary of rectangle containing text.
[nBR_Pain] = Screen('TextBounds',windowptr,'Pain?');%Gets boundary of rectangle containing text.
[nBR_Ar] = Screen('TextBounds',windowptr,'Aroused?');%Gets boundary of rectangle containing text.
[nBR_UP] = Screen('TextBounds',windowptr,'Valence?');%Gets boundary of rectangle containing text.

[nBR_low] = Screen('TextBounds',windowptr,'Low');%nBR 
[nBR_high] = Screen('TextBounds',windowptr,'High');%nBR
[nBR_U] = Screen('TextBounds',windowptr,'Unpleasant');%nBR
[nBR_P] = Screen('TextBounds',windowptr,'Pleasant');%nBR

pre_stimulus_questions = {'How much fear do you feel?'};
pre_stimulus_poles = {{'Low','High'}};
poststimqs_video = {'Fear?','Proximity?','Arousal?','Valence?'};
poststimqs_pain = {'Fear?','Pain?','Arousal?','Valence?'};
poststimqs_poles = {{'Low','High'}, {'Low','High'}, {'Low','High'}, {'Unpleasant','Pleasant'}};

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
left_lineEdge_Anx = left_U + nBR_Proximity(3);
right_LineEdge = left_P; %line, left point given word "low"
line_vert = top_all + (nBR_low(4)/2);

%setup marker bar properties
size_marker = 20;%width of marker
markercenter = size_marker/2;   

%Position of centered marker %centered wrt line
xcen = (right_LineEdge-left_LineEdge)/2+left_LineEdge; 
left_marker = xcen-(size_marker*.5);
right_marker = xcen+(size_marker*.5);

poststimqs_pos = xcen-[fix(nBR_F(3)/2), fix(nBR_Proximity(3)/2), fix(nBR_UP(3)/2), fix(nBR_Ar(3)/2)];
poststimqs_pos_pain = xcen-[fix(nBR_F(3)/2), fix(nBR_Pain(3)/2), fix(nBR_UP(3)/2), fix(nBR_Ar(3)/2)];
poststimqs_poles_pos = [left_Low, left_Low, left_Low, left_U];
pre_stimulus_questions_pos = xcen-[fix(nBR_A(3)/2), fix(nBR_A(3)/2)];
pre_stimulus_poles_pos = [left_Low, left_Low];


%% get trials or trial order info
if run == 1 
    % get trial order info
    [spider_videos, heights_videos, pain_stims] = TrialSplit2();%get stimuluslistssc
    run_trial_list = GetTrialOrders(spider_videos, heights_videos, pain_stims, 5);
end

trials_struct = run_trial_list(run,:);

%Set up stimulus presentation order
ntrials = numel(trials_struct); %length(movie);   %VIDEO_ID);
%% begin task
DrawFormattedText(windowptr, 'The task is about to begin', 'center', 'center'); %,[image_lb image_tb image_rb image_bb]
Screen('Flip',windowptr); %show instruction
DrawFormattedText(windowptr, '+', 'center', 'center');

trigged = 0;
WaitSecs(5);
ccc = [];

DrawFormattedText(windowptr, '+', 'center', 'center');
[anchor] = Screen('Flip',windowptr); %ITI blank screen
WaitSecs(1.5); %delay before movie.

%% BEGIN trials for this run
for i = 1:ntrials %iterate through movies...
    
    current_trial = trials_struct(i);
    condition = current_trial.condition;

    if condition == 1
        
        cue_duration = cue_durationArrayHe(hePlace);
        post_trial_jitter = post_stim_jitter_heights(hePlace);
        pre_stim_jitter = pre_stim_jitter_heights(hePlace);
        hePlace = hePlace +1;
        DrawFormattedText(windowptr, 'H', 'center', 'center');
        text = 'Heights Video';
        questions = poststimqs_video;
        post_stim_positions = poststimqs_pos;
        
    elseif condition == 2
        
        cue_duration = cue_durationArraySp(spPlace);
        post_trial_jitter = post_stim_jitter_spiders(spPlace);
        pre_stim_jitter = pre_stim_jitter_spiders(spPlace);
        DrawFormattedText(windowptr, 'S', 'center', 'center');
        spPlace = spPlace +1;
        text = 'Spider Video';
        questions = poststimqs_video;
        post_stim_positions = poststimqs_pos;
        
    else
        
        cue_duration = cue_durationArrayPain(painPlace);
        post_trial_jitter = post_stim_jitter_pain(painPlace);
        pre_stim_jitter = pre_stim_jitter_pain(painPlace);
        DrawFormattedText(windowptr, 'P', 'center', 'center');
        painPlace = painPlace +1;
        text = 'Pressure';
        questions = poststimqs_pain;
        post_stim_positions = poststimqs_pos_pain;
        
    end


    [CueWordOnset] = Screen('Flip',windowptr); %cue word
    wordStart = CueWordOnset - anchor;
    WaitSecs(cue_duration);
    wordEnd = GetSecs() - anchor;
    
    %% ask pre stim qs
    [pre_stim_qs_rt, pre_stim_qs_resp] = AskQs(...
           pre_stimulus_questions,...
           pre_stimulus_questions_pos,...
           pre_stimulus_poles,...
           pre_stimulus_poles_pos,...
           ycenter,...
           xcen,...
           right_LineEdge,...
           left_LineEdge, ...
           line_vert,...
           top_all,...
           bottom_all,...
           markercolor,...
           markercenter,...
           size_marker,...
           windowptr,...
           mvfac,...
           left_High,...
           response_duration);
       
    
    flip_time = Screen('Flip',windowptr);
    %% add inter trial jitter
    DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5
    [pre_stim_jitter_begin] = Screen('Flip',windowptr); %ITI blank screen
    WaitSecs(pre_stim_jitter); %delay after movie.
    
    vidstart = GetSecs - anchor;
        %% play videos
    PresentBlinkingText(...
                        text,...
                        stimulus_duration,...
                        stimulus_duration/10,...
                        windowptr)
    vidend = GetSecs - anchor;
    %% ask post stim qs
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

    DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5
    [StimulusOffset] = Screen('Flip',windowptr); %ITI blank screen
    
    WaitSecs(post_trial_jitter); %delay after movie.
    
    %% log values
    imVal = 1;
    predVal = 1;
    fprintf(fid,'%s %d %d %d %1.3f %1.3f ',current_trial.stimulus,condition,imVal,predVal,wordStart, wordEnd);
    %log expected fear rating and rt
    fprintf(fid,'%1.3f %1.3f ',pre_stim_qs_resp(1),pre_stim_qs_rt(1));
    fprintf(fid,'%1.3f %1.3f ',vidstart,vidend);
    %log post stimulus questions and reaction times
    fprintf(fid,'%1.3f %1.3f %1.3f %1.3f %1.3f %1.3f %1.3f %1.3f\n',RESP_psqs,RT_psqs);
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

%% close pain ports
fclose(t);
fclose(r);

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

        WaitSecs(.25); %prevent keyboard spillover
    end
end