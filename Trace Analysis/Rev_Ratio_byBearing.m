
%stacks the ratios pre and post all reversals:
clearvars -except ImagingData

CC=0;

home=cd;

cc1=1;
cc2=1;

prerevUG=NaN(1,960);
prerevDG=NaN(1,960);

for F=1:length(ImagingData)
    
    ratio=ImagingData{F}.ratioFo;
    
    %reversals:
    RevON=ImagingData{F}.RevFrames30hz(1:2:end);
    RevEND=ImagingData{F}.RevFrames30hz(2:2:end);
    
    if F==14
        p=1;
    end
    
    for rev=1:length(RevEND)
        
        if RevON(rev)>7800
            continue
        end
        
        try
        XY=ImagingData{F}.XY(RevON(rev)-100:RevON(rev)+100,:);
        catch
            XY=ImagingData{F}.XY(RevON(rev)-1:RevON(rev)+100,:);
            XY=[NaN(99,2);XY];
        end
        
        [bearing]=getbearing_freelyMoving_global(XY(:,1),XY(:,2),1,10);
                
        %%%% reversals upgradient:
        if nanmean(bearing(100:end))>95
            
            if RevON(rev)>600 & RevEND(rev)<length(ratio)
                
                prerevUG(cc1,:)=NaN(1,960);
                revratio=ratio(RevON(rev)-599:RevEND(rev));
                prerevUG(cc1,1:length(revratio))=ratio(RevON(rev)-599:RevEND(rev));
                cc1=cc1+1;
                % if reversal is too close to start of trace:
            elseif RevON(rev)<600
                
                prerevUG(cc1,:)=NaN(1,960);
                revratio=ratio(1:RevEND(rev));
               prerevUG(cc1,601-(RevON(rev)):600-(RevON(rev))+length(revratio))=revratio;
                cc1=cc1+1;
                %or to end
            elseif RevON(rev)+600>length(ratio)
                prerevUG(cc1,:)=NaN(1,960);
                missing=length(ratio)-(RevON(rev)+600);
                prerevUG(cc1,1:960+missing)=ratio(RevON(rev)-599:end);
                cc1=cc1+1;
            end
            
            prerevUG=prerevUG(:,1:960);
        
            %%%%%%% reversals downgradient:
        elseif nanmean(bearing(100:end))<85
            
            if RevON(rev)>600 & RevEND(rev)<length(ratio)
                
                prerevDG(cc2,:)=NaN(1,960);
                revratio=ratio(RevON(rev)-599:RevEND(rev));
                prerevDG(cc2,1:length(revratio))=ratio(RevON(rev)-599:RevEND(rev));
                cc2=cc2+1;
                % if reversal is too close to start of trace:
            elseif RevON(rev)<600
                
                prerevDG(cc2,:)=NaN(1,960);
                revratio=ratio(1:RevEND(rev));
               prerevDG(cc2,601-(RevON(rev)):600-(RevON(rev))+length(revratio))=revratio;
                cc2=cc2+1;
                %or to end
            elseif RevON(rev)+600>length(ratio)
                prerevDG(cc2,:)=NaN(1,960);
                missing=length(ratio)-(RevON(rev)+600);
                prerevDG(cc2,1:960+missing)=ratio(RevON(rev)-599:end);
                cc2=cc2+1;
            end
            
        end
        
        prerevDG=prerevDG(:,1:960);
        if cc1==168 
            p=1;
        end
        
    end % end reversal loop
    
    
end

%% plot:
figure
subtightplot(1,2,1)
sem=NaN;
for i=1:length(prerevUG)
    sem(i)=nanstd(prerevUG(:,i))/sqrt(numel(find(~isnan(prerevUG(:,i)))));
    nn(i)=numel(find(~isnan(prerevUG(:,i))));
end
h1(1)=shadedErrorBar2(-20:0.0333334:12,nanmedian(prerevUG),sem,'b',0);
hold on
plot([0 0],[min(nanmedian(prerevUG)-0.2) max(nanmean(prerevUG)+0.2)],'r')
 set(gca,'XTick',[-20:5:12])
% set(gca,'XTicklabel',round(0:3.33:50));
xlabel('s')
ylabel('dF/F0')
title(['up gradient reversals (>95), n=' num2str(cc1)])
 ylim([0 160])
% xlim([-20 12.1])

subtightplot(1,2,2)

sem=NaN;
for i=1:length(prerevDG)
    sem(i)=nanstd(prerevDG(:,i))/sqrt(numel(find(~isnan(prerevDG(:,i)))));
    nn(i)=numel(find(~isnan(prerevDG(:,i))));
end
h1(2)=shadedErrorBar2(-20:0.0333334:12,nanmedian(prerevDG),sem,'b',0);
hold on
plot([0 0],[min(nanmedian(prerevDG)-0.2) max(nanmean(prerevDG)+0.2)],'r')
 set(gca,'XTick',[-20:5:12])
title(['down gradient reversals (<85), n=' num2str(cc2)])
xlabel('s')
ylabel('dF/F0')
 ylim([0 160])
% ylim([-0.6 1.1])
% xlim([-20 12.1])



