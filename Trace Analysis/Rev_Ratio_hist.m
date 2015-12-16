%stacks the ratios pre and post all reversals:
clearvars -except ImagingData

CC=0;

home=cd;
prerev=NaN(1,1200);
cc=1;
folders=dir('*W*');
ratioAll=[];

for F=1:length(ImagingData)
    
    cherry=medfilt1(ImagingData{F}.cherry,5);
    gcamp=medfilt1(ImagingData{F}.gcamp,5);
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
    ratio=ratioFo;
    ratio(nanIdx)=NaN;
    
    ratioAll=[ratioAll;ratio];
    %reversals:
    RevON=ImagingData{F}.RevFrames30hz(1:2:end);
    RevEND=ImagingData{F}.RevFrames30hz(2:2:end);
    
    if F==14
        p=1;
    end
    
    for rev=1:length(RevON)
        
        if RevON(rev)>900 & RevON(rev)+300<length(ratio)
            
            prerev(cc,:)=ratio(RevON(rev)-899:RevON(rev)+300);
            cc=cc+1;
            % if reversal is too close to start of trace:
        elseif RevON(rev)<900
            
            prerev(cc,:)=NaN(1,1200);
            prerev(cc,RevON(rev)+1:1200)=ratio(1:1200-RevON(rev));
            cc=cc+1;
            %or to end
        elseif RevON(rev)+300>length(ratio)
            prerev(cc,:)=NaN(1,1200);
            missing=length(ratio)-(RevON(rev)+300);
            prerev(cc,1:1200+missing)=ratio(RevON(rev)-899:end);
            cc=cc+1;
        end
        
    end % end reversal loop
    
    
end

% % %% normalize to reversal:
% % %% normalize to reversal:
% prerev_N=NaN(size(prerev));
% for i=1:cc-1
% % prerev_N(i,:)=(prerev(i,:)-prerev(i,899));
% prerev_N(i,:)=100*((prerev(i,:)./nanmean(prerev(i,890:900)))-1);
% end
% prerev=prerev_N;

%% % dC/dT:
% prerev_d=NaN(size(prerev)-1);
% for i=1:cc-1
% prerev_d(i,:)=diff(medfilt1(prerev(i,:),20));
% end
% prerev=prerev_d(:,4:end-3);

prerev_n=prerev;

%% plot:
figure
sem=NaN;
for i=1:length(prerev_n)
    sem(i)=nanstd(prerev_n(:,i))/sqrt(numel(find(~isnan(prerev_n(:,i)))));
    nn(i)=numel(find(~isnan(prerev_n(:,i))));
end


h1=shadedErrorBar2([],nanmedian(prerev_n),sem,'b',0);
hold on
plot([900 900],[min(nanmedian(prerev))-0.2 max(nanmedian(prerev))+0.2],'r')
set(gca,'XTick',[1:100:size(prerev_n,2)])
set(gca,'XTicklabel',round(0:3.33:50))

xlabel('s')
ylabel('dF/F0')

%%%
%% plot mean:
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
ylabel('mean dR/dT BAG')




