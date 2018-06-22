function [Price, Value, mdls, HASLANDINGTERM]=lobsterpricemodels(yr,LL,LP,stmnth,yrs)
%LOBSTERPRICEMODELS--build price models and generate predictions
%
% [Price, Value, mdls]=lobsterpricemodels(yr,LL,LP,stmnth,yrs)
%
% Builds monthly models of lobster prices and then uses them to predict
% prices based on landings.
%
% yr = (length n) years
% LL = (12-by-n) LL(j,k) is the lobster landings in month j, year k
% LP = (12-by-n) LP(j,k) is the price in month j, year k
% stmnth = month for the first prediction
% yrs = (length m) years to make the predictions for
%
% Price = (p-by-3-by-m) = predicted price. Price(j,:,k) contains the
% predictions for year = yrs(k) for month stmnth+j-1. The three columns are
% the [2.5%, mean, 97.5%]
%
% Value = (3-by-m) = value (landings * predicted price) integrated over the
% prediction period. the rows are [min, mean, max]
%
% The error in the model is bootstrapped by fitting n distinct models for
% each month by leaving out each year and then randomly choosing which 
% model to use. Additional error comes from the first prediction
%
% Copyright 2018, Andrew J. Pershing, Gulf of Maine Research Institute
%

[m,n]=size(LL);
if(length(yr)~=n)
    error('LL must have the same number of columns as yr');
end
if(m~=12)
    error('LL must have 12 rows, one for each month');
end
if(size(LP,1)~=m | size(LP,2)~=n)
    error('LP must be the same size as LL');
end

if(stmnth<2 | stmnth > 12)
    error('stmnth must be between 2 and 12');
end

%find the columns for each year
m=length(yrs);
for j=1:m;
    I=find(yr==yrs(j));
    if(isempty(I))
        error('year %d is outside the range of yr',yrs(j));
    end
    yrcol(j)=I;
end

months=(stmnth:12)';

p=length(months);

%build the models for each month
HASLANDINGTERM=zeros(p,n);%flag for whether the model uses the landings term

for j=1:p
    mn=months(j);
    for k=1:n;
        I=[1:k-1,k+1:n];%months for this model
        m1=fitlm([LP(mn-1,I)]',LP(mn,I)'); %P(t)=P(t-1)
        m2=fitlm([LP(mn-1,I);LL(mn,I)]',LP(mn,I)');%P(t)=P(t-1)+L(t)
        if(m1.ModelCriterion.AIC < m2.ModelCriterion.AIC)
            %autoregressive is better
            mdls{j,k}=m1;
        else
            %full model is better
            mdls{j,k}=m2;
            HASLANDINGTERM(j,k)=1;
        end
    end
end

N=5000;%number of different model combinations
Price=nans(p,3,m);
Value=nans(3,m);
TS=nans(p,N);
VTS=nans(1,N);
for i=1:m;%prediction year
    RM=ceil(rand(p,N)*n);%random models
    for k=1:N;
        P0=LP(stmnth-1,yrcol(i));%initial condition for this year
        for j=1:p
            mID=RM(j,k);%the model
            mn=months(j);
            if(HASLANDINGTERM(j,mID))
                [TS(j,k),ci]=predict(mdls{j,mID},[P0,LL(mn,yrcol(i))]);%mean prediction
            else
                [TS(j,k),ci]=predict(mdls{j,mID},[P0]);%mean prediction
            end
            if(j>1)
                P0=TS(j,k);
            else
                P0=TS(j,k)+randn(1)*(ci(2)-TS(j,k))/1.96;%start with some addition prediction error
            end
        end
        VTS(k)=LL(months,yrcol(i))'*TS(:,k);%value for this set of models
    end
    
    [Vsort,J]=sort(VTS);
    I95=[0.025 0.975]*N;
    I95=round(I95);
    Value(1,i)=Vsort(I95(1));
    Price(:,1,i)=TS(:,J(I95(1)));
    Price(:,2,i)=median(TS,2);
    Value(2,i)=median(VTS);
    Value(3,i)=Vsort(I95(2));
    Price(:,3,i)=TS(:,J(I95(2)));
end
    