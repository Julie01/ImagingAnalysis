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
cc2=1;
positiveDF=NaN(length(ImagingData),40);
ratioAll=[];
revAll=[];
bearingAll=[];
bearingGlobAll=[];
rNorth=NaN(length(ImagingData),40);
rSouth=NaN(length(ImagingData),40);
warning off
f1=figure;
f2=figure;
xcfSouth=NaN(1,61);
xcfNorth=NaN(1,61);
bounds=NaN(2,1);
lag=30;

for F=1:length(ImagingData)
    
    %ratio:
    cherry=medfilt1(ImagingData{F}.cherry,5);
    gcamp=medfilt1(ImagingData{F}.gcamp,5);
    eq_ratio=(gcamp/nanmean(gcamp))./(cherry/nanmean(cherry));
    eq_ratio_cent=eq_ratio-nanmedian(eq_ratio);
    eq_ratio_norm=eq_ratio_cent/nanstd(eq_ratio_cent);
    
    %CO2
    sensIn=ImagingData{F}.CO2;
    SensNorm=sensIn-nanmedian(sensIn);
    SensNorm=SensNorm./nanstd(SensNorm);
    
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
    bearingGlob(ri)=NaN;
    eq_ratio_norm(ri)=NaN;
    
    %adjust vector length:
    bearingGlob=bearingGlob(1:length(eq_ratio_norm));
    %     bearingGlobAll=[bearingGlobAll;bearingGlob];
    
    %% only sections which are ca perpendicular to gradient
    
    %%%down:
    
    bi=find(bearingGlob>135 | bearingGlob<55);
    bi2= find(bearingY<90);
    bi=[bi; bi2];
    bi(find(bi>length(eq_ratio_norm)))=[];
    ppr=eq_ratio_norm;
    ppr(bi)=NaN;
    ppSens=SensNorm;
    ppSens(bi)=NaN;
    
    
    %detrend:
    [s e]=nanedge(ppr); %find non-nan episodes and detrend each
    pprD=[];
    ppSensD=[];
    for i=1:length(e)-1
        pprDsub=detrend(ppr(e(i)+1:s(i+1)));
        ppSensDsub=detrend(ppSens(e(i)+1:s(i+1)));
        pprD=[pprD ;pprDsub];
        ppSensD=[ppSensD ;ppSensDsub'];
    end
    
    rSouth(F)= nancorr(ppSensD,pprD);

    %crosscorrelation
    if isempty(find(isnan(ppSensD), 1)) & isempty(find(isnan(pprD), 1))...
            & ~isempty(ppSensD)& length(pprD)>30
        
        [xcfSouth(cc,1:61),lags,bounds(:,cc)]=crosscorr(ppSensD,pprD,lag);
        cc=cc+1;
    else
        disp('NaNs')
        xcf(cc,1:31)=NaN;
        bounds(:,cc)=NaN;
        cc=cc+1;
        
    end
    
    
    %plot
    figure(f1);
    subtightplot(2,1,1)
    cla
    hold on
    plot(pprD,'color',[0.9 0 1])
    plot(ppSensD*2,'k')
    set(gca,'Xgrid','on');       
    title(ImagingData{F}.TrialLabel)
    
    
    
    %%%UP:
    bi=find(bearingGlob>135 | bearingGlob<55);
    bi2= find(bearingY>=90);
    bi=[bi; bi2];
    bi(find(bi>length(eq_ratio_norm)))=[];
    ppSens=SensNorm;
    ppSens(bi)=NaN;
    ppr=eq_ratio_norm;
    ppr(bi)=NaN;
    

    %detrend:
    [s e]=nanedge(ppr); %find non-nan episodes and detrend each
    pprD=[];
    ppSensD=[];
    for i=1:length(e)-1
        pprDsub=detrend(ppr(e(i)+1:s(i+1)));
        ppSensDsub=detrend(ppSens(e(i)+1:s(i+1)));
        pprD=[pprD ;pprDsub];
        ppSensD=[ppSensD ;ppSensDsub'];
    end
    
    rNorth(F)= nancorr(ppSensD,pprD);
    
    %crosscorrelation
    if isempty(find(isnan(ppSensD), 1)) & isempty(find(isnan(pprD), 1))...
            & ~isempty(ppSensD)& length(pprD)>30
        
        [xcfNorth(cc2,1:61),lags,bounds(:,cc2)]=crosscorr(ppSensD,pprD,lag);
        cc2=cc2+1;
    else
        disp('NaNs')
        xcf(cc2,1:31)=NaN;
        bounds(:,cc2)=NaN;
        cc2=cc2+1;
        
    end
    
    %plot
    subtightplot(2,1,2)
    cla
    hold on
        plot(pprD,'r')
        plot(ppSensD*2,'k')
%     S1=smoothn(ppSensD,10);
%     S2=smoothn(pprD,10);
%     plot(S1,'k');
%     plot(S2,'r');
    set(gca,'Xgrid','on');
    
    np=num2str(CC);
    if CC<10
        np= [num2str(0) num2str(CC)];
    end
%     cd('Head Sampling Plots')
%   disp(ImagingData{F}.TrialLabel)
%   %saveas(gcf,[np '_' ImagingData{F}.TrialLabel '_detrended'])
%   
%   cd ..\
   CC=CC+1; 

end

%% plot:
figure
subtightplot(1,3,1,0.1)
imagesc(rSouth)
caxis([-0.9 0.9])
title('S')

subtightplot(1,3,2,0.1)
imagesc(rNorth)
caxis([-0.9 0.9])
colorbar
title('N')
subtightplot(1,3,3,0.1)
rVal(:,1)=(nanmean(rSouth,2));
rVal(:,2)=nanmean(rNorth,2);
boxplot(rVal,'labels',{'south','north'})

%crosscorrelation
figure
subtightplot(2,1,1)
title('down')
hold on
shadedErrorBar2([-30:30],nanmean(xcfSouth),nanstd(xcfSouth)./sqrt(cc),{'-','Color','b'},0)
plot([0 0],[min(nanmean(xcfSouth)) max(nanmean(xcfSouth)) ],'--k')

subtightplot(2,1,2)
title('up')
hold on
shadedErrorBar2([-30:30],nanmean(xcfNorth),nanstd(xcfNorth)./sqrt(cc),{'-','Color','r'},0)

plot([0 0],[min(nanmean(xcfNorth)) max(nanmean(xcfNorth)) ],'--k')
