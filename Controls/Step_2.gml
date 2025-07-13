/// @description Ensures current and previous names and instance numbers match

CTRL_Event_Type = event_type;
CTRL_Event_Number = event_number;

//Previous Name
previous_control_name = CTRL_Name;
previous_control_instance = CTRL_Instance;

//Previous Depth
previous_control_depth = CTRL_Depth;

#region Reset errors

//Type errors
if (CTRL_Type == object_index && CTRL_Is_Background == private_control_is_background)
{a_type_error_occurred = false;}

//Naming errors
if (CTRL_ID == id && CTRL_TypeName == object_get_name(object_index) && current_control_name == previous_control_name && current_control_instance == previous_control_instance)
{a_naming_error_occurred = false;}

//Depth errors
if (CTRL_ID == id && current_control_depth == previous_control_depth)
{a_depth_error_occurred = false;}


#endregion

//Reset whether list of current controls is obtained
global.list_current_controls_obtained = false;
global.list_current_controls_obtained_controls_positions_obtained = false;

//tool-tip
global.tooltip_reset_this_cycle = false;

if (global.control_with_focus_acquired)
{
	//Get prior control id with focus
	global.control_with_focus_previous = global.control_with_focus;
	//reset current
	global.control_with_focus = noone;
	global.control_with_focus_acquired = false;
}

//Reset control mouse position and focus for this step
if (global.control_mouse_data_acquired)
{
	global.control_mouse_data_acquired = false;
	global.control_with_mouse_over_focus_acquired = false;
	global.control_with_useable_focus_acquired = false;
	global.control_with_optional_focus_acquired = false;
	
	//Get prior mouse focus data
	global.control_with_mouse_over_focus_previous = global.control_with_mouse_over_focus;
	
	//Get prior usable and optional focus
	global.control_with_useable_focus_previous = global.control_with_useable_focus;
	global.control_with_optional_focus_previous = global.control_with_optional_focus;
}

//Mouse enter/leave
global.control_mouse_enter_event_performed_this_step		= false;
global.control_mouse_leave_event_performed_this_step		= false;

//Reset control mouse cursor
if (global.control_current_os_mouse_cursor_obtained)
{
	global.control_current_os_mouse_cursor = cr_default;
	global.control_current_os_mouse_cursor_obtained = false;
}/**/

//reset the tab stop selection
if (global.grid_of_quick_actions_current_tab_stop_selection_performed_this_step)
{global.grid_of_quick_actions_current_tab_stop_selection_performed_this_step = false;}

//reset the ability to dismiss all focus
if (global.control_dismiss_all_focus_performed_this_step)
{global.control_dismiss_all_focus_performed_this_step = false;}

//Keyboard Keys
if (global.list_of_concurrent_keys_being_pressed_obtained)
{global.list_of_concurrent_keys_being_pressed_obtained = false;}

//Accelerator Keys
//Reset the control associated with the concurrent accelerator keys
if (global.accelerator_keys_control_id != global.control_with_useable_focus)
{
	if (global.accelerator_keys_control_id != noone)
	{
		//reset key press to key check
		with (global.accelerator_keys_control_id)
		{
			control_shader_OnLeftClick = noone;
			control_shader_has_focus = noone;
			control_using_shader_has_focus = false;
			control_accelerator_keys_pressed  = false;
			control_accelerator_keys_checked  = false;
			control_accelerator_keys_released = false;
		}
		global.accelerator_keys_control_id = noone;
	}
}
//Set previous concurrent keys list to current concurrent keys list
ds_list_copy(global.list_of_previous_concurrent_keys_being_pressed, global.list_of_current_concurrent_keys_being_pressed);