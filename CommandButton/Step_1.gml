/// @description Sets the CommandButton's value based on interactions

// Inherit the parent event
event_inherited();

//State
switch (Command_Button_Click_Event)
{
	case ev_OnClick:
	{
		CTRL_Value = true;
		CTRL_Text = "true";
		Command_Button_Click_Event = ev_OnClickHeldDown;
	}
	break;
	case ev_OnClickHeldDown:
	{
		CTRL_Value = true;
		CTRL_Text = "true";
	}
	break;
	case ev_OnRelease:
	default:
	{
		CTRL_Value = false;
		CTRL_Text = "false";
		Command_Button_Click_Event = undefined;
	}
	break;
}

//Interactions based on window mouse positions (Local)
//window-based mouse position lies within scope of gui layer
//OnEnter (And interactions)
//FUTURE_TODO: Add Gestures
//Also handles keyboard interactions via the current Commandbutton Accelerator key
//OnEnter
if (private_Control_BeginStep_Determine_OnEnter_Or_Usable(true,false))
{
	private_CommandButton_Update_Clickable_Regions(struct_commandButton);
	//Get position of region
	struct_commandButton.clicked_region[of_x] = projected_control_mouse_x;
	struct_commandButton.clicked_region[of_y] = projected_control_mouse_y;
	
	var withinScope = struct_commandButton.clicked_region[of_x] >= struct_commandButton.clickable_regions[ENUM_CommandButton_Clickable_Regions.command_button][ENUM_CommandButton_Clickable_Region_parts.bounds_left] && struct_commandButton.clicked_region[of_x] <= struct_commandButton.clickable_regions[ENUM_CommandButton_Clickable_Regions.command_button][ENUM_CommandButton_Clickable_Region_parts.bounds_right]
					&& struct_commandButton.clicked_region[of_y] >= struct_commandButton.clickable_regions[ENUM_CommandButton_Clickable_Regions.command_button][ENUM_CommandButton_Clickable_Region_parts.bounds_top] && struct_commandButton.clicked_region[of_y] <= struct_commandButton.clickable_regions[ENUM_CommandButton_Clickable_Regions.command_button][ENUM_CommandButton_Clickable_Region_parts.bounds_bottom];
	
	if (CTRL_Focus)
	{
		//allow OnLeave Reset
		reset_OnClick_values_OnLeave = true;
		//cursor is within scope or accelerator key pressed
		if (withinScope	|| (control_accelerator_keys_checked || control_accelerator_keys_released))
		{
			//left mouse pressed or released or accelerator key pressed or released
			if ((global.control_mouse_left_checked || global.control_mouse_left_released)
				|| (control_accelerator_keys_checked || control_accelerator_keys_released))
			{
				//Button is not clicked
				//OnLeftPress or Accelerator Key
				//Has pseudo focus and mouse is within scope and has been left-clicked
				//(allows for mouse press to drag outsizd button to de-click button but can then re-click if still pressed and dragged back over button)
				if (!struct_commandButton.is_clicked
					&& ((withinScope && global.control_mouse_left_checked)
					//Or accelerator key is pressed
					|| control_accelerator_keys_checked))
				{
					//Click button
					CommandButton_Event_Perform_Click(CTRL_ID, true, true);
				}
				//Button is clicked
				//OnLeftRelase or accelerator key release
				else if (struct_commandButton.is_clicked
					&& ((global.control_mouse_left_released && !control_accelerator_keys_checked)
						|| (control_accelerator_keys_released && !global.control_mouse_left_checked)))
				{
					//De-click button
					CommandButton_Event_End_Click(CTRL_ID, true);
				}
			}
			
			//OnRightPress
			if (global.control_mouse_right_checked)
			{struct_commandButton.a_button_is_rightClicked = true;}
			else if (global.control_mouse_right_released)
			{struct_commandButton.a_button_is_rightClicked = false;}
		}
		
	}
}
//OnLeave
//This happens regardless of a function, therefore, keep it as open code in ev_step_begin.
else
{
	if (CTRL_Enabled)
	{
		if (CTRL_Focus)
		{
			if (struct_commandButton.is_clicked)
			{
				CommandButton_Event_End_Click(CTRL_ID, true);
				
			}
			reset_OnClick_values_OnLeave = true;
		}
		else
		{
			if (reset_OnClick_values_OnLeave)
			{
				CommandButton_Event_End_Click(CTRL_ID, false);
				reset_OnClick_values_OnLeave = false;
			}
		}
	}
}

#region Begin Step Finishing Up
//Check whether the current and previous values and text differ
private_Control_Check_Current_And_Previous_Values();
private_Control_Check_Current_And_Previous_Text();
#endregion