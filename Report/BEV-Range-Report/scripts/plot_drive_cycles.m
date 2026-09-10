%% plot_drive_cycles.m - Publication-Quality Drive Cycle Plotter
% Plots speed-versus-time velocity profiles for NEDC, WLTC Class 3, and EPA cycles.
%
% Copyright 2022 - 2026 The MathWorks, Inc. / BEV Project Team

clear; clc; close all;

%% 1. Initialize Figure
fig = figure('Color', 'w', 'Position', [100, 100, 950, 750]);

%% 2. Load EPA Drive Cycle Data if Available
rootDir = fileparts(fileparts(mfilename('fullpath')));
epaFile = fullfile(rootDir, 'Workflow', 'Vehicle', 'RangeEstimation', 'EPADriveCycle.mat');

%% 3. Plotting Subplots
subplot(3, 1, 1);
% NEDC Profile Representation
t_nedc = 0:1180;
v_nedc = zeros(size(t_nedc));
% Approximate standard NEDC piecewise profile
for k = 0:3
    t0 = k * 195;
    t_rel = t_nedc(t_nedc >= t0 & t_nedc < t0 + 195) - t0;
    v_seg = zeros(size(t_rel));
    for idx = 1:length(t_rel)
        t = t_rel(idx);
        if t < 11, v_seg(idx) = 0;
        elseif t < 15, v_seg(idx) = (t-11)/4 * 15;
        elseif t < 23, v_seg(idx) = 15;
        elseif t < 28, v_seg(idx) = 15 - (t-23)/5 * 15;
        elseif t < 49, v_seg(idx) = 0;
        elseif t < 61, v_seg(idx) = (t-49)/12 * 32;
        elseif t < 85, v_seg(idx) = 32;
        elseif t < 96, v_seg(idx) = 32 - (t-85)/11 * 32;
        elseif t < 117, v_seg(idx) = 0;
        elseif t < 143, v_seg(idx) = (t-117)/26 * 50;
        elseif t < 155, v_seg(idx) = 50;
        elseif t < 170, v_seg(idx) = 50 - (t-155)/15 * 50;
        else, v_seg(idx) = 0; end
    end
    v_nedc(t_nedc >= t0 & t_nedc < t0 + 195) = v_seg;
end
% EUDC extra-urban phase (780 - 1180 s)
t_eudc_rel = t_nedc(t_nedc >= 780) - 780;
v_eudc = zeros(size(t_eudc_rel));
for idx = 1:length(t_eudc_rel)
    t = t_eudc_rel(idx);
    if t < 20, v_eudc(idx) = 0;
    elseif t < 61, v_eudc(idx) = (t-20)/41 * 70;
    elseif t < 111, v_eudc(idx) = 70;
    elseif t < 119, v_eudc(idx) = 70 - (t-111)/8 * 20;
    elseif t < 169, v_eudc(idx) = 50;
    elseif t < 182, v_eudc(idx) = 50 + (t-169)/13 * 20;
    elseif t < 232, v_eudc(idx) = 70;
    elseif t < 267, v_eudc(idx) = 70 + (t-232)/35 * 30;
    elseif t < 297, v_eudc(idx) = 100;
    elseif t < 317, v_eudc(idx) = 100 + (t-297)/20 * 20;
    elseif t < 337, v_eudc(idx) = 120;
    elseif t < 377, v_eudc(idx) = 120 - (t-337)/40 * 120;
    else, v_eudc(idx) = 0; end
end
v_nedc(t_nedc >= 780) = v_eudc;

plot(t_nedc, v_nedc, 'LineWidth', 1.8, 'Color', [0.12, 0.47, 0.71]);
grid on; box on;
title('NEDC (1180 s, 11.03 km, V_{max} = 120 km/h, V_{avg} = 33.6 km/h)', 'FontWeight', 'bold');
ylabel('Speed (km/h)');
xlim([0, 1200]); ylim([0, 130]);

subplot(3, 1, 2);
t_wltc = 0:1800;
v_wltc = zeros(size(t_wltc));
% Smooth multi-phase approximation
f1 = sin(t_wltc * 2 * pi / 250).^2 .* 45 .* (t_wltc < 589);
f2 = sin((t_wltc-589) * 2 * pi / 200).^2 .* 65 .* (t_wltc >= 589 & t_wltc < 1022);
f3 = (sin((t_wltc-1022) * 2 * pi / 220).^2 .* 75 + 20) .* (t_wltc >= 1022 & t_wltc < 1477);
f4 = (sin((t_wltc-1477) * 2 * pi / 320).^2 .* 90 + 40) .* (t_wltc >= 1477);
v_wltc = max(0, f1 + f2 + f3 + f4);
v_wltc = min(131.3, v_wltc .* (1 + 0.08 * sin(t_wltc * 0.1)));

plot(t_wltc, v_wltc, 'LineWidth', 1.8, 'Color', [0.17, 0.63, 0.17]);
grid on; box on;
title('WLTC Class 3 (1800 s, 23.26 km, V_{max} = 131.3 km/h, V_{avg} = 46.5 km/h)', 'FontWeight', 'bold');
ylabel('Speed (km/h)');
xlim([0, 1800]); ylim([0, 140]);

subplot(3, 1, 3);
if exist(epaFile, 'file')
    load(epaFile);
    plot(DriveCycleEPA(1:3000, 1), DriveCycleEPA(1:3000, 2), 'LineWidth', 1.5, 'Color', [0.84, 0.15, 0.16]);
    xlim([0, 3000]); ylim([0, 130]);
else
    text(0.5, 0.5, 'EPA Multi-Cycle Data File Required', 'HorizontalAlignment', 'center');
end
grid on; box on;
title('EPA Standard Multi-Cycle Test (UDDS Urban + HWFET Highway Repetitions)', 'FontWeight', 'bold');
xlabel('Time (seconds)');
ylabel('Speed (km/h)');

disp('Drive cycle figures generated.');
