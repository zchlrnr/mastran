function nodal_octtree(varargin)
%   This function takes in two lists of nodes and, for each node in list 1,
%   finds the single nearest node in list 2.
    format compact

    N1 = 9000;  % number of nodes in list 1
    N2 = 35000; % number of nodes in list 2
    
    divisor = 5; % number of times a single dimension will be divided| MUST
    % ALWAYS BE LARGER THAN 3!!!

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
    %hold on 

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

    % Need to create octtree for list 2
    for i = 1:divisor
        xmax(i) = ((BB2(1,1)-BB2(1,2))/divisor)*i + BB2(1,2);
        xmin(i) = ((BB2(1,1)-BB2(1,2))/divisor)*(i-1) + BB2(1,2);
        ymax(i) = ((BB2(2,1)-BB2(2,2))/divisor)*i + BB2(2,2);
        ymin(i) = ((BB2(2,1)-BB2(2,2))/divisor)*(i-1) + BB2(2,2);
        zmax(i) = ((BB2(3,1)-BB2(3,2))/divisor)*i + BB2(3,2);
        zmin(i) = ((BB2(3,1)-BB2(3,2))/divisor)*(i-1) + BB2(3,2);
    end
    % Now let's create coordinates for these voxels
    xvol = [1:size(xmax,2)+1];
    yvol = [1:size(ymax,2)+1];
    zvol = [1:size(ymax,2)+1];
    % For every node in list 2, find its xvol, yvol, and zvol
    voxelmap = zeros(size(NL2));
    for i = 1:size(NL2,1)
        voxelmap(i,1) = NL2(i,1); % Node ID
        x = NL2(i,2);
        y = NL2(i,3);
        z = NL2(i,4);
        voxelmap(i,2) = min(find(xmax>=x)); % x voxel coordinate
        voxelmap(i,3) = min(find(ymax>=y)); % y voxel coordinate
        voxelmap(i,4) = min(find(zmax>=z)); % z voxel coordinate
    end
    format long g
    voxelmap
    
    % now have octree for list 2
    % for each node in list 1, 
    %   - find it's voxel coords for list 2s voxelmap
    %   - determine what other voxels it needs to check
    %   - create list of nodes in list 2 in those voxels to check
    for i = 1:size(NL1,1)
        x = NL1(i,2);
        y = NL1(i,3);
        z = NL1(i,4);
        xvoxcoord = min(find(xmax>=x))
        yvoxcoord = min(find(ymax>=y))
        zvoxcoord = min(find(zmax>=z))
        % want to check every neighboring voxel
        % in other words, every voxel whose coordinates are within +/- 1

    end
end
