s=['select hasnice, * from temptable Inner Join hasniceresults on temptable.MSRunIdentifier = hasniceresults.MSRunIdentifier '];
s=[s  ' WHERE (temptable.ID_MSData between 26989 and 27936) AND (temptable.MSTimeIn between ''6/1/2011 11:43:33 AM'' and ''9/10/2015 9:15:30 AM'') '];
s=[s  ' AND (temptable.MSAcqTime between ''8/27/2015 12:08:29 AM'' and ''9/10/2015 9:15:30 AM'') '];
%AND (temptable.ID_MSAnalysis between 0 and 31339) '];
%s=[s  ' AND (temptable.LaserPower between 0 and 40) AND (temptable.ExtractionStart between ''6/1/2011 11:43:33 AM'' and ''9/10/2015 8:56:20 AM'') ']; 
%s=[s  'AND (temptable.MSInOpen between ''12/31/1903 6:00:00 PM'' and ''12/31/1903 6:00:00 PM'') ORDER BY temptable.MSAcqTime '];

res=doquery(s);

