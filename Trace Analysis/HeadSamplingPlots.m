%stacks the ratios pre and post all reversals:
clearvars -except ImagingData


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
figure

for F=1:length(ImagingData)
    
    %     %ratio:
    ratio=ImagingData{F}.ratioFo;
    ratio_cent=ratio-nanmedian(ratio);
    ratio_norm=ratio_cent/rms(ratio_cent);
    ratio_norm=medfilt1(ratio_norm,5);
    ratio_norm=smoothn(ratio_norm,10);
    % %     ratioAll=[ratioAll; ratio_norm];
    cherry=medfilt1(ImagingData{F}.cherry,5);
    gcamp=medfilt1(ImagingData{F}.gcamp,5);
    eq_ratio=(gcamp/nanmean(gcamp))./(cherry/nanmean(cherry));
    eq_ratio_cent=eq_ratio-nanmedian(eq_ratio);
    eq_ratio_norm=eq_ratio_cent/nanstd(eq_ratio_cent);
    sensIn=ImagingData{F}.CO2;
    
    %reversals:
    RevON=ImagingData{F}.RevFrames30hz(1:2:end);
    RevEND=ImagingData{F}.RevFrames30hz(2:2:end);
    Revs=zeros(length(eq_ratio),1);
    for i=1:length(RevEND)
        Revs(RevON(i)+5:RevEND(i)-5,1)=1;
    end
    Revs=Revs(1:length(eq_ratio));
    %     revAll=[revAll;Revs];
    ri=find(Revs==1);
    
    
    % bearing:
    XY=ImagingData{F}.XY;
    [bearing]=getbearing_freelyMoving_global(XY(:,1),XY(:,2),1,6);
    [bearingGlob smX smY]=getbearing_freelyMoving_global(XY(:,1),XY(:,2),1,58);
    [bearingY]=getbearing_Y_global(XY(:,1),XY(:,2),1,58);
    bearing=[bearing ; NaN(length(eq_ratio)-length(bearing),1)];
    bearingY=[bearingY ; NaN(length(eq_ratio)-length(bearingY),1)];
    bearingGlob=[bearingGlob ; NaN(length(eq_ratio)-length(bearingGlob),1)];
    
    %remove reversal episodes:
    bearing(ri)=NaN;
    bearingGlob(ri)=NaN;
    eq_ratio_norm(ri)=NaN;
    ratio_norm(ri)=NaN;
    
    %adjust vector length:
    bearing=bearing(1:length(eq_ratio));
    bearingGlob=bearingGlob(1:length(eq_ratio));
    bearingAll=[bearingAll;bearing];
    %     bearingGlobAll=[bearingGlobAll;bearingGlob];
    
    %% only sections which are ca perpendicular to gradient
    %%% DOWN:
    bi=find(bearingGlob>135 | bearingGlob<55);
    bi2= find(bearingY<90);
    bi=[bi; bi2];
    bi(find(bi>length(eq_ratio)))=[];
    ppb=bearing;
    ppb(bi)=NaN;
    ppr=eq_ratio_norm;
    ppr(bi)=NaN;
    pprn=ratio_norm;
    pprn(bi)=NaN;
    ppSens=sensIn;
    SensN=ppSens-nanmedian(ppSens);
    SensN=SensN./nanstd(SensN);
    
    %     %%%detrend:
    %     pprN=ppr(find(~isnan(ppr)));
    %     ppb=ppb(find(~isnan(ppr)));
    %     ppb(find(isnan(ppb)))=90;
    %     pprD=detrend(pprN);
    %     ppbD=detrend(ppb);
    
    
    %plot down headed

% subtightplot(4,1,CC)
    cla
    hold on
    h(4)=plot(eq_ratio_norm,'color',[0.6 0.6 0.9]);
    plot(ratio_norm,'color',[0.6 0.6 0.6]);    
    h(1)=plot(ppr*1.2,'color',[0.9 0 1]);
    plot(sensIn,'b');
    h(3)=plot(SensN,'k');
    
    set(gca,'Xgrid','on');


    %up:
    bi=find(bearingGlob>135 | bearingGlob<55);
    bi2= find(bearingY>=90);
    bi=[bi; bi2];
    bi(find(bi>length(eq_ratio)))=[];
    ppb=bearing;
    ppb(bi)=NaN;
    ppr=eq_ratio_norm;
    ppr(bi)=NaN;
    ppSens(bi)=NaN;
    pprn=ratio_norm;
    pprn(bi)=NaN;
    
    
    %     %detrend:
    %     pprN=ppr(find(~isnan(ppr)));
    %     ppb=ppb(find(~isnan(ppr)));
    %     ppb(find(isnan(ppb)))=90;
    %     pprD=detrend(pprN);
    %     ppbD=detrend(ppb);
    
    
    %plot up headed
    hold on
    h(2)=plot(ppr*1.2,'color',[1 0 0.0]);


    
    set(gca,'Xgrid','on');
    if F>0
    legend(h(1:3),'down','up','% normalized CO2');
    end
    
%     if CC>1
%         set(gca,'xticklabel','')
% %         set(gca,'yticklabel','')
%     end

   
    title(ImagingData{F}.TrialLabel)
    ylim([-5 5])
    xlim([1 8000])
    
  np=num2str(CC);
  if CC<10
      np= [num2str(0) num2str(CC)];
  end
  cd('Head Sampling Plots')
  disp(ImagingData{F}.TrialLabel)
  saveas(gcf,[np '_' ImagingData{F}.TrialLabel])
  
  cd ..\
  
    CC=CC+1;  
    
end

