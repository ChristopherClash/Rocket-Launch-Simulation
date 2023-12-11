pragma SPARK_Mode (On);

with AS_Io_Wrapper; use AS_Io_Wrapper;

package body Rocket_control is    

   procedure Get_Target_Distance is
      Distance : Integer;
   begin
      AS_Init_Standard_Output;
      AS_Put_Line("");
      AS_Put_Line("Please enter the target distance (1000-5000KM): ");
      loop
         AS_Get(Distance, "Please enter an integer: ");
         exit when (Distance >= Minimum_Distance) and (Distance <= Maximum_Distance);
         AS_Put_Line("Please enter a value between" &Integer'Image(Minimum_Distance) & " and" &Integer'Image(Maximum_Distance) & ":");
      end loop;
      Rocket.Target_Distance := Distance;
   end Get_Target_Distance;
   
   procedure Get_Stage_Fuel (Stage : in out Stage_Type) is
      Fuel_Load : Integer;
   begin
      AS_Init_Standard_Output;
      AS_Put_Line("Please enter the fuel load for stage" &Integer'image(Stage.Stage_Number) & " of the rocket (0-5000L): ");
      loop
         AS_Get(Fuel_Load, "Please enter an integer: ");
         exit when (Fuel_Load >= Minimum_Fuel_Load) and (Fuel_Load <= Maximum_Fuel_Load);
         AS_Put_Line("Please enter a value between" &Integer'Image(Minimum_Fuel_Load) & " and" &Integer'Image(Maximum_Fuel_Load) & ":");
      end loop;
      Stage.Stage_Fuel := Fuel_Load;
   end Get_Stage_Fuel;
   
   procedure Launch_Rocket_And_Check_Distance (Rocket : in out Rocket_Type; Result : out Boolean) is
   Current_Distance : Integer := Rocket.Current_Distance;
   Target_Distance : Distance_Range := Rocket.Target_Distance;
begin 
   Print_Stage_Statuses;

   if Rocket.Stage1.Stage_Status = Idle then
      Rocket.Stage1.Stage_Status := Firing;
      Print_Stage_Statuses;
      Fire(Rocket.Stage1, Rocket.Current_Distance);
   end if;

   if Rocket.Stage1.Stage_Status = Out_Of_Fuel and 
      Rocket.Stage2.Stage_Status = Idle and Current_Distance < Target_Distance then
      if Rocket.Stage1.Stage_Number = 1 then
         Jettison(Rocket.Stage1);
      end if;
      Rocket.Stage2.Stage_Status := Firing;
      Print_Stage_Statuses;
      Fire(Rocket.Stage2, Rocket.Current_Distance);
   end if;

   if Rocket.Stage1.IsJettisoned and
      Rocket.Stage2.Stage_Status = Out_Of_Fuel and Current_Distance < Target_Distance then
      if Rocket.Stage2.Stage_Number = 2 then
         Jettison(Rocket.Stage2);
      end if;
      Rocket.Stage3.Stage_Status := Firing;
      Print_Stage_Statuses;
      Fire(Rocket.Stage3, Rocket.Current_Distance);
   end if;

   Result := Rocket.Current_Distance >= Rocket.Target_Distance;
end Launch_Rocket_And_Check_Distance;
   
   procedure Fire(Stage : in out Stage_Type; Current_Distance : in out Integer) is
      Distance_Travelled : Integer;
      New_Distance : Integer;
      Current_Distance_Before : Integer := Current_Distance;
   begin
      if Stage.Stage_Status = Firing then
         AS_Put_Line("Firing stage " &Integer'image(Stage.Stage_Number) & " booster!");
         Stage.Stage_Status := Out_Of_Fuel;
         Print_Stage_Statuses;
         Distance_Travelled := Integer(Stage.Stage_Fuel / 2);
         New_Distance := Current_Distance_Before + Distance_Travelled;
         Current_Distance := New_Distance;
         AS_Put_Line("Currently travelled " &Integer'image(Current_Distance) & "KM");
      end if;
   end Fire;
   
   procedure Jettison(Stage : in out Stage_Type) is
   begin
      if Stage.Stage_Status = Out_Of_Fuel then
         Print_Stage_Statuses;
         AS_Put_Line("Stage " &Integer'image(Stage.Stage_Number) & " is out of fuel!");
         AS_Put_Line("Jettisoning stage " &Integer'image(Stage.Stage_Number) & "!");
         Stage.isJettisoned := True;
      end if;
   end Jettison;
   
   procedure Print_Stage_Statuses is
   begin
      AS_Put_Line("");
      AS_Put_Line("Stage 1 Status: " & Status_Of_Stage_To_String(rocket.Stage1));
      AS_Put_Line("Stage 2 Status: " & Status_Of_Stage_To_String(rocket.Stage2));
      AS_Put_Line("Stage 3 Status: " & Status_Of_Stage_To_String(rocket.Stage3)); 
      AS_Put_Line("");
   end Print_Stage_Statuses;
   
      
   
   procedure Check_Launch (Rocket : in out Rocket_Type) is
   begin
      if Rocket.Stage3.Stage_Status = Out_Of_Fuel and Rocket.Current_Distance < Rocket.Target_Distance then
         Rocket.Status := Failed;
         Print_Rocket_Info(Rocket);
         AS_Put_Line("Mission failed, please enter new parameters!");
      end if;
      if Rocket.Current_Distance >= Rocket.Target_Distance then
         Rocket.Status := Finished;
         Print_Rocket_Info(Rocket);
         AS_Put_Line("Mission successful, reached target distance!");
      else
         Rocket.Status := Nominal;
      end if;
   end Check_Launch;
   
                  
   function Status_Of_Rocket_To_String (Rocket_Status : in Rocket_Type) return String is
   begin
      if (Rocket_Status.Status = Nominal)
      then return "Nominal";
      end if;
      if (Rocket_Status.Status = Finished)
      then return "Finished";
      else
         return "Failed";
      end if;
   end Status_Of_Rocket_To_String;
   
   function Status_Of_Stage_To_String (Stage : in Stage_Type) return String is
   begin
      if (Stage.Stage_Status = Idle)
      then return "Idle";
         end if;
      if (Stage.Stage_Status = Firing)
      then return "Firing";
         end if;
      if (Stage.Stage_Status = Out_Of_Fuel)
      then return "Out of fuel";
         end if;
      return "";
   end Status_Of_Stage_To_String;
   
   
   function Is_Initialised(Rocket_Status : in Rocket_Type) return Boolean is
   begin
      if Rocket_Status.Status = Nominal or Rocket_Status.Status = Failed or Rocket_Status.Status = Finished then
         return True;
      else return False;
      end if;
   end Is_Initialised;  
   
  
   procedure Print_Rocket_Info (Rocket : in Rocket_Type) is
   begin
      AS_Put_Line("");
      AS_Put_Line("Target distance: " &Integer'Image(Rocket.Target_Distance) & "KM");
      AS_Put_Line("Current distance: " &Integer'Image(Rocket.Current_Distance) & "KM");
      AS_Put_Line("Stage 1 Status: " & Status_Of_Stage_To_String(Rocket.Stage1));
      AS_Put_Line("Stage 2 Status: " & Status_Of_Stage_To_String(Rocket.Stage2));
      AS_Put_Line("Stage 3 Status: " & Status_Of_Stage_To_String(Rocket.Stage3));
      AS_Put_Line("Mission Status: " & Status_Of_Rocket_To_String(Rocket));
  
   end Print_Rocket_Info;
   
  
   procedure Init is
      stage_1 : Stage_Type := (Stage_Fuel => 0, Stage_Status => Idle, Stage_Number => 1, isJettisoned => False);
      stage_2 : Stage_Type := (Stage_Fuel => 0, Stage_Status => Idle, Stage_Number => 2, isJettisoned => False);
      stage_3 : Stage_Type := (Stage_Fuel => 0, Stage_Status => Idle, Stage_Number => 3, isJettisoned => False);
   begin
      AS_Init_Standard_Output;
      AS_Init_Standard_Input;
      Rocket := (Stage1 => stage_1, Stage2 => stage_2, Stage3 => stage_3, 
                 Target_Distance => Minimum_Distance, Current_Distance => 0, Status => Nominal, Number_Of_Stages => 3);                   
   end Init;            
   
end Rocket_control;
