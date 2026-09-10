function out=writetogit(dbdata,nudata);
% create and populate local git repository
%fn='justtesting';
jslist={};
fn=deblank(dbdata.msrunidentifier);
%disp([fn ' ' dbdata.completeidentifier])
if isempty(fn)
    msgbox('Run Identifier invalid!')
    return
end



global qinfo gitinfo


currentrepo=managerepos(dbdata);

[subreponame fn]=reposplit(fn);
gitinfo.subrepo =subrepo(subreponame,currentrepo);
%disp(gitinfo.subrepo)
gitinfo.repobase='\\github.WiscArData';
qinfo.DB.DefaultDatabase='PYCHRON';
if isfield('jsscratchfolder',gitinfo) && isdir(gitinfo.jsscratchfolder)
else    
    gitinfo.jsscratchfolder=GetWritableFolder;
    disp(['gitinfo.jsscratchfolder ' gitinfo.jsscratchfolder]) 
end
%gitinfo.repo='wiscartest';
gitinfo.path='https://github.com/WiscArData/';
disp(gitinfo)
%
% if ~isdir(fullfile(gitinfo.ArDataDir,'gitdata'));
%     mkdir(fullfile(gitinfo.ArDataDir,'gitdata'));
%     gitinfo.gitdir=fullfile(gitinfo.ArDataDir,'gitdata');
%     cd(gitinfo.gitdir)
%     eval(['!git clone ' [gitinfo.path gitinfo.repo.localpath]])
%      cd(fullfile(gitinfo.ArDataDir));
% end

if length(fn)<4
    msgbox('Complete ID too short to save to git!');
    return
end

% try
%% write general info file
%analysisres=doquery(['select top(1) * from AnalysisTbl where uuid = '''  dbdata.msrunidentifier ''' ']);


s=['SELECT        AnalysisTbl.id, AnalysisTbl.uuid, AnalysisTbl.timestamp, AnalysisTbl.analysis_type, AnalysisTbl.aliquot, '];
s=[s ' AnalysisTbl.increment, AnalysisTbl.mass_spectrometer, IrradiationPositionTbl.identifier, IrradiationPositionTbl.position AS irradiation_position,  '];
s= [s ' IrradiationTbl.name AS irradiation, SampleTbl.name AS sample, MaterialTbl.name AS material, ProjectTbl.name AS project,  '];
s= [s ' LevelTbl.name AS irradiation_level, PrincipalInvestigatorTbl.last_name, PrincipalInvestigatorTbl.first_initial '];
s= [s ' FROM AnalysisTbl '];
s= [s ' INNER JOIN IrradiationPositionTbl ON AnalysisTbl.irradiation_positionID = IrradiationPositionTbl.id '];
s= [s ' INNER JOIN LevelTbl ON IrradiationPositionTbl.levelID = LevelTbl.id  '];
s= [s ' INNER JOIN IrradiationTbl ON LevelTbl.irradiationID = IrradiationTbl.id '];
s= [s ' LEFT OUTER JOIN SampleTbl ON IrradiationPositionTbl.sampleID = SampleTbl.id '];
s= [s ' LEFT OUTER JOIN MaterialTbl ON SampleTbl.materialID = MaterialTbl.id '];
s= [s ' LEFT OUTER JOIN ProjectTbl ON SampleTbl.projectID = ProjectTbl.id '];
s= [s ' LEFT OUTER JOIN PrincipalInvestigatorTbl ON ProjectTbl.principal_investigatorID = PrincipalInvestigatorTbl.id  '];
s= [s ' where uuid = '''  dbdata.msrunidentifier ''' '];

analysisres=doquery(s);



dgit=gitobj;
if ~isempty(analysisres)
    dgit.analysisID=analysisres.id{:};
    dgit.aliquot=analysisres.aliquot{:};
    if strcmpi(analysisres.analysis_type{:},'Sample');
        dgit.analysis_type='unknown';
    else
        dgit.analysis_type=lower(analysisres.analysis_type{:});
    end
    
    dgit.timestamp=analysisres.timestamp{:};
    dgit.material= analysisres.material{:};
    dgit.project= analysisres.project{:};
    dgit.sample= analysisres.sample{:};
    dgit.repository_identifier= gitinfo.currentrepo.name;
    dgit.irradiation= analysisres.irradiation{:};
    dgit.irradiation_level=analysisres.irradiation_level{:};
    dgit.irradiation_position=analysisres.irradiation_position{:};
    dgit.identifier= analysisres.identifier{:};
    dgit.increment=analysisres.increment{:};
    dgit.admit_delay=dbdata.admitdelay;
    if isempty(analysisres.last_name{:}) && isempty(analysisres.first_initial{:})
        dgit.principal_investigator=deblank([analysisres.last_name{:} analysisres.first_initial{:}]);
    else
        dgit.principal_investigator='WiscArLab';
    end
end

dgit.acquisition_software='';

% dgit.analyist_name
dgit.collection_version=nudata.Acq_File;
% dgit.comment
dgit.data_reduction_software= 'ArData';
for i=1:length(nudata.detectors)
    st.(upper(nudata.detectors{i}))=detectorobj;
end
dgit.detectors=st;
% dgit.identifier
% dgit.irradiation = dbdata.irradiation;
% dgit.irradiation_level
% dgit.irradiation_position
st=[];
for i=1:length(nudata.results.names)
    st.(nudata.results.names{i})=isotopesobj;
    st.(nudata.results.names{i}).name=nudata.results.names{i};
    st.(nudata.results.names{i}).serial_id='00000';
    st.(nudata.results.names{i}).detector=nudata.results.str{i};
    if strfind(nudata.results.str{i},'IC');
        units='cps';
    else
        units='fA';
    end
    st.(nudata.results.names{i}).units='cps';
    
end
dgit.isotopes=st;

dgit.mass_spectrometer=dbdata.msname;
% dgit.material
% dgit.principal_investigator
% dgit.project
% dgit.repository_identifier
% dgit.sample
% dgit.source;
dgit.uuid=[dbdata.msrunidentifier];

%jswrite([fn '.json'],dgit);

fp=fullfile(gitinfo.jsscratchfolder,fn);
jswrite([fp '.json'],dgit);
jslist=[jslist;[fp '.json']];
% catch
% end
qinfo.DB.DefaultDatabase='ARDATA';

%% write Data file
st=[];
st1=[];
baselines=[];
for i=1:length(nudata.results.names)
    
    st1.blob=makeblob(nudata.results.zerotime{i},nudata.results.zero{i});
    st1.detector=nudata.results.str{i};
    baselines=[baselines st1];
    
end
st.commit='';
st.endocing='base64';
st.format='>ff';
st.baselines=baselines;
signals=[];
for i=1:length(nudata.results.names)
    
    st1.blob=makeblob(nudata.results.time{i},nudata.results.data{i});
    % d=single(nudata.results.data{i});
    % d=typecast(d,'uint8');
    % d=reshape(d,4,length(d)/4);d=d';
    % d=d(:,end:-1:1);%big endian
    %
    % t=single(nudata.results.time{i});
    % t=typecast(t,'uint8');
    % t=reshape(t,4,length(t)/4);t=t';
    % t=t(:,end:-1:1);%big endian
    % t=[t d];
    % st1.blob=matlab.net.base64encode(t(:));
    st1.detector=nudata.results.str{i};
    st1.isotope=(nudata.results.names{i});
    signals=[signals st1];
end
st.signals=signals;

sniffs=[];
st1=[];
for i=1:length(nudata.results.names)
    st1.blob='';
    st1.detector=nudata.results.str{i};
    st1.isotope=(nudata.results.names{i});
    sniffs=[sniffs st1];
end
st.sniffs=sniffs;


jswrite([fp '.dat.json'],st);
jslist=[jslist;[fp '.dat.json']];




%% Write icfactors file
st=[];
for i=1:length(nudata.detectors)
    st.(nudata.detectors{i}).error=1e-20;
    st.(nudata.detectors{i}).fit='default';
    st.(nudata.detectors{i}).references=NaN;
    st.(nudata.detectors{i}).value=1.0;
    
end
jswrite([fp '.icfa.json'],st);
jslist=[jslist;[fp '.icfa.json']];

%% Write Intercept file
st=[];

for i=1:length(nudata.results.names)
    st.(nudata.results.names{i}).error=nudata.results.error(i);
    st.(nudata.results.names{i}).error_type='SEM';
    filter_outliers_dict.filter_outliers=true;
    filter_outliers_dict.iterations=1;
    filter_outliers_dict.iterations=2;
    
    st.(nudata.results.names{i}).filter_outliers_dict=filter_outliers_dict;
    st.(nudata.results.names{i}).fit='linear';
    st.(nudata.results.names{i}).value=nudata.results.value(i);
end
jswrite([fp '.inte.json'],st);
jslist=[jslist;[fp '.inte.json']];

%% Write Baseline File
st1=[];
st=[];

for det=nudata.detectors
    det=det{:};
    st.(upper(det)).value=nudata.(det).offset(1);
    st.(upper(det)).fit=nudata.(det).fittype;
    st.(upper(det)).filter_outliers_dict={};
    st.(upper(det)).error=nudata.(det).offsetsigma;
    st.(upper(det)).errortype='std';
    
end
jswrite([fp '.base.json'],st);
jslist=[jslist;[fp '.base.json']];
%% Write extractionfile File

st=[];

% st.beam_diameter
% cleanup_duration
% commit
st.extract_device='Photon Machines CO2';
st.extract_duration=dbdata.laserdwell;
st.extract_units='%';
st.extract_value=str2double(dbdata.laserpower);
% pattern
% positions
% ramp_duration
% ramp_rate
% request
% response
% sblob
% snapshots
% tray
% videos
% weight

jswrite([fp '.extr.json'],st);
jslist=[jslist;[fp '.extr.json']];



%% write blank file
if ~strcmp(dbdata.type,'Blank');
    
    
    qinfo.DB.DefaultDatabase='ARDATA';
    %     s=['select TOP 1  MSRunIdentifier from tblMSData  '];
    %     s= [s ' INNER JOIN tblPrepdata on tblPrepData.RunIdentifier = tblMSData.MSRunIdentifier '];
    %     s= [s ' where MSAcqTime < ''' dbdata.msacqtime '''  '];
    %     s= [s ' AND tblPrepData.Type = ''Blank''  '];
    %     s= [s ' order by MSAcqTime DESC' ];
    %     priorblank=doquery(s);
    %     priorblank=priorblank.msrunidentifier{:};
    
    
    s= [' Select * from tblNiceResults where tblNiceResults.NRRunIdentifier = '];
    s= [s ' (select TOP 1  MSRunIdentifier from tblMSData  '];
    s= [s ' INNER JOIN tblPrepdata on tblPrepData.RunIdentifier = tblMSData.MSRunIdentifier '];
    s= [s ' where MSAcqTime < ''' dbdata.msacqtime '''  '];
    s= [s ' AND tblPrepData.Type = ''Blank''  '];
    s= [s ' order by MSAcqTime DESC) '];
    
    %      s= [' Select * from [ARDATA].[dbo].[tblNiceResults] where NRRunIdentifier = '];
    %      s=[ s '''' priorblank ''''];
    
    analysisres=doquery(s);
    blanks=[];
    stl=[];
    if ~isempty(analysisres)
        for i=1:length(analysisres.id_niceresults);
            
            stl.(analysisres.species{i}).error=analysisres.error{i};
            stl.(analysisres.species{i}).fit='Previous';
            references.exclude='false';
            references.runid=analysisres.nrrunidentifier{i};
            
            stl.(analysisres.species{i}).references={references};
            stl.(analysisres.species{i}).value=analysisres.result{i};
            
        end
    else
        %         stl.(nudata.results.names{i}).error=0;
        %         stl.(analysisres.species{i}).fit='Previous';
        %         references.exclude='false';
        %         references.runid=Null;
        %
        %         stl.(analysisres.species{i}).references={references};
        %         stl.(analysisres.species{i}).value=0;
    end
    jswrite([fp '.blan.json'],stl);
    jslist=[jslist;[fp '.blan.json']];
    
end
%create repo if necessary

%move to repository

gitinfo.subrepo.cleanfiles(fp);


status=gitinfo.subrepo.addfiles(fp);

qinfo.DB.DefaultDatabase='PYCHRON';
if status
    s=['delete from RepositoryAssociationTbl where (analysisID =  ' num2str(dgit.analysisID) ')'];
    res=doquery(s);
    s=['Insert INTO RepositoryAssociationTbl(repository,analysisID) Values' ];
    s=[s ' (''' gitinfo.currentrepo.name ''' ,' num2str(dgit.analysisID) ')'];
    res=doquery(s);
end
gitinfo.currentrepo.haschanges=status;

if gitinfo.currentrepo.haschanges;h=msgbox('JSON Files moved to local repository');pause(1);delete(h);end
qinfo.DB.DefaultDatabase='ARDATA';