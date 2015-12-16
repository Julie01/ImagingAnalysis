
home=cd;
folders=dir('*W*');
bearing_global={NaN};
Intensity={NaN};
XYds={NaN};


cc=0;

for F=[2 3 4 5]
    
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
        
Xds=medfilt1(X);
Xds=Xds(1:25:end);
Yds=medfilt1(Y);
Yds=Yds(1:25:end);
TV=1:25:length(X);

[bearingangles, dBearing1, curvature, hx,hy]=getbearing_freelyMoving(Xds,Yds,max(X),5);
% bearingangles=vertcat(bearingangles, NaN(1,6)');


%ratio:

load(logfiles(LN).name)

ratio1=(thiswormdata(:,1)./thiswormdata(:,2));

areaR1=thiswormdata(:,3);

% find very rapid changes in size of cherry area and emove this data:
areaJumps1=find(diff(medfilt1(areaR1))>300 | diff(medfilt1(areaR1))<-300);
areaJumps1=vertcat(areaJumps1, find(areaR1>2*nanmean(areaR1) | areaR1<0.25*nanmean(areaR1)));

ratio1(areaJumps1+1)=NaN;

Rds=(ratio1(1:25:end));

nidx=find(isnan(Rds));
if (length(nidx)/length(Rds))<0.8

cc=cc+1;
bearing_global{cc}=bearingangles;
Intensity{cc}=Rds;
else
    cc=cc+1;
bearing_global{cc}=NaN;
Intensity{cc}=NaN;
end
XYds{cc}=vertcat(hx,hy,TV(1:length(hx)))';
    
 
  end
  
cd(home)

end

save('bearing_global', 'bearing_global','XYds')
%% correlate:
IBcorr_global=NaN;
for i=1:cc
    IBcorr_global(i)=nancorr(Intensity{i},bearing_global{i});
end
