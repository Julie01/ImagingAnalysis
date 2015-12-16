%stacks the ratios pre and post all reversals:
clearvars -except ImagingData

CC=0;

home=cd;
prerev=NaN(1,1200);
cc=1;
folders=dir('*W*');

for F=1:length(ImagingData)
    
    ratio=ImagingData{F}.ratioFo;
    
    ratio_cent=ratio-nanmedian(ratio);
    ratio_norm=ratio_cent/rms(ratio_cent);

    %reversals:
    RevON=ImagingData{F}.RevFrames30hz(1:2:end);
    RevEND=ImagingData{F}.RevFrames30hz(2:2:end);

    if F==14
        p=1;
    end
    
    for rev=1:length(RevON)
        
        if RevON(rev)>900 & RevON(rev)+300<length(ratio_norm)
            
            prerev(cc,:)=ratio_norm(RevON(rev)-899:RevON(rev)+300);
            cc=cc+1;
            % if reversal is too close to start of trace:
        elseif RevON(rev)<900
            
            prerev(cc,:)=NaN(1,1200);
            prerev(cc,RevON(rev)+1:1200)=ratio_norm(1:1200-RevON(rev));
            cc=cc+1;
            %or to end
        elseif RevON(rev)+300>length(ratio_norm)
            prerev(cc,:)=NaN(1,1200);
            missing=length(ratio_norm)-(RevON(rev)+300);
            prerev(cc,1:1200+missing)=ratio_norm(RevON(rev)-899:end);
            cc=cc+1;
        end
        
    end % end reversal loop
    
    
end

%% normalize to reversal:
 prerev_n=NaN(size(prerev));
for  i=1:cc-1   
 prerev_n(i,:)=(prerev(i,:)./prerev(i,899));
end
%    prerev_n=prerev; 
%% plot:
figure
sem=NaN;
tv=(1:size(prerev,2))/30;
tv=round(tv*100)/100;
for i=1:length(prerev_n)
    sem(i)=nanstd(prerev_n(:,i))/sqrt(numel(find(~isnan(prerev_n(:,i)))));
    nn(i)=numel(find(~isnan(prerev_n(:,i))));
end
h1=shadedErrorBar2(tv,nanmean(prerev_n),sem,'b',0);
hold on
plot([30 30],[min(nanmean(prerev_n)-0.2) max(nanmean(prerev_n)+0.2)],'r')
% set(gca,'XTick',[1:100:size(prerev_n,2)])
% set(gca,'XTicklabel',round(0:3.33:50))
%%
xlabel('time(s)')
ylabel('dF/F0 norm')



