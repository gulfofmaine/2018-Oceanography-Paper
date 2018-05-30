function T = chrontree( T,yr )
%CHRONTREE--orders a binomial tree

j=1;

while(isempty(T(j).val))
    T(j).mean=yr(T(j).id);%mean is the year
    T(j).count=1;
    j=j+1;
end
m=j-1;%the leaves
if(m~=length(yr))
    error('expect to have a leaf for each year');
end
n=length(T)-m;
%zero the sums on the nodes and find the root.
for j=m+1:m+n
    T(j).mean=0;
    T(j).count=0;
    if(isempty(T(j).parent))
        root=j;
    end
end


for j=1:m;
    %add each leaf's sum to its parents
    child=j;
    %disp(j);
    while(~isempty(T(child).parent))
        k=T(child).parent;
        T(k).mean=T(k).mean+T(j).mean;
        T(k).count=T(k).count+1;
        child=k;
        %fprintf('\t\t%d\n',k);
    end
end
for j=m+1:m+n;
    if(T(j).count>0)
        T(j).mean=(T(j).mean)/T(j).count;
    else
        error('Tree is not connected: node %d is not connected',j);
    end
end

for j=m+1:m+n;
    jL=T(j).left;
    jR=T(j).right;
    sL=T(jL).mean;
    sR=T(jR).mean;
    if(sR<sL & (jL>m & jR>m));
        S=T(jL);
        T(jL)=T(jR);
        T(jR)=S;
        T(jL).id=jL;
        T(jR).id=jR;
    end
end


