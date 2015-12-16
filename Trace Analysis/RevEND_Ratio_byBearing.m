
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
        
        if RevEND(rev)>7890 |RevEND(rev)<101
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
            
            if RevEND(rev)>500 & RevEND(rev)<length(ratio)-100
                
                prerevUG(cc1,:)=NaN(1,960);
                revratio=ratio(RevEND(rev)-499:RevEND(rev)+100);
                prerevUG(cc1,1:length(revratio))=ratio(RevEND(rev)-499:RevEND(rev)+100);
                cc1=cc1+1;
                % if reversal is too close to start of trace:
            elseif RevEND(rev)<500
                
                prerevUG(cc1,:)=NaN(1,960);
                revratio=ratio(1:RevEND(rev)+100);
               prerevUG(cc1,501-(RevEND(rev)):500-(RevEND(rev))+length(revratio))=revratio;
                cc1=cc1+1;
                %or to end
            elseif RevEND(rev)+500>length(ratio)
                try
                prerevUG(cc1,:)=NaN(1,960);
                missing=length(ratio)-(RevEND(rev)+500);
                prerevUG(cc1,1:960+missing)=ratio(RevEND(rev)-499:end);
                end
                cc1=cc1+1;
            end
            
            prerevUG=prerevUG(:,1:960);
        
            %%%%%%% reversals downgradient:
       elseif nanmean(bearing(100:end))<85
            
            if RevEND(rev)>500 & RevEND(rev)<length(ratio)-100
                
                prerevDG(cc2,:)=NaN(1,960);
                revratio=ratio(RevEND(rev)-499:RevEND(rev)+100);
                prerevDG(cc2,1:length(revratio))=ratio(RevEND(rev)-499:RevEND(rev)+100);
                cc2=cc2+1;
                % if reversal is too close to start of trace:
            elseif RevEND(rev)<500
                
                prerevDG(cc2,:)=NaN(1,960);
                revratio=ratio(1:RevEND(rev)+100);
               prerevDG(cc2,501-(RevEND(rev)):500-(RevEND(rev))+length(revratio))=revratio;
                cc2=cc2+1;
                %or to end
            elseif RevEND(rev)+500>length(ratio)
                prerevDG(cc2,:)=NaN(1,960);
                try
                missing=length(ratio)-(RevEND(rev)+500);
                prerevDG(cc2,1:960+missing)=ratio(RevEND(rev)-499:end);
                end
                cc2=cc2+1;
            end
            
        end
        
        prerevDG=prerevDG(:,1:960);
        
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
h1(1)=shadedErrorBar2(-17:0.0333334:15,nanmean(prerevUG),sem,'b',0);
hold on
plot([0 0],[min(nanmean(prerevUG)-0.2) max(nanmean(prerevUG)+0.2)],'r')
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
h1(2)=shadedErrorBar2(-17:0.0333334:15,nanmean(prerevDG),sem,'b',0);
hold on
plot([0 0],[min(nanmean(prerevDG)-0.2) max(nanmean(prerevDG)+0.2)],'r')
 set(gca,'XTick',[-20:5:12])
title(['down gradient reversals (<85), n=' num2str(cc2)])
xlabel('s')
ylabel('dF/F0')
 ylim([0 160])
% ylim([-0.6 1.1])
% xlim([-20 12.1])



