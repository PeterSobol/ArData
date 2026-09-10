function  AutoMonTimerStart(timerobj,startfun,handles)
tblMSData=getuistring(handles.edMSDataTable);
timefield = 'MSAcqTime';

s=[' SELECT MSRunIdentifier, '  timefield  ' FROM '  tblMSData   ' '];
s=[s ' WHERE '  timefield  ' in (Select MAX('  timefield  ' ) from ' tblMSData ' WHERE MsName = ''NOB'') '];

res=doquery(s);
timerobj.userdata=res; % save current last record to timeruserdata
setuistring(handles.txLastAcq,[res.msrunidentifier{:} ' ' res.msacqtime{:}]);


    
