/// @description Used for obtaining ev_right_button Is overriden by ev_right_press

//Note: This event will run regardless of whether the control has focus or is enabled
//Set Event
CTRL_Event_Type = event_type;
CTRL_Event_Number = CTRL_Event_Number != ev_right_press ? event_number : CTRL_Event_Number;
