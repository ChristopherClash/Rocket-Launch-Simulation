pragma SPARK_Mode (On);

with SPARK.Text_IO; use SPARK.Text_IO;


package rocket_launch is

   Maximum_fuel_load : constant Integer := 5000;
   Minimum_fuel_load : constant Integer := 0;
   Minimum_target_distance : constant Integer := 1000;
   Maximum_target_distance : constant Integer := 5000;
   
  
   subtype target_distance is Integer range Minimum_target_distance .. Maximum_target_distance;
   subtype fuel_range is Integer range Minimum_fuel_load .. Maximum_fuel_load;
   
   type mission_status is (Nominal, Failed, Finished);
   
   type status is (idle, in_use, out_of_fuel, jettisoned);
   
   type stage_type is
      record
         stage_fuel : fuel_range;
         stage_status : status;
         stage_number : Integer;
      end record;
   
   
   type rocket_type is
      record
         stage1 : stage_type;
         stage2 : stage_type;
         stage3 : stage_type;
         target_distance : Integer;
         current_distance : Integer;
         status : mission_status; 
         number_of_stages : Integer := 3;
      end record;
   
   Rocket : rocket_type;
   
   procedure Get_target_distance with
     Global => (In_Out => (rocket, Standard_Input), Output => Standard_Output),
     Depends => (Standard_Output => (Standard_Input), Standard_Input => (Standard_Input), 
                 rocket => (rocket, Standard_Input));
   
   procedure Get_stage_fuel (Stage : in out stage_type) with
     Depends => (Stage => (Stage, Standard_Input), Standard_Output => (Standard_Input, Stage), Standard_Input => (Standard_Input));
   
   procedure launch_rocket(Rocket : in out rocket_type) with
   Pre => Is_Initialised(Rocket);
   
   procedure Fire (Stage : in out stage_type; current_distance : in out Integer);
   
   procedure Jettison (Stage : in out stage_type);
   
   procedure Check_launch (Rocket : in out rocket_type);
   
   procedure Print_stage_statuses with
     Global => (Input => rocket, Output => Standard_Output);
   
   function Is_Initialised(Rocket_status : rocket_type) return Boolean with
   Post => Is_Initialised'Result = True or Is_Initialised'Result = False;
   
   function get_mission_status(Rocket_status : in rocket_type) return boolean is
      (if Rocket_status.stage1.stage_status = jettisoned and Rocket_status.stage2.stage_status = jettisoned 
        and Rocket_status.stage3.stage_status = out_of_fuel and Rocket_status.target_distance > Rocket_status.current_distance then
         Rocket_status.status = Failed else Rocket_status.status = Nominal);
   
   function Status_of_rocket_to_string (Rocket_status : rocket_type)
                                        return String with
     Post => (Status_of_rocket_to_string'Result = "Nominal" or Status_of_rocket_to_string'Result = "Failed" or Status_of_rocket_to_string'Result = "Finished");
   
   function Status_of_stage_to_string (Stage : stage_type)
                                        return String with
     Post => (Status_of_stage_to_string'Result = "Idle" or Status_of_stage_to_string'Result = "Firing" or Status_of_stage_to_string'Result = "Out of fuel" or 
             Status_of_stage_to_string'Result = "Jettisoned");
   
   procedure print_rocket_info with
     Global => (In_Out => Standard_Output,
       Input => rocket),
     Depends => (Standard_Output => (Standard_Output, rocket)),
     Pre => (Is_Initialised(rocket));
   
   procedure init with
     Global => (Output => (Standard_Output, Standard_Input, rocket)),
     Depends => ((Standard_Output, Standard_Input, rocket) => null),
       Post => get_mission_status(rocket);

   
end rocket_launch;
