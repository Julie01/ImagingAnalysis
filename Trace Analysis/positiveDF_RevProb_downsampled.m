%stacks the ratios pre and post all reversals: 30x downsampled
clearvars -except ImagingData

CC=0;

home=cd;
prerev=NaN(1,1200);
cc=1;
positiveDF=NaN(length(ImagingData),40);
revAll=[];
posVAll=[];
posTAll=[];
diffAll=[];

norm=0;

for F=1:length(ImagingData)
    
    ratio=ImagingData{F}.ratioFo;
   if norm==1
    ratio_cent=ratio-nanmedian(ratio);
    ratio_norm=ratio_cent/rms(ratio_cent);
    else
    ratio_norm=ratio;
   end
    ratio_norm=medfilt1(ratio_norm,30);
    ratio_norm=smoothn(ratio_norm,30);
    
    
    %filter above undulation frequency:   
    fDF=smoothn( ratio_norm(1:30:end),1);
    diffDF=(fDF(10:end)-fDF(1:end-9))';
    diffDF=[NaN(1,9) diffDF];
    diffAll=[diffAll,diffDF];
    
        %reversals:
    RevON=ImagingData{F}.RevFrames30hz(1:2:end);
    RevEND=ImagingData{F}.RevFrames30hz(2:2:end);
    Revs=zeros(1,length(diffDF));
    Revs(ceil(RevON/30))=1;
    Revs=Revs(1:length(diffDF));
    revAll=[revAll,Revs];

    
    %find episodes of constant rise
    %(1) derivative
    md=NaN;
    pV=zeros(1,length(diffDF));
    
    c=1;
    for i=1:2:length(diffDF)-5
        
        md(c)=mean(diffDF(i:i+5));
        
        if md(c)>0.1
            pV(i:i+5)=1;
        end
        
        c=c+1;
        
    end
    
    %find end and startpoints of positive DF episodes:
    si=find(diff(pV)==1);
    ei=find(diff(pV)==-1);
    %cumsum of time or dF for thiese episodes:
    %     pVcs=NaN(1,length(diffDF));
    pVcs=NaN(1,length(fDF));
    pTcs=NaN(1,length(diffDF));
    for i=1:length(ei)
        pVcs(si(i):ei(i))=cumsum(fDF(si(i):ei(i)));
        pTcs(si(i):ei(i))=cumsum(ones(1,length((si(i):ei(i)))));
    end
    
    posVAll=[posVAll,pVcs];
    posTAll=[posTAll,pTcs];
    

end % end exp loop

%% bin& frequency %%%%

C=1;
bintype=2;

figure
if bintype==1 & norm==1
    first=-15;
    last=66;
    binsize=0.5;
    
elseif bintype==1 & norm~=1
    first=-400;
    last=8000;
    binsize=10;
else
    first=1;
    last=82;
    binsize=1;
end

for delay =0
    mR=NaN;
    mP=NaN;
    revN=NaN;
    revNnorm=NaN;
    
    cc=1;
    
    for i=first :binsize:(last-binsize)
        
        if bintype==1
            bin_idx= find(posVAll>i & posVAll<=i+binsize);
        else
            bin_idx= find(posTAll>i & posTAll<=i+binsize);
        end
        
        if ~isempty(bin_idx)
            
            if bintype==1
                binPos=posVAll(bin_idx); %mean cumsum dF/F0
            else
                binPos=posTAll(bin_idx);  %mean cumsum time
                 binR=diffAll(bin_idx);
            end
            revV=revAll(bin_idx+delay);
            
%             mR(cc)=nanmean(binR);
            mP(cc)=nanmean(binPos);
            revN(cc)=nansum(revV);
            revNnorm(cc)=nansum(revV)/length(bin_idx);
        end
        
        cc=cc+1;
        
    end
    
    % plot:
    
    plot(revNnorm)
    
    if bintype==1 & norm==1
        set(gca,'XTick',[1:cc/15:length(mP)])
        set(gca,'XTickLabel',round(mP(1:cc/15:end)*10)/10);
        xlabel('cumsum positive dF norm ')
        
    elseif bintype==1 & norm~=1
        set(gca,'XTick',[1:cc/25:length(mP)])
        set(gca,'XTickLabel',round(mP(1:cc/25:end)*1)/1);
        xlabel('cumsum positive dF ')
    else
        set(gca,'XTick',[1:3:length(mP)])
        set(gca,'XTickLabel',round(mP(1:3:end)*1)/1);
        xlabel('cumsum time(s)')
    end

         ylabel('reversal frequency')


 ylim([0 1])
xlim([0 cc-1])

if norm==1;
    title('normalized dF/F0')
else
    title('dF/F0')
end

C=C+1;
end





