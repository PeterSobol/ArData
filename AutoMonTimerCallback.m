function AutoMonTimerCallback(timerobj,c,handles)
set(handles.tbMonitorData,'backgroundcolor',[.25 .25 0.5]);drawnow;pause(.2);
tblMSData=getuistring(handles.edMSDataTable);
timefield = 'MSAcqTime';
tblPrepData=getuistring(handles.edPrepDataTable);

s=[' SELECT MSRunIdentifier, '  timefield  ' FROM '  tblMSData   ' '];
s=[s ' WHERE '  timefield  ' in (Select MAX('  timefield  ' ) from ' tblMSData ' WHERE MsName = ''NOB'') '];

res=doquery(s);
lastdata=get(timerobj,'UserData');
%disp([lastdata.msrunidentifier res.msrunidentifier]);
if strcmp(lastdata.msrunidentifier,res.msrunidentifier);
    % match % carry on.
    
else
    disp(['Fitting ' res.msrunidentifier]);
    % no match - process
    %
    % check and close old windows
    figs=findobj('tag','figFitDisplay-auto');
    nodisplays=size(figs,1);
    if nodisplays>3;
        try
            list=sortrows([[1:length(figs)]' [figs.Number]'],2);
            list(1,end-3:end)
            close(figs(list(end-2:end,1)));% close all but the last 3 figs
        catch ME
            disp(ME);disp(ME.stack(1));
        end
    end
    %
    try
        % pbGetAllRecords_Callback(hObject, eventdata, handles)
        setuistring(handles.txLastAcq,[res.msrunidentifier{:} ' ' res.msacqtime{:}]);
        lastdata.msrunidentifier=res.msrunidentifier;
        set(timerobj,'UserData',lastdata);
        s=[' SELECT ' tblMSData '.*, ' tblPrepData '.* '];
        s = [s ' FROM ' tblMSData ];
        s= [s ' INNER JOIN ' tblPrepData ' on ' tblMSData '.MSRunIdentifier = ' tblPrepData '.RunIdentifier '];
        %wheres=[' WHERE ((' tblMSData '.MSRunIdentifier) = ''' res.msrunidentifier{:} ''' ); '];
        wheres=[' WHERE ((' tblMSData '.MSRunIdentifier) = ''' res.msrunidentifier{:} ''' ); '];
        s = [ s wheres];
        res=doquery(s);
        
        if ~isempty(res);
            i=1;
            if strncmp(res.msdatapath{i},'C:',2); %replace local file path if necessary
                res.msdatapath{i}=[getuistring(handles.edNuInsC),res.msdatapath{i}(3:end)];
            end
            filepath=[res.msdatapath{i} res.msdatafile{i}];
            nudata=loadNuDataFile([filepath]);
            
            fl=fields(res);for fli=1:length(fl);dbdata.(fl{fli})=res.(fl{fli}){i};end
            
            
            fitoptions.nicefilepath=getuistring(handles.edNiceFilePath);
            fitoptions.sigma=str2double(getuistring(handles.edCleanDataSigma));
        
                if isprop(handles,'rbAutoSaveClose') ||isfield(handles,'rbAutoSaveClose')
            fitoptions.autosaveclose=handles.rbAutoSaveClose.Value;
                else
                     fitoptions.autosaveclose=true;
                end
                if isprop(handles,'rbUpdatePychron') ||isfield(handles,'rbUpdatePychron')
            fitoptions.updatepychron=handles.rbUpdatePychron.Value;
                else

                fitoptions.updatepychron=true;
            end
            fitoptions.sectoexclude=str2double(getuistring(handles.edSecToExclude));
            
            fitoptions.fittype=getuistring(handles.puDefaultFitType);
            fitoptions.maxcycles=str2double(getuistring(handles.edMaxCycles));
            fitoptions.timezerooffset=str2double(getuistring(handles.edTimeZeroOffset));
                
            [outputfighdl nudata]=fitnudata(nudata,dbdata,fitoptions);
            persistent results
        
            res=nudata.results;
            type=strsplit(nudata.Sample_Name);type=type{1};
            if ~isfield(results,type);
                results.(type)=[];
            end
            time=nudata.Start_Run_Time;
            for i=1:length(res.names);
               if ~isfield(results.(type),res.names{i});
                   results.(type).(res.names{i})=res.value(i);
               else
                    results.(type).(res.names{i})=[results.(type).(res.names{i}) res.value(i)];
               end
                
            end
            if ~isfield(results.(type),'time');
                results.(type).time=time;
            else
                 results.(type).time=[results.(type).time time];
            end
            if isa(handles,'MonitorArData')
                handles.updateplot(results);
            end
            
            if ishandle(outputfighdl) && isa(outputfighdl,'matlab.ui.Figure')
                set(outputfighdl,'tag','figFitDisplay-auto'); % tag these for autoclose
            end
            global gitinfo
            gitpush(gitinfo.currentrepo);
            

            
        end
        
    catch ME
        disp(ME);
        disp('In AutoMonTimerCallback');
        ME.stack(1)
    end
    
end
set(handles.tbMonitorData,'backgroundcolor',[.3 .99 .3]);drawnow;

