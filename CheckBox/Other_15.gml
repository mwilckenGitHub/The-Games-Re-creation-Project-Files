/// @description Used when resizing the Checkbox

// Inherit the parent event
event_inherited();

#region Local Beginning Exceptions

//Was auto-sizing used?
//display error message in debug window
if (struct_checkBox.auto_size)
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
clean_up_Checkbox(id);

//Reset data structure for this control
struct_checkBox = new basic_Checkbox_Componets(id);
Checkbox_Design(struct_checkBox);

//Reset the following variables
//Note: Timers and shaders DO NOT reset!

//Reset bounds
control_bounds_xx1 = struct_checkBox.xx1;
control_bounds_yy1 = struct_checkBox.yy1;
control_bounds_xx2 = struct_checkBox.xx2;
control_bounds_yy2 = struct_checkBox.yy2;


//Update matrix
control_matrix = matrix_build(x+lengthdir_x(0, image_angle),y+lengthdir_y(0, image_angle),0,0,0,image_angle,1,1,1);

//Finish Up
//Reset captions if they use the CONTROL_AUTO_CAPTION string
Controls_Reset_Captions_Sub_Struct(struct_checkBox);
//If the caption must be reset, re-run any bounds and vertex functions
event_user(ENUM_Control_User_Events.caption_auto_size);

#region Local Ending Exceptions
/**/
#endregion