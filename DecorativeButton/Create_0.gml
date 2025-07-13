/// @description Creates a Decorative Button!

//Note: This control is basically a non-interactive Command Button

// Inherit the parent event
event_inherited();

//Get data structure for this control
struct_decorativeButton = new basic_DecorativeButton_Componets(CTRL_ID);

//build the decorative button using the command button design
CommandButton_Design(struct_decorativeButton);
//Set bounds
control_bounds_xx1 = struct_decorativeButton.xx1;
control_bounds_yy1 = struct_decorativeButton.yy1;
control_bounds_xx2 = struct_decorativeButton.xx2;
control_bounds_yy2 = struct_decorativeButton.yy2;


//Get current click event
Command_Button_Click_Event = undefined; //This event will cycle from ev_OnClick --> ev_OnClickHeldDown --> ev_OnRelease

//Shader Overrides
/*This control doesn't use shader overrides!*/

//Operation
private_CommandButton_Update_Clickable_Regions(struct_decorativeButton);

//Finish Up
//Update captions
Controls_Reset_Captions();
//If the caption must be reset, re-run any bounds and vertex functions
event_user(ENUM_Control_User_Events.caption_auto_size);

//appear pressed?
Control_Set_CommandButton_Vertices(struct_decorativeButton, struct_decorativeButton, COMMANDBUTTON_ARRAY_V_BUFFER_INDICES, Appear_Pressed, Press_Type);