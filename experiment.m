try
close all;
clearvars; %clear variables from memory
sca;
%% HERE I AM DEALING WITH THINGS THAT I DON'T NEED TO CHANGE SO OFTEN
% Call defaults
PsychDefaultSetup(1); % Executes the AssertOpenGL command & KbName('UnifyKeyNames')

% Screen('Preference', 'SkipSyncTests', 2); % DO NOT KEEP THIS IN EXPERIMENTAL SCRIPTS!
rand('seed', sum(100 * clock));

% Setup screens
getScreens   = Screen('Screens'); % Gets the screen numbers (typically 0 = primary and 1 = external)
chosenScreen = max(getScreens);   % Choose which screen to display on (here we chose the external)
rect         = [];                % Full screen

% Get luminance values
white = WhiteIndex(chosenScreen); % 255
black = BlackIndex(chosenScreen); % 0
grey  = white/2;

% Open a psychtoolbox screen
[windowPtr, rect] = Screen('OpenWindow',chosenScreen,grey,rect); % here rect gives us the size of the screen in pixels
[centerX, centerY] = RectCenter(rect); % get the coordinates of the center of the screen

% Get flip and refresh rates
% I did not figure out what is their function
ifi = Screen('GetFlipInterval', windowPtr); % the inter-frame interval (minimum time between two frames)
hertz = FrameRate(windowPtr); % check the refresh rate of the screen

Screen('TextFont', windowPtr, 'Ariel');
Screen('TextSize', windowPtr, 36);

% FIXATION CROSS
% Here we set the size of the arms of our fixation cross
fixCrossDimPix = 40;
% Now we set the coordinates (these are all relative to zero we will let
% the drawing routine center the cross in the center of our monitor for us)
xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
allCoords = [xCoords; yCoords];
% Set the line width for our fixation cross
lineWidthPix = 4;
%% 
%locate where the sound textures are
sounds = '/Users/admin/Desktop/m2project/stimulipilot';
d=dir(sounds);
d=d(~ismember({d.name},{'.','..'}));

% generating a randomized sequence, one cannot hear the same sound
% consecutively
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
% This is our intro text. The '\n' sequence creates a line-feed:
    introText = ['In this experiment you are asked to judge\n' ...
          'whether the sound you hear is continuous\n' ...
          'or is actually a short segment that repeats\n'...
          'Press  [spacebar]  if it is continuous \n' ...
          'Press  [n]  if it is repeating\n' ...
          'You will begin with ' num2str(num_trials) 'trials\n' ...
          'Now you can press any key to start training\n' ];
    endText = ['Experiment is over :)\n' ...
      'Now you can press any key to end the experiment \n']; 

%% Response Matrix
% 1 = response
% 2 = rt
% 3  = correctResponse
respMat = nan(n_trials,2); % tb edit: save response and correct response
%% Setting Keyboard
% OTHER DEFAULTS
% Make sure and control this is the case in every computer
kbDev = 4; 
KbName('UnifyKeyNames');

%Keyboard Info
escapeKey = KbName('ESCAPE');
spaceKey = KbName('space');
nKey = KbName('n');

queueList = zeros(1,256);
queueList([escapeKey,spaceKey,nKey ]) = 1;

KbQueueCreate(kbDev,queueList);

%% Timing, stimulus duration
% Interstimulus interval time in seconds and frames
isiTimeSecs = 0.5;
isiTimeFrames = round(isiTimeSecs / ifi);

% Numer of frames to wait before re-drawing
nextTrialStart = 0;

DrawFormattedText(windowPtr, introText, 'center', 'center');
Screen('Flip', windowPtr);

stimParams = struct([]);


DrawFormattedText(windowPtr, introText, 'center', 'center');
Screen('Flip', windowPtr);
[~, keyCode] = KbWait([], 3);

for a=1:length(sound_order)
    filename= d(sound_order(a)).name;
    [y,fs]= audioread(filename);
    stimDur(a) = length(y)./fs; % time in seconds
    stimFlips(a) = round(stimDur(a)/ifi);
    
    % Draw the fixation cross in white, set it to the center of our screen and
    % set good quality antialiasing
    Screen('DrawLines', windowPtr, allCoords,lineWidthPix, black, [centerX, centerY]);
    
    % Flip to the screen
    Screen('Flip', windowPtr);
    WaitSecs(.1);
    
    % Draw 'questionText', centered in the display window:
    questionText = ['Trial no: ' num2str(a) '\n' ...
      ' \n' ...
      ' \n' ...
      'Was the same sound played multiple times?\n' ...
      ' \n' ...
      'Press  [space bar]  if it is continuous \n' ...
      'Press  [n]  if it is repeating\n'];
  
    DrawFormattedText(windowPtr, questionText, 'center', 'center');
    vbl = Screen('Flip', windowPtr); %vbl is another time stamp showing when exactly you see the question screen

    % Here I am trying to present auditory stimulus at the same time
    [soundFile,freq] = psychwavread(filename);
    trial.Stim(a) = convertCharsToStrings(filename);
    wave = soundFile'; %be careful it is transposed
    nrchannels = size(wave,1);
    if nrchannels <2 
        wave = [wave ; wave];
        nrchannels = 2;
    end
    repetitions = 1;
    PauseTime = 0.5;
    % Start immediately (0 = immediately)
    startCue = 0;    
    % Should we wait for the device to really start (1 = yes)
    % INFO: See help PsychPortAudio
    waitForDeviceStart = 1;  
    
    KbReleaseWait(kbDev);
    KbQueueFlush(kbDev);
    KbQueueStart(kbDev);
    
    while GetSecs <= nextTrialStart
    end
    
    tStart = GetSecs; %to count the RT
    fi = 1;
    pressed = 0;
    doContinue = 0;
    while ~doContinue
        while ~pressed
            % Open Psych-Audio port (buffer), with the follow arguements
            % (1) [] = default sound device
            % (2) 1 = sound playback only
            % (3) 1 = default level of latency
            % (4) Requested frequency in samples per second
            % (5) 2 = stereo output
            pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);
            PsychPortAudio('FillBuffer',pahandle,wave);   
            PsychPortAudio('Start', pahandle, repetitions, startCue, waitForDeviceStart);
            [actualStartTime, ~, ~, ~] = PsychPortAudio('Stop', pahandle, 1, 1);
            
            [pressed, keys] = KbQueueCheck(kbDev);
        end
        
        thisKey = min(find(keys,1,'first'));
        keyTime = min(keys(thisKey));


        if thisKey == escapeKey
            fprintf('User Quit')
            ShowCursor;
            sca;
            return
        elseif thisKey == spaceKey
            response = 1;
            doContinue = 1;
        elseif thisKey == nKey
            response = 0;
            doContinue = 1;
        else
            pressed = 0;
        end
        
        PsychPortAudio('Close', pahandle); % Close the audio device
    end
    
    KbQueueStop(kbDev);

    rt = keyTime - tStart;

    respMat(trial,3) = response;
    respMat(trial,4) = rt;
    
    nextTrialStart = GetSecs+isiTimeSecs;
end
DrawFormattedText(windowPtr, endText, 'center', 'center');
Screen('Flip', windowPtr);
KbWait; % wait for a key press

respMatTable=array2table(respMat);
respMatTable.Properties.VariableNames(1:6) ={'Response','ReactionTime'};
RestrictKeysForKbCheck([])
sca;
% close all;   
catch  
    sca;
    ShowCursor;
    psychrethrow(psychlasterror);
end
