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
    %% RANDOMIZATION OF TRIALS
    
    task1 = "FR";
    task2 = "VSD";

    TASKS = repelem([task1, task2], [10 20]);
    s_TASKS = Shuffle(TASKS);
    %% PRESENTATION OF TRIALS
    
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
            
            for a=1:length(sound_order)
                
                % STEP4: CALL THE SOUND
                Screen('DrawLines', windowPtr, allCoords,lineWidthPix, black, [centerX, centerY]); %Draw the fixation cross
                fixCross(a)= Screen('Flip', windowPtr);
                filename= d(sound_order(a)).name;
                [soundFile,freq] = psychwavread(filename);

                % STEP5: LEARN ITS DURATION
                stimDurFR(a) = length(soundFile)./freq;

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
            sounds = '/Users/admin/Desktop/m2project/VSDstim';
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
            
            for a=1:length(sound_order)
                
                % STEP4: CALL THE SOUND
                Screen('DrawLines', windowPtr, allCoords,lineWidthPix, black, [centerX, centerY]); %Draw the fixation cross
                fixCross(a)= Screen('Flip', windowPtr);
                filename= d(sound_order(a)).name;
                [soundFile,freq] = psychwavread(filename);

                % STEP5: LEARN ITS DURATION
                stimDurVSD(a) = length(soundFile)./freq;

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

                % STEP9: FILL THE BUFFER
                PsychPortAudio('FillBuffer',pahandle,wave);

                % STEP10: SETTING THE PARAMETERS FOR PSYCHPORT AUDIO START
                repetitions = 1;
                when = 0; % Start immediately (0 = immediately)
                waitForDeviceStart = 1; % wait for start argument

                % STEP11: WAIT TILL SOUND IS PLAYED
                t1 = PsychPortAudio('Start', pahandle, repetitions, when, waitForDeviceStart);
                [actualStartTime, ~, ~, ~] = PsychPortAudio('Stop', pahandle, 1, 1);
                
                %____ get response and RT ____%
                resp = 0; %we will update this in the response loop
                FlushEvents;
                while resp == 0 %while there is no logged response
                    [keyIsDown,secs,keyCode] = KbCheck; %continuously checks the state of the keyboard
                    if keyIsDown % if it detects a key has been pressed
                        if keyCode(spaceKey) % if space key is pressed
                            RT_VSD(a) = secs - actualStartTime; %get the current time and subtract offset time to get the RT
                            RESPONSE_VSD(a) = 1; %record a repeating response
                            resp=1; %exit loop
                        elseif keyCode(nKey) %  if right is pressed
                            RT_VSD(a) = secs - actualStartTime; %get the current time and subtract offset time to get the RT
                            RESPONSE_VSD(a) = 0; %record a nonrepeating response
                            resp=1; %exit loop
                        end
                    end
                end

                KbReleaseWait; % Wait for release of all keys on keyboard:

                lastSample = 0;
                lastTime = t1;

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
