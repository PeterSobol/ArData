
function out=makeblob(timevec,datavec)  

d=single(datavec);
   d=typecast(d,'uint8'); 
   d=reshape(d,4,length(d)/4);d=d';
   d=d(:,end:-1:1);%big endian
   
     t=single(timevec);
   t=typecast(t,'uint8'); 
   t=reshape(t,4,length(t)/4);t=t';
     t=t(:,end:-1:1);%big endian
     t=[t d]';
     out=matlab.net.base64encode(t(:));