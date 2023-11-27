pragma SPARK_Mode (On);

with rocket_launch; use rocket_launch;

procedure Main is

begin
   init;
   loop
      pragma Loop_Invariant (is_launch_nominal(Rocket_launch_Status));
      Read_Current_Angle;
      monitor_course;
      print_status;
   end loop;
end Main;
