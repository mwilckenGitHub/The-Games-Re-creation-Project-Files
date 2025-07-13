/// @description Mouse Cursor Entered -- Plays mouse enter audio

//Note: This event filters for those controls below the current control
if (!global.control_mouse_enter_event_performed_this_step)
{
	/*global.control_drawn_to_surfaces_mouse_enter_can_be_checked	= false;
	global.control_drawn_to_surfaces_mouse_leave_can_be_checked	= true;
	
	
	var arrCtrls = private_Controls_Mouse_Enter_Leave();
	
	//reset the globals
	global.control_with_mouse_over_focus = noone;
	global.control_with_mouse_over_focus_acquired = false;
	
	
	//show_debug_message("==========================")
	for (var i = array_length(arrCtrls)-1; i >= 0; i--)
	{
		//show_debug_message(arrCtrls[i]);
		with (arrCtrls[i])
		{
			//set this one to enter
			if (id == arrCtrls[0])
			{
				global.control_with_mouse_over_focus = id;
				global.control_with_mouse_over_focus_acquired = true;
				//Play OnEnter audio
				if (audio_exists(CTRL_Sound_OnEnter) && !OnEnter_audio_has_played) {audio_play_sound(CTRL_Sound_OnEnter,1,false); OnEnter_audio_has_played = true; OnLeave_audio_has_played = false;}
			}
			//all other controls must be set to leave event
			else
			{
				//Play OnLeave audio
				if (audio_exists(CTRL_Sound_OnLeave) && !OnLeave_audio_has_played) {audio_play_sound(CTRL_Sound_OnLeave,1,false); OnEnter_audio_has_played = false; OnLeave_audio_has_played = true;}
			}
		}
	}/**/
	
	//Tool Tip: Must reset the tool tip if there are layered controls and cursor has entered the control with mouse over focus (always the top-most control)
	//if (id == global.control_with_mouse_over_focus)
	//{Control_Reset_ToolTip();}
	/**/
	//global.control_mouse_enter_event_performed_this_step = true;
}
/**/
