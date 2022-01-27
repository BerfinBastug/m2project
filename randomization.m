sounds = '/Users/admin/Desktop/m2/tonecloudstimuli';
d=dir(sounds);
d=d(~ismember({d.name},{'.','..'}));
num_sounds = length(d);
sound_options = 1:num_sounds;
num_repeats = 1;
num_trials = num_sounds * num_repeats;
sound_order = nan(1, num_trials);
for k = 1:num_sounds:num_trials
    subsequence = Shuffle(sound_options);
    sound_order(k:k+(num_sounds-1)) = subsequence;
    % swap the first value of this subsequence if it repeats the previous
    if k > 1 && (sound_order(k) == sound_order(k-1))
        sound_order([k, k+1]) = sound_order([k+1, k]);
    end
end
%%
% diagnostics on sequence
disp('Word Order:')
disp(sound_order);
% verify there are no repeated elements in the sequenceas
has_repeats = any(diff(sound_order) == 0);
if (has_repeats)
    disp('sequence has sequential repeats!')
else
    disp('sequence has no sequential repeats!')
end

for k = 1:num_sounds
    fprintf('Word %i is present at a rate of %2.2f \n', k, mean(sound_order == k)); 
end

%%
blah = 1:length(sound_order);
hundreds = blah(100:100:end);
firstblock = sound_order(1:hundreds(1));
secondblock= sound_order(hundreds(1)+1:hundreds(2));
