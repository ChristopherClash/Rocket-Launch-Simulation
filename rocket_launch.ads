pragma SPARK_Mode (On);

with SPARK.Text_IO; use SPARK.Text_IO;

-- This file was created by Christopher Clash

-- It is a simple example of a rocket launch system,
-- it monitors the angle of attack and remaining fuel of the rocket, with the rocket's angle being changed during flight.

-- The windspeed is a random integer between 1-99 (KM/h),
-- the weight of the rocket is 100KG (for simplicity),
-- the target distance is 1000KM (this is represented as minimum required fuel, where 2 units of fuel = 1km travelled).

-- The angle changed is a function of the total weight of the rocket and the windspeed,
-- the function is ((360 * Windspeed) / Weight_of_rocket) - this is made up, but works well enough for our simulation,
-- as it prevents a situation where the angle changed > 359

-- If the rocket's angle goes outside the acceptable angle of attack range, 
-- corrective action is taken to bring the rocket back to an angle of attack of 90 degrees.

-- However, correcting course uses the limited fuel the rocket has (enough to travel 1.2x the distance),
-- if the rocket runs out of fuel the launch fails.

package rocket_launch is

   Maximum_angle : constant Integer := 359;
   Minimum_angle : constant Integer := 0;
   Maximum_viable_angle_of_attack : constant Integer := 110;
   Minimum_viable_angle_of_attack : constant Integer := 70;
   Maximum_fuel_load : constant Integer := 2400;
   Minimum_required_fuel : constant Integer := 1000;
   Weight_of_rocket : constant Integer := 100;
   Maximum_windspeed : constant Integer := 99;
   Minimum_windspeed : constant Integer := 1;
  
 
   subtype Current_Fuel_load is Integer range 0 .. Maximum_fuel_load;
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
   
   procedure Get_windspeed with
     Global => (In_Out => (Rocket_launch_Status, Standard_Input), Output => Standard_Output),
     Depends => (Standard_Output => (Rocket_launch_Status, Standard_Input), Standard_Input => Standard_Input, 
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
          Integer(Current_status.Angle_measured) < Maximum_viable_angle_of_attack and 
          Current_status.Current_fuel > Minimum_required_fuel then 
           Current_status.Launch_status = Nominal else
              Current_status.Launch_status = Not_Nominal);
   
   function Calculate_new_angle(Wind_speed, Weight_of_rocket : Integer) return angle_range is
      (Integer(360 * Wind_speed) / Weight_of_rocket) with
     Pre => (Wind_speed >= Minimum_windspeed and Wind_speed <= Maximum_windspeed and Weight_of_rocket >= Wind_speed and Weight_of_rocket = 100),
     Post => Calculate_new_angle'Result >= Minimum_angle and Calculate_new_angle'Result <= Maximum_angle;
   
   function Enough_fuel(Current_Fuel_load : Integer) return Boolean is
      (Current_Fuel_load < Minimum_required_fuel) with
     Pre => (Current_Fuel_load <= Maximum_fuel_load);

   
   procedure monitor_course with
     Global => (In_Out => Rocket_launch_status),
     Depends => (Rocket_launch_Status => Rocket_launch_Status),
     Post => (is_launch_nominal(Rocket_launch_Status) = False or is_launch_nominal(Rocket_launch_Status) = True);
   
   procedure correct_course with
     Global => (In_Out => (Rocket_launch_Status), Output => Standard_Output),
     Depends => (Rocket_launch_Status => Rocket_launch_Status, Standard_Output => Rocket_launch_Status),
     Pre => (Rocket_launch_Status.Angle_measured >= Minimum_angle and Rocket_launch_Status.Angle_measured <= Maximum_angle),
     Post => ((is_launch_nominal(Rocket_launch_Status) = False or (is_launch_nominal(Rocket_launch_Status) = True)));
   
   
   procedure init with
     Global => (Output => (Standard_Output, Standard_Input, Rocket_launch_Status)),
     Depends => ((Standard_Output, Standard_Input, Rocket_launch_Status) => null),
       Post => is_launch_nominal(Rocket_launch_Status);
end rocket_launch;
