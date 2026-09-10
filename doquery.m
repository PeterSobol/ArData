function res=doquery(sql)

% returns query results in a structure
global qinfo

if ~isfield(qinfo,'DB') || ~strcmp(class(qinfo.DB),'COM.ADODB_Connection') || ~get(qinfo.DB,'State')
    connect=initdb;
else
    connect=true;
end
if connect
try
    
    res=[];
    res = adodb_query(qinfo.DB, sql);
    if ~isempty(res);
        fls=fields(res);
        if ~iscell(res.(fls{1}));
            for i=1:length(fls);
                res.(fls{i})={res.(fls{i})};
            end
        end
    else
        res=[];
    end
    
catch
    [errmsg, msgid] = lasterr;
    lasterr
    if strcmp(msgid,'MATLAB:COM:E2147500037'); %error unable to connect to DB
        initdb
        try
            res = adodb_query(qinfo.DB, sql);
        catch
            error('Unable to connect to database');
            res='Error';
        end
    end
end
else
    res='Error:no connection to db';
end
    function connect=initdb;
        if ishandle(findobj('tag','edDatabaseServer'))
            %ArData is open use options from open app
            datasource=get(findobj('tag','edDatabaseServer'),'Value');
            databasename=get(findobj('tag','edDatabaseName'),'Value');
            userid=get(findobj('tag','edDatabaseID'),'Value');
            password=get(findobj('tag','edDatabasePassword'),'Value');
        else  % try to load from file
            options=load('options.mat');
            for i=1:length(options.tags);
                switch options.tags{i};
                    case 'edDatabaseServer'
                        datasource=options.cstrings{i};
                    case 'edDatabaseName'
                        databasename=options.cstrings{i};
                    case 'edDatabaseID'
                        userid = options.cstrings{i};
                    case 'edDatabasePassword'
                        password=options.cstrings{i};
                end
                
                
            end
            
        end
        constr= ['Provider=SQLOLEDB;Data Source = ' datasource ';Initial Catalog=' databasename ';User Id= ' userid ';Password= ' password ';'];
        try
            qinfo.DB = adodb_connect(constr);
            connect=true;
        catch
            msgbox('Error Opening DB Connection')
            connect = false;
            return;
        end
    end
end
