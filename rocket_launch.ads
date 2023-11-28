pragma SPARK_Mode (On);

with SPARK.Text_Io; use SPARK.Text_IO;

-- This file was created by Christopher Clash
-- It is a simple example of a rocket launch system 
-- It monitors the angle of attack of the rocket.
-- If the rocket's angle goes outside the angle of attack action is taken to correct this
-- However, correcting course uses the limited fuel the rocket has (enough to travel 1.2x the distance). 
-- If the rocket runs out of fuel the launch fails

package rocket_launch is

   Maximum_angle : constant Integer := 359;
   Minimum_angle : constant Integer := 0;
   Maximum_viable_angle_of_attack : constant Integer := 135;
   Minimum_viable_angle_of_attack : constant Integer := 45;
   Maximum_fuel_load : constant Float := 240.0;
  
 
   subtype Current_Fuel_load is Float range 0.0 .. Maximum_fuel_load;
   subtype angle_range is Integer range Minimum_angle .. Maximum_angle;
   subtype Viable_angle_of_attack_range is angle_range range Minimum_viable_angle_of_attack .. Maximum_viable_angle_of_attack;
   type Rocket_status_type is (Nominal, Not_Nominal);
   
   type rocket_launch_status_type is
      record
         Angle_measured : angle_range;
         Launch_status : Rocket_status_type;
         Current_fuel : Current_Fuel_load;
      end record;
   
   Rocket_launch_Status : rocket_launch_status_type;
   
   procedure Read_Current_Angle with
     Global => (In_Out => (Standard_Output, Standard_Input, Rocket_launch_Status)),
     Depends => (Standard_Output => (Standard_Output, Standard_Input, Rocket_launch_Status),
                 Standard_Input => Standard_Input,
                 Rocket_launch_Status => (Rocket_launch_Status, Standard_Input));
   
   function Is_Initalised(Status : rocket_launch_status_type) return Boolean;
   
   function Status_of_rocket_to_string (Rocket_launch_status : rocket_launch_status_type)
                                        return String with
   Post => (Status_of_rocket_to_string'Result = "Nominal" or Status_of_rocket_to_string'Result = "Not Nominal");
   
   procedure print_status with
     Global => (In_Out => Standard_Output,
                Input => Rocket_launch_Status),
     Depends => (Standard_Output => (Standard_Output, Rocket_launch_Status)),
     Pre => (Is_Initalised(Rocket_launch_Status));
   
   function is_launch_nominal(Current_status : rocket_launch_status_type) return Boolean is
     (if Integer(Current_status.Angle_measured) > Minimum_viable_angle_of_attack and 
          Integer(Current_status.Angle_measured) < Maximum_viable_angle_of_attack then 
           Current_status.Launch_status = Nominal else
              Current_status.Launch_status = Not_Nominal);
   
   procedure monitor_course with
     Global => (In_Out => Rocket_launch_status),
     Depends => (Rocket_launch_Status => Rocket_launch_Status),
     Post => (is_launch_nominal(Rocket_launch_Status) = False or is_launch_nominal(Rocket_launch_Status) = True);
   
   procedure correct_course with
     Global => (In_Out => (Standard_Output, Rocket_launch_Status)),
     Depends => (Standard_Output => (Standard_Output, Rocket_launch_Status),
                 Rocket_launch_Status => (Rocket_launch_Status)),
       Pre => (Rocket_launch_Status.Angle_measured >= Minimum_angle and Rocket_launch_Status.Angle_measured <= Maximum_angle),
     Post => (is_launch_nominal(Rocket_launch_Status) = False or is_launch_nominal(Rocket_launch_Status) = True);
   
   
   procedure init with
     Global => (Output => (Standard_Output, Standard_Input, Rocket_launch_Status)),
     Depends => ((Standard_Output, Standard_Input, Rocket_launch_Status) => null),
       Post => is_launch_nominal(Rocket_launch_Status);
end rocket_launch;
