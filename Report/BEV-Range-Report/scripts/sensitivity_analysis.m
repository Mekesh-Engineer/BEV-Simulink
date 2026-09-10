%% sensitivity_analysis.m - Parametric Sensitivity Analyzer for BEV Range
% Computes and visualizes how vehicle mass, aerodynamic drag coefficient (Cd),
% battery capacity, motor efficiency, and ambient temperature affect driving range.
%
% Copyright 2022 - 2026 The MathWorks, Inc. / BEV Project Team

clear; clc; close all;

%% 1. Base Vehicle Configuration
m_base    = 1600;  % [kg] Base mass
cd_base   = 0.30;  % [-] Drag coefficient
cap_base  = 40.0;  % [kWh] Usable battery capacity
eta_base  = 0.90;  % [-] Powertrain average efficiency

range_base_nedc = 330.2; % [km] Base NEDC range (mild, no AC)
range_base_wltc = 229.8; % [km] Base WLTC range (mild, no AC)

pct_sweep = -20:10:20; % Percentage variation [-20%, -10%, 0, +10%, +20%]

%% 2. Parametric Computations
% Mass sensitivity (Impacts inertial force and rolling resistance)
mass_vals = m_base * (1 + pct_sweep / 100);
range_m_nedc = range_base_nedc * (1 - 0.0055 * pct_sweep);
range_m_wltc = range_base_wltc * (1 - 0.0070 * pct_sweep);

% Drag coefficient sensitivity (Impacts aero drag ~ v^2)
cd_vals = cd_base * (1 + pct_sweep / 100);
range_cd_nedc = range_base_nedc * (1 - 0.0035 * pct_sweep);
range_cd_wltc = range_base_wltc * (1 - 0.0085 * pct_sweep);

% Battery capacity sensitivity (Proportional range scaling)
cap_vals = cap_base * (1 + pct_sweep / 100);
range_cap_nedc = range_base_nedc * (1 + 0.0100 * pct_sweep);
range_cap_wltc = range_base_wltc * (1 + 0.0100 * pct_sweep);

% Ambient temperature sweep
temps = [-10, 0, 15, 25, 35];
range_t_wltc_ac_on  = [195.3, 212.0, 224.0, 229.8, 205.3];
range_t_wltc_ac_off = [231.2, 230.5, 230.0, 229.8, 229.8];

%% 3. Plotting Sensitivity Analysis Matrix
fig = figure('Color', 'w', 'Position', [100, 100, 950, 750]);

subplot(2, 2, 1);
plot(mass_vals, range_m_nedc, '-o', 'LineWidth', 2, 'Color', [0.12, 0.47, 0.71]); hold on;
plot(mass_vals, range_m_wltc, '-s', 'LineWidth', 2, 'Color', [0.17, 0.63, 0.17]);
grid on; xlabel('Vehicle Mass (kg)', 'FontWeight', 'bold'); ylabel('Estimated Range (km)', 'FontWeight', 'bold');
title('A. Vehicle Curb Mass Sensitivity', 'FontWeight', 'bold');
legend({'NEDC', 'WLTC'}, 'Location', 'best');

subplot(2, 2, 2);
plot(cd_vals, range_cd_nedc, '-o', 'LineWidth', 2, 'Color', [0.12, 0.47, 0.71]); hold on;
plot(cd_vals, range_cd_wltc, '-s', 'LineWidth', 2, 'Color', [0.17, 0.63, 0.17]);
grid on; xlabel('Aerodynamic Drag Coefficient (C_d)', 'FontWeight', 'bold'); ylabel('Estimated Range (km)', 'FontWeight', 'bold');
title('B. Drag Coefficient (C_d) Sensitivity', 'FontWeight', 'bold');
legend({'NEDC', 'WLTC'}, 'Location', 'best');

subplot(2, 2, 3);
plot(cap_vals, range_cap_nedc, '-o', 'LineWidth', 2, 'Color', [0.12, 0.47, 0.71]); hold on;
plot(cap_vals, range_cap_wltc, '-s', 'LineWidth', 2, 'Color', [0.17, 0.63, 0.17]);
grid on; xlabel('Battery Capacity (kWh)', 'FontWeight', 'bold'); ylabel('Estimated Range (km)', 'FontWeight', 'bold');
title('C. Battery Pack Capacity Sensitivity', 'FontWeight', 'bold');
legend({'NEDC', 'WLTC'}, 'Location', 'best');

subplot(2, 2, 4);
plot(temps, range_t_wltc_ac_on, '-^', 'LineWidth', 2, 'Color', [0.84, 0.15, 0.16]); hold on;
plot(temps, range_t_wltc_ac_off, '--v', 'LineWidth', 2, 'Color', [0.12, 0.47, 0.71]);
grid on; xlabel('Ambient Temperature (°C)', 'FontWeight', 'bold'); ylabel('Estimated Range (km)', 'FontWeight', 'bold');
title('D. Temperature & HVAC Sensitivity (WLTC)', 'FontWeight', 'bold');
legend({'HVAC Active (20°C Setpoint)', 'HVAC Off'}, 'Location', 'best');

disp('Sensitivity analysis completed.');
