function status=writetoexcel(data)
global fileinfo
fileflag='old';
%%  append a cell array to an excel file
status='';
if ~isfield(fileinfo,'outputfilepath') ||  isempty(fileinfo.outputfilepath) || ~exist(fileinfo.outputfilepath,'file') % need to create file
    [filename, pathname ]=uiputfile('*.xls','specify output xls file');
    if pathname ~=0;
        fileinfo.outputfilepath=[pathname filename];
        set(findobj('tag','edOutputExcelFile'),'string',fileinfo.outputfilepath)
        if exist(fullfile(pathname, filename),'file')==2; % not appending to an exising file
            fileinfo.lineno=NaN;fileflag='old';  % file already exists, append
        else
            fileinfo.lineno=0;fileflag='new';
        end
        
    end
else
   fileflag='old';
end



switch fileflag
    case 'old'
        % find the last row in the file
        e=actxserver('Excel.Application');
        ewb=e.WorkBooks.Open(fileinfo.outputfilepath);
        esh=ewb.activesheet;
        esh.Activate
        ar=esh.UsedRange;
        ar.SpecialCells('xlCellTypeLastCell').Activate;

        fileinfo.lineno=e.ActiveCell.Row;
        
        ewb.Close; % clean up
  
        Quit(e);delete(e)
        
    case 'new'
        % write a header
        if isfield(fileinfo,'header') && ~isempty(fileinfo.header); % need to write a header
            xlswrite(fileinfo.outputfilepath,fileinfo.header,'','A1');
            fileinfo.lineno=1;
            
        end
end
hdl=msgbox(['Writing records to file ' fileinfo.outputfilepath ' at row ' num2str(fileinfo.lineno+1)]);
xlswrite(fileinfo.outputfilepath,data,'',['A' num2str(fileinfo.lineno+1)]);
fileinfo.lineno=fileinfo.lineno+1;
close(hdl);

% try
%     temp=xlsread(fileinfo.outputfilepath);
%     if size(temp,1)>0;
%     fileinfo.lineno=size(temp,1)+2;
%     end
% catch
%     msgbox('Output File not Found')
%     [filename pathname ]=uiputfile('*.xls','specify output xls file');
%     if ~isempty(filename)
%         fileinfo.outputfilepath=[pathname filename];
%         set(findobj('tag','edResultsFile'),'string',fileinfo.outputfilepath);
%         fileinfo.lineno=0;
%     end
% end

% if fileinfo.lineno==0 & isfield(fileinfo,'header') & ~isempty(fileinfo.header); % need to write a header
%     xlswrite(fileinfo.outputfilepath,fileinfo.header,'','A1');
%     fileinfo.lineno=1;
% end

end