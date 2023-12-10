pragma SPARK_Mode (On);

with rocket_launch; use rocket_launch;

procedure Main is

begin
   init;
   loop
      pragma Loop_Invariant (get_mission_status(Rocket));
      if (Rocket.status = Nominal) then
         Get_target_distance;
         Get_stage_fuel(Rocket.stage1);
         Get_stage_fuel(Rocket.stage2);
         Get_stage_fuel(Rocket.stage3);
         Launch_rocket(Rocket);
         Check_launch(Rocket);
      end if;
   end loop;
end Main;
