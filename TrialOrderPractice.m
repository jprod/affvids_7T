%Affective Videos
%Trial Order Script for Practice Run

%This goes into a psychtoolbox script that loads videos, presents them when
%you want them to, and collects behavioral responses.
function [nameList, vidCond, imVal, predVal] = TrialOrderPractice()

    videofiles = {...
       'social_high_P_1.m4v'
       'heights_high_P_1.mov'
       'spider_high_P_1.mov'
    };


trialOrd = randperm(numel(videofiles));


nameList = {};
for i = 1:numel(videofiles)
    nameList{i} = videofiles{trialOrd(i)};   
end
% return list of names in the trialOrd******* to use in the AffVids program


%get condition order and imminence order
vidCond = zeros(numel(videofiles),1);
imVal = zeros(numel(videofiles),1);



for i = 1:numel(videofiles), %iterate across files...
    foo = videofiles{trialOrd(i)}; %gets video name...
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

     
end

%end
%visualize design? imagesc([vidCond, imVal, predVal])


