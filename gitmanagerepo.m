function out=gitmanagerepo(repo);
% initialize git part of git repositories!
%
global gitinfo

remotepath=([gitinfo.path  repo.name]);


[stat ret]=system(['git ls-remote ' remotepath ]);

if isempty(findstr(ret,'head')) % repo does not exist on hub
    msgbox(['Repository ' remotepath ' does not exist on Hub-  Help me!']);
    return;
else % repo not on hub, create
    modelrepo=[gitinfo.path  'empty'];
  %  [stat ret]=system('git clone ' 
end

%
