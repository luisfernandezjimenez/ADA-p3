-- Work carried out by Luis Fernández Jiménez

package body Maps_G is
    
    procedure Get (M      : in Map;
                   Key    : in Key_Type;
                   Value  : out Value_Type;
                   Success: out Boolean) is

        Count: Natural := 1;
                   
    begin
        
        Success := False;
        
        while not Success and Count <= Max Loop
            
            if M.P_Array(Count).Key = Key then
                
                Value   := M.P_Array(Count).Value;
                Success := True;
            
            end if;
            
            Count := Count + 1;
        
        end loop;
        
    end Get;
    
    procedure Put (M    : in out Map;
                   Key  : in Key_Type;
                   Value: in Value_Type) is

	    Count: Natural := 1;
	    Found: Boolean := False;
	    
    begin
        
        while not Found and Count <= Max loop
		    -- Actualizacion del Last_Connection del Cliente
		    if M.P_Array(Count).Key = Key then
			
			    M.P_Array(Count).Value := Value;
			    Found                  := True;
		    
		    end if;
		    
		    Count := Count + 1;
	    
	    end loop;
	    
	    Count := 1;
	    
	    if not Found then
	        -- Añadir Cliente
            if M.Length = Max then
			
			    raise Full_Map;
            
            end if;
            
            while not Found and Count <= Max loop
                
                if not M.P_Array(Count).Full then
                
                    M.P_Array(Count) := (Key, Value, True);
                    M.Length         := M.Length + 1;
                    Found            := True;
                    
                end if;
                
                Count := Count + 1;
                
            end loop;
            
        end if;
        
    end Put;

    procedure Delete (M      : in out Map;
                      Key    : in Key_Type;
                      Success: out Boolean) is

    Count: Natural := 1;
                   
    begin
        
        Success := False;
        
        while not Success and Count <= Max Loop
                
            if M.P_Array(Count).Key = Key then
                -- Indicamos que dicho registro esta vacio para poder rellenarlo
                M.P_Array(Count).Full := False;
                M.Length := M.Length - 1;
                Success  := True;
                
            end if;
            
            Count := Count + 1;
        
        end loop;
    
    end Delete;
    
    function Map_Length (M: in Map) return Natural is
	
	begin
	
    	return M.Length;	
	
	end Map_Length;
    
    function First (M: in Map) return Cursor is
    
    begin
    
        return (M, 1);
    
    end First;
    
    procedure Next (C: in out Cursor) is
    
    begin
    
        C.Element_A := C.Element_A + 1;
        
    end Next;

    function Has_Element (C: in Cursor) return Boolean is
    
    begin
    
   	    return C.M.P_Array(C.Element_A).Full;
        
    end Has_Element;
    
    function Element (C: in Cursor) return Element_Type is
        
    begin
        
        if not Has_Element(C) then
            
            raise No_Element;
        
        end if;
        
        return (C.M.P_Array(C.Element_A).Key, C.M.P_Array(C.Element_A).Value);
    
    end Element;
    
end Maps_G;
