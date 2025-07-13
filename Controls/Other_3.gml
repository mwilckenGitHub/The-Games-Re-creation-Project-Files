/// @description Destroy data-structures

//Set Event
CTRL_Event_Type = event_type;
CTRL_Event_Number = event_number;

//tab stop list
if (ds_exists(global.grid_of_control_quick_actions, ds_type_grid)) {ds_grid_destroy(global.grid_of_control_quick_actions);}

//Controls Lists
if (ds_exists(global.list_of_controls, ds_type_list)){ds_list_destroy(global.list_of_controls);}
if (ds_exists(global.list_of_auto_resized_controls, ds_type_list)){ds_list_destroy(global.list_of_auto_resized_controls);}
if (ds_exists(global.list_current_controls, ds_type_list)){ds_list_destroy(global.list_current_controls);}
if (ds_exists(global.list_of_current_concurrent_keys_being_pressed,ds_type_list)){ds_list_destroy(global.list_of_current_concurrent_keys_being_pressed);}
if (ds_exists(global.list_of_previous_concurrent_keys_being_pressed,ds_type_list)){ds_list_destroy(global.list_of_previous_concurrent_keys_being_pressed);}
if (ds_exists(global.list_of_key_press_history,ds_type_list)){ds_list_destroy(global.list_of_key_press_history);}

//Delete the global Vertex format
vertex_format_delete(global.controls_toolbox_v_format);

//delete the tool tip struct
delete global.struct_toolTip;

//Specified
/**/