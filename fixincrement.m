 %list= {'UW144:AS1','UW144:AS7','UW144:AS9','UW146:AS1','UW146:AS3','UW146:AS7','UW146:AS9','UW146:BS1','UW146:BS3','UW146:BS7','UW146:BS9','UW146:A3','UW146:A4' }
   

for i=1:length(list)
 qinfo.DB.DefaultDatabase='ARDATA';
 
s=['select * from tblToPychron where identifier like ''' list{i} ''''];
s=[s  ' order by topychronid'];
res=doquery(s)


for j=1:size(res.topychronid);
     qinfo.DB.DefaultDatabase='ARDATA';
   s= ['  UPDATE tblToPychron SET  Aliquot = ' num2str(j) ' , Increment = 0, '];
   s= [s ' CompleteIdentifier = ''' res.identifier{j} '-' num2str(j) 'A'' where runidentifier like ''' res.runidentifier{j} '''']
   
doquery(s);

 qinfo.DB.DefaultDatabase='PYCHRON';
 s=[' UPDATE Analysistbl set aliquot = ' num2str(j) ' , Increment = 0 where uuid like ''' res.runidentifier{j} '''']
doquery(s);
end
end

 qinfo.DB.DefaultDatabase='PYCHRON';