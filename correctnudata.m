function out=correctnudata(dbdata);
colors='rgbkymcrgbkymc';
symbols='o^svd<>';
out=[];
zoomlistenerhandle=[];
correctfig=figure;
set(correctfig,'toolbar','figure','units','normalized','position',[   0.0135    0.18    0.5604    0.7542]);
correctax=axes('parent',correctfig','position',[ 0.0500    0.200    0.750    0.75]);

%tblMSData=get(findobj('tag','edMSDataTable'),'string');tblPrepData= get(findobj('tag','edPrepDataTable'),'string');
%tblNiceResults=get(findobj('tag','edNiceResultsTable'),'string');

species={};

for i=1:length(dbdata);
    s=['select * from tblNiceResults where NRRunIdentifier = ''' dbdata(i).msrunidentifier ''''];
    dbdata(i).res=doquery(s);
    species=vertcat(species,  dbdata(i).res.species{:});
end

specieslist=unique(species);

%put Ar39b at the end
Ar39bindex=strcmp(specieslist,'Ar39b');
if any(Ar39bindex) & Ar39bindex ~= length(specieslist);
    Ar39bindex=find(Ar39bindex);
    index=[1:Ar39bindex-1 Ar39bindex+1:length(specieslist) Ar39bindex];
    specieslist=specieslist(index);
end


% for i=1:length(dbdata)
%     for j=1:length(species);
%         index=find(strcmp(dbdata(i).res.species,species(j)));
%         if ~isempty(index)
%             result.(species{j}).(dbdatfit(i)=dbdata(i).res.result{index};
%              result.(species{j}).error(i)=dbdata(i).res.error{index};
%
%
%  %       dbdata(i).res.(species{j}).value= dbdata(i).res.result{index};
%  %       dbdata(i).res.(species{j}).error= dbdata(i).res.error{index};
%         end
%     end
%     end
plothandles=[];
types=cellfun(@(x)[upper(x(1)) lower(x(2:end))],{dbdata(:).type},'uniformoutput',false);
typeslist= unique(types);
legendlist={};

for s=1:length(specieslist);
    symbol=symbols(s);
    
    for t=1:length(typeslist);
        color=colors(t);
        dataindex=0;
        for d=1:length(dbdata)
            if strcmp(dbdata(d).type,typeslist{t});
                legendlist=vertcat(legendlist,strcat(specieslist{s},'-',typeslist{t}));
                
                index=find(strcmp(dbdata(d).res.species,specieslist{s}));
                
    
                if ~isempty(index)
                                dataindex=dataindex+1;
                try
                speciesname=strrep(specieslist{s},'/','d');
                data.(typeslist{t}).(speciesname).res.result(dataindex)=dbdata(d).res.result{index};
                data.(typeslist{t}).(speciesname).res.error(dataindex)=dbdata(d).res.error{index};
                data.(typeslist{t}).(speciesname).time(dataindex)=datenum(dbdata(d).msacqtime)-734655;
                data.(typeslist{t}).(speciesname).color=color;
                data.(typeslist{t}).(speciesname).symbol=symbol;
                data.(typeslist{t}).(speciesname).xlabel{dataindex}=dbdata(d).mssamplestring;
                data.(typeslist{t}).(speciesname).dbdataindex{dataindex}=d;
                data.(typeslist{t}).(speciesname).mask(dataindex)=true;
                data.(typeslist{t}).(speciesname).resdeblanked.res=[];
                catch
                    keyboard
                end
                end
                %         if ~isempty(index)
                %
                %                 ploth=plot(datenum(dbdata(d).msacqtime),dbdata(d).res.result{index},'color',color,'marker',symbol);
                %                 plothandles=[plothandles ploth];
                %                 hold on
                %                 error=dbdata(d).res.error{index};
                %                 if error>0
                %                     errorbarhandle=errorbar(datenum(dbdata(d).msacqtime),dbdata(d).res.result{index},error,color );
                %
                %                     errorbar_tick(errorbarhandle,.01,'units');
                %                end
            end
        end
    end
    
end

% do the axis labels.
% [legendlist legindex]=unique(legendlist);
% legendh=legend(plothandles(legindex),legendlist);
% legendpos=get(legendh,'position');
% set(legendh,'position',[0.8367 legendpos(2:4)]);
% axdata.xticklabels={dbdata.mssamplestring};
% axdata.xticks=datenum({dbdata.msacqtime});
% [axdata.xticks sortindex]=sort(axdata.xticks);
% axdata.xticklabels=axdata.xticklabels(sortindex);
% axdata.tickhdls=xticklabel_rotate(axdata.xticks,90,axdata.xticklabels);
%
% set(correctax,'userdata',axdata);
% %zoomlistenerhandle=addlistener(correctax,'YLim','PostSet',@(src,evt)zoomcallback(src,evt));
%
% hold off

%build the GUI
for i=1:length(typeslist);
    displayplothandle(i)=uicontrol('parent',correctfig,'style','togglebutton','units','normalized','position',[.65+i*.0601 .95 .06 .04],...
        'string',typeslist(i),'callback',@displayplot,'userdata',{'type' typeslist{i}},'value',1,'backgroundcolor',colors(i));
    newcolor=get(displayplothandle(i),'backgroundcolor');
    newcolor=max(newcolor,[.7 .7 .7]);
    set(displayplothandle(i),'backgroundcolor',newcolor);
end
fittypes={'linear','quadratic','cubic'};

%denominatorgrouphdl=uibuttongroup('parent',correctfig,'units','normalized','position',[.866 .812-length(specieslist)*.045 .04 length(specieslist)*.051]);
denominatorgrouphdl=uibuttongroup('parent',correctfig,'units','normalized','position',[.85+.07+.001 .2 .02 .72]);
speciesgrouphdl=uipanel('parent',correctfig,'units','normalized','position',[.85 .2 .07 .72]);
for j=1:length(specieslist);
    displayplothandle(i+j)=uicontrol('parent',speciesgrouphdl,'style','togglebutton','units','normalized','position',[.02 1-.005-j*.081 .96 .08],...
        'string', [specieslist{j} ' ' symbols(j)],'callback',@displayplot,'userdata',{'species' specieslist{j}},'value',1,'backgroundcolor',[.8 .8 .8]);
    %     fittypehandle(i+j)=uicontrol('parent',correctfig,'style','popupmenu','units','normalized','position',[.87 .865-j*.061 .06 .02],...
    %         'string',fittypes,'callback',@fitchange,'userdata',{'species' species{j}},'value',1);
    
    denominatorhandle(j) = uicontrol('Style','Radio','units','normalized',...
        'tag',specieslist{j},'pos',[.05 1-.01-j*.081 .8 .08],'parent',denominatorgrouphdl,'visible','on',...
        'callback',@denombuttoncallback);
    
end
% Initialize some button group properties.
set(denominatorgrouphdl,'SelectionChangeFcn',@selcbk);
set(denominatorgrouphdl,'SelectedObject',[]);  % No selection


uicontrol('parent',correctfig,'style','text','units','normalized','position',[.1 .1 .1 .04],...
    'string','Blank Correction','backgroundcolor',[.8 .8 .8]);
subtractblankhdl=uicontrol('parent',correctfig,'style','popupmenu','units','normalized','position',[.1 .07 .1 .04],...
    'string',{'None','Linear','Nearest Neigbhor'},'callback',@subtractblank,'value',1,'backgroundcolor',[.8 .8 .8]);

outputhandle=uicontrol('parent',correctfig,'style','pushbutton','units','normalized','position',[.8 .1 .1 .04],...
    'string','Output Data','backgroundcolor',[.8 .8 .8],'callback',@outputdata);

displayplot([],[]);

%%
%     function switchcallback(src,event);
%         % basically wait a second for additional buttons to be pressed so
%         % that you don't have to update the display multiple times.
%         persistent buttontime
%         
%         buttontime=now();
%         
%         
%     end
%%
    function displayplot(src,event);
  
        if  ishandle(zoomlistenerhandle);delete(zoomlistenerhandle);end
        if get(subtractblankhdl,'value')>1 ;ystring='resdeblanked';else;ystring='res';end
        userdata=get(displayplothandle,'userdata'); % cellarray of types
        strings=get(displayplothandle,{'string'});  % cellarray of button labels;
        selected=get(displayplothandle,{'value'});   % cell array of button status;
        
        denom=cell2mat(get(denominatorhandle,{'value'}));
        if any(denom) % divide by indicated denominator
            denomname=get(denominatorhandle(find(denom)),'tag');
            
        end
        
        
        userdata=userdata(logical([selected{:}]));
        types={};species={};
        for i=1:length(userdata);
            if strcmp(userdata{i}(1),'type')
                types=[types userdata{i}(2)];
            else
                species=[species userdata{i}(2)];
            end
        end
        hold off
        cla
        
        xticklabels={};xticks=[];
        for ti=1:length(types)
            
            if any(denom);
                denomdata=[data.(types{ti}).(denomname).(ystring).result];
            else
                denomdata=ones(size(data.(types{ti}).(strrep(species{1},'/','d')).time));
            end
            
            for s=1:length(species)
                speciesname=strrep(species{s},'/','d');
                cs=[data.(types{ti}).(speciesname).color data.(types{ti}).(speciesname).symbol]; % get the color and symbol
                % disp([types{ti} speciesname ystring])
                
                mask=data.(types{ti}).(speciesname).mask;
                
                %% if there no fit, then make it
                if isfield(data.(types{ti}).(speciesname).(ystring),'fit') && ~isempty( data.(types{ti}).(speciesname).(ystring).fit);
                else
                    if ~isfield(data.(types{ti}).(speciesname).(ystring),'fit')
                        if isfield(data.(types{ti}).(speciesname).res,'fit');fittype=data.(types{ti}).(speciesname).res.fit.fittype;else;fittype='linear';end
                    else;fittype='linear';end
                    data.(types{ti}).(speciesname).(ystring).fit=makefit(data.(types{ti}).(speciesname).time(mask),data.(types{ti}).(speciesname).(ystring).result(mask),fittype);
                    data.(types{ti}).(speciesname).(ystring).fit.type=types{ti};data.(types{ti}).(speciesname).(ystring).fit.species=speciesname;
                end
                %%
                if ~any(denom)
                    errorbarhandle=errorbar(data.(types{ti}).(speciesname).time,data.(types{ti}).(speciesname).(ystring).result,data.(types{ti}).(speciesname).(ystring).error,cs );
                    errorbar_tick(errorbarhandle,.01,'units');
                    
                    if ~any(isnan(data.(types{ti}).(speciesname).(ystring).fit.fit)); % don't plot if the fit has NaNs (no fit)
                    plotfit(data.(types{ti}).(speciesname).(ystring).fit,data.(types{ti}).(speciesname).color,correctax);
                    end
                    hold on;
                end
                
                
                %plot the results;
                
                plot(data.(types{ti}).(speciesname).time(mask),data.(types{ti}).(speciesname).(ystring).result(mask)./denomdata(mask),'linestyle','none','marker',cs(2),'markerfacecolor',cs(1),...
                    'buttondownfcn',@plotcallback,'userdata',data.(types{ti}).(speciesname).(ystring).fit);
                hold on;
                if ~all(mask);
                    plot(data.(types{ti}).(speciesname).time(~mask),data.(types{ti}).(speciesname).(ystring).result(~mask)./denomdata(~mask),'linestyle','none','marker',cs(2),'markerfacecolor',[.1 .1 .1],...
                        'buttondownfcn',@plotcallback,'userdata',data.(types{ti}).(speciesname).(ystring).fit);
                end
                
            end
            xticklabels=[xticklabels data.(types{ti}).(speciesname).xlabel];
            xticks=[xticks data.(types{ti}).(speciesname).time];
        end
        
        if ~isempty(xticks)
            
            [axdata.xticks sortindex]=sort(xticks);
            axdata.xticklabels=xticklabels(sortindex);
            set(correctax,'xtick',axdata.xticks,'xticklabel',axdata.xticklabels);
            set(correctax,'position',[ 0.0500    0.200    0.7750    0.73]);
             axdata.tickhdls=xticklabel_rotate(axdata.xticks,90,axdata.xticklabels);
            set(axdata.tickhdls,'fontsize',8);
            set(correctax,'userdata',axdata);
        end
        zoomlistenerhandle=addlistener(correctax,'YLim','PostSet',@(src,evt)zoomcallback(src,evt));
        
    end



    function zoomcallback(src,event)
        ax=event.AffectedObject;
        axdata=get(ax,'userdata');
        xlim=get(ax,'xlim');
        
        set(axdata.tickhdls,'units','data');
        ylim=get(ax,'ylim');
        y=ylim(1)-(ylim(2)-ylim(1))*.02;
        for i=1:length(axdata.tickhdls);
            %   pos=get(texthdls(i),'position');
            %      extent=get(texthdls(i),'extent');
            set(axdata.tickhdls(i),'position',[axdata.xticks(i) y 0]);
            if axdata.xticks(i)<xlim(1) || axdata.xticks(i)>xlim(2);
                set(axdata.tickhdls(i),'visible','off');
            else
                set(axdata.tickhdls(i),'visible','on');
            end
        end
    end


    function plotfit(fitdata,color,axhandle);
        ax=axis(axhandle);
        switch fitdata.fittype
            case 'linear'
                lim=fitdata.lim;
                 
                
                x=linspace(lim(1),lim(2),5);
            
                [y  DELTA]=polyconf(fitdata.fit,x,fitdata.S,'predopt','obs','alpha',.05);
                % plot(x,y-DELTA,color);
                % plot(x,y+DELTA,color);
                hold on
                ph=patch([x x(end:-1:1)],[y-DELTA y(end:-1:1)+DELTA(end:-1:1)],color,'facealpha',.1,'edgecolor',color);
                
                ph=plot(lim, fitdata.fit(2)+lim*fitdata.fit(1),color,'linestyle','--','linewidth',3);
                set(ph,'userdata',fitdata,'buttondownfcn',@fitclick);
                hold off
                
            case 'quadratic'
                lim=fitdata.lim;
                x=linspace(lim(1),lim(2),20);
                [y DELTA]=polyconf(fitdata.fit,x,fitdata.S,'predopt','obs','alpha',.05);
                hold on
                ph=patch([x x(end:-1:1)],[y-DELTA y(end:-1:1)+DELTA(end:-1:1)],color,'facealpha',.1,'edgecolor',color);
                
                ph=plot(x,polyval(fitdata.fit,x),color,'linestyle',':','linewidth',3);
                set(ph,'userdata',fitdata,'buttondownfcn',@fitclick);
            case 'cubic'
                lim=fitdata.lim;
                x=linspace(lim(1),lim(2),20);
                [y DELTA]=polyconf(fitdata.fit,x,fitdata.S,'predopt','obs','alpha',.05);
                hold on
                ph=patch([x x(end:-1:1)],[y-DELTA y(end:-1:1)+DELTA(end:-1:1)],color,'facealpha',.1,'edgecolor',color);
                
                ph=plot(x,polyval(fitdata.fit,x),color,'linestyle','-.','linewidth',3);
                set(ph,'userdata',fitdata,'buttondownfcn',@fitclick);
                
        end
    end

    function fitout=makefit(x,y,fittype);
        switch fittype;
            case 'linear';
                fitout=linregress(x,y);
                fitout.fittype='linear';
                
            case 'quadratic'
                fitout=quadfit(x,y);
                fitout.fittype='quadratic';
            case 'cubic'
                fitout=cubicfit(x,y);
                fitout.fittype='cubic';
                
        end
        
    end



    function fitclick(src,event);
        
        switch get(gcf,'selectiontype')
            case 'normal'
            case 'alt' % right mouse click
                fitdata=get(src,'userdata');
                here=get(gcf,'currentpoint');
                uihandle=uicontrol('style','popupmenu','string',{'linear' 'quadratic' 'cubic'},'units','normalized','position',[here .07 .02],'userdata',fitdata,'callback',@fitselectcallback);
                
        end
    end

    function fitselectcallback(src,event);
        fitdata=get(src,'userdata');
        strings=get(src,'string');
        selection=strings{get(src,'value')};
        delete(src)
        if get(subtractblankhdl,'value');ystring='resdeblanked';else;ystring='res';end
        data.(fitdata.type).(fitdata.species).(ystring).fit.fittype=selection;
        data.(fitdata.type).(fitdata.species).(ystring).fit=makefit(data.(fitdata.type).(fitdata.species).time(data.(fitdata.type).(fitdata.species).mask), ...
            data.(fitdata.type).(fitdata.species).(ystring).result(data.(fitdata.type).(fitdata.species).mask),selection);
        data.(fitdata.type).(fitdata.species).(ystring).fit.type=fitdata.type;data.(fitdata.type).(fitdata.species).(ystring).fit.species=fitdata.species;
        displayplot([],[]);
    end

    function plotcallback(src,event);
        switch get(gcf,'selectiontype');
            case 'normal'
                if get(subtractblankhdl,'value');ystring='resdeblanked';else;ystring='res';end
                fitdata=get(src,'userdata');
                here=get(gca,'currentpoint');
                xp=here(1);yp=here(1,2);
                [ minx index]=min(abs(xp-data.(fitdata.type).(fitdata.species).time));
                index=index(1);
                mask=data.(fitdata.type).(fitdata.species).mask;
                mask(index)=~mask(index);
                if sum(mask)>1;
                    data.(fitdata.type).(fitdata.species).mask=mask;
                    data.(fitdata.type).(fitdata.species).(ystring).fit=...
                        makefit(data.(fitdata.type).(fitdata.species).time(mask),data.(fitdata.type).(fitdata.species).(ystring).result(mask),data.(fitdata.type).(fitdata.species).(ystring).fit.fittype);
                    data.(fitdata.type).(fitdata.species).(ystring).fit.type=fitdata.type;data.(fitdata.type).(fitdata.species).(ystring).fit.species=fitdata.species;
                    
                    displayplot([],[]);
                end
            case 'alt'
                fitdata=get(src,'userdata');
                % pick out which datapoint
                  here=get(gca,'currentpoint');
                xp=here(1);yp=here(1,2);
                [ minx index]=min(abs(xp-data.(fitdata.type).(fitdata.species).time));
                index=index(1);
               % dbdata(data.(fitdata.type).(fitdata.species).dbdataindex{index})
               sc=struct2cell(dbdata(data.(fitdata.type).(fitdata.species).dbdataindex{index}));
               svcat=[];dis=fieldnames(dbdata);
               for i=1:length(sc);
                   if isstruct(sc{i}) || isempty(sc{i});
                      
                   else
              
                      svcat=[svcat; {[dis{i} ':    ' char(32*ones(1,30-length(dis{i})))   num2str(sc{i})]}];
                          
                   end
               end
%                colons=regexp(svcat,':','once');colons=[colons{:}];
%                maxcolon=max(colons);
%                for i=1:length(svcat);
%                    svcat{i}=[char(ones(1,maxcolon-colons(i))*32) svcat{i}];
%                end
               
           
            newfig=dialog('windowstyle','normal','units','normalized');
            uicontrol('style','text','parent',newfig,'units','normalized','position',[.05 .05 .9 .9],...
                'horizontalalignment','left','string',svcat);
            
        end
    end
    function subtractblank(src,event)
        % subtract Blank data from data for each species/type combination.
        % errors are calculated from the polyconf evaluatio of the error at
        % each point
        
        options=get(src,'string');
        option=options{get(src,'value')};
        switch option
            case 'None'
                   for s=1:length(specieslist);
                    % subtract Blank
                    for ti=1:length(typeslist);
                        
                       
                        data.(typeslist{ti}).(specieslist{s}).resdeblanked.result= ...
                            data.(typeslist{ti}).(specieslist{s}).res.result;
                        data.(typeslist{ti}).(specieslist{s}).resdeblanked.error= data.(typeslist{ti}).(specieslist{s}).res.error;
                        
                        
                    end
                end
                
            case 'Linear'
                
                for s=1:length(specieslist);
                    % subtract Blank
                    for ti=1:length(typeslist);
                        
                        [y DELTA]=polyconf(data.Blank.(specieslist{s}).res.fit.fit,data.(typeslist{ti}).(specieslist{s}).time, ...
                            data.Blank.(specieslist{s}).res.fit.S,'predopt','obs','alpha',.05);
                        
                        data.(typeslist{ti}).(specieslist{s}).resdeblanked.result= ...
                            data.(typeslist{ti}).(specieslist{s}).res.result-y;
                        data.(typeslist{ti}).(specieslist{s}).resdeblanked.error= ...
                            sqrt(data.(typeslist{ti}).(specieslist{s}).res.error.^2 + DELTA.^2);
                        
                        
                    end
                end
                
            case 'Nearest Neigbhor'
                % uses the two nearest neighbor blanks for baseline correction.
                for s=1:length(specieslist);
                    % subtract Blank
                    for ti=1:length(typeslist);
                        datatimevec= data.(typeslist{ti}).(specieslist{s}).time;
                        blanktimevec=data.Blank.(specieslist{s}).time;
                        
                        for i=1:length(datatimevec);
                            findmat=abs(blanktimevec-datatimevec(i));
                            [ m minind]=min(findmat);findmat(minind)=inf;
                            [ m ind2]=min(findmat);
                            %calculate the result
                            data.(typeslist{ti}).(specieslist{s}).resdeblanked.result(i) = ...
                                data.(typeslist{ti}).(specieslist{s}).res.result(i)-mean(data.Blank.(specieslist{s}).res.result([minind ind2]));
                            % calculate the error
                            data.(typeslist{ti}).(specieslist{s}).resdeblanked.error(i) = ...
                                sqrt(data.(typeslist{ti}).(specieslist{s}).res.error(i).^2 + ...
                                ((sqrt(sum(  data.Blank.(specieslist{s}).res.error([minind ind2]).^2) ))/2).^2);
                            
                        end
                        
                        
                    end
                end
        end
        displayplot([],[]);
    end

    function selcbk(src,event) % radio button for denominator selection, selection change callback;

        if ~isempty(event.OldValue)
            set(denominatorgrouphdl,'SelectedObject',[]);
            displayplot(src,event);
        else
            displayplot(src,event);
        end
    end

    function outputdata(src,event);
        fieldlist={'msrunidentifier','msdatafile','msacqtime','msrunfile',...
            'msnumberofcycles','samplename','type','material','laserposition',...
            'laserdwell','laserpower'};
        colheader1={'Run Id','Data File' ,'Acq Time','Run File',...
            'Number of Cycles','Sample Name','Sample Type','Material',...
            'Laser Position','Laser Dwell','Laser Power'};
%         runidentifiercol=1;
%         msdatafilecol=2;
%         msacqtimecol=3;
%         msrunfilecol=4;
%         numberofcyclescol=5;
%         samplenamecol=6;       
%         typecol=7;
%         materialcol=8;
%         laserpositioncol=9;
%         laserdurationcol=10;
%         laserpowercol=11;
        fitresultcol=12;
        fiterrorcol=13;
        deblankedfitrescol=14;
        deblankedfiterrorcol=15;

        colheader2=colheader1;
        temp=repmat(1:length(specieslist),4,1);temp=temp(:)';
        colheader1=[colheader1 specieslist(temp)'];
        nospecies=size(specieslist,1);
        for i=1:nospecies;colheader2=[colheader2  {'Fit Result','Fit Error','Corrected Fit','Corrected Error'}];end
        
        output=cell(length(dbdata),12);
        for s=1:nospecies;
            % subtract Blank
            for ti=1:length(typeslist);
                for fi=1:length(fieldlist);
                                 output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],fi)=...
                    ({dbdata([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}]).(fieldlist{fi})});   
                    
                 end
%                 output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],runidentifiercol)=...
%                     ({dbdata([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}]).msrunidentifier});
%                 output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],msdatafilecol)=...
%                     ({dbdata([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}]).msdatafile});
%                 output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],msacqtimecol)=...
%                     ({dbdata([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}]).msacqtime});
%                 output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],msrunfilecol)=...
%                     ({dbdata([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}]).msrunfile});
%                 output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],numberofcyclescol)=...
%                     ({dbdata([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}]).msnumberofcycles});
%                 output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}], samplenamecol)=...
%                     ({dbdata([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}]).samplename});
%                 output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],typecol)=...
%                     ({dbdata([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}]).type});
%                 output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],materialcol)=...
%                     ({dbdata([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}]).material});
%                
%                                                 output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],laserpositioncol)=...
%                     ({dbdata([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}]).laserposition});
%                                                 output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],laserdurationcol)=...
%                     ({dbdata([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}]).laserduration});
%                                    output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],laserpowercol)=...
%                     ({dbdata([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}]).laserpower});

fitresultcol=length(fieldlist)+1;


                output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],fitresultcol+(s-1)*4)= ...
                    mat2cell(data.(typeslist{ti}).(specieslist{s}).res.result(:),ones(size(data.(typeslist{ti}).(specieslist{s}).res.result(:))));
                output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],fitresultcol+1+(s-1)*4)= ...
                    mat2cell(data.(typeslist{ti}).(specieslist{s}).res.error(:),ones(size(data.(typeslist{ti}).(specieslist{s}).res.error(:))));

                if isfield( data.(typeslist{ti}).(specieslist{s}).resdeblanked,'result') & ~isempty(   data.(typeslist{ti}).(specieslist{s}).resdeblanked.result);
                    
                    output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],fitresultcol+2+(s-1)*4)= ...
                        mat2cell(data.(typeslist{ti}).(specieslist{s}).resdeblanked.result(:),ones(size(data.(typeslist{ti}).(specieslist{s}).resdeblanked.result(:))));
                    output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],fitresultcol+3+(s-1)*4)= ...
                        mat2cell(data.(typeslist{ti}).(specieslist{s}).resdeblanked.error(:),ones(size(data.(typeslist{ti}).(specieslist{s}).resdeblanked.error(:))));
                else
                    output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],fitresultcol+2+(s-1)*4)={zeros(size([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}]'))};
                    output([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}],fitresultcol+3+(s-1)*4)={zeros(size([data.(typeslist{ti}).(specieslist{s}).dbdataindex{:}]'))};
                end
                
            end
        end
        
        
        status= writetoexcel([colheader1;colheader2;output]);
        
    end

end






function out=quadfit(x,y);
[out.fit,out.S]=polyfit(x,y,2);
out.lim=[min(x) max(x)];


end


function out=cubicfit(x,y);
[out.fit,out.S]=polyfit(x,y,3);
out.lim=[min(x) max(x)];


end


function out=linregress(x,y) % find the linear fit coefficents that best fit x to y.  y=a+bx;
%adapted directly from "Numerical Recipes" Chapter 15.2

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

% CONSTRUCT THE R MATRIX
pn=1;
V(:,pn+1) = ones(length(x),1,class(x));
for j = pn:-1:1
    V(:,j) = x(:).*V(:,j+1);
end

[Q,R] = qr(V,0);

out.S.normr=norm(y-(b*x+a));
out.S.df=n-2;
out.S.R=R;

out.fit=[b a];out.sigma=[bsigma asigma];
out.lim=[min(x) max(x)];

end


