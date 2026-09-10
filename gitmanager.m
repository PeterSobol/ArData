function gitmanager(command,input);
global gitinfo
gitinfo.basegit='https://github.com/WiscArdata/';
if ~isfield(gitinfo,'repository') || ~isempty(gitinfo.repository)
    % initialize
    gitinit

end

switch command
    case 'initialize'
        gitinit
end


    function gitinit % set up git repository.
        if ~isfield(gitinfo,'githome') || ~exist(gitinfo.githome)==0 % no directory
            system('mkdir c:\githome');gitinfo.githome='c:\githome';
           
            if ~exist('c:\githome')==7; % doesn't exist or not a directory
                msgbox('Could not create c:\githome!')
                return;
            end
            
                if ~isempty(input);
                     gitinfo.reponame=input;
                end
            
            if ~isempty(gitinfo.reponame);
                str=['git ls-remote ' fullfile(gitinfo.basegit,gitinfo.reponame)];str=strrep(str,'\','/');
                [status out]=system(str);
                if status~=0; % remote rep doesn't exist
                    
                    
                end
                
                
            end
            
        end
        
        
    end
end

