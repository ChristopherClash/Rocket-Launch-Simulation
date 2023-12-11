pragma SPARK_Mode (On);

with SPARK.Text_IO; use SPARK.Text_IO;


package Rocket_control is

   Maximum_Fuel_Load : constant Integer := 5000;
   Minimum_Fuel_Load : constant Integer := 0;
   Minimum_Distance : constant Integer := 1000;
   Maximum_Distance : constant Integer := 5000;
   
   subtype Distance_Range is Integer range Minimum_Distance .. Maximum_Distance;
   subtype Fuel_Range is Integer range Minimum_Fuel_Load .. Maximum_Fuel_Load;
   subtype Stage_Number_range is Integer range 0 .. 3;
   
   type Mission_Statuses is (Nominal, Failed, Finished);
   
   type Stage_Statuses is (Idle, Firing, Out_Of_Fuel);
   
   type Stage_Type is
      record
         Stage_Fuel : Fuel_Range;
         Stage_Status : Stage_Statuses;
         Stage_Number : Stage_Number_range;
         isJettisoned : boolean;
      end record;
   
   type Rocket_Type is
      record
         Stage1 : Stage_Type;
         Stage2 : Stage_Type;
         Stage3 : Stage_Type;
         Target_Distance : Distance_Range;
         Current_Distance : Integer;
         Status : Mission_Statuses; 
         Number_Of_Stages : Integer := 3;
      end record;
   
   Rocket : Rocket_Type;
   
   procedure Get_Target_Distance with
     Global => (In_Out => (rocket, Standard_Input), Output => Standard_Output),
     Depends => (Standard_Output => (Standard_Input), Standard_Input => (Standard_Input), 
                 rocket => (rocket, Standard_Input));
   
   procedure Get_Stage_Fuel (Stage : in out Stage_Type) with
     Depends => (Stage => (Stage, Standard_Input), Standard_Output => (Standard_Input, Stage), Standard_Input => (Standard_Input));
   
   procedure Launch_Rocket_And_Check_Distance (Rocket : in out Rocket_Type; Result : out Boolean)
  with
    Pre =>
         (Rocket.Stage1.Stage_Status = Idle
            and not Rocket.Stage1.isJettisoned
          and Rocket.Stage2.Stage_Status = Idle
            and not Rocket.Stage2.isJettisoned
          and Rocket.Stage3.Stage_Status = Idle
            and not Rocket.Stage3.isJettisoned
           and Rocket.Current_Distance < Rocket.Target_Distance),
    Post =>
      (if Result then
         (Rocket.Stage1.Stage_Status in Idle | Firing | Out_Of_Fuel or Rocket.Stage1.isJettisoned)
         and (Rocket.Stage1.Stage_Status in Idle | Firing | Out_Of_Fuel or Rocket.Stage1.isJettisoned)
         and (Rocket.Stage3.Stage_Status in Idle | Out_Of_Fuel or Rocket.Stage3.Stage_Status = Firing));
   
   procedure Fire (Stage : in out Stage_Type; Current_Distance : in out Integer) with
    Pre => (Stage.Stage_Status = Firing and not Stage.isJettisoned and Current_Distance <= Integer'Last - Integer(Stage.Stage_Fuel / 2)),
    Post => Current_Distance = Current_Distance'Old + Integer(Stage.Stage_Fuel / 2);

   
   procedure Jettison (Stage : in out Stage_Type) with
    Pre => (Stage.Stage_Status = Out_Of_Fuel and Stage.Stage_Number /= 3),
    Post =>
      (Stage.isJettisoned = True);
   
   procedure Check_Launch (Rocket : in out Rocket_Type) with 
     Depends => (Rocket => Rocket, Standard_Output =>(Rocket, Standard_Output)),
     Pre => is_Initialised(Rocket);
   
   procedure Print_Stage_Statuses with
     Depends => (Standard_Output => (Standard_Output, rocket));
   
   function Is_Initialised(Rocket_Status : Rocket_Type) return Boolean with
   Pre => (Rocket_Status.Status in Nominal | Failed | Finished),
    Post =>
      (if Rocket_Status.Status in Nominal | Failed | Finished then
         Is_Initialised'Result = True
       else
         Is_Initialised'Result = False);
   
   function Get_Mission_Status(Rocket_Status : in Rocket_Type) return boolean is 
     (if Rocket_Status.Stage3.Stage_Status = Out_Of_Fuel and Rocket_Status.Target_Distance > Rocket_Status.Current_Distance and Rocket_Status.Stage2.Stage_Status = Out_Of_Fuel then
         Rocket_Status.Status = Failed else Rocket_Status.Status = Nominal);
   
   function Status_Of_Rocket_To_String (Rocket_Status : Rocket_Type)
                                        return String with
     Post => (Status_Of_Rocket_To_String'Result = "Nominal" or Status_Of_Rocket_To_String'Result = "Failed" or Status_Of_Rocket_To_String'Result = "Finished");
   
   function Status_Of_Stage_To_String (Stage : Stage_Type)
                                       return String with
     Post => (Status_Of_Stage_To_String'Result = "Idle" or Status_Of_Stage_To_String'Result = "Firing" or Status_Of_Stage_To_String'Result = "Out of fuel");
   
   procedure Print_Rocket_Info (Rocket : in Rocket_Type) with
     Depends => (Standard_Output => (Standard_Output, rocket)),
     Pre => (Is_Initialised(rocket));
   
   procedure Init with
     Global => (Output => (Standard_Output, Standard_Input, rocket)),
     Depends => ((Standard_Output, Standard_Input, rocket) => null),
       Post => Get_Mission_Status(rocket);

   
end Rocket_control;
