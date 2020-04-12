function fixed_number = degenerate_negative(char_in)
%------------------------------------------------------------------%
%                     Theory Of Operations                         %
%------------------------------------------------------------------%
% Take in character array that must be a number
% Strips away all whitespace from start and end with strtrim
% replaces all '-' characters with 'E' if they aren't in position 1
% ditto for '+' characters.
% will break if raised to a power of ten in the hundreds place

    char_in = strtrim(char_in);
    L = length(char_in);

    % Repairing negatives
    if L > 1 && strcmpi(char_in(L-1),'-')==1
        fixed_number = str2double(strcat(num2str(...
            char_in(1:(L-2))),'E',num2str(char_in((L-1):L))));
    elseif L > 2 && strcmpi(char_in(L-2),'-')==1
        fixed_number = str2double(strcat(num2str(...
            char_in(1:(L-3))),'E',num2str(char_in((L-2):L))));
    else
        fixed_number = str2double(char_in);
    end

    % Repairing positives
    if L > 1 && strcmpi(char_in(L-1),'+')==1
        fixed_number = str2double(strcat(num2str(...
            char_in(1:(L-2))),'E',num2str(char_in((L-1):L))));
    elseif L > 2 && strcmpi(char_in(L-2),'+')==1
        fixed_number = str2double(strcat(num2str(...
            char_in(1:(L-3))),'E',num2str(char_in((L-2):L))));
    else
        fixed_number = str2double(char_in);
    end

end
