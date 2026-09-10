fields={'ToPychronID','SampleID','Material','Type','Analyst','Irradiation','IrrId','Well','PlanchetteLoad','RunIdentifier','CompleteIdentifier','ProjectName','Identifier','Aliquot','Increment','IrradiationPositionID'}

for i=1:length(fields);
    temp=tp.(fields{i});temp2={};
    if isa(temp(1),'double');
        for j=1:length(temp);
        temp2=[temp2 num2str(temp(j))];
        end
    else 
        for j=1:length(temp)
        temp2=[temp2 temp(j)];
        end
    end
    
    res2.(fields{i})=temp2';
end
