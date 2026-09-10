function NuData=loadNGXDataFile(filepath)
global nuactual
lastcollector=5;lastfaraday=1;lastIC=4;
success=1;
if nargin<1
    
    [fname fpath success]= uigetfile('*.TXT');
    if success
        filepath=[fpath fname];
    end
    
end

fclose all
fid = fopen(filepath,'r');
count = 0;
while ~feof(fid)
    line = fgetl(fid);
    if isempty(line) || strncmp(line,'%',1) || ~ischar(line)
        continue
    end
        count = count + 1;
    filedata(count)={line};

end
fclose(fid);

if success
  %  fid=fopen(filepath);
 %   if fid == -1; msgbox(['Error, Can''t open file ' filepath]);NuData=[];return;end
    
       %filedata=textread(filepath,'%s');
    
       headerstart=findline(filedata,'#HEADER')+1;
       collectorstart=findline(filedata,'#COLLECTOR')+1;
       headerend=collectorstart-2;
       baselinestart=findline(filedata,'#BASELINES')+1;
       collectorend=baselinestart-2;
       onpeakstart=findline(filedata,'#ONPEAK')+1;
       baselineend=onpeakstart-2;
       fileend=findline(filedata,'#END');
       onpeakend=fileend-1;
       
    headerdata=filedata(headerstart:headerend);   
     baselines=filedata(baselinestart:baselineend);
     collectordata=filedata(collectorstart+1:collectorend);
     onpeakdata=filedata(onpeakstart:onpeakend);
     
     
     collectorheader=filedata(collectorstart);
     fs=strsplit(char(collectorheader),',');
         nofs=length(fs); formatstring=[];
      for i=1:nofs;
          switch fs{i};
              case 'Name'
                   formatstring=[formatstring '%s '];
              case 'Type'
                   formatstring=[formatstring '%s '];
                  case 'Resistor'
                       formatstring=[formatstring '%f '];
              case 'Gain'
                   formatstring=[formatstring '%f '];
              case 'Efficiency'
                   formatstring=[formatstring '%f '];
              case 'DT'
                   formatstring=[formatstring '%f '];
                                 otherwise
              formatstring=[formatstring '%s '];
          end
      end
            formatstring(end)=[];
                 
        cd= textscan(char(collectordata)',formatstring,'delimiter',',','EmptyValue',-Inf)                        
     
    cd= cell2struct(cd,fs,2);
     
     
     formatstring=filedata{baselinestart-2};
     fs=strsplit(formatstring,','); % get rid of .B entries
     
      fs=fs(~contains(fs,'.'));
      nofs=length(fs);
      formatstring=[];
      for i=1:nofs;
          switch fs{i};
              case 'ID'
                  formatstring=[formatstring '%s '];
              case 'Block'
                    formatstring=[formatstring '%d '];
              case 'Cycle'     
                    formatstring=[formatstring '%d '];
              case 'Integ'                    
                    formatstring=[formatstring '%d '];
              case 'PeakID'
                    formatstring=[formatstring '%s '];
              case 'AxMass'
                    formatstring=[formatstring '%f '];
              case 'Time'
                    formatstring=[formatstring '%f '];
              otherwise
              formatstring=[formatstring '%f '];
          end
      end
          formatstring(end)=[];%formatstring=[formatstring '\n'];
        od= textscan(char(onpeakdata)',formatstring,'delimiter',',','EmptyValue',-Inf)            
 %  od= cellfun(@(x) textscan(x,formatstring),onpeakdata,'UniformOutput',false) 
         
delims=strfind(onpeakdata,',');
nodelims=find(cellfun(@(x) size(x,2),delims)>nofs-1);

longstrings=onpeakdata(nodelims);
truncate=cellfun(@(x) x(nofs), delims(nodelims));
for i=1:length(longstrings);
    longstrings(i)={longstrings{i}(1:truncate(i)-1)};
end
onpeakdata(nodelims)=longstrings;

od= textscan(char(onpeakdata)',formatstring,'delimiter',',','EmptyValue',-Inf);
 od=cell2struct(od,fs,2);

delims=strfind(baselines,',');
nodelims=find(cellfun(@(x) size(x,2),delims)>nofs-1);
longstrings=baselines(nodelims);
truncate=cellfun(@(x) x(nofs), delims(nodelims));
for i=1:length(longstrings);
    longstrings(i)={longstrings{i}(1:truncate(i)-1)};
end
baselines(nodelims)=longstrings;

 baselines= textscan(char(baselines)',formatstring,'delimiter',',','EmptyValue',-Inf);

baselines=cell2struct(baselines,fs,2);




    NuData.File_Name=filepath;
    NuData.Version_No=fpline(headerdata,'Version');
    
    NuData.Number_Of_Cycles=max(od.Cycle);
    NuData.Number_Of_Zero_Cycles=max(baselines.Cycle);
    NuData.Detectors=fs(8:end);
    startime=datenum(fpline(headerdata,'TimeZero'),'dd mmmm yy HH:MM:SS.FFF')
    
    Nudata.New_Time=datestr(startime);%% need to find the right format
NuData.Start_Run_Time=startime;
 %   [dummy NuData.Start_Integ]=strstrip(fgetl(fid));
 %   [dummy NuData.End_Integ]=strstrip(fgetl(fid));

%    [dummy NuData.No_Of_Analysis_Cycles]=strstrip(fgetl(fid));
 %   [dummy NuData.Offset_Time]=strstrip(fgetl(fid));

  %  [dummy NuData.Collector_Gain]=strstrip(fgetl(fid));
    
    
%     for i=1:NuData.Number_Of_Cycles
%         Nudata.Cycle_Start(i)=str2double(fgetl(fid));
%     end
  NuData.Number_Of_Cycles =max(od.Cycle); 
    [dummy cycindex]=unique(od.Cycle);
    Nudata.Cycle_Start=cycindex;
    
%     for i=1:lastfaraday
%         NuData.Measure_Faraday(i)=str2double(fgetl(fid));
%     end
%     for i=1:lastIC
%         NuData.Measure_ID(i)=str2double(fgetl(fid));
%     end
%     for i=1:lastcollector
%         NuData.Display_Params(i,:)=sscanf(fgetl(fid),'%f,%f,%f,%f');
%     end
  %  NuData.Plot_Denominator_Beam=str2double(fgetl(fid));
  %  [dummy NuData.Number_Of_Peaks_Centered]=strstrip(fgetl(fid));

    NuData.Acq_File=dequote(fgetl(fid));
    NuData.Sample_Name=dequote(fgetl(fid));
    NuData.IC_HT=dequote(fgetl(fid));
    NuData.Disc_Settings=dequote(fgetl(fid));
    
    
    for i=length(NuData.detectors):-1:1
        if NuData.Measure_ID(i)==0;NuData.detectors(i)=[];end
    end
    if NuData.Measure_Faraday==-1;NuData.detectors={NuData.detectors{:}, 'fc'};end
    
    for i=1:8;
        fgetl(fid);
    end
    
    if ~strcmp(fgetl(fid),'""') % should be at start of data!
        
        msgbox('Error Reading File');
        return;
    else
        scanformatstring=['%f %f'];
        for index=1:-sum(NuData.Measure_ID); % build the scan format string to the right length
            scanformatstring=[scanformatstring ' %f'];
        end
        if NuData.Measure_Faraday==-1;
            scanformatstring=[scanformatstring ' %f'];
        end
        
        data=textscan(fid,scanformatstring,'delimiter',',');
        
        
        datatype=data{end};
        datatypes=unique(datatype);
        
        darksteps=datatypes(datatypes>0 & datatypes <100)';
        NuData.darksteps={['S' num2str(darksteps(1))]};
        for i=darksteps(2:end);NuData.darksteps={NuData.darksteps{:},['S' num2str(i)]};end
        
        datasteps=datatypes(datatypes>100)';
        NuData.datasteps={['S' num2str(datasteps(1))]};
        for i=datasteps(2:end);NuData.datasteps={NuData.datasteps{:},['S' num2str(i)]};end
        
        for i=1:length(darksteps)
            stepstring=NuData.darksteps{i};
            
            columnindex=1;
            for index=0:1;
                if NuData.Measure_ID(index+1)==-1;
                    icstring=['ic' num2str(index)];
                    NuData.(stepstring).([icstring 'dark'])=data{columnindex}(datatype==darksteps(i));
                    columnindex=columnindex+1;
                end
            end
            
            if NuData.Measure_Faraday
                NuData.(stepstring).fcdark=data{columnindex}(datatype==darksteps(i));
                columnindex=columnindex+1;
            end
            for index=2:3;
                if NuData.Measure_ID(index+1)==-1;
                    icstring=['ic' num2str(index)];
                    NuData.(stepstring).([icstring 'dark'])=data{columnindex}(datatype==darksteps(i));
                    
                    
                    columnindex=columnindex+1;
                end
            end
            NuData.(stepstring).darktime=data{columnindex}(datatype==darksteps(i));
            NuData.(stepstring).darktype=data{columnindex+1}(datatype==darksteps(i));
            
        end
        
        
        
        
        for i=1:length(datasteps)
            stepstring=NuData.datasteps{i};
            
            columnindex=1;
            for index=0:1;
                if NuData.Measure_ID(index+1)==-1;
                    icstring=['ic' num2str(index)];
                    
                    NuData.(stepstring).([icstring 'data'])=data{columnindex}(datatype==datasteps(i));
                    columnindex=columnindex+1;
                end
            end
            
            
            if NuData.Measure_Faraday
                NuData.(stepstring).fcdata=data{columnindex}(datatype==datasteps(i));
                columnindex=columnindex+1;
            end
            
            for index=2:3;
                if NuData.Measure_ID(index+1)==-1;
                    icstring=['ic' num2str(index)];
                    
                    NuData.(stepstring).([icstring 'data'])=data{columnindex}(datatype==datasteps(i));
                    
                    columnindex=columnindex+1;
                end
            end
            
            
            NuData.(stepstring).datatime=data{columnindex}(datatype==datasteps(i));
            NuData.(stepstring).datatype=data{columnindex+1}(datatype==datasteps(i));
        end
    end
    
    
    %         NuData.ic0dark=mean(data{1}(datatype==1));
    %         NuData.ic1dark=mean(data{2}(datatype==1));
    %         NuData.ic2dark=mean(data{4}(datatype==1));
    %         NuData.ic3dark=mean(data{5}(datatype==1));
    %         NuData.fcdark=mean(data{3}(datatype==1));
    
    % dark current corrected data
    
    %         NuData.ic0data=data{1}(datatype==101)-NuData.ic0dark;
    %         NuData.ic1data=data{2}(datatype==101)-NuData.ic1dark;
    %         NuData.fcdata=data{3}(datatype==101)-NuData.fcdark;
    %         NuData.ic2data=data{4}(datatype==101)-NuData.ic2dark;
    %         NuData.ic3data=data{5}(datatype==101)-NuData.ic3dark;
    %         NuData.datatime=data{6}(datatype==101);
    %         NuData.datatype=data{7}(datatype==101);
    
    
    fclose(fid);
end







function [fieldname,fieldval]=strstrip(instr);
fieldname=[];fieldval=[];

% data parameter

[fieldname res]=strtok(instr,',');
fieldname=dequote(fieldname);

if ~isempty(res)
    
    i=0;done=0;
    while ~done
        i=i+1;
        [val res]=strtok(res,',');
        if ~isempty(val)
            if ~isnan(str2double(val))
                fieldval(i)=str2double(val);
            elseif length(findstr(val,'#'))==2; % datestring detected
                val(findstr(val,'#'))=[];
                fieldval(i)=datenum(val);
            else
                fieldval(i)=NaN;
            end
        else
            done=1;
        end
        
    end
    
    
end


%

function instring=dequote(instring)

instring(strfind(instring,'"'))=[];


function instring=decomma(instring)

instring(strfind(instring,','))=[];

function instring=depound(instring)

instring(strfind(instring,'#'))=[];

function out=findline(instrings,searchstr);
% find the line which is the first occurences of searchstr in 
%cell array of instrings;
sf=strfind(instrings,searchstr);
out=find(~cellfun(@isempty,sf),1);
if out
else
    out=-1;
end

function out=fpline(instrings,searchstr);
% find and parse line
% return the rest of the line (after the comma) for the line in instrings
% that starts with searchstr;  
% instring is a cell array of strings
sf=strfind(instrings,searchstr);
 lineno=find(~cellfun(@isempty,sf),1);
 if lineno
    out=instrings{lineno}(length(searchstr)+2:end);
else
    out='Null';
end