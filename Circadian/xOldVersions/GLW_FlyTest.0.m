function GLW_FlyTest
% GLW_FlyTest  Demonstrates how to drift a grating in GLWindow.
%
% Syntax:
%     GLW_FlyTest
%
% Description:
%     The function makes various changes to stimuli for use in KK's lab to
%     study fly circadian rhythm.

% 11/29/20 dhb  Started.
% 12/03/20 dhb  Getting there.

try
    % Initialize
    close all; win = [];
    
    % Cd to directory containing this function
    [a] = fileparts(mfilename('fullpath'));
    cd(a);
    
    % Control flow parameters.  Set these to true for regular running.
    % Setting to false controls things for development/debugging.
    fullScreen = true;
    regularTiming = true;
    hideCursor = false;
    waitUntilToStartTime = false;
    
    % Path to data files
    dataDir = 'data';
    
    % Set bg RGB.  This may get covered up in the end and have no effect.
    bgRGB = [1 1 1];
    
    % Reversal parameter
    probReverse = 0;
    
    % Static struct
    clear stimStruct
    stimStruct.type = 'drifting';
    stimStruct.name = 'BackgroundBars';
    stimStruct.sfCyclesImage = 2;
    stimStruct.tfHz = 0.5;
    stimStruct.nPhases = 1;
    stimStruct.contrast = 1;
    stimStruct.sine = false;
    stimStruct.sigma = 0.5;
    stimStruct.theta = 0;
    stimStruct.xdist = 0;
    stimStruct.ydist = 0;
    stimStruct.reverseProb = probReverse;
    stimStructs{1} = stimStruct;
    
    % Drifting grating struct
    clear stimStruct;
    stimStruct.type = 'drifting';
    stimStruct.name = 'Bars';
    stimStruct.sfCyclesImage = 2;
    stimStruct.tfHz = 0.25;
    stimStruct.nPhases = 120;
    stimStruct.contrast = 1;
    stimStruct.sine = false;
    stimStruct.sigma = Inf;
    stimStruct.theta = 0;
    stimStruct.xdist = 0;
    stimStruct.ydist = 0;
    stimStruct.reverseProb = probReverse;
    stimStructs{2} = stimStruct;
    
    % Drifting grating struct
    clear stimStruct;
    stimStruct.type = 'looming';
    stimStruct.name = 'BackgroundCircles';
    stimStruct.tfHz = 0.25;
    stimStruct.nSizes = 1;
    stimStruct.contrast = 1;
    stimStruct.reverseProb = probReverse;
    stimStructs{3} = stimStruct;
    
    % Drifting grating struct
    clear stimStruct;
    stimStruct.type = 'looming';
    stimStruct.name = 'Circles';
    stimStruct.tfHz = 0.25;
    stimStruct.nSizes = 240;
    stimStruct.contrast = 1;
    stimStruct.reverseProb = probReverse;
    stimStructs{4} = stimStruct;
    
    % Stimulus cycle time info
    startTime = 15:45;
    stimCycles = [1 2 3 4];
    stimDurationsSecs = [10 10 10 10];
    stimRepeats = 3;
    
    % Open the window
    %
    % And use screen info to get parameters.
    %
    % Choose the last attached screen as our target screen, and figure out its
    % screen dimensions in pixels.  Using these to open the GLWindow keeps
    % the aspect ratio of stuff correct.
    d = mglDescribeDisplays;
    frameRate = d(end).refreshRate;
    screenDims = d(end).screenSizePixel;
    colSize = screenDims(1);
    halfColSize = colSize/2;
    rowSize = screenDims(2);
    maxCircleSize = min([colSize/2 rowSize]) - 5;
    win = GLWindow('SceneDimensions', screenDims,'windowId',length(d),'FullScreen',fullScreen);
    
    % Check that parameters divide things up properly
    if (rem(colSize,4) ~= 0 | rem(rowSize,2) ~= 0)
        error('Col size must be a multiple of 4, and row size a multiple of 2');
    end
    
    % Open up the window and set background   
    win.open;
    win.BackgroundColor = bgRGB;
    win.draw;
    
    % Initialize for each stimulus type actually used
    whichStructsUsed = unique(stimCycles);
    for ss = 1:length(whichStructsUsed)
        fprintf('Initializing stimulus type %d\n',ss);
        stimStruct = stimStructs{whichStructsUsed(ss)};
        switch stimStruct.type
            case 'drifting'
                % Check number of cycles relative to row size
                if (rem(rowSize,2*stimStruct.sfCyclesImage) ~= 0)
                    fprintf('Row size %d, cycles/image %d\n',rowSize,stimStruct.sfCyclesImage);
                    error('Two times cycles/image must evenly divide row size');
                end
                barHeight = rowSize/(2*stimStruct.sfCyclesImage);
                
                % White square
                win.addRectangle([0 0],[colSize rowSize],[stimStruct.contrast stimStruct.contrast stimStruct.contrast],...
                    'Name', sprintf('%sSquare',stimStruct.name));
                win.disableObject(sprintf('%sSquare',stimStruct.name))
                
                % Initialize drifting grating
                if (stimStruct.nPhases == 1)
                    phases = 0;
                else
                    phases = linspace(0,2*barHeight,stimStruct.nPhases);
                end
                for ii = 1:stimStruct.nPhases
                    for cc = 0:stimStruct.sfCyclesImage
                        barPosition = (2*(cc-1))*barHeight+phases(ii)-rowSize/2 + barHeight/2;
                        % fprintf('Row size: %d, barHeight %d, putting black bar %d at offset %0.1f\n',...
                        %    rowSize,barHeight,cc,barPosition);     
                        win.addRectangle([0 barPosition], ...                                              % Center position
                            [colSize barHeight], ...                                                       % Width, Height of oval
                            [1-stimStruct.contrast 1-stimStruct.contrast 1-stimStruct.contrast], ...       % RGB color
                            'Name', sprintf('%sB%d%d',stimStruct.name,cc,ii));
                        barPosition = (2*(cc-1)+1)*barHeight+phases(ii)-rowSize/2 + barHeight/2;
                        % fprintf('\tRow size: %d, barHeight %d, putting white bar at offset %0.1f\n',...
                        %    rowSize,barHeight,barPosition);
                        win.addRectangle([0 barPosition], ...                                              % Center position
                            [colSize barHeight], ...                                                       % Width, Height of oval
                            [stimStruct.contrast stimStruct.contrast stimStruct.contrast], ...       % RGB color
                            'Name', sprintf('%sW%d%d',stimStruct.name,cc,ii));
                        win.disableObject(sprintf('%sB%d%d',stimStruct.name,cc,ii))
                        win.disableObject(sprintf('%sW%d%d',stimStruct.name,cc,ii))     
                    end
                end
                
            case 'looming'                            
                % Compute sizes and create circle of each size, equally
                % space by area.
                fullSize = rowSize*colSize;
                halfArea = fullSize/4;
                
                maxAreaTemp = 2*halfArea; maxSizeTemp = 2*sqrt(maxAreaTemp/pi);
                if (maxSizeTemp > maxCircleSize)
                    maxArea = pi*(maxCircleSize/2)^2;
                else
                    maxArea = maxAreaTemp;
                end
                
                minArea = halfArea-(maxArea-halfArea);
                if (minArea <= 0)
                    error('Min area too small, logic error');
                end
                
                if (stimStruct.nSizes == 1)
                    theAreasL = halfArea; theAreasR = halfArea;
                else
                    theAreasL = [linspace(halfArea,maxArea,stimStruct.nSizes/4) linspace(maxArea,minArea,stimStruct.nSizes/2) linspace(minArea,halfArea,stimStruct.nSizes/4)];
                    theAreasR = [linspace(halfArea,minArea,stimStruct.nSizes/4) linspace(minArea,maxArea,stimStruct.nSizes/2) linspace(maxArea,halfArea,stimStruct.nSizes/4)];
                end
                theSizesL = 2*sqrt(theAreasL/pi);
                theSizesR = 2*sqrt(theAreasR/pi);

                % White square
                win.addRectangle([0 0],[colSize rowSize],[stimStruct.contrast stimStruct.contrast stimStruct.contrast],...
                    'Name', sprintf('%sSquare',stimStruct.name));
                win.disableObject(sprintf('%sSquare',stimStruct.name));

                % Circles of increasing then decreasing size
                for ii = 1:stimStruct.nSizes
                    win.addOval([-halfColSize/2 0], ...                                                   % Center position
                        [theSizesL(ii) theSizesL(ii)], ...                                                % Width, Height of oval
                        [1-stimStruct.contrast 1-stimStruct.contrast 1-stimStruct.contrast], ...          % RGB color
                        'Name', sprintf('%sL%d',stimStruct.name,ii));                                     % Tag associated with this oval.
                    win.disableObject(sprintf('%sL%d',stimStruct.name,ii));
                    win.addOval([halfColSize/2 0], ...                                                     % Center position
                        [theSizesR(ii) theSizesR(ii)], ...                                                % Width, Height of oval
                        [1-stimStruct.contrast 1-stimStruct.contrast 1-stimStruct.contrast], ...          % RGB color
                        'Name', sprintf('%sR%d',stimStruct.name,ii));                               % Tag associated with this oval.
                    win.disableObject(sprintf('%sR%d',stimStruct.name,ii));
                end
                      
            otherwise
                error('Unknown stimulus type specified');
        end
        fprintf('Done with that initialize\n');
    end
     
    % Set up key listener
    ListenChar(2);
    FlushEvents;
    
    % Hide cursor
    if (hideCursor)
        mglDisplayCursor(0);
    end
    
    % Wait until start time
    if (waitUntilToStartTime)
        fprintf('Waiting until specified start time of day, hit space to override ...');
        while (datenum(datestr(now,'HH:MM'),'HH:MM')-datenum(startTime,'HH:MM') < 0)
            % Check whether key was hit, start if ' '
            key = 'z';
            if (CharAvail)
                key = GetChar;
            end
            switch key
                case ' '
                    break;
                otherwise
            end
        end
        fprintf(' done\n');
    end
    fprintf('Starting stimulus cycling\n');
    
    % Cycle through stimulus types until number of repetions reached or someone hits q
    allStimIndex = 1;
    whichStim = 1;
    nStim = length(stimCycles);
    quit = false;
    for rr = 1:(stimRepeats*length(stimCycles));
        % Get current stimulus struct
        stimStruct = stimStructs{stimCycles(whichStim)};
        stimShownList(allStimIndex) = stimCycles(whichStim);
        
        % Set up drawtimes
        whichDraw = 1;
        maxDraws = round(frameRate*(stimDurationsSecs(whichStim)+1));
        drawTimes{allStimIndex} = NaN*ones(1,maxDraws);
        
        % Display.  Assumes already initialized
        startSecs = GetSecs;
        stimShownStartTimes(allStimIndex) = startSecs;
        if (~regularTiming)
            finishSecs = Inf;
        else
            finishSecs = startSecs + stimDurationsSecs(whichStim);
        end
        switch stimStruct.type
            
            case 'drifting'
                % Temporal params
                framesPerPhase = round((frameRate/stimStruct.tfHz)/stimStruct.nPhases);
                fprintf('Running at %d frames per phase, frame rate %d Hz, %0.2f cycles/sec\n', ...
                    framesPerPhase,frameRate,frameRate/(stimStruct.nPhases*framesPerPhase));
                
                % Drift the grating according to the grating's parameters
                whichPhase = 1;
                whichFrame = 1;                
                phaseAdjust = 1;
                oldPhase = stimStruct.nPhases;
                win.enableObject(sprintf('%sSquare',stimStruct.name));
                while (GetSecs < finishSecs)
                    if (whichFrame == 1)
                        for cc = 0:stimStruct.sfCyclesImage
                            win.disableObject(sprintf('%sB%d%d',stimStruct.name,cc,oldPhase));
                            win.disableObject(sprintf('%sW%d%d',stimStruct.name,cc,oldPhase))
                            win.enableObject(sprintf('%sB%d%d',stimStruct.name,cc,whichPhase));
                            win.enableObject(sprintf('%sW%d%d',stimStruct.name,cc,whichPhase))
                        end
                        oldPhase = whichPhase;
                        whichPhase = whichPhase + phaseAdjust;
                        if (whichPhase > stimStruct.nPhases)
                            whichPhase = 1;
                        end
                        if (whichPhase < 1)
                            whichPhase = stimStruct.nPhases;
                        end
                        if (CoinFlip(1,stimStruct.reverseProb))
                            if (phaseAdjust == 1)
                                phaseAdjust = -1;
                            else
                                phaseAdjust = 1;
                            end
                        end
                    end
                    win.draw;
                    drawTimes{allStimIndex}(whichDraw) = GetSecs;
                    whichDraw = whichDraw+1;

                    whichFrame = whichFrame + 1;
                    if (whichFrame > framesPerPhase)
                        whichFrame = 1;
                    end
                    
                    % Check whether key was hit, quit if 'q' then
                    % immediately break out of stimulus show loop
                    key = 'z';
                    if (CharAvail)
                        key = GetChar;
                    end
                    switch key
                        case 'q'
                            stimShownFinishTimes(allStimIndex) = GetSecs;
                            quit = true;
                            break;
                        case ' '
                            break;
                        otherwise
                    end
                end
                
                % Clean
                win.disableObject(sprintf('%sSquare',stimStruct.name));
                for cc = 0:stimStruct.sfCyclesImage
                    win.disableObject(sprintf('%sB%d%d',stimStruct.name,cc,oldPhase));
                    win.disableObject(sprintf('%sW%d%d',stimStruct.name,cc,oldPhase))
                end

                % If we're quiting break out of stimulus loop too
                if (quit)
                    break;
                end
                
            case 'looming'
                % Temporal params
                framesPerSize = round((frameRate/stimStruct.tfHz)/stimStruct.nSizes);
                fprintf('Running at %d frames per size, frame rate %d Hz, %0.2f cycles/sec\n', ...
                    framesPerSize,frameRate,frameRate/(stimStruct.nSizes*framesPerSize));
                
                % Drift the grating according to the grating's parameters
                whichSize = 1;
                whichFrame = 1;
                oldSize = stimStruct.nSizes;
                sizeAdjust = 1;
                win.enableObject(sprintf('%sSquare',stimStruct.name));
                while (GetSecs < finishSecs)
                    if (whichFrame == 1)
                        win.disableObject(sprintf('%sL%d',stimStruct.name,oldSize));
                        win.disableObject(sprintf('%sR%d',stimStruct.name,oldSize));
                        win.enableObject(sprintf('%sL%d',stimStruct.name,whichSize));
                        win.enableObject(sprintf('%sR%d',stimStruct.name,whichSize));
                        
                        oldSize = whichSize;
                        whichSize = whichSize + sizeAdjust;
                        if (whichSize > stimStruct.nSizes)
                            whichSize = 1;
                        end
                        if (whichSize < 1)
                            whichSize = stimStruct.nSizes;
                        end
                        if (CoinFlip(1,stimStruct.reverseProb))
                            if (sizeAdjust == 1)
                                sizeAdjust = -1;
                            else
                                sizeAdjust = 1;
                            end
                        end
                    end
                    win.draw;
                    drawTimes{allStimIndex}(whichDraw) = GetSecs;
                    whichDraw = whichDraw+1;
                    
                    whichFrame = whichFrame + 1;
                    if (whichFrame > framesPerSize)
                        whichFrame = 1;
                    end
                    
                    % Check whether key was hit, quit if 'q' then
                    % immediately break out of stimulus show loop
                    key = 'z';
                    if (CharAvail)
                        key = GetChar;
                    end
                    switch key
                        case 'q'
                            stimShownFinishTimes(allStimIndex) = GetSecs;
                            quit = true;
                            break;
                        case ' '
                            break;
                        otherwise
                    end
                end
                
                % Clean
                win.disableObject(sprintf('%sSquare',stimStruct.name));
                win.disableObject(sprintf('%sL%d',stimStruct.name,oldSize));
                win.disableObject(sprintf('%sR%d',stimStruct.name,oldSize));

                % If we're quiting break out of stimulus loop too
                if (quit)
                    break;
                end
                
            otherwise
                error('Unknown stimulus type specified');
        end
        
        stimShownFinishTimes(allStimIndex) = GetSecs;
        allStimIndex = allStimIndex + 1;
        
        % Quit out of everything?
        if (quit)
            break;
        end
        
        % Cycle stimulus type
        whichStim = whichStim + 1;
        if (whichStim > nStim)
            whichStim = 1;
        end
    end
        
    % We're done, or we quit, clean up and exit
    if (~isempty(win))
        win.close; win = [];
    end
    ListenChar(0);
    mglDisplayCursor(1);
    
    % Save data
    % filename = fullfile(dataDir,['theData_' datestr(now,'yyyy-mm-dd') '_' datestr(now,'HH:MM:SS')]);
    filename = fullfile(dataDir,['theData_Temp']);
    save(filename);

% Error handler
catch e
    if (~isempty(win))
        win.close;
    end
    ListenChar(0);
    mglDisplayCursor(1);
    rethrow(e);
end

%% Old slow code
% Make gabor in each phase
% gaborrgb{ii} = createGabor(rowSize,colSize,stimStruct.contrast,stimStruct.sfCyclesImage,stimStruct.theta,phases(ii),stimStruct.sigma);
% if (~stimStruct.sine)
%     gaborrgb{ii}(gaborrgb{ii} > 0.5) = stimStruct.contrast;
%     gaborrgb{ii}(gaborrgb{ii} < 0.5) = 1-stimStruct.contrast;
% end
% 
% % Convert to RGB
% [calForm1, c1, r1] = ImageToCalFormat(gaborrgb{ii});
% RGB = calForm1;
% gaborRGB{ii} = CalFormatToImage(RGB,c1,r1);
% clear gaborrgb
% 
% % Add the images to the window.
% win.addImage([stimStruct.xdist stimStruct.ydist], [colSize rowSize], gaborRGB{ii}, 'Name',sprintf('%s%d',stimStruct.name,ii));
% win.disableObject(sprintf('%s%d',stimStruct.name,ii));
% clear gaborRGB

% function theGabor = createGabor(rowSize,colSize,contrast,sf,theta,phase,sigma)
% %
% % Input
% %   meshSize: size of meshgrid (and ultimately size of image).
% %       Must be an even integer
% %   contrast: contrast on a 0-1 scale
% %   sf: spatial frequency in cycles/image
% %          cycles/pixel = sf/meshSize
% %   theta: gabor orientation in degrees, clockwise relative to positive x axis.
% %          theta = 0 means horizontal grating
% %   phase: gabor phase in degrees.
% %          phase = 0 means sin phase at center, 90 means cosine phase at center
% %   sigma: standard deviation of the gaussian filter expressed as fraction of image
% %
% % Output
% %   theGabor: the gabor patch as rgb primary (not gamma corrected) image
% 
% 
% % Create a mesh on which to compute the gabor
% if rem(rowSize,2) ~= 0 | rem(colSize,2) ~= 0
%     error('row/col sizes must be an even integers');
% end
% res = [colSize rowSize];
% xCenter=res(1)/2;
% yCenter=res(2)/2;
% [gab_x gab_y] = meshgrid(0:(res(1)-1), 0:(res(2)-1));
% 
% % Compute the oriented sinusoidal grating
% a=cos(deg2rad(theta));
% b=sin(deg2rad(theta));
% sinWave=sin((2*pi/rowSize)*sf*(b*(gab_x - xCenter) - a*(gab_y - yCenter)) + deg2rad(phase));
% 
% % Compute the Gaussian window
% x_factor=-1*(gab_x-xCenter).^2;
% y_factor=-1*(gab_y-yCenter).^2;
% varScale=2*(sigma*rowSize)^2;
% gaussianWindow = exp(x_factor/varScale+y_factor/varScale);
% 
% % Compute gabor.  Numbers here run from -1 to 1.
% theGabor=gaussianWindow.*sinWave;
% 
% % Convert to contrast
% theGabor = (0.5+0.5*contrast*theGabor);
% 
% % Convert single plane to rgb
% theGabor = repmat(theGabor,[1 1 3]);


