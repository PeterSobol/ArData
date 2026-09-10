function [outputfig,output] =fitnudata(nudata,dbdata,options)
% linear fit of nudata file
global fileinfo out
fileinfo.nicefilepath=options.nicefilepath;

if isfield(options,'displayflag')
    displayflag=options.displayflag;
end

output=[];

% %required in options:
%     options.nicefilepath
%     options.sigma
%     options.autosaveclose
%     options.sectoexclude

%     options.fittype
%     options.maxcycles
%     options.timezerooffset
%     options.updatepychron



if ~options.autoclose;
    % warning will close WITHOUT SAVING if too many windows
    fighandles= findobj('tag','figFitDisplay');
    if length(fighandles)>3;
        %need to close some figures
        [~,index]=min([fighandles.Number]);
        close(fighandles(index));
    end
end


set(0,'units','characters');
screensize=get(0,'screensize');
outputfig=figure;
%output=outputfig; % return the figure handle
figpos=[10 screensize(4)*.1 215 round(screensize(4)*.8)  ];
set(outputfig,'toolbar','figure','units','characters','position',figpos,'Tag','figFitDisplay');
figheight=figpos(4);
sigma=options.sigma;

temph=uicontrol('parent',outputfig,'style','text','units','characters','string','exclude sigma:','position',[142   figheight-1.0  18    1.0]);
set(temph,'units','normalized');
handles.edSigma=uicontrol('tag','edSigma','parent',outputfig,'style','edit','units','characters','string',num2str(sigma),'position',[160   figheight-1.1    5    1.5],'backgroundcolor',[1 1 1]);

sectoexclude=options.sectoexclude;

temph=uicontrol('parent',outputfig,'style','text','units','characters','string','Sec. to Exclude:','position',[142   figheight-2.5  18    1.2]);
set(temph,'units','normalized');
handles.edSecondsToExclude=uicontrol('tag','edSecondsToExclude','parent',outputfig,'style','edit','units','characters','string',num2str(sectoexclude),'position',[160   figheight-2.5    5    1.5],'backgroundcolor',[1 1 1]);

fittype=options.fittype;

fitstrings={'Linear','Exponential'};
handles.puFitType=uicontrol('tag','puFitType','parent',outputfig,'style','popupmenu','units','characters','string',fitstrings,'position',[167 figheight-1.75 15 2],'backgroundcolor',[1 1 1]);
whichfit=find(strcmp(fitstrings,fittype));

set(handles.puFitType,'value',whichfit);
handles.pbCropData=uicontrol('parent',outputfig,'style','togglebutton','units','characters','string','Crop Data','position',[183 figheight-1.4 10 2],'callback',@puCropDataCallback);
handles.pbFit=uicontrol('parent',outputfig,'style','pushbutton','units','characters','string','fit','position',[195 figheight-1.4 10 2],'callback',@puFitCallback);

handles.pbZoom=uicontrol('parent',outputfig,'style','togglebutton','units','characters','string','Zoom','position',[5 figheight-3 10 2],'callback',@tbZoomCallback);
handles.pbZoomBaselines=uicontrol('parent',outputfig,'style','togglebutton','units','characters','string','Baselines','position',[16 figheight-3 10 2],'callback',@tbZoomBaselinesCallback);

handles.pbCancel=uicontrol('parent',outputfig,'style','pushbutton','units','characters','string','Cancel','position',[117   1    20    3],'callback',@puCancelCallback);
handles.pbExcludeData=uicontrol('parent',outputfig,'style','pushbutton','units','characters','string','Exclude Data','position',[96    1   20    3],'callback',@puExcludeDataCallback);
handles.pbSaveandExit=uicontrol('parent',outputfig,'style','pushbutton','units','characters','string','Save and Exit','position',[75    1    20    3],'callback',@puSaveandExitCallback);

[pathdummy filename]=fileparts(nudata.File_Name);
[~, acqname]=fileparts(nudata.Acq_File);
titlestring=[filename ': ' nudata.Sample_Name '    Acq. File: ' acqname];

titlepos=[20 figheight-1.0 120 1.2];

handles.titlehandle=uicontrol('parent',outputfig,'style','text','units','characters','position',titlepos,'string',titlestring,'fontsize',10,'fontweight','bold');

for handlei={'puFitType','pbFit','pbCancel','pbExcludeData','pbSaveandExit','edSigma','titlehandle'}
    set(handles.(handlei{:}),'units','normalized');%resets resize behaviour.
end

if strfind(dbdata.prep_split,'CubeOnly');
    dbdata.prep_split='Cube';
end

handles.nudata=nudata;
handles.dbdata=dbdata;
handles.options=options;

guidata(outputfig,handles);

nudata=nufitall(outputfig);

output=nudata;
handles.nudata=nudata;

guidata(outputfig,handles);

if options.autoclose % save the data and close the window.
    
    puSaveandExitCallback(handles.pbSaveandExit,[]);
end


%xloutheader={nudata.Start_Run_Time,nudata.File_Name,nudata.Sample_Name};
%xlout={};
% for dsi=nudata.datasteps;dsi=dsi{:};
%
%     for det={'ic0','ic1','ic2','ic3','fc'};det=det{:};
%         if isfield(nudata.(dsi),det)
%             xlout=[xlout nudata.(dsi).(det).result nudata.(dsi).(det).error];
%         else
%             xlout=[xlout,NaN,NaN];
%         end
%     end
%
%
% end
%writetoexcel([xloutheader xlout]);



%message={nudata.Sample_Name;labelstring;datastring};

%addmessage(message);
%writetoexcel(output);



    function nudata=nufitall(outputfig);
        global fittemp
        fittemp={};
        fittempindex=1;
        %fittempindex=length(fittemp)+1;
        %read the option for the max number of cycles to use in the fit.
        maxcycles=options.maxcycles;
        
        darkred=[.7 0 0];darkgreen=[0 .7 0];
        cleanflag=1;
        handles=guidata(outputfig);
        nudata=handles.nudata;
        
        % load up the various user defined parameters.
        fitstrings=get(handles.puFitType,'string');
        fittype=fitstrings{get(handles.puFitType,'value')};
        
        sigma=get(handles.edSigma,'string');
        sigma=str2double(sigma);
        
        secondstoexclude=get(handles.edSecondsToExclude,'string');
        secondstoexclude=str2double(secondstoexclude);
        timezerooffset=0;
        timezerooffset=options.timezerooffset;
        
        delete(findobj(outputfig,'tag','plotaxis'));
        
        ud=get(gcf,'userdata');
        if isfield(ud,'croplimits') && ~isempty(ud.croplimits)
            croplimits=ud.croplimits;
            cropflag=1;
        else
            cropflag=0;
        end
        
        if ~isempty(nudata.Number_Of_Cycles);
            
            %% first lets get the zero offsets
            if nudata.No_Of_Zero_Cycles >1
                % fit the dark counts for an offset
                for dsi=nudata.darksteps;dsi=dsi{:};
                    for det=nudata.detectors;det=det{:};
                        time=nudata.(dsi).darktime + double(handles.dbdata.admitdelay)+timezerooffset;
                        %
                        data=nudata.(dsi).([det 'dark']);
                        [time data]=cleandata(time,data,sigma);
                        
                        out=linregress(time,data);
                        
                        nudata.(det).offset=out.fit;
                        nudata.(det).offsetsigma=out.sigma;
                        nudata.(det).fittype='linear';
                    end
                    
                end
                
            else  % just use the mean from the first cycle
                for dsi=nudata.darksteps;dsi=dsi{:};
                    %XXXX WARNING - ONLY CORRECT IF ONE BASELINE CYCLE
                    for det=nudata.detectors;det=det{:};
                        
                        data=nudata.(dsi).([det 'dark']);
                        data=cleanmean(data,sigma);
                        
                        nudata.(det).offset=[mean(data) 0];
                        nudata.(det).offsetsigma=std(data);
                        nudata.(det).fittype='mean';
                        
                        %nudata.(det).offset=[ mean(nudata.(dsi).([det 'dark'])) 0];
                        %nudata.(det).offsetsigma=std(nudata.(dsi).([det 'dark']));
                    end
                    
                end
                
            end
            
            
            % now lets get the data
            
            noplots=length(nudata.datasteps)*(length(nudata.detectors)-1);
            s=ceil(noplots^.5);
            
            plotcount=0;
            for dsi=nudata.datasteps;dsi=dsi{:};
                for det=nudata.detectors;det=det{:};
                    if ~strcmp(det,'fc'); % ignore the FC data
                        plotcount=plotcount+1;
                        
                        data=nudata.(dsi).([det 'data']);
                        time=nudata.(dsi).datatime + double(handles.dbdata.admitdelay)+timezerooffset;
                        
                        
                        %          data=data-(time*nudata.(det).offset(2)-nudata.(det).offset(1));
                        %          % subtract the zeros.  NO! DO this after the fit!
                        
                        %e=[ones(size(data)) time];
                        % fit=e\data;
                        if displayflag
                            figure(outputfig);currentax=subplot(s,s,plotcount);
                            
                            if( secondstoexclude>0 || cleanflag)
                                %plot original data
                                ploth=plot(time,data,'.r');hold all;
                            end
                        end
                        if cropflag;
                            [time data]=cropdata(time,data,croplimits);
                        end
                        [time data]=trimdata(time,data,secondstoexclude);
                        %     time=time(1:49);data=data(1:49); XXX used to fix a broken
                        %     dataset
                        
                        switch(fittype)
                            
                            case('Linear')
                                if cleanflag;
                                    %plot original data
                                    %    ploth=plot(time,data,'.r');hold all;
                                    
                                    [time data]=cleandata(time,data,sigma);% XXX
                                end
                                %% identify the cycle breaks
                                databreaks= find(time(2:end)-time(1:end-1)>5)'+1;
                                databreaks=[1 databreaks length(time)+1];
                                %
                                if maxcycles<length(databreaks-1); % limit the number of cycles used.
                                    
                                    subvec=databreaks(1):databreaks(maxcycles+1)-1;
                                    databreaks=databreaks(1:maxcycles+1);
                                    time=time(subvec);data=data(subvec);
                                    
                                else
                                    
                                end
                                
                                %                      %%  XXX Limit the number datapoints - experimental only - remove!!!
                                %                        for i=1:length(databreaks)-1;
                                %                             subvec=databreaks(i):databreaks(i+1)-1;
                                %                              subvec=subvec(5:end); % use first 4 points only
                                %                             data(subvec)=-999;
                                %
                                %                        end
                                %                        time(data==-999)=[]; data(data==-999)=[];
                                %%
                                
                                if displayflag
                                    
                                    ploth=plot(time,data,'.g');hold all;
                                    bounds=[min([0 min(time) double(handles.dbdata.admitdelay)]) max(time) min(data) max(data)];
                                    bounds(1)=bounds(1)-.01*(bounds(2)-bounds(1));
                                    bounds(3)=max([0 bounds(3)-(max(data)-min(data))]);bounds(4)=bounds(4)+(max(data)-min(data));
                                end
                                out=linregress(time,data);
                                nudata.(dsi).(det).fittype='linear';
                                nudata.(dsi).(det).fit=out.fit;
                                nudata.(dsi).(det).sigma=out.sigma;
                                nudata.(dsi).(det).result=out.fit(1)-nudata.(det).offset(1);
                                nudata.(dsi).(det).error=sqrt(out.sigma(1)^2+nudata.(det).offsetsigma(1)^2);
                                nudata.(dsi).(det).excludesigma=sigma;
                                %output.(dsi).(det)=[nudata.(dsi).(det).result nudata.(dsi).(det).error];
                                
                                %% XXX temp stuff to extract fit data
                                fittemp{fittempindex}.(dsi).(det).fit=nudata.(dsi).(det).fit; %XXXX
                                
                                str=['IC(' det(3) ') ='];
                                HTstring=nudata.IC_HT;
                                place=findstr(HTstring,str);
                                
                                fittemp{fittempindex}.(dsi).(det).volts=sscanf(HTstring(place:end),[str '%i']);
                                fittemp{fittempindex}.(dsi).(det).time=nudata.Start_Run_Time;
                                fittemp{fittempindex}.(dsi).(det).fname=nudata.File_Name;
                                
                                %% XXXX
                                
                                % plot fit
                                if displayflag
                                    plot([0; time], out.fit(1)+[0; time]*out.fit(2));
                                    
                                    %          ax=axis;
                                    %axis([ax(1:2) 0 ax(4)*1.1]);
                                    %axis(bounds);
                                    %   if ax(1)<0;
                                    %         bounds(1)=double(handles.dbdata.admitdelay)-.01*(bounds(2)-double(handles.dbdata.admitdelay));
                                    %  end
                                    axis(bounds); %restrict the axes to limits of data in x and y
                                    ax=axis;      % get current axis values.  ax= [xmin xmax ymin ymax];
                                    range=(max(data)-min(data))/5;   % y range is 20% of max(data) - min(data) (data is only unexcluded pts.)
                                    ud.ax1=[ax(1:2) 0 max([data; out.fit(1)])+range];  % full scale
                                    
                                    ud.ax2=[0 max(time) min([data; out.fit(1)])-range max([data; out.fit(1)])+range];  %xmin: t=0 xmax:max(time) ymin:min(data,intercept)-20% of range ymax: max(data,intercept)+20% of range
                                    axis(ud.ax2);
                                end
                                %text(0,out.fit(1),[' ' num2str(round(out.fit(1)))],'color','b');
                                % textbp(['Intercept=' num2str(round(out.fit(1)))],'color','b');
                                try
                                    if displayflag;
                                        textbp(['Intercept=' sprintf('%10.4f',out.fit(1))],'color','b');
                                    end
                                catch
                                end
                                %  sprintf('%10.4',out.fit(1))
                                
                                %% fit and plot fits for each cycle Check that fits
                                % match overall result!  If not show a warning.
                                %                       databreaks= find(time(2:end)-time(1:end-1)>5)'+1;
                                %                      databreaks=[1 databreaks length(time)+1];
                                % This section fits each cycle's data and warns if
                                % fit of each cycle is statistically outside the
                                % overall fit of the data.  Help detect detector
                                % and other data issues.
                                
                                
                                %dofitincongruity=0;
                                % if dofitincongruity
                                
                                fitincongruity=0;
                                fittemp{fittempindex}.(dsi).(det).slopes=[]; %XXX
                                for i=1:length(databreaks)-1;
                                    subvec=databreaks(i):databreaks(i+1)-1;
                                    %XXXXXXXX
                                    %   subvec=[databreaks(end-i):length(time)];
                                    
                                    % XXXXXXX
                                    
                                    subtime=time(subvec);subdata=data(subvec);
                                    if displayflag
                                        if length(subtime)>3;
                                            fitresult=fit(subtime,subdata,'poly1');
                                            
                                            fittemp{fittempindex}.(dsi).(det).slopes= [fittemp{fittempindex}.(dsi).(det).slopes fitresult.p1];%XXX
                                            %plot(fitresult,'r');
                                            subfit=feval(fitresult,subtime([1 end]));
                                            extension=(max(subtime)-min(subtime))/2;
                                            
                                            %   extension=0;
                                            
                                            fithdl=plot([min(subtime)-extension max(subtime)+extension],subfit,'m');
                                            p = predint(fitresult,subtime,0.95,'functional','on');
                                            plot(subtime,p,'b');
                                            p=predint(fitresult,0,0.95,'functional','on');
                                            %
                                            if nudata.(dsi).(det).result + nudata.(det).offset(1)<min(p) || nudata.(dsi).(det).result + nudata.(det).offset(1)>max(p);
                                                %fit incongruity detected!
                                                fitincongruity=1;
                                                set(fithdl,'color','r');
                                                %xvec=[0;subtime];
                                                xvec=[min(subtime)-(max(subtime)-min(subtime))/2;subtime;max(subtime)+(max(subtime)-min(subtime))/2];
                                                p = predint(fitresult,xvec,0.99,'functional','on');
                                                plot(xvec,p,'r');
                                            end
                                        end
                                    end
                                end
                                if displayflag
                                    if fitincongruity;
                                        text(0,ax(4)*.05,'Fit Incongruity Detected','color','r');
                                    end
                                end
                                % end
                                %%
                                
                            case('Exponential')
                                
                                if cleanflag;
                                    ploth=plot(time,data,'.r');hold all;
                                    %plot original data
                                    [time data]=cleandata(time,data,sigma);
                                end
                                
                                if displayflag; ploth=plot(time,data,'.g');hold all;end
                                out=expfit(time,data);
                                nudata.(dsi).(det).fittype='exponential';
                                nudata.(dsi).(det).fit=out.fit;
                                nudata.(dsi).(det).sigma=out.sigma;
                                nudata.(dsi).(det).result=expfun(out.fit,0)-nudata.(det).offset(1);
                                nudata.(dsi).(det).error=sqrt(out.sigma(1)^2+nudata.(det).offsetsigma(1)^2); %%% this is probably wrong XXX
                                nudata.(dsi).(det).excludesigma=sigma;
                                %output.(dsi).(det)=[nudata.(dsi).(det).result nudata.(dsi).(det).error];
                                
                                
                                % plot fit
                                if displayflag;
                                    plot([0; time], expfun(out.fit,[0; time]));
                                    
                                    ax=axis;
                                    axis([ax(1:2) 0 ax(4)*1.1]);
                                    
                                    text(0,(out.fit(1)+out.fit(2)),[' ' num2str(round(out.fit(1)+out.fit(2)))],'color','r');
                                end
                        end
                        if displayflag;set(ploth,'ButtonDownFcn',@fitgetdata,'userdata',{dsi,det});end
                        
                        %plot darkdata
                        if displayflag
                            minx=[];maxx=[];miny=[];maxy=[];
                            for zerodsi=nudata.darksteps;zerodsi=zerodsi{:};
                                plot(nudata.(zerodsi).darktime + double(handles.dbdata.admitdelay),nudata.(zerodsi).([det 'dark']),'.','color',darkgreen);
                                minx=min([minx nudata.(zerodsi).darktime + double(handles.dbdata.admitdelay)]);
                                maxx=max([maxx nudata.(zerodsi).darktime + double(handles.dbdata.admitdelay)]);
                                miny=min([miny nudata.(zerodsi).([det 'dark'])]);
                                maxy=max([maxy nudata.(zerodsi).([det 'dark'])]);
                                
                                %plot darkfit
                                plot(nudata.(zerodsi).darktime+ double(handles.dbdata.admitdelay),nudata.(det).offset(2)*nudata.(zerodsi).darktime+nudata.(det).offset(1),'b');
                                
                            end
                            xsc=(maxx-minx)*.1;ysc=(maxy-miny)*.1;
                            ud.dx=[minx maxx miny maxy]+[-xsc xsc -ysc ysc];
                            ax=axis;
                            plot([double(handles.dbdata.admitdelay) double(handles.dbdata.admitdelay)],[ax(3) ax(4)]);
                            
                            hold off
                            
                            switch dsi;
                                case 'S101'
                                    titledsi='S1';
                                    
                                case 'S102'
                                    titledsi='S2';
                                otherwise
                                    titledsi=dsi;
                            end
                            title(['Step ' titledsi ' - ' det],'fontweight','normal','interpreter','tex','fontsize',9);
                            
                            if ~options.lotsafiles;drawnow;end
                            set(currentax,'tag','plotaxis','buttondownfcn',@PlotButtonDownFcn,'userdata',{dsi,det,s,plotcount,ud});
                            set(currentax,'ActivePositionProperty','outerposition');
                        end
                    end
                end
            end
            
            
            
            nudata=niceify(outputfig,nudata);  % parse the nice file and translate
            %% remove
            fittemp{fittempindex}.results=nudata.results;
            %%
            handles.nudata=nudata;
            guidata(outputfig,handles)
            
        end
        
    end

    function nudata=nufitone(outputfig,data);
        
        dsi=data{1};det=data{2};s=data{3};plotcount=data{4};
        
        darkred=[.7 0 0];darkgreen=[0 .7 0];
        cleanflag=1;
        handles=guidata(outputfig);
        nudata=handles.nudata;
        
        if ~isempty(nudata.Number_Of_Cycles);
            
            fitstrings=getuistring(handles.puFitType);
            fittype=fitstrings{get(handles.puFitType,'value')};
            
            sigma=getuistring(handles.edSigma);
            sigma=str2double(sigma);
            
            secondstoexclude=getuistring(handles.edSecondsToExclude);
            secondstoexclude=str2double(secondstoexclude);
            
            
            %% first lets get the zero offsets
            
            %% NOTE: nufitone DOES NOT REFIT THE dark steps
            
            %%
            
            %% now lets get the data
            
            
            
            if ~strcmp(det,'fc'); % ignore the FC data
                
                data=nudata.(dsi).([det 'data']);
                time=nudata.(dsi).datatime + double(handles.dbdata.admitdelay);
                
                
                %          data=data-(time*nudata.(det).offset(2)-nudata.(det).offset(1));
                %          % subtract the zeros.  NO! DO this after the fit!
                
                %e=[ones(size(data)) time];
                % fit=e\data;
                if displayflag;
                    figure(outputfig);currentax=subplot(s,s,plotcount);
                end
                switch(fittype)
                    case('Linear')
                        if displayflag
                            if cleanflag ;
                                ploth=plot(time,data,'.r');hold all;
                                %plot original data
                                [time data]=cleandata(time,data,sigma);
                            end
                            ploth=plot(time,data,'.g');hold all;
                            bounds=[0 max(time) min(data) max(data)];
                            bounds(3)=max([0 bounds(3)-(max(data)-min(data))]);bounds(4)=bounds(4)+(max(data)-min(data));
                            
                            out=linregress(time,data);
                            plot([0; time], out.fit(1)+[0; time]*out.fit(2));
                            set(ploth,'ButtonDownFcn',@fitgetdata,'userdata',{dsi,det});
                            ax=axis;
                            axis([ax(1:2) 0 ax(4)*1.1]);
                            axis(bounds);
                            text(0,out.fit(1)+ax(4)/10,[' ' num2str(round(out.fit(1)))],'color','r')
                        end
                        nudata.(dsi).(det).fittype='linear';
                        nudata.(dsi).(det).fit=out.fit;
                        nudata.(dsi).(det).sigma=out.sigma;
                        nudata.(dsi).(det).result=out.fit(1)-nudata.(det).offset(1);
                        nudata.(dsi).(det).error=sqrt(out.sigma(1)^2+nudata.(det).offsetsigma(1)^2);
                        
                        % output.(dsi).(det)=[nudata.(dsi).(det).result nudata.(dsi).(det).error];
                        
                        
                        % plot fit
                        ;
                        
                    case('Exponential')
                        if displayflag
                            if cleanflag;
                                ploth=plot(time,data,'.r');hold all;
                                %plot original data
                                [time data]=cleandata(time,data,sigma);
                            end
                            ploth=plot(time,data,'.g');hold all;
                            out=expfit(time,data);
                            
                            
                            
                            % plot fit
                            plot([0; time], expfun(out.fit,[0; time]));
                            set(ploth,'ButtonDownFcn',@fitgetdata,'userdata',{dsi,det});
                            ax=axis;
                            axis([ax(1:2) 0 ax(4)*1.1]);
                        end
                        text(0,(out.fit(1)+out.fit(2))+ax(4)/10,[' ' num2str(round(out.fit(1)+out.fit(2)))],'color','r');
                        nudata.(dsi).(det).fittype='exponential';
                        nudata.(dsi).(det).fit=out.fit;
                        nudata.(dsi).(det).sigma=out.sigma;
                        nudata.(dsi).(det).result= expfun(out.fit,0)-nudata.(det).offset(1);
                        nudata.(dsi).(det).error=sqrt(out.sigma(1)^2+nudata.(det).offsetsigma(1)^2);
                end
                
                
                %plot darkdata
                if displayflag
                    for zerodsi=nudata.darksteps;zerodsi=zerodsi{:};
                        plot(nudata.(zerodsi).darktime + double(handles.dbdata.admitdelay),nudata.(zerodsi).([det 'dark']),'.','color',darkgreen);
                        %plot darkfit
                        plot(nudata.(zerodsi).darktime + double(handles.dbdata.admitdelay),nudata.(det).offset(2)*nudata.(zerodsi).darktime+nudata.(det).offset(1),'b');
                    end
                    ax=axis;
                    plot([double(handles.dbdata.admitdelay) double(handles.dbdata.admitdelay)],[ax(3) ax(4)]);
                    hold off
                    
                    switch dsi;
                        case 'S101'
                            titledsi='S1';
                        case 'S102'
                            titledsi='S2';
                        otherwise
                            titledsi=dsi;
                    end
                    
                    title(['Step ' titledsi ' - Detector ' det],'fontweight','normal','interpreter','latex');
                    
                    if ~options.lotsafiles;drawnow;end;
                    set(currentax,'tag','plotaxis','buttondownfcn',@PlotButtonDownFcn,'userdata',{dsi,det,s,plotcount});
                end
            end
            nudata=niceify(outputfig,nudata);
            handles.nudata=nudata;
            output=nudata.results;
            guidata(outputfig,handles);
        end
        
        
    end
end


    function status=writetoexcel(data)
        global fileinfo
        %%
        status='';
        if ~isfield(fileinfo,'outputfilepath') ||  isempty(fileinfo.outputfilepath) % need to create file
            [filename pathname ]=uiputfile('*.xls','specify output xls file');
            if pathname ~=0;
                fileinfo.outputfilepath=[pathname filename];
                set(findobj('tag','edResultsFile'),'string',fileinfo.outputfilepath)
                fileinfo.lineno=0;
            else
                return
            end
        end
        
        try
            temp=xlsread(fileinfo.outputfilepath);
            fileinfo.lineno=size(temp,1)+1;
        catch
            msgbox('Output File not Found')
            [filename pathname ]=uiputfile('*.xls','specify output xls file');
            if ~isempty(filename)
                fileinfo.outputfilepath=[pathname filename];
                set(findobj('tag','edResultsFile'),'string',fileinfo.outputfilepath);
                fileinfo.lineno=0;
            end
        end
        
        if fileinfo.lineno==0; % need to write a header
            xlswrite(fileinfo.outputfilepath,fileinfo.header,'','A1');
            fileinfo.lineno=1;
        end
        xlswrite(fileinfo.outputfilepath,data,'',['A' num2str(fileinfo.lineno+1)]);
        fileinfo.lineno=fileinfo.lineno+1;
    end

    function nudata=niceify(outputfig,nudata);
        global fileinfo
        
        [pathstr, fname, ext] = fileparts(nudata.Acq_File);
        
        % find the nicefile
        nicepathstring=fullfile(fileinfo.nicefilepath,[fname '.crf']);
        direc=dir(nicepathstring);
        
        if ~isempty(direc)
            fid=fopen(nicepathstring);
            try
                nicecell={};
                done=0;
                while ~done
                    fline=fgetl(fid);
                    if ~isempty(fline);
                        if length(fline)==1 && fline == -1;
                            done=1;break;
                        else
                            nicecell={nicecell{:}, fline};
                            
                            
                        end
                    end
                end
                fclose(fid);
            catch ME
                msgbox('Can''t read file nicefile!')
                try;fclose(fid);catch;end
            end
            
            
            % find the nice file
            
            nicecell=strtrim(nicecell); % clean leading spaces
            dimlineno=strmatch('Dim',nicecell);dimlineno=dimlineno(1);
            %     dimline=nicecell(dimlineno);dimline=dimline{:};
            %     dimline(1:3)=[]; %remove the Dim string
            %     dimline=strrep(dimline,' ',''''); dimline=strrep(dimline,',',''',');
            %     dimline=[dimline ''''];
            % finte the results names
            
            resultstotalline=strmatch('"Total Number Of Answers ",',nicecell);
            [dummy noresults]=strtok(nicecell(resultstotalline),',');
            noresults=str2num(noresults{1}(2:end));
            
            names={};
            for i=1:noresults;
                name=nicecell{resultstotalline+i};
                name(regexp(name,'"'))=[];
                name=strrep(name,'/','d');
                names=[names {name}];
            end
            nudata.results.names=names;
            % eval(['nudata.results.names={ ' dimline '};']);
            
            detectorstring={'ic0','ic1','fc','ic2','ic3'};
            
            %define Mass and Zero Matrices
            for idsi=1:length(nudata.datasteps)
                for idet=1:length(detectorstring)
                    if isfield(nudata.(nudata.datasteps{idsi}),detectorstring{idet})
                        Mass(idsi,idet)= nudata.(nudata.datasteps{idsi}).(detectorstring{idet}).result;
                        Massstr(idsi,idet)={upper([nudata.datasteps{idsi} detectorstring{idet}])};
                        namestr{idsi,idet}={['nudata.' nudata.datasteps{idsi} '.' detectorstring{idet}]};
                        Merror(idsi,idet)= nudata.(nudata.datasteps{idsi}).(detectorstring{idet}).error;
                        N(idsi,idet)= size(nudata.(nudata.datasteps{idsi}).([detectorstring{idet} 'data']),1);
                        Data(idsi,idet)= {nudata.(nudata.datasteps{idsi}).([detectorstring{idet} 'data'])};
                        Datatime(idsi,idet)={nudata.(nudata.datasteps{idsi}).('datatime')};
                    end
                    if isfield(nudata,detectorstring{idet})
                        ZData(idsi,idet)={nudata.(nudata.darksteps{:}).([detectorstring{idet} 'dark'])};
                        ZDatatime(idsi,idet)={nudata.(nudata.darksteps{:}).('darktime')};
                    end
                end
            end
            
            
            for idet=1:length(detectorstring)
                if isfield(nudata,detectorstring{idet})
                    Zero(idsi,idet)= nudata.(detectorstring{idet}).offset(1);
                    Zerror(idsi,idet)= nudata.(detectorstring{idet}).offsetsigma(1);
                end
            end
            
            varlist=who; % get a variable list so that we can delete the made variables later
            % as the eval statement will create a bunch of
            % variables as it parses the nice file.
            
            for i=dimlineno+1:length(nicecell);  % evaluate the nice file line by line
                str=nicecell{i};
                eq=findstr(str,'=');
                digits=regexp(str,',[0-9]');  % compensate for zero indexing of detectors.
                for di=digits(digits>eq)
                    str(di+1)=num2str(str2double(str(di+1))+1);
                end
                digits=regexp(str,'[0-9])'); % compensate for zero indexing of results
                for di=digits(digits<eq)
                    str(di)=num2str(str2double(str(di))+1);
                end
                nicecell{i}=str; %rewrite nicell for error calcs.
                eval([str ';']);  %this line will calculate the values and results as listed in the nice file, and is pretty damn clever if I do say so myself.
                
            end
            
            
            
            
            % save the results in nudata
            nudata.results.value=Result;
            
            % delete the added variables from the eval statement.
            newvarlist=who;
            for i=1:length(newvarlist);
                if ~max(strcmp(newvarlist{i},varlist));clearvars(newvarlist{i});end
            end
            
            % Now add the error in quadrature
            Zero=Zerror;Mass=Merror;
            for i=dimlineno+1:length(nicecell);
                str=nicecell{i};
                eq=findstr(str,'=');
                
                rem=str(eq+1:end);
                accum=[];
                % add any values or variables in the nice statements to an
                % accumulator
                while true
                    [tok rem]= strtok(rem);
                    if isempty(tok);done=1;break;end
                    if exist(tok,'var');
                        accum=[accum eval(char(tok))];
                    elseif strncmp(tok,'Mass',4);
                        accum=[accum eval(char(tok))];
                    elseif strncmp(tok,'Zero',4);
                        accum=[accum eval(char(tok))];
                    end
                    
                end
                
                err=sqrt(sum(accum.^2));
                eval([str(1:eq)  num2str(err) ';']);  %
                
                
            end
            
            
            nudata.results.error=Result;
            
            %% record the detector string
            nicecellorig=nicecell;
            nicecell(cellfun(@isempty,nicecell))=[];
            nicecell=strrep(nicecell,'Mass','Massstr');
            nicecell=strrep(nicecell,'Result','Resultstr');
            nicecell=regexprep(nicecell,'Zero(\S*)','');
            nicecell=regexprep(nicecell,'-','''-''');
            nicecell=regexprep(nicecell,'=','=[');
            nicecell=regexprep(nicecell,'(','{');
            nicecell=regexprep(nicecell,')','}');
            for i=1:length(nicecell);nicecell{i}=[nicecell{i} ']'];end
            
            for i=dimlineno+1:length(nicecell);
                try
                    eval([nicecell{i} ';']);
                catch
                    keyboard
                end
            end
            nudata.results.str=Resultstr;
            %% record the data and time for pychron
            nicecell=nicecellorig;
            nicecell(cellfun(@isempty,nicecell))=[];
            nicecell=strrep(nicecell,'Mass','Data');
            nicecell=strrep(nicecell,'Result','Resultdata');
            nicecell=regexprep(nicecell,'Zero(\S*)','');
            nicecell=regexprep(nicecell,'-','');
            %nicecell=regexprep(nicecell,'=','=[');
            %nicecell=regexprep(nicecell,'(','{');
            %       nicecell=regexprep(nicecell,')','}');
            %   for i=1:length(nicecell);nicecell{i}=[nicecell{i} ']'];end
            
            for i=dimlineno+1:length(nicecell);
                
                eval([nicecell{i} ';']);
            end
            nudata.results.data=Resultdata;
            
            nicecell=strrep(nicecell,'Data','Datatime');
            for i=dimlineno+1:length(nicecell);
                
                eval([nicecell{i} ';']);
            end
            nudata.results.time=Resultdata;
            
            nicecell=strrep(nicecell,'Datatime','ZData');
            for i=dimlineno+1:length(nicecell);
                
                eval([nicecell{i} ';']);
            end
            nudata.results.zero=Resultdata;
            
            nicecell=strrep(nicecell,'ZData','ZDatatime');
            for i=dimlineno+1:length(nicecell);
                
                eval([nicecell{i} ';']);
            end
            nudata.results.zerotime=Resultdata;
            
            %%
            
            
            %     for namesi=1:length(nudata.results.names);
            %         eval(['nudata.results.value(namesi)= ' nudata.results.names{namesi} ';']);
            %     end
            
            % label the plot
            
            
            
            labelstrings=strcat( nudata.results.names', ' = ', cellstr(num2str(nudata.results.value(:),'%10.1f')));
            delete(findobj(outputfig,'tag','txResults'))
            figpos=get(outputfig,'position');
            txpos=[1 figpos(4)-size(labelstrings,1)*3-10 16 size(labelstrings,1)*3];
            txResults=uicontrol('style','text','units','characters','horizontalalignment','left',...
                'position',txpos,'string',labelstrings,'tag','txResults',...
                'backgroundcolor','w');
            set(txResults,'units','normalized');
        else
            addmessage('Warning: Could not find NICE file')
        end
        output=nudata.results;
    end

    function filesep=getfilesep
        if ispc;    filesep='\';else  filesep='/';end % filesep for type of computator
    end

    function status=addmessage(message)
        
        pmhdl=findobj('tag','lbProcessMessages');
        messages=get(pmhdl,'string');
        messages=[messages;message];
        set(pmhdl,'string',messages,'value',length(messages))
        status=1;
        
    end

    function fitgetdata(hObject,eventdata)%% callback
        
        xdata=get(hObject,'xdata');
        ydata=get(hObject,'ydata');
    end

    function out=linregress(x,y) % find the linear fit coefficents that best fit x to y.  y=a+bx;
        %adapted directly from "Numerical Recipes in C: The Art of Scientific
        %Computing" Chapter 15.2 (case where individual measurement errors are not
        %known)
        
        n=length(x);
        sx=sum(x);
        sy=sum(y);
        
        t=(x-sx/n);
        stt=sum(t.^2);
        b=(1/stt)*sum(t.*y);
        a=(sy-sx*b)/n;
        
        chisquare=sum((y-a-b*x).^2);
        correct=sqrt(chisquare/(n-2));
        asigma=sqrt((1+(sx.^2)/(n*stt))/n)*correct;
        bsigma=sqrt(1/stt)*correct;
        
        out.fit=[a b];out.sigma=[asigma bsigma];
    end

    function [x y]=trimdata(x,y,timetoexclude);
        reject=x<timetoexclude;
        x=x(~reject);y=y(~reject);
    end

    function [x y]=cropdata(x,y,croplimits);
        croplimits=sort(croplimits);
        reject=x<min(croplimits) | x>max(croplimits);
        x=x(~reject);y=y(~reject);
    end

    function y=cleanmean(y,sigma);
        meany=mean(y);
        stdy=std(y);
        rejects=abs(y-meany)>sigma*stdy;
        y=y(~rejects);
    end


    function [x y]=cleandata(x,y,sigma) % remove data points outside of t sigma from the original mean
        
        out=linregress(x,y);
        fit=out.fit(1)+x*out.fit(2);
        res=(y-fit);
        stdev=rlinstd(res);  %XXXX NOTE RLINSTD is not std
        rejects=abs(res)>sigma*stdev;
        x=x(~rejects);y=y(~rejects);
    end

    function out=expfitnew(time,data)
        endmean=(mean(data(end-10:end))-mean(data(1:10)));
        [fitresult g]=fit(time,data,'a+b*exp(-x/c)','StartPoint',[mean(data(1:10))  -10000 sign(endmean)*1000000]);
        out.fit=[fitresult.a fitresult.b fitresult.c];
        out.sigma=g.sse;
        out.fit=fitresult;
    end

    function out=expfit(time,data)
        iterations=0;
        options=optimset('MaxIter',100000,'MaxFunEvals',1000);
        endmean=(mean(data(end-10:end))-mean(data(1:10)));
        x0=[mean(data(1:10))  -10000 sign(endmean)*1000000];
        iterhandle=plot(time,expfun(x0,time));
        
        [fit resnorm residual] =lsqcurvefit(@expfun,x0,time,data,[],[],options);
        delete(iterhandle)
        out.fit=fit;
        out.sigma=resnorm;
        
        
        function out = expfun(coefs,xdata)
            iterations=iterations+1;
            out=coefs(1)+coefs(2)*exp(-xdata/coefs(3));
            if mod(iterations,10)==9;
                set(iterhandle,'ydata',out);
                %            if ~options.lotsafiles;drawnow;end;
            end
        end
    end

    function out = expfun(coefs,xdata)
        
        out=coefs(1)+coefs(2)*exp(-xdata/coefs(3));
        
    end

    function puFitCallback(hObject,eventdata)
        outputfig=get(hObject,'parent');
        nufitall(outputfig);
    end

    function PlotButtonDownFcn(hObject,eventdata)
        data=get(hObject,'userdata');
        dad=get(hObject,'parent');
        if strcmp(get(dad,'SelectionType'),'alt');
            delete(hObject);
            nufitone(dad,data);
        end
    end

    function tbZoomCallback(hObject,eventdata)
        dad=get(hObject,'parent');
        kids=findobj(dad.Children,'type','Axes');
        uds=get(kids,'userdata');
        for i=1:length(kids);
            if hObject.Value
                axis(kids(i),uds{i}{5}.ax1);
            else
                axis(kids(i),uds{i}{5}.ax2);
            end
        end
        
        
    end

    function tbZoomBaselinesCallback(hObject,eventdata)
        dad=get(hObject,'parent');
        kids=findobj(dad.Children,'type','Axes');
        uds=get(kids,'userdata');
        for i=1:length(kids);
            if hObject.Value
                axis(kids(i),uds{i}{5}.dx);
            else
                axis(kids(i),uds{i}{5}.ax2);
            end
        end
        
        
    end

    function puExcludeDataCallback(hObject,eventdata)
        outputfig=get(hObject,'parent');
        handles=guidata(outputfig);
        dbdata=handles.dbdata;
        
        s=[ ' UPDATE tblMSData SET tblMSData.MSExclude = 1 WHERE tblMSData.MSRunIdentifier = ''' dbdata.msrunidentifier ''' ; '];
        doquery(s);
        msgbox('Data marked for exclusion!')
        delete(outputfig);
    end


    function puCancelCallback(hObject,eventdata)
        outputfig=get(hObject,'parent');
        
        delete(outputfig);
    end

    function puCropDataCallback(hObject,eventdata)
        persistent crophandle
        
        switch hObject.Value
            case 1 % turn on the cropping
                hObject.String='Waiting...';
                outputfig=get(hObject,'parent');
                handles=guidata(outputfig);
                dbdata=handles.dbdata;
                nudata=handles.nudata;
                k = waitforbuttonpress;
                if k==0;
                    if ~isempty(crophandle);delete(crophandle);end
                    point1 = get(gca,'CurrentPoint');    % button down detected
                    finalRect = rbbox;                   % return figure units
                    point2 = get(gca,'CurrentPoint');    % button up detected
                    point1 = point1(1,1:2);              % extract x and y
                    point2 = point2(1,1:2);
                    p1 = sort([point1(1) point2(1)]);             % calculate locations
                    ax=axis;
                    if min(p1)>ax(1) & max(p1)<ax(2);
                        offset = abs(point1-point2);         % and dimensions
                        x = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
                        %  y = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
                        ax=axis;y=[ax(3) ax(3) ax(4) ax(4) ax(3)];
                        hold on
                        crophandle=plot(x,y,'k','linewidth',1);
                        ud.croplimits=x(1:2);
                        set(crophandle,'tag','croptag');
                        set(gcf,'userdata',ud);
                        hold off
                    end
                    hObject.String='UnCrop';
                end
                
            case 0 % turn off the cropping
                hObject.String='Crop Data';
                delete(crophandle);
                ud.croplimits=[];
                set(gcf,'userdata',ud);
        end
    end

    function writetopychron(dbdata,nudata)
        try
            % outputfig=get(hObject,'parent');
            % handles=guidata(outputfig);
            % dbdata=handles.dbdata;
            % nudata=handles.nudata;
            pyAnalysisTbl='AnalysisTbl';
            pyresultstbl='AnalysisIntensitiesTbl';
            %get analysisID
            s=['SELECT TOP 1 id FROM ' pyAnalysisTbl ' where uuid = ''' dbdata.runidentifier ''''];
            
            global qinfo
            qinfo.DB.DefaultDatabase='PYCHRON';
            
            res=doquery(s);
            if ~isempty(res)
                
                analysisID=res.id{:};
                
                s=['DELETE FROM ' pyresultstbl '  WHERE analysisID = ' num2str(analysisID) ';'];
                doquery(s);
                
                s=['INSERT INTO '  pyresultstbl ' ([analysisID],[isotope],[value],[error],[n]) SELECT ' num2str(analysisID) ' '];
                
                for i=1:length(nudata.results.names);
                    ps=[ s ', ''' nudata.results.names{i} ''', ' num2str(nudata.results.value(i)) ' , '  num2str(nudata.results.error(i)) ' , ' num2str(nudata.End_Integ) ';'];
                    
                    doquery(ps);
                    
                end
            else
                msgbox('No matching analysisID in pychronDB');
            end
            
        catch % fall through to changing the db back
        end
        qinfo.DB.DefaultDatabase='ARDATA';
    end

    function puSaveandExitCallback(hObject,eventdata)
        global qinfo
        outputfig=get(hObject,'parent');
        handles=guidata(outputfig);
        dbdata=handles.dbdata;
        nudata=handles.nudata;
        
        if handles.options.updatepychron
            writetopychron(dbdata,nudata);
            
            
            try
                writetogit(dbdata,nudata);
            catch ME
                disp(ME);disp(ME.stack(1));
                disp([' Can''t write to git ' dbdata.type ' ' dbdata.msrunidentifier]);
                msgbox(['Can''t write to Git! ' dbdata.msrunidentifier]);
                
            end
            
        end
        
        
        % delete existing data
        if handles.options.autosave;
            qinfo.DB.DefaultDatabase='ARDATA';
            
            s=['DELETE FROM tblFitResults WHERE FRRunIdentifier = ''' num2str(dbdata.msrunidentifier) ''';'];
            doquery(s);
            
            
            s=['INSERT INTO tblFitResults([FRRunIdentifier], [Detector], [Step], [Fit], [Error], [FitType], [ExclusionSigma] ) '];
            s=[ s ' SELECT ''' dbdata.msrunidentifier ''' ' ];
            
            count=0;
            for dsi=nudata.datasteps;dsi=dsi{:};
                
                for det={'ic0','ic1','ic2','ic3','fc'};det=det{:};
                    if isfield(nudata.(dsi),det)
                        %   [ nudata.(dsi).(det).result nudata.(dsi).(det).error]
                        
                        ps = [ s ',  ''' det ''', ''' dsi ''', ' num2str(nudata.(dsi).(det).result) ', '  num2str(nudata.(dsi).(det).error)  ', ''' nudata.(dsi).(det).fittype ''', ' num2str(nudata.(dsi).(det).excludesigma) ];
                        doquery(ps);
                        
                        count=count+1;
                        
                    end
                end
                
                
            end
            msgboxhandle=msgbox([num2str(count) ' Results written to database' ]);
            pause(2);
            delete(msgboxhandle);
            
            
            s=['DELETE FROM tblNiceResults WHERE NRRunIdentifier = ''' num2str(dbdata.msrunidentifier) ''';'];
            doquery(s);
            
            s=['INSERT INTO tblNiceResults ([NRRunIdentifier],[Species],[Result],[Error]) SELECT ''' dbdata.msrunidentifier ''' '];
            
            for i=1:length(nudata.results.names);
                ps=[ s ', ''' nudata.results.names{i} ''', ' num2str(nudata.results.value(i)) ' , '  num2str(nudata.results.error(i)) ';'];
                
                doquery(ps);
            end
            
            %unexclude
            s=[ ' UPDATE tblMSData SET tblMSData.MSExclude = 0 WHERE tblMSData.MSRunIdentifier = ''' dbdata.msrunidentifier ''' ; '];
            doquery(s);
        end
        delete(outputfig);
    end



    function out=rlinstd(in); %%PES NOTE: NOT STANDARD Z-SCORE FOR OUTLIER DETECTION
        in=in-mean(in);
        out=sqrt(sum(in.^2)/(length(in)-2));
    end
