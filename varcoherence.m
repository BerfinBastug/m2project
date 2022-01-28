dir = '/Users/admin/Desktop/m2project/';
NewFolder = 'stimulipilot';
mkdir(NewFolder);
Ntrial = 1;
stimdir = strcat(dir,NewFolder);
cohVals = 0:0.05:1;
for a=1:Ntrial
    for i = 1:length(cohVals)
        [x, sP] = gencloudcoherence;
        sP.coherence = cohVals(i);
        x = gencloudcoherence(sP);
        stimname = strcat(stimdir,'/','tonecloudstim',num2str(a),'_',num2str(i),'_','repdur',num2str(sP.repdur),'_', 'nrep',num2str(sP.nrep),'_','coherence',num2str(sP.coherence),'.wav');
        audiowrite(stimname,x,sP.fs);
        xValues(i,:) = x;
        sPValues{i} = sP;
    end
    allxValues{a} = xValues;
    allsPValues{a} = sPValues;
end
% dir = '/Users/admin/Desktop/tonecloudsproject/';
% writetable(struct2table(ALLsPValues), 'ALLsPValues09.09.2021.csv')
% writematrix(xValues, 'xval_100coherence_07december2021.csv')