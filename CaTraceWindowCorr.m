

load CaDataConcat
fps=30;
numTrials=length(inputTrace);
steps=5;
winsize=600;
winsize=winsize-1;

rValues=NaN(numTrials,round((16000-winsize)/ceil(winsize/steps)));
nc=5;
nr=ceil(numTrials/nc);



for i=1:numTrials
    
    goodFrames=1:min([length(inputTrace{i}) length(outputTrace{i}) ]);    
    thisInputTrace=medfilt1(inputTrace{i}(goodFrames));
    thisOutputTrace=medfilt1(outputTrace{i}(goodFrames));
    thisLabel=trialLabel{i};

  if thisLabel(end-1:end)=='T2' | thisLabel(end-1:end)=='T1'
 % if thisLabel(end-1:end)=='T1'
    
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

figure('Position',[10 200 1100 400]);
subtightplot(1,2,1)
plot(rValues')
hold on
plot(nanmean(rValues), 'linewidth',2,'color','k')
title(['window size=' num2str(winsize) '   max r=' num2str(max(nanmean(round(rValues*100))/100)) ])
set(gca,'XTick', 1:4:size(rValues,2))
set(gca,'XTickLabel',xt(1:4:end));
xlabel('start frame')
ylabel( 'r value')
ylim([-0.6 1])

subtightplot(1,2,2)
imagesc(rValues)
set(gca,'XTick',1:4: size(rValues,2))
set(gca,'XTickLabel',xt(1:4:end));
colorbar
caxis([-1.1 1])




