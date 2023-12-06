pragma SPARK_Mode (On);

with AS_Io_Wrapper; use AS_Io_Wrapper;

package body rocket_launch is
   
   procedure Get_windspeed is
      Wind_speed : Integer;
      new_angle : angle_range;
   begin
      AS_Init_Standard_Output;
      AS_Put_Line("Please enter the current windspeed readout (KM/h): ");
      loop
         AS_Get(Wind_speed, "Please enter an integer");
         exit when (Wind_speed >= Minimum_windspeed) and (Wind_speed <= Maximum_windspeed);
         AS_Put_Line("Please enter a value between " &Integer'Image(Minimum_windspeed) & " and " &Integer'Image(Maximum_windspeed));
      end loop;
      new_angle := Calculate_new_angle(Wind_speed, Weight_of_rocket);
      Rocket_launch_Status.Angle_measured := new_angle;
      if (Rocket_launch_Status.Angle_measured > Maximum_viable_angle_of_attack) or 
        (Rocket_launch_Status.Angle_measured < Minimum_viable_angle_of_attack) then
         correct_course;
      end if;
   end Get_windspeed;
   
                   
   function Status_of_rocket_to_string (Rocket_launch_status : in rocket_launch_status_type) return String is
   begin
      if (Rocket_launch_Status.Launch_status = Nominal)
      then return "Nominal";
      else return "Not Nominal";
      end if;
   end Status_of_rocket_to_string;
   
   
   function Is_Initalised(Status : in rocket_launch_status_type) return Boolean is
   begin
      if Status.Launch_status = Nominal or Status.Launch_status = Not_Nominal then
         return True;
      else return False;
      end if;
   end Is_Initalised;  
   
  
   procedure print_status is
   begin
      AS_Put_Line("");
      AS_Put_Line("Angle of attack = " &Integer'Image(Rocket_launch_Status.Angle_measured));
      AS_Put_Line("Launch status = " & (Status_of_rocket_to_string(Rocket_launch_Status)));
      AS_Put_Line("Remaining fuel = " & Integer'Image(Rocket_launch_Status.Current_fuel));
      AS_Put_Line("");
   end print_status;
   
   
   procedure monitor_course is
   begin
      if Integer(Rocket_launch_Status.Angle_measured) >= Minimum_viable_angle_of_attack and
        Integer(Rocket_launch_Status.Angle_measured) <= Maximum_viable_angle_of_attack and Integer(Rocket_launch_Status.Current_fuel) > Minimum_required_fuel
      then Rocket_launch_Status.Launch_status := Nominal;
      else Rocket_launch_Status.Launch_status := Not_Nominal;
      end if;
   end monitor_course;
   
   
   procedure correct_course is
      Fuel_used : Integer := 0;
      Current_fuel_Remaining : Current_Fuel_load := Rocket_launch_Status.Current_fuel;
      Current_angle : angle_range := Rocket_launch_Status.Angle_measured;
      Angle_Change : angle_range := 0; 
      Is_enough_fuel : Boolean;
   begin
      AS_Init_Standard_Output;
      AS_Put_Line("Current angle is: " &Integer'Image(Current_angle) & " degrees, correction needed!");
      if Current_angle < Minimum_viable_angle_of_attack then
         loop
            pragma Loop_Invariant(Current_angle >= Minimum_angle and Angle_Change >= Minimum_angle and Fuel_used >= 0 and Fuel_used <= Maximum_fuel_load);
            if Current_angle < 90 then
               Current_angle := Current_angle + 1;
               if Angle_Change + 1 < Maximum_angle then
                  Angle_Change := Angle_Change + 1;
                  end if;
               if Fuel_used + 2 < Maximum_fuel_load then
                  Fuel_used := Fuel_used + 2;
               end if;
               Rocket_launch_Status.Angle_measured := Current_angle;
            else
               exit;
            end if;
         end loop;
      elsif Current_angle > Maximum_viable_angle_of_attack then
         loop
            pragma Loop_Invariant(Current_angle >= Minimum_angle and Angle_Change >= Minimum_angle and Fuel_used >= 0 and Fuel_used <= Maximum_fuel_load);
            if 90 < Current_angle then
                  Current_angle := Current_angle - 1;
                  if Angle_Change + 1 < Maximum_angle then
                  Angle_Change := Angle_Change + 1;
                  end if;
               if Fuel_used + 2 < Maximum_fuel_load then
                  Fuel_used := Fuel_used + 2;
               end if;
               Rocket_launch_Status.Angle_measured := Current_angle;
            else
               exit;
            end if;
         end loop;
      end if;
      AS_Put_Line("Course corrected.");
      AS_Put_Line("Total angle changed during correction to optimal angle: " &Integer'Image(Angle_Change));
      AS_Put_Line("Total fuel burned during correction: " &Integer'Image(Fuel_used));
      if (Current_fuel_Remaining - Fuel_used >= Minimum_required_fuel) then
         Is_enough_fuel := Enough_fuel(Current_Fuel_load =>  - Fuel_used);
         if (Is_enough_fuel) then
            Current_fuel_Remaining := Current_fuel_Remaining - Fuel_used;
            AS_Put_Line("Enough fuel remaining");
         end if; 
      else
         AS_Put_Line("");
         AS_Put_Line("Insufficient fuel to reach orbit, launch has failed!");
      end if;
      Rocket_launch_Status.Current_fuel := Current_fuel_Remaining;
      AS_Put_Line("");
      AS_Put_Line("Fuel is now: " &Integer'Image(Rocket_launch_Status.Current_fuel));           
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
