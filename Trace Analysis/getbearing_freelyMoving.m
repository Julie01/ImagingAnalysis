
function [headingangles, bearingangles, dBearing1, curvature, smX,smY]= getbearing_freelyMoving(X,Y,Xref,window)

% funtion caltulates heading and Bearing of XY trajectories to a refereence
% point

smY=round(smoothn(Y,window));
smX=round(smoothn(X,window));


L=length(smX);

beelineX=NaN(L,1);
beelineY=NaN(L,1);
headingX=NaN(L,1);
headingY=NaN(L,1);
nenner=NaN(L,1);
Brecher=NaN(L,1);
cosinus_angle=NaN(L,1);
bearingangles=NaN(L,1);
headingangles=NaN(L,1);

if L>3
    for ii=1:L-2
        beelineX(ii)=(Xref-(smY(ii)));
        beelineY(ii)=0;%(roi(2,2)+100-(smX(ii)));  % alternatively bearing towards gas inlet
        headingX(ii)=(smX(ii+2))-(smX(ii));
        headingY(ii)=(smY(ii+2))-(smY(ii));
        nenner(ii)=((beelineX(ii)*headingX(ii))+(beelineY(ii)*headingY(ii)));
        Brecher(ii)=(sqrt((beelineX(ii)).^2+(beelineY(ii)).^2))*(sqrt((headingX(ii)).^2+(headingY(ii)).^2));
        cosinus_angle(ii)=nenner(ii)/Brecher(ii);
        bearingangles(ii,1)=(acos(cosinus_angle(ii)))*(360/(2*pi));
        headingangles(ii) = atan2(headingY(ii),headingX(ii));
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
