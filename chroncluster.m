function T=chroncluster(TS);
%CHRONCLUSTER--chronological cluster analysis
%
% T=chroncluster(TS)
%
% Takes a time series in TS form and returns the chronological clustering
% as a "chron tree."  
%
% TS = m-by-2 = [yr, value]
%
% T will be a struct array containing a binary tree. Each entry represents 
% either a year (a leaf) or a branch containing several leaves.  T has
% fields:
% 
%     parent--the identity of the entry that is the parent
%     left--the identity of the child on the left
%     right--the identity of the child on the right
%     id--the identity
%     val--the level of the cluster
%     mean--the mean year of all leaves under this cluster
%     count--the number of leaves under this cluster
%
% copyright 2018, Andrew J. Pershing, Gulf of Maine Research Institute
% 

[m,n]=size(TS);
if(n~=2)
    error('TS form must have two columns [time, value]');
end
%build something like Matlab's linkage functions
L=chronclustlinkage(TS(:,2));
%convert to a tree
T1=linkage2tree(L,m);
%convert to a chron tree
T=chrontree(T1,TS(:,1));