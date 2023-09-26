function SoftCodeHandler(softCode)
%soft codes 1-10 reserved for odor delivery
%soft code 11-20 reserved for PulsePal sound delivery

global BpodSystem
global TaskParameters

if ~BpodSystem.EmulatorMode
    
    switch softCode
        case 11
            ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamFeedback);
            SendCustomPulseTrain(1,cumsum(randi(9,1,1000))/10000,(rand(1,1000)-.5)*6); % White(?) noise on channel 1+2
            SendCustomPulseTrain(2,cumsum(randi(9,1,1000))/10000,(rand(1,1000)-.5)*6);
            TriggerPulsePal(1,2);
            ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
        case 12
            ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamFeedback);
            SendCustomPulseTrain(2,0:.001:.3,(ones(1,301)*1));  % Beep on channel 1+2
            SendCustomPulseTrain(1,0:.001:.3,(ones(1,301)*1));
            TriggerPulsePal(1,2);
            ProgramPulsePal(BpodSystem.Data.Custom.PulsePalParamStimulus);
            
    end
end

end

