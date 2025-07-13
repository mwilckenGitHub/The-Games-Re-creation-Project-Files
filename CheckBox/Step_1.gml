/// @description Sets Checkbox's value per interactions

// Inherit the parent event
event_inherited();

//State
//Note: This state machine works at start of begin step and should be used only to change the current OnClick event
switch (Checkbox_Click_Event)
{
	case ev_OnClick:
	{
		Checkbox_Click_Event = ev_OnClickHeldDown;
	}
	break;
	case ev_OnClickHeldDown:
	{
		/**/
	}
	break;
	case ev_OnRelease:
	default:
	{
		Checkbox_Click_Event = undefined;
	}
	break;
}

//Interactions based on window mouse positions (Local)
//window-based mouse position lies within scope of gui layer
//OnEnter (And interactions)
//FUTURE_TODO: Add Gestures
//Also handles keyboard interactions via the current Checkbox Accelerator key
//OnEnter
if (private_Control_BeginStep_Determine_OnEnter_Or_Usable(true,false))
{

#region Initial Value
	//(used with Toggle Buttons and Radio Buttons)
	if (CTRL_Can_Use_Initial_Value && !control_initial_value_set)
	{
		//Note: checkbox values cycle false -> undefined -> true
		if (CTRL_Initial_Value)
		{
			CTRL_Value = false; //Note: control value must be false to cycle to true
		}
		else if (!CTRL_Initial_Value)
		{
			CTRL_Value = true; //Note: control value must be true to cycle to false
		}
		else if (is_undefined(CTRL_Initial_Value) && Checkbox_Triple_State)
		{
			CTRL_Value = false; //Note: control value must be false to cycle to undefined
		}
		//An unknown error has occurred
		else
		{
			CTRL_Value = true; //Note: control value must be true to cycle to false
			show_debug_message("An unknown error has occurred in selecting a value for this checkbox!\r\nSetting value to false!");
		}
			
		//"Press" and "Release" the checkbox to perform its full cycle
		Checkbox_Event_Perform_Click(CTRL_ID,true,false);
		Checkbox_Event_End_Click(CTRL_ID,false,false);
			
		//allow OnLeave Reset
		reset_OnClick_values_OnLeave = true;
		control_initial_value_set = true;
	}
#endregion
	
	private_Checkbox_Update_Clickable_Regions(struct_checkBox);
	//Get position of region
	struct_checkBox.clicked_region[of_x] = projected_control_mouse_x;
	struct_checkBox.clicked_region[of_y] = projected_control_mouse_y;
	
	var withinScope = struct_checkBox.clicked_region[of_x] >= struct_checkBox.clickable_regions[ENUM_Checkbox_Clickable_Regions.checkbox][ENUM_Checkbox_Clickable_Region_parts.bounds_left] && struct_checkBox.clicked_region[of_x] <= struct_checkBox.clickable_regions[ENUM_Checkbox_Clickable_Regions.checkbox][ENUM_Checkbox_Clickable_Region_parts.bounds_right]
				&& struct_checkBox.clicked_region[of_y] >= struct_checkBox.clickable_regions[ENUM_Checkbox_Clickable_Regions.checkbox][ENUM_Checkbox_Clickable_Region_parts.bounds_top] && struct_checkBox.clicked_region[of_y] <= struct_checkBox.clickable_regions[ENUM_Checkbox_Clickable_Regions.checkbox][ENUM_Checkbox_Clickable_Region_parts.bounds_bottom];
	
	//Update Output Value
	if (CTRL_Focus)
	{
		//allow OnLeave Reset
		reset_OnClick_values_OnLeave = true;
		//cursor is within scope or accelerator key pressed
		if (withinScope	|| control_accelerator_keys_checked || control_accelerator_keys_released)
		{	
			//left mouse pressed or released or accelerator key pressed or release
			if (!struct_checkBox.is_clicked && (global.control_mouse_left_checked || control_accelerator_keys_checked))
			{Checkbox_Event_Perform_Click(CTRL_ID,true,true);}
			//Set checkbox value on release
			else if (struct_checkBox.is_clicked && (global.control_mouse_left_released || control_accelerator_keys_released))
			{Checkbox_Event_End_Click(CTRL_ID,true,true);}
			
			//OnRightPress
			if (global.control_mouse_right_checked)
			{struct_checkBox.a_button_is_rightClicked = true;}
			else if (global.control_mouse_right_released)
			{struct_checkBox.a_button_is_rightClicked = false;}
		}
	}
}
//OnLeave
else
{
	//The following behavior is universal for the CHeckbox and should not be constrained to a script
	if (CTRL_Enabled)
	{
		if (CTRL_Focus)
		{
			if (struct_checkBox.is_clicked)
			{			
				//Event
				Checkbox_Click_Event = !is_undefined(Checkbox_Click_Event) ? ev_OnRelease : undefined;
				
				//Reset image index
				Control_CommandButton_Set_Texture_Image_Index(struct_checkBox, Label_Sprite_Index, Label_Image_Index);
				
				Control_Set_Checkbox_Vertices(struct_checkBox,false,noone);
				
				
				private_Checkbox_Reset_All_Button_Click_Values();
			}
			reset_OnClick_values_OnLeave = true;
		}
		else
		{
			if (reset_OnClick_values_OnLeave)
			{
				//Event
				Checkbox_Click_Event = !is_undefined(Checkbox_Click_Event) ? ev_OnRelease : undefined;
			
				struct_checkBox.is_clicked = false;
				Control_Set_Checkbox_Vertices(struct_checkBox,false,noone);
			
				//Reset ALL Image Indices
				Control_CommandButton_Set_Texture_Image_Index(struct_checkBox, Label_Sprite_Index, Label_Image_Index);
			
				private_Checkbox_Reset_All_Button_Click_Values();
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