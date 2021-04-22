%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A function to obtain the option parameters.   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [opt_flow, opt_it, opt_disp1, opt_disp2, opt_it_max] = GetOptParams(m_opt)

opt_flow = m_opt(1);
opt_it = m_opt(2);
opt_disp1 = m_opt(3);
opt_disp2 = m_opt(4);
opt_it_max = m_opt(5);

end