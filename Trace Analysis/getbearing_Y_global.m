
function [ bearingangles,headingangles, smX,smY]= getbearing_Y_global(X,Y,Yref,window)

% funtion caltulates heading and Bearing of XY trajectories to a refereence
% point

smY1=round(smoothn(Y,window));
smX1=round(smoothn(X,window));

Xd=smX1(1:window:end);
Yd=smY1(1:window:end);
X=interp1(1:length(Xd),Xd,1:(1/window):length(Yd));
Y=interp1(1:length(Yd),Yd,1:(1/window):length(Xd));
smY=smoothn(Y,window*3);
smX=smoothn(X,window*3);


L=length(X);

beelineX=NaN(L,1);
beelineY=NaN(L,1);
headingX=NaN(L,1);
headingY=NaN(L,1);
nenner=NaN(L,1);
Brecher=NaN(L,1);
cosinus_angle=NaN(L,1);
bearingangles=NaN(L,1);
headingangles=NaN(L,1);

diffwin=3;
if L>diffwin+1
    for ii=1:L-diffwin
        beelineX(ii)=0;
        beelineY(ii)=(Yref-(smY(ii)));0;%(roi(2,2)+100-(X(ii)));  % alternatively bearing towards gas inlet
        headingX(ii)=(smX(ii+diffwin))-(smX(ii));
        headingY(ii)=(smY(ii+diffwin))-(smY(ii));
        nenner(ii)=((beelineX(ii)*headingX(ii))+(beelineY(ii)*headingY(ii)));
        Brecher(ii)=(sqrt((beelineX(ii)).^2+(beelineY(ii)).^2))*(sqrt((headingX(ii)).^2+(headingY(ii)).^2));
        cosinus_angle(ii)=nenner(ii)/Brecher(ii);
        bearingangles(ii+1,1)=(acos(cosinus_angle(ii)))*(360/(2*pi));
        headingangles(ii+1) = atan2(headingY(ii),headingX(ii));
    end
    
    dBearing1=[diff(bearingangles)', NaN]; 
    curvature=(diff(headingangles));
    headingangles=[headingangles' , NaN];
    bi=find(curvature>0.9|curvature<-0.9);% account for jumps at 3-3 rad border
    curvature(bi)=NaN;
    
else
    dBearing1=NaN;
    curvature=NaN;
    
end
