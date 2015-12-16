%stacks the ratios pre and post all reversals:
home=cd;
folders=dir('*W*');

prerand_n=NaN(1,900);
minR=NaN;
cc=1;

for F=[1 2 4 5 ]
    
    cd(folders(F).name)
    
    behavfiles=dir('*behav*');
    logfiles=dir('*R1*log*');
    L=[length(logfiles) length(behavfiles)];
    
    
    for LN =1:min(L)
        
        disp(logfiles(LN).name)
        load(logfiles(LN).name)
        load (behavfiles(LN).name)
        
        ratio=(thiswormdata(:,1)./thiswormdata(:,2));
        ratioF=JuliaPolyfitX(ratio,6);
        ratioF(1:6)=ratio(1:6);
        ratioF(end-6:end)=ratio(end-6:end);
        bi=find(ratioF>1.8 | ratioF<0.02);
        ratioF(bi)=NaN;
        minR(LN)=min(ratioF);
        normRatio=ratioF/min(ratioF);
        
        if max(normRatio)>10
            normRatio=ratioF/(nanmean(ratioF)-(2*nanstd(ratioF)));
        end
        
        r_rand=sort(randsample([1:length(normRatio)],length(r_onset)));
        
        for rev=1:length(r_rand)
            
            if r_rand(rev)>600 & r_rand(rev)+300<length(normRatio)
                
                prerand_n(cc,:)=normRatio(r_rand(rev)-599:r_rand(rev)+300);
                cc=cc+1;
                % if reversal is too close to start of trace:
            elseif r_rand(rev)<600
                
                prerand_n(cc,:)=NaN(1,900);
                prerand_n(cc,r_rand(rev)+1:900)=normRatio(1:900-r_rand(rev));
                cc=cc+1;
                %or to end
            elseif r_rand+300>length(normRatio)
                prerand_n(cc,:)=NaN(1,900);
                missing=abs(length(normRatio)-(r_rand(rev)+300));
                prerand_n(cc,1:900-missing)=normRatio(r_rand(rev)-599:900-end);
                cc=cc+1;
            end
            
        end % end reversal loop
        
    end
    
    cd(home)
    
end % end folder loop

%% plot
figure
sem=NaN;
for i=1:length(prerand_n)
sem(i)=nanstd(prerand_n(:,i))/sqrt(numel(find(~isnan(prerand_n(:,i)))));
nn(i)=numel(find(~isnan(prerand_n(:,i))));
end
shadedErrorBar2([],nanmean(prerand_n),sem,'b',0);
hold on
plot([600 600],[min(nanmean(prerand_n)-0.2) max(nanmean(prerand_n)+0.2)],'r')
set(gca,'XTicklabel',0:3.3334:30)
 ylim([1.2 3.1])
 
nd=(cd);
d= strfind(cd, '\');
name=nd(d(end)+1:(end));
title(name)



