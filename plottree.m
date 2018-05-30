function [h]=plottree(T);
%PLOTTREE--plots a tree structure
%
% 

c=1;
ysp=0;
for j=1:length(T);
    if(~isempty(T(j).left));%has children
        L=T(j).left;
        xL=T(L).mean;
        yL=T(L).val;
        if(isempty(yL))
            yL=0;
        end
        
        R=T(j).right;
        xR=T(R).mean;
        yR=T(R).val;
        if(isempty(yR))
            yR=0;
        end
        
        xC=T(j).mean;
        yC=T(j).val;
        
        h(c)=plot([xL,xL,xR,xR],[yL,yC,yC,yR]);hold on;
        ysp=max([ysp,yL,yC,yC,yR]);%range of y values
        c=c+1;
    end
end
set(h,'color','k');



        