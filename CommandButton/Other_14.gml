/// @description Used when setting an array of variables for the CommandButton

// Inherit the parent event
event_inherited();


#region Local Beginning Exceptions
for (var i = 0, n = array_length(user_event_variable4_name); i < n; i++)
{
	if (user_event_variable4_name[i] == "CTRL_Value")
	{
		//set CTRL_Text = CTRL_Value
		if (bool(CTRL_Value) == true) {CTRL_Text = "true";}
		else {CTRL_Value = false; CTRL_Text = "false";}
	}
	else if (user_event_variable4_name[i] == "CTRL_Text")
	{
		//set CTRL_Value = bool(CTRL_Text)
		if (string_lower(CTRL_Text) == "true") {CTRL_Value = true;}
		else {CTRL_Value = false; CTRL_Text = "false";}
	}
}
#endregion

//Garbage Collect To Reset This Control
clean_up_CommandButton(id);

//Reset data structure for this control
struct_commandButton = new basic_CommandButton_Componets(id);
CommandButton_Design(struct_commandButton);

//Reset the following variables
//Note: Timers and shaders DO NOT reset!

//Reset bounds
control_bounds_xx1 = struct_commandButton.xx1;
control_bounds_yy1 = struct_commandButton.yy1;
control_bounds_xx2 = struct_commandButton.xx2;
control_bounds_yy2 = struct_commandButton.yy2;

//Operation
private_CommandButton_Update_Clickable_Regions(struct_commandButton);

//Finish Up
//Reset captions if they use the CONTROL_AUTO_CAPTION string
Controls_Reset_Captions_Sub_Struct(struct_commandButton);
//If the caption must be reset, re-run any bounds and vertex functions
event_user(ENUM_Control_User_Events.caption_auto_size);

#region Local Ending Exceptions

for (var i = 0, n = array_length(user_event_variable4_name); i < n; i++)
{
	//Briefly "presses" the button
	//If you require a press-and-hold behavior, consider instantiating a Toggle Button
	//We recommend against setting CTRL_Value or CTRL_Text in event 3 or 4
	if (CTRL_Value)
	{event_user(ENUM_Control_User_Events.basic_interaction);}
	else
	{event_user(ENUM_Control_User_Events.end_interaction);}
}
#endregion