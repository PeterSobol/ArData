function NuData=loadNuDataFile(filepath)

lastcollector=5;lastfaraday=1;lastIC=4;
success=1;
if nargin<1
    
    [fname fpath success]= uigetfile('*.RUN');
    if success
        filepath=[fpath fname];
    end
    
end

if success
    fid=fopen(filepath);
    if fid == -1; msgbox(['Error, Can''t open file ' filepath]);NuData=[];return;end
    
    NuData.File_Name=filepath;
    NuData.Version_No=fgetl(fid);
    [dummy NuData.Number_Of_Cycles]=strstrip(fgetl(fid));
    [dummy NuData.New_Time]=strstrip(fgetl(fid));
    [dummy NuData.Start_Integ]=strstrip(fgetl(fid));
    [dummy NuData.End_Integ]=strstrip(fgetl(fid));
    [dummy NuData.No_Of_Zero_Cycles]=strstrip(fgetl(fid));
    [dummy NuData.No_Of_Analysis_Cycles]=strstrip(fgetl(fid));
    [dummy NuData.Offset_Time]=strstrip(fgetl(fid));
    [dummy NuData.Start_Run_Time]=strstrip(fgetl(fid));
    %    NuData.Start_Run_Time=  datenum(depound(NuData.Start_Run_Time));
    [dummy NuData.Collector_Gain]=strstrip(fgetl(fid));
    
    
    for i=1:NuData.Number_Of_Cycles
        Nudata.Cycle_Start(i)=str2double(fgetl(fid));
    end
    
    
    for i=1:lastfaraday
        NuData.Measure_Faraday(i)=str2double(fgetl(fid));
    end
    for i=1:lastIC
        NuData.Measure_ID(i)=str2double(fgetl(fid));
    end
    for i=1:lastcollector
        NuData.Display_Params(i,:)=sscanf(fgetl(fid),'%f,%f,%f,%f');
    end
    NuData.Plot_Denominator_Beam=str2double(fgetl(fid));
    [dummy NuData.Number_Of_Peaks_Centered]=strstrip(fgetl(fid));
    [dummy NuData.Number_Of_Deflectors_Available]=strstrip(fgetl(fid));
    [dummy NuData.Source_HT]=strstrip(fgetl(fid));
    [dummy NuData.Half_Plate_V]=strstrip(fgetl(fid));
    [dummy NuData.Trap]=strstrip(fgetl(fid));
    [dummy NuData.Trap_Voltage]=strstrip(fgetl(fid));
    [dummy NuData.Repeller]=strstrip(fgetl(fid));
    [dummy NuData.Filament_V]=strstrip(fgetl(fid));
    [dummy NuData.Delta_HP]=strstrip(fgetl(fid));
    [dummy NuData.Z_Lens]=strstrip(fgetl(fid));
    [dummy NuData.Delta_Z]=strstrip(fgetl(fid));
    [dummy NuData.Max_Current]=strstrip(fgetl(fid));
    [dummy NuData.Quad_1]=strstrip(fgetl(fid));
    [dummy NuData.Cubic_1]=strstrip(fgetl(fid));
    [dummy NuData.Lin_1]=strstrip(fgetl(fid));
    [dummy NuData.Q18_Cor]=strstrip(fgetl(fid));
    [dummy NuData.Q19_Cor]=strstrip(fgetl(fid));
    [dummy NuData.Quad_2]=strstrip(fgetl(fid));
    [dummy NuData.Cubic_2]=strstrip(fgetl(fid));
    [dummy NuData.Lin_2]=strstrip(fgetl(fid));
    [dummy NuData.Q28_Cor]=strstrip(fgetl(fid));
    [dummy NuData.Q29_Cor]=strstrip(fgetl(fid));
    [dummy NuData.Suppressor]=strstrip(fgetl(fid));
    [dummy NuData.Deflect_IC1]=strstrip(fgetl(fid));
    [dummy NuData.Filter_IC0]=strstrip(fgetl(fid));
    [dummy NuData.Deflect_IC0]=strstrip(fgetl(fid));
    [dummy NuData.Deflect_IC2]=strstrip(fgetl(fid));
    [dummy NuData.Filter_IC3]=strstrip(fgetl(fid));
    [dummy NuData.Deflect_IC3]=strstrip(fgetl(fid));
    NuData.Acq_File=dequote(fgetl(fid));
    NuData.Sample_Name=dequote(fgetl(fid));
    NuData.IC_HT=dequote(fgetl(fid));
    NuData.Disc_Settings=dequote(fgetl(fid));
    
    NuData.detectors={'ic0','ic1','ic2','ic3'};
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

