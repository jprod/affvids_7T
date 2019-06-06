%Affective Videos
%Trial Order Script
%Purpose: To organize stimuli and onset times. Output them as fprintf
%statements...

%e.g. output:

%Trial, Onsettime, Stimulus, Stimulus Properties (could be many)- duration,
%experimenter category

%ITI - fixed at say 11 seconds...

%Data file
%Subject 1, date...
%1, 5, Vidfile1.mov, 19.22, Snake, 1, responses.... etc.
%2, 29.22, Vidfile6.mov, 20, Heights, 
%3, ..., Vidfile13.mov, 19.22, Snake, 2
%4, ..., Vidfile3.mov, 19.22, Snake, 3
%5, ..., Vidfile34.mov, 19.22, Snake, 2
%6, ..., Vidfile8.mov, 19.22, Snake, 1
%7, ..., Vidfile19.mov, 19.22, Snake, 1

%Randomizing... use randperm(...)

%This goes into a psychtoolbox script that loads videos, presents them when
%you want them to, and collects behavioral responses.
function [nameList, vidCond, imVal, predVal] = TrialOrder(videofiles)
% for number: the number movie it is to perform this function on
equal = false;
while ~equal

trialOrd = randperm(numel(videofiles));



nameList = {};
for i = 1:numel(videofiles)
    nameList{i} = videofiles{trialOrd(i)}{1};   
end
% return list of names in the trialOrd******* to use in the AffVids program


%get condition order and imminence order
vidCond = zeros(numel(videofiles),1);
imVal = zeros(numel(videofiles),1);



for i = 1:numel(videofiles), %iterate across files...
    foo = videofiles{trialOrd(i)}{1}; %gets video name...
    %nameList{i} = foo;
    
    locofunderscore = strfind(foo,'_'); %location of underscore
    
    if strcmp(foo(1:4),'heig')
        vidCond(i) = 1;
    elseif strcmp(foo(1:4),'soci')
        vidCond(i) = 2;
    elseif strcmp(foo(1:4),'spid')
        vidCond(i) = 3;
    end
    
    
    if strcmp(foo((locofunderscore+1):(locofunderscore+2)),'lo')
        imVal(i) = 1;
    elseif strcmp(foo((locofunderscore+1):(locofunderscore+2)),'hi')
        imVal(i) = 2;
    else
        error('imminence not found')
    end
end

% The first trial is always different
predVal = zeros(numel(videofiles),1);

% calculate whether the trial is same or different from the one before
for i = 1:numel(videofiles);
    fooBcond = vidCond(i);
    fooBim = imVal(i);
    
    fooAcond = NaN;
    fooAim = NaN;
    if i ~= 1 
        fooAcond = vidCond(i-1);
        fooAim = imVal(i-1);
    end    
    
    
    if (fooAcond == fooBcond)  %&& (fooAim == fooBim)
        predVal(i) = 1;
    else
        predVal(i) = 2;
    end
  
    
end
    
numSame = sum(predVal(:) == 1);
numDiff = sum(predVal(:) == 2);

%equal = (numSame == numDiff);

%catName = ['Heights' 'Social' 'Spider'];


%answerDur = 

 %logfile = sprintf('data/AffVids_Run1_logfile.dat');
% %open log file 
 %fileID = fopen(logfile,'a+');

%current time
% t = 0;
% for i = 1:numel(videofiles)
    %how to get duration of videos?
    %dur = lengthfunction(videofiles(trialOrd(i)))

%     vid = VideoReader(videofiles(trialOrd(i)));
%     dur = vid.Duration;
    
    %fprintf(fileID,'%d, %s, %d, %d\n',i,videofiles{trialOrd(i)},vidCond(i),imVal(i));
  %  fprintf('%d, %d, %s, %d, %d, %d/n',i,t,videofiles(trialOrd(i)),dur,vidCond(i),imVal(i));
     %t = t + dur + answerDur
     
     
     equal = length(vidCond(predVal ==1 & vidCond == 3)) == 2 && length(vidCond(predVal ==1 & vidCond == 2)) == 2 && length(vidCond(predVal ==1 & vidCond == 1)) == 2;
     
         
     
end

end
%visualize design? imagesc([vidCond, imVal, predVal])


