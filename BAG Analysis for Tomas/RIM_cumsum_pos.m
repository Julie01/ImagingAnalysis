% locks RIB signals to speed onset:
clearvars -except ImagingData
close
%initieate variables:
SpeedMatrix=NaN(length(ImagingData),14560);
RIM_Matrix=NaN(length(ImagingData),14560);
CumSumRIMpos=NaN(length(ImagingData),14560);
RevMatrix=NaN(length(ImagingData),14560);
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
        
        %cumsum RIM:
        RIM=[eq_ratio1; eq_ratio2];
        RIM=medfilt1(RIM,10);
        RIM_Matrix(CC,:)=RIM;
        rim_pos=NaN(length(RIM),1);
        for ii=1:15:length(RIM)-30
            if mean(diff(RIM(ii:3:ii+30)))>0.01
                rim_pos(ii:ii+30)=RIM(ii:ii+30);
            end
        end
        nf=ones(length(rim_pos),1);
        ni=(isnan(rim_pos));
        nf(ni)=NaN;
        nfc=nancumsum(nf);
        CumSumRIMpos(CC,:)=(nancumsum(rim_pos));
        %CumSumRIMpos(CC,:)=(nancumsum(rim_pos))./nfc;%normalized
        
        %reversals derived from RIM Activity:
        RevMatrix(CC,:)=~isnan(rim_pos);
        
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

%         CC=CC+1;

    end
    CC=CC+1;
end

%correlate rim/reversals with R:






           