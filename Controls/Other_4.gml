/// @description Resets some depth values

//Set Event
CTRL_Event_Type = event_type;
CTRL_Event_Number = event_number;

//OnRoomStart
if (!global.room_start_checked)
{
	//get depths
	var arrDepths = Controls_Get_Depths();	
	//sort the array
	array_sort(arrDepths,true);
	//assign to globals
	if (array_length(arrDepths) > 0)
	{
		global.control_nearest_depth_value = arrDepths[0];
		global.control_farthest_depth_value = arrDepths[array_length(arrDepths)-1];
	}
	global.room_start_checked = true;
	
}