-- Work carried out by Luis Fernández Jiménez

with Ada.Text_IO;
with Ada.Strings.Unbounded;
with Ada.Strings.Maps;
with Ada.Exceptions;
with Maps_G;
with Lower_Layer_UDP;
with Ada.Command_Line;
with Ada.Calendar;
with Gnat.Calendar.Time_IO;

package Map_Treatment is
    
    package ASU renames Ada.Strings.Unbounded;
    package LLU renames Lower_Layer_UDP;
    package ACL renames Ada.Command_Line;
    package AC  renames Ada.Calendar;
    
    use type LLU.End_Point_Type;
    use type ASU.Unbounded_String;
    use type AC.Time;
    
    type Values is record
        
        EP             : LLU.End_Point_Type;
        Last_Connection: AC.Time;
   
    end record;
    -- Necesito definir el maximo de clientes activos permitidos en el server_handler
    Max_Clients: Natural := Natural'Value(ACL.Argument(ACL.Argument_Count));
    
    -- Clientes Activos
    package A_Maps is new Maps_G(Key_Type   => ASU.Unbounded_String,
							     Value_Type => Values,
							     "="        => ASU."=",
   							     Max        => Max_Clients);
   	-- Clientes Antiguos No Activos								 
    package O_Maps is new Maps_G(Key_Type   => ASU.Unbounded_String,
   								 Value_Type => Values,
   								 "="        => ASU."=",
   								 Max        => 150);
    
    My_Active_Map: A_Maps.Map;
    My_Old_Map   : O_Maps.Map;
    
    function Check_Nick (Nick       : in ASU.Unbounded_String;
                         EP         : in LLU.End_Point_Type;
                         Mess_Init  : in Boolean) return Boolean;
    
    procedure Inactive_Client (Nick_Del : out ASU.Unbounded_String;
                               Value_Del: out Values);
                               
    procedure Inactive_Old_Client (Nick_Del : out ASU.Unbounded_String;
                                   Value_Del: out Values);
    
    procedure Add_Active_Client (Nick             : in ASU.Unbounded_String;
                                 Client_EP_Handler: in LLU.End_Point_Type;
                                 Del_Active_Client: out Boolean;
                                 Nick_Del         : out ASU.Unbounded_String);
                                
    procedure Add_Old_Client (Nick: in ASU.Unbounded_String;
                              EP  : in LLU.End_Point_Type);

    procedure Delete_Active_Client (Nick : in ASU.Unbounded_String;
                                    Found: out Boolean);

    procedure Send_To_All (Nick:     in ASU.Unbounded_String;
                           Send_All: in Boolean; 
                           P_Buffer: access LLU.Buffer_Type);

    function Time_Image (T: in AC.Time) return String;
    
    procedure Print_Active_Clients;
    
    procedure Print_Old_Clients;
    
end Map_Treatment;
