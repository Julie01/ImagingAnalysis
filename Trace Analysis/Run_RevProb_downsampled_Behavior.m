%stacks the ratios pre and post all reversals: 30x downsampled
clear

trackfiles=dir('*als_v2.mat');
if isempty(trackfiles)
    trackfiles=dir('*als.mat');
end


mR=NaN;
mP=NaN;
revN=NaN(length(trackfiles),200);
revNnorm=NaN(length(trackfiles),200);
% create gradient matrix
    gradient=zeros(1200+70,2500+70);
    gl=1:-1/(2200-100):0;
    low=0;
    high=1;
    
    for i=1:size(gradient,1)
        gradient(i,1:100)=high;
        gradient(i,100:2200)=gl;
        gradient(i,2301:length(gradient))=low;
    end
    % adjust concentration:
    gradient=gradient*5;

for F=1:length(trackfiles)
    
    fname=(trackfiles(F,1).name);
    load (trackfiles(F).name);
    load([fname(1:end-4), '_anglesV8-smoothn8-corrected.mat']);
    disp(trackfiles(F).name);
    
    if F<2
        gradient=fliplr(gradient);
    end
    
    revAll=[];
    posTAll=[];
    
    posVAll=[];
    
    
    for T=1:length(Tracks)
        
        %CO2
        % get head positions:
            BBy=round(Tracks(1,T).BoundingBox(2:4:end));
            BBx=round(Tracks(1,T).BoundingBox(1:4:end));
            
            try
                absHeadX=WormGeomTracks(1,T).WormHeadPosition(:,1)+BBx'-5;
                absHeadY=WormGeomTracks(1,T).WormHeadPosition(:,2)+BBy'-5;
            catch
                absHeadX=NaN(length(BBx),1);
                absHeadY=NaN(length(BBx),1);
            end
            
            %filter:
            absHeadXf=ceil(medfilt1(absHeadX,10))';
            absHeadYf=ceil(medfilt1(absHeadY,10))';
            %downsample:
            absHeadXf=absHeadXf(1:15:end);
            absHeadYf=absHeadYf(1:15:end);
            
            % find indices which are not NAN and map to gradient
            % landscape:
            %Head:
            sensoryPathHead=NaN;
            H_ind=sub2ind(size(gradient),absHeadYf,absHeadXf);
            for n=1:length(H_ind)
                try
                    sensoryPathHead(n)=gradient(round(H_ind(n)));
                catch%if NaN
                    sensoryPathHead(n)=NaN;
                end
            end
        
        %reversals: make a vector were reversal onsets are marked 1 , other are
        %0
        Revs=Tracks(1,T).polishedReversals;
        RevV=zeros(1,ceil(length(Tracks(T).Frames)/15));
        pTcs=NaN(1,length(RevV));
        if ~isempty(Revs)
            gi=find(Revs(:,4)>0);
            Revs=Revs(gi,:);
            RevON=ceil(Revs(:,1)/15);
            RevEND=ceil(Revs(:,2)/15);
            RevV(RevON)=1;
            revAll=[revAll,RevV];
            
            %     %find episodes of constant CO2 rise
            %     %(1) derivative
            %     md=NaN;
            %     pV=zeros(1,length(diffDF));
            %
            %     c=1;
            %     for i=1:2:length(diffDF)-5
            %         md(c)=mean(diffDF(i:i+5));
            %         if md(c)>0.1
            %             pV(i:i+5)=1;
            %         end
            %         c=c+1;
            %     end
            
            %     %find end and startpoints of positive DF episodes/runs
            %     si=find(diff(pV)==1);
            %     ei=find(diff(pV)==-1);
            

            %     pVcs=NaN(1,length(fDF));
            %% --- cumsum of time in runs:
            for i=1:length(RevEND)
                %         pVcs(si(i):ei(i))=cumsum(fDF(si(i):ei(i)));
            
                    if i+1<length(RevON) & nanmeanJ(diff(sensoryPathHead(RevEND(i):RevON(i+1))))<-0.0005 % only whe sensory input was on average positive during run
                        
                        pTcs(RevEND(i):RevON(i+1))=cumsum(ones(1,length(RevEND(i):RevON(i+1))));

                    elseif i+1>length(RevON)
                    pTcs(RevEND(i):end)=cumsum(ones(1,length(RevEND(i):length(pTcs))));
                end
            end
            
            %     posVAll=[posVAll,pVcs];
            posTAll=[posTAll,pTcs];
        end
    end % end track loop
    
    %% bin& frequency %%%%
    
    C=1;
    bintype=2; %1=sensory, 2=time
    
    if bintype==1
        first=-15;
        last=66;
        binsize=0.5;
        
    else
        first=1;
        last=150;
        binsize=2;
    end
    
    for delay =0
        
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
                end
                revV=revAll(bin_idx+delay);
                
                mP(F,cc)=nanmeanJ(binPos);
                revN(F,cc)=nansum(revV);
                revNnorm(F,cc)=nansum(revV)/length(bin_idx);
            else
                mP(F,cc)=NaN;
                revN(F,cc)=NaN;
                revNnorm(F,cc)=NaN;
            end
            
            cc=cc+1;
            
        end
        
    end
    
end % end track files loop

%%  plot:
revNnorm(revNnorm==0)=NaN;

revNnorm=revNnorm(:,1:cc);

errorplot(revNnorm,1,0)

if bintype==1 
    set(gca,'XTick',1:cc/15:length(mP))
    set(gca,'XTickLabel',round(mP(:,1:cc/15:end)*10)/10);
    xlabel('cumsum positive dF norm ')
    
else
    set(gca,'XTick',[1:10:length(nanmeanJ(mP))])
    set(gca,'XTickLabel',round(nanmeanJ(mP(:,1:10:end))*1)/1);
    xlabel('cumsum time(s)')
end

ylabel('reversal frequency')


ylim([0 0.25])
xlim([0 cc-1])


C=C+1;



