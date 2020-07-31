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
    % Pre-allocating E2N. No element has more than 20 nodes.
    E2N = zeros(size(remaining_bdf,1),20);
    for i = 1:size(Types.names,1)
        type_name = Types.names{i};
        fprintf('Looking for %s elements\n',type_name)
        % logical vector of length size(remaining_bdf,1) if a given line contains "type_name"
        logicals = (~cellfun(@isempty,cellfun(@(x) regexpi(x,type_name),cellstr(remaining_bdf),'un',0)));
        % Excempting commented lines from logical array
        iscomment = (~cellfun(@isempty,cellfun(@(x) regexpi(x,'^\s{0,}\$'),cellstr(remaining_bdf),'un',0)));
        logicals = and(logicals,not(iscomment));
        pertinant_lines = remaining_bdf(logicals,:);
        % The Nastran allowable syntax for bulk data entries is a clusterfuck
        for j = 1:size(pertinant_lines,1)
            % catch every type of continuation
            % Read Format of Bulk Data Entries in the MSC Nastran QRG
            % Conditional logic of the three format types. {{{
            %     - Free Field Format Rules
            %         * Data starts on column 1
            %         * Commas in succession skip fields
            %     - Small Field Format Rules
            %         * Data starts on column 1
            %     - Large Field Format Rules
            %         * Denoted by asterisk immediately after first string in field 1A
            % Rules of continuation lines 
            %     - If there's a + in field 10, theres a continuation line
            %     - If there's a * in field 1, there's a continuation line
            %     - If there's a * in field 1, there must be a * in column 1 of field 1B (on the next line)
            %     - If field 10 AND field 1 are empty and if the continuation line is non blank, its real.
            % }}}
            % Reading contents of matching line
            cl = pertinant_lines(j,:); % current line
            fields = getfields(cl); % fields in current line
            % Determine how many continuation lines are needed
            % if field 1 matches '^\w+\*' 
            % OR
            % if "field 10 is empty" && "field 1b is ( \s{8} | "*" | "+" )" && 
            %     "fields 11-20 contain any non whitespace"
            N_continuations = 0;
            escape = 0;
            while escape == 0
                % does current line contain asterisk, implying continuation?
                asterisk_flag = logical(~isempty(regexpi(num2str(fields{1}),'^\w+\*','once')));
                % is field 10 empty?
                if ceil(length(cl)/8)<10 
                    f_10_empty = 1;
                elseif ceil(length(deblank(cl))/8)<10
                    f_10_empty = 1;
                end
                % is next line a candidate?
                if j + N_continuations < size(remaining_bdf,1)
                end
                escape=1;
            end
        end
    end
% }}}
end
function fields = getfields(cl) % {{{
    % This subfunction gets a line and splits it into eight character fields
    cl = length(deblank(cl));
    number_of_fields = ceil(length(cl)/8);
    for i = 1:number_of_fields
        fields{i} = cl(i*8-7:min(i*8,length(cl)));
    end
end % }}}
