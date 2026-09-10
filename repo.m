classdef repo < handle
    
    % handle git repo information
    properties
        name
        localpath
        pi
        inpychron
        synced
         synceddt
        haschanges
        tag
    end
    methods
        function obj=repo(name,varargin)
            global gitinfo
            if nargin<2;obj.pi='WiscArLab';
            else
                obj.pi=varargin{1};
            end
            obj.name=name;
            obj.inpychron= false;
            obj=checkpychron(obj);
            obj.localpath=fullfile(gitinfo.localrepopath,obj.name);
            if ~obj.inpychron
                obj=addtopychron(obj);
            end
            [obj status]=checklocalpath(obj);
            if ~status
                obj=buildlocalpath(obj);
            end
            repo.tag='repo';
        end
        function obj=checkpychron(obj);
            global qinfo
            qinfo.DB.DefaultDatabase='PYCHRON';
            
            s=['select name from RepositoryTbl where name = ''' obj.name ''''];
            
            res=doquery(s);
            if isempty(res);
                obj.inpychron= false;
                status=false;
            else
                obj.inpychron= true;
                status=true;
            end
            qinfo.DB.DefaultDatabase='ARDATA';
        end
        function obj=addtopychron(obj);
            global qinfo
            
            obj=checkpychron(obj);
            if obj.inpychron
                disp('Already in repository table')
                return
            end
            qinfo.DB.DefaultDatabase='PYCHRON';
            s=['select top(1) id from PrincipalInvestigatorTbl '];
            s=[s ' WHERE ( first_initial+last_name = ''' obj.pi ''')'];
            res=doquery(s);
            if isempty(res);pi_id=1;
            else
                pi_id=res.id{:};
            end
            
            
            s=['INSERT INTO RepositoryTbl(name,principal_investigatorID) '];
            s= [s ' VALUES ( ''' obj.name ''',' num2str(pi_id) ')'];
            doquery(s);
            obj=checkpychron(obj);
            if ~obj.inpychron
                msgbox('Unable to create entry in repositorytbl, Help!')
            end
            
            qinfo.DB.DefaultDatabase='ARDATA';
        end
        function [obj status]=checklocalpath(obj);
            if isdir(obj.localpath)
                status=true;
            else
                status=false;
            end
            
        end
        function obj = buildlocalpath(obj);
            global gitinfo
         
            if ~isdir(fullfile(gitinfo.localrepopath));
                mkdir(fullfile(gitinfo.localrepopath));
            end
            if ~isdir(obj.localpath);
                mkdir(obj.localpath);
            end
            
            
            direc=dir(obj.localpath);
            if length(direc)<3; % need to clone in a database!
                % gitinfo.gitdir=fullfile(gitinfo.ArDataDir,'gitdata');
                %     cd(gitinfo.gitdir)
                %     eval(['!git clone ' [gitinfo.path gitinfo.repo.localpath]])
                %      cd(fullfile(gitinfo.ArDataDir));
            end
        end
        function obj=gitpush(obj);
            % push up to the git repository
          
            if obj.haschanges
               currentdir=pwd;
               try
                   cd(obj.localpath);
                   gp=system('git push')
                      obj.haschanges= false;
                   if isstring(gp)
                         msgbox(gp);
                   end
                
               catch
               end
               cd(currentdir);
                
            end
            
        end
    end
end