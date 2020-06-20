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

%% Reading In File % {{{
    fprintf('Entered E2N_E2P_E2T\n')
    % if bdf is as a filename, finding it and importing it
    if size(bdf,1)==1 && exist(bdf,'file')==2
        fprintf('See that input is a filename. Reading in %s\n',bdf)
        fid = fopen(bdf);
        bdf = textscan(fid,'%s','Delimiter','\n','Whitespace','');
        bdf = char(bdf{:});
        fclose all;
    end % }}}

%% Reading in data to Nodes  % {{{
    [remaining_bdf,Nodes] = gridpoint_extractor(bdf);
    % }}}

%% Declaring and defining 'Types' Structure  % {{{
    % List of Type name strings to match against 
    Types.names = {'CROD';'CBAR';'CBEAM';'CTRIA3';'CQUAD4';'CTRIA6';...
            'CQUAD8';'CQUADR';'CTRIAR';'CSHEAR';'CHEXA';'CPENTA';...
            'CTETRA';'CBUSH'};
    % List of how many lines each element type could possible have
    % NOTE: manually created continuation lines WILL NOT BE TOLERATED!!!
    Types.shortlines = [1;2;3;2;2;2;3;2;2;1;3;3;2;2]; 
    % }}}

%% Creating E2P and E2T % {{{
    % Looping through all types of elements I'm looking for
    E2T = [];
    E2P = [];
    for i = 1:size(Types.names,1)
        type_name = Types.names{i};
        fprintf('Looking for %s\n',type_name)
        % logical vector of length size(remaining_bdf,1) if a given line contains "type_name"
        logicals = (~cellfun(@isempty,cellfun(@(x) regexpi(x,type_name),cellstr(remaining_bdf),'un',0)));
        % Excempting commented lines from logical array
        iscomment = (~cellfun(@isempty,cellfun(@(x) regexpi(x,'^\s{0,}\$'),cellstr(remaining_bdf),'un',0)));
        logicals = and(logicals,not(iscomment));

        % if logicals is empty, there's none of that element type in the bdf
        if sum(logicals) > 0
            fprintf('%s discovered in model %s times\n',type_name,num2str(sum(logicals)))

            % pertinant_lines is all of the lines which contain the type name AT ALL
            pertinant_lines = remaining_bdf(logicals,:);

            % Match 8-Character Fixed Width Fields "($type_name)\s" in pertinant_lines
            space_matches = pertinant_lines(~cellfun(@isempty,cellfun(@(x) regexpi(x,[type_name,' ']), ...
                cellstr(pertinant_lines),'un',0)),:);
            % Match Comma Delimited Fields "($type_name).*\,"
            comma_matches = pertinant_lines(~cellfun(@isempty,cellfun(@(x) regexpi(x,[type_name,'.*,']), ...
                cellstr(pertinant_lines),'un',0)),:);
            % Match 16-Character Fixed Width Fields "($type_name)\*"
            longform_matches = pertinant_lines(~cellfun(@isempty,cellfun(@(x) regexpi(x,[type_name,'\*']), ...
                cellstr(pertinant_lines),'un',0)),:);

            % Populating E2T and E2P matrices 
            if ~isempty(space_matches)
                E2T = [E2T;str2double(space_matches(:,9:16)),ones(size(str2double(space_matches(:,9:16))))*i];
                E2P = [E2P;str2double(space_matches(:,9:16)),str2double(space_matches(:,17:24))];
            end
            if ~isempty(comma_matches)
                fields=cellfun(@(x) strsplit(x,','),cellstr(comma_matches),'un',0);
                fields = vertcat(fields{:});
                E2T = [E2T;str2double(vertcat(fields{:,2})),ones(size(str2double(vertcat(fields{:,2}))))*i];
                E2P = [E2P;str2double(vertcat(fields{:,2})),str2double(vertcat(fields{:,3}))];
            end
            if ~isempty(longform_matches)
                E2T = [E2T;str2double(longform_matches(:,9:24)),i];
                E2P = [E2P;str2double(longform_matches(:,9:24)),str2double(longform_matches(:,25:40))];
            end
        end
        % Will check to see if any lines are continuation lines
        % is continuation line if first eight characters are empty
    end
    % }}}

%% Creating E2N % {{{
    % Recall that the Types.names structure is defined as
% }}}

end
