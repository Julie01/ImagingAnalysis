

[bearingangles, dBearing1, curvature, hx,hy]=getbearing_freelyMoving(X,Y,max(X),5);
%bearingangles=vertcat(bearingangles, NaN(1,6)');

scatter(X,Y,15,bearingangles(1:length(X)),'filled')