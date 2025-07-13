/// @description Used when resizing the CommandButton

// Inherit the parent event
event_inherited();

#region Local Beginning Exceptions

//Was auto-sizing used?
//display error message in debug window
if (struct_commandButton.auto_size)
{
	show_debug_message(user_event_error_message_intro + "We're sorry, but we cannot resize the \"" + object_get_name(object_index) + "\" if auto-size used!\r\nDisable auto-sizing!");
	image_xscale = autoSized_image_xscale;
	image_yscale = autoSized_image_yscale;
	exit;
}

#endregion

//sets x and y to the new fixed point
x = control_fixed_point_x + round(min(0,user_event_variable5[0]));
y = control_fixed_point_y + round(min(0,user_event_variable5[1]));

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

//Update matrix
control_matrix = matrix_build(x+lengthdir_x(0, image_angle),y+lengthdir_y(0, image_angle),0,0,0,image_angle,1,1,1);

//Finish Up
//Reset captions if they use the CONTROL_AUTO_CAPTION string
Controls_Reset_Captions_Sub_Struct(struct_commandButton);
//If the caption must be reset, re-run any bounds and vertex functions
event_user(ENUM_Control_User_Events.caption_auto_size);

#region Local Ending Exceptions
//Briefly "presses" the button
//If you require a press-and-hold behavior, consider instantiating a Toggle Button
if (CTRL_Value)
{event_user(ENUM_Control_User_Events.basic_interaction);}
else
{event_user(ENUM_Control_User_Events.end_interaction);}
#endregion