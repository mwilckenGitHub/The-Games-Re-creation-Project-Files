/// @description Updates mouse position values, sets maxtrix, and error checking

//Get all controls currently instantiated
if (!global.list_current_controls_obtained)
{
	array_to_ds_list(Controls_Get_Controls_Any(),global.list_current_controls,true);
	global.list_current_controls_obtained = true;
}

//Get global control with focus
if (!global.control_with_focus_acquired && CTRL_Focus)
{
	global.control_with_focus = CTRL_Focus;
	global.control_with_focus_acquired = true;
}

//Get global mouse data
if (!global.control_mouse_data_acquired)
{
	//Set type of mouse interaction
	global.control_mouse_left_pressed		= mouse_check_button_pressed(mb_left);
	global.control_mouse_left_checked		= mouse_check_button(mb_left);
	global.control_mouse_left_released		= mouse_check_button_released(mb_left);
	global.control_mouse_right_pressed		= mouse_check_button_pressed(mb_right);
	global.control_mouse_right_checked		= mouse_check_button(mb_right);
	global.control_mouse_right_released		= mouse_check_button_released(mb_right);
	global.control_mouse_middle_pressed		= mouse_check_button_pressed(mb_middle);
	global.control_mouse_middle_checked		= mouse_check_button(mb_middle);
	global.control_mouse_middle_released	= mouse_check_button_released(mb_middle);
	
	//Reset mouse cursor position
	global.control_room_mouse_x = mouse_x;
	global.control_room_mouse_y = mouse_y;
	global.control_window_mouse_x = device_mouse_x_to_gui(0);
	global.control_window_mouse_y = device_mouse_y_to_gui(0);
		
	#region Deprecated Window x,y getter (11/24/2023)
	//global.control_window_mouse_x = round(!is_infinity(window_mouse_get_x()/window_get_width())  && !is_nan(window_mouse_get_x()/window_get_width())  ? ((window_mouse_get_x()/window_get_width())  * display_get_gui_width())  : global.control_room_mouse_x);
	//global.control_window_mouse_y = round(!is_infinity(window_mouse_get_y()/window_get_height()) && !is_nan(window_mouse_get_y()/window_get_height()) ? ((window_mouse_get_y()/window_get_height()) * display_get_gui_height()) : global.control_room_mouse_y);
	#endregion
	
	global.control_mouse_data_acquired = true;
}

//Get all mouse positions for all controls in one cycle
if (!global.list_current_controls_obtained_controls_positions_obtained)
{
	for (var ctrl = 0, num_ctrls = ds_list_size(global.list_current_controls); ctrl < num_ctrls; ctrl++)
	{
		with(global.list_current_controls[|ctrl])
		{
			//image_angle+=choose(ctrl+2,ctrl-2);
			//get mouse position amd matrix rotation (works with 2D only)
			/**
			* !!USE THESE VALUES TO GET THE PROPER MOUSE POSITION FOR THIS CONTROL!!
			* mouse_x, mouse_y, etc. won't quite fit the bill as the window position must be taken into account
			* GUI uses window mouse positions
			* NORMAL uses mouse_x and mouse_y
			*/
			//Get matrix for rotations of control
			control_matrix = matrix_build(x,y,0,0,0,image_angle,1.0,1.0,1.0);

			//default to giving mouse coordiantes via the gui mouse position
			control_relative_mouse_x = global.control_window_mouse_x;
			control_relative_mouse_y = global.control_window_mouse_y;
			//Else there might be a non-GUI draw event being used (not recommended but available)
			if (CTRL_Draw_Event_Used == DRAW_NORMAL_END
			 || CTRL_Draw_Event_Used == DRAW_NORMAL_OTHER_POST
			 || CTRL_Draw_Event_Used == DRAW_NORMAL_OTHER_END 
			 || CTRL_Draw_Event_Used == DRAW_NORMAL_OTHER_NORMAL
			 || CTRL_Draw_Event_Used == DRAW_NORMAL_OTHER_BEGIN 
			 || CTRL_Draw_Event_Used == DRAW_NORMAL_OTHER_PRE)
			{
				control_relative_mouse_x = global.control_room_mouse_x;
				control_relative_mouse_y = global.control_room_mouse_y;
			}
			
			//Set abosolute mouse coordiantes
			control_absolute_mouse_x = control_relative_mouse_x;
			control_absolute_mouse_y = control_relative_mouse_y;
			
			//Adjust for any offsets
			if (control_drawn_to_surface)
			{
				/**
				* Is the control being rendered to a surface other than the application surface?
				* If so, this begin step is run again TODO: (need function name) again to offset the mouse cursor position. This
				* allows for acurate interaction with a control rendered in a surface whose origin is not (0,0)
				*/
				//Note: These offset values must always be subtracted due to how surfaces work
				control_relative_mouse_x -= control_drawn_to_surface_offset_x;
				control_relative_mouse_y -= control_drawn_to_surface_offset_y;
				
				//Get length and angle to mouse cursor position
				var len_to_cursor = point_distance( 0,0,control_relative_mouse_x,control_relative_mouse_y);
				var ang_to_cursor = point_direction(0,0,control_relative_mouse_x,control_relative_mouse_y);
				control_relative_mouse_x = lengthdir_x(len_to_cursor,ang_to_cursor+control_drawn_to_surface_absolute_image_angle);
				control_relative_mouse_y = lengthdir_y(len_to_cursor,ang_to_cursor+control_drawn_to_surface_absolute_image_angle);/**/
				
				//add surface part offset
				control_relative_mouse_x += control_drawn_to_surface_draw_surface_part_left;
				control_relative_mouse_y += control_drawn_to_surface_draw_surface_part_top;
				
				//adjust per given scale
				control_relative_mouse_x /= control_drawn_to_surface_absolute_scale_x;
				control_relative_mouse_y /= control_drawn_to_surface_absolute_scale_y;
				
				//Cursor lies within this surface?
				//Uses counter-clockwise winding order
				//FUTURE TODO:
				//control_drawn_to_surface_tri1 = point_in_triangle(	control_relative_mouse_x,
				//													control_relative_mouse_y,
				//													control_drawn_to_surface_selectable_bounds_left,
				//													control_drawn_to_surface_selectable_bounds_top,
				//													control_drawn_to_surface_selectable_bounds_left,
				//													control_drawn_to_surface_selectable_bounds_bottom,
				//													control_drawn_to_surface_selectable_bounds_right,
				//													control_drawn_to_surface_selectable_bounds_top);
				//control_drawn_to_surface_tri2 = point_in_triangle(	control_relative_mouse_x,
				//													control_relative_mouse_y,
				//													control_drawn_to_surface_selectable_bounds_right,
				//													control_drawn_to_surface_selectable_bounds_top,
				//													control_drawn_to_surface_selectable_bounds_left,
				//													control_drawn_to_surface_selectable_bounds_bottom,
				//													control_drawn_to_surface_selectable_bounds_right,
				//													control_drawn_to_surface_selectable_bounds_bottom);
			}

			//Build the new matrix
			control_matrix_projection_build = matrix_build_projection_ortho(window_get_width(),window_get_height(),GML_NEAREST_DEPTH,GML_FURTHEST_DEPTH);
			control_projected_matrix = window_get_xy_2d_ray_to_3d_world_space(control_relative_mouse_x, control_relative_mouse_y, control_matrix, control_matrix_projection_build);

			//get projected mouse positions based on the matrix
			projected_control_mouse_x = control_projected_matrix[ENUM_Cursor_Point_To_World_Space_Projection_Ray.ox];
			projected_control_mouse_y = control_projected_matrix[ENUM_Cursor_Point_To_World_Space_Projection_Ray.oy];
		}
	}
	global.list_current_controls_obtained_controls_positions_obtained = true;
}

#region MOUSE AND KEYBOARD INTERACTIONS

#region MOUSE CURSOR
//If window-based mouse position lies within scope of control
//OnEnter (And interactions)
//FUTURE_TODO: Add Gestures
//Note: CTRL_Sound_OnEnter and OnLeave have been moved to the Mouse Enter and Leave events
//Note: This method IS CORRECT for obtaining current control with mouse hover or other active hover control getter.
if (private_Control_Parent_BeginStep_Determine_MouseOver())
{
	//Get mouse-over focus (hover)
	if (!global.control_mouse_enter_event_performed_this_step)
	{		
		private_Controls_Mimic_Mouse_Enter_Leave();
		global.control_mouse_enter_event_performed_this_step = true;
	}
	
	control_mouseOver = true;
	
	//obtain left-click pseudo focus
	if (global.control_mouse_left_pressed)
	{control_leftClick_pseudo_focus = true;}
	//obtain right-click pseudo focus
	if (global.control_mouse_right_pressed)
	{control_rightClick_pseudo_focus = true;}
	
	//Play OnEnter audio
	if (CTRL_Sound_OnEnter_OnLeave_Plays_On == BOUNDS)
	{
		if (audio_exists(CTRL_Sound_OnEnter)
			&& !OnEnter_audio_has_played
			&& OnLeave_audio_has_played)
		{
			audio_play_sound(CTRL_Sound_OnEnter,1,false);
			OnEnter_audio_has_played = true;
			OnLeave_audio_has_played = false;
		}
	}
	else if (CTRL_Sound_OnEnter_OnLeave_Plays_On == FOCUS)
	{
		if (id == global.control_with_mouse_over_focus)
		{
			if (audio_exists(CTRL_Sound_OnEnter)
				&& !OnEnter_audio_has_played
				&& OnLeave_audio_has_played)
			{
				audio_play_sound(CTRL_Sound_OnEnter,1,false);
				OnEnter_audio_has_played = true;
				OnLeave_audio_has_played = false;
			}
		}
		//Play OnLeave audio if using focus mode
		else if (id != global.control_with_mouse_over_focus)
		{
			if (audio_exists(CTRL_Sound_OnLeave)
				&& OnEnter_audio_has_played
				&& !OnLeave_audio_has_played)
			{
				audio_play_sound(CTRL_Sound_OnLeave,1,false);
				OnEnter_audio_has_played = false;
				OnLeave_audio_has_played = true;
			}
		}
	}
	
	//Mouse-over Shader and tool-tip prep
	if (global.control_with_mouse_over_focus == CTRL_ID)
	{
		control_shader_hover = CTRL_Shader_Hover;
		
		//Engage tooltip timer
		//Note: Tooltip timer and other tooltip values are reset in the mouseEnter and mouseLeave events.
		//A tooltip should reset if cursor has left mouse-over focus
		global.struct_toolTip.display_timer += delta_time/1000000;
		global.struct_toolTip.display_timer = clamp(global.struct_toolTip.display_timer,0,TOOL_TIP_DISPLAY_TIME+TOOL_TIP_TIMER_MOUSEOVER_DELAY+1);
		
		global.struct_toolTip.str = CTRL_ToolTip;
		
		if (global.struct_toolTip.display_timer >= TOOL_TIP_TIMER_MOUSEOVER_DELAY && (global.struct_toolTip.display_timer - TOOL_TIP_TIMER_MOUSEOVER_DELAY) <= TOOL_TIP_DISPLAY_TIME
				|| global.struct_toolTip.stupidly_large_tool_tip_mode)
		{
			global.struct_toolTip.can_display							= true;
			if (!global.struct_toolTip.setup_operation_performed_and_set || global.struct_toolTip.stupidly_large_tool_tip_mode)
			{
				//Setup
				global.struct_toolTip.calling_instance					= CTRL_ID;
				global.struct_toolTip.cursor_x							= global.control_window_mouse_x;
				global.struct_toolTip.cursor_y							= global.control_window_mouse_y;
				
				//Calling control
				global.struct_toolTip.control_matrix					= control_matrix;
				global.struct_toolTip.control_x							= x;
				global.struct_toolTip.control_y							= y;
				global.struct_toolTip.control_width						= sprite_width - sprite_xoffset;
				global.struct_toolTip.control_height					= sprite_height - sprite_yoffset;
				
				//Font and border related
				global.struct_toolTip.str_width							= string_width(global.struct_toolTip.str);
				global.struct_toolTip.str_height						= string_height(global.struct_toolTip.str);
				global.struct_toolTip.str_font							= CTRL_ToolTip_Font;
				global.struct_toolTip.str_font_color					= CTRL_ToolTip_Font_Color;
				global.struct_toolTip.str_hAlign						= CTRL_ToolTip_HAlign;
				global.struct_toolTip.str_vAlign						= CTRL_ToolTip_VAlign;
				global.struct_toolTip.rect_background_color				= CTRL_ToolTip_Background_Color;
				global.struct_toolTip.rect_border_color					= CTRL_ToolTip_Border_Color;
			}
		}
		else
		{	global.struct_toolTip.can_display							= false;}
		
#region Mouse Curosr
		//Uses a custom mouse cursor?
		//Note: this is NOT the same as the standard os mouse cursor!
		global.control_current_mouse_cursor = CTRL_Mouse_Cursor;
		global.control_can_display_custom_mouse_cursor = true;
		
		/**
		* OS Mouse cursor changes
		* reports back suggestions for use of certain os mouse cursors
		* for a list of os mouse cursors available in Windows and changable with Game Maker: Studio:
		* @see "https://manual.yoyogames.com/GameMaker_Language/GML_Reference/Cameras_And_Display/The_Game_Window/window_set_cursor.htm"
		* Note: These suggestions apply ONLY to the edge of the control with focus
		* 
		* !!Note: the global for the control's os mouse cursor is a suggestion as is NOT set by Controls!!
		* use window_set_cursor(global.control_current_os_mouse_cursor) in a different object!!
		*/
		//Get current os mouse cursor to use
		if (!global.control_current_os_mouse_cursor_obtained)
		{
			//cursor is along the right edge of the control
			//mouse cursor is within OS_MOUSE_CURSOR_PADDING padding from:
			
			//upper-left edge
			//(intended to be the move location, hence use of cardinal cursor)
			if (control_relative_mouse_x >= bbox_left && control_relative_mouse_x <= bbox_left + OS_MOUSE_CURSOR_PADDING
				&& control_relative_mouse_y >= bbox_top && control_relative_mouse_y <= bbox_top + OS_MOUSE_CURSOR_PADDING)
			{
				global.control_current_os_mouse_cursor = cr_size_all;
			}
			//top-center
			else if (control_relative_mouse_x > bbox_left + OS_MOUSE_CURSOR_PADDING && control_relative_mouse_x < bbox_right - OS_MOUSE_CURSOR_PADDING
				&& control_relative_mouse_y >= bbox_top && control_relative_mouse_y <= bbox_top + OS_MOUSE_CURSOR_PADDING)
			{global.control_current_os_mouse_cursor = cr_size_ns;}
			//upper-right
			else if (control_relative_mouse_x >= bbox_right - OS_MOUSE_CURSOR_PADDING && control_relative_mouse_x <= bbox_right
				&& control_relative_mouse_y >= bbox_top && control_relative_mouse_y <= bbox_top + OS_MOUSE_CURSOR_PADDING)
			{global.control_current_os_mouse_cursor = cr_size_nesw;}
			//right-center
			else if (control_relative_mouse_x >= bbox_right - OS_MOUSE_CURSOR_PADDING && control_relative_mouse_x <= bbox_right 
				&& control_relative_mouse_y > bbox_top + OS_MOUSE_CURSOR_PADDING && control_relative_mouse_y < bbox_bottom - OS_MOUSE_CURSOR_PADDING)
			{global.control_current_os_mouse_cursor = cr_size_we;}
			//lower-right
			else if (control_relative_mouse_x >= bbox_right - OS_MOUSE_CURSOR_PADDING && control_relative_mouse_x <= bbox_right
				&& control_relative_mouse_y >= bbox_bottom - OS_MOUSE_CURSOR_PADDING && control_relative_mouse_y <= bbox_bottom)
			{global.control_current_os_mouse_cursor = cr_size_nwse;}
			//bottom-center
			else if (control_relative_mouse_x > bbox_left + OS_MOUSE_CURSOR_PADDING && control_relative_mouse_x < bbox_right - OS_MOUSE_CURSOR_PADDING
				&& control_relative_mouse_y >= bbox_bottom - OS_MOUSE_CURSOR_PADDING && control_relative_mouse_y <= bbox_bottom)
			{global.control_current_os_mouse_cursor = cr_size_ns;}
			//lower-left
			else if (control_relative_mouse_x >= bbox_left && control_relative_mouse_x <= bbox_left + OS_MOUSE_CURSOR_PADDING
				&& control_relative_mouse_y >= bbox_bottom - OS_MOUSE_CURSOR_PADDING && control_relative_mouse_y <= bbox_bottom)
			{global.control_current_os_mouse_cursor = cr_size_nesw;}
			//left-center
			else if (control_relative_mouse_x >= bbox_left && control_relative_mouse_x <= bbox_left + OS_MOUSE_CURSOR_PADDING
				&& control_relative_mouse_y > bbox_top + OS_MOUSE_CURSOR_PADDING && control_relative_mouse_y < bbox_bottom - OS_MOUSE_CURSOR_PADDING)
			{global.control_current_os_mouse_cursor = cr_size_we;}
			else
			{global.control_current_os_mouse_cursor = cr_default;}
			
			global.control_current_os_mouse_cursor_obtained = true;
		}
		
#endregion
	}
	else
	{control_shader_hover = noone;}
	
	//On Left-click
	if (global.control_mouse_left_pressed)
	{
		if (!global.control_with_useable_focus_acquired)
		{
			global.control_with_useable_focus = global.control_with_mouse_over_focus;
			private_Control_Set_Focus_And_Shader(global.control_with_useable_focus);
			global.control_with_useable_focus_acquired = true;
		}
	}
	//Reset OnClick Shader
	else if (global.control_mouse_left_released)
	{control_shader_OnLeftClick = noone;}
	//On Right-click
	else if (global.control_mouse_right_pressed)
	{
		if (!global.control_with_optional_focus_acquired)
		{
			global.control_with_optional_focus = global.control_with_mouse_over_focus;
			private_Control_Set_Optional_Focus_And_Shader(global.control_with_optional_focus);
			global.control_with_optional_focus_acquired = true;
		}
	}
	//Reset OnRightClick Shader
	else if (global.control_mouse_right_released)
	{control_shader_OnRightClick = noone;}
}
//OnLeave
else
{
	//Get mouse-over focus (hover)
	if (!global.control_mouse_leave_event_performed_this_step)
	{
		private_Controls_Mimic_Mouse_Enter_Leave();
		global.control_mouse_leave_event_performed_this_step = true;
	}
	
	control_mouseOver = false;
	
	//Play OnLeave audio if it hasen't played yet
	if (CTRL_Sound_OnEnter_OnLeave_Plays_On == BOUNDS || CTRL_Sound_OnEnter_OnLeave_Plays_On == FOCUS)
	{
		if (audio_exists(CTRL_Sound_OnLeave)
			&& OnEnter_audio_has_played
			&& !OnLeave_audio_has_played)
		{
			audio_play_sound(CTRL_Sound_OnLeave,1,false);
			OnEnter_audio_has_played = false;
			OnLeave_audio_has_played = true;
		}
	}
	
	//obtain pseudo focus
	if (global.control_mouse_left_pressed)
	{control_leftClick_pseudo_focus = false;}
	//obtain pseudo focus
	if (global.control_mouse_right_pressed)
	{control_rightClick_pseudo_focus = false;}
	//Mouse-over Shader
	control_shader_hover = noone;
	
	//Mouse cursor reset
	if (global.control_with_mouse_over_focus == noone)
	{
		//reset the custom mouse cursor
		global.control_current_mouse_cursor = noone;
		global.control_can_display_custom_mouse_cursor = false;
		
		//reset the os mouse cursor
		global.control_current_os_mouse_cursor = cr_default;
	}
		
	//Reset OnLeftClick Shader
	if (global.control_mouse_left_released)
	{control_shader_OnLeftClick = noone;}
	//Reset OnRightClick Shader
	else if (global.control_mouse_right_released)
	{control_shader_OnRightClick = noone;}
}
#endregion

#region KEYBOARD
//DE-SELECT ALL CONTROLS
//User has opted to de-select ALL controls: No control has focus or optional focus
//Note: If a tooltip is being displayed and vk_escape is pressed, only the tooltip will close. vk_escape must then be pressed again to deselect all
if (!global.control_dismiss_all_focus_performed_this_step)
{	
	Controls_Grid_Of_Control_Quick_Actions_DeSelect_Controls_Via_Escape_Key();
	global.control_dismiss_all_focus_performed_this_step = true;
}

//TAB-STOPS
//Iterates through the controls via the tab key
//Selects a control with the current tab-index
//Deselects other controls
if (!global.grid_of_quick_actions_current_tab_stop_selection_performed_this_step)
{
	Controls_Grid_Of_Control_Quick_Actions_Set_Control_Via_Tab_Index();
	//Tab-stop action for this cycle complete!
	global.grid_of_quick_actions_current_tab_stop_selection_performed_this_step = true;

}

// ACCELERATOR KEY(S)
if (!global.list_of_concurrent_keys_being_pressed_obtained)
{
	Controls_Grid_Of_Control_Quick_Actions_Set_Control_Via_Accelerator_Keys();
	global.list_of_concurrent_keys_being_pressed_obtained = true;
}
#endregion

#endregion



#region ERROR CHECKING

#region Type Errors
if (CTRL_Type != object_index || CTRL_Is_Background != private_control_is_background)
{
	CTRL_Type = object_index;
	CTRL_Is_Background = private_control_is_background;
	a_type_error_occurred = true;
}
#endregion

#region Naming Errors
//control id
if (CTRL_ID != id)
{
	CTRL_ID = id;
	a_naming_error_occurred = true;
}

//Ensure name and instance number at begin_step == name and instance number at end_step
current_control_name = CTRL_Name;
current_control_instance = CTRL_Instance;
if (current_control_name != previous_control_name || current_control_instance != previous_control_instance)
{
	name_updated = false;
	a_naming_error_occurred = true;
	with (id)
	{
		show_debug_message("Exception in Controls: An error occurred with CTRL_Name \"" + string(CTRL_Name) + "\" on instance id " + string(id) + "!");
		Control_Check_Name(CTRL_Name,CTRL_Instance,CTRL_ID);
		Control_Set_Number_Of_Control_Name();
		show_debug_message("We've set its CTRL_Name to \"" + CTRL_Name + "\" using control instance number " + string(CTRL_Instance) + (current_control_instance != previous_control_instance ? ", the next available control instance number!" : "."));
	}
}
//ensure type name matches
if (CTRL_TypeName != object_get_name(object_index))
{
	CTRL_TypeName = object_get_name(object_index);
	a_naming_error_occurred = true;
}
#endregion

#region Depth Errors
current_control_depth = CTRL_Depth;

if (current_control_depth != previous_control_depth || CTRL_Depth != depth)
{
	control_depth_updated = false;
	a_depth_error_occurred = true;
	with (id)
	{
		show_debug_message("Exception in Controls: An error occurred with CTRL_Depth " + string(CTRL_Depth) + " on instance id " + string(id) + "!");
		Controls_Set_Depth();
		if is_undefined(CTRL_Depth)
		{CTRL_Depth = depth;}
		show_debug_message("We've set its CTRL_Depth to " + string(CTRL_Depth) + ", the next available control depth number!");
	}
}
#endregion

#endregion

//Control Variables Refresh
image_alpha = CTRL_Opacity;
visible = CTRL_Appearance == VISIBLE ? true : false;