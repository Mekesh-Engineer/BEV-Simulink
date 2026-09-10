%% Analyze PMSM Motor Thermal Durability and Inverter Lifetime
% Main analytical script for extraction, processing, and summary of PMSM thermal metrics.
% Copyright 2025 - 2026 The MathWorks, Inc. / Powertrain Research Group

clc; clear; close all;

%% 1. Load Data Sources
gearBatchFile = fullfile('Workflow', 'MotorDrive', 'GearRatioSelect', 'BatchRunTemp.mat');
inverterTempFile = fullfile('Workflow', 'MotorDrive', 'InverterLife', 'InverterTemp.mat');
testCycleFile = fullfile('Workflow', 'MotorDrive', 'InverterLife', 'TestCycleTemp.mat');

if exist(gearBatchFile, 'file')
    load(gearBatchFile, 'PMSMallTempBatch');
    fprintf('Loaded Gear Ratio and Sump Temperature Batch Results.\n');
end

if exist(inverterTempFile, 'file')
    load(inverterTempFile, 'TigbtJ', 'TdiodeJ', 'allTime', 'cur');
    fprintf('Loaded Inverter Thermal Cycling Results.\n');
end

%% 2. Process Gear Ratio Thermal Limits
gearRatios = [4.2, 5.0, 5.6, 6.2];
testCycles = ["FTP75", "US06"];
T_limit_K = 473.15; % 200°C Insulation Trip Limit

fprintf('\n========================================================================\n');
fprintf('  PMSM THERMAL DURABILITY & GEAR RATIO SELECTION SUMMARY TABLE\n');
fprintf('========================================================================\n');
fprintf('%-12s | %-15s | %-15s | %-12s | %-10s\n', 'Gear Ratio', 'Test Cycle', 'Max Winding T (C)', 'Max Mag T (C)', 'Status');
fprintf('------------------------------------------------------------------------\n');

for i = 1:size(PMSMallTempBatch, 1)
    for j = 1:size(PMSMallTempBatch, 2)
        t = PMSMallTempBatch{i,j,1};
        Tcoil = PMSMallTempBatch{i,j,2};
        Tmag = PMSMallTempBatch{i,j,3};
        
        maxTcoil_C = max(Tcoil) - 273.15;
        maxTmag_C = max(Tmag) - 273.15;
        
        if max(Tcoil) >= T_limit_K
            status = 'FAIL (Trip)';
        else
            status = 'PASS';
        end
        
        fprintf('G = %-8.1f | %-15s | %-17.2f | %-13.2f | %-10s\n', ...
            gearRatios(i), testCycles(j), maxTcoil_C, maxTmag_C, status);
    end
end
fprintf('========================================================================\n');

%% 3. Process Inverter Lifetime
addpath(fullfile('Workflow', 'MotorDrive', 'InverterLife'));
peakItest = 200; % A
EOLrth = 0.20;   % 20% degradation
eqTest = countEqTest(peakItest);
dutyLife = getDutyLife(peakItest, EOLrth, eqTest);

fprintf('\n========================================================================\n');
fprintf('  INVERTER POWER MODULE RELIABILITY & LIFETIME SUMMARY\n');
fprintf('========================================================================\n');
fprintf('Peak Test Current:                      %8.2f A\n', peakItest);
fprintf('End-Of-Life Thermal Resistance Delta:  %8.2f %%\n', EOLrth * 100);
fprintf('Equivalent Test Cycles per Drive Cycle: %8.2f cycles\n', eqTest);
fprintf('Projected Inverter Operating Life:      %8.2e vehicle cycles\n', dutyLife);
fprintf('========================================================================\n');
