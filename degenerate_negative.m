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

    % This is a deceptively infuriating problem.
    % Let me explain: {{{
    %{
    a number like ' 12.5-6 ' is easy. It should be 12.5E-6
    HOWEVER if it ALREADY IS 12.5E-6, then doing the same find and
    replace of '-' with 'E-' would put E there twice.
    So perhaps that's the answer for what to do?.. Just look for E twice
    and then replace it with E once? 

    BUT NO because now leading negatives or positive signs break
    everything. So you need a way to define what a "leading" symbol is,
    which sounds easy, but then you need to make sure you throw away
    standalone prints of either of those special character.

    Did I mention the fact that you can't even be fucking sure that the
    string passed has a length greater than one so you can't even
    logically index it away with char_in(1) as leading digit and then
    operating upon only char_in(2:end) BECAUSE THERES A CHANCE CALLING
    THAT SECOND TERM BREAKS THE REFERENCE GOD DAMMIT
    %}
    %}}}

    if L > 1 % if the length of the number to check is greater than one
        % if contains neg or plus sign in not leading character
        special_char_location = regexpi(char_in(2:end),'[\-\+]');
        if ~isempty(special_char_location)
            % replacing said character with 'E' and then that character
            fixed_number = [char_in(1:special_char_location),...
            'E',char_in(special_char_location+1:end)];

            % replacing 'EE' values with a single E
            fixed_number = strrep(fixed_number,'EE','E');

            % Converting fixed_number from string to double
            fixed_number = str2double(fixed_number);
        else
            fixed_number = str2double(char_in);
        end
    end
end
