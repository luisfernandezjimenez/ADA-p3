-- Work carried out by Luis Fernández Jiménez

package body Map_Treatment is
    
    function Check_Nick (Nick       : in ASU.Unbounded_String;
                         EP         : in LLU.End_Point_Type;
                         Mess_Init  : in Boolean) return Boolean is
        
        Get_Value: Values;
        Found    : Boolean := False;
        C_Active : A_Maps.Cursor := A_Maps.First(My_Active_Map);
    
    begin
        -- Compruebar si esta en la lista de Clientes Activos
        A_Maps.Get(My_Active_Map, Nick, Get_Value, Found);
        
        if (Nick = "server") or else (not Mess_Init and Found and EP = Get_Value.EP) 
            or else (Mess_Init and Found) then
            
            Found := True;
        
        else
            
            Found := False;
        
        end if;
        
        return Found;

    end Check_Nick;
    
    procedure Inactive_Client (Nick_Del : out ASU.Unbounded_String;
                               Value_Del: out Values) is
        
        C_Active: A_Maps.Cursor := A_Maps.First(My_Active_Map);
        
    begin
        -- Value del primer elemento del Mapa
        Value_Del := A_Maps.Element(C_Active).Value;
            
        while A_Maps.Has_Element(C_Active) loop
		    -- Si la ultima conexion del cliente apuntado por el cursor 
		    -- es antes que la ultima conexion de mi cliente guardado
		    if (A_Maps.Element(C_Active).Value.Last_Connection <= Value_Del.Last_Connection) then
		
			    Value_Del := A_Maps.Element(C_Active).Value;
			    Nick_Del  := A_Maps.Element(C_Active).Key;
			
		    end if;

		    A_Maps.Next(C_Active);

	    end loop;

    end Inactive_Client;
    
    procedure Inactive_Old_Client (Nick_Del : out ASU.Unbounded_String;
                                   Value_Del: out Values) is
        
        C_Old: O_Maps.Cursor := O_Maps.First(My_Old_Map);
        
    begin
        -- Value del primer elemento del Mapa
        Value_Del := O_Maps.Element(C_Old).Value;
            
        while O_Maps.Has_Element(C_Old) loop
		    -- Si la ultima conexion del cliente apuntado por el cursor 
		    -- es antes que la ultima conexion de mi cliente guardado
		    if (O_Maps.Element(C_Old).Value.Last_Connection <= Value_Del.Last_Connection) then
		
			    Value_Del := O_Maps.Element(C_Old).Value;
			    Nick_Del  := O_Maps.Element(C_Old).Key;
			
		    end if;

		    o_Maps.Next(C_Old);

	    end loop;
    
    end Inactive_Old_Client;
  
    procedure Add_Active_Client (Nick             : in ASU.Unbounded_String;
                                 Client_EP_Handler: in LLU.End_Point_Type;
                                 Del_Active_Client: out Boolean;
                                 Nick_Del         : out ASU.Unbounded_String) is
                                     
        Client_Value: Values;
        Value_Del   : Values;
        
    begin
        -- Creo Value con Actualizacion del Last_Time
        Client_Value := (Client_EP_Handler, AC.CLock);
        -- necesito saber si se ha eliminado cliente de la lista de clientes activos y decirselo al server_handler
        Del_Active_Client := False;
        Nick_Del          := ASU.To_Unbounded_String("unknown");
        
        A_Maps.Put(My_Active_Map, Nick, Client_Value);

    exception
        -- Se ha alcanzado el maximo de Clientes Activos permitidos
        when A_Maps.Full_Map =>
            
            Del_Active_Client := True;
            
            -- Buscar Cliente inactivo durante más tiempo --> Cliente que se va a eliminar
            Inactive_Client(Nick_Del, Value_Del);
            
            -- Añadir Cliente eliminado al Mapa de Clientes Viejos
            Add_Old_Client(Nick_Del, Value_Del.EP);
    
    end Add_Active_Client;
    
    procedure Add_Old_Client (Nick: in ASU.Unbounded_String;
                              EP  : in LLU.End_Point_Type) is
    
        Nick_Del : ASU.Unbounded_String;
        Value_Del: Values;
        Value    : Values;
        Found    : Boolean := False;
        
    begin
        -- Actualizo su tiempo y lo guardo en clientes viejos
        Value := (EP, AC.Clock);
        O_Maps.Put(My_Old_Map, Nick, Value);
        
	    exception
            -- Se ha alcanzado el maximo de Clientes Viejos permitidos
            when O_Maps.Full_Map =>                
                -- Encontrar Cliente Viejo mas antiguo
                Inactive_Old_Client(Nick_Del, Value_Del);

                -- Eliminar Cliente Viejo mas antiguo
                O_Maps.Delete(My_Old_Map, Nick_Del, Found);
                
                if Found then
                
                    Ada.Text_IO.Put_Line("Old Client has been removed"); -- opcional
                    -- Añadir cliente eliminado al Mapa de Clientes Viejos
                    O_Maps.Put(My_Old_Map, Nick, Value);
                
                end if;
        
    end Add_Old_Client;
    
    procedure Delete_Active_Client (Nick : in ASU.Unbounded_String;
                                    Found: out Boolean) is
        
    begin
    
        A_Maps.Delete(My_Active_Map, Nick, Found);
        
        Ada.Text_IO.Put_Line("Active Client has been removed"); -- opcional
        
    end Delete_Active_Client;
    
    procedure Send_To_All (Nick:     in ASU.Unbounded_String;
                           Send_All: in Boolean; 
                           P_Buffer: access LLU.Buffer_Type) is
        
        C_Active: A_Maps.Cursor := A_Maps.First(My_Active_Map);
    
    begin
        
        while A_Maps.Has_Element(C_Active) loop

	        if Send_All or else 
	           (not Send_All and Nick /= A_Maps.Element(C_Active).Key) then

                LLU.Send(A_Maps.Element(C_Active).Value.EP, P_Buffer);
	            
	        end if;

	        A_Maps.Next(C_Active);

        end loop;
        
    end Send_to_All;
    
    function Time_Image (T: in AC.Time) return String is

    begin

        return Gnat.Calendar.Time_IO.Image(T, "%d-%b-%y %T.%i");

    end Time_Image;

    procedure Print_Active_Clients is
        
        C_Active    : A_Maps.Cursor := A_Maps.First(My_Active_Map);
        List        : ASU.Unbounded_String;
        Full_Address: ASU.Unbounded_String;
        IP          : ASU.Unbounded_String;
        Port        : ASU.Unbounded_String;
        Count       : Integer := 0;
        
    begin
        
        if not A_Maps.Has_Element(C_Active) then
            
            raise A_Maps.No_Element;
            
        end if; 
        
		while A_Maps.Has_Element(C_Active) loop
-- Full_Address := LOWER_LAYER.INET.UDP.UNI.ADDRESS IP: 193.147.49.72, Port: 1025		    
		    Full_Address := ASU.To_Unbounded_String(LLU.Image(A_Maps.Element(C_Active).Value.EP));
		    
		    while Count /= 1 loop
                    
                Count := ASU.Index(Full_Address, Ada.Strings.Maps.To_Set(" :,"));	            
                Full_Address := ASU.Tail(Full_Address, ASU.Length(Full_Address) - Count);
            
            end loop;
-- Full_Address := 193.147.49.72, Port: 1025                
            Count := ASU.Index(Full_Address, Ada.Strings.Maps.To_Set(" :,"));
            IP := ASU.Head(Full_Address, Count - 1);
-- Full_Address :=  Port: 1025             
            Full_Address := ASU.Tail(Full_Address, ASU.Length(Full_Address) - Count);

            while Count /= 0 loop
                
                Count := ASU.Index(Full_Address, Ada.Strings.Maps.To_Set(" :,"));	            
                Full_Address := ASU.Tail(Full_Address, ASU.Length(Full_Address) - Count);
                
            end loop;
-- Full_Address := 1025
            Port := ASU.Tail(Full_Address, ASU.Length(Full_Address) - Count);
		    
		    
            List := A_Maps.Element(C_Active).Key & " (" & IP & ":" & Port & "): " & 
                    Time_Image(A_Maps.Element(C_Active).Value.Last_Connection) & 
                    ASCII.LF & List;
            
            A_Maps.Next(C_Active);
        
        end loop;

        Ada.Text_IO.Put_Line(ASU.To_String(List));
    
    exception

        when A_Maps.No_Element =>
            
            Ada.Text_IO.Put_Line("The Map or the List of Active Clients is empty" & ASCII.LF);
    
    end Print_Active_Clients;
    
    procedure Print_Old_Clients is
        
        C_Old : O_Maps.Cursor := O_Maps.First(My_Old_Map);
        List  : ASU.Unbounded_String;
        
    begin

        if not O_Maps.Has_Element(C_Old) then
            
            raise O_Maps.No_Element;
            
        end if;
        
		while O_Maps.Has_Element(C_Old) loop
		
            List := O_Maps.Element(C_Old).Key & ": " & 
                    Time_Image(O_Maps.Element(C_Old).Value.Last_Connection) &
                    ASCII.LF & List;
            
            O_Maps.Next(C_Old);
        
        end loop;

        Ada.Text_IO.Put_Line(ASU.To_String(List));
    
    exception

        when O_Maps.No_Element =>
            
            Ada.Text_IO.Put_Line("The Map or the List of Old Clients is empty" & ASCII.LF);
    
    end Print_Old_Clients;
        
end Map_Treatment;
