/// @description Cleans up tab stops and other vars; Other clean up functions in inherited events

//Set Event
CTRL_Event_Type = event_type;
CTRL_Event_Number = event_number;

//Cleans up tab-stops and resets the tab-stop counter
Controls_Grid_Of_Control_Quick_Actions_CleanUp_Tab_Stops();

//reset the os mouse cursor
global.control_current_os_mouse_cursor = cr_default;
global.control_current_os_mouse_cursor_obtained = false;