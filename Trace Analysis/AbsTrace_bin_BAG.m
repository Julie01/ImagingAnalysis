%stacks the ratios pre and post all reversals:
clearvars -except ImagingData

% close all
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
% f1=figure;
f2=figure;
bagAll=[];
afdAll=[];
SensNormAll=[];
dCdTAll=[];
dRdTAll=[];

plots=0;

for F=1:length(ImagingData)
    
    %if isfield(ImagingData{F}, 'cherry_AFD')==1
    
    %ratio:
    
    cherry=medfilt1(ImagingData{F}.cherry,5);
    gcamp=medfilt1(ImagingData{F}.gcamp,5);
    nanIdx=find(isnan(cherry));
    eq_ratio=(gcamp/nanmean(gcamp))./(cherry/nanmean(cherry));
    eq_ratio_cent=eq_ratio-nanmedian(eq_ratio);
    %filter
    eq_ratio_norm=smoothn((eq_ratio_cent/nanstd(eq_ratio_cent)),20);
    eq_ratio_norm=medfilt1(eq_ratio_norm,10);
    eq_ratio_norm(nanIdx)=NaN;
        
    
    %dR/R0:
    sd=nanstd(eq_ratio);
    mr=nanmean(eq_ratio);
    F0=mr-(1.5*sd);
    if F0<min(eq_ratio)
        F0=min(eq_ratio);
    end
    ratioFo=100*((eq_ratio/F0)-1);
    eq_ratio_norm=ratioFo;
    eq_ratio_norm(nanIdx)=NaN;
    

%     %ratio AFD:
%     cherry_AFD=medfilt1(ImagingData{F}.cherry_AFD,5);
%     gcamp_AFD=medfilt1(ImagingData{F}.gcamp_AFD,5);
%     eq_ratio=(gcamp_AFD/nanmean(gcamp_AFD))./(cherry_AFD/nanmean(cherry_AFD));
%     eq_ratio_cent=eq_ratio-nanmedian(eq_ratio);
%     ni=find(isnan(eq_ratio_cent));
%     eq_ratio_norm_AFD=smoothn((eq_ratio_cent/nanstd(eq_ratio_cent)),10);
    %     eq_ratio_norm_AFD(ni)=NaN; %reintroducing NaNs after smooth interpolation
    
    %     % NaN huge ration jumps( focus artefacts)
    %     bi=find(abs(diff(eq_ratio_norm_AFD))>0.3 );
    %     bi2=find(abs(eq_ratio_norm_AFD)>2.6);
    %     bi=[bi; bi2];
    %     for i=-10:10
    %         try
    %         eq_ratio_norm_AFD(bi+i)=NaN;
    %         end
    %     end
    
    %CO2
    sensIn=ImagingData{F}.CO2;
    SensNorm=smoothn(sensIn,30);    
    SensNorm(nanIdx)=NaN;
    
    
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
    
    
%     % bearing:
%     XY=ImagingData{F}.XY;
%     [bearingGlob smX smY]=getbearing_freelyMoving_global(XY(:,1),XY(:,2),1,58);
%     [bearingY]=getbearing_Y_global(XY(:,1),XY(:,2),1,58);
%     bearingY=[bearingY ; NaN(length(eq_ratio_norm)-length(bearingY),1)];
%     bearingGlob=[bearingGlob ; NaN(length(eq_ratio_norm)-length(bearingGlob),1)];
    
    %remove reversal episodes:
        bearingGlob(ri)=NaN;
        eq_ratio_norm(ri)=NaN;
        eq_ratio_norm_AFD(ri)=NaN;
    
%     %adjust vector length:
%     bearingGlob=bearingGlob(1:length(eq_ratio_norm));
    
    % plot:
    if plots==1
        figure(f1)
        cla
        %subtightplot(4,4,CC)
        hold on
        plot(SensNorm,'k')
        plot(eq_ratio_norm,'b')
        %     plot(eq_ratio_norm_AFD,'color',[1 0 0.5])
        try
            h=scatter(ri,SensNorm(ri),'marker','.','SizeData',1);
            set(h,'MarkerEdgeColor',[0.5 0.5 0.5]);
        end
        set(gca,'Xgrid','on');
    end
    
    %% concat data:
    %     try
    %         afd=eq_ratio_norm_AFD;
    %         bag=eq_ratio_norm(1:length(afd));
    %     catch
    %         bag=eq_ratio_norm;
    %         afd=eq_ratio_norm_AFD(1:length(bag));
    %     end
    bag=eq_ratio_norm;
    
    try
        SensNorm=SensNorm(1:length(bag));
        
    catch
        SensNorm=[SensNorm NaN(1,length(bag)-length(SensNorm))];
        SensNorm=SensNorm(1:length(bag));
    end
    
    bagAll=[bagAll; bag];
    %   afdAll=[afdAll; afd];
    
    %derivatives:
    SensNormAll=[SensNormAll SensNorm] ;
    dRdT=[diff(bag); NaN];
    dRdTAll=[dRdTAll ; dRdT];
    
    dCdT=[diff(SensNorm) NaN];
    dCdTAll=[dCdTAll dCdT];
    
    % plot derivatives:
    if plots==1
        
        figure(f2)
        cla
        %subtightplot(4,4,CC)
        hold on
        plot(dRdT,'color',[0.3 0.3 1])
        plot(dCdT,'k')
        %     plot(eq_ratio_norm_AFD,'color',[1 0 0.5])
        try
            h=scatter(ri,dCdT(ri),'marker','.','SizeData',1);
            set(h,'MarkerEdgeColor',[0.5 0.5 0.5]);
        end
        set(gca,'Xgrid','on');
        
    end
    
    np=num2str(CC);
    if CC<10
        np= [num2str(0) num2str(CC)];
    end
    
    CC=CC+1;
    
    
    %  end
    
    
end
legend ('CO2','BAG','AFD');

%%

bintype=1
% % bin for dCdt
if bintype == 1
mBAG=NaN(1,10);
mAFD=NaN(1,10);
mSens=NaN(1,10);
mDC=NaN(1,10);
mDR=NaN(1,10);
binsize=0.00008;

cc=1;
for i=-0.001 :binsize:(0.001-binsize)
    
    bin_idx= find(dCdTAll>i & dCdTAll<=i+binsize);
    
    if length(bin_idx)>200
        
        bV=bagAll(bin_idx);
        %         aV=afdAll(bin_idx);
        sV=SensNormAll(bin_idx);
        dCV=dCdTAll(bin_idx);
        dRV=dRdTAll(bin_idx);
        
        mBAG(1,cc)=nanmedian(bV);
        %         mAFD(1,cc)=nanmedian(aV);
        mSens(1,cc)=nanmean(sV);
        mDC(1,cc)=nanmedian(dCV);
        mDR(1,cc)=nanmedian(dRV);
        if mDR(1,cc)==0
            sd=sort(dRV);
            mDR(1,cc)=nanmean(sd(10:end-10));
        end
            
        
    end
    cc=cc+1;
end

end

% bin for %CO2
if bintype==2
mBAG=NaN(1,40);
mAFD=NaN(1,40);
mSens=NaN(1,40);
mDC=NaN(1,40);
mDR=NaN(1,40);

binsize=0.05;

cc=1;
for i=1 :binsize:(3-binsize)
    
    bin_idx= find(SensNormAll>i & SensNormAll<=i+binsize);
    
    if length(bin_idx)>50
        
        bV=bagAll(bin_idx);
        %         aV=afdAll(bin_idx);
        sV=SensNormAll(bin_idx);
        dCV=dCdTAll(bin_idx);
        dRV=dRdTAll(bin_idx);
        
        mBAG(1,cc)=nanmedian(bV);
        %         mAFD(1,cc)=nanmedian(aV);
        mSens(1,cc)=nanmean(sV);
        mDC(1,cc)=nanmedian(dCV);
        mDR(1,cc)=nanmean(dRV);
        
    end
    cc=cc+1;
end

end

%%%%%% plot %%%%%%%

% plot  bins dCdT:
if bintype==1
figure
 scatter(mDC(1,:),mDR(1,:))
 hold on
 plot(mDC(1,:),mDR(1,:),'--k')
% set(gca,'XTick',[1:2:length(mDC(1,:))])
set(gca,'XTickLabel',round(mDC(1,1:2:end)*300000)/10);
title(' dRdT')
xlabel(' CO2 change (‰/sec)')
ylabel(' dR/dt')
end



% plot  bins CO2:
if bintype==2
figure
scatter(mSens(1,:),mBAG(1,:))
hold on
plot(mSens(1,:),mBAG(1,:),'--k')

% set(gca,'XTick',[1:2:length(mSens(1,:))])
% set(gca,'XTickLabel',round(mSens(1,1:2:end)*10)/10);
ylabel('dR/R0 BAG')
xlabel('% CO2')
end


