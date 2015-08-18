function fn=VideoReplay(moviename,rate,start)
global fn
warning off

vp = VideoPlayer(moviename, 'Verbose', false, 'ShowTime', false,'InitialFrame',start);
screen=get(0,'screensize');
setPlotPosition(vp, [screen(3)/2.8,screen(4)/2.9,screen(3)/1.7,screen(4)/1.8]);

%annotation button:
AnnotateFrameRev(moviename,start)

while ( true )

        plot( vp );
        drawnow;
        fn=vp.FrameNum;
        pause(1/rate)
        
        
        if ( ~vp.nextFrame)
            break;
        end
     
end
end