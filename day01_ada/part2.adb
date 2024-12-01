with Ada.Containers.Vectors;
with Ada.Strings;
with Ada.Strings.Fixed;
with Ada.Text_IO;

use Ada.Containers;
use Ada.Strings;
use Ada.Text_IO;

procedure Main is
    package Int_Vectors is new Vectors (
        Index_Type   => Natural,
        Element_Type => Integer
    );
    List1, List2 : Int_Vectors.Vector;
    Sum : Integer := 0;
    F : File_Type;
begin
    Sum := 0;

    -- Read both lists from stdin
    while not End_Of_File loop
        declare
            Line : String := Get_Line;
            Num1, Num2 : Integer;
            Space_Pos : Positive;
        begin
            if Line'Length = 0 then
                exit;
            end if;

            Space_Pos := Ada.Strings.Fixed.Index(Line, "   ");
            Num1 := Integer'Value(Line(1 .. Space_Pos - 1));
            Num2 := Integer'Value(Line(Space_Pos + 3 .. Line'Last));
            List1.Append(Num1);
            List2.Append(Num2);
        end;
    end loop;

    -- Sum List1(I) * Count, where count is the number of times List1(I)
    -- occurs in List2
    for I in List1.First_Index .. List1.Last_Index loop
        declare
            Count : Integer := 0;
        begin
            for J in List2.First_Index .. List2.Last_Index loop
                if List1(I) = List2(J) then
                    Count := Count + 1;
                end if;
            end loop;
            Sum := Sum + List1(I) * Count;
        end;
    end loop;

    Put_Line("Answer is:" & Integer'Image(Sum));
end Main;