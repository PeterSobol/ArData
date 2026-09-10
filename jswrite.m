function status=jswrite(filepath,instruct)
crlf=[char(13) char(10)];
jsstr=jsonencode(instruct);

jsstr=strrep(jsstr,'\','');
jsstr=strrep(jsstr,'{',['{' crlf]);
jsstr=strrep(jsstr,',',[',' crlf]);

jsstr=strrep(jsstr,'}',[crlf '}']);
jsstr=strrep(jsstr,']',[crlf ']']);
jsstr=strsplit(jsstr,crlf);

openp=[0 strfind(jsstr,'{')];
openp=~cellfun(@isempty,openp);

closep=[0 strfind(jsstr,'}')  ];
closep=~cellfun(@isempty,closep);
tabno=cumsum(openp)-cumsum(closep);

utabno=unique(tabno);
utabno(utabno==0)=[];
strout=[];
for i=1:length(jsstr);
    strout=[strout [repmat(char(9),1,2*tabno(i)) jsstr{i} crlf]];
end

try
fid=fopen(fullfile(filepath),'w');
if fid>0
    fprintf(fid,'%s',strout);
    fclose(fid);
    status=true;
else
    status=false;
end
catch ME
   msgbox('Can not create JSON file')    
     disp(ME);disp(ME.stack(1));
     try fclose(fid);catch;end
end


