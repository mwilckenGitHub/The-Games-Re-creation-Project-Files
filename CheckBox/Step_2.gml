/// @description Ensure Certain Check Box Values Are Set Prior To Draw Events

// Inherit the parent event
event_inherited();

//Keyboard derived OnLeftClick (same effect as left-clicked with mouse)
if (CTRL_Enabled && CTRL_Focus && control_accelerator_keys_checked)
{control_shader_OnLeftClick = control_shader_OnLeftClick == noone ? CTRL_Shader_OnLeftClick : control_shader_OnLeftClick;}

//Keyboard key shader interactions
///@see parent Create_Event
control_shader_keyboard_key_OnLeftClick = control_accelerator_keys_checked;

//Accelerator key interactions
private_Control_Reset_Accelerator_Key_Bools();