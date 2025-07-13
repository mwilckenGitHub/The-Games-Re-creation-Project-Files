/// @description Performs a Checkbox Press
// Used for button presses where focus is not required
// Inherit the parent event
event_inherited();

//"Press" and "Release" the checkbox to perform its full cycle
Checkbox_Event_Perform_Click(CTRL_ID,false,false);
Checkbox_Event_End_Click(CTRL_ID,false,false);