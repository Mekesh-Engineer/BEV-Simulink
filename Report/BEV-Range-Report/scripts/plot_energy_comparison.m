%% plot_energy_comparison.m - Publication-Quality Energy & Range Comparison Plotter
% Generates stacked bar charts of subsystem energy breakdown vs range rating
% for NEDC and WLTC across all 4 environmental scenarios.
%
% Copyright 2022 - 2026 The MathWorks, Inc. / BEV Project Team

clear; clc; close all;

rootDir = fileparts(fileparts(mfilename('fullpath')));
dataPath = fullfile(rootDir, 'Workflow', 'Vehicle', 'RangeEstimation');

load(fullfile(dataPath, 'NEDCrangeData.mat'));
load(fullfile(dataPath, 'WLTCrangeData.mat'));

scenarios = categorical({'Low Temp (-10°C) AC ON', 'Low Temp (-10°C) AC OFF', ...
                         'High Temp (+35°C) AC ON', 'High Temp (+35°C) AC OFF'});
scenarios = reordercats(scenarios, {'Low Temp (-10°C) AC ON', 'Low Temp (-10°C) AC OFF', ...
                                    'High Temp (+35°C) AC ON', 'High Temp (+35°C) AC OFF'});

%% 1. NEDC Energy & Range Plot
fig1 = figure('Color', 'w', 'Position', [100, 100, 800, 480]);
energy_nedc = [
    NEDCloTpAC.EM1energy, NEDCloTpNoAC.EM1energy, NEDChiTpAC.EM1energy, NEDChiTpNoAC.EM1energy;
    NEDCloTpAC.EM2energy, NEDCloTpNoAC.EM2energy, NEDChiTpAC.EM2energy, NEDChiTpNoAC.EM2energy;
    NEDCloTpAC.HVACenergy, NEDCloTpNoAC.HVACenergy, NEDChiTpAC.HVACenergy, NEDChiTpNoAC.HVACenergy;
    NEDCloTpAC.AuxEnergy, NEDCloTpNoAC.AuxEnergy, NEDChiTpAC.AuxEnergy, NEDChiTpNoAC.AuxEnergy
];
ranges_nedc = [NEDCloTpAC.RangeRating, NEDCloTpNoAC.RangeRating, NEDChiTpAC.RangeRating, NEDChiTpNoAC.RangeRating];

yyaxis left
b1 = bar(scenarios, energy_nedc', 'stacked');
ylabel('Energy Consumed (Wh)', 'FontWeight', 'bold');
ylim([0, 2500]);
grid on;

yyaxis right
p1 = plot(scenarios, ranges_nedc, '-s', 'LineWidth', 2.5, 'MarkerSize', 8, 'Color', [0.84, 0.15, 0.16]);
ylabel('Estimated Range (km)', 'FontWeight', 'bold');
ylim([150, 360]);

title('NEDC: Subsystem Energy Consumption & Range Rating', 'FontWeight', 'bold');
legend([b1(1), b1(2), b1(3), b1(4), p1], {'Motor 1 (Front)', 'Motor 2 (Rear)', 'HVAC Plant', 'Auxiliary Loads', 'Range'}, ...
    'Location', 'northoutside', 'Orientation', 'horizontal');

%% 2. WLTC Energy & Range Plot
fig2 = figure('Color', 'w', 'Position', [150, 150, 800, 480]);
energy_wltc = [
    WLTCloTpAC.EM1energy, WLTCloTpNoAC.EM1energy, WLTChiTpAC.EM1energy, WLTChiTpNoAC.EM1energy;
    WLTCloTpAC.EM2energy, WLTCloTpNoAC.EM2energy, WLTChiTpAC.EM2energy, WLTChiTpNoAC.EM2energy;
    WLTCloTpAC.HVACenergy, WLTCloTpNoAC.HVACenergy, WLTChiTpAC.HVACenergy, WLTChiTpNoAC.HVACenergy;
    WLTCloTpAC.AuxEnergy, WLTCloTpNoAC.AuxEnergy, WLTChiTpAC.AuxEnergy, WLTChiTpNoAC.AuxEnergy
];
ranges_wltc = [WLTCloTpAC.RangeRating, WLTCloTpNoAC.RangeRating, WLTChiTpAC.RangeRating, WLTChiTpNoAC.RangeRating];

yyaxis left
b2 = bar(scenarios, energy_wltc', 'stacked');
ylabel('Energy Consumed (Wh)', 'FontWeight', 'bold');
ylim([0, 5500]);
grid on;

yyaxis right
p2 = plot(scenarios, ranges_wltc, '-o', 'LineWidth', 2.5, 'MarkerSize', 8, 'Color', [0.84, 0.15, 0.16]);
ylabel('Estimated Range (km)', 'FontWeight', 'bold');
ylim([160, 260]);

title('WLTC Class 3: Subsystem Energy Consumption & Range Rating', 'FontWeight', 'bold');
legend([b2(1), b2(2), b2(3), b2(4), p2], {'Motor 1 (Front)', 'Motor 2 (Rear)', 'HVAC Plant', 'Auxiliary Loads', 'Range'}, ...
    'Location', 'northoutside', 'Orientation', 'horizontal');

disp('Energy and range comparison plots generated.');
