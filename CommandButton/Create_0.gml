/// @description Creates a CommandButton!
// You can write your code in this editor
// Inherit the parent event
event_inherited();

//Get data structure for this control
struct_commandButton = new basic_CommandButton_Componets(CTRL_ID);

//build the command button
CommandButton_Design(struct_commandButton);
//Set bounds
control_bounds_xx1 = struct_commandButton.xx1;
control_bounds_yy1 = struct_commandButton.yy1;
control_bounds_xx2 = struct_commandButton.xx2;
control_bounds_yy2 = struct_commandButton.yy2;


//Get current click event
Command_Button_Click_Event = undefined; //This event will cycle from ev_OnClick --> ev_OnClickHeldDown --> ev_OnRelease

//Default
//Command Buttons don't really use initial values
//Get initial value
if (CTRL_Can_Use_Initial_Value && !control_initial_value_set)
{
	CTRL_Value = bool(CTRL_Initial_Value);
	CTRL_Text = CTRL_Value ? "true" : "false";
}
//update previous events
CTRL_Previous_Value = CTRL_Value;
CTRL_Previous_Text = CTRL_Text;

//For Command Buttons, The initial value is considered set in this case
//Note: Other controls must finalize this in the begin step due to a delay with how Game Maker instantiates objects and variables.
control_initial_value_set = true;

//Shader Overrides
/*This control doesn't use shader overrides!*/

//Operation
private_CommandButton_Update_Clickable_Regions(struct_commandButton);

//Finish Up
//Update captions
Controls_Reset_Captions();
//If the caption must be reset, re-run any bounds and vertex functions
event_user(ENUM_Control_User_Events.caption_auto_size);