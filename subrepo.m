classdef subrepo
    properties
        parentrepo
        fullpath
        name
        hasdirs
        haschanges
        
    end
    
    methods
        function obj=subrepo(name,parentrepo)
            
 %disp('function subrepo')           
            obj.parentrepo=parentrepo;
            obj.name=name;
        if isempty(parentrepo.localpath);parentrepo=buildlocalpath(parentrepo);end

            obj.fullpath=fullfile(parentrepo.localpath,name);
            
            if ~parentrepo.inpychron;parentrepo=addtopychron(parentrepo);end
            obj=checklocalpath(obj);
            if ~obj.hasdirs;obj=buildlocalpath(obj);end
            
            
            
            
        end
        function obj=checklocalpath(obj);
    %disp('function checklocalpath') ;
    %disp(obj.fullpath)
            if ~isdir(obj.fullpath);
                obj.hasdirs=false;
                
            else
                a=isdir(fullfile(obj.fullpath,'baselines'));
                b=isdir(fullfile(obj.fullpath,'intercepts'));
                c=isdir(fullfile(obj.fullpath,'.data'));
                d=isdir(fullfile(obj.fullpath,'blanks'));
                e=isdir(fullfile(obj.fullpath,'icfactors'));
                f=isdir(fullfile(obj.fullpath,'extraction'));
                
                if ~( a & b & c & d & e & f)
                    
                    obj.hasdirs=false;
                else
                    obj.hasdirs=true;
                end
            end
        end
        function obj=buildlocalpath(obj);
    %disp('function buildlocalpath')
        %disp(obj.fullpath)
            global gitinfo
            mkdir(obj.fullpath);
            if ~isdir(obj.fullpath);
                msgbox('Can"t create local subrepo directory');
            else
                a=mkdir(obj.fullpath,'baselines');
                b=mkdir(obj.fullpath,'.data');
                c=mkdir(obj.fullpath,'intercepts');
                d=mkdir(obj.fullpath,'blanks');
                e=mkdir(obj.fullpath,'icfactors');
                f=mkdir(obj.fullpath,'extraction');
                if ~( a && b && c && d && e && f)
                    obj=checklocalpath(obj);
                    if ~obj.hasdirs
                        msgbox('Can"t create subprepo target dirs')
                    end
                else
                    obj.hasdirs=true;
                    currentdir=pwd;
                    cd(obj.parentrepo.localpath);
                    try
                        [~,~]=system(['git add . ']);
                        [~,~]=system(['git commit -m "test"']);
                    catch ME
                        msgbox('Git Add/Commit failed creating Repo Dir');
                         disp(ME);disp(ME.stack(1));
                    end
                   cd(currentdir)
                end
                
                
            end
        end
        
              
        function cleanfiles(obj,fn);
            
           %disp('function cleanfiles')
           %disp(obj.fullpath)
            
            
            % remove a file and all its brethren from the repo
            global gitinfo
            direc=dir(fullfile(obj.fullpath,[fn '.json']));
            
            if ~isempty(direc);
   
                delete(fullfile(obj.fullpath,[fn '.json']));
                try   delete(fullfile(obj.fullpath,'baselines',[fn '.base.json']));catch;end
                try  delete(fullfile(obj.fullpath,'intercepts',[fn '.inte.json']));catch;end
                try delete(fullfile(obj.fullpath,'.data',[fn '.dat.json']));catch;end
                try delete(fullfile(obj.fullpath,'icfactors',[fn '.icfa.json']));catch;end
                try delete(fullfile(obj.fullpath,'blanks',[fn '.blan.json']));catch;end
                try delete(fullfile(obj.fullpath,'extraction',[fn '.extr.json']));catch;end
                currentdir=pwd;
                try
                cd(gitinfo.currentrepo.localpath);
                 [~,~]=system(['git add -u . ']);
                 [~,~]=system(['git commit -m "delete"']);
                catch ME
                    disp(ME);
                end   
                      cd(currentdir);
                
            end

            
            
        end
        function [status]=addfiles(obj,fn)
            global gitinfo
            a=movefile([fn '.json'],fullfile(obj.fullpath));
            b=movefile([fn '.base.json'],fullfile(obj.fullpath,'baselines'));
            c=movefile([fn '.inte.json'],fullfile(obj.fullpath,'intercepts'));
            d=movefile([fn '.dat.json'],fullfile(obj.fullpath,'.data')) ;
            e=movefile([fn '.icfa.json'],fullfile(obj.fullpath,'icfactors')) ;
            f=movefile([fn '.blan.json'],fullfile(obj.fullpath,'blanks')) ;
            g=movefile([fn '.extr.json'],fullfile(obj.fullpath,'extraction')) ;
            %disp([fullfile(obj.fullpath,'extraction') ]);            

            currentdir=pwd;
            try
        %disp(gitinfo.currentrepo.localpath);
            cd(gitinfo.currentrepo.localpath);
            system([' git add .' ]);
            %disp('@subrepo 127');
            system(['git commit -m "' [gitinfo.subrepo.name fn] '"']);
       %disp(gitinfo.subrepo.name);     
            catch ME
               (ME);disp(ME.stack(1));
               msgbox(['Git add/commit failed: ' gitinfo.subrepo.name fn '!']);
            end
             cd(currentdir);
            if ~(a&&b&&c&&d&&e&&g)
                msgbox('Unable to Move all files to subrepo')
                status=false;
            else
                status=true;
              
                obj.parentrepo.haschanges=true;
            end
            
        end
        
    end
    
end
