%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A function to calculate the conditions that need to be met in order   % 
%   for the desired final CO2 bulk temperature to be achieved.            %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [m_Cr, m_Hr, GH] = ItTbCn(m_C, m_H, kw, qw, TbCn, m_delta, m_opt)

[pC, GC, nC, DC, lC, sC, TbC0] = GetCParams(m_C);
[pH, ~, nH, DH, lH, sH, TbH0] = GetHParams(m_H);
[~, ~, delta_TbC, delta_ItTbH, delta_GH] = GetDeltaParams(m_delta);
[~, opt_it, ~, opt_disp2, opt_it_max] = GetOptParams(m_opt);

ip = 1; iG = 2; in = 3; iD = 4; iL = 5; is = 6; iT0 = 7;

%% Calculate the flow areas of both channels [m]
ACf = pi * (DC / 2)^2;
AHf = pi * (DH / 2)^2;

%% Calculate the surface areas of both sub-channels [m]
ACs = pi * (DC + sC) * lC;
AHs = pi * (DH + sH) * lH;

%% Initialize the vectors that should store the results.
m_CChProps = zeros(nH, nC+1, 6);
m_HChProps = zeros(nH+1, nC, 6);

%% Index values of the properties to be logged.
iqw = 1; iTw = 2; iTb = 3; ih = 4; id = 5; iv = 6;

%% Obtain the inlet CO2 properties.
hC0   = CoolProp.PropsSI('H', 'T', TbC0, 'P', pC, 'CO2') / 1000; 
rhoC0 = CoolProp.PropsSI('D', 'T', TbC0, 'P', pC, 'CO2');
miC0   = CoolProp.PropsSI('V', 'T', TbC0, 'P', pC, 'CO2');

%% Obtain the inlet H2O properties.
hH0 = CoolProp.PropsSI('H', 'T', TbH0, 'P', pH, 'H2O') / 1000; 
rhoH0 = CoolProp.PropsSI('D', 'T', TbH0, 'P', pH, 'H2O');
miH0 = CoolProp.PropsSI('V', 'T', TbH0, 'P', pH, 'H2O');

%% Set the inlet values of the CO2 side.
m_CChProps(:, 1, iTb) = TbC0;
m_CChProps(:, 1, ih) = hC0; 
m_CChProps(:, 1, id) = rhoC0;
m_CChProps(:, 1, iv) = miC0;

%% Set the inlet values of the H2O side.
m_HChProps(1, :, iTb) = TbH0;
m_HChProps(1, :, ih) = hH0;
m_HChProps(1, :, id) = rhoH0;
m_HChProps(1, :, iv) = miH0;

%%
if (opt_disp2 == 2 || opt_disp2 == 3)
    file = fopen('Log_ItTbCn.txt', 'w');
else
    file = 0;
end

%%
TextOut(file, opt_disp2, '---------------------');
TextOut(file, opt_disp2, ' CO2 BULK TEMPERATURE ITERATION ');
TextOut(file, opt_disp2, '----------------------\n');


%% Initialize the iteration variables.
it = 0;       % Iteration count
it_err = 0;   % Indicates that an error has occurred.
it_prev = 0;  % Previous iterative operation 
              % [1 = subtraction; 2 = sum] 
TbCf = 0;     % Averaged outlet CO2 bulk temperature (all channels)
var_prev = 0; % Previous iteration value

%% Loop until the final CO2 bulk temperature is achieved.
while (abs(TbCn - TbCf) > delta_TbC && it < opt_it_max)
    
    hCf = 0; % Averaged outlet CO2 enthalpy (all channels)
    hHf = 0; % Averaged outlet H2O enthalpy (all channels)
    
    %% Delete any previous heat flux iteration logs.
    if (exist('Log_Itqw.txt', 'file'))
        delete('Log_Itqw.txt');
    end
    
    %% Loop through all CO2/H2O channels.
    for xC = 1:nC
        for xH = 1:nH         
            %% Obtain the temperature values of the current sub-channels.
            m_C(iT0) = m_CChProps(xH, xC, iTb);
            m_H(iT0) = m_HChProps(xH, xC, iTb);
            
            %% Compute the wall heat flux for the input conditions.
            [qw, TwC, TwH, TbH] = Itqw(xC, xH, m_C, m_H, kw, qw, m_delta, m_opt);

            %% Check if a valid value for qw was obtained.
            if (isnan(qw))
                xC = nC;
                xH = nH;
                it_err = 1;
                break;
            end

            %% Store the iterated heat flux value.
            m_CChProps(xH, xC+1, iqw) = qw;
            m_HChProps(xH+1, xC, iqw) = qw;
            
            %% Obtain the initial enthalpy of the sub-channel.
            hC0 = m_CChProps(xH, xC, ih);

            %% Calculate the final enthalpy of the sub-channel.
            hC = ((qw * ACs) / (GC * ACf)) + hC0;

            %% Obtain the outlet CO2 properties (single sub-channel).
            TbC = CoolProp.PropsSI('T', 'H', hC * 1000, 'P', pC, 'CO2');
            rhoC = CoolProp.PropsSI('D', 'T', TbC, 'P', pC, 'CO2');
            miC = CoolProp.PropsSI('V', 'T', TbC, 'P', pC, 'CO2');
            
            %% Obtain the outlet H2O properties (single sub-channel).
            hH = CoolProp.PropsSI('H', 'T', TbH, 'P', pH, 'H2O') / 1000;
            rhoH = CoolProp.PropsSI('D', 'T', TbH, 'P', pH, 'H2O');
            miH = CoolProp.PropsSI('V', 'T', TbH, 'P', pH, 'H2O');
            
            %% Store the CO2 results.
            m_CChProps(xH, xC+1, iTw) = TwC;
            m_CChProps(xH, xC+1, iTb) = TbC;
            m_CChProps(xH, xC+1, ih) = hC;
            m_CChProps(xH, xC+1, id) = rhoC;
            m_CChProps(xH, xC+1, iv) = miC;

            %% Store the H2O results.
            m_HChProps(xH+1, xC, iTw) = TwH;
            m_HChProps(xH+1, xC, iTb) = TbH;
            m_HChProps(xH+1, xC, ih) = hH;
            m_HChProps(xH+1, xC, id) = rhoH;
            m_HChProps(xH+1, xC, iv) = miH;

            %% Calculate the partial average CO2 outlet enthalpy.
            if (xC == nC)
                hCf = hCf + hC / nH;
            end
            
            %% Calculate the partial average H2O outlet enthalpy.
            if (xH == nH)
                hHf = hHf + hH / nC;
            end
        end 
    end
    
    %% Quit if an error has happened.
    if (it_err == 1)
        break;
    end

    %% Obtain the outlet bulk temperatures.
    TbCf = CoolProp.PropsSI('T', 'H', hCf * 1000, 'P', pC, 'CO2');
    TbHf = CoolProp.PropsSI('T', 'H', hHf * 1000, 'P', pH, 'H2O');
    
    %%
    TextOut(file, opt_disp2, '\n%d', it+1);
    TextOut(file, opt_disp2, '  TBH0: %f', TbH0);
    TextOut(file, opt_disp2, '  GH: %f', m_H(iG));
    TextOut(file, opt_disp2, '  RE: %f', (m_H(iG) * DH) / miH0);
    TextOut(file, opt_disp2, '  TBCF: %f', TbCf);
    TextOut(file, opt_disp2, '  TBHF: %f', TbHf);

    %% Evaluate for convergence the outlet CO2 bulk temperature.
    if (TbCf > (TbCn + delta_TbC))      
        %%
        %  Check if this is the 1st iteration or if the iterative operation
        %  remains the same (subtraction in this case).
        if (it_prev == 0 || it_prev == 1)           
            it_prev = 1;          
            %%
            switch (opt_it)
                case 1
                    %%
                    %  Evaluate the size of the step and decrease it if 
                    %  necessary.
                    while (delta_ItTbH >= TbH0)
                        delta_ItTbH = delta_ItTbH * 0.1;
                    end
                    
                    var_prev = TbH0;
                    TbH0 = TbH0 - delta_ItTbH;
                case 2
                    var_prev = m_H(iG);
                    m_H(iG) = m_H(iG) + delta_GH;
            end
        elseif (it_prev == 2)
            %%
            %  If the previous iterative operation was sum, that means
            %  that the right value for the iteration variable should be
            %  in between the previous and the current value. So we need
            %  to decrease the iteration step in order for convergence to
            %  be achieved.
            switch (opt_it)
                case 1 
                    delta_ItTbH = delta_ItTbH * 0.1;
                    TbH0 = var_prev + delta_ItTbH;
                case 2
                    delta_GH = delta_GH * 0.1;
                    m_H(iG) = var_prev - delta_GH;
            end
        end          
    elseif (TbCf < (TbCn - delta_TbC))
        %% Same as above, but this time for sum.
        if (it_prev == 0 || it_prev == 2)       
            it_prev = 2;            
            %%
            switch (opt_it)
                case 1
                    var_prev = TbH0;
                    TbH0 = TbH0 + delta_ItTbH;
                case 2
                    %%
                    %  Evaluate the size of the step and decrease it if 
                    %  necessary.
                    while (delta_GH >= m_H(iG))
                        delta_GH = delta_GH * 0.1;
                    end
                    
                    var_prev = m_H(iG);
                    m_H(iG) = m_H(iG) - delta_GH;
            end            
        elseif (it_prev == 1)                    
            %%
            switch (opt_it)
                case 1
                    delta_ItTbH = delta_ItTbH * 0.1; 
                    TbH0 = var_prev - delta_ItTbH;                  
                case 2 
                    delta_GH = delta_GH * 0.1; 
                    m_H(iG) = var_prev + delta_GH;
            end          
        end
    end

    if (opt_it == 1)
        %% Obtain the inlet H2O properties.
        hH0 = CoolProp.PropsSI('H', 'T', TbH0, 'P', pH, 'H2O') / 1000; 
        rhoH0 = CoolProp.PropsSI('D', 'T', TbH0, 'P', pH, 'H2O');
        miH0 = CoolProp.PropsSI('V', 'T', TbH0, 'P', pH, 'H2O');

        %% Set the inlet values of the H2O side.
        m_HChProps(1, :, iTb) = TbH0;
        m_HChProps(1, :, ih) = hH0;
        m_HChProps(1, :, id) = rhoH0;
        m_HChProps(1, :, iv) = miH0;
    end
        
    it = it + 1;    
end

TextOut(file, opt_disp2, '\n\n%d iterations performed. ', it);

if (abs(TbCn - TbCf) > delta_TbC)
    TextOut(file, opt_disp2, 'Convergence not achieved.\n\n');

    m_Cr = NaN(nH, nC+1, 6);
    m_Hr = NaN(nH+1, nC, 6);
    
    GH = NaN;
else
    TextOut(file, opt_disp2, 'Convergence achieved.\n\n');
    
    m_Cr = m_CChProps;
    m_Hr = m_HChProps;
    GH = m_H(iG);
end

if (opt_disp2 == 2 || opt_disp2 == 3)
    fclose(file);
end

end