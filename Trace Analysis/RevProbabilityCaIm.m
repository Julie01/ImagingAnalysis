%stacks the ratios pre and post all reversals:
clearvars -except ImagingData

bintype=1;

CC=0;

home=cd;
prerev=NaN(1,1200);
cc=1;
positiveDF=NaN(length(ImagingData),40);
revAll=[];
ratioAll=[];
diffDFAll=[];

for F=1:length(ImagingData)
    
    ratio=ImagingData{F}.ratioFo;
    ratio_cent=ratio-nanmedian(ratio);
    ratio_norm=ratio_cent/rms(ratio_cent);
    ratio_norm=medfilt1(ratio_norm,30);
    ratio_norm=smoothn(ratio_norm,30);
    
    ratioAll=[ratioAll,ratio'];
    
    
    %reversals:
    RevON=ImagingData{F}.RevFrames30hz(1:2:end);
    RevEND=ImagingData{F}.RevFrames30hz(2:2:end);
    Revs=zeros(1,length(ratio));
    Revs(RevON)=1;
    Revs=Revs(1:length(ratio));
    revAll=[revAll,Revs];
    
    %filter above undulation frequency:
    Y=ratio_norm(1:45:end);
    Y=vertcat(Y, ratio_norm(end));
    fDF=interp1(1:length(Y),Y,1:1/44.99:length(Y));
    diffDF=(fDF(10:end)-fDF(1:end-9));
    diffDF=[NaN(1,10) diffDF];
    diffDF=diffDF(1:length(ratio));
    
    diffDFAll=[diffDFAll,diffDF];
    
    %find episodes of constant rise
    %(1) derivative
    md=NaN;
    c=1;
    for i=1:40:length(diffDF)-80
        md(c)=mean(diffDF(i:i+80));
        c=c+1;
    end
    
    n=length(find(md>0.02));
    positiveDF(F,1:n)=(find(md>0.02))*40;
    positiveDF(find(positiveDF>7900))=NaN;
    
    %     %plot
    %     cla
    %     hold on
    %     plot(ratio_norm,'--','color',[0.5 0.6 0.6])
    %     plot(fDF,'k')
    %     if positiveDF(F,n)>7872
    %         positiveDF(F,n)=NaN;
    %         n=n-1;
    %     end
    %
    % %     scatter(positiveDF(F,1:n),fDF(positiveDF(F,1:n)),'r','sizedata',3)
    %     for  i=1:n
    %         plot(positiveDF(F,i):positiveDF(F,i)+80,fDF(positiveDF(F,i):positiveDF(F,i)+80),'m','linewidth',2)
    %     end
    
    
end


%% bin& frequency
C=1;
for delay =0:30:120
mR=NaN;
mD=NaN;
revN=NaN;
revNnorm=NaN;

cc=1;
binsize=0.01;


bi=find(diffDFAll>-0.0002 & diffDFAll<0.0002);
diffDFAll(bi)=NaN;

for i=-0.16 :binsize:(0.16-binsize)
    
    if bintype==1
        bin_idx= find(diffDFAll>i & diffDFAll<=i+binsize);
    else
        bin_idx= find(ratioAll>i & ratioAll<=i+binsize);
    end
    bin_idx(bin_idx>length(diffDFAll)-delay)=[];
    
    if ~isempty(bin_idx)
        
        bindR=diffDFAll(bin_idx);
        binR=ratioAll(bin_idx);
        revV=revAll(bin_idx+delay);
        
        mR(cc)=nanmedian(binR);
        mD(cc)=nanmean(bindR);
        revN(cc)=nansum(revV);
        revNnorm(cc)=nansum(revV)/length(bin_idx);
    end
    
    cc=cc+1;
    
end

% plot:
subtightplot(1,5,C)
plot(revNnorm)

if bintype==1
    set(gca,'XTick',[1:5:length(mD)])
    set(gca,'XTickLabel',round(mD(1:5:end)*100)/100);
     xlabel('normalized dF/F0')
else
    set(gca,'XTick',[1:3:length(mR)])
    set(gca,'XTickLabel',round(mR(1:3:end)*1)/1);
    xlabel('F/F0')
end
if C==1
 ylabel('reversal frequency')
end
title(delay)
 ylim([0 0.004])
 xlim([0 cc-1])

C=C+1;
end


