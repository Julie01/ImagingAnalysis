
CC=1;
mf=figure('Position',[10 90 900 800]);
load CaDataConcat
warning off

for F=1:4
    
    clearvars -except F CC mf outputTrace inputTrace trialLabel XYTrace
    %parameters
    fps=30;
    numTrials=length(inputTrace);
    steps=5;
    winsize=600*F;
    xf=10/F;
    winsize=winsize-1;
    %initialize
    rValues=NaN(numTrials,round((15000-winsize)/ceil(winsize/steps))-1);
    mean_speed=NaN(numTrials,round((15000-winsize)/ceil(winsize/steps))-1);
    mean_CO2=NaN(numTrials,round((15000-winsize)/ceil(winsize/steps))-1);
    mean_diffCO2=NaN(numTrials,round((15000-winsize)/ceil(winsize/steps))-1);
    mean_globalbearing=rValues;
    mean_localbearing=rValues;
     
    nc=5;
    nr=ceil(numTrials/nc);
    
    
    for i=1:numTrials
        
        if i==10 %omit files
            continue
        end
        
        goodFrames=1:min([length(inputTrace{i}) length(outputTrace{i}) ]);
        thisInputTrace=medfilt1(inputTrace{i}(goodFrames));
        thisOutputTrace=medfilt1(outputTrace{i}(goodFrames));
        NanIdx=isnan(thisOutputTrace);
        thisXY=NaN(2,16000);
        thisXY(:,1:length(XYTrace{i}))=XYTrace{i};
        thisXY=(thisXY(:,goodFrames));
        thisLabel=trialLabel{i};
        
        
        % speed:
        X=medfilt1(thisXY(1,1:10:end));
        Y=medfilt1(thisXY(2,1:10:end));
        speed10=NaN(1,length(X));
        for ii=1:length(X)-1
            speed10(ii)=abs(sqrt(((X(ii)-X(ii+1)).^2)+((Y(ii)-Y(ii+1)).^2)))*3; % traveled path during "distance" intervall
        end
        %interpolate
        %         Y=nansum(mHM1);
        Xup=interp1(1:length(speed10),speed10,1:1/10:length(speed10));
        speed=Xup./100;
        speed(speed>1.5)=NaN;
        
        %heading:
        [ heading, localbearing, dBearing1, curvature, hx,hy]= getbearing_freelyMoving_fast(thisXY(1,:),thisXY(2,:),0.1,20);
        [ heading, globalbearing, dBearing1, curvature, smX,smY]= getbearing_freelyMoving_fast(X,Y,0.1,20);
        
        globalBearingUps=interp1(1:length(globalbearing),globalbearing,1:1/10:length(globalbearing));
        
        %NaN all variables:
        thisInputTrace(NanIdx)=NaN;
        speed(NanIdx)=NaN;
        localbearing(NanIdx)=NaN;
        globalbearing(NanIdx)=NaN;
        
        %%%%%%%%%%
        if thisLabel(end-1:end)=='T2' | thisLabel(end-1:end)=='T1'
            %    if thisLabel(end-1:end)=='T1'
            
            cc=1;
            for W=1:winsize/steps:length(speed)-winsize
                W=floor(W);
                winin=thisInputTrace(W:W+winsize);
                winout=thisOutputTrace(W:W+winsize);
                
                winInputTrace_cent=winin-nanmean(winin);
                winOutputTrace_cent=winout-nanmean(winout);
                
                winInputTrace_norm=winInputTrace_cent/rms(winInputTrace_cent);
                winOutputTrace_norm=winOutputTrace_cent/rms(winOutputTrace_cent);
                
                win_globalbearing= globalBearingUps(W:W+winsize);
                 win_localbearing= localbearing(W:W+winsize);
                
                %correlate current window
                rValues(i,cc)=nancorr(winInputTrace_norm,winOutputTrace_norm);
                
                mean_speed(i,cc)= nanmean(speed(W:W+winsize));
                
                mean_CO2(i,cc)=nanmean(winin);
                
                diffCO2=diff(winin);
                diffCO2(diffCO2>0.05| diffCO2<-0.05)=NaN;
                mean_diffCO2(i,cc)=nanmean(diffCO2);
                
                mean_globalbearing(i,cc)=nanmean(win_globalbearing);
                mean_localbearing(i,cc)=nanmean(win_localbearing);
                
                xt(cc)=W;
                cc=cc+1;
                
            end
            
        end
        
    end % end exp loop
    
    %%
    
    figure(mf)
    subtightplot(2,2,CC,[0.07,0.03])
    plot(nanmean(mean_CO2),'r')
    hold on
    plot(nanmean(mean_speed),'g')
    plot(nanmean(mean_diffCO2)*1000,'m')
    plot(nanmean( mean_globalbearing)/100,'b')
    plot(nanmean( mean_localbearing)/100,'color',[0.1 0.1 0.3])
    
    plot(1:length(mean_speed),zeros(1,length(mean_speed)),'--','color', [0.5 0.5 0.5])
    plot(nanmean(rValues), 'linewidth',2,'color','k')
    title(['window size=' num2str(winsize) '   max r=' num2str(max(nanmean(round(rValues*100))/100)) ])
    set(gca,'XTick', 1:xf:size(rValues,2))
    set(gca,'XTickLabel',xt(1:xf:end));
    
    speedcorr=nancorr(nanmean(rValues),nanmean(mean_speed));
    CO2corr=nancorr(nanmean(rValues),nanmean(mean_CO2));
    diffCO2corr=nancorr(nanmean(rValues),nanmean(mean_diffCO2));
    bearingcorr=nancorr(nanmean(rValues),nanmean(mean_globalbearing));
    loc_bearingcorr=nancorr(nanmean(rValues),nanmean(mean_localbearing));
    
    legend(['mean CO2 r= ' num2str(speedcorr)],['mean speed r= ' num2str(CO2corr)],...
        ['mean diffCO2 r= ' num2str(diffCO2corr)],['global bearing r= ' num2str(bearingcorr)],['local bearing r= ' num2str(loc_bearingcorr)])
    
    
    CC=CC+1;
end

xlabel('start frame')

