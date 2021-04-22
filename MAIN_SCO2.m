%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Supercritical CO2 heat exchanger iterative calculator   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

addpath('C:\\Users\\andre\\Documents\\MATLAB_CoolProp');
clear all; clc;

%% Define the channel-dependent input parameters.
pC = 80E+5;         % CO2 Pressure [Pa]
pH = 1.01325E+5;    % H2O Pressure [Pa]
GC = 53.7;          % CO2 Mass flow density [kg/(s*m2)]
GH = 5;             % H2O Mass flow density [kg/(s*m2)]
nC = 75;            % Number of CO2 channels [-]
nH = 75;            % Number of H2O channels [-]
DC = 2E-3;          % CO2 channel diameter [m]
DH = 2E-3;          % H2O channel diameter [m]
lC = 4E-3;          % CO2 sub-channel length [m]
lH = 4E-3;          % H2O sub-channel length [m]
sC = 1E-3;          % CO2 channel wall thickness [m]
sH = 1E-3;          % H2O channel wall thickness [m]
TbC0 = 69 + 273.15; % Inlet CO2 bulk temperature [K]
TbCn = 32 + 273.15; % Outlet CO2 bulk temperature [K]
TbH0 = 5 + 273.15;  % Inlet H2O bulk temperature [K]

%% Define the channel-independent input parameters.
kw = 0.054; % Heat conductivity of 0.5% Carbon Steel at 20 °C [kW/(m*K)]
qw = -1;    % Cooling wall heat flux for a single channel [kW/m2]

%% Define the input delta values.
delta_qw = 1;     % Heat flux delta to be used in the iterations [kW/m2]
delta_TbH = 0.01; % H2O temperature delta to be admitted [K]
delta_TbC = 0.01; % CO2 outlet bulk temperature to be admitted [K]
delta_ItTbH = 1;  % H2O temperature delta to be used in the iterations [K]
delta_GH = 1000;  % H2O mass flow delta to be used in the iterations [kg/(s*m2)]

m_delta = [delta_qw; delta_TbH; delta_TbC; delta_ItTbH; delta_GH];

%% Desired CO2 flow configuration:
%  1 - Upward flow
%  2 - Downward flow
%  3 - Forced flow
opt_flow = 1;                             
                                          
%% Desired iteration method:
%  1 - Change H2O temperature
%  2 - Change H2O mass flux 
opt_it = 2;

%% Output method:
%  1 - Display results in command window (medium-slow)
%  2 - Display results in a log file (slow)
%  3 - Combine 1 and 2 (very slow)
%  4 - Do not display results (fast)
opt_disp1 = 4; % Itqw
opt_disp2 = 3; % ItTbCn

%% Maximum number of iterations
opt_it_max = 100;

%%

m_opt = [opt_flow; opt_it; opt_disp1; opt_disp2; opt_it_max];

m_C = [pC; GC; nC; DC; lC; sC; TbC0];

%%
iqw = 1; iTw = 2; iTb = 3; ih = 4; id = 5; iv = 6; % Indexes of properties.
T_max = 278.15; T_step = 0.1; % Max loop count and loop step.
x = 1; y = 1; % Index of channels and files.
s = 1; % Whether the graphs should be saved to a file. [ 0 = no; 1 = yes]

%m_H = [pH; GH; nH; DH; lH; sH; TbH0];
%[m_Cr, m_Hr, GH] = ItTbCn(m_C, m_H, kw, qw, TbCn, m_delta, m_opt);
%CtrfChs(m_Cr, iTb, GH, m_Hr(1, 1, iTb), TbC0, y, s);
%CtrfChs(m_Hr, iTb, GH, m_Hr(1, 1, iTb), TbC0, y+1, s);
%CtrfChs(m_Cr, iqw, GH, m_Hr(1, 1, iTb), TbC0, y+2, s);
%PinchPt(m_Cr, m_Hr, GH, m_Hr(1, 1, iTb), y+3, s);
    
m_GH = NaN((T_max-TbH0)/T_step, 1);
m_TbH0 = NaN((T_max-TbH0)/T_step, 1);
m_vH = NaN((T_max-TbH0)/T_step, 1);
m_ReH = NaN((T_max-TbH0)/T_step, 1);
m_qw = NaN((T_max-TbH0)/T_step, 1);

for T=TbH0:T_step:T_max

    m_TbH0(x) = T;
    
    m_H = [pH; GH; nH; DH; lH; sH; m_TbH0(x)];

    %% 
    %  Iterate through the given input conditions until the desired CO2
    %  bulk temperature is achieved.
    [m_Cr, m_Hr, m_GH(x)] = ItTbCn(m_C, m_H, kw, qw, TbCn, m_delta, m_opt);

    %% Check if a valid value for GH was obtained.
    if (isnan(m_GH(x)))
        break;
    end
            
    m_vH(x) = CoolProp.PropsSI('V', 'T', m_TbH0(x), 'P', pH, 'H2O'); 
    m_ReH(x) = (m_GH(x) * DH) / m_vH(x); 
    m_qw(x) = mean2(m_Cr(:, 2:length(m_Cr), iqw));
    
    %CtrfChs(m_Cr, iTb, m_GH(x), m_TbH0(x), TbC0, y, s);
    %CtrfChs(m_Hr, iTb, m_GH(x), m_TbH0(x), TbC0, y+1, s);
    %CtrfChs(m_Cr, iqw, m_GH(x), m_TbH0(x), TbC0, y+2, s);
    %PinchPt(m_Cr, m_Hr, m_GH(x), m_TbH0(x), y+3, s);

    GH = m_GH(x);
    x = x + 1;
    y = y + 4;
end

PlotProps(m_TbH0, m_GH, 'TxG', y, s);
PlotProps(m_TbH0, m_ReH, 'TxRe', y+1, s);
