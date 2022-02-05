function [FRBLOCKS] = organizeFRblocks
%% RANDOMIZE FRstim
% STEP1: LOCATE WHERE THE SOUNDS ARE
FRstimDir = '/Users/admin/Desktop/m2project/FRstim';
FRstims=dir(FRstimDir);
FRstim_list = {FRstims.name};

% STEP2: DROP THE EMPTY ITEMS IN THE LIST
FRstim_list = FRstim_list(~ismember(FRstim_list,{'.','..'}));
FRstim_list = convertCharsToStrings(FRstim_list);

% STEP3: RANDOMIZE THE SOUNDS
FRnum_stims = length(FRstim_list);
FRstim_indices = 1:FRnum_stims;
FRnum_repeats = 1;
FRnum_trials = FRnum_stims * FRnum_repeats;
FRrand_stim_order = nan(1, FRnum_trials);

for k = 1:FRnum_stims:FRnum_trials
    subsequence = Shuffle(FRstim_indices);
    FRrand_stim_order(k:k+(FRnum_stims-1)) = subsequence;
    % swap the first value of this subsequence if it repeats the previous
    if k > 1 && (FRrand_stim_order(k) == FRrand_stim_order(k-1))
        FRrand_stim_order([k, k+1]) = FRrand_stim_order([k+1, k]);
    end
end
%% GROUP STIMULI
NBLOCK = 9;
start_index = 1:10:90;
end_index = 10:10:90;
randomizedFRstim = FRstim_list(FRrand_stim_order);
for i=1:NBLOCK
    FRBLOCKS(i).FR  = randomizedFRstim(start_index(i):end_index(i));
end
end
