/// @description Used when setting an array of variables for the Decorative Button

// Inherit the parent event
event_inherited();


#region Local Beginning Exceptions
for (var i = 0, n = array_length(user_event_variable4_name); i < n; i++)
{
	if (user_event_variable4_name[i] == "CTRL_Value")
	{
		show_debug_message("The Decorative Button's value is always false!")
		CTRL_Value = false;
		CTRL_Text = "false";
	}
	else if (user_event_variable4_name[i] == "CTRL_Text")
	{
		show_debug_message("The Decorative Button's text is always \"false\"!")
		CTRL_Value = false;
		CTRL_Text = "false";
	}
}
#endregion

//Garbage Collect To Reset This Control
clean_up_DecorativeButton(id);

//Reset data structure for this control
struct_decorativeButton = new basic_DecorativeButton_Componets(id);
CommandButton_Design(struct_decorativeButton);

//Reset the following variables
//Note: Timers and shaders DO NOT reset!

//Reset bounds
control_bounds_xx1 = struct_decorativeButton.xx1;
control_bounds_yy1 = struct_decorativeButton.yy1;
control_bounds_xx2 = struct_decorativeButton.xx2;
control_bounds_yy2 = struct_decorativeButton.yy2;

//Operation
private_CommandButton_Update_Clickable_Regions(struct_decorativeButton);

//Finish Up
//Reset captions if they use the CONTROL_AUTO_CAPTION string
Controls_Reset_Captions_Sub_Struct(struct_decorativeButton);
//If the caption must be reset, re-run any bounds and vertex functions
event_user(ENUM_Control_User_Events.caption_auto_size);

#region Local Ending Exceptions
/*None*/
#endregion

//appear pressed?
Control_Set_CommandButton_Vertices(struct_decorativeButton, struct_decorativeButton, COMMANDBUTTON_ARRAY_V_BUFFER_INDICES, Appear_Pressed, Press_Type);