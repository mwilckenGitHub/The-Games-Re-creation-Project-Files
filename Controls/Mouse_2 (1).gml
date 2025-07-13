/// @description Used for obtaining ev_middle_button Is overriden by ev_middle_press

//Note: This event will run regardless of whether the control has focus or is enabled
//Set Event
CTRL_Event_Type = event_type;
CTRL_Event_Number = CTRL_Event_Number != ev_middle_press ? event_number : CTRL_Event_Number;
