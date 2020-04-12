function [E2N,E2P,E2T,remaining_bdf] = E2N_E2P_E2T(bdf)
%------------------------------------------------------------------%
%                     Theory Of Operations                         %
%------------------------------------------------------------------%
%  * Rips element data from the bdf. Leaves the rest alone.        %
%  * Can either take in a bdf as plaintext or as a filename        %
%------------------------------------------------------------------%
%                         Dependants                               %
%------------------------------------------------------------------%
%  *  gridpoint_extractor.m                                        %

%% Reading In File
    fprintf('Entered E2N_E2P_E2T\n')
    % if bdf is as a filename, finding it and importing it
    if size(bdf,1)==1 && exist(bdf,'file')==2
        fprintf('See that input is a filename. Reading in %s\n',bdf)
        fid = fopen(bdf);
        bdf = textscan(fid,'%s','Delimiter','\n','Whitespace','');
        bdf = char(bdf{:});
        fclose all;
    end

%% Reading in data to Nodes
    [remaining_bdf,Nodes] = gridpoint_extractor(bdf);

%% Preparing Sieve for E2T

    % List of Type name strings to match against 
    Types.names = {'CROD';'CBAR';'CBEAM';'CTRIA3';'CQUAD4';'CTRIA6';...
            'CQUAD8';'CQUADR';'CTRIAR';'CSHEAR';'CHEXA';'CPENTA';...
            'CTETRA';'CBUSH'};

    % List of how many lines each element type could possible have
    % NOTE: manually created continuation lines are AND WILL NOT BE TOLERATED!!!
    Types.shortlines = [1;2;3;2;2;2;3;2;2;1;3;3;2;2];


    % Looping through all types of elements I'm looking for
    bdfcell = cellstr(bdf);
    for i = 1:size(Types.names,1)
        type_name = Types.names{i};

        % get logical array of rows which match the Type Name
        logical_matches = ~cellfun(@isempty,cellfun(@(x) regexpi(x,type_name),...
            bdfcell,'UniformOutput',false));

        % if there is at least one match
        if sum(logical_matches)>0
            % the number of lines I can look ahead without running into end of file
            lines_can_look_ahead = ...
                min(Types.shortlines(i), size(bdf,1) - max(find(logical_matches)));

            % Appending lines that could be continuation lines to match lines
            offset_logicals = logical_matches;
            for j = 1:lines_can_look_ahead
                offset_logicals = [0;offset_logicals(1:end-1)];
                logical_matches = or(logical_matches,offset_logicals);
            end
        end

        % Will check to see if any lines are continuation lines
        % is continuation line if first eight characters are empty
        relevant_lines = bdfcell(logical_matches);
        if ~isempty(relevant_lines)
        end

    end
end
