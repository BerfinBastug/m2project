%STEP1
NTRIAL=10;
%STEP2
dir = '/Users/admin/Desktop/m2project/';
NewFolder = 'FRstim';
mkdir(NewFolder);
stimdir = strcat(dir,NewFolder);
cohVals = 0:0.5:1;
for i=1:NTRIAL
    sP.repdur = 0.5;
    for a = 1:length(cohVals)
        [x, sP] = gencloudcoherence;
        sP.coherence = cohVals(a);
        x = gencloudcoherence(sP);
        stimname = strcat(stimdir,'/','FR_tonecloudstim_repdur',num2str(sP.repdur),'_','coherence',num2str(sP.coherence),'_nrep',num2str(sP.nrep),'.wav');
        audiowrite(stimname,x,sP.fs);
        allsP{i,a} = sP; %duration X coherence
        allXs{i,a} = x; %duration X coherence
    end
end
save all_sP_values_FR.mat allsP
save all_x_values_FR.mat allXs