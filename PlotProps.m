%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A function to plot iteration results as a graph.  %  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function PlotProps(m_X, m_Y, type, iFile, opt_save)

figure;

semilogy(m_X(:), m_Y(:));
ylim([1 max(m_Y(:))*10]);

switch (type)
    case 'TxG'
        title('Water inlet temperature (T) x Water mass flux density (G)');
        xlabel('T [K]');
        ylabel('G [kg/(s*m2)]');
        
    case 'TxRe'
        title('Water inlet temperature (T) x Reynolds number (-)');
        xlabel('T [K]');
        ylabel('Re [-]');  
end

grid on;

if (opt_save ~= 0)
    saveas(gcf, [num2str(iFile), '.png']);
end

end