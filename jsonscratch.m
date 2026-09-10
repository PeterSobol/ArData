out=jsencode(in);
crlf=[char(13) char(10)];
jsstr=jsonencode(in);

jsstr=strrep(strrep(strrep(jsstr,'{',['{' '@']),',',[',' '@']),'}',[ '@' '}']);
locs=findstr(jsstr,'@');

tabstr=(jsstr=='{')-(jsstr=='}');
tabstr=[cumsum(tabstr) 0];
cells={};
cells(1)={jsstr(1:locs(1))};
for i=2:length(locs);
    cells(i)={jsstr(locs(i-1)+1:locs(i)-1)};
   % cells(i)={strcat(repmat(char(9),1,tabstr(locs(i))),cells{i})};
    tabs(i)=tabstr(locs(i+1));
end
cells(i+1)={jsstr(locs(i)+1:end)};

for i=1:length(cells);
    cells(i)={[repmat(char(9),1,(tabs(i))) cells{i}]};
       
end
stvcat(cells)