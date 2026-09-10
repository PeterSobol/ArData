function setuistring(handle,str)

% set the string from a uicontrol regardless of type
if ~isstr(str);str=num2str(str);end
switch handle.Type
     case 'uicontrol'
        handle.String=str;
        return
    case 'uieditfield'
        handle.Value=str;
        return
    case 'uibutton'
        handle.Text=str;
        return
    case 'uidropdown'
        handle.Value=str;
        return
     case 'uieditfield'
        handle.Value=str;
        return  
          case 'uilabel'
        handle.Text=str;
        return 
     case 'uilistbox'
        handle.Value=str;
        return  
    case 'uinumericeditfield'
        handle.Value=str2num(str);
        return  
          
    otherwise
        
        str = handle.String;
end