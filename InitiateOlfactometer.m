function InitiateOlfactometer(iTrial)
global BpodSystem
global TaskParameters
if ~BpodSystem.Data.Custom.AuditoryTrial(iTrial) && ~BpodSystem.Data.Custom.OlfactometerStartup
    if ~BpodSystem.EmulatorMode
        BpodSystem.Data.Custom.OlfIp = FindOlfactometer;
        if isempty(BpodSystem.Data.Custom.OlfIp)
            error('Bpod:Olf2AFC:OlfComFail','Failed to connect to olfactometer')
        end
        OdorA_flow = BpodSystem.Data.Custom.OdorFracA(iTrial);
        OdorB_flow = 100 - OdorA_flow;
        SetBankFlowRate(BpodSystem.Data.Custom.OlfIp, TaskParameters.GUI.OdorA_bank, OdorA_flow)
        SetBankFlowRate(BpodSystem.Data.Custom.OlfIp, TaskParameters.GUI.OdorB_bank, OdorB_flow)
        clear Odor* flow*
    else
        BpodSystem.Data.Custom.OlfIp = '198.162.0.0';
    end
    BpodSystem.Data.Custom.OlfactometerStartup = true;
end