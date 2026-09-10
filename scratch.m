for i=1:length(ic0);
ic0out(:,i)= [ic0{i}.S101.ic0.volts ic0{i}.S101.ic0.fit(2) mean(ic0{i}.S101.ic0.slopes) 0 ic0{i}.S101.ic0.time ];
end
ic0out(4,:)=ic0out(2,:)-ic0out(3,:);
plot(ic0out(1,:),ic0out(2,:)-ic0out(3,:),'.')

format bank 
ic0out'

ic1out=[];
for i=1:length(ic1);
ic1out(:,i)= [ic1{i}.S101.ic1.volts ic1{i}.S101.ic1.fit(2) mean(ic1{i}.S101.ic1.slopes) 0 ic1{i}.S101.ic1.time ];
end
ic1out(4,:)=ic1out(2,:)-ic1out(3,:);
plot(ic1out(1,:),ic1out(4,:),'.')

format bank 
ic0out'


for i=1:length(fittemp);
    if isfield(fittemp{i}.S101,'ic0');
        s='ic0';
    else
        s='ic1';
    end
     [pathstr, name, ext] = fileparts(fittemp{i}.S101.(s).fname);
       out{i}.name= name;
       out{i}.volts=fittemp{i}.S101.(s).volts;
end
       