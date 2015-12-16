%stacks the ratios pre and post all reversals:
clearvars -except ImagingData

CC=0;
figure

for F=1:length(ImagingData)
    
prerev=NaN(1,1200);
cc=1;
    
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
    
    subtightplot(6,6,F)
    errorplot(prerev,1,0);
    set(gca,'XTicklabel','')
    title(F)
     
end

