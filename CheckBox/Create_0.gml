/// @description Creates a Checkbox! (reuses many CommandButton variables)
// Note: The Check Box IS a Command Button in its design and will reuse many of the same variables
// Plese keep this is mind when designing your Check Box!

// Inherit the parent event
event_inherited();
//Get data structure for this control

struct_checkBox = new basic_Checkbox_Componets(id);
Checkbox_Design(struct_checkBox);

//Set bounds
control_bounds_xx1 = struct_checkBox.xx1;
control_bounds_yy1 = struct_checkBox.yy1;
control_bounds_xx2 = struct_checkBox.xx2;
control_bounds_yy2 = struct_checkBox.yy2;

//Get current click event
Checkbox_Click_Event = undefined; //This event will cycle from ev_OnClick --> ev_OnRelease

//Defaults
//Get initial value
//This is finalized in the begin step due to a delay with variables and how Game Maker instantiates objects
if (CTRL_Can_Use_Initial_Value && !control_initial_value_set)
{
	CTRL_Value = bool(CTRL_Initial_Value);
	CTRL_Text = CTRL_Value ? "true" : "false";
}

//update previous events
CTRL_Previous_Value = CTRL_Value;
CTRL_Previous_Text = CTRL_Text;

//Shader Overrides
/*This control doesn't use shader overrides!*/

//Operation
private_Checkbox_Update_Clickable_Regions(struct_checkBox);

//Finish Up
//Update captions
Controls_Reset_Captions();
//If the caption must be reset, re-run any bounds and vertex functions
event_user(ENUM_Control_User_Events.caption_auto_size);