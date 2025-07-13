/// @description Resets tab-stop count
/**
* If a new control is instantiated in the next room, it will get the next available
* tab-stop index greater-than -1
*/

//Set Event
CTRL_Event_Type = event_type;
CTRL_Event_Number = event_number;

// OnRoomEnd
if (global.room_start_checked) {global.room_start_checked = false;}


//If persistant, lose focus to prevent unpredictable behavior between rooms
if (persistent && CTRL_Focus)
{Controls_Deselect_Control(id,true,true,false,true);}