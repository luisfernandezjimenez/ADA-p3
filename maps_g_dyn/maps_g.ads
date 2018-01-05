-- Work carried out by Luis Fernández Jiménez

with Ada.Unchecked_Deallocation;

generic
    
    type Key_Type   is private;
    type Value_Type is private;
    with function "=" (K1, K2: in Key_Type) return Boolean;    
    Max: in Natural;
    
package Maps_G is
        
    type Map is limited private;
    
    procedure Get (M      : in Map;
                   Key    : in Key_Type;
                   Value  : out Value_Type;
                   Success: out Boolean);
    -- Dado un Key, se busca en el Mapa y si se encuentra devuelve su Value y Success es True
    Full_Map : exception;

    procedure Put (M    : in out Map;
                   Key  : in Key_Type;
                   Value: in Value_Type);
    -- Añadir cliente (key y Value) al Mapa si no se ha llegado al Max
    procedure Delete (M      : in out Map;
                      Key    : in Key_Type;
                      Success: out Boolean);
    -- Dado un Key, se busca en el Mapa y si se encuentra se elimina y Success es True
    function Map_Length (M: in Map) return Natural;
    --
    -- Cursor Interface for iterating over Map elements
    --
    type Cursor is limited private;
    
    function First (M: in Map) return Cursor;
    -- Pasa al siguiente elemento del Mapa
    procedure Next (C: in out Cursor);
    -- Si el Cursos /= Null --> return True else False
    function Has_Element (C: in Cursor) return Boolean;

    type Element_Type is record
        Key: Key_Type;
        Value: Value_Type;
    end record;

    No_Element: exception;
    -- Raises No_Element if Has_Element(C) = False;
    
    -- Devuelve el contenido de los campos del elemento apuntado por el Cursor
    function Element (C: in Cursor) return Element_Type;

private
    type Cell;
    type Cell_A is access Cell;
    type Cell is record
        Key  : Key_Type;
        Value: Value_Type;
        Next : Cell_A;
    end record;

    type Map is record
        P_First: Cell_A  := Null;
        Length : Natural := 0;
    end record;

    type Cursor is record
        M         : Map;
        Element_A : Cell_A;
    end record;

end Maps_G;
