%stacks the ratios pre and post all reversals:
clearvars -except ImagingData


CC=0;

home=cd;
prerev=NaN(1,1200);
cc=1;
positiveDF=NaN(length(ImagingData),40);
ratioAll=[];
revAll=[];
bearingAll=[];
% figure

for F=1:length(ImagingData)
    
    %ratio:
    ratio=ImagingData{F}.ratioFo;
    ratio_cent=ratio-nanmedian(ratio);
    ratio_norm=ratio_cent/rms(ratio_cent);
    ratio_norm=medfilt1(ratio_norm,30);
    ratio_norm=smoothn(ratio_norm,30);
    ratioAll=[ratioAll; ratio_norm];
    
    %reversals:
    RevON=ImagingData{F}.RevFrames30hz(1:2:end);
    RevEND=ImagingData{F}.RevFrames30hz(2:2:end);
    Revs=zeros(length(ratio),1);
    for i=1:length(RevEND)
        Revs(RevON(i)+20:RevEND(i)-5,1)=1;
    end
    Revs=Revs(1:length(ratio));
    revAll=[revAll;Revs];
    
    
    % bearing:
    XY=ImagingData{F}.XY;
    [bearing]=getbearing_freelyMoving_global(XY(:,1),XY(:,2),1,9);
    bearing=[bearing ; NaN(length(ratio)-length(bearing),1)];
    bearing=bearing(1:length(ratio));
    bearingAll=[bearingAll;bearing];
    
    
end

%% bin& frequency %%%%

%NaN outliers:
ratioAll(ratioAll<-2 | ratioAll>2)=NaN;
C=1;
bintype=1;

mR=NaN;
mB=NaN;
mRrev=NaN;

cc=1;
first=1;
last=180;
binsize=10;

for i=first :binsize:(last-binsize)
    
    if bintype==1
        bin_idx= find(bearingAll>i & bearingAll<=i+binsize);
    else
        bin_idx= find(ratioAll>i & ratioAll<=i+binsize);
    end
    
    if ~isempty(bin_idx)
        
        revV=revAll(bin_idx);
        ri=find(revV==1);
        
        bearingBin=bearingAll(bin_idx);
        ratioBin=ratioAll(bin_idx);
        ratioBinR=ratioBin(ri);
        ratioBin(ri)=NaN;
        %             subplot(1,2,2)
        %             hold on
        %             scatter(bearingBin(ri),ratioBinR)
        
        
        %             subplot(1,2,1)
        %             hold on
        %             scatter(bearingBin,ratioBin)
        
        mB(cc)=nanmedian(bearingBin);
        mRrev(cc)=nanmean(ratioBinR);
        mR(cc)=nanmean(ratioBin);
        
    end
    
    cc=cc+1;
    
end

%% plot:
figure
plot(mR,'linewidth',2)
hold on
plot(mRrev,'r','linewidth',2)
legend('forward','reversal','Location','NorthWest')

if bintype==1
    set(gca,'XTick',[1:1:length(mB)])
    set(gca,'XTickLabel',round(mB(1:1:end)*1)/1);
    xlabel('bearing ')
else
    set(gca,'XTick',[1:3:length(mR)])
    set(gca,'XTickLabel',round(mR(1:3:end)*1)/1);
    xlabel('F/F0')
end

ylim([-0.5 0.5])
% xlim([0 cc-1])

ylabel('mean normalized ratio')
xlabel('bearing')








