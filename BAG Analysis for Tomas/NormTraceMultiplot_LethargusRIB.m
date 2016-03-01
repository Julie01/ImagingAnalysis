%stacks the ratios pre and post all reversals:
clearvars -except ImagingData

close

f1=figure;
CC=1;
numF=14;


for F=1:length(ImagingData)
    
    if isfield(ImagingData{F},'cherryR2_1') %only RIM data
    %-----ratios BAG:-------------
    %(1)
    
    cherry1=medfilt1(ImagingData{F}.cherry1(1:7280),5);
    gcamp1=medfilt1(ImagingData{F}.gcamp1(1:7280),5);
    
    %out of focus correction
    % find very rapid changes in size of cherry area and emove this data:
    areaR1=ImagingData{F}.AreaR1_1;
    areaJumps1=find(diff(medfilt1(areaR1))>80 | diff(medfilt1(areaR1))<-80);
    areaJumps1=vertcat(areaJumps1, find(areaR1>2*nanmedian(areaR1) | areaR1<0.25*nanmedian(areaR1)));
    ni= find(cherry1<(nanmedian(cherry1)-(2.5*nanstd(cherry1))));
    niD= find(cherry1>(nanmedian(cherry1)+(2.5*nanstd(cherry1))));
    ni1=[ni ;niD;areaJumps1];
    cherry1(ni1)=NaN;
    gcamp1(ni1)=NaN;
    
    eq_ratio1=(gcamp1/nanmedian(gcamp1))./(cherry1/nanmedian(cherry1));
    
    cherry2=medfilt1(ImagingData{F}.cherry2(1:7280),5);
    gcamp2=medfilt1(ImagingData{F}.gcamp2(1:7280),5);
    
    %out of focus correction
    % find very rapid changes in size of cherry area and emove this data:
    areaR1=ImagingData{F}.AreaR1_2;
    areaJumps1=find(diff(medfilt1(areaR1))>80 | diff(medfilt1(areaR1))<-80);
    areaJumps1=vertcat(areaJumps1, find(areaR1>2*nanmedian(areaR1) | areaR1<0.25*nanmedian(areaR1)));
    ni= find(cherry2<(nanmedian(cherry2)-(2.5*nanstd(cherry2))));
    niD= find(cherry1>(nanmedian(cherry1)+(2.5*nanstd(cherry1))));
    ni2=[ni;niD; areaJumps1];
    cherry2(ni2)=NaN;
    gcamp2(ni2)=NaN;
    
    eq_ratio2=(gcamp2/nanmedian(gcamp1))./(cherry2/nanmedian(cherry1));
    %     eq_ratio2=(gcamp2./cherry2)*20;
    
    % ----speed:----
    if ~isempty (ImagingData{F}.XY_1)
        thisXY=[ImagingData{F}.XY_1 ;ImagingData{F}.XY_2];
        Xf=medfilt1(thisXY(1:10:end,1),5);
        Yf=medfilt1(thisXY(1:10:end,2),5);
        speed10=NaN(1,length(Xf));
        for ii=1:length(Xf)-1
            speed10(ii)=abs(sqrt(((Xf(ii)-Xf(ii+1)).^2)+((Yf(ii)-Yf(ii+1)).^2)))*3; % traveled path during "distance" intervall
        end
        %interpolate
        warning off
        Xup=interp1(1:length(speed10),speed10,1:1/10.0065:length(speed10));
        speed=Xup./100; %is in pix/sec (pix-->mm=47/64000 = 0.00073)
        %NaN episodes of high stage search & when the neuron is lost
        bi=find(speed>3);
        bi2=find(isnan([eq_ratio1; eq_ratio2]));
        for b=-9:9
            try
                speed(bi+b)=NaN;
            end
        end
        speed(bi2)=NaN;
        speed=medfilt1(speed,15);
        SpeedMatrix(CC,1:14560)=NaN(1,14560);
        SpeedMatrix(CC,1:length(speed))=speed;
        
    end
    
    %-----ratios RIB:-------------
    
    cherry1_2=medfilt1(ImagingData{F}.cherryR2_1(1:7280),5);
    gcamp1_2=medfilt1(ImagingData{F}.gcampR2_1(1:7280),5);
    
    %out of focus correction
    
    cherry1_2(ni1)=NaN;
    gcamp1_2(ni1)=NaN;
    
    eq_ratio1_2=(gcamp1_2/nanmedian(gcamp1_2))./(cherry1_2/nanmedian(cherry1_2));
    
    %(2)
    cherry2_2=medfilt1(ImagingData{F}.cherryR2_2(1:7280),5);
    gcamp2_2=medfilt1(ImagingData{F}.gcampR2_2(1:7280),5);
    
    %out of focus correction
    cherry2_2(ni2)=NaN;
    gcamp2_2(ni2)=NaN;
    
    eq_ratio2_2=(gcamp2_2/nanmedian(gcamp1_2))./(cherry2_2/nanmedian(cherry1_2));
    
    
    
    %plot
    figure(f1);
    
    subtightplot(numF,1,CC,0.02)
    cla
    %(1)BAG
    hold on
    tv=(1:length( eq_ratio1))/30;
    tv2=tv+tv(end);
    p=patch([ 4.5*60 tv2(end)  tv2(end) 4.5*60 ], [-0.1 -0.1 2 2], [1 1 1]);
    set(p,'FaceColor',[0.8 0.9 0.8],'EdgeColor',[0.8 0.9 0.8])
    set(p,'FaceColor',[0.8 0.9 0.8],'EdgeColor',[0.8 0.9 0.8])
    plot ([4.63*60 4.63*60], [0 max( eq_ratio2)/2],'g')
    
    plot(tv, eq_ratio1,'k','linewidth',1.5);
    plot(tv2,eq_ratio2,'k','linewidth',1.5)
    set(gca,'Xgrid','on');
    set(gca,'XTick',1:15:tv2(end))
    set(gca,'XTicklabel','')
    ylim([-0.15 9])
    
    %(2)RIB
    plot(tv, eq_ratio1_2,'color',[0 0.2 1],'linewidth',1.5);
    plot(tv2,eq_ratio2_2,'color',[0 0.2 1],'linewidth',1.5)
    
    %plot speed
    try
            plot([tv tv2], speed*1, 'color' ,[0.2 0.2 0.3]);
    catch
        tv3=[tv tv2];
         plot(tv3(1:length(speed)), speed*1, 'color' ,[0.2 0.2 0.3]);
    end    
    
    if CC==1
        %ylabel('dR/R0')
        ylabel('R')
        title(dirname(cd))
        set(gca,'XTicklabel',0:15:tv2(end))
    elseif  CC==length(ImagingData)
        set(gca,'XTicklabel',0:15:tv2(end))
        ylabel('R')
        xlabel('sec')
    end
    yp=get(gca, 'ylim');
    text(5,yp(2), ImagingData{F}.TrialLabel(2:3),'color', 'b')
    
    CC=CC+1;
    
    end
end

% saveas(gcf,[dirname(cd) '_multiplot'])


