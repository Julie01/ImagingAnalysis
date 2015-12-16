%stacks the ratios pre and post all reversals:
clearvars -except ImagingData

CC=0;

home=cd;
prerev=NaN(1,1200);
cc=1;
folders=dir('*W*');

for F=1:length(ImagingData)
    
    if isfield(ImagingData{F}, 'cherry_AFD')==1
cherry=medfilt1(ImagingData{F}.cherry_AFD,5);
    gcamp=medfilt1(ImagingData{F}.gcamp_AFD,5);
    nanIdx=find(isnan(cherry));
    eq_ratio=(gcamp/nanmean(gcamp))./(cherry/nanmean(cherry));
    %dR/R0:
    sd=nanstd(eq_ratio);
    mr=nanmean(eq_ratio);
    F0=mr-(1.5*sd);
    if F0<min(eq_ratio)
        F0=min(eq_ratio);
    end
    ratioFo=100*((eq_ratio/F0)-1);
    ratioAFD=ratioFo;
    ratioAFD(nanIdx)=NaN;
    
    
    %reversals:
    RevON=ImagingData{F}.RevFrames30hz(1:2:end);
    RevEND=ImagingData{F}.RevFrames30hz(2:2:end);
    
    if F==14
        p=1;
    end
    
    for rev=1:length(RevON)
        
        if RevON(rev)>900 & RevON(rev)+300<length(ratioAFD)
            
            prerev(cc,:)=ratioAFD(RevON(rev)-899:RevON(rev)+300);
            cc=cc+1;
            % if reversal is too close to start of trace:
        elseif RevON(rev)<900
            
            prerev(cc,:)=NaN(1,1200);
            prerev(cc,RevON(rev)+1:1200)=ratioAFD(1:1200-RevON(rev));
            cc=cc+1;
            %or to end
        elseif RevON(rev)+300>length(ratioAFD)
            prerev(cc,:)=NaN(1,1200);
            missing=length(ratioAFD)-(RevON(rev)+300);
            prerev(cc,1:1200+missing)=ratioAFD(RevON(rev)-899:end);
            cc=cc+1;
        end
        
    end % end reversal loop
 
    end
    
end

%% % dC/dT:
% prerev_d=NaN(size(prerev)-1);
% for i=1:cc-1
% prerev_d(i,:)=diff(medfilt1(prerev(i,:),20));
% end
% prerev_d(prerev_d>20 |prerev_d<-20)=NaN;
% prerev=prerev_d(:,4:end-3);

prerev_n=prerev;

%% plot:
figure
sem=NaN;
for i=1:length(prerev_n)
    sem(i)=nanstd(prerev_n(:,i))/sqrt(numel(find(~isnan(prerev_n(:,i)))));
    nn(i)=numel(find(~isnan(prerev_n(:,i))));
end
h1=shadedErrorBar2([],nanmean(prerev_n),sem,'b',0);
hold on
plot([900 900],[min(nanmean(prerev_n)-0.002) max(nanmean(prerev_n)+0.002)],'r')
set(gca,'XTick',[1:100:size(prerev_n,2)])
set(gca,'XTicklabel',round(0:3.33:50))

xlabel('s')
ylabel('ratioAFD')



