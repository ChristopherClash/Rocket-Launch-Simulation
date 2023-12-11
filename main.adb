pragma SPARK_Mode (On);

with rocket_control; use rocket_control;

procedure Main is
   Mission_Finished : Boolean := False;
begin
   Init;
   loop
      pragma Loop_Invariant (Get_Mission_Status(Rocket));
      if not (Mission_Finished) then
         Get_Target_Distance;
         Get_Stage_Fuel(Rocket.Stage1);
         Get_Stage_Fuel(Rocket.Stage2);
         Get_Stage_Fuel(Rocket.Stage3);
         Launch_Rocket_And_Check_Distance(Rocket, Mission_Finished);
      Check_Launch(Rocket);
      end if;
   end loop;
end Main;
