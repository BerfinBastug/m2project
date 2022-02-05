try
    input ('start>>>','s'); % prints to command window
    
    PsychDefaultSetup(1); % executes the AssertOpenGL & KbName('UnifyKeyNames')
    
    rand('seed', sum(100 * clock));
    
    %% PSYCHTOOLBOX SCREEN SETUPS
    %STEP1
    getScreens   = Screen('Screens'); % Gets the screen numbers (typically 0 = primary and 1 = external)
    chosenScreen = max(getScreens);   % Choose which screen to display on (here we chose the external)
    rect         = [];                % Full screen
    
    %STEP2: Get luminance values
    white = WhiteIndex(chosenScreen); % 255
    black = BlackIndex(chosenScreen); % 0
    grey  = white/2;
    
    %STEP3: Open a psychtoolbox screen
    [windowPtr, rect] = Screen('OpenWindow',chosenScreen,grey,rect); % here rect gives us the size of the screen in pixels
    [centerX, centerY] = RectCenter(rect); % get the coordinates of the center of the screen
    
    %STEP4: Get flip and refresh rates
    ifi = Screen('GetFlipInterval', windowPtr); % the inter-frame interval (minimum time between two frames)
    hertz = FrameRate(windowPtr); % check the refresh rate of the screen
    
    %STEP5: Font setups
    Screen('TextFont', windowPtr, 'Ariel');
    Screen('TextSize', windowPtr, 36);
    
    %STEP6: Keyboard setups
    nKey = KbName('n');
    spaceKey = KbName('space');
    escapeKey = KbName('ESCAPE');
    
    %STEP7: Fixation cross setups
    fixCrossDimPix = 40; % Here we set the size of the arms of our fixation cross
    
    % Now we set the coordinates (these are all relative to zero we will let
    % the drawing routine center the cross in the center of our monitor for us)
    xCoords = [-fixCrossDimPix fixCrossDimPix 0 0];
    yCoords = [0 0 -fixCrossDimPix fixCrossDimPix];
    allCoords = [xCoords; yCoords];
    
    lineWidthPix = 4; % Set the line width for our fixation cross
    
    %STEP8: TRIAL NAMES
    FRtrialinfo = ['FREE RESPONSE TRIAL\n' ...
               'Respond as soon as possible \n'];
    VSDtrialinfo =['VARIED STIMULUS DURATION TRIAL\n' ...
               'Respond when the sound finishes \n'];     
    %% RANDOMIZE TASKS
    
    task1 = "FR";
    task2 = "VSD";

    TASKS = repelem([task1, task2], [3 3]);
    s_TASKS = Shuffle(TASKS);
    
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
    
    %% RANDOMIZE VSDstim
    % STEP1: LOCATE WHERE THE SOUNDS ARE
    VSDstimDir = '/Users/admin/Desktop/m2project/VSDstim';
    VSDstims=dir(VSDstimDir);
    VSDstim_list = {VSDstims.name};

    % STEP2: DROP THE EMPTY ITEMS IN THE LIST
    VSDstim_list = VSDstim_list(~ismember(VSDstim_list,{'.','..'}));
    VSDstim_list = convertCharsToStrings(VSDstim_list);

    % STEP3: RANDOMIZE THE SOUNDS
    VSDnum_stims = length(VSDstim_list);
    VSDstim_indices = 1:VSDnum_stims;
    VSDnum_repeats = 1;
    VSDnum_trials = VSDnum_stims * VSDnum_repeats;
    VSDrand_stim_order = nan(1, VSDnum_trials);

    for k = 1:VSDnum_stims:VSDnum_trials
        subsequence = Shuffle(VSDstim_indices);
        VSDrand_stim_order(k:k+(VSDnum_stims-1)) = subsequence;
        % swap the first value of this subsequence if it repeats the previous
        if k > 1 && (VSDrand_stim_order(k) == VSDrand_stim_order(k-1))
            VSDrand_stim_order([k, k+1]) = VSDrand_stim_order([k+1, k]);
        end
    end
    %% PRESENTATION OF TRIALS
    
    for i=1:length(s_TASKS)
        WaitSecs(0.3);
        
        thiscond = s_TASKS(i);
        if thiscond == "FR"
            
            % STEP1: LOCATE WHERE THE SOUNDS ARE
            FRsounds = '/Users/admin/Desktop/m2project/FRstim';
            d=dir(FRsounds);
            
            % STEP2: DROP THE EMPTY ITEMS IN THE LIST
            d=d(~ismember({d.name},{'.','..'}));
            
            % STEP3: RANDOMIZE THE SOUNDS
            num_sounds = length(d);
            sound_options = 1:num_sounds;
            FRnum_repeats = 1;
            FRnum_trials = num_sounds * FRnum_repeats;
            sound_order = nan(1, FRnum_trials);
            
            for k = 1:num_sounds:FRnum_trials
                subsequence = Shuffle(sound_options);
                sound_order(k:k+(num_sounds-1)) = subsequence;
                % swap the first value of this subsequence if it repeats the previous
                if k > 1 && (sound_order(k) == sound_order(k-1))
                    sound_order([k, k+1]) = sound_order([k+1, k]);
                end
            end
            
            for a=1:length(sound_order)
                
                % STEP4: CALL THE SOUND
                DrawFormattedText(windowPtr, FRtrialinfo, 'center', 'center');
                t_fr_trialinfo(a) = Screen('Flip', windowPtr); 
                FRfilename= d(sound_order(a)).name;
                [FRsoundFile,FRfreq] = psychwavread(FRfilename);

                % STEP5: LEARN ITS DURATION
                stimDurFR(a) = length(FRsoundFile)./FRfreq;

                % STEP6: GET VALUES NECESSARY TO ENTER INTO THE PSYCHPORT FUNCTIONS
                wave = FRsoundFile'; %be careful it is transposed
                nrchannels = size(wave,1);

                % STEP7: MAKE SURE IT HAS 2 CHANNELS
                if nrchannels <2 
                    wave = [wave ; wave];
                    nrchannels = 2;
                end

                % STEP8: OPEN THE PSYCHPORT AUDIO
                pahandle = PsychPortAudio('Open', [], [], 0, FRfreq, nrchannels);

                % STEP9: FILL THE BUFFER
                PsychPortAudio('FillBuffer',pahandle,wave);

                % STEP10: SETTING THE PARAMETERS FOR PSYCHPORT AUDIO START
                repetitions = 1;
                when = 0; % Start immediately (0 = immediately)
                waitForDeviceStart = 1; % wait for start argument

                % STEP11: KEYPRESS WILL STOP THE PLAYBACK
                t1 = PsychPortAudio('Start', pahandle, repetitions, when, waitForDeviceStart);

                KbReleaseWait; % Wait for release of all keys on keyboard:

                lastSample = 0;
                lastTime = t1;

                while ~KbCheck % Stay in a little loop until keypress:
                    s = PsychPortAudio('GetStatus', pahandle);
                    realSampleRate = (s.ElapsedOutSamples - lastSample) / (s.CurrentStreamTime - lastTime);
                    tHost = s.CurrentStreamTime;
                end

                [~,secs,keyCode] = KbCheck;
                if keyCode(spaceKey)
                    RESPONSE_FR(a) = 1;
                    RT_FR(a) = secs-t1;
                elseif keyCode(nKey)
                    RESPONSE_FR(a) = 0;
                    RT_FR(a) = secs-t1;
                end

                % STEP12: STOP THE AUDIO 
                [startTime,~,~, stopTime] = PsychPortAudio('Stop', pahandle);

                % STEP13: CLOSE THE AUDIO DEVICE
                PsychPortAudio('Close', pahandle);
            end
            
        elseif thiscond == "VSD"
            % STEP1: LOCATE WHERE THE SOUNDS ARE
            VSDsounds = '/Users/admin/Desktop/m2project/VSDstim';
            d=dir(VSDsounds);

            % STEP2: DROP THE EMPTY ITEMS IN THE LIST
            d=d(~ismember({d.name},{'.','..'}));

            % STEP3: RANDOMIZE THE SOUNDS
            num_sounds = length(d);
            sound_options = 1:num_sounds;
            FRnum_repeats = 1;
            FRnum_trials = num_sounds * FRnum_repeats;
            sound_order = nan(1, FRnum_trials);

            for k = 1:num_sounds:FRnum_trials
                subsequence = Shuffle(sound_options);
                sound_order(k:k+(num_sounds-1)) = subsequence;
                % swap the first value of this subsequence if it repeats the previous
                if k > 1 && (sound_order(k) == sound_order(k-1))
                    sound_order([k, k+1]) = sound_order([k+1, k]);
                end
            end

            for a=1:length(sound_order)

            % STEP4: CALL THE SOUND
            DrawFormattedText(windowPtr, VSDtrialinfo, 'center', 'center');
            t_vsd_trialinfo(a) = Screen('Flip', windowPtr); 
            VSDfilename= d(sound_order(a)).name;
            [VSDsoundFile,VSDfreq] = psychwavread(VSDfilename);

            % STEP5: LEARN ITS DURATION
            stimDurVSD(a) = length(VSDsoundFile)./VSDfreq;

            % STEP6: GET VALUES NECESSARY TO ENTER INTO THE PSYCHPORT FUNCTIONS
            wave = VSDsoundFile'; %be careful it is transposed
            nrchannels = size(wave,1);

            % STEP7: MAKE SURE IT HAS 2 CHANNELS
            if nrchannels <2 
                wave = [wave ; wave];
                nrchannels = 2;
            end

            % STEP8: OPEN THE PSYCHPORT AUDIO
            pahandle = PsychPortAudio('Open', [], [], 0, VSDfreq, nrchannels);

            % STEP9: FILL THE BUFFER
            PsychPortAudio('FillBuffer',pahandle,wave);

            % STEP10: SETTING THE PARAMETERS FOR PSYCHPORT AUDIO START
            repetitions = 1;
            when = 0; % Start immediately (0 = immediately)
            waitForDeviceStart = 1; % wait for start argument

            % STEP11: WAIT TILL SOUND IS PLAYED
            t1 = PsychPortAudio('Start', pahandle, repetitions, when, waitForDeviceStart);
            [actualStartTime, ~, ~, ~] = PsychPortAudio('Stop', pahandle, 1, 1);

    
            resp = 0; %we will update this in the response loop
            FlushEvents;
            while resp == 0 %while there is no logged response
                [keyIsDown,secs,keyCode] = KbCheck; %continuously checks the state of the keyboard
                if keyCode(spaceKey) % if space key is pressed
                    RT(a) = secs - t1; %get the current time and subtract offset time to get the RT
                    response(a) = 1; %record a repeating response
                    resp = 1; %exit loop
                elseif keyCode(nKey) %  if right is pressed
                    RT(a) = secs - t1; %get the current time and subtract offset time to get the RT
                    response(a) = 0; %record a repeating response
                    resp=1; %exit loop
                end
            end

            % STEP12: CLOSE THE AUDIO DEVICE
            PsychPortAudio('Close', pahandle);
            end
        end
    end
    Screen('CloseAll')
catch
    Screen('CloseAll')
    psychrethrow(psychlasterror);
end
