%Julia code

clear
cc=1;

dirList=dir('*BAGxAFD.mat');
m=1;

load CaData

%%%%%%%%%


figure('Position',[0 0 1200 800]);

fps=30;
numTrials=length(inputTrace);
nc=5;
nr=ceil(numTrials/nc);



for i=1:numTrials
    
    subtightplot(nr,nc,i);

    goodFrames=1:min([length(inputTrace{i}) length(outputTrace{i}) ]);

    thisInputTrace=inputTrace{i}(goodFrames);
    thisOutputTrace=outputTrace{i}(goodFrames);

    tv=(1:length(goodFrames))/fps;

    thisInputTrace_cent=thisInputTrace-nanmean(thisInputTrace);
    thisOutputTrace_cent=thisOutputTrace-nanmean(thisOutputTrace);

    thisInputTrace_norm=thisInputTrace_cent/rms(thisInputTrace_cent);
    thisOutputTrace_norm=thisOutputTrace_cent/rms(thisOutputTrace_cent);

    plot(tv,thisInputTrace_norm,'r');
    hold on;
    plot(tv,thisOutputTrace_norm,'b');
    h=intitle(trialLabel{i});


end

