function Z=chronclustlinkage(tv);
%CHRONCLUSTLINKAGE--weight & linkage function for chronological clustering
%
% Z=chronclustlinkage(tv);
%
% tv=m-by-n matrix of data.  Assumes that each row corresponds to a time
% and that the time samples are evenly spaced. Works by adding a time
% column and adjusting the weight so that differences in time lead to a big
% increase in distance.
%
% Z will be the clustering (same structure as Matlab's linkage), but with
% the cluster distances adjusted so that they reflect the data, not the
% time.
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

Z=linkage(d);%organize data into groups
%scale to the distance between the two clusters based on their
%data-distance

[Zmax,p]=max(Z(:,3));
I=Z(p,1);J=Z(p,2);%last cluster
LI=get_leaves(I,Z,m);%build the set of leaves for I & J
LJ=get_leaves(J,Z,m);
davg=0;
for k=1:length(LI);
    for p=1:length(LJ);
        davg=davg+getdist_leaves(LI(k),LJ(p),wd,m);%look up distance in wd
    end
end
davgMX=davg/(length(LI)*length(LJ));%average distance 

[Zmin,p]=min(Z(:,3));
I=Z(p,1);J=Z(p,2);%last cluster
LI=get_leaves(I,Z,m);%build the set of leaves for I & J
LJ=get_leaves(J,Z,m);
davg=0;
for k=1:length(LI);
    for p=1:length(LJ);
        davg=davg+getdist_leaves(LI(k),LJ(p),wd,m);%look up distance in wd
    end
end
davgMN=davg/(length(LI)*length(LJ));%average distance 

Z(:,3)=(Z(:,3)-Zmin)/(Zmax-Zmin)*(davgMX-davgMN)+davgMN;

%now, reorder to 
[Z2,I]=sortrows(Z);
J=I;

for j=1:length(I);
    jL=Z2(j,1);
    jR=Z2(j,2);
    if(jL>m)
        K=find(J==(jL-m));
        Z2(j,1)=K+m;
    end
    if(jR>m)
        K=find(J==(jR-m));
        Z2(j,2)=K+m;
    end
end
Z=Z2;

end
%getdist_leaves
function d=getdist_leaves(I,J,wd,m);
    if(J<I)
        k=I;I=J;J=k;%swap
    end
    n=[0,m-1:-1:1];
    k=(J-I)+sum(n(1:I));
    d=wd(k);
end

%get_leaves
function L=get_leaves(ii,Z,m);
    if(ii<=m);
        L=ii;
    else
        L=[get_leaves(Z(ii-m,1),Z,m),get_leaves(Z(ii-m,2),Z,m)];
    end
end
