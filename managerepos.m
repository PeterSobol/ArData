function currentrepo=managerepos(dbdata)
global gitinfo
% decide what repo to use, create if necessary
currentrepo=[];
switch(lower(dbdata.type))
    case 'blank'
 %       reponame=[dbdata.msname '-Blanks-' dbdata.runidentifier(1:3)  ];
  reponame=[dbdata.msname '-Blanks'  ];
%                 if ~isdir(fullfile('C:\Users\raregas\Pychron3\data\.dvc\repositories\',reponame));
%             reponame=[dbdata.msname '-Blanks'];
%         end
    case 'air'
        reponame=[dbdata.msname '-Air'];
    case 'cocktail'
    %    reponame=[dbdata.msname '-Cocktail-' dbdata.runidentifier(1:3)  ]
%         if ~isdir(fullfile('C:\Users\raregas\Pychron3\data\.dvc\repositories\',reponame));
            reponame=[dbdata.msname '-Cocktail'];
%         end
    case 'sample'
       % try
 %       reponame=fix4git(dbdata.projectname);
         reponame=[dbdata.msname '-Unknowns'];
%         reponame=fix4git(dbdata.projectid);
%         if ~isdir(fullfile('C:\Users\raregas\Pychron3\data\.dvc\repositories\',reponame));
%             reponame=[dbdata.msname '-Unknowns'];
%         end
%         catch
%          reponame=[dbdata.msname '-Unknowns'];
%         end
%        
    otherwise
        msgbox(['Unrecognized ' dbdata.type ' analysis type while saving to git!']);
        return
end
if ~isfield(gitinfo,'currentrepo');gitinfo.currentrepo=[];end

if ~isa(gitinfo.currentrepo,'repo') || ~strcmp(gitinfo.currentrepo.name,reponame);
    
    foundrepo=false;
    for i=1:length(gitinfo.repolist)
        if strcmp(gitinfo.repolist(i).name,reponame)
            foundrepo=true;
            gitinfo.currentrepo=gitinfo.repolist(i);
            currentrepo=gitinfo.currentrepo;
            break
        end 
    end
    
    if  ~foundrepo
        gitinfo.currentrepo=repo(reponame,dbdata.type);
        gitinfo.repolist=[gitinfo.repolist gitinfo.currentrepo];
        currentrepo=gitinfo.currentrepo;
    end
else
    currentrepo=gitinfo.currentrepo;
end
