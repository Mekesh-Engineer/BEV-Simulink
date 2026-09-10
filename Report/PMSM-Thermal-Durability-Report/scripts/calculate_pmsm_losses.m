%% Calculate PMSM Multi-Physics Loss Components
% Calculates copper loss, iron hysteresis & eddy losses, and inverter losses
% across user-defined torque-speed operating grids.

function lossSummary = calculate_pmsm_losses(torque_vec, speed_vec, T_winding_C)
    if nargin < 3
        T_winding_C = 120; % Nominal high-temperature winding state
    end
    
    [T_grid, N_grid] = meshgrid(torque_vec, speed_vec);
    w_grid = N_grid * 2 * pi / 60; % rad/s
    
    % Mechanical Power
    P_mech = T_grid .* w_grid;
    
    % Stator Copper Loss with Temperature Coefficient (alpha = 0.00393 1/K for Copper)
    R_ref = 0.045; % Ohm
    T_ref = 20; % C
    R_T = R_ref * (1 + 0.00393 * (T_winding_C - T_ref));
    % Stator current proportional to torque (approximate kt = 1.15 N*m/A)
    I_rms = T_grid / 1.15;
    P_cu = 3 * (I_rms.^2) * R_T;
    
    % Iron Core Loss (Steinmetz formulation: P_fe = k_h * f * B^2 + k_e * f^2 * B^2)
    f_e = (4 * N_grid) / 60; % 4 pole-pairs
    P_fe = 0.08 * (f_e.^1.2) .* (T_grid.^0.6) + 0.0012 * (f_e.^2.0);
    
    % Inverter Loss
    P_inv = 0.022 * P_mech + 120 + 0.00015 * (T_grid .* N_grid);
    
    % Total Losses
    P_loss_total = P_cu + P_fe + P_inv;
    
    % Efficiency
    Efficiency = P_mech ./ (P_mech + P_loss_total + 1e-6) * 100;
    Efficiency(P_mech <= 0) = 0;
    Efficiency(Efficiency > 98) = 98;
    
    lossSummary.P_mech = P_mech;
    lossSummary.P_cu = P_cu;
    lossSummary.P_fe = P_fe;
    lossSummary.P_inv = P_inv;
    lossSummary.P_loss_total = P_loss_total;
    lossSummary.Efficiency = Efficiency;
end
