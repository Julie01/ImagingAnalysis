%stacks the ratios pre and post all reversals:
clearvars -except ImagingData

 close all
common_peaks=NaN(length(ImagingData),3);
phaseDifs=NaN(length(ImagingData),3);
CC=1;
winsize=150;
steps=2;
home=cd;
prerev=NaN(1,1200);
cc=1;
positiveDF=NaN(length(ImagingData),40);
ratioAll=[];
revAll=[];
bearingAll=[];
bearingGlobAll=[];
rNorth=NaN(length(ImagingData),40);
rSouth=NaN(length(ImagingData),40);
warning off
    mBAG=NaN(1,10);
    mAFD=NaN(1,10);
    mSens=NaN(1,10);
f1=figure;
f2=figure;
bagAll=[];
afdAll=[];
SensNormAll=[];
dCdTAll=[];

for F=1:length(ImagingData)
    
    if isfield(ImagingData{F}, 'cherry_AFD')==1
    
    %ratio:
    cherry=medfilt1(ImagingData{F}.cherry,5);
    gcamp=medfilt1(ImagingData{F}.gcamp,5);
    eq_ratio=(gcamp/nanmean(gcamp))./(cherry/nanmean(cherry));
    eq_ratio_cent=eq_ratio-nanmedian(eq_ratio);
    eq_ratio_norm=smoothn((eq_ratio_cent/nanstd(eq_ratio_cent)),10);
    
    %ratio AFD:
    cherry_AFD=medfilt1(ImagingData{F}.cherry_AFD,5);
    gcamp_AFD=medfilt1(ImagingData{F}.gcamp_AFD,5);
    eq_ratio=(gcamp_AFD/nanmean(gcamp_AFD))./(cherry_AFD/nanmean(cherry_AFD));
    eq_ratio_cent=eq_ratio-nanmedian(eq_ratio);
    ni=find(isnan(eq_ratio_cent));
    eq_ratio_norm_AFD=smoothn((eq_ratio_cent/nanstd(eq_ratio_cent)),10);
    eq_ratio_norm_AFD(ni)=NaN; %reintroducing NaNs after smooth interpolation
    
    % NaN huge ration jumps( focus artefacts)
    bi=find(abs(diff(eq_ratio_norm_AFD))>0.3 );
    bi2=find(abs(eq_ratio_norm_AFD)>2.6);
    bi=[bi; bi2];
    for i=-10:10
        try
        eq_ratio_norm_AFD(bi+i)=NaN;
        end
    end
    
    %CO2
    sensIn=ImagingData{F}.CO2;
    SensNorm=sensIn-nanmedian(sensIn);
    SensNorm=smoothn(SensNorm./nanstd(SensNorm),10);
    
    %reversals:
    RevON=ImagingData{F}.RevFrames30hz(1:2:end);
    RevEND=ImagingData{F}.RevFrames30hz(2:2:end);
    Revs=zeros(length(eq_ratio_norm),1);
    for i=1:length(RevEND)
        Revs(RevON(i)+5:RevEND(i)-5,1)=1;
    end
    Revs=Revs(1:length(eq_ratio_norm));
    %     revAll=[revAll;Revs];
    ri=find(Revs==1);
    
    
    % bearing:
    XY=ImagingData{F}.XY;
    [bearingGlob smX smY]=getbearing_freelyMoving_global(XY(:,1),XY(:,2),1,58);
    [bearingY]=getbearing_Y_global(XY(:,1),XY(:,2),1,58);
    bearingY=[bearingY ; NaN(length(eq_ratio_norm)-length(bearingY),1)];
    bearingGlob=[bearingGlob ; NaN(length(eq_ratio_norm)-length(bearingGlob),1)];
    
    %remove reversal episodes:
%     bearingGlob(ri)=NaN;
%     eq_ratio_norm(ri)=NaN;
%     eq_ratio_norm_AFD(ri)=NaN;
    
    %adjust vector length:
    bearingGlob=bearingGlob(1:length(eq_ratio_norm));
    
    % plot:
    figure(f1)
    cla
    %subtightplot(4,4,CC)
    hold on
    plot(SensNorm,'k')
    plot(eq_ratio_norm,'b')
    plot(eq_ratio_norm_AFD,'color',[1 0 0.5])
    try
    h=scatter(ri,SensNorm(ri),'marker','.','SizeData',1);
    set(h,'MarkerEdgeColor',[0.5 0.5 0.5]);
    end
    set(gca,'Xgrid','on');
    
    %% concat data:
    try
    afd=eq_ratio_norm_AFD;
    bag=eq_ratio_norm(1:length(afd));
    catch
        bag=eq_ratio_norm;
         afd=eq_ratio_norm_AFD(1:length(bag));
    end
    try
    SensNorm=SensNorm(1:length(bag));
    catch
        SensNorm=[SensNorm NaN(1,length(bag)-length(SensNorm))];
        SensNorm=SensNorm(1:length(bag));
    end
    
    bagAll=[bagAll; bag];
    afdAll=[afdAll; afd];
    SensNormAll=[SensNormAll SensNorm] ;
    
    
    np=num2str(CC);
    if CC<10
        np= [num2str(0) num2str(CC)];
    end

   CC=CC+1; 
   
   
    end
    
    
end
legend ('CO2','BAG','AFD');

%% bin
    binsize=0.3;

    cc=1;
    for i=-2.5 :binsize:(2.5-binsize)
        
        bin_idx= find(bagAll>i & bagAll<=i+binsize);
        if length(bin_idx)>100
            
            bV=bagAll(bin_idx);
            aV=afdAll(bin_idx);
            sV=SensNormAll(bin_idx);
            mBAG(1,cc)=nanmedian(bV);
            mAFD(1,cc)=nanmedian(aV);
            mSens(1,cc)=nanmean(sV);
        end
        cc=cc+1;
    end
    %% plot  bins:
    figure(f2)
    %%
    subtightplot(1,2,1)
    bar(mSens(1,:))
set(gca,'XTick',[1:1:length(mBAG(1,:))])
set(gca,'XTickLabel',round(mBAG(1,1:1:end)*10)/10);
title('norm CO2')

subtightplot(1,2,2)
bar(mAFD(1,:))
set(gca,'XTick',[1:1:length(mBAG(1,:))])
set(gca,'XTickLabel',round(mBAG(1,1:1:end)*10)/10);
title('norm AFD')


