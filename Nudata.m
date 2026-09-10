filepath='\\Ng022\nu noble ng22\Results\';

direc=dir([filepath 'Data_22*.RUN']);
%%
for i=length(direc)-100:length(direc)
    
     
     if ~isempty(nudata.Number_Of_Cycles);
    
    %%  fit the data
   
    e=[ones(size(nudata.datatype)) nudata.datatime];
    clf
    for index=0:3;
        icstring=['ic' num2str(index)];
        if isfield(nudata,([icstring 'dark']))
            
    c=e\nudata.([icstring 'data']);output.(icstring)(i)=c(1); output.([icstring '_slope'])(i)=c(2);
    title(nudata.Sample_Name)
    subplot(2,2,index+1)
    plot(nudata.datatime,[nudata.([icstring 'data']) c(1)+nudata.datatime*c(2)]); drawnow
    xlabel([icstring])

%     c=e\nudata.ic1data;output.ic1(i)=c(1);output.ic1_slope(i)=c(2);;
%     c=e\nudata.ic2data;output.ic2(i)=c(1);output.ic2_slope(i)=c(2);
%     c=e\nudata.ic3data;output.ic3(i)=c(1);output.ic3_slope(i)=c(2);
    
        end 
    end

     end
     pause
end   %%
    





