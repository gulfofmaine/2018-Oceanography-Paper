function d=chronclustweight(tv);
%CHRONCLUSTWEIGHT--weight function for chronological clustering
%
% d=chronclustweight(tv);
%
% tv=m-by-n matrix of data.  Assumes that each row corresponds to a time
% and that the time samples are evenly spaced. Works by adding a time
% column and adjusting the weight so that differences in time lead to a big
% increase in distance.
%
%
% copyright 2018, Andrew J. Pershing, Gulf of Maine Research Institute
% 


if(isvector(tv))
    tv=tv(:);%column
end
[m,n]=size(tv);

wd=pdist(tv);%ordinary distance for the data
wT=pdist((1:m)');

dd=max(wd);%max distance based on the data
wT=wT*10*dd;%10 times the max distance in the data

d=wT+wd;
d=d/20*dd;%rescale
