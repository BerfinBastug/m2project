%STEP1
pd = makedist('Exponential','mu',0.6);
t = truncate(pd,0.15,1);
r = random(t,15,1);
%histogram(r,100);
%STEP2
dir = '/Users/admin/Desktop/m2project/';
NewFolder = 'VSDstim';
mkdir(NewFolder);
stimdir = strcat(dir,NewFolder);
cohVals = 0:0.5:1;
for i=1:length(r)
    [x, sP] = gencloudcoherence;
    sP.repdur = r(i);
    for a = 1:length(cohVals)
        sP.coherence = cohVals(a);
        x = gencloudcoherence(sP);
        stimname = strcat(stimdir,'/','VSD_tonecloudstim_repdur',num2str(sP.repdur),'_','coherence',num2str(sP.coherence),'_nrep',num2str(sP.nrep),'.wav');
        audiowrite(stimname,x,sP.fs);
        allsP{i,a} = sP; %duration X coherence
        allXs{i,a} = x; %duration X coherence
    end
end
save all_sP_values.mat allsP
save all_x_values.mat allXs