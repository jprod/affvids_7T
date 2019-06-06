clear all;
clc;
usetrigger = 0;
AssertOpenGL; %checks if psychtoolbox is properly installed.
showmovs = true;
rand('twister',sum(100*clock)); %reset random number gen.
Screen('Preference', 'SkipSyncTests', 1 );
%startrun = 3; %in case you have to start on run 2, or 3, due to error or break out, change this!

studydir = pwd;%make sure you're in the right directory!
cd(studydir);

%numSections = 1;
beforeTime = 10;
wordTime = 3;
respdur = 4;
inbtwtime = .5;
afterTime = 5;
mvfac= 120;
%breakLength = 5;

HideCursor;
subject_code = input('Enter subject code: ','s');
subject_code = str2num(subject_code);
logfile = sprintf('data/AffVids_Pract_logfile_%d.txt',subject_code);

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





%HideCursor; ShowCursor;

%initialize key press variables...
KbName('UnifyKeyNames');
kb_spillover_time = .1; %to prevent spillover of responses.
[keyIsDown, secs, keyCode] = KbCheck;

%open log file 
fid = fopen(logfile,'a+');
fprintf(fid,'Date: %s Subject: %d\n',datestr(now), subject_code);

%%%%%%%%[VIDEO_ID] = textread(stimf,'%s'); %video onsets are echoed to log file below...

%set up instruction screens
instscrns = {'Beginning_Slide.jpg'};

exp_screen=max(Screen('Screens'));
%HideCursor; 
    windowptr = Screen('OpenWindow', exp_screen); 
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
    [nBR_Current_Anx] = Screen('TextBounds',windowptr,'Current Anxiety');
    [nBR_F] = Screen('TextBounds',windowptr,'Fearful?');%Gets boundary of rectangle containing text.     
    [nBR_An] = Screen('TextBounds',windowptr,'Anxious?');%Gets boundary of rectangle containing text.
    [nBR_Ar] = Screen('TextBounds',windowptr,'Aroused?');%Gets boundary of rectangle containing text.
    [nBR_UP] = Screen('TextBounds',windowptr,'Valence?');%Gets boundary of rectangle containing text.

    [nBR_low] = Screen('TextBounds',windowptr,'Low');%nBR 
    [nBR_high] = Screen('TextBounds',windowptr,'High');%nBR
    [nBR_U] = Screen('TextBounds',windowptr,'Unpleasant');%nBR
    [nBR_P] = Screen('TextBounds',windowptr,'Pleasant');%nBR

%     poststimqs = {'Fear?','Anxiety?','Arousal?','Valence?'};
%     poststimqs_poles = {{'Low','High'}, {'Low','High'}, {'Low','High'}, {'Very Unpleasant','Very Pleasant'}};
    poststimqs = {'Fear?','Anxiety?', 'Arousal?','Valence?'};
    
    poststimqs_poles = {{'Low','High'}, {'Low','High'}, ...
    {'Low','High'}, {'Unpleasant','Pleasant'}};
    
    pre_stimulus_questions = {'Expected fear?','Current anxiety?'};
    pre_stimulus_poles = {{'Low','High'}, {'Low','High'}};
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
    right_LineEdge = left_P; %line, left point given word "low"
    line_vert = top_all + (nBR_low(4)/2);

    %setup marker bar properties
    size_marker = 20;%width of marker
    markercenter = size_marker/2;   

    %Position of centered marker %centered wrt line
    xcen = (right_LineEdge-left_LineEdge)/2+left_LineEdge; 
    left_marker = xcen-(size_marker*.5);
    right_marker = xcen+(size_marker*.5);

    %positions of words and poles, wrt to line and pole words
%   poststimqs_pos = xcen-[fix(nBR_F(3)/2), fix(nBR_An(3)/2), fix(nBR_UP(3)/2), fix(nBR_Ar(3)/2)];
    poststimqs_pos = xcen-[fix(nBR_F(3)/2), fix(nBR_An(3)/2), fix(nBR_UP(3)/2), fix(nBR_Ar(3)/2)];
    pre_stimulus_questions_pos = xcen-[fix(nBR_A(3)/2), fix(nBR_Current_Anx(3)/2)];
    poststimqs_poles_pos = [left_Low, left_Low, left_Low, left_U];
    pre_stimulus_poles_pos = [left_Low, left_Low];
    
 
    % get trial order info
     [nameList, vidCond, imVal, predVal] = TrialOrderPractice();
%     vidlogfile = sprintf('data/AffVids_vidlogfile_%d.mat',subject_code);
%     save(vidlogfile,'videoTrials');
%else
    %vidlogfile = sprintf('data/AffVids_vidlogfile_%d.mat',subject_code);
    %load(vidlogfile);
%end


   
    movie = [];
    %Load up video file
   
for i = 1:numel(nameList)      %length(VIDEO_ID),    
    try
        % Open movie file:
        movie(i) = Screen('OpenMovie', windowptr, [studydir,sprintf('/finalVideos/%s',nameList{i})]);
        %EDIT TO ACCOMMODATE MULTIPLE MOVIE FILES, can only do one right now
    catch
        Screen('CloseAll');    
        error('Could not load video\n');
        break;
    end
end




%Set up stimulus presentation order
ntrials = numel(nameList); %length(movie);   %VIDEO_ID);


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

DrawFormattedText(windowptr, 'Press any key to continue', 'center', 'center'); %,[image_lb image_tb image_rb image_bb]
Screen('Flip',windowptr); %show instruction
DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5

trigged = 0;
if usetrigger == 1,
    while trigged == 0,
        [keyIsDown,secs_fromKbCheck,keyCode] = KbCheck();            
        if keyIsDown,%if response is made
            foo = KbName(keyCode);
            if ~isstrprop(foo(1),'digit'),
                trigged = 1;
                [anchor] = Screen('Flip', windowptr);%Displays screen
            end
        end
        WaitSecs(.01);%Wait to avoid keypress spillover
    end
else
    while trigged == 0,
        [keyIsDown,secs_fromKbCheck,keyCode] = KbCheck();            
        if keyIsDown,%if response is made
            foo = KbName(keyCode);
            trigged = 1;
%             if run == 1
             [anchor] = Screen('Flip', windowptr);%Displays screen
%             else
%                 [notAnchor] = Screen('Flip', windowptr);
%             end
        end        
        WaitSecs(.01);%Wait to avoid keypress spillover        
    end
end
ccc = [];



ISItimeArraySp = [3,4];
ISItimeArraySo = [3,4];
ISItimeArrayHe = [3,4];

ISItimeArraySp = ISItimeArraySp(randperm(length(ISItimeArraySp)));
ISItimeArraySo = ISItimeArraySp(randperm(length(ISItimeArraySo)));
ISItimeArrayHe = ISItimeArraySp(randperm(length(ISItimeArrayHe)));

hePlace = 1;
soPlace = 1;
spPlace = 1;


DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5
[StimulusOffset] = Screen('Flip',windowptr); %ITI blank screen
WaitSecs(beforeTime); %delay before movie.


%BEGIN
for i = 1:3%ntrials, %iterate through movies...

        %print start time to file...
        %fprintf(fid,'START TIME: %1.3f\n',GetSecs - anchor);

        if vidCond(i) == 1
            
            ISItime = ISItimeArrayHe(hePlace);
            hePlace = hePlace +1;
          elseif vidCond(i) == 2
            
            ISItime = ISItimeArraySo(soPlace);
            soPlace = soPlace +1;
        else
            
            ISItime = ISItimeArraySp(spPlace);
            spPlace = spPlace +1;
        end
        
        % SHOW WORD HERE
        if vidCond(i) == 1
            DrawFormattedText(windowptr, 'Heights', 'center', 'center');
        elseif vidCond(i) == 2
            DrawFormattedText(windowptr, 'Social', 'center', 'center');
        else
            DrawFormattedText(windowptr, 'Spider', 'center', 'center');
        end
        
        [CueWordOnset] = Screen('Flip',windowptr); %cue word
        wordStart = CueWordOnset - anchor;

        WaitSecs(wordTime);
        wordEnd = GetSecs - anchor;
        DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5
        [StimulusOffset] = Screen('Flip',windowptr); %ITI blank screen
        WaitSecs(ISItime); %delay before movie.
        
         %Flips to rating screen
        
       pre_stim_qs_rt = NaN(1,numel(pre_stimulus_questions));
       pre_stim_qs_resp = NaN(1,numel(pre_stimulus_questions));
       for pre_q_index=1:numel(pre_stimulus_questions)
           SetMouse(xcen,ycenter,windowptr);
        [RateOnset] = Screen('Flip', windowptr)
        
           question = pre_stimulus_questions{pre_q_index};
           question_pos = pre_stimulus_questions_pos(pre_q_index);
           poles = pre_stimulus_poles{pre_q_index};
           poles_pos = pre_stimulus_poles_pos(pre_q_index);
           
            [pre_stim_qs_rt(pre_q_index),...
             pre_stim_qs_resp(pre_q_index)] = DrawQuestion(question,...
                                            question_pos, poles,poles_pos,...
                                            ycenter, right_LineEdge,left_LineEdge, line_vert,...
                                            top_all,bottom_all, markercolor,markercenter, size_marker,...
                                            windowptr, RateOnset,mvfac,left_High);
            WaitSecs(0.25);
       end
       
        
        
        
        
        if showmovs,
            % Start playback engine:
            vidstart = GetSecs - anchor;
            Screen('PlayMovie', movie(i), 1);
 
            % Playback loop: Runs until end of movie or keypress:
            ctex = false;
            while ~ctex
                % Wait for next movie frame, retrieve texture handle to it
                tex = Screen('GetMovieImage', windowptr, movie(i));
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
            Screen('PlayMovie', movie(i), 0);

            % Close movie:
            Screen('CloseMovie', movie(i));

            %print movie end info to file...
            vidend = GetSecs - anchor;


        else
            vidstart = NaN;
            vidend = NaN;
        end %if showmovs
        
        RESP_psqs = NaN(1,numel(poststimqs));
        RT_psqs = NaN(1,numel(poststimqs));
        for ii = 1:numel(poststimqs), 

            SetMouse(xcen,ycenter,windowptr);
            mouseclick = [0,0,0];
            keyIsDown = 0;
            [RateOnset] = Screen('Flip', windowptr); %Flips to rating screen
            
           [reaction_time,q_resp] = DrawQuestion(poststimqs{ii}, poststimqs_pos(ii),...
                    poststimqs_poles{ii},poststimqs_poles_pos(ii),...
                    ycenter, right_LineEdge,left_LineEdge, line_vert,...
                    top_all,bottom_all, markercolor,markercenter, size_marker,...
                    windowptr, RateOnset, mvfac, left_High);
            RESP_psqs(ii) = q_resp;
            RT_psqs(ii) = reaction_time;
                                      
            %mouse click spill over
            WaitSecs(0.25);
        end
        
        DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5
        [StimulusOffset] = Screen('Flip',windowptr); %ITI blank screen

        WaitSecs(inbtwtime); %delay before movie.
        fprintf(fid,'%s %d %d %d %1.3f %1.3f ',nameList{i},vidCond(i),imVal(i),predVal(i),wordStart, wordEnd);
       %log expected fear rating and rt
        fprintf(fid,'%1.3f %1.3f ',pre_stim_qs_resp(1),pre_stim_qs_rt(1));
        %log current anxiety rating and rt
        fprintf(fid,'%1.3f %1.3f ',pre_stim_qs_resp(2),pre_stim_qs_rt(2));
        %log video start and end
        fprintf(fid,'%1.3f %1.3f ',vidstart,vidend);
        %log post stim qs
        fprintf(fid,'%1.3f %1.3f %1.3f %1.3f %1.3f %1.3f %1.3f %1.3f \n',RESP_psqs,RT_psqs);
        

end

DrawFormattedText(windowptr, '+', 'center', 'center');%Draw text , 60, 0, 0, 1.5
[StimulusOffset] = Screen('Flip',windowptr); %ITI blank screen
WaitSecs(afterTime);


fclose(fid);
DrawFormattedText(windowptr, 'This part is complete.', 'center', 'center');%Draw text
Screen('Flip', windowptr);%Displays screen
ShowCursor;
WaitSecs(kb_spillover_time);%Wait to avoid keypress spillover
KbWait();
Screen('CloseAll');
clear all;


