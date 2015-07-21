
CC=1;
figure('Position',[10 90 900 800]);
load CaDataConcat

for F=1:8
clearvars -except F CC outputTrace inputTrace trialLabel 
fps=30;
numTrials=length(inputTrace);
steps=5;
winsize=300*F;
xf=16/F;
winsize=winsize-1;
rValues=NaN(numTrials,round((16000-winsize)/ceil(winsize/steps))-1);
nc=5;
nr=ceil(numTrials/nc);



for i=1:numTrials
    if i==10
        continue
    end
    
    goodFrames=1:min([length(inputTrace{i}) length(outputTrace{i}) ]);    
    thisInputTrace=medfilt1(inputTrace{i}(goodFrames));
    thisOutputTrace=medfilt1(outputTrace{i}(goodFrames));
    thisLabel=trialLabel{i};
   
   if thisLabel(end-1:end)=='T2' | thisLabel(end-1:end)=='T1'
 %  if thisLabel(end-1:end)=='T1'
    
    cc=1;
    for W=1:winsize/steps:length(thisOutputTrace)-winsize
        W=floor(W);
        winin=thisInputTrace(W:W+winsize);
        winout=thisOutputTrace(W:W+winsize);
        
        winInputTrace_cent=winin-nanmean(winin);
        winOutputTrace_cent=winout-nanmean(winout);
        
        winInputTrace_norm=winInputTrace_cent/rms(winInputTrace_cent);
        winOutputTrace_norm=winOutputTrace_cent/rms(winOutputTrace_cent);
        
        %correlate current window
        rValues(i,cc)=nancorr(winInputTrace_norm,winOutputTrace_norm);
         xt(cc)=W;
        cc=cc+1;
        
    end
    
    end
    
end % end exp loop

%%
subtightplot(4,2,CC,[0.06,0.02])
plot(rValues')
hold on
plot(nanmean(rValues), 'linewidth',2,'color','k')
title(['window size=' num2str(winsize) '   max r=' num2str(max(nanmean(round(rValues*100))/100)) ...
    '   mean r=' num2str(nanmean(nanmean(round(rValues*100))/100))])
set(gca,'XTick', 1:xf:size(rValues,2))
set(gca,'XTickLabel',xt(1:xf:end));
ylabel( 'r value')
ylim([-0.6 1])

CC=CC+1;
end

xlabel('start frame')

