function [ yi ] = DeRateMatching( xi, Xi, DeltaNij,  Eini , Eplus , Eminus, yi, Fi )
% DeRateMatching
%
% This function calculates Punctures or Reapeats Bits in respect to the
% rate matching pattern defined by Eini, Eplus , Eminus,
%
% Usage :
%
% [ yi ] = DeRateMatching( xi, Xi, DeltaNij,  Eini , Eplus , Eminus, yi, Fi )
%
% Where         xi          = Is the Recieved packet
%
%				Xi          = Is the Original frame length before
%                             Puncturing or Repretition
%
%				DeltaNij	= Negative LLR probability is zero size
%                             DeltaNij for each frame. Positive LLR is summed
%                             is required of size DeltaNij for each frame
%
%				Eini		= Initial value of e in rate matching algorithm
%							  This is different for each frame in the TTI therefore
%							  a vector is returned with each element containing
%							  the parameter value for each parameter.
%
%               Eplus       = Updateds Inital Error Error
%               Eminus      = Updateds Inital Error Error
%               yi          = Empty Matrix
%               Fi          = Number of Frames

if DeltaNij ~= 0                    % If Rate Matching is required
    M=1;
    for i = 1:Fi
        IndexRequiredBit = 1;       % Index for determing when Bit is to be kept
        if DeltaNij<0
            E=Eini(i);              % Inital error between current and desired puncturing ratio
            m=1;                    % Index of current bit
            tempIndex = 1;
            while(m<=Xi)
                E = E-Eminus;       % Update Error
                if E<=0             % Check if bit number m should be punctured
                    IndexRequiredBit = IndexRequiredBit -1;
                    M = M-1;
                    E = E+Eplus;
                end
                if tempIndex == IndexRequiredBit            % Determines when a bit in the frame is to be kept
                    yi(m,i) = xi(M);
                    tempIndex = tempIndex +1;
                end
                IndexRequiredBit = IndexRequiredBit +1;     % Update Indexing
                M = M+1;
                m = m+1;
            end
        else
            E = Eini(i);            % Initial error between current and desired puncturing ratio
            m = 1;                  % Index of current bit
            while m <=Xi
                E = E-Eminus;       % Update error
                yi(m,i) = xi(M);
                while E<=0          % Check if bit number m should be repeared
                    yi(m,i) = xi(M)+xi(M+1);
                    IndexRequiredBit = IndexRequiredBit+1;
                    M = M+1;
                    E=E+Eplus;      % Update error
                end
                IndexRequiredBit = IndexRequiredBit+1;
                M = M+1;
                m = m+1;            % Next bit
            end
        end
    end
else
    yi = xi;
end
yi = reshape(yi,1,[]);
end

