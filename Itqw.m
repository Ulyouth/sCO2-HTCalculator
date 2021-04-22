%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A function to iteratively calculate the wall heat flux of a water-  % 
%   cooled supercritical CO2 heat exchanger.                            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [qw, TwC, TwH, TbH] = Itqw(xC, xH, m_C, m_H, kw, qw, m_delta, m_opt)

[pC, ~, ~, ~, ~, ~, TbC0] = GetCParams(m_C);
[pH, GH, ~, DH, ~, sH, TbH0] = GetHParams(m_H);
[delta_qw, delta_TbH, ~, ~, ~] = GetDeltaParams(m_delta);
[opt_flow, ~, opt_disp1, ~, opt_it_max] = GetOptParams(m_opt);

%% Obtain the CO2 enthalpy [kJ/kg] for the given temperature and pressure.
hC = CoolProp.PropsSI('H', 'T', TbC0, 'P', pC, 'CO2') / 1000;

%% Obtain the properties of the H2O for the given temperature and pressure.
miH = CoolProp.PropsSI('V', 'T', TbH0, 'P', pH, 'H2O');        % Viscosity [Pa*s]
cpH = CoolProp.PropsSI('C', 'T', TbH0, 'P', pH, 'H2O') / 1000; % Specific heat [kJ/(kg*K)]
kH = CoolProp.PropsSI('L', 'T', TbH0, 'P', pH, 'H2O') / 1000;  % Thermal conductivity [kW/(m*K)]

%% Calculate the heat transfer properties for the next H2O channel.
Uw = kw / sH;                         % Wall heat transfer coefficient
                                      % [kW/(m2*K)]
ReH = (GH * DH) / miH;                % Reynolds number [-]
PrH = (cpH * miH) / kH;               % Prandtl number [-]
%% Nusselt number [-]
if (ReH >= 10000)
    NuH = (0.023*ReH^0.8) * PrH^0.33; % For turbulent flows
elseif (ReH >= 2300 && ReH < 10000)
    %% 
     % For transitional flows, there is no good model to describe the
     % behaviour of fluids in this region. In this case, to avoid
     % unphysical behaviours during the heat flux iteration procedure,
     % the Nusselt number of the flow is "smoothed-out" by taking the
     % percentage of the flow within the laminar region and within the
     % turbulent region.
    x_lam = (9999 - ReH) / 7699; % Percentage of laminar flow
    x_turb = 1 - x_lam;          % Percentage of turbulence
    
    NuH1 = x_turb * ((0.023*ReH^0.8) * PrH^0.33);
    NuH2 = x_lam * 4.36;
    
    NuH = NuH1 + NuH2;
else
    NuH = 4.36;                       % For laminar flows
end
%%                              
UH = (NuH * kH) / DH;                 % Heat transfer coefficient
                                      % [kW/(m2*K)]
%%

if (opt_disp1 == 2 || opt_disp1 == 3)
    file = fopen('Log_Itqw.txt', 'a');
else
    file = 0;
end

TextOut(file, opt_disp1, '-----------------------');
TextOut(file, opt_disp1, ' (%.3d, %.3d) WATER PROPERTIES ', xH, xC);
TextOut(file, opt_disp1, '-----------------------\n\n');

TextOut(file, opt_disp1, 'VISCOSITY               [Pa*s]: %f\n', miH);
TextOut(file, opt_disp1, 'SPECIFIC HEAT      [kJ/(kg*K)]: %f\n', cpH);
TextOut(file, opt_disp1, 'THERMAL CONDUCTIVITY [W/(m*K)]: %f\n\n', kH);

TextOut(file, opt_disp1, '--------------------');
TextOut(file, opt_disp1, ' (%.3d, %.3d) WATER FLOW PROPERTIES ', xH, xC);
TextOut(file, opt_disp1, '---------------------\n\n');

if (ReH >= 2300 && ReH < 3000) % For transition phase flows.
    TextOut(file, opt_disp1, 'WARNING: Water flow in transition phase regime!\n\n');
end

TextOut(file, opt_disp1, 'REYNOLDS NUMBER             [-]: %f\n', ReH);
TextOut(file, opt_disp1, 'PRANDTL NUMBER              [-]: %f\n', PrH);
TextOut(file, opt_disp1, 'NUSSELT NUMBER              [-]: %f\n', NuH);
TextOut(file, opt_disp1, 'WALL HT COEFFICIENT [kW/(m2*K)]: %f\n', Uw);
TextOut(file, opt_disp1, 'FLOW HT COEFFICIENT [kW/(m2*K)]: %f\n\n', UH);

%% Initialize the iteration variables.
it = 0;             % Iteration count
it_step = delta_qw; % Initial iteration step
it_prev = 0;        % Previous iterative operation 
                    % [1 = subtraction; 2 = sum]
TbH = 0;            % H2O final bulk temperature
qw_it = qw;         % Wall heat flux
qw_prev = 0;        % Wall heat flux in the previous iteration step

TextOut(file, opt_disp1, '---------------------');
TextOut(file, opt_disp1, ' (%.3d, %.3d) HEAT FLUX ITERATION ', xH, xC);
TextOut(file, opt_disp1, '----------------------\n');
            
%%
%  Loop until the calculated value of the bulk temperature matches the
%  desired temperature or the maximum iteration count has been reached.
%  It is assumed that the temperature in the next channel will be same as 
%  the inlet temperature.
while (abs(TbH - TbH0) > delta_TbH && it < opt_it_max)  
    %% Obtain the wall temperature of the next CO2 channel.
    TwC = CalcWallVar(hC, qw_it, TbC0, opt_flow, 1);

    %% Calculate the wall/bulk temperature of the next H2O channel.
    TwH = TwC + (qw_it / Uw); % Wall temperature [K]
    TbH = TwH + (qw_it / UH); % Bulk temperature [K]
    
    %%   
    TextOut(file, opt_disp1, '\n%d', it+1);
    TextOut(file, opt_disp1, '  QW: %f', qw_it);
    TextOut(file, opt_disp1, '  TWC: %f', TwC);
    TextOut(file, opt_disp1, '  TWH: %f', TwH);
    TextOut(file, opt_disp1, '  TBH: %f', TbH);

    %% Evaluate for convergence the iterated bulk temperature.
    if (TbH > (TbH0 + delta_TbH))
        %%
        %  Check if this is the 1st iteration or if the iterative operation
        %  remains the same (subtraction in this case).
        if (it_prev == 0 || it_prev == 1)
            qw_prev = qw_it; % Save the current value of the heat flux
            qw_it = qw_it - it_step;
            it_prev = 1;
        elseif (it_prev == 2)
            %  If the previous iterative operation was sum, that means
            %  that the right value for the heat flux should be in between
            %  the previous and the current value. So we need to decrease
            %  the iteration step in order for convergence to be achieved.
            it_step = it_step * 0.1; % Decrease the iteration step
            qw_it = qw_prev + it_step;
        end           
    elseif (TbH < (TbH0 - delta_TbH))
        %% Same as above, but this time for sum.
        if (it_prev == 0 || it_prev == 2)
            %%
            %  Evaluate the size of the step and decrease it if necessary.
            while (it_step >= (qw_it * -1))
                it_step = it_step * 0.1;
            end
            
            qw_prev = qw_it;
            qw_it = qw_it + it_step;
            it_prev = 2;
        elseif (it_prev == 1)
            it_step = it_step * 0.1;
            qw_it = qw_prev - it_step;           
        end   
    end

    it = it + 1;
end

TextOut(file, opt_disp1, '\n\n%d iterations performed. ', it);

if (abs(TbH - TbH0) > delta_TbH)
    TextOut(file, opt_disp1, 'Convergence not achieved.\n\n');
    qw = NaN;
else
    TextOut(file, opt_disp1, 'Convergence achieved.\n\n');
    qw = qw_it;
    
    % Calculate the real H2O outlet bulk temperature for the iterated heat
    % flux.
    TbH = TbH0 - (qw / (GH * cpH));
end

if (opt_disp1 == 2 || opt_disp1 == 3)
    fclose(file);
end

end





