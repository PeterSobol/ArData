function CallArData(varargin)
ardatah=ArData; % start ArData or raise the current instance


if nargin>0 % called with data
    
   

    %called with a runidentifier
    

   ud.callarg=varargin{1};
   ardatah.UserData=ud;   
   ArData('pbPopulate_Callback',0,0,handles)
else
  
end