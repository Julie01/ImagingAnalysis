% locks RIB signals to speed onset:
clearvars -except ImagingData
close
%initieate variables:
SpeedMatrix=NaN(length(ImagingData),14560);
RIM_Matrix=NaN(length(ImagingData),14560);
CC=1;
cc=1;
        rev_rim=NaN(500,300);
        rev_speed=NaN(500,300);
        rev_rim_d=NaN(500,300);
        rev_speed_d=NaN(500,300);

for F=1:length(ImagingData)
    
    if isfield(ImagingData{F},'cherryR2_1') %only RIM data
        %-----ratios RIM:-------------
        %(1)
        cherry1=medfilt1(ImagingData{F}.cherryR2_1(1:7280),5);
        gcamp1=medfilt1(ImagingData{F}.gcampR2_1(1:7280),5);
        eq_ratio1=(gcamp1/nanmedian(gcamp1))./(cherry1/nanmedian(cherry1));
        %(2)
        cherry2=medfilt1(ImagingData{F}.cherryR2_2(1:7280),5);
        gcamp2=medfilt1(ImagingData{F}.gcampR2_2(1:7280),5);
        eq_ratio2=(gcamp2/nanmedian(gcamp2))./(cherry2/nanmedian(cherry2));
        
        %speed:
        thisXY=[ImagingData{F}.XY_1 ;ImagingData{F}.XY_2];
        Xf=medfilt1(thisXY(1:10:end,1),5);
        Yf=medfilt1(thisXY(1:10:end,2),5);
        speed10=NaN(1,length(Xf));
        for ii=1:length(Xf)-1
            speed10(ii)=abs(sqrt(((Xf(ii)-Xf(ii+1)).^2)+((Yf(ii)-Yf(ii+1)).^2)))*3; % traveled path during "distance" intervall
        end
        %interpolate
        warning off
        Xup=interp1(1:length(speed10),speed10,1:1/10.0065:length(speed10));
        speed=Xup./100; %is in pix/sec (pix-->mm=47/64000 = 0.00073)
        %NaN episodes of high stage search & when the neuron is lost
        bi=find(speed>3);
        bi2=find(isnan([eq_ratio1; eq_ratio2]));
        for b=-9:9
            try
                speed(bi+b)=NaN;
            end
        end
        speed(bi2)=NaN;
        speed=medfilt1(speed,15);
        SpeedMatrix(CC,:)=speed;
        
        speedV=zeros(1,length(speed));
        hi=find(speed>0.065);
        speedV(hi)=1;
        %find speed onsets:
        Mon=find(diff(speedV)>0)/1;
        Moff=find(diff(speedV)<0)/1;
        try
        if Moff(1)<Mon(1)
            Moff(1)=[];
        end
        end
        
        RIM=[eq_ratio1; eq_ratio2];
        RIM=medfilt1(RIM,10);
        RIM_Matrix(CC,:)=RIM;
        
        
        %find speed onsets which coincide with RIM rise:
%         rev_rim=NaN(50,300);
%         rev_speed=NaN(50,300);
%         rev_rim_d=NaN(50,300);
%         rev_speed_d=NaN(50,300);
        
        on=NaN;
%         cc=1;
        for ii=1:length(Mon)
            if Mon(ii)<14525
            if mean(diff(RIM(Mon(ii):3:Mon(ii)+35)))>0.009
                rev_rim(cc,1:length((Mon(ii):Moff(ii))))=RIM(Mon(ii)-10:Moff(ii)-10);
                rev_speed(cc,1:length((Mon(ii):Moff(ii))))=speed(Mon(ii):Moff(ii));
                rev_rim_d(cc,1:length((Mon(ii):Moff(ii))))=[diff(RIM(Mon(ii):Moff(ii))); NaN];
                rev_speed_d(cc,1:length((Mon(ii):Moff(ii))))=[diff(speed(Mon(ii):Moff(ii))) NaN];
                on(cc)=Mon(ii);
                cc=cc+1;
            end
            end
        end
        
         rev_rim=rev_rim(:,1:300);
        rev_speed=rev_speed(:,1:300);
        
        rim{F}=rev_rim;
        r_speed{F}=rev_speed;
        
        %% plot:
        subtightplot(3,3,CC)
        for i=1:cc
            cr=rev_rim(i,:)/rev_rim(i,1);
            plot(cr)
            hold on
        end
        title(F)
        CC=CC+1;

    end
    % %correct for bleaching:
    % bcf=[1:0.2/length(RIM):1.2];
    % bcf=bcf(1:length(RIM))';
    % RIMc=RIM.*bcf;
    
end

%% normalize:
norm_rim=NaN(size(rev_rim));
norm_speed=NaN(size(rev_rim));
for i=1:cc
    nr=rev_rim(i,:)/rev_rim(i,1);
    ns=rev_speed(i,:)/rev_speed(i,1);
    norm_rim(i,1:length(nr))=nr;
    norm_speed(i,1:length(ns))=ns;
end

%% bin:
mRIM=NaN;
mSpeed=NaN;
rimall=reshape(norm_rim,1,numel(norm_rim));
speedall=reshape(rev_speed,1,numel(rev_speed));
speedall(find(speedall==inf))=NaN;

binsize=0.05;
bc=1;
for i=0.05 :binsize:(2-binsize)
    
    bin_idx= find(speedall>i & speedall<=i+binsize);
    
    if length(bin_idx)>100
        
        bR=rimall(bin_idx);
        sV=speedall(bin_idx);
        
        mRIM(1,bc)=nanmean(bR);
        mSpeed(1,bc)=nanmean(sV);
    else
        mRIM(1,bc)=NaN;
        mSpeed(1,bc)=NaN;
        
    end
    bc=bc+1;
    
end


           