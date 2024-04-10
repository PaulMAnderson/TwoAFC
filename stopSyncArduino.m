function stopSyncArduino(src, ~)
% Simple function to try and close a serial connection to an Arduino on
% figure close 

% Get BpodSystem Object
global BpodSystem

plugins = BpodSystem.PluginObjects;
if ~isempty(plugins) && isfield(plugins,'SerialConnection')
    try
        write(plugins.SerialConnection,'S','STRING');        
        disp('Arduino Sync Signals Stopped');
    end
    BpodSystem.PluginObjects = [];
end

delete(src);