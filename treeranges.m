function [levels,ranges]=treeranges(T);
%TREERANGES--get the ranges of each level of a chron-tree
%
% [levels,ranges]=treeranges(T);
%
% levels = [depth, value at that depth]
% ranges = [min, max]

%1. find the root

root=1;
while(~isempty(T(root).parent));
    root=T(root).parent;
end

[levels,ranges]=treerangechicken(T,root,0);
D=[levels,ranges];
D=sortrows(D);
levels=D(:,1:2);
ranges=D(:,3:4);

%%%%%%%%%%%%%%

function [levels,ranges]=treerangechicken(T,root,lev);

left=T(root).left;
right=T(root).right;
if(isempty(left) & isempty(right))
    %this is a leaf
    levels=[lev,0];
    ranges=[-0.5 0.5]+T(root).mean;
else
    [Llev,Lrng]=treerangechicken(T,left,lev+1);
    [Rlev,Rrng]=treerangechicken(T,right,lev+1);
    if(Llev(1,2)==0)
        Llev(1,2)=T(root).val;
    end
    if(Rlev(1,2)==0);
        Rlev(1,2)=T(root).val;
    end
    levels=[[lev,T(root).val];Llev;Rlev];
    ranges=[span([Lrng;Rrng]);Lrng;Rrng];
end