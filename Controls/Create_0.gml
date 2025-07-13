/// @description Parent event for creating a new control
#region Controls/Create/main
/**
/// @module Controls/Create/main
/// @requires DSListScripts; StringScripts; ControlScripts, et al.
/// @description The Create Event for user controls. This should be considered the main
 * event for all operations pertaining to the user contorls.
/// @license GNU But please purchase for your first copy!
 * Copyright (c) 2022 The Games Re-creation Project.org.
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in all
 * copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 * SOFTWARE.
 *
 * Addendum:
 * This license applies to all modules and objects associated with the "User
 * Controls Toolbox," otherwise known as the "Toolbox" group and its child objects,
 * assets, and procedures stored therein as a file structure in its original form
 * as listed in the "Marketplace." The user of Software will note that there are
 * many modules called by Software. These modules should all include a JSDOC
 * indication (/// @license ...) of their license status, which, to the best
 * recollection of this programmer, should all be GNU type licenses. Note that
 * a missing /// @license listing IMPLIES the current license.
 * 
 * Please reference this citation for this software:
 * Matthew Wilcken
 * The Games Re-creation Project
 * https://thegamesrecreationproject.org/
*/
#endregion
//****Inhereted Values****
#region CONTROL TYPE
//add object index to list if not already listed
if (ds_list_entries_count(global.list_of_controls, object_index) == 0)
{ds_list_add(global.list_of_controls,object_index);}
//get a boo in case type doesn't match assigned type
a_type_error_occurred = false;

//Note: whether the control is a background should NOT be changed
//Changing this value may cause errors or may cause a foreground to appear behind backgrounds
private_control_is_background = CTRL_Is_Background;
#endregion

#region CONTROL NAMING
//Get a boo in case an error occurs
a_naming_error_occurred = false;
//Update Names if necessary
name_updated = false;
//Get caption_string_auto_caption_reset forces a reset of caption variables if the caption name is automated
caption_string_auto_caption_reset = false;
caption_string_auto_caption_reset_rountine_completed = false; //Allows the resizing of the caption string to occur only once
//Check control name to ensure it is formulated correctly
Control_Check_Name(CTRL_Name, CTRL_Instance, CTRL_ID);
//Number this control name to ensure all names are unique
Control_Set_Number_Of_Control_Name();

//Get current control name and instance to check for changes user may have introduced at run-time
current_control_name = CTRL_Name;
previous_control_name = CTRL_Name;
current_control_instance = CTRL_Instance;
previous_control_instance = CTRL_Instance;
#endregion

#region CONTROL DEPTH
//For this project, all depths will assume a z-layer less-than-or-equal to 0 as instances accrue
//boo if depth error occurs
a_depth_error_occurred = false;
//Update depths if necessary
control_depth_updated = false;

depth = CTRL_Depth != undefined ? CTRL_Depth : 0;
Controls_Set_Depth();

current_control_depth = CTRL_Depth;
previous_control_depth = CTRL_Depth;
#endregion

#region CONTROL DESIGN
private_Controls_Create_Shader_Variables();
//CAUTION! Do not assign shader overrides here! Assign them in each child control
#endregion

#region CONTROL OPERATION
//get mouse position amd matrix rotation (works with 2D only)
control_relative_mouse_x = device_mouse_x_to_gui(0); //Relative based on surface (use these for most cursor references)
control_relative_mouse_y = device_mouse_y_to_gui(0); //Relative based on surface (use these for most cursor references)
control_absolute_mouse_x = control_relative_mouse_x; //Fixed, absolute coordinates based on window or room (use only if an absolute coordiante is required)
control_absolute_mouse_y = control_relative_mouse_y; //Fixed, absolute coordinates based on window or room (use only if an absolute coordiante is required)

//Get matrix for rotations of control
control_matrix = matrix_build(x+(lengthdir_x(0, image_angle)),y+(lengthdir_y(0, image_angle)),0,0,0,image_angle,1,1,1);
control_matrix_projection_build = matrix_build_projection_ortho(window_get_width(),window_get_height(),GML_NEAREST_DEPTH,GML_FURTHEST_DEPTH);
control_projected_matrix = window_get_xy_2d_ray_to_3d_world_space(control_relative_mouse_x, control_relative_mouse_y, control_matrix, control_matrix_projection_build);
//get projected mouse positions
projected_control_mouse_x = control_projected_matrix[ENUM_Cursor_Point_To_World_Space_Projection_Ray.ox];
projected_control_mouse_y = control_projected_matrix[ENUM_Cursor_Point_To_World_Space_Projection_Ray.oy];

//mouse wheel interactions
control_mouse_wheel_up_was_used = false;
control_mouse_wheel_down_was_used = false;
control_mouse_wheel_speed = 0; //Unused but when it was used it produced an interesting result

//Accelerator Key
control_accelerator_keys_pressed  = false;
control_accelerator_keys_checked  = false;
control_accelerator_keys_released = false;

//Positioning
//get a z point
z = 0; //FUTURE_TODO: Add z positioning
//get fixed origin points (change ONLY when using Controls_Move_Control())
control_fixed_point_x = x;
control_fixed_point_y = y;
control_fixed_point_z = z;

//Is the control drawn to a surface?

//get absolute coordinantes for use when control is drawn to a surface that is not drawn at (0,0)
//These are used primarily with adjusting the output position of the mouse cursor so that a control
//may be selected if it is not rendered to the application_surface
control_drawn_to_surface							= false;
control_drawn_to_surface_offset_x					= 0; //The x-offset of this surface relative to world (0,0)
control_drawn_to_surface_offset_y					= 0; //The y-offset of this surface relative to world (0,0)
control_drawn_to_surface_relative_width				= 0; //The relative width of the surface this control is being drawn to (used with things like draw_surface_part() etc.)
control_drawn_to_surface_relative_height			= 0; //The relative height of the surface this control is being drawn to (used with things like draw_surface_part() etc.)
control_drawn_to_surface_absolute_scale_x			= 1; //Keep these at 1! (scaled srufaces were tested and are too difficult to implement at this time [4/22/2025])
control_drawn_to_surface_absolute_scale_y			= 1; //Keep these at 1! (scaled srufaces were tested and are too difficult to implement at this time [4/22/2025])
control_drawn_to_surface_absolute_image_angle		= 0; //The angle of the surface
control_drawn_to_surface_draw_surface_part_left		= 0; //If the draw_surface_part or general functions used
control_drawn_to_surface_draw_surface_part_top		= 0; //If the draw_surface_part or general functions used
control_drawn_to_surface_selectable_bounds_left		= 0; //The selectable bounds. If a control lay beyond these bounds, it cannot be selected. Used with point_in_triangle()
control_drawn_to_surface_selectable_bounds_top		= 0; //The selectable bounds. If a control lay beyond these bounds, it cannot be selected. Used with point_in_triangle()
control_drawn_to_surface_selectable_bounds_right	= 0; //The selectable bounds. If a control lay beyond these bounds, it cannot be selected. Used with point_in_triangle()
control_drawn_to_surface_selectable_bounds_bottom	= 0; //The selectable bounds. If a control lay beyond these bounds, it cannot be selected. Used with point_in_triangle()
control_drawn_to_surface_parent						= noone; //The object wherein the surface is being drawn which then draws THIS control.
control_drawn_to_surface_tri1						= false; //The cursor lies within the triangle (FUTURE TODO)
control_drawn_to_surface_tri2						= false; //The cursor lies within the triangle (FUTURE TODO)

//Get this control's bounds
control_bounds_xx1 = -1;
control_bounds_yy1 = -1;
control_bounds_xx2 = -1;
control_bounds_yy2 = -1;

//Mouse
control_mouseOver = false; //The mouse cursor is within the bounds of the control. This is used primarily with the CallBacks for OnMouseEnter(), OnMouseHover(), and OnMouseLeave()

//pseudo focus
control_leftClick_pseudo_focus = false; //Ensures that a control which has focus cannot become activated if a mouse left-click occurres outside the control's bounds and the mouse left-click is held and dragged within scope of the control. This behavior matches HWDN controls.
control_rightClick_pseudo_focus = false;

//Audio
//OnEnter and Leave
OnEnter_audio_has_played = false;
OnLeave_audio_has_played = true;
//General Reset
//Resets this control
control_reset = false;
//Specified Reset
//Reset certain values if the user has left the control and the control has NO focus
reset_OnClick_values_OnEnter = false;
reset_OnClick_values_OnLeave = false;


//Parent Control object's event system
//These event vars are unused as of 1/31/2025
CTRL_Event_Type = event_type; //The current control events main event type @see ENUM_GameMaker_Events_Main_Event
CTRL_Event_Number = event_number; //The current control sub-sevent event number @see ENUM_GameMaker_Events_Sub_Event


//Information events
//Previous value and text events to run as a comparison for the OnChage callbacks
//These must be re-instantiated in the child event's create event
//This is then re-run in the Pre-Draw event.
CTRL_Previous_Value = CTRL_Value;
CTRL_Previous_Text = CTRL_Text;

CTRL_Current_And_Previous_Values_Differ = false; //Whether the current and previous values are different
CTRL_Current_And_Previous_Values_Difference = 0; //The value difference between the current and previuos values =(CTRL_Value - CTRL_Previous_Value)

CTRL_Current_And_Previous_Text_Differs = false; //Whether the current and previous text strings are different

//Values
control_initial_value_set = false;

#region User Event Variables
/**
* The user event variables are arrays of variables to be set prior to calling a specific user event and are then to be used within the user event.
* If a user calls a user event using, say Controls_Set_Control_Value_By_id(_id, _value), the _value variable's value would then be assigned 
* to the user event variable (user_event_variable1 in this case) so that it could then be used within user event 1
*/

//Note: NOT all of these variables are in use as of this version release
/*Variable Name					Value		Type			Note			*/
user_event_variable0		=	undefined;	//				
user_event_variable1		=	undefined;	//number		Used when resetting a value
user_event_variable2		=	undefined;	//string		Used when resetting text
user_event_variable3		=	undefined;	//variant		Used for resetting any one pre-created variable (Other object variables should work, however)
user_event_variable4		=	undefined;	//array			Array of pre-create variable values (Other object variables should work, however)
user_event_variable5		=	undefined;	//unused		Event 5 resizes
user_event_variable6		=	undefined;	//unused		Event 6 Performs a basic control interaction (simply pressing a command buttom)
user_event_variable7		=	undefined;	//unused		Event 7 Ends a basic control interaction (simply ends a command button press) Note: ev_6 and ev_7 These should be used only when CTRL_Focus cannot be obtained
user_event_variable8		=	undefined;	//unused		Event 8 Used with shader overrides (Note: not all controls use shader overrides)		
user_event_variable9		=	undefined;	//		
user_event_variable10		=	undefined;	//				
user_event_variable12		=	undefined;	//				
user_event_variable13		=	undefined;	//				
user_event_variable14		=	undefined;	//				
user_event_variable15		=	undefined;	//				
user_event_variable16		=	undefined;	//				
//Name of the variable used
user_event_variable0_name	=	"";			//string		
user_event_variable1_name	=	"";			//string		Always "CTRL_Value"
user_event_variable2_name	=	"";			//string		Always "CTRL_Text"
user_event_variable3_name	=	"";			//string		A pre-create variable name
user_event_variable4_name	=	[""];		//string		Array of pre-create variable names
user_event_variable5_name	=	"";			//string		unused
user_event_variable6_name	=	"";			//string		unused
user_event_variable7_name	=	"";			//string		unused
user_event_variable8_name	=	"";			//string		unused
user_event_variable9_name	=	"";			//string
user_event_variable10_name	=	"";			//string		
user_event_variable12_name	=	"";			//string		
user_event_variable13_name	=	"";			//string		
user_event_variable14_name	=	"";			//string		
user_event_variable15_name	=	"";			//string		
user_event_variable16_name	=	"";			//string		

user_event_error_message_intro = "Calling Control id = " + string(id) + "\r\nType = " + string(object_get_name(object_index) + "\r\n");


#endregion

//Animation
//set to 0
image_speed = 0;

//Opacity
image_alpha = CTRL_Opacity;
visible = CTRL_Appearance == VISIBLE ? true : false;

//Image scale
//Get variable for the current auto-sized image-scale
autoSized_image_xscale = image_xscale; //set at create and in private_Control_Set_Autosized_Bounds_Of_A_Plane()
autoSized_image_yscale = image_yscale;

//These varaibles are used only with certain types of control resizing
special_image_xscale_value = image_xscale;
special_image_yscale_value = image_yscale;

#endregion

show_debug_overlay(false);