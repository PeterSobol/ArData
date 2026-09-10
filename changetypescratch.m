dp='C:\Users\raregas\Pychron3\data\.dvc\repositories\NOB-Cocktail\NAG';

direc=dir(dp);

direc([direc.isdir])=[];

for i=1:length(direc);

    fid=fopen(fullfile(dp,direc(i).name));
    a=char(fread(fid,'uint8')');
fclose(fid);
a=strcat(a);
a=strrep(a,'analysis_type":"air"','analysis_type":"cocktail"');
a=strrep(a,'analysis_type":"Air"','analysis_type":"cocktail"');
%a=[a(1:fa+15) "cocktail" a(fa+19,end)];

a=strrep(a,'NOB-Air','NOB-Cocktail');
fid=fopen(fullfile(dp,direc(i).name),'w');
fwrite(fid,a);
fclose(fid);
end



