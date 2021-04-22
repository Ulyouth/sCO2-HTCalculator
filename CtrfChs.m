%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A function to plot channel properties as isolines.  %  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function CtrfChs(m_Props, iProp, GH, TbH0, TbC0, iFile, opt_save)

iqw = 1; iTw = 2; iTb = 3; ih = 4; id = 5; iv = 6;

%% Define the number steps to be used.
x = 100;

figure;

switch (iProp)
    case iTb
        if (m_Props(1, 1, iTb) > TbH0)

            m_TbC = m_Props(:, 2:length(m_Props), iProp);
            qw = mean2(m_Props(:, 2:length(m_Props), iqw));
            
            T_min = min(m_TbC(:));
            T_max = max(m_TbC(:));
            lvls = T_min:((T_max - T_min)/x):T_max;
            
            colormap(jet);
            contourf(m_TbC, lvls, 'LineColor', 'none');

            str1 = ['CO2 Bulk temperature [GH = ', num2str(GH)];
            str1 = [str1, 'kg/(s*m2); TbH0 = ' , num2str(TbH0), ' K]'];
            str2 = ['Total heat flux density: qw = ', num2str(qw), ' kW/m2'];

            title({str1, str2});   
            caxis([T_min T_max]);
        else

            m_TbH = m_Props(2:length(m_Props), :, iProp);
            qw = mean2(m_Props(2:length(m_Props), :, iqw));
            
            T_min = min(m_TbH(:));
            T_max = max(m_TbH(:));
            lvls = T_min:((T_max - T_min)/x):T_max;
            
            colormap(jet);
            contourf(m_TbH, lvls, 'LineColor', 'none');

            str1 = ['H2O Bulk temperature [GH = ', num2str(GH)];
            str1 = [str1, 'kg/(s*m2); TbH0 = ' , num2str(TbH0), ' K]'];
            str2 = ['Total heat flux density: qw = ', num2str(qw), ' kW/m2'];

            title({str1, str2}); 
            caxis([T_min T_max]);
        end
        
    case iqw
        
        m_qw = m_Props(:, 2:length(m_Props), iProp);
        qw = mean2(m_qw);

        colormap(flipud(jet));
        contourf(m_qw, x, 'LineColor', 'none');
        
        str1 = ['Heat flux density [GH = ', num2str(GH)];
        str1 = [str1, 'kg/(s*m2); TbH0 = ', num2str(TbH0), ' K]'];
        str2 = ['Total heat flux density: qw = ', num2str(qw), ' kW/m2'];
        
        title({str1, str2});    
end

xlabel('H2O channel');
ylabel('CO2 channel');
colorbar;
grid on;

if (opt_save ~= 0)
    saveas(gcf, [num2str(iFile), '.png']);
end

end