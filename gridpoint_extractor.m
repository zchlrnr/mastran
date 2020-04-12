function [remaining_bdf,gridpoints] = gridpoint_extractor(bdf)
%------------------------------------------------------------------%
%                     Theory Of Operations                         %
%------------------------------------------------------------------%
% yoinks the GRID cards from the nastran deck. Leaves the rest alone
% I've outdone myself. This takes either the filename 
% or the character matrix while processing input
    if size(bdf,1)==1 && exist(bdf,'file')==2
        fid=fopen(bdf);
        bdf=textscan(fid,'%s','Delimiter','\n');
        bdf=char(bdf{:});
    end

    remaining_bdf=char(zeros(size(bdf,1),size(bdf,2))); %this will be a reduced bdf
    gridpoints=zeros(size(bdf,1),4);
    for i = 1:size(bdf,1)
        current_line = bdf(i,:);
        if strcmpi('GRID,',current_line(1:5))==1
            fields=strsplit(current_line,',');
            fields=deblank(char(fields{:}));
            %checking for long form strings
            if strcmpi(deblank(fields(1,:)),'GRID')
                NID = str2double(fields(2,:));
                x = (degenerate_negative(fields(3,:)));
                y = (degenerate_negative(fields(4,:)));
                z = (degenerate_negative(fields(5,:)));
                gridpoints(i,:)=[NID,x,y,z];
            end
        elseif strcmpi('GRID ',current_line(1:5))==1
            pause(1)
            NID = str2double(current_line(9:16));
            x = (degenerate_negative(current_line(25:32)));
            y = (degenerate_negative(current_line(33:40)));
            z = (degenerate_negative(current_line(41:min(length(current_line),48))));
            gridpoints(i,:)=[NID,x,y,z];
        elseif strcmpi('GRID*',current_line(1:5))==1
            NID = str2double((current_line(9:24)));
            x = (degenerate_negative(current_line(41:56)));
            y = (degenerate_negative(current_line(57:min(72,length(current_line)))));
            next_line = bdf(i+1,:);
            z = (degenerate_negative(next_line(9:min(length(next_line),24))));
            gridpoints(i,:)=[NID,x,y,z];
        % I don't want to weed out comments yet that's kind excessive
        else
             remaining_bdf(i,:)=current_line;
        end
    end
    remaining_bdf = remaining_bdf(any(remaining_bdf,2),:);
    gridpoints = gridpoints(any(gridpoints,2),:);
    fclose all;
end
