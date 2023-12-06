pragma SPARK_Mode (On);

with rocket_launch; use rocket_launch;

procedure Main is

begin
   init;
   loop
      pragma Loop_Invariant (is_launch_nominal(Rocket_launch_Status));
      if (Rocket_launch_Status.Launch_status = Nominal) then
         Get_windspeed;
         monitor_course;
         print_status;
      end if;
   end loop;
end Main;
