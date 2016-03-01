%stacks the ratios pre and post all reversals:
% load ImagingDataRevCorr
clearvars -except ImagingData idx AD nearest
type='all'
%close
%ImagingData=AD;
f1=figure;
CC=1;
PauseMatrix=NaN(length(ImagingData),14560);
SpeedMatrix=NaN(length(ImagingData),14560);
RMatrix=NaN(length(ImagingData),14560);
RevMatrix=NaN(length(ImagingData),14560);
CumSumN=NaN(length(ImagingData),14560/2);
CumSumS=NaN(length(ImagingData),14560/2);
nfc1=NaN(length(ImagingData),14560/2);
nfc2=NaN(length(ImagingData),14560/2);
P1=NaN;
P2=NaN;

p_cutoff=0.025;
disp(p_cutoff)

%for F=nearest(:,2)'

for F=1:length(ImagingData)
    
    %ratio:
    %(1)
    cherry1=abs(medfilt1(ImagingData{F}.cherry1(1:7280),5));
    gcamp1=abs(medfilt1(ImagingData{F}.gcamp1(1:7280),5));
   
    %out of focus correction
    % find very rapid changes in size of cherry area and emove this data:
    areaR1=ImagingData{F}.AreaR1_1(1:7280);
    areaJumps1=find(diff(medfilt1(areaR1))>80 | diff(medfilt1(areaR1))<-80);
    areaJumps1=vertcat(areaJumps1, find(areaR1>2*nanmedian(areaR1) | areaR1<0.25*nanmedian(areaR1)));
    ni= find(cherry1<nanmedian(cherry1)-(2.5*nanstd(cherry1)));
    ni=[ni ;areaJumps1];
    cherry1(ni)=NaN;
    gcamp1(ni)=NaN;
    mc(F)=nanmean(cherry1(1:1000)./areaR1(1:1000));
    mg(F)=nanmean(gcamp1(1:1000)./areaR1(1:1000));

    
end

%------------plot----------
plots=1;

if plots==1
    figure(f1);
    plotyy(1:length(mg),mg,1:length(mc),mc)
end

legend('gcamp', 'cherry')

[v idx]=sort(mg);
    
    
