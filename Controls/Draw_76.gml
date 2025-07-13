/// @description Used for resetting Event variables

CTRL_Event_Type = event_type;
CTRL_Event_Number = event_number;

//Reset current and previous control values
CTRL_Previous_Value = CTRL_Value;
CTRL_Previous_Text = CTRL_Text;

//Set shaders
control_shader = private_Control_Set_Shader(CTRL_Enabled, CTRL_Shader_Idle, control_shader_OnLeftClick, control_shader_OnRightClick, control_shader_hover, control_shader_has_focus, control_shader_has_optional_focus, control_shader_keyboard_key_OnLeftClick, control_shader_keyboard_key_OnRightClick);

//Mouse cursor (Note: the mouse cursor is always drawn last [above everything else])
//!NOTE: Culling will affect the visibility of the custom cursor!
//final non-control object drawn must cull-counterclockwise or cull_noculling!!
Control_Display_Mouse_Cursor();