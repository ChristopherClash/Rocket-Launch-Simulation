pragma SPARK_Mode (On);

with AS_Io_Wrapper; use AS_Io_Wrapper;

package body rocket_launch is    

   procedure Get_target_distance is
      distance : Integer;
   begin
      AS_Init_Standard_Output;
      AS_Put_Line("Please enter the target distance (1000-5000KM): ");
      loop
         AS_Get(distance, "Please enter an integer");
         exit when (distance >= Minimum_target_distance) and (distance <= Maximum_target_distance);
         AS_Put_Line("Please enter a value between " &Integer'Image(Minimum_target_distance) & " and " &Integer'Image(Maximum_target_distance));
      end loop;
      rocket.target_distance := distance;
   end Get_target_distance;
   
   procedure Get_stage_fuel (Stage : in out stage_type) is
      fuel_load : Integer;
   begin
      AS_Init_Standard_Output;
      AS_Put_Line("Please enter the fuel load for stage" &Integer'image(Stage.stage_number) & " of the rocket (0-5000L): ");
      loop
         AS_Get(fuel_load, "Please enter an integer");
         exit when (fuel_load >= Minimum_fuel_load) and (fuel_load <= Maximum_fuel_load);
         AS_Put_Line("Please enter a value between " &Integer'Image(Minimum_fuel_load) & " and " &Integer'Image(Maximum_fuel_load));
      end loop;
      Stage.stage_fuel := fuel_load;
   end Get_stage_fuel;
   
   procedure launch_rocket(Rocket : in out rocket_type) is
      Current_distance : Integer := Rocket.current_distance;
      Target_distance : Integer := Rocket.target_distance;
   begin 
      Print_stage_statuses;
      if Rocket.stage1.stage_status = idle then
         Rocket.stage1.stage_status := in_use;
         Print_stage_statuses;
         Fire(Rocket.stage1, Rocket.current_distance);
      end if;
      
      if Rocket.stage1.stage_status = out_of_fuel and 
           Rocket.stage2.stage_status = idle and Current_distance < Target_distance then
         Jettison(Rocket.stage1);
         Rocket.stage2.stage_status := in_use;
         Print_stage_statuses;
         Fire(Rocket.stage2, Rocket.current_distance);
      end if;
                  
      if Rocket.stage1.stage_status = jettisoned and
           Rocket.stage2.stage_status = out_of_fuel and Current_distance < Target_distance then
         Jettison(Rocket.stage2);
         Rocket.stage3.stage_status := in_use;
         Print_stage_statuses;
         Fire(Rocket.stage3, Rocket.current_distance);
      end if;      
   end launch_rocket;
   
   procedure Fire(Stage : in out stage_type; current_distance : in out Integer) is
      Distance_travelled : Integer;
   begin
      if Stage.stage_status = in_use then
         AS_Put_Line("Firing stage " &Integer'image(Stage.stage_number) & " booster!");
         Stage.stage_status := out_of_fuel;
         Print_Stage_statuses;
         Distance_travelled := Stage.stage_fuel / 2;
         current_distance := current_distance + Distance_travelled;  
         AS_Put_Line("Currently travelled " &Integer'image(current_distance) & "KM");
      end if;
   end Fire;
   
   procedure Jettison(Stage : in out stage_type) is
   begin
      if Stage.stage_status = out_of_fuel then
         Print_Stage_statuses;
         AS_Put_Line("Stage " &Integer'image(Stage.stage_number) & " is out of fuel!");
         AS_Put_Line("Jettisoning stage " &Integer'image(Stage.stage_number) & "!");
         Stage.stage_status := jettisoned;
      end if;
   end Jettison;
   
   procedure Print_stage_statuses is
   begin
      AS_Put_Line("");
      AS_Put_Line("Stage 1 status: " & Status_of_stage_to_string(rocket.stage1));
      AS_Put_Line("Stage 2 status: " & Status_of_stage_to_string(rocket.stage2));
      AS_Put_Line("Stage 3 status: " & Status_of_stage_to_string(rocket.stage3)); 
      AS_Put_Line("");
   end Print_stage_statuses;
   
      
   
   procedure Check_launch (Rocket : in out rocket_type) is
   begin
      if Rocket.stage1.stage_status = jettisoned and Rocket.stage2.stage_status = jettisoned 
        and Rocket.stage3.stage_status = out_of_fuel and Rocket.current_distance < Rocket.target_distance then
         Rocket.status := Failed;
         print_rocket_info;
      end if;
      if Rocket.current_distance >= Rocket.target_distance then
         AS_Put_Line("Mission successful, reached target distance!");
         Rocket.status := Finished;
         print_rocket_info;
      else
         Rocket.status := Nominal;
      end if;
   end Check_launch;
   
                  
   function Status_of_rocket_to_string (Rocket_Status : in rocket_type) return String is
   begin
      if (Rocket_Status.status = Nominal)
      then return "Nominal";
      end if;
      if (Rocket_Status.status = Finished)
      then return "Finished";
      else
         return "Failed";
      end if;
   end Status_of_rocket_to_string;
   
   function Status_of_stage_to_string (Stage : in stage_type) return String is
   begin
      if (Stage.stage_status = idle)
      then return "Idle";
         end if;
      if (Stage.stage_status = in_use)
      then return "Firing";
         end if;
      if (Stage.stage_status = out_of_fuel)
      then return "Out of fuel";
         end if;
      if (Stage.stage_status = jettisoned)
      then return "Jettisoned";
      end if;
      return "";
   end Status_of_stage_to_string;
   
   
   function Is_Initialised(Rocket_status : in rocket_type) return Boolean is
   begin
      if Rocket_status.status = Nominal or Rocket_status.status = Failed or Rocket_status.status = Finished then
         return True;
      else return False;
      end if;
   end Is_Initialised;  
   
  
   procedure print_rocket_info is
   begin
      AS_Put_Line("");
      AS_Put_Line("Target distance: " &Integer'Image(rocket.target_distance));
      AS_Put_Line("Current distance: " &Integer'Image(rocket.current_distance));
      AS_Put_Line("Stage 1 status: " & Status_of_stage_to_string(rocket.stage1));
      AS_Put_Line("Stage 2 status: " & Status_of_stage_to_string(rocket.stage2));
      AS_Put_Line("Stage 3 status: " & Status_of_stage_to_string(rocket.stage3));
      AS_Put_Line("Mission status: " & Status_of_rocket_to_string(rocket));
  
   end print_rocket_info;
   
  
   procedure init is
      stage_1 : stage_type := (stage_fuel => 1000, stage_status => idle, stage_number => 1);
      stage_2 : stage_type := (stage_fuel => 800, stage_status => idle, stage_number => 2);
      stage_3 : stage_type := (stage_fuel => 600, stage_status => idle, stage_number => 3);
   begin
      AS_Init_Standard_Output;
      AS_Init_Standard_Input;
      rocket := (stage1 => stage_1, stage2 => stage_2, stage3 => stage_3, 
                 target_distance => Minimum_target_distance, current_distance => 0, status => Nominal, number_of_stages => 3);                   
   end init;            
   
end rocket_launch;
