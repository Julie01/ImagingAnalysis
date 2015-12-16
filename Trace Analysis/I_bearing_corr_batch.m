
home=cd;
folders=dir('*W*');
bearing={NaN};
Intensity={NaN};
cherry={NaN};

cc=0;

for F=[ 2 3 4 5 ]
    
    cd(folders(F).name)
    
    posfiles=dir('*stagepos*');
    logfiles=dir('*R1*log*');
    
    
    for LN =1:length(logfiles)
        
        %XY coordinates
        if isempty(posfiles)
            
            posfiles=dir('*.xlsx');
            xy=xlsread(posfiles(1).name);
            X=xy(1:7900);
            X=1-X;
            Y=xy(7901:end);
            Y=1-Y;
            
        else
            disp(posfiles(LN).name)
            XYpos=load(posfiles(LN).name);
            X=1-XYpos(:,3);
            Y=1-XYpos(:,4);
        end
        
        [bearingangles, dBearing1, curvature, hx,hy]=getbearing_freelyMoving(X,Y,max(X),6);
        % bearingangles=vertcat(bearingangles, NaN(1,6)');
        
        
        %ratio:
        
        load(logfiles(LN).name)
        
        ratio1=(thiswormdata(:,1)./thiswormdata(:,2));
        
        areaR1=thiswormdata(:,3);
        
        % find very rapid changes in size of cherry area and emove this data:
        areaJumps1=find(diff(medfilt1(areaR1))>300 | diff(medfilt1(areaR1))<-300);
        areaJumps1=vertcat(areaJumps1, find(areaR1>2*nanmean(areaR1) | areaR1<0.25*nanmean(areaR1)));
        
        ratio1(areaJumps1+1)=NaN;
        cutoff_idx=find(ratio1<0.049);
        ratio1(cutoff_idx)=0.04;
        cutoff_idx=find(ratio1>5);
        ratio1(cutoff_idx)=NaN;
        nidx=find(isnan(ratio1));
        if (length(nidx)/length(ratio1))<0.8
            
        else
            cc=cc+1;
            bearing{cc}=NaN;
            Intensity{cc}=NaN;
        end
        
        cc=cc+1;
        bearing{cc}=bearingangles;
        Intensity{cc}=ratio1;
        cherry{cc}=medfilt1(thiswormdata(:,2));
        
    end
    
    cd(home)
    
end

save bearing bearing
save 'Intensities' Intensity cherry
%% correlate:
IBcorr=NaN;
for i=1:cc
    IBcorr(i)=nancorr(medfilt1(Intensity{i}),bearing{i});
end
