% plots fraction of reversing worms from imaging:

figure
pp=nansum(RevMatrix,1)/(CC-1);
pp=medfilt1(pp);
plot([tv tv2], pp(1:end), 'linewidth',2)
hold on
plot ([4.63*60 4.63*60], [0 1],'g')
ylabel('fraction animals reversing')
xlabel( 'sec')
ylim([0 1])
title(dirname(cd))