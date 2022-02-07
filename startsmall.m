function startsmall(subID, blockID)
    input ('start>>>','s'); % prints to command window
try
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
    %% RANDOMIZE FRstim
    [FRBLOCKS] = organizeFRblocks;
    
    %% RANDOMIZE VSDstim
    [VSDBLOCKS] = organizeVSDblocks;
    
    %% RANDOMIZE TASKS
    taskFR = "FR";
    taskVSD = "VSD";
    
    FRtrialnum = 10;
    VSDtrialnum = 10;

    TASKS = repelem([taskFR, taskVSD], [FRtrialnum VSDtrialnum]);
    s_TASKS = Shuffle(TASKS);
    
    HideCursor;
    %% PRESENTATION OF TRIALS
    
    FRconstant = 1;
    VSDconstant = 1;
    
    for i=1:length(s_TASKS)
        
        block.subID(i) = subID;
        block.blockID(i) = blockID;
        
        WaitSecs(0.5);
        
        block.thiscond(i) = s_TASKS(i);
        
        if block.thiscond(i) == "FR"
        
            % STEP1: GIVE THE TRIAL INFORMATION
            FRinfo = ['Trial no: ' num2str(i) '\n' ...
                  'Free response trial\n' ...
                  ' \n' ...
                  ' \n' ...
                  'Was the same sound played multiple times?\n' ...
                  ' \n' ...
                  'Press  [space bar]  if the answer is yes \n' ...
                  'Press  [n]  if the answer is no\n' ...
                  'You can respond as soon as you decide\n'];
            DrawFormattedText(windowPtr, FRinfo, 'center', 'center');
            tFR(FRconstant) = Screen('Flip', windowPtr); 
            
            % STEP2: CALL THE SOUND
            whichFRstim = FRBLOCKS(blockID).FR(FRconstant);
            [y,freq] = psychwavread(whichFRstim);
            
            % STEP3: LEARN ITS NAME
            block.Stim(i) = convertCharsToStrings(whichFRstim);

            % STEP4: LEARN ITS DURATION
            block.stimDur(i) = length(y)./freq;

            % STEP5: GET VALUES NECESSARY TO ENTER INTO THE PSYCHPORT FUNCTIONS
            wave = y'; %be careful it is transposed
            nrchannels = size(wave,1);

            % STEP6: MAKE SURE IT HAS 2 CHANNELS
            if nrchannels <2 
                wave = [wave ; wave];
                nrchannels = 2;
            end

            % STEP7: OPEN THE PSYCHPORT AUDIO
            pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);

            % STEP8: FILL THE BUFFER
            PsychPortAudio('FillBuffer',pahandle,wave);

            % STEP9: SETTING THE PARAMETERS FOR PSYCHPORT AUDIO START
            repetitions = 1;
            when = 0; % Start immediately (0 = immediately)
            waitForDeviceStart = 1; % wait for start argument

            % STEP10: KEYPRESS WILL STOP THE PLAYBACK
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
                block.RESPONSE(i) = 1;
                block.RT(i) = secs-t1;
            elseif keyCode(nKey)
                block.RESPONSE(i) = 0;
                block.RT(i) = secs-t1;
            end

            % STEP11: STOP THE AUDIO 
            [startTime,~,~, stopTime] = PsychPortAudio('Stop', pahandle);

            % STEP12: CLOSE THE AUDIO DEVICE
            PsychPortAudio('Close', pahandle);
            FRconstant = FRconstant + 1;
        
        elseif block.thiscond(i) == "VSD"

            % STEP1: GIVE THE TRIAL INFORMATION
            VSDinfo = ['Trial no: ' num2str(i) '\n' ...
                  'Varied stimulus duration trial\n' ...
                  ' \n' ...
                  ' \n' ...
                  'Was the same sound played multiple times?\n' ...
                  ' \n' ...
                  'Press  [space bar]  if the answer is yes \n' ...
                  'Press  [n]  if the answer is no\n' ...
                  'You can respond after the stimulus completely finishes \n'];
            DrawFormattedText(windowPtr, VSDinfo, 'center', 'center');
            tVSD(VSDconstant) = Screen('Flip', windowPtr);
            
            % STEP2: CALL THE SOUND
            whichVSDstim= VSDBLOCKS(blockID).VSD(VSDconstant);
            [y,freq] = psychwavread(whichVSDstim);
            
            % STEP3: LEARN ITS NAME
            block.Stim(i) = convertCharsToStrings(whichVSDstim);
            
            % STEP4: LEARN ITS DURATION
            block.stimDur(i) = length(y)./freq;

            % STEP5: GET VALUES NECESSARY TO ENTER INTO THE PSYCHPORT FUNCTIONS
            wave = y'; %be careful it is transposed
            nrchannels = size(wave,1);

            % STEP6: MAKE SURE IT HAS 2 CHANNELS
            if nrchannels <2 
                wave = [wave ; wave];
                nrchannels = 2;
            end

            % STEP7: OPEN THE PSYCHPORT AUDIO
            pahandle = PsychPortAudio('Open', [], [], 0, freq, nrchannels);

            % STEP8: FILL THE BUFFER
            PsychPortAudio('FillBuffer',pahandle,wave);

            % STEP9: SETTING THE PARAMETERS FOR PSYCHPORT AUDIO START
            repetitions = 1;
            when = 0; % Start immediately (0 = immediately)
            waitForDeviceStart = 1; % wait for start argument

            % STEP10: WAIT TILL SOUND IS PLAYED
            t1 = PsychPortAudio('Start', pahandle, repetitions, when, waitForDeviceStart);
            [actualStartTime, ~, ~, ~] = PsychPortAudio('Stop', pahandle, 1, 1);

    
            resp = 0; %we will update this in the response loop
            FlushEvents;
            while resp == 0 %while there is no logged response
                [keyIsDown,secs,keyCode] = KbCheck; %continuously checks the state of the keyboard
                if keyCode(spaceKey) % if space key is pressed
                    block.RT(i) = secs - t1; %get the current time and subtract offset time to get the RT
                    block.RESPONSE(i) = 1; %record a repeating response
                    resp = 1; %exit loop
                elseif keyCode(nKey) %  if right is pressed
                    block.RT(i) = secs - t1; %get the current time and subtract offset time to get the RT
                    block.RESPONSE(i) = 0; %record a repeating response
                    resp=1; %exit loop
                end
            end

            % STEP11: CLOSE THE AUDIO DEVICE
            PsychPortAudio('Close', pahandle);
            VSDconstant = VSDconstant + 1;
        end   
    end
    Screen('CloseAll')
    
    B_cell = struct2cell(block);
    B_fields = fieldnames(block);
    B = [B_fields, B_cell];
    B_table = cell2table(B);
    data_name = strcat(num2str(subID),'_',num2str(blockID),'_DATA.csv');
    writetable(B_table, data_name)
catch
    Screen('CloseAll')
    psychrethrow(psychlasterror);
end
end
