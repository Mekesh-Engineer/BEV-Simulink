%% analyze_results.m - Comprehensive BEV Simulation Results Analyzer
% Analyzes simulated energy consumption, subsystem loss breakdown, and range ratings
% across NEDC, WLTC Class 3, and EPA regulatory cycles under multiple environmental scenarios.
%
% Copyright 2022 - 2026 The MathWorks, Inc. / BEV Project Team

clear; clc; close all;

%% 1. Locate and Load Pre-Computed Simulation Datasets
rootDir = fileparts(fileparts(mfilename('fullpath'))); % Electric-Vehicle-Simscape root
dataPath = fullfile(rootDir, 'Workflow', 'Vehicle', 'RangeEstimation');

nedcFile = fullfile(dataPath, 'NEDCrangeData.mat');
wltcFile = fullfile(dataPath, 'WLTCrangeData.mat');
epaFile  = fullfile(dataPath, 'EPArangedata.mat');

if ~exist(nedcFile, 'file') || ~exist(wltcFile, 'file') || ~exist(epaFile, 'file')
    error('Simulation dataset (.mat) files not found in Workflow/Vehicle/RangeEstimation.');
end

load(nedcFile);
load(wltcFile);
load(epaFile);

fprintf('========================================================================================\n');
fprintf('                   BATTERY ELECTRIC VEHICLE SIMULATION RESULTS ANALYSIS                  \n');
fprintf('========================================================================================\n\n');

%% 2. Process NEDC Simulation Results
fprintf('--- 1. NEDC (New European Driving Cycle - 1180 s) ---\n');
nedc_scenarios = {'Low Temp (-10°C), AC ON', 'Low Temp (-10°C), AC OFF', ...
                  'High Temp (+35°C), AC ON', 'High Temp (+35°C), AC OFF'};
nedc_structs   = {NEDCloTpAC, NEDCloTpNoAC, NEDChiTpAC, NEDChiTpNoAC};

fprintf('%-30s | %-10s | %-12s | %-12s | %-10s | %-10s | %-12s\n', ...
    'Scenario', 'Dist (km)', 'Energy (Wh)', 'EM1+EM2 (Wh)', 'HVAC (Wh)', 'Aux (Wh)', 'Range (km)');
fprintf('%s\n', repmat('-', 1, 105));

for i = 1:4
    s = nedc_structs{i};
    em_total = s.EM1energy + s.EM2energy;
    fprintf('%-30s | %10.2f | %12.2f | %12.2f | %10.2f | %10.2f | %12.2f\n', ...
        nedc_scenarios{i}, s.Distance, s.EnergyCons, em_total, s.HVACenergy, s.AuxEnergy, s.RangeRating);
end
fprintf('\n');

%% 3. Process WLTC Class 3 Simulation Results
fprintf('--- 2. WLTC Class 3 (Worldwide Harmonized Light Vehicles Test Cycle - 1800 s) ---\n');
wltc_scenarios = {'Low Temp (-10°C), AC ON', 'Low Temp (-10°C), AC OFF', ...
                  'High Temp (+35°C), AC ON', 'High Temp (+35°C), AC OFF'};
wltc_structs   = {WLTCloTpAC, WLTCloTpNoAC, WLTChiTpAC, WLTChiTpNoAC};

fprintf('%-30s | %-10s | %-12s | %-12s | %-10s | %-10s | %-12s\n', ...
    'Scenario', 'Dist (km)', 'Energy (Wh)', 'EM1+EM2 (Wh)', 'HVAC (Wh)', 'Aux (Wh)', 'Range (km)');
fprintf('%s\n', repmat('-', 1, 105));

for i = 1:4
    s = wltc_structs{i};
    em_total = s.EM1energy + s.EM2energy;
    fprintf('%-30s | %10.2f | %12.2f | %12.2f | %10.2f | %10.2f | %12.2f\n', ...
        wltc_scenarios{i}, s.Distance, s.EnergyCons, em_total, s.HVACenergy, s.AuxEnergy, s.RangeRating);
end
fprintf('\n');

%% 4. Process EPA Multi-Cycle Results
fprintf('--- 3. EPA Standard Multi-Cycle Test (Depletion to 0%% SOC) ---\n');
fprintf('Total Cumulative Distance: %.2f km\n', EPArange.Distance);
fprintf('Total Energy Consumed:     %.2f kWh\n', EPArange.EnergyCons / 1000);
fprintf('Primary Traction Energy:   %.2f kWh\n', (EPArange.EM1energy + EPArange.EM2energy) / 1000);
fprintf('Auxiliary Energy Consumed: %.2f Wh\n', EPArange.AuxEnergy);
fprintf('Specific Energy Rate:      %.2f Wh/km (%.2f kWh/100km)\n', ...
    EPArange.EnergyCons / EPArange.Distance, (EPArange.EnergyCons / EPArange.Distance) / 10);
fprintf('Projected Vehicle Range:   %.2f km\n\n', EPArange.RangeRating);

fprintf('========================================================================================\n');
fprintf('Analysis complete. Results ready for report incorporation.\n');
