

clear
home=cd;
folders=dir('*W*');
dCO2={NaN};
Intensity={NaN};
cherry={NaN};

cc=0;

for F=[ 2 3 4 5 ]
    
    cd(folders(F).name)
    
    posfiles=dir('*stagepos*');
    logfiles=dir('*R1*log*');
    
    
    for LN =1:length(logfiles)
        
        %XY coordinates
        
        disp(posfiles(LN).name)
        XYpos=load(posfiles(LN).name);
        X=1-XYpos(:,3);
        Y=1-XYpos(:,4);
        
        %normalize and round:
        X=round((X+32000)/10);
        Y=round((Y+32000)/10);
        
        %gradient:
        gradient=NaN(5001,5001);
        gradient=0:1/5000:1;
        for i=1:12
            gradient=vertcat(gradient,gradient);
            %     gradient(i,:)=0:1/5000:1;
        end
        gradient=gradient*2.5;
        
        %Map XY on gradient:
        
        X(X>length(gradient))=NaN;
        C_ind=sub2ind(size(gradient),Y,X);
        
        %get CO2 concentration at this position of path:
        nan_idx=isnan(C_ind);
        C_ind=C_ind(nan_idx~=1);
        
        %get CO2 concentration at this position of path and reinsert Nans:
        gradV=(gradient(round(C_ind)));
        gradVal=NaN(1,length(nan_idx));
        gradVal(nan_idx~=1)=gradV;
        
        
        
        
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
        if (length(nidx)/length(ratio1))>0.8
            
     
            cc=cc+1;
            dCO2{cc}=NaN(2,1);
            Intensity{cc}=NaN(2,2);
        else
        
        cc=cc+1;
        dCO2{cc}=[diff(gradVal) NaN];
        Intensity{cc}=ratio1;
        cherry{cc}=medfilt1(thiswormdata(:,2));
        end
        
    end
    
    cd(home)
    
end

save dCO2 dCO2
save 'Intensities' Intensity cherry
%% correlate:
I_dCO2_corr=NaN;
for i=1:cc
    I_dCO2_corr(i)=nancorr(medfilt1(Intensity{i}(1:length(dCO2{i}))),dCO2{i});
end
