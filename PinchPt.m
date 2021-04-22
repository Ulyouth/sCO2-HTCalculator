%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A function to plot the pinch-point graph.  %  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PinchPt(m_C, m_H, GH, TbH0, iFile, opt_save)

iqw = 1; iTw = 2; iTb = 3; ih = 4; id = 5; iv = 6;

figure;

m_TbC = mean(m_C(:, 2:length(m_C), iTb));
m_TbH = mean(m_H(2:length(m_H), :, iTb));
m_hC = mean(m_C(:, 2:length(m_C), ih));
m_qw = mean(m_C(:, 2:length(m_C), iqw));
qw = mean2(m_qw);

plot(m_hC(:), m_TbC(:), 'r', m_hC(:), m_TbH(:), 'b');

str1 = ['Pinch-Point [GH = ', num2str(GH)];
str1 = [str1, 'kg/(s*m2); TbH0 = ' , num2str(TbH0), ' K]'];
str2 = ['Total heat flux density: qw = ', num2str(qw), ' kW/m2'];
         
grid on;
title({ str1, str2 });
xlabel('CO2 Enthalpy [kJ/kg]');
ylabel('Bulk Temperature [K]');
legend({'CO2', 'H2O'}, 'Location', 'northwest');
    
if (opt_save ~= 0)
    saveas(gcf, [num2str(iFile), '.png']);
end

end