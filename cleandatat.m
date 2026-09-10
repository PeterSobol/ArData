function [x y]=cleandata(x,y,sigma) % remove data points outside of t sigma from the original mean

out=linregresst(x,y);
fit=out.fit(1)+x*out.fit(2);
res=(y-fit);
stdev=std(res);  %XXXX NOTE RLINSTD is not std
rejects=abs(res)>sigma*stdev;
x=x(~rejects);y=y(~rejects);
end