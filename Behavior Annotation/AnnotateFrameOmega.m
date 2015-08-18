
function AnnotateFrame(moviename,start)

global fn handles OmegaFrames
handles.moviename=moviename;
handles.start=start;
handles.OmegaFrames=NaN;
handles.cc=1;
screen=get(0,'screensize');
handles.f1=figure('OuterPosition',[screen(3)/1.5,screen(4)/7,screen(3)/5,screen(4)/5],'Name','Button');
dim=get(handles.f1,'Position');
stop_button1 = uicontrol('Style', 'pushbutton', 'String', 'Omega',...
'Position', [dim(3)/12 dim(4)/10 dim(3)/1.6 dim(3)/2],'Callback',@stopandsave);

end

%----------
function stopandsave(hObject,handles,fn)
global fn OmegaFrameshandles
handles.OmegaFrames(handles.cc)=fn;
handles.cc=handles.cc+1;
OmegaFrames=handles.OmegaFrames;
us= strfind(handles.moviename, '_');
recordname=[handles.moviename(1:us(end)) '_omega_StFrame_' num2str(handles.start)];
save (recordname, 'OmegaFrames')
end

%----------
