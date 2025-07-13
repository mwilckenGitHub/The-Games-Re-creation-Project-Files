/// @description Used when setting a variable for the Checkbox

// Inherit the parent event
event_inherited();


#region Local Beginning Exceptions
/**/
#endregion


//Garbage Collect To Reset This Control
clean_up_Checkbox(id);

//Reset data structure for this control
struct_checkBox = new basic_Checkbox_Componets(id);
Checkbox_Design(struct_checkBox);

//Reset the following variables
//Note: Timers and shaders DO NOT reset!

//Set bounds
control_bounds_xx1 = struct_checkBox.xx1;
control_bounds_yy1 = struct_checkBox.yy1;
control_bounds_xx2 = struct_checkBox.xx2;
control_bounds_yy2 = struct_checkBox.yy2;


//Operation
private_Checkbox_Update_Clickable_Regions(struct_checkBox);

//Finish Up
//Reset captions if they use the CONTROL_AUTO_CAPTION string
Controls_Reset_Captions_Sub_Struct(struct_checkBox);
//If the caption must be reset, re-run any bounds and vertex functions
event_user(ENUM_Control_User_Events.caption_auto_size);

#region Local Ending Exceptions
if (user_event_variable3_name == "CTRL_Value")
{Controls_Set_Control_Value_By_id(id,user_event_variable3);}
else if (user_event_variable3_name == "CTRL_Text")
{Controls_Set_Control_Text_By_id(id,user_event_variable3);}
#endregion