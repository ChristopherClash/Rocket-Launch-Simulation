pragma SPARK_Mode (On);

with AS_Io_Wrapper; use AS_Io_Wrapper;

package body rocket_launch is
   
   procedure Read_Current_Angle is
      Angle : Integer;
   begin
      AS_Put_Line("Please enter the current angle readout: ");
      loop
         AS_Get(Angle, "Please enter an integer");
         exit when (Angle >= Minimum_angle) and (Angle <= Maximum_angle);
         AS_Put_Line("Please enter a value between " &Integer'Image(Minimum_angle) & " and " &Integer'Image(Maximum_angle));
      end loop;
      Rocket_launch_Status.Angle_measured := Integer(Angle);
      if (Rocket_launch_Status.Angle_measured > Maximum_viable_angle_of_attack) or 
        (Rocket_launch_Status.Angle_measured < Minimum_viable_angle_of_attack) then
         AS_Put_Line("Course correction needed!");
         correct_course;
      end if;
   end Read_Current_Angle;
                
   function Status_of_rocket_to_string (Rocket_launch_status : rocket_launch_status_type)
                                        return String is
   begin
      if (Rocket_launch_Status.Launch_status = Nominal)
      then return "Nominal";
      else return "Not Nominal";
      end if;
   end Status_of_rocket_to_string;
   
   procedure print_status is
   begin
      AS_Put_Line("Angle of attack = " &Integer'Image(Rocket_launch_Status.Angle_measured));
      AS_Put_Line("Launch status = " & (Status_of_rocket_to_string(Rocket_launch_Status)));
      AS_Put_Line("Remaining fuel = " & Current_Fuel_load'Image(Rocket_launch_Status.Current_fuel));
   end print_status;
   
   procedure monitor_course is
   begin
      if Integer(Rocket_launch_Status.Angle_measured) >= Minimum_viable_angle_of_attack and
        Integer(Rocket_launch_Status.Angle_measured) <= Maximum_viable_angle_of_attack and Integer(Rocket_launch_Status.Current_fuel) > 0
      then Rocket_launch_Status.Launch_status := Nominal;
      else Rocket_launch_Status.Launch_status := Not_Nominal;
      end if;
   end monitor_course;
   
   procedure correct_course is
      Fuel_used : Current_Fuel_load := 0;
      Current_fuel_Remaining : Current_Fuel_load := Rocket_launch_Status.Current_fuel;
      Current_angle : Integer := Rocket_launch_Status.Angle_measured;
      Angle_Change : Integer := 0;
   begin
      if Current_angle < Minimum_viable_angle_of_attack then
         loop
            if Current_angle < 90 then
               Current_angle := Current_angle + 1;
               Angle_Change := Angle_Change + 1;
               AS_Put_Line("Correcting course, new angle of attack is: " &Integer'Image(Current_angle));
               Fuel_used := Fuel_used + 1;
               Rocket_launch_Status.Angle_measured := Current_angle;
            else
               exit;
            end if;
         end loop;
      elsif Current_angle > Maximum_viable_angle_of_attack then
         loop
            if 90 < Current_angle then
               Current_angle := Current_angle - 1;
               Angle_Change := Angle_Change + 1;
               AS_Put_Line("Correcting course, new angle of attack is: " &Integer'Image(Current_angle));
               Fuel_used := Fuel_used + 1;
               Rocket_launch_Status.Angle_measured := Current_angle;
            else
               exit;
            end if;
         end loop;
      end if;
      AS_Put_Line("Course corrected. Total angle change: " &Integer'Image(Angle_Change) & " Total fuel burned: " &Current_Fuel_load'Image(Fuel_used));
      Current_fuel_Remaining := Current_fuel_Remaining - Fuel_used;
      Rocket_launch_Status.Current_fuel := Current_fuel_Remaining;
   end correct_course;
    
   procedure init is
   begin
      AS_Init_Standard_Input;
      AS_Init_Standard_Output;
      Rocket_launch_Status := (Angle_measured => 90,
                               Launch_status => Nominal,
                               Current_Fuel => Current_Fuel_load(Maximum_fuel_load));
   end init;            
   
end rocket_launch;
