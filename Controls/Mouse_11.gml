/// @description Mouse Cursor Left -- Plays mouse leave audio

//Note: This event filters for those controls below the current control
if (!global.control_mouse_leave_event_performed_this_step)
{
	/*global.control_drawn_to_surfaces_mouse_enter_can_be_checked	= true;
	global.control_drawn_to_surfaces_mouse_leave_can_be_checked	= false;
	
	var arrCtrls = private_Controls_Mouse_Enter_Leave();
	
	//reset the globals
	global.control_with_mouse_over_focus = noone;
	global.control_with_mouse_over_focus_acquired = false;
	
	for (var i = array_length(arrCtrls)-1; i >= 0; i--)
	{
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
	//global.control_mouse_leave_event_performed_this_step = true;
}
//Play OnLeave audio
//if (audio_exists(CTRL_Sound_OnLeave) && !OnLeave_audio_has_played) {audio_play_sound(CTRL_Sound_OnLeave,1,false); OnEnter_audio_has_played = false; OnLeave_audio_has_played = true;}	
/**/
//reset tooltip
//IF No control or current control doesn't equal previous
//if (Controls_Get_Topmost(control_mouse_x, control_mouse_y, all, false) == noone ||
//(id != global.control_with_mouse_over_focus && id == global.control_with_mouse_over_focus_previous))
//{Control_Reset_ToolTip();}
