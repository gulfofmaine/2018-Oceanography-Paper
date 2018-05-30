function T=linkage2tree(Z,m);
%LINKAGE2TREE--Matlab's linkage structure to a tree-struct
%
% T=linkage2tree(Z,m);
%
% Converts Matlab's linkage output into a tree structure.
%
% 
% copyright 2018, Andrew J. Pershing, Gulf of Maine Research Institute
% 


B.parent=[];
B.left=[];
B.right=[];
B.id=0;
B.val=[];

n=length(Z);
T=repmat(B,1,m+length(Z));
for j=1:m+n;
    T(j).id=j;
end
for j=1:n;
    zl=Z(j,1);
    T(j+m).left=zl;
    T(zl).parent=j+m;
    zr=Z(j,2);
    T(j+m).right=zr;
    T(zr).parent=j+m;
    T(j+m).val=Z(j,3);
end
    