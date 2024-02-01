This system is designed to be a very basic rocket launch simulation, which tells the user whether, given inputs of a target distance between 1000 and 5000KM, and the fuel loads for stages 1, 2 and 3 of the rocket (between 0 and 5000L per stage), the rocket will reach the target distance. The system does this by:
1.	Changing the status of the current stage (initially stage 1) from Idle to Firing.
2.	Calculate the distance travelled using the fuel stored by the current stage (distance = fuel load / 2) and change the status of the current stage to Out_Of_Fuel.
3.	Update the rocket’s current distance and checks whether this is greater than or equal to the target distance.
4.	If it is, then we report a mission success via the console, otherwise, we change the isJettisoned attribute of the current stage from False (initial value) to True. This represents the stage being jettisoned from the rest of the rocket.
5.	We repeat steps 1 to 3 for stages 2 and 3. If after stage 3 has fired we have not met the target distance, we report a mission failure to the console, but do not jettison stage 3 (as we cannot jettison the only stage remaining).
Keeping in mind that we want to ensure that all available fuel is used up, and that we don’t want to jettison a stage before the previous stage has been jettisoned, we check that the current stage can only be jettisoned if the current stage’s status is Out_Of_Fuel, and that stage 2 can only be jettisoned if stage 1 has already been jettisoned. 
