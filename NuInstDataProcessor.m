function varargout = NuInstDataProcessor(varargin)
% NUINSTDATAPROCESSOR M-file for NuInstDataProcessor.fig
%      NUINSTDATAPROCESSOR, by itself, creates a new NUINSTDATAPROCESSOR or raises the existing
%      singleton*.
%
%      H = NUINSTDATAPROCESSOR returns the handle to a new NUINSTDATAPROCESSOR or the handle to
%      the existing singleton*.
%
%      NUINSTDATAPROCESSOR('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in NUINSTDATAPROCESSOR.M with the given input arguments.
%
%      NUINSTDATAPROCESSOR('Property','Value',...) creates a new NUINSTDATAPROCESSOR or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before NuInstDataProcessor_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to NuInstDataProcessor_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help NuInstDataProcessor

% Last Modified by GUIDE v2.5 13-Oct-2010 14:43:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @NuInstDataProcessor_OpeningFcn, ...
                   'gui_OutputFcn',  @NuInstDataProcessor_OutputFcn, ...
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


% --- Executes just before NuInstDataProcessor is made visible.
function NuInstDataProcessor_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to NuInstDataProcessor (see VARARGIN)

% Choose default command line output for NuInstDataProcessor
global fileinfo
handles.output = hObject;
handles.xlsindex=0;

filesep=getfilesep;

%load the file list
watchon;
try
if isfield(handles,'edFileSuffix')    
fileinfo.filesuffix=get(handles.edFileSuffix,'string');

if isempty(fileinfo.filesuffix);fileinfo.filesuffix='*';end
else
    fileinfo.filesuffix='RUN';
end

dirpathstring=get(handles.edSource,'string');
direc=dir([dirpathstring filesep '*.' fileinfo.filesuffix]);
[unused, order] = sort([direc(:).datenum]);
handles.direc = direc(order); 
set(handles.lbSourceDirectory,'value',[],'string', [strvcat(handles.direc(:).name) char(32*ones(length(direc),2)) num2str([handles.direc(:).bytes]')]);
catch
end
    watchoff;
guidata(hObject,handles)

% setup the output file:

resultspathstring=get(handles.edResultsFile,'string');
direc=dir(resultspathstring);

fileinfo.outputfilepath=resultspathstring;

%set up the nice file directory string:

fileinfo.nicefilepath=get(handles.edNiceFilePath,'string');



% Update handles structure
guidata(hObject, handles);








% UIWAIT makes NuInstDataProcessor wait for user response (see UIRESUME)
% uiwait(handles.GSSFig);


% --- Outputs from this function are returned to the command line.
function varargout = NuInstDataProcessor_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in pbExit.
function pbExit_Callback(hObject, eventdata, handles)
% hObject    handle to pbExit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close all

function edSource_Callback(hObject, eventdata, handles)
% hObject    handle to edSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edSource as text
%        str2double(get(hObject,'String')) returns contents of edSource as a double


filesep=getfilesep;
watchon;
try
filesuffix=get(handles.edFileSuffix,'string');

if isempty(filesuffix);filesuffix='*';end

dirpathstring=get(handles.edSource,'string');

direc=dir([dirpathstring filesep '*.' filesuffix]);
[unused, order] = sort([direc(:).datenum]);
handles.direc = direc(order); 
set(handles.lbSourceDirectory,'value',[],'string', [strvcat(handles.direc(:).name) char(32*ones(length(direc),2)) num2str([handles.direc(:).bytes]')]);
catch

end
watchoff;
guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function edSource_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edSource (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edResultsFile_Callback(hObject, eventdata, handles)
% hObject    handle to edResultsFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edResultsFile as text
%        str2double(get(hObject,'String')) returns contents of edResultsFile as a double
global fileinfo
fileinfo.outputfilepath=get(hObject,'String');

% --- Executes during object creation, after setting all properties.
function edResultsFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edResultsFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
global fileinfo
fileinfo.outputfilepath=get(hObject,'String');

% --- Executes on button press in pbResultsFile.
function pbResultsFile_Callback(hObject, eventdata, handles)
% hObject    handle to pbResultsFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fileinfo

resultspathstring=get(handles.edResultsFile,'string');

[FileName PathName FilterIndex] = uiputfile(resultspathstring);
  
fileinfo.outputfilepath=[PathName FileName];
set(handles.edResultsFile,'string',fileinfo.outputfilepath);


% --- Executes on selection change in lbSourceDirectory.
function lbSourceDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to lbSourceDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lbSourceDirectory contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbSourceDirectory

%set(handles.lbSourceDirectory,'value',[],'string', [strvcat(handles.direc(:).name) char(32*ones(length(direc),2)) num2str([handles.direc(:).bytes]')]);

%guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function lbSourceDirectory_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbSourceDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end





% --- Executes on button press in pbConvert.
function pbConvert_Callback(hObject, eventdata, handles)
% hObject    handle to pbConvert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fileinfo
fileinfo.lineno=0;
fileinfo.header={'Date/time','File Name','Sample Name','Intercept: IC0','IC0_Err','IC1','IC1_Err','IC2','IC2_Err','IC3','IC3_Err','FC','FC_Err'};
filesep=getfilesep;


sourcepath=[get(handles.edSource,'string') filesep];
listvalues=get(handles.lbSourceDirectory,'value');
if ~isempty(listvalues)

list=handles.direc(listvalues);    
    
outputpath=get(handles.edResultsFile,'string');
if isempty(outputpath);outputpath=['.' filesep];end
if ~strcmp(outputpath(end),filesep);outputpath=[outputpath filesep];end



if ~isempty(list)
 
   for i=1:length(list);
      % out=serialstreamtogcf([sourcepath outline.name{i}],outputpath,0,handles.lbProcessMessages);
       nudata=loadNuDataFile([sourcepath list(i).name]);
       output=fitnudata(nudata);
   end

end

end

% --- Executes on selection change in lbProcessMessages.
function lbProcessMessages_Callback(hObject, eventdata, handles)
% hObject    handle to lbProcessMessages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns lbProcessMessages contents as cell array
%        contents{get(hObject,'Value')} returns selected item from lbProcessMessages


% --- Executes during object creation, after setting all properties.
function lbProcessMessages_CreateFcn(hObject, eventdata, handles)
% hObject    handle to lbProcessMessages (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbSourceDirectory.
function pbSourceDirectory_Callback(hObject, eventdata, handles)
% hObject    handle to pbSourceDirectory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

filesep=getfilesep;
watchon;
try
filesuffix=get(handles.edFileSuffix,'string');

if isempty(filesuffix);filesuffix='*';end

dirpathstring=get(handles.edSource,'string');

dirpathstring=uigetdir(dirpathstring);

set(handles.edSource,'string',dirpathstring);

direc=dir([dirpathstring filesep '*.' filesuffix]);
[unused, order] = sort([direc(:).datenum]);
handles.direc = direc(order); 
watchoff

set(handles.lbSourceDirectory,'value',[],'string', [strvcat(handles.direc(:).name) char(32*ones(length(direc),2)) num2str([handles.direc(:).bytes]')]);
catch
  
end
watchoff;
guidata(hObject,handles)


function edFileSuffix_Callback(hObject, eventdata, handles)
% hObject    handle to edFileSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edFileSuffix as text
%        str2double(get(hObject,'String')) returns contents of edFileSuffix as a double

filesep=getfilesep;

filesuffix=get(handles.edFileSuffix,'string');

if isempty(filesuffix);filesuffix='*';end

dirpathstring=get(handles.edSource,'string');

direc=dir([dirpathstring filesep '*.' filesuffix]);
set(handles.lbSourceDirectory,'value',[],'string', [strvcat(direc(:).name) char(32*ones(length(direc),2)) num2str([direc(:).bytes]')]);

% --- Executes during object creation, after setting all properties.
function edFileSuffix_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edFileSuffix (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function [sourcepath list]=getfilelist(handles);
filesep=getfilesep;
list=[]; 
sourcepath=[get(handles.edSource,'string') filesep];
selected=get(handles.lbSourceDirectory,'value');
   
filesuffix=get(handles.edFileSuffix,'string');
    if isempty(filesuffix);filesuffix='*';end

    if isempty(selected);  %process all files


    list=dir([sourcepath '*.' filesuffix]);    
    
else  % process just selected files


       direc=dir([sourcepath '*.' filesuffix]);
      
   list=direc(selected);
    
end


% --- Executes on button press in pbSelectAll.
function pbSelectAll_Callback(hObject, eventdata, handles)
% hObject    handle to pbSelectAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

set(handles.lbSourceDirectory,'value',[]);


 
     
 function filesep=getfilesep
 if ispc;    filesep='\';else  filesep='/';end % filesep for type of computator

 
 function status=addmessage(message)

         pmhdl=findobj('tag','lbProcessMessages');
         messages=get(pmhdl,'string');
         messages=[messages;message];
         set(pmhdl,'string',messages,'value',length(messages))
         status=1;


% --- Executes on button press in pbRefreshList.
function pbRefreshList_Callback(hObject, eventdata, handles)
% hObject    handle to pbRefreshList (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


filesep=getfilesep;
watchon;drawnow
try
filesuffix=get(handles.edFileSuffix,'string');

if isempty(filesuffix);filesuffix='*';end
dirpathstring=get(handles.edSource,'string');
set(handles.edSource,'string',dirpathstring);
direc=dir([dirpathstring filesep '*.' filesuffix]);
[unused, order] = sort([direc(:).datenum]);
handles.direc = direc(order); 
watchoff

set(handles.lbSourceDirectory,'value',[],'string', [strvcat(handles.direc(:).name) char(32*ones(length(direc),2)) num2str([handles.direc(:).bytes]')]);
catch
  
end
watchoff;
guidata(hObject,handles)


% --- Executes on selection change in puFitType.
function puFitType_Callback(hObject, eventdata, handles)
% hObject    handle to puFitType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns puFitType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from puFitType


% --- Executes during object creation, after setting all properties.
function puFitType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to puFitType (see GCBO)
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



% handles    structure with handles and user data (see GUIDATA)



function edNiceFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to edNiceFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edNiceFilePath as text
%        str2double(get(hObject,'String')) returns contents of edNiceFilePath as a double
global fileinfo
fileinfo.NiceFilePath=get(hObject,'string');

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


% --- Executes on button press in pbGetNiceFilePath.
function pbGetNiceFilePath_Callback(hObject, eventdata, handles)
% hObject    handle to pbGetNiceFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global fileinfo
fileinfo.NiceFilePath=get(hObject,'string');

if isempty(fileinfo.NiceFilePath);fileinfo.NiceFilePath='.';end
fileinfo.NiceFilePath=uigetdir(fileinfo.NiceFilePath);


% --- Executes during object creation, after setting all properties.
function pbGetNiceFilePath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pbGetNiceFilePath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
