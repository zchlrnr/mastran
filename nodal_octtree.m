function nearest_node_list = nodal_octtree(varargin)
%   This function takes in two lists of nodes and, for each node in list 1,
%   finds the single nearest node in list 2. If two nodes are very far apart, it won't find them.
%   User input will take the form [NodeList1, NodeList2, number of spatial divisions in each axis]
%   Where each node list is of the form [NID, x coordinate, y coordinate, z coordinate];
    if nargin != 0
        NL1 = varargin{1};
        NL2 = varargin{2};
        divisor = varargin{3};
    else 
        % faking user input for development {{{
        N1 = 9000;  % number of nodes in list 1
        N2 = 35000; % number of nodes in list 2
        
        divisor = 20; % number of times a single dimension will be divided
        % MUST ALWAYS BE LARGER THAN 3! OUGHT ALWAYS BE LARGER THAN 5!

        % creating node IDs and coordinates of the nodes.
        NL1{1} = 1000000+[1:1:N1]'; % if NID starts with 1, it's in group 1
        NL2{1} = 2000000+[1:1:N2]'; % if NID starts with 2, it's in group 2

        % populating NL1
        x1 = rand(N1,1).*3;
        y1 = rand(N1,1).*5;
        z1 = rand(N1,1).*9;
        NL1{2} = x1;
        NL1{3} = y1;
        NL1{4} = z1;
        NL1 = cell2mat(NL1);
        %scatter3(NL1(:,2),NL1(:,3),NL1(:,4),ones(size(N2,1),1)*10,ones(size(N2,1),1)*3)
        %hold on

        % populating NL2
        x2 = rand(N2,1).*9;
        y2 = rand(N2,1).*3;
        z2 = rand(N2,1).*5;
        NL2{2} = x2;
        NL2{3} = y2;
        NL2{4} = z2;
        NL2 = cell2mat(NL2);
        %scatter3(NL2(:,2),NL2(:,3),NL2(:,4),ones(size(N2,1),1)*10,ones(size(N2,1),1)*2)
        %hold on  }}}
    end

    % Bounding Box Around Part 1
    BB1 = [max(NL1(:,2)),min(NL1(:,2));...
        max(NL1(:,3)),min(NL1(:,3));...
        max(NL1(:,4)),min(NL1(:,4))];

    % Bounding box around Part 2
    BB2 = [max(NL2(:,2)),min(NL2(:,2));...
        max(NL2(:,3)),min(NL2(:,3));...
        max(NL2(:,4)),min(NL2(:,4))];

    % Bounding box around assembly
    BB = [max(BB1(1,1),BB2(1,1)),min(BB1(1,2),BB2(1,2));...
        max(BB1(2,1),BB2(2,1)),min(BB1(2,2),BB2(2,2));...
        max(BB1(3,1),BB2(3,1)),min(BB1(3,2),BB2(3,2))];

    % Need to create octtree for a combined list
    for i = 1:divisor
        xmax(i) = ((BB(1,1)-BB(1,2))/divisor)*i + BB(1,2);
        xmin(i) = ((BB(1,1)-BB(1,2))/divisor)*(i-1) + BB(1,2);
        ymax(i) = ((BB(2,1)-BB(2,2))/divisor)*i + BB(2,2);
        ymin(i) = ((BB(2,1)-BB(2,2))/divisor)*(i-1) + BB(2,2);
        zmax(i) = ((BB(3,1)-BB(3,2))/divisor)*i + BB(3,2);
        zmin(i) = ((BB(3,1)-BB(3,2))/divisor)*(i-1) + BB(3,2);
    end
    % Now let's create coordinates for these voxels
    xvol = [1:size(xmax,2)+1];
    yvol = [1:size(ymax,2)+1];
    zvol = [1:size(ymax,2)+1];
    % For every node, find its xvol, yvol, and zvol
    NL = [NL1;NL2];
    voxelmap = zeros(size(NL));
    for i = 1:size(NL,1)
        voxelmap(i,1) = NL(i,1); % Node ID
        x = NL(i,2);
        y = NL(i,3);
        z = NL(i,4);
        voxelmap(i,2) = min(find(xmax>=x)); % x voxel coordinate
        voxelmap(i,3) = min(find(ymax>=y)); % y voxel coordinate
        voxelmap(i,4) = min(find(zmax>=z)); % z voxel coordinate
    end
    format long g

    % now have global octree
    % for each node in list 1, 
    %   - retrieve it's voxel coords
    %   - determine what other voxels it needs to check
    %   - create list of nodes in list 2 in those voxels to check
    %   - get back either that no nodes are close enough, or the node ID in list 2 that's closest
    nearest_node_list = zeros(size(NL1,1),2);
    for i = 1:size(NL1,1) % loop through nodes in NL1 to find the nearest node in NL2{{{
        nearest_node_list(i,1) = NL1(i,1);
        x = NL1(i,2);
        y = NL1(i,3);
        z = NL1(i,4);
        index = find(voxelmap(:,1)==NL(i,1));
        xvoxcoord = voxelmap(index,2); % x voxel coordindate
        yvoxcoord = voxelmap(index,3); % y voxel coordindate
        zvoxcoord = voxelmap(index,4); % z voxel coordindate
        % get expanded voxel coordinate ranges
        % don't want to think of a better way to do this than with six if else
        % statements right now, so that's what it's gonna be.

        % getting x voxel range
        if xvoxcoord == min(xvol) % if is at min of x voxels
            xrange = [1,2];
        elseif xvoxcoord == max(xvol) % if it's at max of x voxels
            xrange = [xvoxcoord-1:xvoxcoord];
        else % if it's in th emiddle of the cloud
            xrange = [xvoxcoord-1:xvoxcoord+1];
        end

        % getting y voxel range
        if yvoxcoord == min(yvol) % if is at min of y voxels
            yrange = [1,2];
        elseif yvoxcoord == max(yvol) % if it's at max of y voxels
            yrange = [yvoxcoord-1:yvoxcoord];
        else % if it's in th emiddle of the cloud
            yrange = [yvoxcoord-1:yvoxcoord+1];
        end

        % getting z voxel range
        if zvoxcoord == min(zvol) % if is at min of z voxels
            zrange = [1,2];
        elseif zvoxcoord == max(zvol) % if it's at max of z voxels
            zrange = [zvoxcoord-1:zvoxcoord];
        else % if it's in th emiddle of the cloud
            zrange = [zvoxcoord-1:zvoxcoord+1];
        end

        % getting nodes in x voxel range
        candidates = voxelmap(voxelmap(:,2)>=(min(xrange)),:);
        candidates = candidates(candidates(:,2)<=max(xrange),:);

        % getting nodes in y voxel range
        candidates = candidates(candidates(:,3)>=min(yrange),:);
        candidates = candidates(candidates(:,3)<=max(yrange),:);

        % getting nodes in z voxel range
        candidates = candidates(candidates(:,4)>=min(zrange),:);
        candidates = candidates(candidates(:,4)<=max(zrange),:);

        % getting nodes that are in NL2
        NodesInNL2 = NL2(ismember(NL2(:,1),candidates(:,1)),:);
        
        % If there are no nodes in NL2 within proximity of current node in NL1, mission accomplished
        if size(NodesInNL2,1) != 0
            % getting distances between current node in NL1 and all pertinant nodes in NL2
            distances = zeros(size(NodesInNL2,1),2);
            for j = 1:size(NodesInNL2,1)
                distances(j,1) = NodesInNL2(j,1);
                distances(j,2) = ((x-NodesInNL2(j,2))^2+...
                    (y-NodesInNL2(j,3))^2+(z-NodesInNL2(j,4))^2)^0.5;
            end
            ClosestNodeInNL2 = distances(distances(:,2)==min(distances(:,2)),1);
            nearest_node_list(i,2) = ClosestNodeInNL2;
        end
    end % }}}
    nearest_node_list = nearest_node_list(nearest_node_list(:,2)!=0,:);
end
