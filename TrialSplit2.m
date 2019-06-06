function [videolist] = TrialSplit2()

nTrials = 3;

spiderHigh = {...
    'spider_high_1.mov'
    'spider_high_2.m4v'
    'spider_high_3.mov'
    'spider_high_4.m4v'
    'spider_high_5.m4v'
    'spider_high_6.mov'
    };

spiderLow = {...
    'spider_low_1.m4v'
    'spider_low_2.mov'
    'spider_low_3.m4v'
    'spider_low_4.m4v'
    'spider_low_5.mov'
    'spider_low_6.m4v'
    };

heightsHigh = {...
    'heights_high_1.m4v'
    'heights_high_2.mov'
    'heights_high_3.m4v'
    'heights_high_4.m4v'
    'heights_high_5.mov'
    'heights_high_6.mov'
    };

heightsLow = {...
    'heights_low_1.m4v'
    'heights_low_2.m4v'
    'heights_low_3.mov'
    'heights_low_4.m4v'
    'heights_low_5.m4v'
    'heights_low_6.m4v'
    };

socialHigh = {...
    'social_high_1.mov'
    'social_high_2.mov'
    'social_high_3.mov'
    %'social_high_4.mov'
    'social_high_4_replacement.mov'
    'social_high_5.m4v'
    'social_high_6.mov'
    };

socialLow = {...
    'social_low_1.m4v'
    'social_low_2.mov'
    'social_low_3.m4v'
    'social_low_4.m4v'
    'social_low_5.m4v'
    'social_low_6.m4v'
    };



trialOrdSpiderHigh = randperm(numel(spiderHigh));

trialOrdSpiderLow = randperm(numel(spiderLow));

trialOrdHeightsHigh = randperm(numel(heightsHigh));

trialOrdHeightsLow = randperm(numel(heightsLow));

trialOrdSocialHigh = randperm(numel(socialHigh));

trialOrdSocialLow = randperm(numel(socialLow));

nameListSpH = {};
for i = 1:numel(spiderHigh)
    nameListSpH{i} = spiderHigh{trialOrdSpiderHigh(i)};
end

nameListSpL = {};
for i = 1:numel(spiderLow)
    nameListSpL{i} = spiderLow{trialOrdSpiderLow(i)};
end

nameListHeH = {};
for i = 1:numel(heightsHigh)
    nameListHeH{i} = heightsHigh{trialOrdHeightsHigh(i)};
end

nameListHeL = {};
for i = 1:numel(heightsLow)
    nameListHeL{i} = heightsLow{trialOrdHeightsLow(i)};
end

nameListSoH = {};
for i = 1:numel(socialHigh)
    nameListSoH{i} = socialHigh{trialOrdSocialHigh(i)};
end

nameListSoL = {};
for i = 1:numel(socialLow)
    nameListSoL{i} = socialLow{trialOrdSocialLow(i)};
end

videolist = {};
k = 1;
j = 2;
for i = 1:nTrials,
    
    videolist{i} = {...
        nameListSoL(k)
        nameListSoL(j)
        nameListSoH(k)
        nameListSoH(j)
        nameListSpL(k)
        nameListSpL(j)
        nameListSpH(k)
        nameListSpH(j)
        nameListHeL(k)
        nameListHeL(j)
        nameListHeH(k)
        nameListHeH(j)
        };
    
    k = k +2;
    j = j +2;
end

end