%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A function to calculate Lagrange interpolation values.   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function yw = LagInt(x0, x1, x2, xw, y0, y1, y2)

Lx0 = ((xw - x1) * (xw - x2)) / ((x0 - x1) * (x0 - x2));
Lx1 = ((xw - x0) * (xw - x2)) / ((x1 - x0) * (x1 - x2));
Lx2 = ((xw - x0) * (xw - x1)) / ((x2 - x0) * (x2 - x1));

yw = (y0 * Lx0) + (y1 * Lx1) + (y2 * Lx2);

end