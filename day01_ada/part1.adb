with Ada.Strings;
use Ada.Strings;

with Ada.Strings.Bounded;
with Ada.Strings.Fixed;
with Ada.Text_IO;
use Ada.Text_IO;

with Ada.Containers.Vectors;
use Ada.Containers;

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

    -- Sort both lists
    declare
        package Int_Vector_Sorting is new Int_Vectors.Generic_Sorting;
    begin
        Int_Vector_Sorting.Sort(List1);
        Int_Vector_Sorting.Sort(List2);
    end;

    for I in List1.First_Index .. List1.Last_Index loop
        Sum := Sum + abs(List1(I) - List2(I));
    end loop;

    Put_Line("Answer is:" & Integer'Image(Sum));
end Main;