%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   A function to display/log the calculated results.   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function TextOut(file, opt_output, txt, varargin)

switch (opt_output)
    case 1
        fprintf(txt, varargin{:});

    case {2, 3}
        fprintf(file, txt, varargin{:});
        
        if (opt_output == 3)
            fprintf(txt, varargin{:});
        end
end

end