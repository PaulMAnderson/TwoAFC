function generateAuditoryStimuli(nNewTrials, auditoryAlpha, leftBias)
% This function generates new trial stimuli and updates the various data
% and GUI fields as needed

%% Load global variables
global BpodSystem
global TaskParameters

%% Get the left bias, or set to no bias

if nargin < 3
    try
        leftBias = TaskParameters.GUI.FutureLeftBias;
    catch
        leftBias = 0.5;
    end
end

%% Calculate the beta ratio

BetaRatio = leftBias / (1 - leftBias);

%make a,b symmetric around auditoryAlpha to make B symmetric
BetaA =  (2 * auditoryAlpha * BetaRatio) / (1 + BetaRatio);
BetaB = (auditoryAlpha - BetaA) + auditoryAlpha;

%% Generate Stimuli

% Need to account for very first trials where we don't have evidenceStrength
% calculated yet
if isfield(BpodSystem.Data.Custom,'evidenceStrength')
    latestTrial = numel(BpodSystem.Data.Custom.evidenceStrength);
else
    latestTrial = numel(BpodSystem.Data.Custom.trialNumber);
end

for trialNum = 1:nNewTrials

    % Get the trial index
    trialIdx = latestTrial + trialNum;

    % Save the alpha
    BpodSystem.Data.Custom.effectiveAlpha(trialIdx) = auditoryAlpha;

    % Check for deliberate 50-50 trial
    if rand(1,1) < TaskParameters.GUI.Proportion50Fifty && trialIdx > TaskParameters.GUI.StartEasyTrials
        BpodSystem.Data.Custom.omega(trialIdx) = 0.5;
    else
        BpodSystem.Data.Custom.omega(trialIdx) = betarnd(max(0,BetaA),max(0,BetaB),1,1); %prevent negative parameters
    end

    %% Calculate click rates
    BpodSystem.Data.Custom.clickRateLeft(trialIdx) = ...
        round(BpodSystem.Data.Custom.omega(trialIdx)*TaskParameters.GUI.SumRates);

    BpodSystem.Data.Custom.clickRateRight(trialIdx) = ...
        round((1-BpodSystem.Data.Custom.omega(trialIdx))*TaskParameters.GUI.SumRates);

    BpodSystem.Data.Custom.clickTrainLeft{trialIdx} = ...
        GeneratePoissonClickTrain(BpodSystem.Data.Custom.clickRateLeft(trialIdx), ...
        TaskParameters.GUI.AuditoryStimulusTime);

    BpodSystem.Data.Custom.clickTrainRight{trialIdx} = ...
        GeneratePoissonClickTrain(BpodSystem.Data.Custom.clickRateRight(trialIdx), ...
        TaskParameters.GUI.AuditoryStimulusTime);

    %% Correct left/right click train - Set the first click to be equal

    if ~isempty(BpodSystem.Data.Custom.clickTrainLeft{trialIdx}) && ...
       ~isempty(BpodSystem.Data.Custom.clickTrainRight{trialIdx})

        BpodSystem.Data.Custom.clickTrainLeft{trialIdx}(1) = ...
            min(BpodSystem.Data.Custom.clickTrainLeft{trialIdx}(1), ...
                BpodSystem.Data.Custom.clickTrainRight{trialIdx}(1));

        BpodSystem.Data.Custom.clickTrainRight{trialIdx}(1) = ...
            min(BpodSystem.Data.Custom.clickTrainLeft{trialIdx}(1), ...
                BpodSystem.Data.Custom.clickTrainRight{trialIdx}(1));

    elseif isempty(BpodSystem.Data.Custom.clickTrainLeft{trialIdx}) && ...
           ~isempty(BpodSystem.Data.Custom.clickTrainRight{trialIdx})

        BpodSystem.Data.Custom.clickTrainLeft{trialIdx}(1) = ...
            BpodSystem.Data.Custom.clickTrainRight{trialIdx}(1);

    elseif ~isempty(BpodSystem.Data.Custom.clickTrainLeft{trialIdx}) && ...
           isempty(BpodSystem.Data.Custom.clickTrainRight{trialIdx})

        BpodSystem.Data.Custom.clickTrainRight{trialIdx}(1) = ...
            BpodSystem.Data.Custom.clickTrainLeft{trialIdx}(1);

    else
        % Both trains are empty: generate fallback single-click trains
        BpodSystem.Data.Custom.clickTrainLeft{trialIdx} = ...
            round(1/BpodSystem.Data.Custom.clickRateLeft(trialIdx)*10000)/10000;
        BpodSystem.Data.Custom.clickTrainRight{trialIdx} = ...
            round(1/BpodSystem.Data.Custom.clickRateRight(trialIdx)*10000)/10000;
    end

    nLeft  = length(BpodSystem.Data.Custom.clickTrainLeft{trialIdx});
    nRight = length(BpodSystem.Data.Custom.clickTrainRight{trialIdx});

    if nLeft > nRight
        BpodSystem.Data.Custom.sideProgrammed{trialIdx} = 'left';
    elseif nRight > nLeft
        BpodSystem.Data.Custom.sideProgrammed{trialIdx} = 'right';
    else
        BpodSystem.Data.Custom.sideProgrammed{trialIdx} = 'none';
    end

    % evidenceStrength: positive = right-dominant (canonical convention)
    if (nLeft + nRight) > 0
        BpodSystem.Data.Custom.evidenceStrength(trialIdx) = ...
            (nRight - nLeft) / (nRight + nLeft);
    else
        BpodSystem.Data.Custom.evidenceStrength(trialIdx) = 0;
    end

end


end % End function generateAuditoryStimuli


%% Sub functions
function ClickTimes = GeneratePoissonClickTrain(ClickRate, Duration)
% ClickTimes = click time points in us
% ClickRate = mean click rate in Hz
% Duration = click train duration in seconds

SamplingRate = 1000000;
nSamples = Duration*SamplingRate;
ExponentialMean = round((1/ClickRate)*SamplingRate); % Calculates mean of exponential distribution
InvertedMean = ExponentialMean*-1;
PreallocateSize = round(ClickRate*Duration*2);
ClickTimes = zeros(1,PreallocateSize);
Pos = 0;
Time = 0;
Building = 1;
while Building == 1
    Pos = Pos + 1;
    Interval = InvertedMean*log(rand)+100; % +100 ensures no duplicate timestamps at PulsePal resolution of 100us
    Time = Time + Interval;
    if Time > nSamples
        Building = 0;
    else
        ClickTimes(Pos) = Time;
    end
end
ClickTimes = ClickTimes(1:Pos-1); % Trim click train preallocation to length
ClickTimes = round(ClickTimes/100)/10000; % Make clicks multiples of 100us - necessary for pulse time programming

end %  function GeneratePoissonClickTrain
