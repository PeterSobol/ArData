a=1000;b=1000;n=1000;amp=100;
d=a*t+b;
 d=repmat(d,n,1);
 d=d+randn(size(d))*amp;
 s=100;
 
 for i=1:n;
[x y]=cleandatat(t,d(i,:),s);
out=linregresst(x,y);
f(i)=out.fit(2);
end;
 [mean(f-a) rms(f-a)]
o=[];
for s=.1:.2:4;

for i=1:n;
[x y]=cleandatat(t,d(i,:),s);
out=linregresst(x,y);
g(i)=out.fit(2);
end;
o=[o;s rms(g-a)];
end
o
