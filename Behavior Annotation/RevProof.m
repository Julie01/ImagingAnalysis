% calculates speed and angular speed from stagepositon:
clearvars -except RevFrames
global fn click handles

start=10;
F=2;


click=0;
warning off
close all
d=NaN;

%XY:
posfiles=dir('*stagepos*');
XYpos=load(posfiles(F).name);
X=1-XYpos(1:5:end,3);
Y=XYpos(1:5:end,4);
Ya=XYpos(:,4);
Xa=1-XYpos(:,3);

%ratio:
rfiles=dir(['*_log.mat']);
load (rfiles(F).name);

%name:
stacks=dir('*ch*.stk'); stackname=stacks(F).name;
us= strfind(stackname, '.');
recordname=[stackname(1:us(end)-1) '_rev_SF_1'];

%%
% figure
% plot(frames',AV);
% hold on
% scatter(frames(maxi(:,1)),maxi(:,2))
%%

%%%%% replay and annotate cherry movie
screen=get(0,'screensize');
mf=figure('Position', [screen(3)/3,screen(4)/3,screen(3)/1.6,screen(4)/1.7]);

plot(Xa,Ya,'k');
hold on
RevFrames30hz=(RevFrames-1)*3;

RevON=RevFrames30hz(1:2:end);
RevEND=RevFrames30hz(2:2:end);

scatter(Xa(RevON(1:end)),Ya(RevON(1:end)),'rp','filled');
scatter(Xa(RevON(end)),Ya(RevON(end)),'mh','filled');
try
    scatter(Xa(RevEND(1:end)),Ya(RevEND(1:end)),'gp','filled')
catch
    scatter(Xa(RevEND(1:end-1)),Ya(RevEND(1:end-1)),'gp','filled')
end



%%%%%% SAVE

%save (recordname, 'RevFrames30hz')







% if exist('RevFrames')
% start=RevFrames(end)-30;
% end

% %%%%---annotation button:---
% AnnotateFrameRev(stackname,start)
%
% cc=0;
% p=9;
% for i = start:3:length(Xa)
%     fn=i;
%     if i>40
%         p=40;
%     end
%     worm=scatter(Xa(i-p:i),Ya(i-p:i),'b','filled');
%     title(fn);
%     pause(0.1);
%     cf=gcf;
%     if cf~=1 & cc==1
% cc=cc+1;
% pause(0.5)
% figure(mf)
%     elseif cf~=1 & cc>2
%             figure(mf)
%         cc=0;
%     end
%     try
%    delete(worm)
%
%     end
%     cc=cc+1;
%
% end
%
%
