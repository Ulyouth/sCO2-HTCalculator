%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A function to calculate the wall heat flux and temperature for a   %
%   supercritical CO2 heat exchanger.                                  %
%   VALID FOR: p = 80 bar, D = 2mm, G = 57 kg/(s*m2)                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function yw = CalcWallVar(h, xw, Tb, flow_opt, var_opt)

%%
%  Define the constant heat fluxes from which a 3rd value should be 
%  interpolated.
qw1 = -30.87;
qw2 = -61.74;

%%
if (flow_opt == 1) % Upward flow
    %%
    % Calculate the wall heat fluxes from the constant equations for
    % qw = -30.87 kW/m2 (T1) and qw = -61.74 kW/m2 (T2)
    T1 = 2.40333E-6*h^3 - 3.27833E-3*h^2 + 1.52005*h + 6.28516E+1;
    T2 = -1.34370E-6*h^3 + 1.01674E-3*h^2 - 9.53435E-2*h + 2.52699E+2;
elseif (flow_opt == 2) % Downward flow
    %%
    %  Calculate the wall heat fluxes from the constant equations for
    %  qw = -30.87 kW/m2 (T1) and qw = -61.74 kW/m2 (T2)
    T1 = 2.04793E-5*h^3 - 2.23862E-2*h^2 + 8.08828*h - 6.78556E+2;
    T2 = -1.70653E-7*h^3 + 2.71985E-3*h^2 - 1.87395*h + 5.90926E+2;
else % Forced flow
    %%
    %  Calculate the wall heat fluxes from the constant equations for
    %  qw = -30.87 kW/m2 (T1) and qw = -61.74 kW/m2 (T2)
    T1 = 2.95437E-6*h^3 - 4.25164E-3*h^2 + 2.07489*h - 4.28837E+1;
    T2 = 5.69358E-6*h^3 - 7.98254E-3*h^2 + 3.77080*h - 3.11993E+2;
end

%%
if (var_opt == 1) % Calculate the wall temperature (Tw) 
    
    yw = LagInt(0, qw1, qw2, xw, Tb, T1, T2); % xw = qw   
    
else % Calculate the wall heat flux (qw)
    
    yw = LagInt(Tb, T1, T2, xw, 0, qw1, qw2); % xw = Tw 
    
end

end