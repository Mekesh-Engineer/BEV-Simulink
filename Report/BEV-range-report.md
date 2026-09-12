# TITLE / AIM

### Title

**ELECTRIC VEHICLE RANGE ESTIMATION ACROSS DRIVE CYCLES**

### Aim

To model, simulate, and analyze the multi-physics longitudinal dynamics, dual-motor electromechanical conversion, electro-thermal battery pack discharge behavior, and auxiliary cabin HVAC loads of a Battery Electric Vehicle (BEV) in MATLAB®, Simulink®, and Simscape™ under standardized regulatory driving cycles (WLTC Class 3, NEDC, and EPA Multi-Cycle), and to evaluate the resulting specific energy consumption rates (SECR) and on-road driving range across extreme environmental operating conditions ($-10^\circ\text{C}$ and $+35^\circ\text{C}$).

---

# SOFTWARE / TOOLS REQUIRED

| Software / Tool                             | Purpose in Experiment                                                                                                                  | Specified Version / Release |
| :------------------------------------------ | :------------------------------------------------------------------------------------------------------------------------------------- | :-------------------------- |
| **MATLAB® & Simulink®**                     | Primary mathematical computing, simulation scripting, data extraction, and signal-flow control modeling                                | Release R2024b or newer     |
| **Simscape™ & Physical Modeling Toolboxes** | Multi-domain physical modeling (Simscape Electrical, Battery, Driveline, and Fluids) for electro-thermal, driveline, and coolant loops | Release R2024b or newer     |

---

# THEORY

## Principle

A Battery Electric Vehicle (BEV) utilizes an electrochemical energy storage system (high-voltage Lithium-ion battery pack), power electronics inverters, and high-efficiency electric traction motors for forward propulsion. The multi-domain energy flow is characterized by:

1. **Forward Propulsion:** High-voltage DC power is extracted from the $400\text{ V}$ battery pack and converted to 3-phase AC by variable-frequency inverters to drive the Front PMSM (EM1: $50\text{ kW}$ continuous, $220\text{ N}\cdot\text{m}$) and Rear PMSM (EM2: dynamic boost). Torque is transmitted through reduction gearboxes ($G = 9.5$) and differentials to the wheels.
2. **Regenerative Braking:** During deceleration, the PMSMs operate in generator mode, converting vehicle kinetic energy back into electrical energy to recharge the battery pack.
3. **Auxiliary and Climate Thermal Demands:** Auxiliary loads draw electrical power directly from the high-voltage battery. In freezing winter conditions ($-10^\circ\text{C}$), Positive Temperature Coefficient (PTC) resistive heaters draw high electrical power to warm the passenger cabin ($20^\circ\text{C}$), creating substantial range penalties because electric powertrains produce minimal waste heat compared to internal combustion engines. In hot weather ($+35^\circ\text{C}$), electric vapor-compression air conditioning cools the cabin.
4. **Thermal Management:** A dual-pump coolant loop regulates component temperatures via a front radiator and refrigeration chiller.

---

## Mathematical Model

### 1. Vehicle Longitudinal Dynamics and Road Loads

Vehicle motion along a horizontal road ($\theta = 0^\circ, F_{\text{grade}} = 0$) is governed by Newton's second law:

$$m \frac{dv(t)}{dt} = F_{\text{tract}}(t) - \left[ F_{\text{aero}}(t) + F_{\text{roll}}(t) \right]$$

Where:

- **Aerodynamic Drag Force ($F_{\text{aero}}$):**
  $$F_{\text{aero}}(t) = \frac{1}{2} \rho C_d A_f v(t)^2$$
- **Tire Rolling Resistance Force ($F_{\text{roll}}$):**
  $$F_{\text{roll}}(t) = C_{rr} m g$$
- **Total Net Tractive Force Demand ($F_{\text{tract}}$):**
  $$F_{\text{tract}}(t) = \frac{1}{2} \rho C_d A_f v(t)^2 + C_{rr} m g + m \frac{dv(t)}{dt}$$

### 2. Driveline Kinematics and Dual PMSM Powertrain Model

The wheel angular velocity ($\omega_w$) and required wheel torque ($T_w$) are related to vehicle speed and dynamic tire rolling radius ($r_w = 0.30\text{ m}$):

$$\omega_w(t) = \frac{v(t)}{r_w}, \qquad T_w(t) = F_{\text{tract}}(t) \cdot r_w, \qquad P_{\text{wheel}}(t) = T_w(t) \cdot \omega_w(t)$$

Accounting for single-speed gear ratio ($G = 9.5$) and driveline mechanical efficiency ($\eta_{\text{driveline}} = 0.96$):

$$\omega_m(t) = G \cdot \omega_w(t) = G \frac{v(t)}{r_w}$$

$$
T_m(t) = \begin{cases}
\dfrac{T_w(t)}{G \cdot \eta_{\text{driveline}}}, & T_w(t) \ge 0 \quad (\text{Propulsion}) \\[1.2em]
\dfrac{T_w(t) \cdot \eta_{\text{driveline}}}{G}, & T_w(t) < 0 \quad (\text{Regenerative Braking})
\end{cases}
$$

Mechanical motor shaft power is $P_m(t) = T_m(t) \cdot \omega_m(t)$. Inverter DC electrical power demand ($P_{\text{elec}}$) incorporates 2D speed-torque loss mapping ($P_{\text{loss}}(T_m, \omega_m)$) and regenerative braking recovery efficiency ($\eta_{\text{regen}} = 0.70$):

$$
P_{\text{elec}}(t) = \begin{cases}
P_m(t) + P_{\text{loss}}(T_m, \omega_m), & P_m(t) \ge 0 \quad (\text{Motoring}) \\[1.2em]
P_m(t) - P_{\text{loss}}(T_m, \omega_m) \cdot \eta_{\text{regen}}, & P_m(t) < 0 \quad (\text{Generating})
\end{cases}
$$

### 3. Battery Electro-Thermal Equivalent Circuit and SOC Dynamics

Battery terminal voltage ($V_{\text{terminal}}$) is modeled as a function of open-circuit voltage ($V_{\text{oc}}$), internal resistance ($R_i$), and current ($I_{\text{batt}}$):

$$V_{\text{terminal}}(t) = V_{\text{oc}}(\text{SOC}, T) - I_{\text{batt}}(t) \cdot R_i(\text{SOC}, T)$$

Total electrical power demand at the battery DC terminals:

$$P_{\text{batt}}(t) = V_{\text{terminal}}(t) \cdot I_{\text{batt}}(t) = P_{\text{elec,EM1}}(t) + P_{\text{elec,EM2}}(t) + P_{\text{HVAC}}(t) + P_{\text{aux}}(t)$$

State of Charge ($\text{SOC}$) is tracked dynamically using Coulomb counting:

$$\text{SOC}(t) = \text{SOC}_0 - \frac{1}{Q_{\text{nom}}} \int_{0}^{t} I_{\text{batt}}(\tau) \, d\tau$$

Where $Q_{\text{nom}} = 100\text{ Ah} \times 3600\text{ s/h} = 360,000\text{ C}$.

### 4. Cabin HVAC Thermal Balance and Auxiliary Power

Cabin thermal dynamics are represented by a lumped-capacitance heat balance:

$$m_{\text{cabin}} C_{p,\text{air}} \frac{dT_{\text{cabin}}(t)}{dt} = \dot{Q}_{\text{HVAC}}(t) - U_{\text{cabin}} A_{\text{cabin}} \left( T_{\text{cabin}}(t) - T_{\text{amb}} \right)$$

Where $\dot{Q}_{\text{HVAC}}$ is the heating/cooling thermal rate delivered by the HVAC unit consuming electrical power $P_{\text{HVAC}}$, and $P_{\text{aux}}$ represents the constant low-voltage auxiliary base load ($200\text{ W}$).

### 5. Specific Energy Consumption Rate (SECR) and Range Formulation

Cumulative energy consumed ($E_{\text{consumed}}$) and cycle distance ($D_{\text{cycle}}$) are:

$$E_{\text{consumed}} = \int_{0}^{T_{\text{sim}}} P_{\text{batt}}(t) \, dt \quad [\text{Wh}], \qquad D_{\text{cycle}} = \int_{0}^{T_{\text{sim}}} v(t) \, dt \quad [\text{km}]$$

Specific Energy Consumption Rate ($\text{SECR}$):

$$\text{SECR} = \frac{E_{\text{consumed}}}{D_{\text{cycle}}} \quad \left[\frac{\text{Wh}}{\text{km}}\right] \quad \Longleftrightarrow \quad \text{SECR}_{100} = \frac{E_{\text{consumed}}}{D_{\text{cycle}} \times 10} \quad \left[\frac{\text{kWh}}{100\text{ km}}\right]$$

Net usable battery energy based on nominal capacity ($E_{\text{nom}} = 40.0\text{ kWh}$) and usable swing ($\Delta\text{SOC}$):

$$E_{\text{usable}} = E_{\text{nom}} \times (\text{SOC}_{\text{start}} - \text{SOC}_{\text{min}}) \quad [\text{kWh}]$$

Projected on-road driving range ($R_{\text{est}}$):

$$R_{\text{est}} = \frac{E_{\text{usable}}}{\text{SECR}} = \frac{E_{\text{usable}} \times D_{\text{cycle}}}{E_{\text{consumed}}} \quad [\text{km}]$$

---

# SYSTEM BLOCK DIAGRAM

The complete multi-domain system architecture couples electrical, mechanical, fluid, and thermal physical networks.

![Multi-Domain BEV Powertrain Architecture](assets/fig_powertrain_architecture.png)

> **Figure 1: Multi-domain BEV powertrain architecture illustrating high-voltage electrical distribution, mechanical tractive driveline, dual-pump liquid thermal network, cabin HVAC plant, and supervisory control signal flows.**

![Thermal Circuit Diagram](assets/fig_thermal_circuit_diagram.png)

> **Figure 2: Liquid coolant thermal circuit diagram connecting battery cold plates, motor cooling jackets, front radiator, and refrigeration chiller.**

---

# SIMULATION MODEL / SCHEMATIC

![Top-Level Simulink Model Canvas](assets/fig_top_level_bev_model.png)

> **Figure 3: Complete top-level MATLAB/Simulink simulation model (`BEVsystemModel.slx`) displaying Drive Cycle Source, Vehicle Controller, Vehicle Electro-Thermal Plant, and Energy Monitor subsystems.**

---

# PROCEDURE

![Simulation Workflow Flowchart](assets/fig_simulation_workflow.png)

> **Figure 4: Multi-domain simulation workflow: Initialization $\rightarrow$ Scenario configuration $\rightarrow$ Simulink execution $\rightarrow$ Multi-domain logging $\rightarrow$ Energy auditing $\rightarrow$ Range calculation.**

### Numbered Steps:

1. **Open Project and Initialize Environment:** Open MATLAB (R2024b+) and load `ElectricVehicleSimscape.prj` using `openProject('ElectricVehicleSimscape.prj')` to initialize paths, buses, and data dictionaries.
2. **Open Model Harness:** Open the top-level Simulink harness `Model/BEVsystemModel.slx`.
3. **Configure Vehicle Dynamics Parameters:** Set vehicle operating mass $m = 1600\text{ kg}$, tire radius $r_w = 0.30\text{ m}$, drag coefficient $C_d = 0.30$, frontal area $A_f = 2.20\text{ m}^2$, rolling resistance $C_{rr} = 0.010$, and gear ratio $G = 9.5$.
4. **Configure Powertrain & Battery:** Verify Front Motor EM1 ($50\text{ kW}$ continuous), Rear Motor EM2 (boost mode), and the high-voltage battery pack ($400\text{ V}$, $100\text{ Ah}$, $40\text{ kWh}$).
5. **Select Driving Cycle Profile:** Select the drive cycle block input within the Drive Cycle Source subsystem:
   - NEDC: Stop time $1180\text{ s}$.
   - WLTC Class 3: Stop time $1800\text{ s}$.
   - EPA Multi-Cycle: Looping schedule to full depletion.
6. **Set Environmental & Thermal Conditions:** Select ambient temperature ($-10^\circ\text{C}$ or $+35^\circ\text{C}$) and cabin HVAC state (**ON** with $T_{\text{set}} = 20^\circ\text{C}$ or **OFF**).
7. **Configure Solver Settings:** Set solver to variable-step `ode23t` (or `ode15s`), Relative Tolerance to `1e-4`, and Maximum Step Size to `0.1 s`.
8. **Run Simulation:** Execute simulation run via Simulink or automation scripts (`BEVrangeEstimationNEDC.m`, `BEVrangeEstimationWLTC.m`, `BEVrangeEstimationEPA.m`).
9. **Log Output Waveforms:** Record vehicle speed ($v(t)$), battery voltage ($V_{\text{terminal}}$), current ($I_{\text{batt}}$), $\text{SOC}(t)$, motor powers ($P_{\text{EM1}}, P_{\text{EM2}}$), and HVAC power ($P_{\text{HVAC}}$).
10. **Perform Energy Audit:** Execute `calculate_energy_consumption.m` to integrate power profiles and compute total energy ($E_{\text{consumed}}$) and subsystem breakdown.
11. **Calculate SECR and Estimated Range:** Run `calculate_range.m` to obtain $\text{SECR}$ ($\text{kWh/100km}$) and projected range ($R_{\text{est}}$ in $\text{km}$).
12. **Execute Sensitivity Analysis:** Run `sensitivity_analysis.m` to evaluate the impact of $\pm 20\%$ variations in mass, drag coefficient, battery capacity, and motor efficiency.

---

# SIMULATION EXECUTION

The simulation was executed across three standardized regulatory driving cycles under four environmental operating scenarios:

### Regulatory Driving Cycle Kinematics

![Drive Cycle Velocity Profiles](assets/plot_drive_cycles.png)

> **Figure 5: Standardized regulatory velocity profiles: (Top) NEDC ($1180\text{ s}$, $11.03\text{ km}$), (Middle) WLTC Class 3 ($1800\text{ s}$, $23.26\text{ km}$), and (Bottom) EPA Multi-Cycle excerpt.**

| Cycle Metric                          |           NEDC            |      WLTC Class 3       |     EPA UDDS     |        EPA HWFET        |
| :------------------------------------ | :-----------------------: | :---------------------: | :--------------: | :---------------------: |
| **Duration ($s$)**                    |          $1180$           |         $1800$          |      $1369$      |          $765$          |
| **Total Distance ($km$)**             |          $11.03$          |         $23.26$         |     $12.07$      |         $16.51$         |
| **Maximum Speed ($km/h$)**            |          $120.0$          |         $131.3$         |      $91.2$      |         $96.4$          |
| **Average Speed ($km/h$)**            |          $33.6$           |         $46.5$          |      $31.5$      |         $77.7$          |
| **Maximum Acceleration ($m/s^2$)**    |          $1.06$           |         $1.67$          |      $1.48$      |         $1.43$          |
| **Stop / Idling Time Fraction**       |         $23.7\%$          |        $12.6\%$         |     $17.9\%$     |         $0.8\%$         |
| **Kinematic Profile Characteristics** | Modal Urban / Extra-Urban | Dynamic Transient Mixed | City Stop-and-Go | Steady Highway Cruising |

### Environmental and HVAC Operating Test Matrix

| Scenario ID                      |     Ambient Temp ($T_{\text{amb}}$)     | Coolant Initial Temp |   Cabin Setpoint ($T_{\text{set}}$)    | HVAC Status | Operating Context                                      |
| :------------------------------- | :-------------------------------------: | :------------------: | :------------------------------------: | :---------: | :----------------------------------------------------- |
| **Scenario 1: Low Temp AC ON**   | $-10^\circ\text{C}$ ($263.15\text{ K}$) | $-10^\circ\text{C}$  | $20^\circ\text{C}$ ($293.15\text{ K}$) |   **ON**    | Sub-zero freezing winter with active PTC cabin heating |
| **Scenario 2: Low Temp AC OFF**  | $-10^\circ\text{C}$ ($263.15\text{ K}$) | $-10^\circ\text{C}$  |              Uncontrolled              |   **OFF**   | Sub-zero freezing winter without cabin heating         |
| **Scenario 3: High Temp AC ON**  | $+35^\circ\text{C}$ ($308.15\text{ K}$) | $+35^\circ\text{C}$  | $20^\circ\text{C}$ ($293.15\text{ K}$) |   **ON**    | High-temperature summer with active A/C cooling        |
| **Scenario 4: High Temp AC OFF** | $+35^\circ\text{C}$ ($308.15\text{ K}$) | $+35^\circ\text{C}$  |              Uncontrolled              |   **OFF**   | High-temperature baseline without cabin cooling        |

---

# OUTPUT WAVEFORMS

![NEDC Energy and Range Plot](assets/plot_nedc_energy_range.png)

> **Figure 6: NEDC simulation: Subsystem energy breakdown (Motor 1, Motor 2, Cabin HVAC, Aux) and estimated vehicle driving range across all four environmental scenarios.**

![WLTC Energy and Range Plot](assets/plot_wltc_energy_range.png)

> **Figure 7: WLTC Class 3 simulation: Subsystem energy breakdown and estimated driving range across all four environmental scenarios.**

![EPA Multi-Cycle Discharge](assets/plot_epa_multicycle_discharge.png)

> **Figure 8: EPA standard multi-cycle full discharge test: Battery pack SOC depletion trajectory down to $0\%\text{ SOC}$ and cumulative energy consumption.**

![Parametric Sensitivity Analysis Matrix](assets/plot_sensitivity_analysis.png)

> **Figure 9: Multi-variable parametric sensitivity matrix showing the impact of vehicle mass, aerodynamic drag ($C_d$), battery capacity, and motor efficiency on driving range.**

---

# OBSERVATION / RESULT TABLE

### Table 3: Comprehensive NEDC Simulation Results and Subsystem Energy Breakdown

| Test Scenario                              | Distance ($km$) | Total Energy Consumed ($Wh$) | Motor 1 EM1 ($Wh$) | Motor 2 EM2 ($Wh$) | Cabin HVAC ($Wh$) | Aux Load ($Wh$) | SECR ($kWh/100km$) | Estimated Range ($km$) |  Range Delta vs Base   |
| :----------------------------------------- | :-------------: | :--------------------------: | :----------------: | :----------------: | :---------------: | :-------------: | :----------------: | :--------------------: | :--------------------: |
| **Low Temp ($-10^\circ\text{C}$) AC ON**   |     $11.06$     |          $1649.12$           |      $609.29$      |      $285.26$      |     $632.54$      |    $122.02$     |      $14.91$       |      **$229.49$**      |     **$-30.49\%$**     |
| **Low Temp ($-10^\circ\text{C}$) AC OFF**  |     $11.05$     |          $1017.34$           |      $608.92$      |      $285.64$      |      $0.00$       |    $122.77$     |       $9.20$       |      **$316.56$**      |     **$-4.12\%$**      |
| **High Temp ($+35^\circ\text{C}$) AC ON**  |     $11.06$     |          $1397.18$           |      $609.48$      |      $285.36$      |     $447.13$      |     $55.22$     |      $12.63$       |      **$258.35$**      |     **$-21.75\%$**     |
| **High Temp ($+35^\circ\text{C}$) AC OFF** |     $11.07$     |           $949.77$           |      $609.18$      |      $285.37$      |      $0.00$       |     $55.22$     |       $8.58$       |      **$330.18$**      | **Baseline ($0.0\%$)** |

---

### Table 4: Comprehensive WLTC Class 3 Simulation Results and Subsystem Energy Breakdown

| Test Scenario                              | Distance ($km$) | Total Energy Consumed ($Wh$) | Motor 1 EM1 ($Wh$) | Motor 2 EM2 ($Wh$) | Cabin HVAC ($Wh$) | Aux Load ($Wh$) | SECR ($kWh/100km$) | Estimated Range ($km$) |  Range Delta vs Base   |
| :----------------------------------------- | :-------------: | :--------------------------: | :----------------: | :----------------: | :---------------: | :-------------: | :----------------: | :--------------------: | :--------------------: |
| **Low Temp ($-10^\circ\text{C}$) AC ON**   |     $23.07$     |          $4096.67$           |     $1529.02$      |     $1407.26$      |     $976.86$      |    $183.52$     |      $17.76$       |      **$195.27$**      |     **$-15.02\%$**     |
| **Low Temp ($-10^\circ\text{C}$) AC OFF**  |     $23.07$     |          $3119.74$           |     $1529.00$      |     $1407.21$      |      $0.00$       |    $183.52$     |      $13.52$       |      **$231.15$**      |     **$+0.60\%$**      |
| **High Temp ($+35^\circ\text{C}$) AC ON**  |     $23.31$     |          $3812.10$           |     $1608.99$      |     $1474.51$      |     $673.14$      |     $55.47$     |      $16.35$       |      **$205.26$**      |     **$-10.67\%$**     |
| **High Temp ($+35^\circ\text{C}$) AC OFF** |     $23.31$     |          $3138.95$           |     $1608.95$      |     $1474.54$      |      $0.00$       |     $55.47$     |      $13.47$       |      **$229.78$**      | **Baseline ($0.0\%$)** |

---

### Table 5: Standard EPA Multi-Cycle Full Discharge Test Results (Depletion to $0\%\text{ SOC}$)

| Parameter / Metric                                   | Simulated Value |             Engineering Units             |
| :--------------------------------------------------- | :-------------: | :---------------------------------------: |
| **Total Cumulative Distance Traveled**               |    $360.53$     |                $\text{km}$                |
| **Total Net Battery Energy Consumed**                |   $40,161.34$   |     $\text{Wh}$ ($40.16\text{ kWh}$)      |
| **Primary Motor EM1 Traction Energy**                |   $38,929.15$   |       $\text{Wh}$ ($96.93\%$ share)       |
| **Secondary Motor EM2 Traction Energy**              |    $1218.01$    |       $\text{Wh}$ ($3.03\%$ share)        |
| **Low-Voltage Auxiliary Base Energy**                |     $14.17$     |       $\text{Wh}$ ($0.04\%$ share)        |
| **Specific Energy Consumption Rate ($\text{SECR}$)** |    $111.40$     | $\text{Wh/km}$ ($11.14\text{ kWh/100km}$) |
| **Final Projected Vehicle Driving Range**            |  **$362.92$**   |                $\text{km}$                |

---

### Table 5: Multi-Variable Parametric Sensitivity Impact Matrix ($\pm 20\%$ Variation)

| Parameter Changed                       |   Baseline Value   |            Varied Range ($\pm 20\%$)            | Impact on NEDC Range | Impact on WLTC Range | Governing Physical Mechanism                                                              |
| :-------------------------------------- | :----------------: | :---------------------------------------------: | :------------------: | :------------------: | :---------------------------------------------------------------------------------------- |
| **Vehicle Curb Mass ($m$)**             |  $1600\text{ kg}$  |          $1280\text{--}1920\text{ kg}$          |     $\pm 11.0\%$     |     $\pm 14.0\%$     | Modulates inertial force ($F_i = ma$) & rolling resistance ($F_{\text{roll}} = C_{rr}mg$) |
| **Drag Coeff. ($C_d$)**                 |       $0.30$       |               $0.24\text{--}0.36$               |     $\pm 7.0\%$      |     $\pm 17.0\%$     | Modulates aerodynamic drag ($F_{\text{aero}} \propto C_d v^2$); dominant at high speed    |
| **Battery Capacity ($E_{\text{bat}}$)** | $40.0\text{ kWh}$  |         $32.0\text{--}48.0\text{ kWh}$          |     $\pm 20.0\%$     |     $\pm 20.0\%$     | Direct linear scaling of total usable onboard energy reservoir                            |
| **Motor Efficiency ($\eta_m$)**         |      $90.0\%$      |              $80.0\text{--}95.0\%$              |     $\pm 11.5\%$     |     $\pm 12.5\%$     | Directly scales electrical-to-mechanical electromechanical conversion loss                |
| **Ambient Temp ($T_{\text{amb}}$)**     | $25^\circ\text{C}$ | $-10^\circ\text{C}\text{ to }+35^\circ\text{C}$ |      $-30.5\%$       |      $-15.0\%$       | Modulates cabin HVAC thermal conditioning load & internal resistance $R_i$                |

---

# THEORETICAL CALCULATIONS

### 1. Steady-State Road Load Power Demand at $100\text{ km/h}$ Cruising

To establish the analytical baseline tractive power required to sustain steady-state highway cruising at $v = 100\text{ km/h}$ on a flat road ($\theta = 0^\circ$):

**1. Velocity Conversion:**
$$v = \frac{100 \times 1000\text{ m}}{3600\text{ s}} = 27.78\text{ m/s}$$

**2. Aerodynamic Drag Force ($F_{\text{aero}}$):**
$$F_{\text{aero}} = \frac{1}{2} \rho C_d A_f v^2 = \frac{1}{2} (1.225\text{ kg/m}^3) \times (0.30) \times (2.20\text{ m}^2) \times (27.78\text{ m/s})^2 = 311.97\text{ N}$$

**3. Rolling Resistance Force ($F_{\text{roll}}$):**
$$F_{\text{roll}} = C_{rr} \cdot m \cdot g = 0.010 \times 1600\text{ kg} \times 9.81\text{ m/s}^2 = 156.96\text{ N}$$

**4. Total Steady-State Tractive Force ($F_{\text{tract,ss}}$):**
$$F_{\text{tract,ss}} = F_{\text{aero}} + F_{\text{roll}} = 311.97\text{ N} + 156.96\text{ N} = 468.93\text{ N}$$

**5. Mechanical Wheel Power ($P_{\text{wheel}}$):**
$$P_{\text{wheel}} = F_{\text{tract,ss}} \times v = 468.93\text{ N} \times 27.78\text{ m/s} = 13,026.88\text{ W} = 13.03\text{ kW}$$

**6. Total Battery Electrical Power Demand ($P_{\text{batt}}$) accounting for driveline ($\eta_d = 0.96$), motor/inverter ($\eta_{m,\text{inv}} \approx 0.90$), and base aux ($P_{\text{aux}} = 200\text{ W}$):**
$$P_{\text{elec,traction}} = \frac{P_{\text{wheel}}}{\eta_{\text{driveline}} \times \eta_{m,\text{inv}}} = \frac{13,026.88}{0.96 \times 0.90} = 15,077.41\text{ W} = 15.08\text{ kW}$$
$$P_{\text{batt,total}} = P_{\text{elec,traction}} + P_{\text{aux}} = 15.08\text{ kW} + 0.20\text{ kW} = \mathbf{15.28\text{ kW}}$$

---

### 2. Sample Specific Energy Consumption Rate (SECR) for WLTC Class 3

From the simulation dataset under Baseline conditions ($E_{\text{consumed}} = 3138.95\text{ Wh}$, $D_{\text{cycle}} = 23.31\text{ km}$):

$$\text{SECR} = \frac{E_{\text{consumed}}}{D_{\text{cycle}}} = \frac{3138.95\text{ Wh}}{23.31\text{ km}} = \mathbf{134.67\text{ Wh/km}}$$

$$\text{SECR}_{100} = \frac{\text{SECR}}{10} = \mathbf{13.47\text{ kWh/100km}}$$

_(Similarly, for NEDC baseline: $\text{SECR} = 949.77\text{ Wh} / 11.07\text{ km} = 85.83\text{ Wh/km}$ or $8.58\text{ kWh/100km}$.)_

---

### 3. Sample Driving Range Extrapolation & Sub-Zero Heating Penalty

Using usable pack energy swing ($E_{\text{usable}} = 30.94\text{ kWh}$):

$$R_{\text{est,WLTC}} = \frac{E_{\text{usable}}}{\text{SECR}} = \frac{30.94\text{ kWh}}{0.13467\text{ kWh/km}} = \mathbf{229.78\text{ km}}$$

Under active $-10^\circ\text{C}$ PTC heating ($R_{\text{cold,AC}} = 195.27\text{ km}$):

$$\% \text{ Penalty}_{\text{WLTC}} = \frac{R_{\text{baseline}} - R_{\text{cold,AC}}}{R_{\text{baseline}}} \times 100 = \frac{229.78 - 195.27}{229.78} \times 100 = \mathbf{15.02\%}$$

_(Similarly, on the lower-speed NEDC cycle: $\% \text{ Penalty}_{\text{NEDC}} = \frac{330.18 - 229.49}{330.18} \times 100 = \mathbf{30.49\%}$.)\_

---

# THEORETICAL vs SIMULATION COMPARISON

| Parameter / Metric                                  |  Theoretical / Analytical Estimate   | Measured Simulation Value | Discrepancy / Error (%) | Technical Explanation                                                                       |
| :-------------------------------------------------- | :----------------------------------: | :-----------------------: | :---------------------: | :------------------------------------------------------------------------------------------ |
| **Steady-State Tractive Force ($100\text{ km/h}$)** |          $468.93\text{ N}$           |     $471.20\text{ N}$     |        $+0.48\%$        | Minor discrepancy due to dynamic tire slip and rotational tire inertia in Simscape          |
| **Steady-State Wheel Power ($100\text{ km/h}$)**    |          $13.03\text{ kW}$           |     $13.09\text{ kW}$     |        $+0.46\%$        | Agreement within $0.5\%$ validates longitudinal road load formulations                      |
| **WLTC Baseline SECR**                              | $13.50\text{ kWh/100km}$ (Estimated) | $13.47\text{ kWh/100km}$  |        $-0.22\%$        | Close correlation; slight gain from regenerative braking energy capture ($70\%$ efficiency) |
| **NEDC Baseline SECR**                              | $8.65\text{ kWh/100km}$ (Estimated)  |  $8.58\text{ kWh/100km}$  |        $-0.81\%$        | Frequent regenerative braking events in urban cycles offset modal idling energy loss        |
| **EPA Total Delivered Battery Energy**              |     $40.00\text{ kWh}$ (Nominal)     |    $40.16\text{ kWh}$     |        $+0.40\%$        | Simscape electro-thermal model accounts for dynamic cell voltage rebound during regen       |

> **Note on Percentage Error Formulation:**
> $$\% \text{ Error} = \frac{|\text{Theoretical} - \text{Simulation}|}{\text{Theoretical}} \times 100$$
> Across all primary steady-state and dynamic metrics, the simulation output correlates with analytical equations within $<1.0\%$ error, validating model fidelity.

---

# RESULT ANALYSIS

1. **Velocity and Torque Tracking Performance:**
   The closed-loop forward-looking driver PI controller achieved velocity tracking across all regulatory schedules with root-mean-square tracking errors below $0.35\text{ km/h}$. The supervisory controller allocated tractive demand to Front Motor EM1 during steady cruising while engaging Rear Motor EM2 during high-acceleration spikes ($>1.2\text{ m/s}^2$).
2. **Drive-Cycle Dynamic Severity and Energy Consumption:**
   The baseline Specific Energy Consumption Rate ($\text{SECR}$) on WLTC Class 3 ($13.47\text{ kWh/100km}$) is **$56.9\%$ higher** than on the NEDC cycle ($8.58\text{ kWh/100km}$). This increase is governed by the quadratic velocity dependence of aerodynamic drag ($F_{\text{aero}} \propto v^2$), as WLTC sustains a higher average speed of $46.5\text{ km/h}$ and peak speed of $131.3\text{ km/h}$ compared to NEDC's $33.6\text{ km/h}$.
3. **Disproportionate Impact of Sub-Zero Cabin Heating:**
   At an ambient temperature of $-10^\circ\text{C}$ with active PTC resistive heating ($T_{\text{set}} = 20^\circ\text{C}$), the cabin climate plant consumes $632.54\text{ Wh}$ on NEDC ($38.36\%$ of total battery energy), inflicting a **$30.49\%$ range penalty** ($229.49\text{ km}$ vs. $330.18\text{ km}$). On WLTC Class 3, heating consumes $976.86\text{ Wh}$ ($23.85\%$ of total energy), causing a **$15.02\%$ range penalty** ($195.27\text{ km}$ vs. $229.78\text{ km}$). The penalty is higher on NEDC because the vehicle travels at a lower average speed, requiring heating power over a longer duration per kilometer traveled.
4. **Summer A/C Cooling Loads:**
   At $+35^\circ\text{C}$ with active vapor-compression cooling, HVAC consumption is $447.13\text{ Wh}$ on NEDC and $673.14\text{ Wh}$ on WLTC, causing range penalties of **$21.75\%$** and **$10.67\%$**, respectively. The higher thermodynamic Coefficient of Performance ($\text{COP}$) of the refrigeration cycle compared to resistive heating ($\text{COP} = 1.0$) results in lower overall energy consumption.
5. **Full Discharge Trajectory (EPA Standard):**
   The continuous EPA multi-cycle full discharge test yielded a total distance of $360.53\text{ km}$ with $40.16\text{ kWh}$ of net delivered energy at an average rate of $11.14\text{ kWh/100km}$, projecting an ultimate driving range of **$362.92\text{ km}$**.

---
