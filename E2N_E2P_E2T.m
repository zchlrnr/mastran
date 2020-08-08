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
%  *  degenerate_negative.m                                        %
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
    fprintf('\n Reading in data to Nodes\n')
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
        fprintf('Looking for %s Element\n',type_name)
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
    % getting length of each line in order to check for continuation criteria
    length_of_each_line = vertcat(cellfun(@size,cellstr(remaining_bdf),'un',0));
    length_of_each_line = vertcat(length_of_each_line{:});
    length_of_each_line = length_of_each_line(:,2);
    for i = 1:size(Types.names,1)
        type_name = Types.names{i};
        fprintf('Looking for %s Elements\n',type_name)
        % logical vector of length size(remaining_bdf,1) if a given line contains "type_name"
        logicals = (~cellfun(@isempty,cellfun(@(x) regexpi(x,['^',type_name]),...
            cellstr(remaining_bdf),'un',0)));
        pertinant_lines = remaining_bdf(logicals,:);
        % Let's start off by trying to do it fully vectorized
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
        % METHOD IDEA!!
        %{
        - For each match, store its line number in matrix 'a' as the first column
            (a(:,1)=find(logicals)
        - in the second column, store the logicals + the number of lines forward we must check
            (a(:,2)=a(:,1)+2*Types.shortlines(i))
        - Work from there
        %}

        % continuation_ranges is a two column array of where a match is, followed by the line where
        % the longest possible matching line would stop.
        continuation_ranges = [find(logicals),find(logicals)+Types.shortlines(i)];
        % prototype with loop
        % make a column vector where the values are 0,1, or 2 where
        %   - 0 == useless get rid of it
        %   - 1 == original line
        %   - 2 == relevant continuation line
        % day is 2020.08.08
        % have the idea to just try a loop again because I found out how to read a fixed width line
        % automatically. it's cl = [cl,repmat(' ',1,8-mod(size(cl,2),8))]; cl=reshape(cl,8,[]);
        % start off with vector of '1's where I have element tags I know I need
        action_vector = double(logicals);
        for j = 1:size(continuation_ranges,1)
            line_start = continuation_ranges(j,1);
            line_end = continuation_ranges(j,2);
            % catch end of file exception
            line_end = min(line_end,size(remaining_bdf,1));
            for k = line_start:line_end
                cl = remaining_bdf(k,:);
                if size(cl,2)==0
                    action_vector(k)=0;
                elseif logical(strcmpi(cl(1),'*'))
                    action_vector(k)=2;
                elseif strcmpi(cl(1),'+')
                    action_vector(k)=2;
                elseif strcmpi(cl(1),'$')
                    action_vector(k)=0;
                end
            end
        end
        % now have action_vector which is logicals with extra data
        if not(isempty(action_vector))
            lines_to_check = [find(~action_vector==0),action_vector(find(~action_vector==0))];
        end
        % will check each line_to_check and then rip pertinant data from it
    end

    cd ..
    save workstack
    cd mastran
end
