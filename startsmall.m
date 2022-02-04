try
    input ('start>>>','s'); % prints to command window
    PsychDefaultSetup(1); % executes the AssertOpenGL & KbName('UnifyKeyNames')
    %Screen('Preference', 'SkipSyncTests', 1); % DO NOT KEEP THIS IN EXPERIMENTAL SCRIPTS!
     
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
    
    % draw the fixation cross in white, set it to the center of our screen
    Screen('DrawLines', windowPtr, allCoords, lineWidthPix, black, [centerX, centerY]);
    % flip to the screen
    fixation_onset= Screen('Flip', windowPtr);
    KbWait;
    
    %% RANDOMIZATION OF TASKS
    task1 = "FR";
    task2 = "VSD";

    TASKS = repelem([task1, task2], [10 20]);
    s_TASKS = Shuffle(TASKS);
    for i=1:length(s_TASKS)
        thiscond = s_TASKS(i);
        if thiscond == "FR"
            % STEP1: LOCATE WHERE THE SOUNDS ARE
            sounds = '/Users/admin/Desktop/m2project/FRstim';
            d=dir(sounds);
            % STEP2: DROP THE EMPTY ITEMS IN THE LIST
            d=d(~ismember({d.name},{'.','..'}));
            % STEP3: RANDOMIZE THE SOUNDS
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
        elseif thiscond == "VSD"
            %get VSD stamped audio file
        end
    end
    
    % STEP1: LOCATE WHERE THE SOUNDS ARE
    sounds = '/Users/admin/Desktop/m2project/stimulipilot';
    d=dir(sounds);
    % STEP2: DROP THE EMPTY ITEMS IN THE LIST
    d=d(~ismember({d.name},{'.','..'}));
    % STEP3: RANDOMIZE THE SOUNDS
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

    % STEP4: CALL THE SOUND
    filename= d(sound_order(1)).name;
    [soundFile,freq] = psychwavread(filename);
    % STEP5: LEARN ITS DURATION
    stimDur(1) = length(soundFile)./freq;

    % STEP6: GET VALUES NECESSARY TO ENTER INTO THE PSYCHPORT FUNCTIONS
    wave = soundFile'; %be careful it is transposed
    nrchannels = size(wave,1);

    % STEP7: MAKE SURE IT HAS 2 CHANNELS
    if nrchannels <2 
        wave = [wave ; wave];
        nrchannels = 2;
    end

    % STEP8: OPEN THE PSYCHPORT AUDIO
    pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);

    % STEP5: FILL THE BUFFER
    PsychPortAudio('FillBuffer',pahandle,wave);

    % STEP6: SETTING THE PARAMETERS FOR PSYCHPORT AUDIO START
    repetitions = 1;
    when = 0; % Start immediately (0 = immediately)
    waitForDeviceStart = 1; % wait for start argument
    
    % STEP7: START PLAYING
    resp = 0; %we will update this in the response loop
    FlushEvents;
    t0 = GetSecs;
    while resp == 0
        [keyIsDown,secs,keyCode] = KbCheck;
        rt=secs-t0;
        if rt<stimDur(1)
            stopTime = t0+secs;
            PsychPortAudio('Start', pahandle, repetitions, when, waitForDeviceStart, stopTime);
            audiostatus = PsychPortAudio('GetStatus', pahandle);
            resp == 1;
        else
            stopTime = t0 + stimDur(1);
            PsychPortAudio('Start', pahandle, repetitions, when, waitForDeviceStart, stopTime);
            audiostatus = PsychPortAudio('GetStatus', pahandle);
            resp == 1;
        end
    end
    PsychPortAudio('Close', pahandle); % Close the audio device
    
    Screen('CloseAll')
catch
    Screen('CloseAll')
    psychrethrow(psychlasterror);
end
