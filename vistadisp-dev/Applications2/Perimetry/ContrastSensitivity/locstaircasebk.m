function [thresholds,retflag]=locstaircase(positions,initdirect,testParams,stimParams)% This routine calculate contrast threshold for every location by finding 4 changes % of directions in observer answers and averaging the correspondent contrasts.%%Inputs :%positions = [vertical_i, horizontal_i] locations to evaluate%initdirect = 0 decrease contrast in next trial, 1 increase contrast in next trial%testParams  = See perimetry.m%stimParams  = See perimetry.m%%Outputs%thresholds = [ contrast_threshold_i] contrast threshold for each location%retflag   = 0 this routine completed execution, 1 this routine was terminated by user or by max. trials  % % 4 April 2004 % Claudioglobal keycounter global hrmatrixglobal displayglobal answercatchglobal ncatchretflag=0;scale=testParams.contrastscale;zscale =size(scale,2);catchcount=0;%For each location Initialize variables for n=1:size(positions,1)	stop(n) =0;	counter(n)=0;	counterdir(n)=initdirect; 	thresh(n,:)=zeros(1,4);	outofrange(n)=0;	    if(initdirect==0)	    contrastindex(n)= (testParams.medcontrastindex-1);        else	    contrastindex(n)= (testParams.medcontrastindex+1);		endend% Do for all locations until 4 changes of direction are foundwhile(sum(stop)<size(stop,2))	for n=1:size(positions,1)    if(stop(n)==0)	stimParams.position= positions(n,:);	stimParams.contrast=scale(contrastindex(n));   	[trial, data] = Perimtrial(display, stimParams,testParams);    runPriority = 0;    eventNum = 1:size(trial,1);    material = trial{eventNum,2};	t = soundFreqSweep(100, 500, .1);	cleankeybbuff;		sound(t);    showStimulus(display,material.stimulus,runPriority);	catchcount=catchcount+1;	answer=getchar;	keycounter=keycounter+1;	%Stop if required			if (answer==testParams.keystop) | ( size(hrmatrix,1) > testParams.maxtrials )			  	retflag=1;				return		     end		if answer==testParams.keyyes		hrmatrix(size(hrmatrix,1)+1,:)=[stimParams.position stimParams.contrast 1];		disp([stimParams.position stimParams.contrast 1]);			if counterdir(n)==1 					thresh(n,counter(n)+1)=stimParams.contrast;					counter(n)=counter(n)+1;					counterdir(n)=0;					if counter(n)==4						stop(n)=1;					end			end				if contrastindex(n) <= 1			stop(n)=1;			thresholds(n)=scale(1);			outofrange(n)=1;		end		contrastindex(n) = contrastindex(n)-1;	end	if answer==testParams.keyno		hrmatrix(size(hrmatrix,1)+1,:)=[stimParams.position stimParams.contrast 0];		disp([stimParams.position stimParams.contrast 0]);				if counterdir(n)==0 					thresh(n,counter(n)+1)=stimParams.contrast;					%disp(contrast);					counter(n)=counter(n)+1;					counterdir(n)=1;			    	if counter(n)==4					stop(n)=1;				    end            	end		if contrastindex(n) >= zscale			stop(n) =1;			thresholds(n) = scale(zscale);			outofrange(n)=1;		end		contrastindex(n) = contrastindex(n)+1;		endpause(1)catchtrial;end % of inner ifend %of for next below big-whileend % of big-while	%For each location calculate threshold averagefor n=1:size(positions,1)if (outofrange(n)==0)thresholds(n)= sum(thresh(n,:))/size(thresh(n,:),2);endend % 