function str=getuistring(handle)

% get the string from a uicontrol regardless of type

switch handle.Type
     case 'uicontrol'
         switch handle.Style
             case 'popupmenu'
                  strs=handle.String;
                   str=strs{handle.Value};
             otherwise
                  str=handle.String;
        return
         end

    case 'uieditfield'
        str=handle.Value;
        return
    case 'uibutton'
        str=handle.Text;
        return
    case 'uidropdown'
        str=handle.Value;
        return
     case 'uieditfield'
        str=handle.Value;
        return  
          case 'uilabel'
        str=handle.Text;
        return 
                  case 'uilistbox'
        str=handle.Value;
        return  
    case 'uinumericeditfield'
        str=num2str(handle.Value);
        return  
          
    otherwise
        
        str = handle.String;
end

