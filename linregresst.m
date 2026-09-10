function out=linregresst(x,y) % find the linear fit coefficents that best fit x to y.  y=a+bx;
%adapted directly from "Numerical Recipes" Chapter 15.2

n=length(x);
sx=sum(x);
sy=sum(y);

t=(x-sx/n);
stt=sum(t.^2);
b=(1/stt)*sum(t.*y);
a=(sy-sx*b)/n;

chisquare=sum((y-a-b*x).^2);
correct=sqrt(chisquare/(n-2));
asigma=sqrt((1+(sx.^2)/(n*stt))/n)*correct;
bsigma=sqrt(1/stt)*correct;

out.fit=[a b];out.sigma=[asigma bsigma];
end

function [x y]=cleandata(x,y,sigma) % remove data points outside of t sigma from the original mean

out=linregress(x,y);
fit=out.fit(1)+x*out.fit(2);
res=(y-fit);
stdev=std(res);  %XXXX NOTE RLINSTD is not std
rejects=abs(res)>sigma*stdev;
x=x(~rejects);y=y(~rejects);
end