g=guidata(gcf);
nudata=g.nudata;

s1c0y=nudata.S101.ic0data;
s1c1y=nudata.S101.ic1data;
s1c2y=nudata.S101.ic2data;
s1c3y=nudata.S101.ic3data;
s1t=nudata.S101.datatime;

s2c0y=nudata.S102.ic0data;
s2c1y=nudata.S102.ic1data;
s2c2y=nudata.S102.ic2data;
s2c3y=nudata.S102.ic3data;
s2t=nudata.S102.datatime;


xlswrite('c:\users\raregas\desktop\nudata.xls',[s1t s1c0y s1c1y s1c2y c1c3y]);

