/// @description Ends a Checkbox Press
// Used for ending button presses where focus is not required
// Inherit the parent event
event_inherited();

//Run a full control interaction cycle per current CTRL_Value in this case
event_user(ENUM_Control_User_Events.set_control_value);