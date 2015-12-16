%stacks the ratios pre and post all reversals:
home=cd;
dayfolders=dir('*_BAGx*');
behavior={NaN};

for DF=1:length(dayfolders)
    
    cd(dayfolders(DF).name)
    
    folders=dir('*_W*');
    
    prerev=NaN(1,900);
    cc=1;
    
    for F=1:length(folders)
        
        cd(folders(F).name)
        
        behavfiles=dir('*behav*');
        logfiles=dir('*R1*log*');
        
        
        for LN =1:length(behavfiles)
            
            disp(logfiles(LN).name)
            load (behavfiles(LN).name)
            behavior{cc}.r_on=r_onset;
            behavior{cc}.r_off=r_off;
            behavior{cc}.omega_off=omega_off;
            behavior{cc}.label=[logfiles(LN).name(1:11) '_T' num2str(LN)];
            disp(behavior{cc}.label)
            
            cc=cc+1;
            
        end
        
        cd ..\
    end
    
    cd(home)
    
end % end dayfolder loop



