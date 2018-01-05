-- Work carried out by Luis Fernández Jiménez

package body Maps_G is
    
    procedure Free is new 
    
        Ada.Unchecked_Deallocation (Cell, Cell_A);
    
    procedure Get (M      : in Map;
                   Key    : in Key_Type;
                   Value  : out Value_Type;
                   Success: out Boolean) is

        P_Aux: Cell_A := M.P_First;
                   
    begin
        
        Success := False;
        
        while not Success and P_Aux /= null Loop
            
            if P_Aux.all.Key = Key then
                
                Value   := P_Aux.all.Value;
                Success := True;
            
            end if;
            
            P_Aux := P_Aux.all.Next;
        
        end loop;
        
    end Get;
    
    procedure Put (M    : in out Map;
                   Key  : in Key_Type;
                   Value: in Value_Type) is
                   
	    P_Aux: Cell_A;
	    P_Act: Cell_A  := M.P_First;
	    Found: Boolean := False;
	    
    begin     
        
        while not Found and P_Act /= Null loop
		    -- Actualizacion del Last_Connection del Cliente
		    if P_Act.Key = Key then
			
			    P_Act.all.Value := Value;
			    Found := True;
		    
		    end if;
		    
		    P_Act := P_Act.all.Next;
	    
	    end loop;
	    
	    if not Found then
	        -- Añadir Cliente
            if M.Length = Max then
			
			    raise Full_Map;
            
            end if;
            
	        P_Aux     := new Cell' (Key, Value, M.P_First);
	        M.P_First := P_Aux;
            M.Length  := M.Length + 1;
        
        end if;
	    
    end Put;

    procedure Delete (M      : in out Map;
                      Key    : in Key_Type;
                      Success: out Boolean) is

    P_Aux     : Cell_A;
    P_Aux_Next: Cell_A;
                   
    begin
        
        Success    := False;
        P_Aux      := M.P_First;
        P_Aux_Next := M.P_First.all.Next;
        
        if P_Aux.all.Key = Key then
        -- Eliminar primer elemento del Mapa
            M.P_First := P_Aux_Next;
            Free(P_Aux);
            M.Length := M.Length - 1;
            Success  := True;
            
        else
        
            while not Success and P_Aux /= null Loop
                    
                if P_Aux_Next.all.Key = Key then
                    
                    P_Aux.all.Next := P_Aux_Next.all.Next;
                    Free(P_Aux_Next);
                    M.Length := M.Length - 1;
                    Success  := True;
                    
                elsif P_Aux.all.Next /= Null then
                    
                    P_Aux      := P_Aux.all.Next;
                    P_Aux_Next := P_Aux_Next.all.Next;
                    
                end if;
            
            end loop;
        
        end if;
    
    end Delete;
    
    function Map_Length (M: in Map) return Natural is
	
	begin
	
    	return M.Length;	
	
	end Map_Length;
    
    function First (M: in Map) return Cursor is
    
    begin
    
        return (M, M.P_First);
    
    end First;
    
    procedure Next (C: in out Cursor) is
    
    begin
    
        C.Element_A := C.Element_A.all.Next;
        
    end Next;

    function Has_Element (C: in Cursor) return Boolean is
    
    begin
    
   	    return C.Element_A /= Null;
        
    end Has_Element;
    
    function Element (C: in Cursor) return Element_Type is
        
    begin
        
        if not Has_Element(C) then
        
            raise No_Element;
            
        end if;
        
        return (C.Element_A.all.Key, C.Element_A.all.Value);
    
    end Element;
    
end Maps_G;
