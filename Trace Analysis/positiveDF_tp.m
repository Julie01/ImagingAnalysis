%stacks the ratios pre and post all reversals:
clearvars -except ImagingData


CC=0;

home=cd;
prerev=NaN(1,1200);
cc=1;
positiveDF=NaN(length(ImagingData),40);
revAll=[];
posVAll=[];
% figure

for F=1:length(ImagingData)
    
    ratio=ImagingData{F}.ratioFo;
    ratio_cent=ratio-nanmedian(ratio);
    ratio_norm=ratio_cent/rms(ratio_cent);
    ratio_norm=medfilt1(ratio_norm,30);
    ratio_norm=smoothn(ratio_norm,30);
    
    %reversals:
    RevON=ImagingData{F}.RevFrames30hz(1:2:end);
    RevEND=ImagingData{F}.RevFrames30hz(2:2:end);
    Revs=zeros(1,length(ratio));
    Revs(RevON)=1;
    Revs=Revs(1:length(ratio));
    revAll=[revAll,Revs];
    
    %filter above undulation frequency:
    %filter above undulation frequency:
    Y=ratio_norm(1:45:end);
    Y=vertcat(Y, ratio_norm(end));
    fDF=interp1(1:length(Y),Y,1:1/44.99:length(Y));
    diffDF=(fDF(10:end)-fDF(1:end-9));
    diffDF=[NaN(1,10) diffDF];
    diffDF=diffDF(1:length(ratio));
   
    
    %find episodes of constant rise
    %(1) derivative
    md=NaN;
    pV=zeros(1,length(ratio));
    
    c=1;
    for i=1:40:length(diffDF)-80
        
        md(c)=mean(diffDF(i:i+80));
        
        if md(c)>0.02
            pV(i:i+80)=1;
        end
        
        c=c+1;
        
    end
    
    si=find(diff(pV)==1);
    ei=find(diff(pV)==-1);
    pVcs=NaN(1,length(ratio));
    for i=1:length(si)
        pVcs(si(i):ei(i))=cumsum(diffDF(si(i):ei(i)));
    end
        
    posVAll=[posVAll,pVcs];
    

end

%% bin& frequency %%%%

C=1;
bintype=1;

for delay =0:10:20
    mR=NaN;
    mP=NaN;
    revN=NaN;
    revNnorm=NaN;
    
    cc=1;
    first=-1;
    last=25;
    binsize=0.25;
    
    for i=first :binsize:(last-binsize)
        
        if bintype==1
            bin_idx= find(posVAll>i & posVAll<=i+binsize);
        else
            bin_idx= find(ratioAll>i & ratioAll<=i+binsize);
        end
        
        if ~isempty(bin_idx)
            
            binPos=posVAll(bin_idx);
            revV=revAll(bin_idx+delay);

            mP(cc)=nanmean(binPos);
            revN(cc)=nansum(revV);
            revNnorm(cc)=nansum(revV)/length(bin_idx);
        end
        
        cc=cc+1;
        
    end
    
    % plot:
    subtightplot(1,3,C)
    plot(revNnorm)
    
    if bintype==1
        set(gca,'XTick',[1:cc/5:length(mP)])
        set(gca,'XTickLabel',round(mP(1:cc/5:end)*10)/10);
        xlabel('cumsum positive dF/dT ')
    else
        set(gca,'XTick',[1:3:length(mR)])
        set(gca,'XTickLabel',round(mR(1:3:end)*1)/1);
        xlabel('F/F0')
    end
%     if C==1
%         ylabel('reversal frequency')
%     end
title(delay)
ylim([0 0.02])
xlim([0 cc-1])

C=C+1;
end





