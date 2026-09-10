%% Calculate Inverter Power Module Lifetime and Degradation
% Based on the methodology by M. Thoben et al.

function inverterLifeSummary = calculate_inverter_life(peakItest, EOLrth)
    if nargin < 1, peakItest = 200; end
    if nargin < 2, EOLrth = 0.20; end
    
    addpath(fullfile('Workflow', 'MotorDrive', 'InverterLife'));
    
    eqTest = countEqTest(peakItest);
    dutyLife = getDutyLife(peakItest, EOLrth, eqTest);
    
    inverterLifeSummary.peakItest = peakItest;
    inverterLifeSummary.EOLrth = EOLrth;
    inverterLifeSummary.eqTest = eqTest;
    inverterLifeSummary.dutyLife = dutyLife;
end
