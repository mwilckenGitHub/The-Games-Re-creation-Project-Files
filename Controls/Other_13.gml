/// @description Runs after vairable set by Controls_Set_Control_Variable_By_id()
//Inherit this event

//Set Event
CTRL_Event_Type = event_type;
CTRL_Event_Number = event_number;

#region Exceptions BEFORE setting variable
/**
* These exceptions apply ONLY to certain variable resets
*/
/**/
#endregion

//Set the variable as entered in Controls_Set_Control_Variable_By_id()
variable_instance_set(id, user_event_variable3_name,user_event_variable3);

#region Exceptions AFTER setting variable
/**
* These exceptions apply ONLY to certain variable resets
*/

//Unchanging value(s)
//backgrounds CANNOT be changed to foregrounds and vice versa
if (user_event_variable3_name == "CTRL_Is_Background")
{CTRL_Is_Background = private_control_is_background;}

//Changeable value(s)
//Renaming control
if (user_event_variable3_name == "CTRL_Name" || user_event_variable3_name == "CTRL_Instance")
{Control_Rename(previous_control_name, CTRL_Name, true);}

//Depth
if (user_event_variable3_name == "CTRL_Depth" || user_event_variable3_name == "depth")
{control_depth_updated = false; Controls_Set_Depth();}

//Image scale
//image_x or y_scale
//Set width and height indices
special_image_xscale_value = user_event_variable3_name == "image_xscale" ? user_event_variable3 : special_image_xscale_value;
special_image_yscale_value = user_event_variable3_name == "image_yscale" ? user_event_variable3 : special_image_yscale_value;
//Image Scale
//Note: Get these variables inside the counter
if (user_event_variable3_name == "image_xscale" || user_event_variable3_name == "image_yscale")
{Controls_Resize_Control(id, special_image_xscale_value * sprite_get_width(sprite_index),special_image_yscale_value * sprite_get_height(sprite_index));}
#endregion