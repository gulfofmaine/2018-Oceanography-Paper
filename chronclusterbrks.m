function brks=chronclusterbrks(T,val);
%CHRONCLUSTERBRKS--uses chronological clustering to find breakpoints 
%
% brks=chronclusterbrks(T,val);
%
% T = chron tree structure (see chroncluster)
% val = value to define breaks.  Breaks will be taken from clusters with
% values >= val
%
% brks = sequence of years to break.  Note that if the times in T were not
% integers, this could give some funny values
%
%
% copyright 2018, Andrew J. Pershing, Gulf of Maine Research Institute
% 

[levels,ranges]=treeranges(T); %get the ranges

I=find(levels(:,2)>=val);

B=ranges(I,:);
I=find((B(:,2)-B(:,1))==1);
if(~isempty(I));%some singletons
    Bsing=B(I,:);
    B(I,:)=[];
    Bsp=span(B);%should be full range
    for j=1:length(I)
        if(Bsing(j,1)~=Bsp(1) & Bsing(j,2)~=Bsp(2))
            J=find(B==Bsing(j,1) | B==Bsing(j,2));
            B(J)=mean(Bsing(j,:));%replace singleton breaks with the year
        end
    end
end
B=unique(B);
brks=B(2:end-1);


