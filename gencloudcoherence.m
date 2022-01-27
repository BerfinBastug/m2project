function[x,sP] = gencloudcoherence(sP,sigint)

% parameters
if nargin < 1
    sP.lowf = 200; % lower edge of the frequency grid
    sP.highf = 5000; % nominal higher edge of the frequency grid (we overshoot by at most fstep)
    sP.fstep = 0.5; % size of grid cell, in octave    
    sP.timestep = 0.05; % in s. By default: start at any time point within the timestep
    sP.tonedur = 0.05; % duration of one tone
    sP.repdur = 0.25; % how long is a repeat, in s
    sP.nrep = 5; % how many repeats do we generate (warning: 1 is actually no repeat! 2 is 1+1)
    sP.coherence = 1; % what is the proportion of tones repeated in each repeat
    sP.seed = NaN; % use this if you want to regenerate the same stimulus
    sP.rtime = 0.025; % rise time for individual tones
    sP.fs = 44100; % sampling rate
end
    
if nargin < 2
    sigint = 1; % if sigint == 1, then generate a repeated stimulus with the sP parameters, else non-repeated (but same parameters)
end


% deal with random number generator
if ~isnan(sP.seed)
    rng(sP.seed, 'twister')
else     
    rng('shuffle','twister');
    randstate = rng;
    sP.seed = randstate.Seed;
end

% compute lower edges of the grid
ok = 0;
freqgrid = [];
freqgrid(1) = sP.lowf;
idx = 1;
while ~ok
    zfreq = freqgrid(idx)*2^sP.fstep;
    if zfreq > sP.highf
        ok = 1;
    else
        idx = idx+1;
        freqgrid(idx) = zfreq;
    end
end

% we do one rep
timegrid = [0:sP.timestep:sP.repdur-sP.timestep];

% init
nfsteps = length(freqgrid);
ntsteps = length(timegrid);

% do all that is random: normalized perturbations of freq and time
fnorm = rand(nfsteps,ntsteps);
tnorm = rand(nfsteps,ntsteps);

% now build the actual frequency and time matrices
bigf = repmat(freqgrid',1,ntsteps);
zf = 2.^(log2(bigf)+fnorm*sP.fstep);
bigt = repmat(timegrid,nfsteps,1);
zt = bigt+tnorm*sP.timestep;

% deal with coherence
% number of tones
ntones = length(bigf(:));
% how many of them will repeat
if (sP.coherence == 0) | (sigint == 0)
    nreptones = 0
    nnewtones = ntones - nreptones
 elseif (sP.coherence == 1) & (sigint == 1)
    nreptones = ntones
    nnewtones = ntones - nreptones
else
    nreptones = ceil(ntones*sP.coherence)
    nnewtones = ntones - nreptones
end
% who are the lucky few?
idxdraw = randperm(ntones);
idxreptones = idxdraw(1:nreptones);
idxnewtones = idxdraw(nreptones+1:end);


bigzf = [];
bigzt = [];
for idelay = 1:1:sP.nrep
    % first, exact repetitions
    newzf = zf;
    newzt = zt;
    newfnorm = rand(nfsteps,ntsteps); % more than needed but cheap and easier for indexing
    newtnorm = rand(nfsteps,ntsteps); % ditto
    zf(idxnewtones) = 2.^(log2(bigf(idxnewtones))+newfnorm(idxnewtones)*sP.fstep);
    zt(idxnewtones) = bigt(idxnewtones)+newtnorm(idxnewtones)*sP.timestep;
    bigzf = [bigzf zf];
    bigzt = [bigzt zt+(idelay-1)*sP.repdur];
end
      


% generate all tones
tx = [0:1/sP.fs:sP.tonedur-1/sP.fs]; % support for one tone
bigx = zeros(1,ceil((sP.repdur*sP.nrep+sP.tonedur)*sP.fs)); % the full repetition

for itstep = 1:1:size(bigzt,2) 
    for ifstep = 1:1:size(bigzf,1)
        xtone = sin(2*pi*tx*bigzf(ifstep,itstep)); % change phase if needed
        xtone = psyramp(xtone,sP.rtime,sP.fs);
        % insert spectral shape here if needed
        istart = max(round(bigzt(ifstep,itstep)*sP.fs),1); % we round but no start at idx=0;
        iend = istart+length(xtone)-1;
        bigx(istart:iend)=bigx(istart:iend)+xtone;
    end
end

% Normalization. Not trivial, as we want to balance loudness across freq
% conditions?
x = bigx/20;
%x = bigx/max(abs(bigx))/100*size(freqgrid,1);

if max(abs(x))>0.999
    error('Clipped!')
end
    
% do a bit of zero-padding 
zpad = zeros(1,0.2*sP.fs);
x = [zpad x zpad];
    