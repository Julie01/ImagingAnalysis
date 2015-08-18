
function AnnotateFrameRev(moviename,start)

global fn handles RevFrames click

handles.moviename=moviename;
us= strfind(handles.moviename, '.');
handles.start=start;
handles.recordname=[handles.moviename(1:us(end)-1) '_rev_SF_' num2str(handles.start)];

handles.RevFrames=NaN;
handles.cc=1;
screen=get(0,'screensize');
handles.f1=figure('OuterPosition',[screen(3)/1.5,screen(4)/7,screen(3)/4,screen(4)/5],'Name','Button','MenuBar','None');
dim=get(handles.f1,'Position');

stop_button = uicontrol('Style', 'pushbutton', 'String', 'Reversal',...
    'Position', [dim(3)/12 dim(4)/13 dim(3)/1.6 dim(3)/2],'Callback',@stopandsave);
delete_button = uicontrol('Style', 'pushbutton', 'String', 'delete',...
    'Position', [dim(3)/1.3 dim(4)/13 dim(3)/5 dim(3)/6],'Callback',@delete);
handles.statefield=subplot('Position',[ 0.74  0.6  0.22 0.25],'XTick',[],'YTick',[]);

end

%----------
function stopandsave(hObject,handles,fn)
global fn RevFrames handles click
click=1;
handles.RevFrames(handles.cc)=fn;

RevFrames=handles.RevFrames;

save (handles.recordname, 'RevFrames')

% change indicator field color
if mod(handles.cc,2)==0
    set(handles.statefield,'Color','g')
    cla
    axes(handles.statefield)
    text(0.3,0.5,'FW')
else
    cla
    set(handles.statefield,'Color','r')
    axes(handles.statefield)
    text(0.3,0.5,'REV')
end


handles.cc=handles.cc+1;
uiresume
click=0;
end

%----------
function delete(hObject,handles,fn)
global fn RevFrames handles

handles.cc=handles.cc-1;
handles.RevFrames(handles.cc)=[];
RevFrames=handles.RevFrames;

save (handles.recordname, 'RevFrames')

% change indicator field color
if mod(handles.cc-1,2)==0
    set(handles.statefield,'Color','g')
    cla
    axes(handles.statefield)
    text(0.3,0.5,'FW')
else
    cla
    set(handles.statefield,'Color','r')
    axes(handles.statefield)
    text(0.3,0.5,'REV')
end

end
