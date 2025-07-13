/// @description Used when setting the CommandButton's text (is immediately converted to its value)

// Inherit the parent event
event_inherited();

//set CTRL_Value = bool(CTRL_Text)
if (string_lower(CTRL_Text) == "true") {CTRL_Value = true;}
else {CTRL_Value = false; CTRL_Text = "false";}

//Briefly "presses" the button
//If you require a press-and-hold behavior, consider instantiating a Toggle Button
if (CTRL_Value)
{event_user(ENUM_Control_User_Events.basic_interaction);}
else
{event_user(ENUM_Control_User_Events.end_interaction);}