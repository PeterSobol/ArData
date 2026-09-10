function varargout = ArData(varargin)
% ARDATA M-file for ArData.fig
%      ARDATA, by itself, creates a new ARDATA or raises the existing
%      singleton*.
%
%      H = ARDATA returns the handle to a new ARDATA or the handle to
%      the existing singleton*.
%
%      ARDATA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ARDATA.M with the given input arguments.
%
%      ARDATA('Property','Value',...) creates a new ARDATA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ArData_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ArData_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ArData

% Last Modified by GUIDE v2.5 29-Jul-2021 09:47:42

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @ArData_OpeningFcn, ...
    'gui_OutputFcn',  @ArData_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before ArData is made visible.
function ArData_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ArData (see VARARGIN)

% Choose default command line output for ArData
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
addpath(pwd);
global gitinfo

if isdeployed % Stand-alone mode.
    [status, result] = system('path');
    gitinfo.ArDataDir = char(regexpi(result, 'Path=(.*?);', 'tokens', 'once'))
else % MATLAB mode.
   gitinfo.ArDataDir=fileparts(which('ArData.m'));
end

updateoptions;
gitinfo.ScratchFolder='c:\program data\ArData';
if ~isdir(gitinfo.ScratchFolder)
    mkdir(gitinfo.ScratchFolder);
end

gitinfo.localrepopath=get(handles.edPychronRepoPath,'string');
if ~strcmp(gitinfo.localrepopath,filesep);
    gitinfo.localrepopath= [gitinfo.localrepopath filesep];
end
if isdir(gitinfo.localrepopath);% local repo exists
    %do nothing
else
    gitinfo.localrepopath=fullfile('C:','repository');
    if isdir(gitinfo.localrepopath);
        %do nothing
    else
        mkdir(gitinfo.localrepopath);
        cd(gitinfo.localrepopath);
        system(['git init .']);
    end
end
disp(['Local repopath: ' gitinfo.localrepopath]);

if ~isfield(gitinfo,'repolist');gitinfo.repolist=[];end

addpath(gitinfo.ArDataDir);% add the path so I can move around when handling the git stuff;
disp('@ArData.m line 93, gitinfo:') ;disp(gitinfo);
if ~isdeployed
try;addpath gitclasses;catch;disp('@ArData.m line 95 Error adding gitclasses directory');end;
end

% UIWAIT makes ArData wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ArData_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in puPanelSelect.
function puPanelSelect_Callback(hObject, eventdata, handles)
% hObject    handle to puPanelSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

contents = cellstr(get(hObject,'String'));
str= contents{get(hObject,'Value')};

set(findobj('-regexp','tag','pn'),'visible','off');
set(findobj('title',str),'visible','on');



% --- Executes during object creation, after setting all properties.
function puPanelSelect_CreateFcn(hObject, eventdata, handles)
% hObject    handle to puPanelSelect (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edDatabaseName_Callback(hObject, eventdata, handles)
% hObject    handle to edDatabaseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edDatabaseName as text
%        str2double(get(hObject,'String')) returns contents of edDatabaseName as a double
global qinfo
qinfo=[];% reset the db connection

% --- Executes during object creation, after setting all properties.
function edDatabaseName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edDatabaseName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function txStartDate_Callback(hObject, eventdata, handles)
% hObject    handle to txStartDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txStartDate as text
%        str2double(get(hObject,'String')) returns contents of txStartDate as a double

set(hObject,'string',datestr(get(hObject,'string'),'mm/dd/yy'));



% --- Executes during object creation, after setting all properties.
function txStartDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txStartDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string',datestr(now-14,'mm/dd/yy'))


function txEndDate_Callback(hObject, eventdata, handles)
% hObject    handle to txEndDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txEndDate as text
%        str2double(get(hObject,'String')) returns contents of txEndDate as a double
set(hObject,'string',datestr(get(hObject,'string'),'mm/dd/yy'));

% --- Executes during object creation, after setting all properties.
function txEndDate_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txEndDate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string',datestr(now+1,'mm/dd/yy'))


% --- Executes on button press in pbPopulate.
function pbPopulate_Callback(hObject, eventdata, handles)
% hObject    handle to pbPopulate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.lbFileSelection,'visible','off');

% tbl1=get(handles.edMSDataTable,'string');tbl2= get(handles.edPrepDataTable,'string');
% 
% when1=get(handles.txStartDate,'string');when2=get(handles.txEndDate,'string');

tblMSData=get(handles.edMSDataTable,'string');tblPrepData= get(handles.edPrepDataTable,'string');
tblNiceResults=get(handles.edNiceResultsTable,'string');
when1=get(handles.txStartDate,'string');when2=get(handles.txEndDate,'string');

s=['if exists (select * from sysobjects where name = ''temptable'') DROP TABLE temptable'];
doquery(s);%try;doquery(s);catch;end
if startsWith(s,'Error','IgnoreCase',true)
    return
end
s=['if exists (select * from sysobjects where name = ''hasniceresults'') DROP VIEW hasniceresults'];
res=doquery(s);%try;doquery(s);catch;end
if startsWith(s,'Error','IgnoreCase',true)
    return
end
% s=[' SELECT ' tbl1 '.*, ' tbl2 '.* INTO temptable '];
% s = [s ' FROM ' tbl1 ' LEFT OUTER JOIN ' tbl2 ' ON ' tbl1 '.MSRunIdentifier = ' tbl2 '.RunIdentifier '];
% wheres=[' WHERE (((tblMSData.MSAcqTime) Between ''' when1 ''' And ''' when2 ''')); '];
% s = [ s wheres];

% much faster to link on ID_MSData

 s= [ ' SELECT ' tblMSData '.*, ' tblPrepData '.* INTO temptable '];
s= [ s ' FROM  ' tblMSData ' INNER JOIN ' tblPrepData ' ON ' tblMSData '.ID_MSData = ' tblPrepData '.ID_MSAnalysis '];
 wheres=[' WHERE (((tblMSData.MSAcqTime) Between ''' when1 ''' And ''' when2 ''')); '];
 s = [ s wheres];


res=doquery(s);
if startsWith(s,'Error','IgnoreCase',true)
    return
end
s=['select column_name,* from information_schema.columns '];
s = [s  ' where table_name = ''temptable'' '];
s= [s ' order by ordinal_position' ];

res=doquery(s);
if startsWith(s,'Error','IgnoreCase',true)
    return
end

% get the limits for each column
for i=1:length(res.column_name);
    switch(res.data_type{i})
        case 'datetime'
            s= [ 'SELECT Min(' res.column_name{i} ') AS mintime, Max(' res.column_name{i} ') AS maxtime' ];
            s = [ s ' From temptable ' ];
            res2=doquery(s);
            buildui(i).name=res.column_name{i};
            buildui(i).type='dt';
            buildui(i).control='editminmax';
            buildui(i).items = {res2.mintime, res2.maxtime};
        case {'int', 'real', 'smallint'}
            s= ['  SELECT ' res.column_name{i} ' AS ' res.column_name{i} ' FROM temptable GROUP BY ' res.column_name{i} ';'];
            res2=doquery(s);
            buildui(i).name=res.column_name{i};
            if length(res2.(lower(res.column_name{i})))<20;
                buildui(i).control='list';
                buildui(i).items = res2.(lower(res.column_name{i}));
                buildui(i).type='enum';
            else
                
                buildui(i).items = [min([res2.(lower(res.column_name{i})){:}]); max([res2.(lower(res.column_name{i})){:}])];
                buildui(i).type='rangenum';
            end
            
        case {'decimal','numeric'}
            s= ['  SELECT ' res.column_name{i} ' AS ' res.column_name{i} ' FROM temptable GROUP BY ' res.column_name{i} ';'];
            res2=doquery(s);
            buildui(i).name=res.column_name{i};
            %       lower(res.column_name{i})(cellfun(@(lower(res.column_name{i}) any(isnan(lower(res.column_name{i}))),lower(res.column_name{i})))) = [];
            x=res2.(lower(res.column_name{i}));
            
            x(cellfun(@(x) any(isnan(x)),x)) = [];
            if iscellstr(x);x=str2double(x);x=num2cell(x);end;
            if length(x)<10;
                buildui(i).control='list';
                %             buildui(i).items = res2.(lower(res.column_name{i}));
                buildui(i).items = x;
                buildui(i).type='enum';
            else
                
                %           buildui(i).items = [min([res2.(lower(res.column_name{i})){:}]); max([res2.(lower(res.column_name{i})){:}])];
                buildui(i).items = [min([x{:}]); max([x{:}])];
                buildui(i).type='rangenum';
            end
            
            
        case 'nvarchar'
            s= ['  SELECT ' res.column_name{i} ' AS ' res.column_name{i} ' FROM temptable GROUP BY ' res.column_name{i} ' ORDER BY ' res.column_name{i} ' ;'];
            res2=doquery(s);
            buildui(i).name=res.column_name{i};
            buildui(i).type='text';
            buildui(i).control='list';
            buildui(i).items = res2.(lower(res.column_name{i}));
            if ~iscell(buildui(i).items);buildui(i).items={buildui(i).items};end
        case 'nchar'
            s= ['  SELECT ' res.column_name{i} ' AS ' res.column_name{i} ' FROM temptable GROUP BY ' res.column_name{i} ' ORDER BY ' res.column_name{i} ';'];
            res2=doquery(s);
            buildui(i).name=res.column_name{i};
            buildui(i).type='text';
            buildui(i).control='list';
            buildui(i).items = res2.(lower(res.column_name{i}));
            if ~iscell(buildui(i).items);buildui(i).items={buildui(i).items};end
            
            
        case 'bit'
            
            buildui(i).name=res.column_name{i};
            buildui(i).type='bit';
            buildui(i).control='bit';
            buildui(i).items = logical([0 1]);
            
        case 'ntext'
            buildui(i).name=res.column_name{i};
            buildui(i).type='text';
            buildui(i).control='';
            %buildui(i).items = logical([0 1]);
            
        otherwise
         
            buildui(i).name=res.column_name{i};
            buildui(i).type='uk';
            msgbox(['undefinded data type case found: ' res.column_name{i} ',' res.data_type{i}]);
    end
    
end

parenth=findobj('tag','pnRawDataFitting');

delete(findobj('-regexp','tag','buildtemp'));
height=1.3;
for i=1:length(buildui); %construct the display fields
    v=51-i*height;h=1;
    pos=[h v 20 1.3];
    
    buildui(i).handle(1)=uicontrol('parent',parenth,'style','togglebutton','string',buildui(i).name,...
         'units','characters','position',pos,'tag','buildtemp');

    h=22;w=24;
    switch buildui(i).type
        case 'dt'
            pos=[h v w 1.3];
            buildui(i).handle(2)=uicontrol('parent',parenth,'style','edit', ...
                'string',buildui(i).items{1},'units','characters','position',pos,'tag','buildtemp',...
                'backgroundcolor',[1 1 1],'callback',@valuechanged,'userdata',buildui(i));
            pos=[h+w v w 1.3];
            buildui(i).handle(3)=uicontrol('parent',parenth,'style','edit',...
                'string',buildui(i).items{2},'units','characters','position',pos,'tag','buildtemp',...
                'backgroundcolor',[1 1 1],'callback',@valuechanged,'userdata',buildui(i));
        case 'text'
            pos=[h v w 1.3];
            buildui(i).handle(2)=uicontrol('parent',parenth,'style','popupmenu',...
                'string', vertcat({'*'}, buildui(i).items),'units','characters','position',pos,...
                'tag','buildtemp','backgroundcolor',[1 1 1],'callback',@valuechanged,'userdata',buildui(i));
        case 'enum'
            pos=[h v w 1.3];
            buildui(i).handle(2)=uicontrol('parent',parenth,'style','popupmenu',...
                'string', vertcat({'*'}, buildui(i).items),'units','characters','position',pos,...
                'tag','buildtemp','backgroundcolor',[1 1 1],'callback',@valuechanged,'userdata',buildui(i));
            
        case 'rangenum'
            
            pos=[h v w 1.3];
            buildui(i).handle(2)=uicontrol('parent',parenth,'style','edit','string',...
                buildui(i).items(1),'units','characters','position',pos,'tag','buildtemp',...
                'backgroundcolor',[1 1 1],'callback',@valuechanged,'userdata',buildui(i));
            pos=[h+w v w 1.3];
            buildui(i).handle(3)=uicontrol('parent',parenth,'style','edit','string',...
                buildui(i).items(2),'units','characters','position',pos,'tag','buildtemp',...
                'backgroundcolor',[1 1 1],'callback',@valuechanged,'userdata',buildui(i));
        case 'bit'
            
            pos=[h v w 1.3];
            buildui(i).handle(2)=uicontrol('parent',parenth,'style','popupmenu',...
                'string',{'*','True','False'},'units','characters','position',pos,...
                'tag','buildtemp','backgroundcolor',[1 1 1],'callback',@valuechanged,'userdata',buildui(i));
            
            
    end
    pos=[h+2*w v w 1.3];
    buildui(i).handle(4)=uicontrol('parent',parenth,'style','edit','string',...
        '','units','characters','position',pos,'tag','buildtemp',...
        'backgroundcolor',[1 1 1],'callback',@valuechanged,'userdata',buildui(i));
end


v=51-(i+2)*height;
pos=[h+w v w 2.6];
buildgo=uicontrol('parent',parenth,'style','pushbutton','string','Get Records','units','characters','position',pos,'tag','buildtemp', ...
    'callback',@buildgocallback,'userdata',buildui);


function edDatabaseServer_Callback(hObject, eventdata, handles)
% hObject    handle to edDatabaseServer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edDatabaseServer as text
%        str2double(get(hObject,'String')) returns contents of edDatabaseServer as a double
global qinfo
qinfo=[];% reset the db connection


% --- Executes during object creation, after setting all properties.
function edDatabaseServer_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edDatabaseServer (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edDatabaseID_Callback(hObject, eventdata, handles)
% hObject    handle to edDatabaseID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edDatabaseID as text
%        str2double(get(hObject,'String')) returns contents of edDatabaseID as a double
global qinfo
qinfo=[];% reset the db connection


% --- Executes during object creation, after setting all properties.
function edDatabaseID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edDatabaseID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edDatabasePassword_Callback(hObject, eventdata, handles)
% hObject    handle to edDatabasePassword (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edDatabasePassword as text
%        str2double(get(hObject,'String')) returns contents of edDatabasePassword as a double
global qinfo
qinfo=[];% reset the db connection


% --- Executes during object creation, after setting all properties.
function edDatabasePassword_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edDatabasePassword (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edMSDataTable_Callback(hObject, eventdata, handles)
% hObject    handle to edMSDataTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edMSDataTable as text
%        str2double(get(hObject,'String')) returns contents of edMSDataTable as a double


% --- Executes during object creation, after setting all properties.
function edMSDataTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edMSDataTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edPrepDataTable_Callback(hObject, eventdata, handles)
% hObject    handle to edPrepDataTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edPrepDataTable as text
%        str2double(get(hObject,'String')) returns contents of edPrepDataTable as a double


% --- Executes during object creation, after setting all properties.
function edPrepDataTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edPrepDataTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbGetAllRecords.
function pbGetAllRecords_Callback(hObject, eventdata, handles)
% hObject    handle to pbGetAllRecords (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global arinfo qinfo
qinfo.DB.DefaultDatabase='ARDATA';
%populates the file selection listbox with all records between dates.
delete(findobj('-regexp','tag','buildtemp'));
tblMSData=get(handles.edMSDataTable,'string');tblPrepData= get(handles.edPrepDataTable,'string');
tblNiceResults=get(handles.edNiceResultsTable,'string');
when1=get(handles.txStartDate,'string');when2=get(handles.txEndDate,'string');
tblanalysistbl='[PYCHRON].dbo.AnalysisTbl';
tblanalysisintensitiestbl= '[PYCHRON].dbo.AnalysisIntensitiesTbl';
tblreptbl= '[PYCHRON].dbo.RepositoryAssociationTbl';

s=['if exists (select * from sysobjects where name = ''temptable'') DROP TABLE temptable'];
doquery(s);%try;doquery(s);catch;end
s=['if exists (select * from sysobjects where name = ''hasniceresults'') DROP VIEW hasniceresults'];
doquery(s);%

 s= [ ' SELECT ' tblMSData '.*, ' tblPrepData '.* INTO temptable '];
s= [ s ' FROM  ' tblMSData ' INNER JOIN ' tblPrepData ' ON ' tblMSData '.MSRunIdentifier  = ' tblPrepData '.RunIdentifier  '];
 wheres=[' WHERE (((tblMSData.MSAcqTime) Between ''' when1 ''' And ''' when2 ''')); '];
 s = [ s wheres];

doquery(s);
%
s=[' create view hasniceresults as '];
s=[s 'SELECT  max(temptable.MSRunIdentifier) as MSRunIdentifier, '];
s= [s ' case when MAX(cast(temptable.MSExclude AS int)) =1 then ''EX'' '];
%s= [s 'CASE when MAX(tbltoPychron.Identifier) IS NULL then ''N'' ELSE ''Y'' END as inPychron '];
s= [s ' when max(' tblNiceResults '.NRRunIdentifier) IS NULL then ''NF'' ELSE ''FIT'' END as hasnice '];
s= [s ' FROM temptable LEFT OUTER JOIN ' tblNiceResults ' ON  temptable.MSRunIdentifier = ' tblNiceResults '.NRRunIdentifier '];
%s= [s ' LEFT OUTER JOIN tbltoPychron ON temptable.MSRunIdentifier = tbltoPychron.RunIdentifier ' ];  
s=[s ' GROUP BY temptable.MSRunIdentifier  '];

doquery(s);

% doquery('DROP VIEW pychrontemp ');
% s=['CREATE VIEW pychrontemp as '];
% s= [s ' SELECT ProjectName,tbltoPychron.Aliquot,tbltoPychron.Increment,temptable.MSRunIdentifier, ' tblreptbl '.AnalysisID '];
% s= [s ', CASE when (tbltoPychron.Identifier) IS NULL then ''N'' ELSE ''Y'' END as toPychron  '];
% s= [s ', CASE when ' tblanalysistbl '.ID IS Null then ''N'' ELSE ''Y'' END as InPychron from tblToPychron ' ];
% s= [s ' RIGHT OUTER JOIN temptable ON  tbltoPychron.RunIdentifier = temptable.MSRunIdentifier '];
% s= [s 'LEFT OUTER JOIN ' tblanalysistbl ' on temptable.MSRunIdentifier= ' tblanalysistbl '.uuid'];


doquery('DROP VIEW pychrontemp ');
s=['CREATE VIEW pychrontemp as '];
s= [s 'SELECT       tblToPychron.ProjectName, tblToPychron.Increment, tblToPychron.Aliquot, temptable.MSRunIdentifier '];
 s= [s ', CASE when ' tblreptbl '.analysisID IS Null then ''N'' ELSE ''Y'' END as InRepo ' ];
  s= [s ', CASE when (tbltoPychron.Identifier) IS NULL then ''N'' ELSE ''Y'' END as toPychron  '];
s= [s 'FROM  ' tblreptbl ' RIGHT OUTER JOIN '];
s= [s ' ' tblanalysistbl ' RIGHT OUTER JOIN '];
s= [s ' tblToPychron RIGHT OUTER JOIN '];
s= [s '  temptable ON tblToPychron.RunIdentifier = temptable.MSRunIdentifier '];
s= [s ' ON PYCHRON.dbo.AnalysisTbl.uuid = tblToPychron.RunIdentifier '];
s= [s ' ON  ' tblreptbl '.analysisID =  ' tblanalysistbl '.id'];
doquery(s); 


    

s=[ ' select hasnice,toPychron,ProjectName, Aliquot,Increment,InRepo,toPychron, * from temptable '];
s=[s ' Inner Join hasniceresults on temptable.MSRunIdentifier = hasniceresults.MSRunIdentifier '];
s=[ s ' LEFT OUTER JOIN pychrontemp on temptable.msRunIdentifier = pychrontemp.MSRunIdentifier '];
%s=[ s ' LEFT OUTER JOIN inrepo on temptable.msRunIdentifier = pychrontemp.MSRunIdentifier '];
s=[s ' ORDER BY temptable.MSAcqTime '];


res=doquery(s);

if ~isempty(res);
res.samplename=strrep(res.samplename,char(10),'');
warning('off')% suppress warnings during parsing

fl=get(findobj('tag','edDisplayFields'),'string');
fl=lower(fl);
commas=repmat(', ',size(res.(fl{1}),1),1);
out=strvcat(res.(fl{1}));

for i=2:length(fl);
    out=[out commas strvcat(char(res.(fl{i}){:}))];
end



warning('on')

set(handles.lbFileSelection,'string',out,'visible','on','value',[1:size(res.(fl{1}),1)],'userdata',res);
else % no records found
    
   warndlg('No Records Found!') 
end

% --- Executes on selection change in edDisplayFields.
function edDisplayFields_Callback(hObject, eventdata, handles)
% hObject    handle to edDisplayFields (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns edDisplayFields contents as cell array
%        contents{get(hObject,'Value')} returns selected item from edDisplayFields


% --- Executes during object creation, after setting all properties.
function edDisplayFields_CreateFcn(hObject, eventdata, ~)
% hObject    handle to edDisplayFields (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% tbl1=get(handles.edMSDataTable,'string');tbl2= get(handles.edPrepDataTable,'string');
%
%
% s=['select column_name,* from information_schema.columns '];
% s = [s  ' where table_name = ''' tbl1 ''' or table_name = ''' tbl2 ''];
% s= [s ' order by ordinal_position' ];
%
% res=doquery(s);


% --- Executes on selection change in lbFileSelection.
function lbFileSelection_Callback(hObject, eventdata, handles)
% hObject    handle to lbFileSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lbFileSelection contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbFileSelection


% --- Executes during object creation, after setting all properties.
function lbFileSelection_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbFileSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edOutputExcelFile_Callback(hObject, eventdata, handles)
% hObject    handle to edOutputExcelFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edOutputExcelFile as text
%        str2double(get(hObject,'String')) returns contents of edOutputExcelFile as a double


% --- Executes during object creation, after setting all properties.
function edOutputExcelFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edOutputExcelFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbOutputExcelFile.
function pbOutputExcelFile_Callback(hObject, eventdata, handles)
% hObject    handle to pbOutputExcelFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

resultspathstring=get(handles.edOutputExcelFile,'string');

[FileName PathName FilterIndex] = uiputfile(resultspathstring);

fileinfo.outputfilepath=[PathName FileName];
set(handles.edOutputExcelFile,'string',fileinfo.outputfilepath);


function edNiceFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to edNiceFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edNiceFilePath as text
%        str2double(get(hObject,'String')) returns contents of edNiceFilePath as a double


% --- Executes during object creation, after setting all properties.
function edNiceFilePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edNiceFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbNiceFilePath.
function pbNiceFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to pbNiceFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbProcessSelection.
function pbProcessSelection_Callback(hObject, eventdata, handles)
% hObject    handle to pbProcessSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get data for each of the files in the list and then call the fitting
% window for each.
global output gitinfo
filesep=getfilesep;
% if ~isempty(hObject.parent)
% res=hObject.parent.UserData;
% else
res=get(handles.lbFileSelection,'userdata');
% end
selected=get(handles.lbFileSelection,'value');
fitoptions.lotsafiles=false;
if length(selected)>30;
    fitoptions.lotsafiles=true;
    button = questdlg('You have selected a large number of files, do you want to continue?', ...
        'Whoa there Missy-','Continue','Cancel','Cancel');
    if ~strcmp(button,'Continue');
        return;
    end
end


outputpath=get(handles.edOutputExcelFile,'string');
if isempty(outputpath);outputpath=['.' filesep];end
if ~strcmp(outputpath(end),filesep);outputpath=[outputpath filesep];end

for i=selected;
    disp(res.msrunidentifier(i));
    if strncmp(res.msdatapath{i},'C:',2); %replace local file path if necessary
        res.msdatapath{i}=[get(handles.edNuInsC,'string'),res.msdatapath{i}(3:end)];
    end
    filepath=[res.msdatapath{i} res.msdatafile{i}];
    nudata=loadNuDataFile([filepath]);
    
    fl=fields(res);
    for fli=1:length(fl);
        dbdata.(fl{fli})=res.(fl{fli}){i};end
    
    fitoptions.nicefilepath=handles.edNiceFilePath.String;
    fitoptions.sigma=str2double(handles.edCleanDataSigma.String);
    fitoptions.autoclose=handles.rbAutoClose.Value;
    fitoptions.autosave=handles.rbAutoSave.Value;
    fitoptions.sectoexclude=str2double(handles.edSecToExclude.String);
    fitstrings=handles.puDefaultFitType.String;
    fitoptions.fittype=fitstrings{handles.puDefaultFitType.Value};
    fitoptions.maxcycles=str2double(handles.edMaxCycles.String);
    fitoptions.timezerooffset=str2double(handles.edTimeZeroOffset.String);
    fitoptions.updatepychron=handles.rbUpdatePychron.Value;
    fitoptions.displayflag=handles.rbDisplayFlag.Value;
    
    output=fitnudata(nudata,dbdata,fitoptions);
    % outstring{i}=[filepath ' ' nudata.IC_HT];
    
    
end
if fitoptions.updatepychron;
try
    h=msgbox('Git push in progress ...');
for i=1:length(gitinfo.repolist)
    if gitinfo.repolist(i).haschanges
        h.Children(2).Children.String={['Git pushing:' gitinfo.repolist(i).name ' ...' ]};drawnow;
        gitpush(gitinfo.repolist(i));
    end
end
catch
end
delete(h)
end
% global fileinfo
% fileinfo.lineno=0;
% fileinfo.header={'Date/time','File Name','Sample Name','Intercept: IC0','IC0_Err','IC1','IC1_Err','IC2','IC2_Err','IC3','IC3_Err','FC','FC_Err'};
% filesep=getfilesep;
%
%
% sourcepath=[get(handles.edSource,'string') filesep];
% listvalues=get(handles.lbSourceDirectory,'value');
% if ~isempty(listvalues)
%
% list=handles.direc(listvalues);
%
% outputpath=get(handles.edResultsFile,'string');
% if isempty(outputpath);outputpath=['.' filesep];end
% if ~strcmp(outputpath(end),filesep);outputpath=[outputpath filesep];end
%
%
%
% if ~isempty(list)
%
%    for i=1:length(list);
%
%        nudata=loadNuDataFile([sourcepath list(i).name]);
%        output=fitnudata(nudata);
%    end
%
% end
%
% end


% --- Executes on selection change in puDefaultFitType.
function puDefaultFitType_Callback(hObject, eventdata, handles)
% hObject    handle to puDefaultFitType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns puDefaultFitType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from puDefaultFitType


% --- Executes during object creation, after setting all properties.
function puDefaultFitType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to puDefaultFitType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edCleanDataSigma_Callback(hObject, eventdata, handles)
% hObject    handle to edCleanDataSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edCleanDataSigma as text
%        str2double(get(hObject,'String')) returns contents of edCleanDataSigma as a double


% --- Executes during object creation, after setting all properties.
function edCleanDataSigma_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edCleanDataSigma (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function filesep=getfilesep
if ispc;    filesep='\';else  filesep='/';end % filesep for type of computator


function status=addmessage(message)

pmhdl=findobj('tag','lbProcessMessages');
messages=get(pmhdl,'string');
messages=[messages;message];
set(pmhdl,'string',messages,'value',length(messages))
status=1;



function edit14_Callback(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit14 as text
%        str2double(get(hObject,'String')) returns contents of edit14 as a double


% --- Executes during object creation, after setting all properties.
function edit14_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit14 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function edNuInsC_Callback(hObject, eventdata, handles)
% hObject    handle to edNuInsC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edNuInsC as text
%        str2double(get(hObject,'String')) returns contents of edNuInsC as a double


% --- Executes during object creation, after setting all properties.
function edNuInsC_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edNuInsC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbNuInsC.
function pbNuInsC_Callback(hObject, eventdata, handles)
% hObject    handle to pbNuInsC (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pbCorrectSelection.
function pbCorrectSelection_Callback(hObject, eventdata, handles)
% hObject    handle to pbCorrectSelection (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% get the list of selected files and pass them to the correction window.


filesep=getfilesep;
res=get(handles.lbFileSelection,'userdata');

selected=get(handles.lbFileSelection,'value');

hasnice= strcmp(res.hasnice,'FIT');
selectvec=zeros(size(hasnice));
selectvec(selected)=1;
selected=find(selectvec & hasnice);

for i=1:length(selected);
    if strncmp(res.msdatapath{selected(i)},'C:',2); %replace local file path if necessary
        res.msdatapath{selected(i)}=[get(handles.edNuInsC,'string'),res.msdatapath{selected(i)}(3:end)];
    end
end

% rearrange structure
flds=fields(res);
for fl=1:length(flds);
    [dbdata(1:length(selected)).(flds{fl})]=deal(res.(flds{fl}){selected});
end

%enter the correction routine
if ~isempty(dbdata);
    output=correctnudata(dbdata);
    
end


function edNiceResultsTable_Callback(hObject, eventdata, handles)
% hObject    handle to edNiceResultsTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edNiceResultsTable as text
%        str2double(get(hObject,'String')) returns contents of edNiceResultsTable as a double


% --- Executes during object creation, after setting all properties.
function edNiceResultsTable_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edNiceResultsTable (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function buildgocallback(src,event)
handles=guidata(src);
tblMSData=get(handles.edMSDataTable,'string');tblPrepData= get(handles.edPrepDataTable,'string');
tblNiceResults=get(handles.edNiceResultsTable,'string');
tblanalysistbl='[PYCHRON].dbo.AnalysisTbl';
tblanalysisintensitiestbl= '[PYCHRON].dbo.AnalysisIntensitiesTbl';
tblreptbl= '[PYCHRON].dbo.RepositoryAssociationTbl';

buildui=get(src,'userdata');

for i=1:length(buildui);
    use=get(buildui(i).handle(1),'value');
    if use; % only work with selected filters.
        field=get(buildui(i).handle(1),'string');
        
        switch(buildui(i).type);
            case 'dt'
                d1=char(get(buildui(i).handle(2),'string'));
                d2=char(get(buildui(i).handle(3),'string'));
                if strcmp(d1,'NaN');
                    buildui(i).whereclause='';
                else
                    if ~strcmp(d1,buildui(i).items(1)) || ~strcmp(d2,buildui(i).items(2))
                        if ~isempty(d1) && ~isempty(d2)
                            buildui(i).whereclause=[' (temptable.' field ' between ''' d1 ''' and ''' d2 ''') '];
                        else
                            if ~isempty(d1)
                                buildui(i).whereclause=[' (temptable.' field ' > ''' d1 ''') '];
                            else
                                buildui(i).whereclause=[' (temptable.' field ' < ''' d2 ''') '];
                            end
                        end
                    end
                end
                
            case 'text'
                strings=get(buildui(i).handle(2),'string');
                item=strings{get(buildui(i).handle(2),'value')};
                expression=get(buildui(i).handle(4),'string');
                if ~strcmp(item,'*')
                    buildui(i).whereclause=[' (temptable.' field ' = ''' deblank(item) ''') '];
                elseif ~isempty(expression);
                    buildui(i).whereclause=[' (temptable.' field ' like ''' expression ''') '];
                else
                    buildui(i).whereclause='';
                end
                
            case 'enum'  % enumerated number type
                strings=get(buildui(i).handle(2),'string');
                item=strings{get(buildui(i).handle(2),'value')};
                expression=get(buildui(i).handle(4),'string');
                if ~isempty(expression);
                    
                    remain = expression;
                    accum={};
                    while true
                        [str, remain] = strtok(remain, ',');
                        if isempty(str),  break; else accum=[accum str]; end
                        
                    end
                    if regexp(accum{1}(1),'[0-9]');accum{1}=['=' accum{1}];end % stick a '=' in front of a case without operators
                    buildui(i).whereclause=[' (temptable.' field '  ' accum{1} ' '];
                    for accumindex=2:length(accum)
                        if regexp(accum{accumindex}(1),'[0-9]');accum{accumindex}=['=' accum{accumindex}];end % stick a '=' in front of a case without operators
                        buildui(i).whereclause=[buildui(i).whereclause ' OR temptable.' field ' ' accum{accumindex} ' '];
                    end
                    buildui(i).whereclause=[buildui(i).whereclause ') '];
                    
                elseif ~strcmp(item,'*')
                    buildui(i).whereclause=[' (temptable.' field ' = ' item ') '];
                    
                else
                    buildui(i).whereclause='';
                end
                
                
                
            case 'rangenum'
                dmin=char(get(buildui(i).handle(2),'string'));
                dmax=char(get(buildui(i).handle(3),'string'));
                expression=get(buildui(i).handle(4),'string');
                if ~isempty(expression)
                    remain = expression;
                    accum={};
                    while true
                        [str, remain] = strtok(remain, ',');
                        if isempty(str),  break; else accum=[accum str]; end
                        
                    end
                    if regexp(accum{1}(1),'[0-9]');accum{1}=['=' accum{1}];end % stick a '=' in front of a case without operators
                    buildui(i).whereclause=[' (temptable.' field '  ' accum{1} ' '];
                    for accumindex=2:length(accum)
                        if regexp(accum{accumindex}(1),'[0-9]');accum{accumindex}=['=' accum{accumindex}];end % stick a '=' in front of a case without operators
                        buildui(i).whereclause=[buildui(i).whereclause ' OR temptable.' field ' ' accum{accumindex} ' '];
                    end
                    buildui(i).whereclause=[buildui(i).whereclause ') '];
                else
                    if ~isempty(dmin) && ~isempty(dmax)
                        buildui(i).whereclause=[' (temptable.' field ' between ' dmin ' and ' dmax ') '];
                    else
                        if ~isempty(dmin)
                            buildui(i).whereclause=[' (temptable.' field ' > ' dmin ') '];
                        else
                            buildui(i).whereclause=['(temptable.' field ' < ' dmax ') '];
                        end
                    end
                end
            case 'bit'
                
                strings=get(buildui(i).handle(2),'string');
                item=strings{get(buildui(i).handle(2),'value')};
                
                if ~strcmp(item,'*')
                    buildui(i).whereclause=[' (temptable.' field ' = ''' item ''') '];
                else
                    buildui(i).whereclause='';
                end
                
                
        end
    end
end
whereclause=[];

if isfield(buildui,'whereclause'); % test that anyfields where filtered.
wh=strvcat(buildui.whereclause);
if ~isempty(wh);
    whereclause=[' WHERE ' strtrim(wh(1,:))];
    
    for i=2:size(wh,1);
        whereclause=[whereclause ' AND ' strtrim(wh(i,:))];
        
    end
end
end


% s=[' select * from temptable ' whereclause];
% res=doquery(s);

delete(findobj('tag','buildtemp'));

s=[' create view hasniceresults as '];
s=[s 'SELECT  max(temptable.MSRunIdentifier) as MSRunIdentifier, '];
s= [s ' case when MAX(cast(temptable.MSExclude AS int)) =1 then ''EX'' '];
s= [s ' when max(' tblNiceResults '.NRRunIdentifier) IS NULL then ''NF'' ELSE ''FIT'' END as hasnice '];
s= [s ' FROM temptable LEFT OUTER JOIN ' tblNiceResults ' ON  temptable.MSRunIdentifier = ' tblNiceResults '.NRRunIdentifier'];
s=[s ' GROUP BY temptable.MSRunIdentifier '];

doquery(s);


doquery('DROP VIEW pychrontemp ');
s= ['CREATE VIEW pychrontemp as '];
s= [s 'SELECT       tblToPychron.ProjectName, tblToPychron.Increment, tblToPychron.Aliquot, temptable.MSRunIdentifier '];
 s= [s ', CASE when ' tblreptbl '.analysisID IS Null then ''N'' ELSE ''Y'' END as InRepo ' ];
  s= [s ', CASE when (tbltoPychron.Identifier) IS NULL then ''N'' ELSE ''Y'' END as toPychron  '];
s= [s 'FROM  ' tblreptbl ' RIGHT OUTER JOIN '];
s= [s ' ' tblanalysistbl ' RIGHT OUTER JOIN '];
s= [s ' tblToPychron RIGHT OUTER JOIN '];
s= [s '  temptable ON tblToPychron.RunIdentifier = temptable.MSRunIdentifier '];
s= [s ' ON PYCHRON.dbo.AnalysisTbl.uuid = tblToPychron.RunIdentifier '];
s= [s ' ON  ' tblreptbl '.analysisID =  ' tblanalysistbl '.id'];
doquery(s); 
  

s=[ ' select hasnice,toPychron,ProjectName, Aliquot,Increment,InRepo,toPychron, * from temptable '];
s=[s ' Inner Join hasniceresults on temptable.MSRunIdentifier = hasniceresults.MSRunIdentifier '];
s=[ s ' LEFT OUTER JOIN pychrontemp on temptable.msRunIdentifier = pychrontemp.MSRunIdentifier '];
%s=[ s ' LEFT OUTER JOIN inrepo on temptable.msRunIdentifier = pychrontemp.MSRunIdentifier '];
s=[s whereclause];
s=[s ' ORDER BY temptable.MSAcqTime '];




% 
% 
% s=[' select hasnice, * from temptable Inner Join hasniceresults on temptable.MSRunIdentifier = hasniceresults.MSRunIdentifier ' whereclause];
% s=[s ' ORDER BY temptable.MSAcqTime ;'];

res=doquery(s);

if ~isempty(res)
    
    warning('off')% suppress warnings during parsing
    
    fl=get(findobj('tag','edDisplayFields'),'string');
    fl=lower(fl);
    commas=repmat(', ',size(res.(fl{1}),1),1);
    if  isa([res.(fl{1}){1}],'numeric')
        out=strvcat( num2str([res.(fl{1}){:}]'));
    else
        out=strvcat(res.(fl{1}));
    end
   
    for i=2:length(fl);
        % isa([res.(fl{i}){:}],'numeric');
        if  isa([res.(fl{i}){:}],'numeric')
            out=[out commas strvcat(num2str([res.(fl{i}){:}]'))];
        else
            
            
            out=[out commas strvcat(char(res.(fl{i}){:}))];
        end
    end
    
    
    
    warning('on')
    
    set(handles.lbFileSelection,'string',out,'visible','on','value',[1:size(res.(fl{1}),1)],'userdata',res);
end


% --- Executes on button press in rbAutoClose.
function rbAutoClose_Callback(hObject, eventdata, handles)
% hObject    handle to rbAutoClose (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbAutoClose



function edMaxCycles_Callback(hObject, eventdata, handles)
% hObject    handle to edMaxCycles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edMaxCycles as text
%        str2double(get(hObject,'String')) returns contents of edMaxCycles as a double


% --- Executes during object creation, after setting all properties.
function edMaxCycles_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edMaxCycles (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edSecToExclude_Callback(hObject, eventdata, handles)
% hObject    handle to edSecToExclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edSecToExclude as text
%        str2double(get(hObject,'String')) returns contents of edSecToExclude as a double


% --- Executes during object creation, after setting all properties.
function edSecToExclude_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edSecToExclude (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edTimeZeroOffset_Callback(hObject, eventdata, handles)
% hObject    handle to edTimeZeroOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edTimeZeroOffset as text
%        str2double(get(hObject,'String')) returns contents of edTimeZeroOffset as a double


% --- Executes during object creation, after setting all properties.
function edTimeZeroOffset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edTimeZeroOffset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbSaveSettings.
function pbSaveSettings_Callback(hObject, eventdata, handles)
% hObject    handle to pbSaveSettings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global gitinfo
optionshdl=get(hObject,'parent');
%get all controls on options panel
controls= get(optionshdl,'children');
% get rid of text controls
controls(~strcmp(get(controls,'type'),'uicontrol'))=[];
controls(strcmp(get(controls,'style'),'text'))=[];
controls(strcmp(get(controls,'style'),'pushbutton'))=[];
tags=get(controls,'tag');
cstrings=get(controls,'string');
styles=get(controls,'style');
values=get(controls,'value');
save(fullfile(gitinfo.ArDataDir,'ArData-options.ini'),'tags','cstrings','styles','values');





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function updateoptions
global gitinfo
try
    options=load(fullfile(gitinfo.ArDataDir,'ArData-options.ini'),'-mat');
    for i=1:length(options.tags);% find the new handles
        hdl(i)=findobj('tag',options.tags{i});
    end
    
    index=strcmp(options.styles,'edit');
    for i=find(index(:))';
        set(hdl(i),'string',options.cstrings{i});
    end
    for i=find(~index(:))';
        set(hdl(i),'value',options.values{i});
    end
    
catch ME
    msgbox('Unable to update options');
    disp(ME);disp(ME.stack(1));
end

function valuechanged(src,event)
buildui=get(src,'userdata');
if ishandle(buildui.handle(1));
    set(buildui.handle(1),'value',1);
end


% --- Executes on button press in tbMonitor.
function tbMonitor_Callback(hObject, eventdata, handles)
% hObject    handle to tbMonitor (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbMonitor

%turn on/off auto monitor and display of data.

onoff=get(hObject,'value');
switch onoff
    case 0
        % turn off
        timerhandle=timerfind('tag','AutoMonitorTimer');
        if ~isempty(timerhandle);
            stop(timerhandle);delete(timerhandle);
        end
        set(hObject,'BackgroundColor',[.94 .5 .5]);
    case 1
        
        % kill the old ones.
        timerhandle=timerfind('tag','AutoMonitorTimer');
        set(hObject,'BackgroundColor',[.5 .94 .5]);
        if ~isempty(timerhandle);
            stop(timerhandle);delete(timerhandle);
        end
        % turn on
        timerhandle=timer('tag','AutoMonitorTimer','Timerfcn',{@AutoMonTimerCallback,handles},...
            'StartFcn',{@AutoMonTimerStart,handles},'period',10,...
            'ExecutionMode','fixedRate');
        start(timerhandle);
end

% 
% function AutoMonTimerStart(timerobj,data,handles)
% %get the last entry in the database
% tblMSData=get(handles.edMSDataTable,'string');
% timefield = 'MSAcqTime';
% 
% s=[' SELECT MSRunIdentifier, '  timefield  ' FROM '  tblMSData   ' '];
% s=[s ' WHERE '  timefield  ' in (Select MAX('  timefield  ' ) from ' tblMSData ' WHERE MsName = ''NOB'') '];
% 
% res=doquery(s);
% timerobj.userdata=res; % save current last record to timeruserdata
% set(handles.txLastAcq,'String',[res.msrunidentifier{:} ' ' res.msacqtime{:}]);
% 
% 
% function AutoMonTimerCallback(timeobj,event,handles)
% set(handles.tbMonitorData,'backgroundcolor',[.25 .25 0.5]);drawnow;pause(.05);
% 
% tblMSData=get(handles.edMSDataTable,'string');
% timefield = 'MSAcqTime';
% tblPrepData=get(handles.edPrepDataTable,'string');
% 
% s=[' SELECT MSRunIdentifier, '  timefield  ' FROM '  tblMSData   ' '];
% s=[s ' WHERE '  timefield  ' in (Select MAX('  timefield  ' ) from ' tblMSData ' WHERE MsName = ''NOB'') '];
% 
% res=doquery(s);
% lastdata=get(timeobj,'UserData');
% disp([lastdata.msrunidentifier res.msrunidentifier])
% if strcmp(lastdata.msrunidentifier,res.msrunidentifier);
%     % match % carry on.
%     
% else
%     disp(['Fitting ' res.msrunidentifier]);
%     % no match - process
%     %
%     % check and close old windows
%     figs=findobj('tag','figFitDisplay-auto');
%     nodisplays=size(figs,1);
%     if nodisplays>3;
%         try
%         list=sortrows([[1:length(figs)]' [figs.Number]'],2);
%         list(1,end-3:end)
%         close(figs(list(end-2:end,1)));% close all but the last 3 figs
%         catch ME
%             disp(ME);disp(ME.stack(1));
%         end
%     end
%     %
%     try
%        % pbGetAllRecords_Callback(hObject, eventdata, handles)
%     set(handles.txLastAcq,'String',[res.msrunidentifier{:} ' ' res.msacqtime{:}]);
%     lastdata.msrunidentifier=res.msrunidentifier;
%     set(timeobj,'UserData',lastdata);
%     s=[' SELECT ' tblMSData '.*, ' tblPrepData '.* '];
%     s = [s ' FROM ' tblMSData ];
%     s= [s ' INNER JOIN ' tblPrepData ' on ' tblMSData '.MSRunIdentifier = ' tblPrepData '.RunIdentifier '];
%     %wheres=[' WHERE ((' tblMSData '.MSRunIdentifier) = ''' res.msrunidentifier{:} ''' ); '];
%     wheres=[' WHERE ((' tblMSData '.MSRunIdentifier) = ''' res.msrunidentifier{:} ''' ); '];
%     s = [ s wheres];
%     res=doquery(s);
%     
%     if ~isempty(res);
%         i=1;
%         if strncmp(res.msdatapath{i},'C:',2); %replace local file path if necessary
%             res.msdatapath{i}=[get(handles.edNuInsC,'string'),res.msdatapath{i}(3:end)];
%         end
%         filepath=[res.msdatapath{i} res.msdatafile{i}];
%         nudata=loadNuDataFile([filepath]);
%         
%         fl=fields(res);for fli=1:length(fl);dbdata.(fl{fli})=res.(fl{fli}){i};end
%         outputfighdl=fitnudata(nudata,dbdata,get(handles.edNiceFilePath,'string'));
%         if ishandle(outputfighdl) && isa(outputfighdl,'matlab.ui.Figure')
%             set(outputfighdl,'tag','figFitDisplay-auto'); % tag these for autoclose
%         end
%         global gitinfo
%         gitpush(gitinfo.currentrepo);
%         
%     end
%     
%     catch ME
%         disp(ME);
%       disp('In ArData line 1360');
%     end
%     
%   
%     
% end
%   set(handles.tbMonitorData,'backgroundcolor',[.3 .99 .3]);drawnow;


% --- Executes during object creation, after setting all properties.
function txLastAcq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to txLastAcq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in tbMonitorData.
function tbMonitorData_Callback(hObject, eventdata, handles)
% hObject    handle to tbMonitorData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of tbMonitorData



function edPychronRepoPath_Callback(hObject, eventdata, handles)
% hObject    handle to edPychronRepoPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edPychronRepoPath as text
%        str2double(get(hObject,'String')) returns contents of edPychronRepoPath as a double


% --- Executes during object creation, after setting all properties.
function edPychronRepoPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edPychronRepoPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in rbUpdatePychron.
function rbUpdatePychron_Callback(hObject, eventdata, handles)
% hObject    handle to rbUpdatePychron (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of rbUpdatePychron


% --- Executes on button press in pbDataSelectorTab.
function pbDataSelectorTab_Callback(hObject, eventdata, handles)
% hObject    handle to pbDataSelectorTab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'));
str= contents{get(hObject,'Value')};

set(findobj(gcf,'-regexp','tag','pn'),'visible','off');
set(findobj(gcf,'title',str),'visible','on');

% --- Executes on button press in pbOptionsTab.
function pbOptionsTab_Callback(hObject, eventdata, handles)
% hObject    handle to pbOptionsTab (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
contents = cellstr(get(hObject,'String'));
str= contents{get(hObject,'Value')};

set(findobj('-regexp','tag','pn'),'visible','off');
set(findobj('title',str),'visible','on');

function res=getrecordquery(handles)


tblMSData=get(handles.edMSDataTable,'string');tblPrepData= get(handles.edPrepDataTable,'string');
tblNiceResults=get(handles.edNiceResultsTable,'string');
when1=get(handles.txStartDate,'string');when2=get(handles.txEndDate,'string');

s=['if exists (select * from sysobjects where name = ''temptable'') DROP TABLE temptable'];
doquery(s);%try;doquery(s);catch;end
s=['if exists (select * from sysobjects where name = ''hasniceresults'') DROP VIEW hasniceresults'];
doquery(s)


% --- Executes on button press in pbOpenLogBook.
function pbOpenLogBook_Callback(hObject, eventdata, handles)
% hObject    handle to pbOpenLogBook (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
ArLogBook


