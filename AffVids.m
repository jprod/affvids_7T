clear all;
clc;
usetrigger = 1;
AssertOpenGL; %checks if psychtoolbox is properly installed.
Screen('Preference', 'SkipSyncTests', 1);
showmovs = true;
rand('twister',sum(100*clock)); %reset random number gen.

studydir = pwd;%make sure you're in the right directory!
cd(studydir);

beforeTime = 1;
wordTime = 1;
respdur = 4;
inbtwtime = 1;
afterTime = 15;
mvfac = 120;

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

exp_screen=max(Screen('Screens'));%get screen for displaying videos
[windowptr, window_rect] = Screen('OpenWindow', exp_screen,[], [0 0 640 480]); %open window
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

[nBR_A] = Screen('TextBounds',windowptr,'Expected Fear?');%Gets boundary of rectangle containing text.
[nBR_F] = Screen('TextBounds',windowptr,'Fear?');%Gets boundary of rectangle containing text.     
[nBR_An] = Screen('TextBounds',windowptr,'Anxious?');%Gets boundary of rectangle containing text.
[nBR_Ar] = Screen('TextBounds',windowptr,'Aroused?');%Gets boundary of rectangle containing text.
[nBR_UP] = Screen('TextBounds',windowptr,'Valence?');%Gets boundary of rectangle containing text.

[nBR_low] = Screen('TextBounds',windowptr,'Low');%nBR 
[nBR_high] = Screen('TextBounds',windowptr,'High');%nBR
[nBR_U] = Screen('TextBounds',windowptr,'Unpleasant');%nBR
[nBR_P] = Screen('TextBounds',windowptr,'Pleasant');%nBR
[nBR_very_much] = Screen('TextBounds',windowptr,'High');%nBR
pre_stimulus_questions = {'How much Fear do you feel?'};
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
left_lineEdge_Anx = left_U + nBR_An(3);
right_LineEdge = left_P; %line, left point given word "low"
line_vert = top_all + (nBR_low(4)/2);

%setup marker bar properties
size_marker = 20;%width of marker
markercenter = size_marker/2;   

%Position of centered marker %centered wrt line
xcen = (right_LineEdge-left_LineEdge)/2+left_LineEdge; 
left_marker = xcen-(size_marker*.5);
right_marker = xcen+(size_marker*.5);

poststimqs_pos = xcen-[fix(nBR_F(3)/2), fix(nBR_An(3)/2), fix(nBR_UP(3)/2), fix(nBR_Ar(3)/2)];
poststimqs_poles_pos = [left_Low, left_Low, left_Low, left_U];
pre_stimulus_questions_pos = xcen-[fix(nBR_A(3)/2), fix(nBR_Current_Anx(3)/2)];
pre_stimulus_poles_pos = [left_Low, left_Low];

if run == 1, 
    % get trial order info
    [spider_videos, heights_videos, pain_stims] = TrialSplit2();%get stimuluslists
    run_trial_list = GetTrialOrders(spider_videos, heights_videos, pain_stims, 4);
    vidlogfile = sprintf('data/AffVids_vidlogfile_%d.mat',subject_code);%and save here
    save(vidlogfile,'run_trial_list');
else
    vidlogfile = sprintf('data/AffVids_vidlogfile_%d.mat',subject_code);%make sure loading is correct
    load(vidlogfile);
end

current_run_trials = run_trial_list(run,:);
trials_struct = TrialOrder(current_run_trials);
%%%%%[nameList, vidCond, imVal, predVal] = TrialOrder(videoTrials{run});
%Load up video file put this whole thing in a method at the bottom
for i = 1:numel(trials_struct)      %length(VIDEO_ID),
    try
        % Open movie file:
        %movie(i) = Screen('OpenMovie', windowptr, [studydir,sprintf(video_dir,nameList{i})]);
        if(trials_struct(i).video_trial)
            video_path = [studydir,sprintf('/finalVideos/%s', trials_struct(i).stimulus)];
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
%Resize and present instruction screen
i = 1;
foo = imread(instscrns{i},'jpg');
if size(foo,1)/wHeight > size(foo,2)/wWidth,
    %then wHeight is the factor to scale by...
    foo = imresize(foo,wHeight/size(foo,1));
else
    foo = imresize(foo,wWidth/size(foo,2));
end

inst_texture{i} = foo; %Screen('MakeTexture',windowptr,foo);
%%%%%
DrawFormattedText(windowptr, 'Press any key to continue', 'center', 'center'); %,[image_lb image_tb image_rb image_bb]
Screen('Flip',windowptr); %show instruction
DrawFormattedText(windowptr, '+', 'center', 'center');

trigged = 0;
wait_onset = GetSecs();

if usetrigger == 1,
    while trigged == 0,

        [keyIsDown,secs_fromKbCheck,keyCode] = KbCheck();
        if keyIsDown || GetSecs() - wait_onset > 3,%if response is made
            %foo = KbName(keyCode);
            trigged = 1;
            [first_flip] = Screen('Flip', windowptr);
            %on first run set time anchors
            %if (run==1) - comment out for now set anchors on all runs?
                first_flip_unix = now();
                anchor = first_flip;
                fprintf(fid, 'unix: %1.6f\n', first_flip_unix);
           % end - 

            %end
        end
        WaitSecs(.01);%Wait to avoid keypress spillover
    end
else
    while trigged == 0,
        [keyIsDown,secs_fromKbCheck,keyCode] = KbCheck();
        if keyIsDown,%if response is made
            foo = KbName(keyCode);
            trigged = 1;
            [anchor] = Screen('Flip', windowptr);%Displays screen

        end
        WaitSecs(.01);%Wait to avoid keypress spillover
    end
end


ccc = [];



ISItimeArraySp = [3,3,4,5];
ISItimeArrayPain = [3,3,4,5];
ISItimeArrayHe = [3,3,4,5];

ISItimeArraySp = ISItimeArraySp(randperm(length(ISItimeArraySp)));
ISItimeArrayPain = ISItimeArraySp(randperm(length(ISItimeArrayPain)));
ISItimeArrayHe = ISItimeArraySp(randperm(length(ISItimeArrayHe)));

hePlace = 1;
painPlace = 1;
spPlace = 1;


DrawFormattedText(windowptr, '+', 'center', 'center');
[StimulusOffset] = Screen('Flip',windowptr); %ITI blank screen
WaitSecs(beforeTime); %delay before movie.


%BEGIN
for i = 1:ntrials %iterate through movies...
    current_trial = trials_struct(i);
    condition = current_trial.condition;
    %print start time to file...
    %fprintf(fid,'START TIME: %1.3f\n',GetSecs - anchor);
    
    
    
    if condition == 1
        ISItime = ISItimeArrayHe(hePlace);
        hePlace = hePlace +1;
    elseif condition == 2
        ISItime = ISItimeArraySp(spPlace);
        spPlace = spPlace +1;
        
    else
        ISItime = ISItimeArrayPain(painPlace);
        painPlace = painPlace +1;
    end

    % SHOW WORD HERE
    if condition == 1
        DrawFormattedText(windowptr, 'Heights', 'center', 'center');
    elseif condition == 2
        DrawFormattedText(windowptr, 'Spider', 'center', 'center');
    else
        DrawFormattedText(windowptr, 'Pain', 'center', 'center');
    end

    [CueWordOnset] = Screen('Flip',windowptr); %cue word
    wordStart = CueWordOnset - anchor;

    WaitSecs(wordTime);
    wordEnd = GetSecs() - anchor;
    %Apprehension question
    RT_expectedFear = NaN;
    RESP_expectedFear = NaN;
    keyIsDown = 0;
    mouseclick = 0;
    keyIsDown = 0;

    DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5
    [StimulusOffset] = Screen('Flip',windowptr); %ITI blank screen
    WaitSecs(ISItime); %delay before movie.

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
           left_High);
       
    vidstart = GetSecs - anchor;
    flip_time = Screen('Flip',windowptr);
    if(current_trial.video_trial)
        questions = poststimqs_video;
        PlayVideo(...
            current_trial.movie_object,...
            windowptr, ...
            window_rect,...
            ifi,...
            flip_time,...
            1);
    else
        questions = poststimqs_pain;
        DrawFormattedText(windowptr, 'PAIN', 'center', 'center');%Draw text , 60, 0, 0, 1.5
        [StimulusOffset] = Screen('Flip',windowptr); %ITI blank screen
        WaitSecs(3);

    end
    vidend = GetSecs - anchor;
    [RESP_psqs,RT_psqs]= AskQs(...
                questions,...
                poststimqs_pos,...
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
                left_High);

    DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5
    [StimulusOffset] = Screen('Flip',windowptr); %ITI blank screen

    WaitSecs(inbtwtime); %delay before movie.
    imVal = 1;
    predVal = 1;
    fprintf(fid,'%s %d %d %d %1.3f %1.3f ',current_trial.stimulus,condition,imVal,predVal,wordStart, wordEnd);
    %log expected fear rating and rt
    fprintf(fid,'%1.3f %1.3f ',pre_stim_qs_resp(1),pre_stim_qs_rt(1));
    fprintf(fid,'%1.3f %1.3f ',vidstart,vidend);
    fprintf(fid,'%1.3f %1.3f %1.3f %1.3f %1.3f %1.3f %1.3f %1.3f\n',RESP_psqs,RT_psqs);
end  

DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5
[StimulusOffset] = Screen('Flip',windowptr); %ITI blank screen
WaitSecs(afterTime);


fclose(fid);
DrawFormattedText(windowptr, 'This part is complete.', 'center', 'center');%Draw text
Screen('Flip', windowptr);%Displays screen
WaitSecs(kb_spillover_time);%Wait to avoid keypress spillover
KbWait();
Screen('CloseAll');
clear all;


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
                left_High)
            
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
                left_High);

        RESP_psqs(ii) = q_resp;
        RT_psqs(ii) = reaction_time;

        WaitSecs(.25); %prevent keyboard spillover
    end
end