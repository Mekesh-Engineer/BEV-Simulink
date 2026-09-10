%% calculate_range.m - Electric Vehicle Range Extrapolation Calculator
% Calculates projected driving range based on usable battery energy and
% cycle-specific energy consumption rates.
%
% Copyright 2022 - 2026 The MathWorks, Inc. / BEV Project Team

function range_km = calculate_range(usableBatteryEnergy_kWh, energyConsumed_kWh, distanceTraveled_km)
    % Formulations:
    % SECR = Energy_Consumed (kWh) / Distance (km)
    % Range = Usable_Battery_Energy (kWh) / SECR (kWh/km)
    
    arguments
        usableBatteryEnergy_kWh (1,1) double {mustBePositive}
        energyConsumed_kWh (1,1) double {mustBePositive}
        distanceTraveled_km (1,1) double {mustBePositive}
    end
    
    secr_kwh_per_km = energyConsumed_kWh / distanceTraveled_km;
    range_km = usableBatteryEnergy_kWh / secr_kwh_per_km;
end
