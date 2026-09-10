function [subrepo,fnout]=reposplit(fn);

subrepo = fn(1:3);
fnout=fn(4:end);
