function [response, timing, quitProg] = showColorStimulus(display,stimulus, t0)% [response, timing, quitProg] = showColorStimulus(display,stimulus, [time0=getSecs])%% t0 is the time the scan started and the stimulus timing should be% relative to t0. If t0 does not exist it is created at the start of% this program.%% INPIUTS:%	display: display struct. See loadDisplayParams, getDisplaysList.%%	stimulus: stimulus structure. Key fields are 'textures', 'seq',%	'seqtiming', and 'fixSeq'. See color_run for an example of how this is%	created.%%	time0: start time. Defaults to now.%% OUTPUTS:%	response: structure of key presses for the task.%%	timing: actual length of stimulus, in seconds.%%	quitProg: flag indicating whether one of the quit keys ('q' or 'ESC')%	was pressed.%%% This is a version of showScanStimulus, with minor changes made for the% color experiment (mainly, support for the simon task, and multiple escape% keys).%% HISTORY:% 2005.02.23 RFD: ported from showStimulus.% 2005.06.15 SOD: modified for OSX. Use internal clock for timing rather% than framesyncing because getting framerate does not always work. Using% the internal clock will also allow some "catching up" if stimulus is% delayed for whatever reason. Loading mex functions is slow, so this% should be done before callling this program.% input checksif nargin < 2,    help(mfilename);    return;end;if nargin < 3 | isempty(t0),    t0 = GetSecs; % "time 0" to keep timing goingend;% some more checksif ~isfield(stimulus,'textures')    % Generate textures for each image    disp('WARNING: Creating textures before stimulus presentation.');    disp(['         This should be done before calling ' mfilename ' for']);    disp('         accurate timing.  See "makeTextures" for help.');    stimulus = makeTextures(display,stimulus);end;% quit keytry,    quitProgKey = display.quitProgKey;catch,    quitProgKey = [KbName('q') KbName('ESCAPE')];end;% some variablesnFrames = length(stimulus.seq);HideCursor;nGamma = size(stimulus.cmap,3);nImages = length(stimulus.textures);response.keyCode = zeros(length(stimulus.seq),1); % get 1 buttons maxresponse.secs = zeros(size(stimulus.seq));        % timingwaitTime = 0;quitProg = 0;% gofprintf('[%s]:Running. Hit ''q'' or ''escape'' to quit.', mfilename);for frame = 1:nFrames        %--- update display    if stimulus.seq(frame)>0        % put in an image        imgNum = mod(stimulus.seq(frame)-1,nImages)+1;        Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);        drawFixation(display,stimulus.fixSeq(frame));    elseif stimulus.seq(frame)<0        % put in a color table        gammaNum = mod(-stimulus.seq(frame)-1,nGamma)+1;        drawFixation(display,stimulus.fixSeq(frame));        Screen('LoadNormalizedGammaTable', display.windowPtr, stimulus.cmap(:,:,gammaNum));    end;        %--- timing    waitTime = (GetSecs-t0)-stimulus.seqtiming(frame);        %--- get inputs (subject or experimentor)    while(waitTime<0),        % Scan the keyboard for subject response        [ssKeyIsDown,ssSecs,ssKeyCode] = KbCheck(display.devices.keyInputExternal);        if(ssKeyIsDown)            kc = find(ssKeyCode);            response.keyCode(frame) = kc(1);            response.secs(frame)    = ssSecs - t0;        end;        % scan the keyboard for experimentor input        [exKeyIsDown,exSecs,exKeyCode] = KbCheck(display.devices.keyInputInternal);        if exKeyIsDown            if any(exKeyCode(quitProgKey)),                quitProg = 1;                break; % out of while loop            end;        end;                % if there is time release cpu        if(waitTime<-0.02),            WaitSecs(0.01);        end;                % timing        waitTime = (GetSecs-t0)-stimulus.seqtiming(frame);    end;        %--- stop?    if quitProg,        disp(sprintf('[%s]:Quit signal recieved.',mfilename));        break;    end;        %--- update screen    if stimulus.seq(frame) > 0        Screen('Flip',display.windowPtr);    endend;% that's itShowCursor;timing = GetSecs-t0;disp(sprintf('[%s]:Stimulus run time: %f seconds [should be: %f].',mfilename,timing,max(stimulus.seqtiming)));return;