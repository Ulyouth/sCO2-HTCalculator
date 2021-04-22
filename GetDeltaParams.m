%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A function to obtain the delta input parameters.   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [delta_qw, delta_TbH, delta_TbC, delta_ItTbH, delta_GH] = GetDeltaParams(m_delta)

delta_qw = m_delta(1);
delta_TbH = m_delta(2);
delta_TbC = m_delta(3);
delta_ItTbH = m_delta(4);
delta_GH = m_delta(5);

end