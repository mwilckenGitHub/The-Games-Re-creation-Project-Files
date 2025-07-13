/// @description Runs after vairable(s) set by Controls_Set_Control_Variables_By_id()
//Inherit this event

//Set Event
CTRL_Event_Type = event_type;
CTRL_Event_Number = event_number;

//Error check
//iterate arrays
var widthIndex = undefined, heightIndex = undefined;
for (var i = 0, n = array_length(user_event_variable4_name); i < n; i++)
{
	/**
	* Initially set value and check if it can be used
	* Once value has been confirmed, reset in case it had to be changed
	*/
	
#region Exceptions BEFORE setting variable
	/**
	* These exceptions apply ONLY to certain variable resets
	*/
#endregion
					
	//Initally Set the new value to its variable
	try{variable_instance_set(id,user_event_variable4_name[i],user_event_variable4[i]);}
	catch(e){show_message(e);}

#region Exceptions AFTER setting variable
	/**
	* These exceptions apply ONLY to certain variable resets
	*/

	//--Unchanging value(s)--
	//backgrounds CANNOT be changed to foregrounds and vice versa
	if (user_event_variable4_name[i] == "CTRL_Is_Background")
	{CTRL_Is_Background = private_control_is_background;}
	
	//--Changeable value(s)--
	//Renaming control
	if (user_event_variable4_name[i] == "CTRL_Name" || user_event_variable4_name[i] == "CTRL_Instance")
	{Control_Rename(previous_control_name, CTRL_Name, true);}

	//Depth
	if (user_event_variable4_name[i] == "CTRL_Depth" || user_event_variable4_name[i] == "depth")
	{control_depth_updated = false; Controls_Set_Depth();}
	
	//image_x or y_scale
	//Set width and height indices
	widthIndex = user_event_variable4_name[i] == "image_xscale" ? i : widthIndex;
	special_image_xscale_value = user_event_variable4_name[i] == "image_xscale" ? user_event_variable4[i] : special_image_xscale_value;
	heightIndex = user_event_variable4_name[i] == "image_yscale" ? i : heightIndex;
	special_image_yscale_value = user_event_variable4_name[i] == "image_yscale" ? user_event_variable4[i] : special_image_yscale_value;

#endregion
}


#region Exceptions outside of counter
/**
* These exceptions apply ONLY to certain variable resets OUTSIDE the counter
*/

//Image Scale
//Note: Get these variables inside the counter
if (!is_undefined(widthIndex) || !is_undefined(heightIndex))
{Controls_Resize_Control(id, special_image_xscale_value * sprite_get_width(sprite_index), special_image_yscale_value * sprite_get_height(sprite_index));}

#endregion