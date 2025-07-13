/// @description Used when setting the CommandButton's value
// Caution! Sets the CommandButton's value repeatedly!

// Inherit the parent event
event_inherited();

//set CTRL_Text = CTRL_Value
if (bool(CTRL_Value) == true) {CTRL_Text = "true";}
else {CTRL_Value = false; CTRL_Text = "false";}

//Briefly "presses" the button
//If you require a press-and-hold behavior, consider instantiating a Toggle Button
if (CTRL_Value)
{event_user(ENUM_Control_User_Events.basic_interaction);}
else
{event_user(ENUM_Control_User_Events.end_interaction);}