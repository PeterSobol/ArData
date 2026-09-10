
delete( timerfind('tag','pingtimer'))
pingtimer=timer('tag','pingtimer','TimerFcn',@pingtimerfcn)
pingtimer.executionmode='fixedRate';
pingtimer.period=60;

global pingdata pingtime pingfig
pingdata=[];pingtime=[];
pingfig=figure;
start(pingtimer);


function pingtimerfcn(a,b)
global pingdata pingtime pingfig


[reply d]=system('ping -l 4096 -n 1 RGLAB6');
p=strfind(d,'time');
if p>0;
pingdata=[pingdata sscanf(d(p+5:p+10),'%g')];
pingtime=[pingtime now()];
f=gcf;
figure(pingfig);
plot(pingtime,pingdata,'o');datetick;
figure(f);
end
end