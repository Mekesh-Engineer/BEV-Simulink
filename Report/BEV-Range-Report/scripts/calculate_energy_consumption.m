%% calculate_energy_consumption.m - Subsystem Energy Consumption Auditor
% Computes specific energy consumption rates (Wh/km, kWh/100km) and energy shares
% across traction (EM1, EM2), cabin HVAC, and low-voltage auxiliary systems.
%
% Copyright 2022 - 2026 The MathWorks, Inc. / BEV Project Team

function audit = calculate_energy_consumption(simResultStruct)
    % simResultStruct: struct containing fields Distance (km), EnergyCons (Wh),
    %                  EM1energy (Wh), EM2energy (Wh), HVACenergy (Wh), AuxEnergy (Wh)
    
    arguments
        simResultStruct struct
    end
    
    dist_km = simResultStruct.Distance;
    e_total_wh = simResultStruct.EnergyCons;
    
    audit.Distance_km = dist_km;
    audit.TotalEnergy_Wh = e_total_wh;
    audit.TotalEnergy_kWh = e_total_wh / 1000;
    
    % Specific Energy Consumption Rates
    audit.SECR_Wh_per_km = e_total_wh / dist_km;
    audit.SECR_kWh_per_100km = (e_total_wh / dist_km) / 10;
    
    % Subsystem Breakdown
    audit.EM1_Wh = simResultStruct.EM1energy;
    audit.EM2_Wh = simResultStruct.EM2energy;
    audit.TractionTotal_Wh = simResultStruct.EM1energy + simResultStruct.EM2energy;
    audit.HVAC_Wh = simResultStruct.HVACenergy;
    audit.Aux_Wh = simResultStruct.AuxEnergy;
    
    % Percentage Shares
    audit.Traction_Pct = (audit.TractionTotal_Wh / e_total_wh) * 100;
    audit.HVAC_Pct = (audit.HVAC_Wh / e_total_wh) * 100;
    audit.Aux_Pct = (audit.Aux_Wh / e_total_wh) * 100;
end
