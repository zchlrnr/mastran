function fixed_number = degenerate_negative(char_in)
    char_in = deblank(char_in);
    L = length(char_in);
    if L > 1 && strncmp(char_in(L-1),'-',1)==1
        fixed_number = str2double(strcat(num2str(...
            char_in(1:(L-2))),'E',num2str(char_in((L-1):L))));
    elseif L > 2 && strncmp(char_in(L-2),'-',1)==1
        fixed_number = str2double(strcat(num2str(...
            char_in(1:(L-3))),'E',num2str(char_in((L-2):L))));
    else
        fixed_number = str2double(char_in);
    end
end
