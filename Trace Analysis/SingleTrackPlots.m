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
%main figure
scr=get(0,'screensize');
f1=figure('Position',[scr(3)/2.7 scr(2)+49 scr(3)*0.6 scr(4)*0.85]);


for F=1:length(ImagingData)
    
    %ratio:
    cherry=medfilt1(ImagingData{F}.cherry,5);
    gcamp=medfilt1(ImagingData{F}.gcamp,5);
    nanIdx=find(isnan(cherry));
    eq_ratio=(gcamp/nanmean(gcamp))./(cherry/nanmean(cherry));
    eq_ratio_cent=eq_ratio-nanmedian(eq_ratio);
    eq_ratio_norm=smoothn(eq_ratio_cent/nanstd(eq_ratio_cent),10);
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
    
    %CO2
    sensIn=ImagingData{F}.CO2;
    nanIdx=find(isnan(sensIn));
    SensNorm=sensIn-nanmedian(sensIn);
    SensNorm=smoothn(SensNorm./nanstd(SensNorm),10);
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
    
    %% plots:
    
%     XY:
    subtightplot(6,1,[1 2],0.045, 0.06)
    cla
    scatter(ImagingData{F}.XY(:,1),ImagingData{F}.XY(:,2),10,sensIn,'filled')
    caxis([min(sensIn)-0.1 max(sensIn)+0.1])
    cb=colorbar('Position',[0.95 0.69 0.015 0.25]);
    hold on
    try
    scatter(ImagingData{F}.XY(RevON,1),ImagingData{F}.XY(RevON,2),'hr')
    scatter(ImagingData{F}.XY(RevEND,1),ImagingData{F}.XY(RevEND,2),'pb')
    end
    for i=500:500:length(sensIn)
        scatter(ImagingData{F}.XY(i,1),ImagingData{F}.XY(i,2),'k')
        text(ImagingData{F}.XY(i,1),ImagingData{F}.XY(i,2),num2str(i),'FontSize',5)
    end
    title(ImagingData{F}.TrialLabel);
    axis equal
    
    %%
    subtightplot(6,1,3,0.045,0.045)
    cla
    hold on
    for i=1:length(RevON)-1
        p=patch([ RevON(i) RevEND(i)  RevEND(i) RevON(i) ], [-1 -1 1 1], [1 1 1]);
        set(p,'FaceColor',[0.9 0.8 0.8],'EdgeColor',[0.9 0.8 0.8])
    end
    plot(SensNorm,'k')
    plot(eq_ratio_norm,'color',[0.9 0.2 0.5])
    set(gca,'Xgrid','on');
    
    subtightplot(6,1,4,0.045,0.05)
    plot(sensIn)
    ylim([1 3])
    xlim([1 8000])
    
    subtightplot(6,1,5,0.045,0.05)
    cla
    plot(cherry,'r')
    hold on
    plot(gcamp,'g')
    
    subtightplot(6,1,6,0.045,0.06)
    cla
    hold on
    for i=1:length(RevON)-1
        p=patch([ RevON(i) RevEND(i)  RevEND(i) RevON(i) ], [-0.01 -0.01 0.01 0.01], [1 1 1]);
        set(p,'FaceColor',[0.9 0.8 0.8],'EdgeColor',[0.9 0.8 0.8])
    end
    plot(diff(medfilt1(eq_ratio,20)),'m')
    hold on
    plot(diff(medfilt1(sensIn,20))*5,'k')
    ylim([-0.05 0.05])
    
    
    %save:
    np=num2str(CC);
    if CC<10
        np= [num2str(0) num2str(CC)];
    end
    try
    cd('SingleTrackPlots')
    end
    disp(ImagingData{F}.TrialLabel)
    saveas(gcf,[np '_ST_' ImagingData{F}.TrialLabel])
    
    
    CC=CC+1;
pause(0.5)

end

cd ..\


