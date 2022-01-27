function toyexperiment(subID)
input ('start>>>','s'); % prints to command window
try
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
    
    % OTHER DEFAULTS
    % Make sure and control this is the case in every computer
    nKey = KbName('n');
    spaceKey = KbName('space');
    escapeKey = KbName('ESCAPE');
    
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
    %% HERE I AM DEFINING KEY VALUES
    % locate where the sound textures are
    sounds = '/Users/admin/Desktop/tonecloudsproject/tonecloudstimulipilot';
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
    % This is our intro text. The '\n' sequence creates a line-feed:
    introText = ['In this experiment you are asked to judge\n' ...
          'whether an example sound texture is continuous\n' ...
          'or is actually a short segment that repeats\n'...
          'Press  [spacebar]  if it is continuous \n' ...
          'Press  [n]  if it is repeating\n' ...
          'You will begin with ' num2str(num_trials) ' training trials\n' ...
          'Now you can press any key to start training\n' ];
    endText = ['Experiment is over :)\n' ...
      'Now you can press any key to end the experiment \n']; 
    % Because we have nothing to do with the cursor
    HideCursor;
    
    %% WE ARE SLOWLY GETTING THERE....
    % Preparing and displaying the welcome screen
    % Draw 'introText', centered in the display window:
    DrawFormattedText(windowPtr, introText, 'center', 'center');
    Screen('Flip', windowPtr);
    [~, keyCode] = KbWait([], 3);
    
    for a=1:length(sound_order)
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
        name = d(sound_order(a)).name;
        [soundFile,freq] = psychwavread(name);
        trial.Stim(a) = convertCharsToStrings(name);
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
        %____ get response and RT ____%
        resp = 0; %we will update this in the response loop
        FlushEvents;
        while resp == 0 %while there is no logged response
            [keyIsDown,secs,keyCode] = KbCheck; %continuously checks the state of the keyboard
            if keyIsDown % if it detects a key has been pressed
                trial.subID(a) = subID;
                if keyCode(spaceKey) % if space key is pressed
                    trial.RT(a) = GetSecs - actualStartTime; %get the current time and subtract offset time to get the RT
                    trial.altRTsecs(a) =  secs - actualStartTime;
                    trial.altRTsecsvbl(a) = secs-vbl;
                    trial.response(a) = 1; %record a repeating response
                    resp=1; %exit loop
                elseif keyCode(nKey) %  if right is pressed
                    trial.RT(a) = GetSecs - actualStartTime; %get the current time and subtract offset time to get the RT
                    trial.altRTsecs(a) =  secs - actualStartTime;
                    trial.altRTsecsvbl(a) = secs-vbl;
                    trial.response(a) = 0; %record a nonrepeating response
                    resp=1; %exit loop
                end
            end
        end
        PsychPortAudio('Close', pahandle); % Close the audio device
    end
    DrawFormattedText(windowPtr, endText, 'center', 'center');
    Screen('Flip', windowPtr);
    KbWait; % wait for a key press
    sca; % close all screens
    T_cell = struct2cell(trial);
    T_fields = fieldnames(trial);
    T = [T_fields, T_cell];
    T_table = cell2table(T);
    data_name = strcat(num2str(subID),'_', 'DATA.csv');
    writetable(T_table, data_name)
catch  
    sca;
    ShowCursor;
    psychrethrow(psychlasterror);
end
end