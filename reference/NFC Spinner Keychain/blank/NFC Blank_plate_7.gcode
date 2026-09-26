; HEADER_BLOCK_START
; BambuStudio 02.08.02.61
; model printing time: 14m 56s; total estimated time: 21m 1s
; total layer number: 25
; total filament length [mm] : 1970.90
; total filament volume [cm^3] : 4740.57
; total filament weight [g] : 5.88
; filament_density: 1.24,1.24
; filament_diameter: 1.75,1.75
; max_z_height: 5.00
; filament: 1
; support_material_on_wipe_tower: 0
; HEADER_BLOCK_END

; CONFIG_BLOCK_START
; accel_to_decel_enable = 0
; accel_to_decel_factor = 50%
; activate_air_filtration = 0,0
; additional_cooling_fan_speed = 70,70
; additional_fan_full_speed_layer = 0,0
; alternate_extra_wall = 0
; ams_filament_load_time_ams = 0
; ams_filament_load_time_ams_lite = 0
; ams_filament_load_time_n3f_s = 0
; ams_filament_unload_time_ams = 0
; ams_filament_unload_time_ams_lite = 0
; ams_filament_unload_time_n3f_s = 0
; apply_scarf_seam_on_circles = 1
; auxiliary_fan = 0
; avoid_crossing_wall_includes_support = 0
; bed_custom_model = 
; bed_custom_texture = 
; bed_exclude_area = 
; bed_heat_soak_area = 
; bed_temperature_formula = by_first_filament
; before_layer_change_gcode = 
; best_object_pos = 0.7,0.5
; bottom_color_penetration_layers = 2
; bottom_shell_layers = 3
; bottom_shell_thickness = 0
; bottom_surface_density = 100%
; bottom_surface_pattern = monotonic
; bridge_angle = 0
; bridge_flow = 1
; bridge_no_support = 0
; bridge_speed = 20
; brim_object_gap = 0.1
; brim_type = auto_brim
; brim_width = 5
; chamber_temperatures = 0,0
; change_filament_gcode = ;===== A1mini 20251031 =====\nG392 S0\nM1007 S0\nM620 S[next_extruder]A\nM204 S9000\nG1 Z{max_layer_z + 3.0} F1200\n\nM400\nM106 P1 S0\nM106 P2 S0\n{if old_filament_temp > 142 && next_extruder < 255}\nM104 S[old_filament_temp]\n{endif}\n\nG1 X180 F18000\n\n{if long_retractions_when_cut[previous_extruder]}\nM620.11 S1 I[previous_extruder] E-{retraction_distances_when_cut[previous_extruder]} F1200\n{else}\nM620.11 S0\n{endif}\nM400\n\nM620.1 E F{flush_volumetric_speeds[previous_extruder]/2.4053*60} T{flush_temperatures[previous_extruder]}\nM620.10 A0 F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\nT[next_extruder]\nM620.1 E F{flush_volumetric_speeds[next_extruder]/2.4053*60} T{flush_temperatures[next_extruder]}\nM620.10 A1 F{flush_volumetric_speeds[next_extruder]/2.4053*60} L[flush_length] H[nozzle_diameter] T{flush_temperatures[next_extruder]}\n\nG1 Y90 F9000\n\n{if next_extruder < 255}\n\n{if long_retractions_when_cut[previous_extruder]}\nM620.11 S1 I[previous_extruder] E{retraction_distances_when_cut[previous_extruder]} F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\nM628 S1\nG92 E0\nG1 E{retraction_distances_when_cut[previous_extruder]} F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\nM400\nM629 S1\n{else}\nM620.11 S0\n{endif}\n\nM400\nG92 E0\nM628 S0\n\n{if flush_length_1 > 1}\n; FLUSH_START\n; always use highest temperature to flush\nM400\nM1002 set_filament_type:UNKNOWN\nM109 S[flush_temperatures[next_extruder]]\nM106 P1 S60\n{if flush_length_1 > 23.7}\nG1 E23.7 F{flush_volumetric_speeds[previous_extruder]/2.4053*60} ; do not need pulsatile flushing for start part\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{(flush_length_1 - 23.7) * 0.02} F50\nG1 E{(flush_length_1 - 23.7) * 0.23} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\n{else}\nG1 E{flush_length_1} F{flush_volumetric_speeds[previous_extruder]/2.4053*60}\n{endif}\n; FLUSH_END\nG1 E-[old_retract_length_toolchange] F1800\nG1 E[old_retract_length_toolchange] F300\nM400\nM1002 set_filament_type:{filament_type[next_extruder]}\n{endif}\n\n{if flush_length_1 > 45 && flush_length_2 > 1}\n; WIPE\nM400\nM106 P1 S178\nM400 S3\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nM400\nM106 P1 S0\n{endif}\n\n{if flush_length_2 > 1}\nM106 P1 S60\n; FLUSH_START\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\nG1 E{flush_length_2 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_2 * 0.02} F50\n; FLUSH_END\nG1 E-[new_retract_length_toolchange] F1800\nG1 E[new_retract_length_toolchange] F300\n{endif}\n\n{if flush_length_2 > 45 && flush_length_3 > 1}\n; WIPE\nM400\nM106 P1 S178\nM400 S3\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nM400\nM106 P1 S0\n{endif}\n\n{if flush_length_3 > 1}\nM106 P1 S60\n; FLUSH_START\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\nG1 E{flush_length_3 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_3 * 0.02} F50\n; FLUSH_END\nG1 E-[new_retract_length_toolchange] F1800\nG1 E[new_retract_length_toolchange] F300\n{endif}\n\n{if flush_length_3 > 45 && flush_length_4 > 1}\n; WIPE\nM400\nM106 P1 S178\nM400 S3\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nM400\nM106 P1 S0\n{endif}\n\n{if flush_length_4 > 1}\nM106 P1 S60\n; FLUSH_START\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\nG1 E{flush_length_4 * 0.18} F{flush_volumetric_speeds[next_extruder]/2.4053*60}\nG1 E{flush_length_4 * 0.02} F50\n; FLUSH_END\n{endif}\n\nM629\n\nM400\nM106 P1 S60\nM109 S[new_filament_temp]\nG1 E5 F{flush_volumetric_speeds[next_extruder]/2.4053*60} ;Compensate for filament spillage during waiting temperature\nM400\nG92 E0\nG1 E-[new_retract_length_toolchange] F1800\nM400\nM106 P1 S178\nM400 S3\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nG1 X-3.5 F18000\nG1 X-13.5 F3000\nM400\nG1 Z{max_layer_z + 3.0} F3000\nM106 P1 S0\n{if layer_z <= (initial_layer_print_height + 0.001)}\nM204 S[initial_layer_acceleration]\n{else}\nM204 S[default_acceleration]\n{endif}\n{else}\nG1 X[x_after_toolchange] Y[y_after_toolchange] Z[z_after_toolchange] F12000\n{endif}\n\nM622.1 S0\nM9833 F{outer_wall_volumetric_speed/2.4} A0.3 ; cali dynamic extrusion compensation\nM1002 judge_flag filament_need_cali_flag\nM622 J1\n  G92 E0\n  G1 E-[new_retract_length_toolchange] F1800\n  M400\n  \n  M106 P1 S178\n  M400 S7\n  G1 X0 F18000\n  G1 X-13.5 F3000\n  G1 X0 F18000 ;wipe and shake\n  G1 X-13.5 F3000\n  G1 X0 F12000 ;wipe and shake\n  G1 X-13.5 F3000\n  G1 X0 F12000 ;wipe and shake\n  M400\n  M106 P1 S0 \nM623\n\nM621 S[next_extruder]A\nG392 S0\n\nM1007 S1\n
; circle_compensation_manual_offset = 0
; circle_compensation_speed = 200,200
; close_additional_fan_first_x_layers = 1,1
; close_fan_the_first_x_layers = 1,1
; complete_print_exhaust_fan_speed = 70,70
; cool_plate_temp = 35,35
; cool_plate_temp_initial_layer = 35,35
; cooling_filter_enabled = 0
; cooling_perimeter_transition_distance = 10,10
; cooling_slowdown_logic = uniform_cooling,uniform_cooling
; counter_coef_1 = 0,0
; counter_coef_2 = 0.008,0.008
; counter_coef_3 = -0.041,-0.041
; counter_limit_max = 0.033,0.033
; counter_limit_min = -0.035,-0.035
; counterbore_hole_bridging = none
; curr_bed_type = Textured PEI Plate
; default_acceleration = 6000
; default_ams_type = -1
; default_filament_colour = ;
; default_filament_profile = "Bambu PLA Basic @BBL A1M"
; default_jerk = 0
; default_nozzle_volume_type = Standard
; default_print_profile = 0.20mm Standard @BBL A1M
; deretraction_speed = 30
; detect_floating_vertical_shell = 1
; detect_narrow_internal_solid_infill = 1
; detect_overhang_wall = 1
; detect_thin_wall = 0
; diameter_limit = 50,50
; different_settings_to_system = bottom_color_penetration_layers;bridge_speed;enable_support;min_feature_size;support_filament;support_interface_filament;support_on_build_plate_only;support_remove_small_overhang;support_top_z_distance;thick_bridges;top_color_penetration_layers;wall_generator;;;
; draft_shield = disabled
; during_print_exhaust_fan_speed = 70,70
; elefant_foot_compensation = 0
; embedding_wall_into_infill = 0
; enable_arc_fitting = 1
; enable_circle_compensation = 0
; enable_filament_dynamic_map = 0
; enable_height_slowdown = 0
; enable_long_retraction_when_cut = 2
; enable_mixed_color_sublayer = 0
; enable_order_independent_overlap_carving = 0
; enable_overhang_bridge_fan = 1,1
; enable_overhang_speed = 1
; enable_pre_heating = 0
; enable_pressure_advance = 0,0
; enable_prime_tower = 0
; enable_support = 1
; enable_support_ironing = 0
; enable_tower_interface_features = 0
; enable_wrapping_detection = 0
; enforce_support_layers = 0
; eng_plate_temp = 0,0
; eng_plate_temp_initial_layer = 0,0
; ensure_vertical_shell_thickness = enabled
; exclude_object = 1
; extruder_ams_count = 1#0|4#0;
; extruder_clearance_dist_to_rod = 56.5
; extruder_clearance_height_to_lid = 180
; extruder_clearance_height_to_rod = 25
; extruder_clearance_max_radius = 73
; extruder_colour = #018001
; extruder_max_nozzle_count = 1
; extruder_nozzle_stats = Standard#1
; extruder_nozzle_stats_new = 
; extruder_offset = 0x0
; extruder_printable_area = 
; extruder_type = Direct Drive
; extruder_variant_list = "Direct Drive Standard"
; fan_cooling_layer_time = 80,80
; fan_direction = undefine
; fan_max_speed = 80,80
; fan_min_speed = 60,60
; farthest_point_timelapse = 0
; filament_adaptive_volumetric_speed = 0,0
; filament_adhesiveness_category = 100,100
; filament_bridge_speed = 25,25
; filament_change_length = 10,10
; filament_change_length_nc = 10,10
; filament_colour = #FFFFFF;#0000FF
; filament_colour_type = 1;1
; filament_cooling_before_tower = 0,0
; filament_cost = 20,20
; filament_density = 1.24,1.24
; filament_dev_ams_drying_ams_limitations = 1;0;1;0
; filament_dev_ams_drying_heat_distortion_temperature = 45,45
; filament_dev_ams_drying_temperature = 45,45,45,45,45,45,45,45
; filament_dev_ams_drying_time = 12,12,12,12,12,12,12,12
; filament_dev_chamber_drying_bed_temperature = 70,70
; filament_dev_chamber_drying_time = 12,12
; filament_dev_drying_cooling_temperature = 45,45
; filament_dev_drying_softening_temperature = 50,50
; filament_diameter = 1.75,1.75
; filament_enable_overhang_speed = 1,1
; filament_end_gcode = "; filament end gcode \n\n";"; filament end gcode \n\n"
; filament_extruder_compatibility = 0,0
; filament_extruder_variant = "Direct Drive Standard";"Direct Drive Standard"
; filament_flow_ratio = 0.98,0.98
; filament_flush_temp = 0,0
; filament_flush_temp_fast = 0,0
; filament_flush_volumetric_speed = 0,0
; filament_ids = GFL99;GFL99
; filament_is_mixed = 0,0
; filament_is_support = 0,0
; filament_map = 1,1
; filament_map_2 = 0,0
; filament_map_mode = Auto For Flush
; filament_max_volumetric_speed = 12,12
; filament_metal_stickiness = None,None
; filament_minimal_purge_on_wipe_tower = 15,15
; filament_mixed_components = ;
; filament_mixed_gradient = 0,0
; filament_mixed_gradient_curve = ;
; filament_mixed_gradient_per_part = 0,0
; filament_mixed_gradient_range = ;
; filament_mixed_sublayer_ratios = ;
; filament_multi_colour = #FFFFFF;#0000FF
; filament_notes = 
; filament_nozzle_map = 0,0
; filament_overhang_1_4_speed = 0,0
; filament_overhang_2_4_speed = 50,50
; filament_overhang_3_4_speed = 30,30
; filament_overhang_4_4_speed = 10,10
; filament_overhang_totally_speed = 10,10
; filament_pre_cooling_temperature = 0,0
; filament_pre_cooling_temperature_nc = 0,0
; filament_preheat_temperature_delta = 0,0
; filament_prime_volume = 45,45
; filament_prime_volume_nc = 60,60
; filament_printable = 3,3
; filament_ramming_travel_time = 0,0
; filament_ramming_travel_time_nc = 0,0
; filament_ramming_volumetric_speed = -1,-1
; filament_ramming_volumetric_speed_nc = -1,-1
; filament_retract_length_nc = 14,14
; filament_scarf_gap = 15%,15%
; filament_scarf_height = 10%,10%
; filament_scarf_length = 10,10
; filament_scarf_seam_type = none,none
; filament_self_index = 1,2
; filament_settings_id = "Generic PLA @BBL A1M";"Generic PLA @BBL A1M"
; filament_shrink = 100%,100%
; filament_soluble = 0,0
; filament_start_gcode = "; filament start gcode\n{if  (bed_temperature[current_extruder] >45)||(bed_temperature_initial_layer[current_extruder] >45)}M106 P3 S255\n{elsif(bed_temperature[current_extruder] >35)||(bed_temperature_initial_layer[current_extruder] >35)}M106 P3 S180\n{endif};Prevent PLA from jamming\n\n\n{if activate_air_filtration[current_extruder] && support_air_filtration}\nM106 P3 S{during_print_exhaust_fan_speed_num[current_extruder]} \n{endif}";"; filament start gcode\n{if  (bed_temperature[current_extruder] >45)||(bed_temperature_initial_layer[current_extruder] >45)}M106 P3 S255\n{elsif(bed_temperature[current_extruder] >35)||(bed_temperature_initial_layer[current_extruder] >35)}M106 P3 S180\n{endif};Prevent PLA from jamming\n\n\n{if activate_air_filtration[current_extruder] && support_air_filtration}\nM106 P3 S{during_print_exhaust_fan_speed_num[current_extruder]} \n{endif}"
; filament_tower_interface_pre_extrusion_dist = 10,10
; filament_tower_interface_pre_extrusion_length = 0,0
; filament_tower_interface_print_temp = -1,-1
; filament_tower_interface_purge_volume = 20,20
; filament_tower_ironing_area = 4,4
; filament_type = PLA;PLA
; filament_velocity_adaptation_factor = 1,1
; filament_vendor = Generic;Generic
; filament_volume_map = 0,0,0
; filename_format = {input_filename_base}_{filament_type[0]}_{print_time}.gcode
; fill_multiline = 1
; filter_out_gap_fill = 0
; first_layer_print_sequence = 0
; first_x_layer_fan_speed = 0,0
; first_x_layer_part_fan_speed = 0,0
; flush_into_infill = 0
; flush_into_objects = 0
; flush_into_support = 1
; flush_multiplier = 1.5
; flush_multiplier_fast = 1.2
; flush_volumes_matrix = 0,546,1129.5,0
; flush_volumes_vector = 140,140,140,140
; full_fan_speed_layer = 0,0
; fuzzy_skin = none
; fuzzy_skin_first_layer = 0
; fuzzy_skin_mode = displacement
; fuzzy_skin_noise_type = classic
; fuzzy_skin_octaves = 4
; fuzzy_skin_persistence = 0.5
; fuzzy_skin_point_distance = 0.8
; fuzzy_skin_scale = 1
; fuzzy_skin_thickness = 0.3
; gap_infill_speed = 250
; gcode_add_line_number = 0
; gcode_flavor = marlin
; grab_length = 17.4
; group_algo_with_time = 0
; has_filament_switcher = 0
; has_scarf_joint_seam = 0
; head_wrap_detect_zone = 156x152,180x152,180x180,156x180
; hole_coef_1 = 0,0
; hole_coef_2 = -0.008,-0.008
; hole_coef_3 = 0.23415,0.23415
; hole_limit_max = 0.22,0.22
; hole_limit_min = 0.088,0.088
; host_type = octoprint
; hot_plate_temp = 60,60
; hot_plate_temp_initial_layer = 60,60
; hotend_cooling_rate = 2
; hotend_heating_rate = 2
; impact_strength_z = 10,10
; independent_support_layer_height = 1
; infill_combination = 0
; infill_direction = 45
; infill_instead_top_bottom_surfaces = 0
; infill_jerk = 9
; infill_lock_depth = 1
; infill_rotate_step = 0
; infill_shift_step = 0.4
; infill_wall_overlap = 15%
; inherits_group = "0.20mm Standard @BBL A1M";;;
; initial_layer_acceleration = 500
; initial_layer_flow_ratio = 1
; initial_layer_infill_speed = 105
; initial_layer_jerk = 9
; initial_layer_line_width = 0.5
; initial_layer_print_height = 0.2
; initial_layer_speed = 50
; initial_layer_travel_acceleration = 6000
; inner_wall_acceleration = 0
; inner_wall_jerk = 9
; inner_wall_line_width = 0.45
; inner_wall_speed = 300
; interface_shells = 0
; interlocking_beam = 0
; interlocking_beam_layer_count = 2
; interlocking_beam_width = 0.8
; interlocking_boundary_avoidance = 2
; interlocking_depth = 2
; interlocking_orientation = 22.5
; internal_bridge_support_thickness = 0.8
; internal_solid_infill_line_width = 0.42
; internal_solid_infill_pattern = zig-zag
; internal_solid_infill_speed = 250
; ironing_direction = 45
; ironing_fan_speed = -1,-1
; ironing_flow = 10%
; ironing_inset = 0.21
; ironing_pattern = zig-zag
; ironing_spacing = 0.15
; ironing_speed = 30
; ironing_type = no ironing
; is_infill_first = 0
; layer_change_gcode = ; layer num/total_layer_count: {layer_num+1}/[total_layer_count]\n; update layer progress\nM73 L{layer_num+1}\nM991 S0 P{layer_num} ;notify layer change
; layer_height = 0.2
; line_width = 0.42
; locked_skeleton_infill_pattern = zigzag
; locked_skin_infill_pattern = crosszag
; long_retractions_when_cut = 0
; long_retractions_when_ec = 0,0
; machine_bed_mass_Y = 0
; machine_end_gcode = ;===== date: 20260513 =====================\n;turn off nozzle clog detect\nG392 S0\n\nM400 ; wait for buffer to clear\nG92 E0 ; zero the extruder\nG90\nG1 Z{max_layer_z + 0.4} F900 ; lower z a little\nG1 X0 Y{first_layer_center_no_wipe_tower[1]} F18000 ; move to safe pos\nG1 X-13.0 F3000 ; move to safe pos\n{if !spiral_mode && print_sequence != \"by object\"}\nM1002 judge_flag timelapse_record_flag\nM622 J1\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM400 P100\nM971 S11 C11 O0\nM991 S0 P-1 ;end timelapse at safe pos\nM623\n{endif}\n\nM140 S0 ; turn off bed\nM106 S0 ; turn off fan\nM106 P2 S0 ; turn off remote part cooling fan\nM106 P3 S0 ; turn off chamber cooling fan\n\n;G1 X27 F15000 ; wipe\n\n; pull back filament to AMS\nM620 S255\nG1 X181 F12000\nT255\nG1 X0 F18000\nG1 X-13.0 F3000\nG1 X0 F18000 ; wipe\nM621 S255\n\nM104 S0 ; turn off hotend\n\nM400 ; wait all motion done\nM17 S\nM17 Z0.4 ; lower z motor current to reduce impact if there is something in the bottom\n{if (max_layer_z + 100.0) < 180}\n    G1 Z{max_layer_z + 100.0} F600\n    G1 Z{max_layer_z +98.0}\n{else}\n    G1 Z180 F600\n    G1 Z180\n{endif}\nM400 P100\nM17 R ; restore z current\n\nG90\nG1 X-13 Y180 F3600\n\nG91\nG1 Z-1 F600\nG90\nM83\n\nM220 S100  ; Reset feedrate magnitude\nM201.2 K1.0 ; Reset acc magnitude\nM73.2   R1.0 ;Reset left time magnitude\nM1002 set_gcode_claim_speed_level : 0\n\n;=====printer finish  sound=========\nM17\nM400 S1\nM1006 S1\nM1006 A0 B20 L100 C37 D20 M100 E42 F20 N100\nM1006 A0 B10 L100 C44 D10 M100 E44 F10 N100\nM1006 A0 B10 L100 C46 D10 M100 E46 F10 N100\nM1006 A44 B20 L100 C39 D20 M100 E48 F20 N100\nM1006 A0 B10 L100 C44 D10 M100 E44 F10 N100\nM1006 A0 B10 L100 C0 D10 M100 E0 F10 N100\nM1006 A0 B10 L100 C39 D10 M100 E39 F10 N100\nM1006 A0 B10 L100 C0 D10 M100 E0 F10 N100\nM1006 A0 B10 L100 C44 D10 M100 E44 F10 N100\nM1006 A0 B10 L100 C0 D10 M100 E0 F10 N100\nM1006 A0 B10 L100 C39 D10 M100 E39 F10 N100\nM1006 A0 B10 L100 C0 D10 M100 E0 F10 N100\nM1006 A44 B10 L100 C0 D10 M100 E48 F10 N100\nM1006 A0 B10 L100 C0 D10 M100 E0 F10 N100\nM1006 A44 B20 L100 C41 D20 M100 E49 F20 N100\nM1006 A0 B20 L100 C0 D20 M100 E0 F20 N100\nM1006 A0 B20 L100 C37 D20 M100 E37 F20 N100\nM1006 W\n;=====printer finish  sound=========\nM400 S1\nM18 X Y Z\n
; machine_hotend_change_time = 0
; machine_load_filament_time = 28
; machine_max_acceleration_e = 5000,5000
; machine_max_acceleration_extruding = 20000,20000
; machine_max_acceleration_retracting = 5000,5000
; machine_max_acceleration_travel = 9000,9000
; machine_max_acceleration_x = 20000,20000
; machine_max_acceleration_y = 20000,20000
; machine_max_acceleration_z = 1500,1500
; machine_max_force_Y = 0
; machine_max_jerk_e = 3,3
; machine_max_jerk_x = 9,9
; machine_max_jerk_y = 9,9
; machine_max_jerk_z = 5,5
; machine_max_printed_mass = 0
; machine_max_speed_e = 30,30
; machine_max_speed_x = 500,200
; machine_max_speed_y = 500,200
; machine_max_speed_z = 30,30
; machine_min_extruding_rate = 0,0
; machine_min_travel_rate = 0,0
; machine_pause_gcode = M400 U1
; machine_prepare_compensation_time = 260
; machine_start_gcode = ;===== machine: A1 mini =========================\n;===== date: 20260513 ==================\n\n;===== start to heat heatbead&hotend==========\nM1002 gcode_claim_action : 2\nM1002 set_filament_type:{filament_type[initial_no_support_extruder]}\nM104 S170\nM140 S[bed_temperature_initial_layer_single]\nG392 S0 ;turn off clog detect\nM9833.2\n;=====start printer sound ===================\nM17\nM400 S1\nM1006 S1\nM1006 A0 B0 L100 C37 D10 M100 E37 F10 N100\nM1006 A0 B0 L100 C41 D10 M100 E41 F10 N100\nM1006 A0 B0 L100 C44 D10 M100 E44 F10 N100\nM1006 A0 B10 L100 C0 D10 M100 E0 F10 N100\nM1006 A43 B10 L100 C39 D10 M100 E46 F10 N100\nM1006 A0 B0 L100 C0 D10 M100 E0 F10 N100\nM1006 A0 B0 L100 C39 D10 M100 E43 F10 N100\nM1006 A0 B0 L100 C0 D10 M100 E0 F10 N100\nM1006 A0 B0 L100 C41 D10 M100 E41 F10 N100\nM1006 A0 B0 L100 C44 D10 M100 E44 F10 N100\nM1006 A0 B0 L100 C49 D10 M100 E49 F10 N100\nM1006 A0 B0 L100 C0 D10 M100 E0 F10 N100\nM1006 A44 B10 L100 C39 D10 M100 E48 F10 N100\nM1006 A0 B0 L100 C0 D10 M100 E0 F10 N100\nM1006 A0 B0 L100 C39 D10 M100 E44 F10 N100\nM1006 A0 B0 L100 C0 D10 M100 E0 F10 N100\nM1006 A43 B10 L100 C39 D10 M100 E46 F10 N100\nM1006 W\nM18\n;=====avoid end stop =================\nG91\nG380 S2 Z30 F1200\nG380 S3 Z-20 F1200\nG1 Z5 F1200\nG90\n\n;===== reset machine status =================\nM204 S6000\n\nM630 S0 P0\nG91\nM17 Z0.3 ; lower the z-motor current\n\nG90\nM17 X0.7 Y0.9 Z0.5 ; reset motor current to default\nM960 S5 P1 ; turn on logo lamp\nG90\nM83\nM220 S100 ;Reset Feedrate\nM221 S100 ;Reset Flowrate\nM73.2   R1.0 ;Reset left time magnitude\n;====== cog noise reduction=================\nM982.2 S1 ; turn on cog noise reduction\n\n;===== prepare print temperature and material ==========\nM400\nM18\nM109 S100 H170\nM104 S170\nM400\nM17\nM400\nG28 X\n\nM211 X0 Y0 Z0 ;turn off soft endstop ; turn off soft endstop to prevent protential logic problem\n\nM975 S1 ; turn on\n\nG1 X0.0 F30000\nG1 X-13.5 F3000\n\nM620 M ;enable remap\nM620 S[initial_no_support_extruder]A   ; switch material if AMS exist\n    G392 S0 ;turn on clog detect\n    M1002 gcode_claim_action : 4\n    M400\n    M1002 set_filament_type:UNKNOWN\n    M109 S[nozzle_temperature_initial_layer]\n{if (filament_type[initial_no_support_extruder] == \"PLA\") && (nozzle_diameter != 0.2)}\n    M104 S220\n{else}\n    M104 S250\n{endif}\n    M400\n    T[initial_no_support_extruder]\n    G1 X-13.5 F3000\n    M400\n{if (filament_type[initial_no_support_extruder] == \"PLA\") && (nozzle_diameter != 0.2)}\n    M620.1 E F{flush_volumetric_speeds[initial_no_support_extruder]/2.4053*60} T220\n    M109 S220 ;set nozzle to common flush temp\n{else}\n    M620.1 E F{flush_volumetric_speeds[initial_no_support_extruder]/2.4053*60} T{flush_temperatures[initial_no_support_extruder]}\n    M109 S250 ;set nozzle to common flush temp\n{endif}\n    M106 P1 S0\n    G92 E0\n    G1 E50 F200\n    M400\n    M1002 set_filament_type:{filament_type[initial_no_support_extruder]}\n{if (filament_type[initial_no_support_extruder] == \"PLA\") && (nozzle_diameter != 0.2)}\n    M104 S220\n{else}\n    M104 S{flush_temperatures[initial_no_support_extruder]}\n{endif}\n    G92 E0\n    G1 E50 F{flush_volumetric_speeds[initial_no_support_extruder]/2.4053*60}\n    M400\n    M106 P1 S178\n    G92 E0\n    G1 E5 F{flush_volumetric_speeds[initial_no_support_extruder]/2.4053*60}\n    M109 S{nozzle_temperature_initial_layer[initial_no_support_extruder]-20} ; drop nozzle temp, make filament shink a bit\n    M104 S{nozzle_temperature_initial_layer[initial_no_support_extruder]-40}\n    G92 E0\n    G1 E-0.5 F300\n\n    G1 X0 F30000\n    G1 X-13.5 F3000\n    G1 X0 F30000 ;wipe and shake\n    G1 X-13.5 F3000\n    G1 X0 F12000 ;wipe and shake\n    G1 X0 F30000\n    G1 X-13.5 F3000\n    M109 S{nozzle_temperature_initial_layer[initial_no_support_extruder]-40}\n    G392 S0 ;turn off clog detect\nM621 S[initial_no_support_extruder]A\n\nM400\nM106 P1 S0\n;===== prepare print temperature and material end =====\n\n\n;===== mech mode fast check============================\nM1002 gcode_claim_action : 3\nG0 X25 Y175 F20000 ; find a soft place to home\n;M104 S0\nG28 Z P0 T300; home z with low precision,permit 300deg temperature\nG29.2 S0 ; turn off ABL\nM104 S170\n\n; build plate detect\nM1002 judge_flag build_plate_detect_flag\nM622 S1\n  G39.4\n  M400\nM623\n\nG1 Z5 F3000\nG1 X90 Y-1 F30000\nM400 P200\nM970.3 Q1 A7 K0 O2\nM974 Q1 S2 P0\n\nG1 X90 Y0 Z5 F30000\nM400 P200\nM970 Q0 A10 B50 C90 H15 K0 M20 O3\nM974 Q0 S2 P0\n\nM975 S1\nG1 F30000\nG1 X-1 Y10\nG28 X ; re-home XY\n\n;===== wipe nozzle ===============================\nM1002 gcode_claim_action : 14\nM975 S1\n\nM104 S170 ; set temp down to heatbed acceptable\nM106 S255 ; turn on fan (G28 has turn off fan)\nM211 S; push soft endstop status\nM211 X0 Y0 Z0 ;turn off Z axis endstop\n\nM83\nG1 E-1 F500\nG90\nM83\n\nM109 S170\nM104 S140\nG0 X90 Y-4 F30000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X91 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X92 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X93 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X94 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X95 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X96 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X97 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X98 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X99 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X99 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X99 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X99 F10000\nG380 S3 Z-5 F1200\nG1 Z2 F1200\nG1 X99 F10000\nG380 S3 Z-5 F1200\n\nG1 Z5 F30000\n;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\nG1 X25 Y175 F30000.1 ;Brush material\nG1 Z0.2 F30000.1\nG1 Y185\nG91\nG1 X-30 F30000\nG1 Y-2\nG1 X27\nG1 Y1.5\nG1 X-28\nG1 Y-2\nG1 X30\nG1 Y1.5\nG1 X-30\nG90\nM83\n\nG1 Z5 F3000\nG0 X50 Y175 F20000 ; find a soft place to home\nG28 Z P0 T300; home z with low precision, permit 300deg temperature\nG29.2 S0 ; turn off ABL\n\nG0 X85 Y185 F10000 ;move to exposed steel surface and stop the nozzle\nG0 Z-1.01 F10000\nG91\n\nG2 I1 J0 X2 Y0 F2000.1\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\nG2 I1 J0 X2\nG2 I-0.75 J0 X-1.5\n\nG90\nG1 Z5 F30000\nG1 X25 Y175 F30000.1 ;Brush material\nG1 Z0.2 F30000.1\nG1 Y185\nG91\nG1 X-30 F30000\nG1 Y-2\nG1 X27\nG1 Y1.5\nG1 X-28\nG1 Y-2\nG1 X30\nG1 Y1.5\nG1 X-30\nG90\nM83\n\nG1 Z5\nG0 X55 Y175 F20000 ; find a soft place to home\nG28 Z P0 T300; home z with low precision, permit 300deg temperature\nG29.2 S0 ; turn off ABL\n\nG1 Z10\nG1 X85 Y185\nG1 Z-1.01\nG1 X95\nG1 X90\n\nM211 R; pop softend status\n\nM106 S0 ; turn off fan , too noisy\n;===== wipe nozzle end ================================\n\n\n;===== wait heatbed  ====================\nM1002 gcode_claim_action:54\nM104 S0\nM190 S[bed_temperature_initial_layer_single];set bed temp\nM109 S140\n\nG1 Z5 F3000\nG29.2 S1\nG1 X10 Y10 F20000\n\n;===== bed leveling ==================================\n;M1002 set_flag g29_before_print_flag=1\nM1002 judge_flag g29_before_print_flag\nM622 J1\n    M1002 gcode_claim_action : 1\n    G29 A1 X{first_layer_print_min[0]} Y{first_layer_print_min[1]} I{first_layer_print_size[0]} J{first_layer_print_size[1]}\n    M400\n    M500 ; save cali data\nM623\n;===== bed leveling end ================================\n\n;===== home after wipe mouth============================\nM1002 judge_flag g29_before_print_flag\nM622 J0\n\n    M1002 gcode_claim_action : 13\n    G28 T145\n\nM623\n\n;===== home after wipe mouth end =======================\n\nM975 S1 ; turn on vibration supression\n;===== nozzle load line ===============================\nM975 S1\nG90\nM83\nT1000\n\nG1 X-13.5 Y0 Z10 F10000\nG1 E1.2 F500\nM400\nM1002 set_filament_type:UNKNOWN\nM109 S{nozzle_temperature[initial_extruder]}\nM400\n\nM412 S1 ;    ===turn on  filament runout detection===\nM400 P10\n\nG392 S0 ;turn on clog detect\n\nM620.3 W1; === turn on filament tangle detection===\nM400 S2\n\nM1002 set_filament_type:{filament_type[initial_no_support_extruder]}\n;M1002 set_flag extrude_cali_flag=1\nM1002 judge_flag extrude_cali_flag\nM622 J1\n    M1002 gcode_claim_action : 8\n    \n    M400\n    M900 K0.0 L1000.0 M1.0\n    G90\n    M83\n    G0 X68 Y-4 F30000\n    G0 Z0.3 F18000 ;Move to start position\n    M400\n    G0 X88 E10  F{outer_wall_volumetric_speed/(24/20)    * 60}\n    G0 X93 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G0 X98 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\n    G0 X103 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G0 X108 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\n    G0 X113 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\n    G0 Y0 Z0 F20000\n    M400\n    \n    G1 X-13.5 Y0 Z10 F10000\n    M400\n    \n    G1 E10 F{outer_wall_volumetric_speed/2.4*60}\n    M983 F{outer_wall_volumetric_speed/2.4} A0.3 H[nozzle_diameter]; cali dynamic extrusion compensation\n    M106 P1 S178\n    M400 S7\n    G1 X0 F18000\n    G1 X-13.5 F3000\n    G1 X0 F18000 ;wipe and shake\n    G1 X-13.5 F3000\n    G1 X0 F12000 ;wipe and shake\n    G1 X-13.5 F3000\n    M400\n    M106 P1 S0\n\n    M1002 judge_last_extrude_cali_success\n    M622 J0\n        M983 F{outer_wall_volumetric_speed/2.4} A0.3 H[nozzle_diameter]; cali dynamic extrusion compensation\n        M106 P1 S178\n        M400 S7\n        G1 X0 F18000\n        G1 X-13.5 F3000\n        G1 X0 F18000 ;wipe and shake\n        G1 X-13.5 F3000\n        G1 X0 F12000 ;wipe and shake\n        M400\n        M106 P1 S0\n    M623\n    \n    G1 X-13.5 F3000\n    M400\n    M984 A0.1 E1 S1 F{outer_wall_volumetric_speed/2.4} H[nozzle_diameter]\n    M106 P1 S178\n    M400 S7\n    G1 X0 F18000\n    G1 X-13.5 F3000\n    G1 X0 F18000 ;wipe and shake\n    G1 X-13.5 F3000\n    G1 X0 F12000 ;wipe and shake\n    G1 X-13.5 F3000\n    M400\n    M106 P1 S0\n\nM623 ; end of \"draw extrinsic para cali paint\"\n\n;===== extrude cali test ===============================\nM104 S{nozzle_temperature_initial_layer[initial_extruder]}\nG90\nM83\nG0 X68 Y-2.5 F30000\nG0 Z0.3 F18000 ;Move to start position\nG0 X88 E10  F{outer_wall_volumetric_speed/(24/20)    * 60}\nG0 X93 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\nG0 X98 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\nG0 X103 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\nG0 X108 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)     * 60}\nG0 X113 E.3742  F{outer_wall_volumetric_speed/(0.3*0.5)/4     * 60}\nG0 X115 Z0 F20000\nG0 Z5\nM400\n\n;========turn off light and wait extrude temperature =============\nM1002 gcode_claim_action : 0\n\nM400 ; wait all motion done before implement the emprical L parameters\n\n;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==\n;curr_bed_type={curr_bed_type}\n{if curr_bed_type==\"Textured PEI Plate\"}\nG29.1 Z{-0.02} ; for Textured PEI Plate\n{endif}\n\nM960 S1 P0 ; turn off laser\nM960 S2 P0 ; turn off laser\nM106 S0 ; turn off fan\nM106 P2 S0 ; turn off big fan\nM106 P3 S0 ; turn off chamber fan\n\nM975 S1 ; turn on mech mode supression\nG90\nM83\nT1000\n\nM211 X0 Y0 Z0 ;turn off soft endstop\nM1007 S1\n\n\n\n
; machine_switch_extruder_time = 0
; machine_unload_filament_time = 34
; master_extruder_id = 1
; max_bridge_length = 0
; max_layer_height = 0.28
; max_travel_detour_distance = 0
; min_bead_width = 85%
; min_feature_size = 1%
; min_layer_height = 0.08
; minimum_sparse_infill_area = 15
; mmu_segmented_region_interlocking_depth = 0
; mmu_segmented_region_max_width = 0
; monotonic_travel_into_wall = 0%
; no_slow_down_for_cooling_on_outwalls = 0,0
; nozzle_diameter = 0.4
; nozzle_flush_dataset = 0
; nozzle_height = 4.76
; nozzle_temperature = 220,220
; nozzle_temperature_initial_layer = 220,220
; nozzle_temperature_range_high = 240,240
; nozzle_temperature_range_low = 190,190
; nozzle_type = stainless_steel
; nozzle_volume = 92
; nozzle_volume_type = Standard
; only_one_wall_first_layer = 0
; ooze_prevention = 0
; other_layers_print_sequence = 0
; other_layers_print_sequence_nums = 0
; outer_wall_acceleration = 5000
; outer_wall_jerk = 9
; outer_wall_line_width = 0.42
; outer_wall_speed = 200
; overhang_1_4_speed = 0
; overhang_2_4_speed = 50
; overhang_3_4_speed = 30
; overhang_4_4_speed = 10
; overhang_fan_speed = 100,100
; overhang_fan_threshold = 50%,50%
; overhang_threshold_participating_cooling = 95%,95%
; overhang_totally_speed = 10
; override_filament_scarf_seam_setting = 0
; override_process_overhang_speed = 0,0
; physical_extruder_map = 0
; post_process = 
; pre_start_fan_time = 0,0
; precise_outer_wall = 0
; precise_z_height = 0
; pressure_advance = 0.02,0.02
; prime_tower_brim_width = 3
; prime_tower_enable_framework = 0
; prime_tower_extra_rib_length = 0
; prime_tower_fillet_wall = 1
; prime_tower_flat_ironing = 0
; prime_tower_infill_gap = 150%
; prime_tower_lift_height = -1
; prime_tower_lift_speed = 90
; prime_tower_max_speed = 90
; prime_tower_rib_wall = 1
; prime_tower_rib_width = 8
; prime_tower_skip_points = 1
; prime_tower_width = 35
; prime_volume_mode = Default
; print_compatible_printers = "Bambu Lab A1 mini 0.4 nozzle"
; print_extruder_id = 1
; print_extruder_variant = "Direct Drive Standard"
; print_flow_ratio = 1
; print_in_clockwise = 0
; print_sequence = by layer
; print_settings_id = 0.2mm NFC Keychain A1 Mini
; printable_area = 0x0,180x0,180x180,0x180
; printable_height = 180
; printer_extruder_id = 1
; printer_extruder_variant = "Direct Drive Standard"
; printer_model = Bambu Lab A1 mini
; printer_notes = 
; printer_settings_id = Bambu Lab A1 mini 0.4 nozzle
; printer_structure = i3
; printer_technology = FFF
; printer_variant = 0.4
; printhost_authorization_type = key
; printhost_ssl_ignore_revoke = 0
; printing_by_object_gcode = 
; process_notes = 
; raft_contact_distance = 0.1
; raft_expansion = 1.5
; raft_first_layer_density = 90%
; raft_first_layer_expansion = -1
; raft_layers = 0
; reduce_crossing_wall = 0
; reduce_fan_stop_start_freq = 1,1
; reduce_infill_retraction_mode = Auto
; required_nozzle_HRC = 3,3
; resolution = 0.012
; retract_before_wipe = 0%
; retract_length_toolchange = 2
; retract_lift_above = 0
; retract_lift_below = 179
; retract_restart_extra = 0
; retract_restart_extra_toolchange = 0
; retract_when_changing_layer = 1
; retraction_distances_when_cut = 18
; retraction_distances_when_ec = 0,0
; retraction_length = 0.8
; retraction_minimum_travel = 1
; retraction_speed = 30
; role_base_wipe_speed = 1
; scan_first_layer = 0
; scarf_angle_threshold = 155
; seam_gap = 15%
; seam_placement_away_from_overhangs = 0
; seam_position = aligned
; seam_slope_conditional = 1
; seam_slope_entire_loop = 0
; seam_slope_gap = 0
; seam_slope_inner_walls = 1
; seam_slope_min_length = 10
; seam_slope_start_height = 10%
; seam_slope_steps = 10
; seam_slope_type = none
; silent_mode = 0
; single_extruder_multi_material = 1
; skeleton_infill_density = 15%
; skeleton_infill_line_width = 0.45
; skin_infill_density = 15%
; skin_infill_depth = 2
; skin_infill_line_width = 0.45
; skirt_distance = 2
; skirt_height = 1
; skirt_loops = 0
; skirt_per_object = 1
; slice_closing_radius = 0.049
; slicing_mode = regular
; slow_down_for_layer_cooling = 1,1
; slow_down_layer_time = 8,8
; slow_down_min_speed = 20,20
; slowdown_end_acc = 100000
; slowdown_end_height = 400
; slowdown_end_speed = 1000
; slowdown_start_acc = 100000
; slowdown_start_height = 0
; slowdown_start_speed = 1000
; small_perimeter_speed = 50%
; small_perimeter_threshold = 0
; smooth_coefficient = 80
; smooth_speed_discontinuity_area = 1
; solid_infill_filament = 0
; sparse_infill_acceleration = 100%
; sparse_infill_anchor = 400%
; sparse_infill_anchor_max = 20
; sparse_infill_density = 15%
; sparse_infill_filament = 0
; sparse_infill_lattice_angle_1 = -45
; sparse_infill_lattice_angle_2 = 45
; sparse_infill_line_width = 0.45
; sparse_infill_pattern = grid
; sparse_infill_speed = 270
; spiral_mode = 0
; spiral_mode_max_xy_smoothing = 200%
; spiral_mode_smooth = 0
; standby_temperature_delta = -5
; start_end_points = 30x-3,54x245
; supertack_plate_temp = 45,45
; supertack_plate_temp_initial_layer = 45,45
; support_air_filtration = 0
; support_angle = 0
; support_base_pattern = default
; support_base_pattern_spacing = 2.5
; support_bottom_interface_spacing = 0.5
; support_bottom_z_distance = 0.2
; support_chamber_temp_control = 0
; support_cooling_filter = 0
; support_critical_regions_only = 0
; support_expansion = 0
; support_fast_purge_mode = 0
; support_filament = 1
; support_interface_bottom_layers = 2
; support_interface_filament = 1
; support_interface_loop_pattern = 0
; support_interface_not_for_body = 1
; support_interface_pattern = auto
; support_interface_spacing = 0.5
; support_interface_speed = 80
; support_interface_top_layers = 2
; support_ironing_direction = 0
; support_ironing_flow = 10%
; support_ironing_inset = 0
; support_ironing_pattern = zig-zag
; support_ironing_spacing = 0.15
; support_ironing_speed = 30
; support_line_width = 0.42
; support_object_first_layer_gap = 0.2
; support_object_skip_flush = 0
; support_object_xy_distance = 0.35
; support_on_build_plate_only = 1
; support_remove_small_overhang = 0
; support_speed = 150
; support_style = default
; support_threshold_angle = 30
; support_top_z_distance = 0.26
; support_type = tree(auto)
; symmetric_infill_y_axis = 0
; temperature_vitrification = 45,45
; template_custom_gcode = 
; textured_plate_temp = 65,65
; textured_plate_temp_initial_layer = 65,65
; thick_bridges = 1
; thumbnail_size = 50x50
; time_lapse_gcode = ;===================== date: 20250206 =====================\n{if !spiral_mode && print_sequence != \"by object\"}\n; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer\n; SKIPPABLE_START\n; SKIPTYPE: timelapse\nM622.1 S1 ; for prev firmware, default turned on\nM1002 judge_flag timelapse_record_flag\nM622 J1\nG92 E0\nG1 Z{max_layer_z + 0.4}\nG1 X0 Y{first_layer_center_no_wipe_tower[1]} F18000 ; move to safe pos\nG1 X-13.0 F3000 ; move to safe pos\nM400\nM1004 S5 P1  ; external shutter\nM400 P300\nM971 S11 C11 O0\nG92 E0\nG1 X0 F18000\nM623\n\n; SKIPTYPE: head_wrap_detect\nM622.1 S1\nM1002 judge_flag g39_3rd_layer_detect_flag\nM622 J1\n    ; enable nozzle clog detect at 3rd layer\n    {if layer_num == 2}\n      M400\n      G90\n      M83\n      M204 S5000\n      G0 Z2 F4000\n      G0 X187 Y178 F20000\n      G39 S1 X187 Y178\n      G0 Z2 F4000\n    {endif}\n\n\n    M622.1 S1\n    M1002 judge_flag g39_detection_flag\n    M622 J1\n      {if !in_head_wrap_detect_zone}\n        M622.1 S0\n        M1002 judge_flag g39_mass_exceed_flag\n        M622 J1\n        {if layer_num > 2}\n            G392 S0\n            M400\n            G90\n            M83\n            M204 S5000\n            G0 Z{max_layer_z + 0.4} F4000\n            G39.3 S1\n            G0 Z{max_layer_z + 0.4} F4000\n            G392 S0\n          {endif}\n        M623\n    {endif}\n    M623\nM623\n; SKIPPABLE_END\n{endif}\n\n\n
; timelapse_type = 0
; top_area_threshold = 200%
; top_color_penetration_layers = 2
; top_one_wall_type = all top
; top_shell_layers = 5
; top_shell_thickness = 1
; top_solid_infill_flow_ratio = 1
; top_surface_acceleration = 2000
; top_surface_density = 100%
; top_surface_jerk = 9
; top_surface_line_width = 0.42
; top_surface_pattern = monotonicline
; top_surface_speed = 200
; top_z_overrides_xy_distance = 0
; travel_acceleration = 10000
; travel_jerk = 9
; travel_short_distance_acceleration = 250
; travel_speed = 700
; travel_speed_z = 0
; tree_support_branch_angle = 45
; tree_support_branch_diameter = 2
; tree_support_branch_diameter_angle = 5
; tree_support_branch_distance = 5
; tree_support_wall_count = -1
; upward_compatible_machine = "Bambu Lab P1S 0.4 nozzle";"Bambu Lab P1P 0.4 nozzle";"Bambu Lab X1 0.4 nozzle";"Bambu Lab X1 Carbon 0.4 nozzle";"Bambu Lab X1E 0.4 nozzle";"Bambu Lab A1 0.4 nozzle";"Bambu Lab H2D 0.4 nozzle";"Bambu Lab H2D Pro 0.4 nozzle";"Bambu Lab H2S 0.4 nozzle";"Bambu Lab P2S 0.4 nozzle";"Bambu Lab H2C 0.4 nozzle";"Bambu Lab X2D 0.4 nozzle";"Bambu Lab A2L 0.4 nozzle"
; use_firmware_retraction = 0
; use_relative_e_distances = 1
; vertical_shell_speed = 80%
; volumetric_speed_coefficients = "0 0 0 0 0 0";"0 0 0 0 0 0"
; wall_distribution_count = 1
; wall_filament = 0
; wall_generator = arachne
; wall_loops = 2
; wall_sequence = inner wall/outer wall
; wall_transition_angle = 10
; wall_transition_filter_deviation = 25%
; wall_transition_length = 100%
; wipe = 1
; wipe_distance = 2
; wipe_speed = 80%
; wipe_tower_no_sparse_layers = 0
; wipe_tower_rotation_angle = 0
; wipe_tower_x = 107.736,44.2608,22.45,22.15,22.25,22.25,15
; wipe_tower_y = 131.673,113.987,134.947,134.847,134.847,134.847,140.972
; wrapping_detection_gcode = 
; wrapping_detection_layers = 20
; wrapping_exclude_area = 
; xy_contour_compensation = 0
; xy_hole_compensation = 0
; z_direction_outwall_speed_continuous = 0
; z_hop = 0.4
; z_hop_types = Auto Lift
; CONFIG_BLOCK_END

; EXECUTABLE_BLOCK_START
M73 P0 R21
M73 C13
M201 X20000 Y20000 Z1500 E5000
M203 X500 Y500 Z30 E30
M204 P20000 R5000 T20000
M205 X9.00 Y9.00 Z5.00 E3.00
M106 S0
; FEATURE: Custom
;===== machine: A1 mini =========================
;===== date: 20260513 ==================

;===== start to heat heatbead&hotend==========
M1002 gcode_claim_action : 2
M1002 set_filament_type:PLA
M104 S170
M140 S65
G392 S0 ;turn off clog detect
M9833.2
;=====start printer sound ===================
M17
M400 S1
M1006 S1
M1006 A0 B0 L100 C37 D10 M100 E37 F10 N100
M1006 A0 B0 L100 C41 D10 M100 E41 F10 N100
M1006 A0 B0 L100 C44 D10 M100 E44 F10 N100
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A43 B10 L100 C39 D10 M100 E46 F10 N100
M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B0 L100 C39 D10 M100 E43 F10 N100
M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B0 L100 C41 D10 M100 E41 F10 N100
M1006 A0 B0 L100 C44 D10 M100 E44 F10 N100
M1006 A0 B0 L100 C49 D10 M100 E49 F10 N100
M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
M1006 A44 B10 L100 C39 D10 M100 E48 F10 N100
M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B0 L100 C39 D10 M100 E44 F10 N100
M1006 A0 B0 L100 C0 D10 M100 E0 F10 N100
M1006 A43 B10 L100 C39 D10 M100 E46 F10 N100
M1006 W
M18
;=====avoid end stop =================
G91
G380 S2 Z30 F1200
G380 S3 Z-20 F1200
G1 Z5 F1200
G90

;===== reset machine status =================
M204 S6000

M630 S0 P0
G91
M17 Z0.3 ; lower the z-motor current

G90
M17 X0.7 Y0.9 Z0.5 ; reset motor current to default
M960 S5 P1 ; turn on logo lamp
G90
M83
M220 S100 ;Reset Feedrate
M221 S100 ;Reset Flowrate
M73.2   R1.0 ;Reset left time magnitude
;====== cog noise reduction=================
M982.2 S1 ; turn on cog noise reduction

;===== prepare print temperature and material ==========
M400
M18
M109 S100 H170
M104 S170
M400
M17
M400
G28 X

M211 X0 Y0 Z0 ;turn off soft endstop ; turn off soft endstop to prevent protential logic problem

M975 S1 ; turn on

G1 X0.0 F30000
G1 X-13.5 F3000

M620 M ;enable remap
M620 S0A   ; switch material if AMS exist
    G392 S0 ;turn on clog detect
    M1002 gcode_claim_action : 4
    M400
    M1002 set_filament_type:UNKNOWN
    M109 S220

    M104 S220

    M400
    T0
    G1 X-13.5 F3000
    M400

    M620.1 E F299.339 T220
    M109 S220 ;set nozzle to common flush temp

    M106 P1 S0
    G92 E0
M73 P2 R20
M73 C12
    G1 E50 F200
    M400
    M1002 set_filament_type:PLA

    M104 S220

    G92 E0
    G1 E50 F299.339
    M400
    M106 P1 S178
    G92 E0
M73 P3 R20
    G1 E5 F299.339
    M109 S200 ; drop nozzle temp, make filament shink a bit
    M104 S180
    G92 E0
M73 P4 R20
    G1 E-0.5 F300

    G1 X0 F30000
    G1 X-13.5 F3000
    G1 X0 F30000 ;wipe and shake
    G1 X-13.5 F3000
    G1 X0 F12000 ;wipe and shake
    G1 X0 F30000
    G1 X-13.5 F3000
    M109 S180
    G392 S0 ;turn off clog detect
M621 S0A

M400
M106 P1 S0
;===== prepare print temperature and material end =====


;===== mech mode fast check============================
M1002 gcode_claim_action : 3
G0 X25 Y175 F20000 ; find a soft place to home
;M104 S0
G28 Z P0 T300; home z with low precision,permit 300deg temperature
G29.2 S0 ; turn off ABL
M104 S170

; build plate detect
M1002 judge_flag build_plate_detect_flag
M622 S1
  G39.4
  M400
M623

G1 Z5 F3000
G1 X90 Y-1 F30000
M400 P200
M970.3 Q1 A7 K0 O2
M974 Q1 S2 P0

G1 X90 Y0 Z5 F30000
M400 P200
M970 Q0 A10 B50 C90 H15 K0 M20 O3
M974 Q0 S2 P0

M975 S1
G1 F30000
G1 X-1 Y10
G28 X ; re-home XY

;===== wipe nozzle ===============================
M1002 gcode_claim_action : 14
M975 S1

M104 S170 ; set temp down to heatbed acceptable
M106 S255 ; turn on fan (G28 has turn off fan)
M211 S; push soft endstop status
M211 X0 Y0 Z0 ;turn off Z axis endstop

M83
G1 E-1 F500
G90
M83

M109 S170
M104 S140
G0 X90 Y-4 F30000
G380 S3 Z-5 F1200
M73 P25 R15
M73 C7
G1 Z2 F1200
G1 X91 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X92 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X93 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X94 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X95 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X96 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X97 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X98 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X99 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X99 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X99 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X99 F10000
G380 S3 Z-5 F1200
G1 Z2 F1200
G1 X99 F10000
G380 S3 Z-5 F1200

G1 Z5 F30000
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
G1 X25 Y175 F30000.1 ;Brush material
G1 Z0.2 F30000.1
G1 Y185
G91
G1 X-30 F30000
G1 Y-2
G1 X27
G1 Y1.5
G1 X-28
G1 Y-2
G1 X30
G1 Y1.5
G1 X-30
G90
M83

G1 Z5 F3000
G0 X50 Y175 F20000 ; find a soft place to home
G28 Z P0 T300; home z with low precision, permit 300deg temperature
G29.2 S0 ; turn off ABL

G0 X85 Y185 F10000 ;move to exposed steel surface and stop the nozzle
G0 Z-1.01 F10000
G91

G2 I1 J0 X2 Y0 F2000.1
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5
G2 I1 J0 X2
G2 I-0.75 J0 X-1.5

G90
G1 Z5 F30000
G1 X25 Y175 F30000.1 ;Brush material
G1 Z0.2 F30000.1
G1 Y185
G91
G1 X-30 F30000
G1 Y-2
G1 X27
G1 Y1.5
G1 X-28
G1 Y-2
G1 X30
G1 Y1.5
G1 X-30
G90
M83

G1 Z5
G0 X55 Y175 F20000 ; find a soft place to home
G28 Z P0 T300; home z with low precision, permit 300deg temperature
G29.2 S0 ; turn off ABL

G1 Z10
G1 X85 Y185
G1 Z-1.01
G1 X95
G1 X90

M211 R; pop softend status

M106 S0 ; turn off fan , too noisy
;===== wipe nozzle end ================================


;===== wait heatbed  ====================
M1002 gcode_claim_action:54
M104 S0
M190 S65;set bed temp
M109 S140

G1 Z5 F3000
G29.2 S1
G1 X10 Y10 F20000

;===== bed leveling ==================================
;M1002 set_flag g29_before_print_flag=1
M1002 judge_flag g29_before_print_flag
M622 J1
    M1002 gcode_claim_action : 1
    G29 A1 X67.5 Y65.25 I45 J49.5
    M400
    M500 ; save cali data
M623
;===== bed leveling end ================================

;===== home after wipe mouth============================
M1002 judge_flag g29_before_print_flag
M622 J0

    M1002 gcode_claim_action : 13
    G28 T145

M623

;===== home after wipe mouth end =======================

M975 S1 ; turn on vibration supression
;===== nozzle load line ===============================
M975 S1
G90
M83
T1000

G1 X-13.5 Y0 Z10 F10000
G1 E1.2 F500
M400
M1002 set_filament_type:UNKNOWN
M109 S220
M400

M412 S1 ;    ===turn on  filament runout detection===
M400 P10

G392 S0 ;turn on clog detect

M620.3 W1; === turn on filament tangle detection===
M400 S2

M1002 set_filament_type:PLA
;M1002 set_flag extrude_cali_flag=1
M1002 judge_flag extrude_cali_flag
M622 J1
    M1002 gcode_claim_action : 8
    
    M400
    M900 K0.0 L1000.0 M1.0
    G90
    M83
    G0 X68 Y-4 F30000
    G0 Z0.3 F18000 ;Move to start position
    M400
    G0 X88 E10  F720
    G0 X93 E.3742  F1200
    G0 X98 E.3742  F4800
    G0 X103 E.3742  F1200
    G0 X108 E.3742  F4800
    G0 X113 E.3742  F1200
    G0 Y0 Z0 F20000
    M400
    
    G1 X-13.5 Y0 Z10 F10000
    M400
    
    G1 E10 F300
    M983 F5 A0.3 H0.4; cali dynamic extrusion compensation
    M106 P1 S178
    M400 S7
    G1 X0 F18000
    G1 X-13.5 F3000
    G1 X0 F18000 ;wipe and shake
    G1 X-13.5 F3000
    G1 X0 F12000 ;wipe and shake
    G1 X-13.5 F3000
    M400
    M106 P1 S0

    M1002 judge_last_extrude_cali_success
    M622 J0
        M983 F5 A0.3 H0.4; cali dynamic extrusion compensation
        M106 P1 S178
        M400 S7
        G1 X0 F18000
        G1 X-13.5 F3000
        G1 X0 F18000 ;wipe and shake
M73 P26 R15
        G1 X-13.5 F3000
        G1 X0 F12000 ;wipe and shake
        M400
        M106 P1 S0
    M623
    
    G1 X-13.5 F3000
    M400
    M984 A0.1 E1 S1 F5 H0.4
    M106 P1 S178
    M400 S7
    G1 X0 F18000
    G1 X-13.5 F3000
    G1 X0 F18000 ;wipe and shake
    G1 X-13.5 F3000
    G1 X0 F12000 ;wipe and shake
    G1 X-13.5 F3000
    M400
    M106 P1 S0

M623 ; end of "draw extrinsic para cali paint"

;===== extrude cali test ===============================
M104 S220
G90
M83
G0 X68 Y-2.5 F30000
G0 Z0.3 F18000 ;Move to start position
G0 X88 E10  F720
G0 X93 E.3742  F1200
G0 X98 E.3742  F4800
G0 X103 E.3742  F1200
G0 X108 E.3742  F4800
G0 X113 E.3742  F1200
G0 X115 Z0 F20000
G0 Z5
M400

;========turn off light and wait extrude temperature =============
M1002 gcode_claim_action : 0

M400 ; wait all motion done before implement the emprical L parameters

;===== for Textured PEI Plate , lower the nozzle as the nozzle was touching topmost of the texture when homing ==
;curr_bed_type=Textured PEI Plate

G29.1 Z-0.02 ; for Textured PEI Plate


M960 S1 P0 ; turn off laser
M960 S2 P0 ; turn off laser
M106 S0 ; turn off fan
M106 P2 S0 ; turn off big fan
M106 P3 S0 ; turn off chamber fan

M975 S1 ; turn on mech mode supression
G90
M83
T1000

M211 X0 Y0 Z0 ;turn off soft endstop
M1007 S1



; MACHINE_START_GCODE_END
; filament start gcode
M106 P3 S255
;Prevent PLA from jamming


;VT0 H-1
G90
G21
M83 ; use relative distances for extrusion
M981 S1 P20000 ;open spaghetti detector
; CHANGE_LAYER
; Z_HEIGHT: 0.2
; LAYER_HEIGHT: 0.2
G1 E-.8 F1800
; layer num/total_layer_count: 1/25
; update layer progress
M73 L1
M991 S0 P0 ;notify layer change
M106 S0
; OBJECT_ID: 19785
G1 X86.688 Y104.373 F42000
M204 S6000
M73 P27 R15
G1 Z.4
G1 Z.2
G1 E.8 F1800
; FEATURE: Support
; LINE_WIDTH: 0.5
G1 F3000
M204 S500
G2 X93.684 Y104.29 I3.299 J-16.75 E.26247
G1 X93.829 Y104.872 E.02234
G3 X86.223 Y104.884 I-3.83 J-17.842 E.28536
G3 X86.301 Y104.287 I.808 J-.199 E.02294
M73 P28 R15
G1 X86.621 Y104.358 E.01222
; WIPE_START
G1 X88.345 Y104.619 E-.66241
G1 X88.601 Y104.632 E-.09759
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X89.101 Y97.016 Z.6 F42000
G1 X90.861 Y70.222 Z.6
G1 Z.2
G1 E.8 F1800
G1 F3000
M204 S500
G3 X93.81 Y70.624 I-1.888 J24.851 E.11094
G1 X93.662 Y71.205 E.02234
G1 X93.312 Y71.127 E.01336
G2 X86.292 Y71.215 I-3.298 J16.806 E.26334
G3 X86.24 Y70.613 I.84 J-.376 E.02296
M73 P28 R14
G3 X90.792 Y70.22 I3.978 J19.536 E.17054
; WIPE_START
G1 X92.575 Y70.39 E-.68058
G1 X92.78 Y70.429 E-.07942
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X91.181 Y77.892 Z.6 F42000
G1 X84.624 Y108.489 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.49999
G1 F3000
M204 S500
G1 X84.602 Y108.42 E.00268
G2 X84.317 Y108.167 I-.58 J.366 E.01439
G3 X111.189 Y87.781 I5.685 J-20.411 E3.50529
G3 X96.123 Y108.034 I-21.218 J-.053 E1.0069
G1 X95.605 Y108.211 E.02037
G1 X95.398 Y108.42 E.01097
G1 X95.293 Y108.751 E.01294
; LINE_WIDTH: 0.53285
G1 X95.262 Y109.014 E.01057
; LINE_WIDTH: 0.56571
G3 X95.156 Y109.79 I-12.137 J-1.272 E.03335
; LINE_WIDTH: 0.56874
G3 X94.852 Y110.773 I-5.355 J-1.116 E.04418
; LINE_WIDTH: 0.56828
G3 X92 Y113.612 I-4.853 J-2.024 E.17677
; LINE_WIDTH: 0.56873
G3 X91.014 Y113.911 I-2.073 J-5.055 E.04421
; LINE_WIDTH: 0.56848
G3 X89.472 Y113.983 I-1.059 J-6.13 E.0663
; LINE_WIDTH: 0.56865
G3 X87.976 Y113.604 I.75 J-6.109 E.06628
; LINE_WIDTH: 0.56846
G3 X86.654 Y112.808 I2.503 J-5.649 E.06629
; LINE_WIDTH: 0.56867
G3 X85.924 Y112.07 I3.457 J-4.148 E.04451
; LINE_WIDTH: 0.56838
G1 X85.619 Y111.661 E.02185
; LINE_WIDTH: 0.56862
G3 X85.138 Y110.75 I4.565 J-2.994 E.04419
; LINE_WIDTH: 0.56837
G1 X84.963 Y110.264 E.02213
; LINE_WIDTH: 0.5698
G3 X84.766 Y109.252 I5.569 J-1.611 E.0443
; LINE_WIDTH: 0.56567
G1 X84.736 Y109.002 E.01075
; LINE_WIDTH: 0.53283
M73 P29 R14
G1 X84.707 Y108.751 E.01007
; LINE_WIDTH: 0.49999
G1 X84.642 Y108.546 E.00802
M204 S6000
G1 X84.216 Y108.664 F42000
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X84.121 Y108.58 E.00473
G3 X111.646 Y87.793 I5.883 J-20.827 E3.57815
G3 X96.323 Y108.451 I-21.647 J-.044 E1.0258
G1 X95.844 Y108.601 E.01867
G1 X95.749 Y108.774 E.00737
G3 X84.276 Y109.277 I-5.749 J-.033 E.65152
G1 X84.221 Y108.724 E.02072
; WIPE_START
G1 X84.121 Y108.58 E-.06684
G1 X83.634 Y108.437 E-.1928
G1 X82.623 Y108.099 E-.40481
G1 X82.389 Y108.008 E-.09556
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X90.004 Y108.526 Z.6 F42000
G1 X94.511 Y108.833 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3000
M204 S500
G1 X94.591 Y108.916 E.00431
; LINE_WIDTH: 0.53285
G1 X94.652 Y109.079 E.00695
; LINE_WIDTH: 0.56571
G3 X94.701 Y109.357 I-.263 J.19 E.01241
; LINE_WIDTH: 0.56874
G1 X94.527 Y110.129 E.03394
G1 X94.203 Y110.936 E.03726
; LINE_WIDTH: 0.56828
G1 X93.932 Y111.383 E.02239
G1 X93.386 Y112.063 E.03731
G1 X92.997 Y112.412 E.02238
G1 X92.28 Y112.903 E.03719
G1 X91.805 Y113.124 E.02244
G1 X90.975 Y113.386 E.03723
; LINE_WIDTH: 0.56854
G1 X90.458 Y113.46 E.0224
G1 X89.589 Y113.469 E.03722
; LINE_WIDTH: 0.56865
G1 X89.07 Y113.39 E.02248
G1 X88.237 Y113.147 E.03718
; LINE_WIDTH: 0.56855
G1 X87.764 Y112.921 E.02244
G1 X87.036 Y112.445 E.03726
; LINE_WIDTH: 0.56867
G1 X86.65 Y112.092 E.02242
G1 X86.091 Y111.425 E.03729
G1 X85.824 Y110.975 E.02243
M73 C6
G1 X85.482 Y110.176 E.03722
; LINE_WIDTH: 0.5698
G3 X85.288 Y109.243 I6.526 J-1.847 E.04095
; LINE_WIDTH: 0.56567
G1 X85.348 Y109.079 E.00742
; LINE_WIDTH: 0.53283
G1 X85.409 Y108.916 E.00695
; LINE_WIDTH: 0.49999
G1 X85.65 Y108.666 E.01294
G1 X85.811 Y108.595 E.00653
G1 X86.124 Y108.577 E.01168
G2 X93.877 Y108.577 I3.876 J-20.538 E.29044
G1 X94.189 Y108.595 E.01167
G1 X94.35 Y108.666 E.00653
G1 X94.469 Y108.79 E.00639
M204 S6000
G1 X94.193 Y109.14 F42000
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X94.22 Y109.286 E.00551
G1 X94.053 Y109.998 E.02726
G1 X93.756 Y110.738 E.02971
G3 X85.938 Y110 I-3.755 J-1.993 E.37281
G1 X85.783 Y109.301 E.02665
G1 X85.807 Y109.14 E.00606
G1 X85.941 Y109.033 E.00638
G1 X86.736 Y109.147 E.02991
G2 X93.955 Y109.027 I3.248 J-21.763 E.27011
G1 X94.112 Y109.057 E.00598
G1 X94.151 Y109.097 E.00208
; WIPE_START
G1 X94.22 Y109.286 E-.07626
G1 X94.053 Y109.998 E-.27813
G1 X93.756 Y110.738 E-.30307
G1 X93.612 Y110.967 E-.10255
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X90.027 Y106.457 Z.6 F42000
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
G1 F3000
M204 S500
G1 X90.017 Y106.453 E.00041
G3 X77.425 Y73.9 I-.02 J-18.704 E1.67576
G1 X77.425 Y73.9 E0
G1 X78.12 Y73.3 E.03419
G3 X90.934 Y106.429 I11.878 J14.449 E2.63298
G1 X90.087 Y106.455 E.03156
M204 S6000
G1 X90.016 Y106 F42000
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X90.006 Y105.996 E.00042
G3 X77.74 Y74.232 I-.008 J-18.247 E1.63483
G1 X78.418 Y73.646 E.03336
G3 X90.901 Y105.974 I11.579 J14.103 E2.56865
G1 X90.076 Y105.998 E.03071
; WIPE_START
G1 X90.006 Y105.996 E-.02689
G1 X89.11 Y105.978 E-.34029
G1 X88.217 Y105.912 E-.34041
G1 X88.08 Y105.895 E-.05241
; WIPE_END
G1 E-.04 F1800
M204 S6000
G17
G3 Z.6 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z0.6
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X102.653 Y70.986 F42000
G1 Z.2
G1 E.8 F1800
; FEATURE: Bottom surface
; LINE_WIDTH: 0.50007
G1 F6300
M204 S500
G1 X104.709 Y73.042 E.10833
G3 X107.435 Y76.414 I-15.223 J15.093 E.16182
G1 X101.336 Y70.315 E.32134
G2 X99.753 Y69.379 I-14.401 J22.544 E.0685
G1 X108.371 Y77.997 E.45401
G3 X108.979 Y79.251 I-12.339 J6.753 E.05194
G1 X98.499 Y68.771 E.5521
G2 X97.396 Y68.315 I-5.26 J11.148 E.04449
G1 X109.435 Y80.354 E.63427
G3 X109.786 Y81.351 I-9.72 J3.977 E.03938
G1 X106.393 Y77.958 E.17874
G3 X107.149 Y79.361 I-13.779 J8.334 E.05939
G1 X110.06 Y82.272 E.15333
G3 X110.276 Y83.134 I-8.528 J2.593 E.03313
G1 X107.678 Y80.537 E.13684
G3 X108.062 Y81.567 I-10.234 J4.398 E.04097
M73 P30 R14
G1 X110.446 Y83.951 E.1256
G3 X110.58 Y84.731 I-7.566 J1.7 E.02951
G1 X108.357 Y82.508 E.11712
G3 X108.585 Y83.383 I-8.584 J2.704 E.03368
G1 X110.67 Y85.467 E.10983
G3 X110.735 Y86.179 I-7.447 J1.042 E.02664
G1 X108.76 Y84.204 E.10406
G3 X108.893 Y84.984 I-7.861 J1.746 E.02949
G1 X110.779 Y86.87 E.09935
G1 X110.796 Y87.533 E.02471
G1 X108.984 Y85.721 E.09545
G3 X109.044 Y86.428 I-7.194 J.966 E.02642
G1 X110.79 Y88.174 E.09202
G3 X110.773 Y88.803 I-6.504 J.135 E.02345
G1 X109.08 Y87.11 E.08922
G3 X109.095 Y87.772 I-6.653 J.486 E.02467
G1 X110.729 Y89.405 E.08607
G3 X110.674 Y89.998 I-5.843 J-.238 E.02216
G1 X109.079 Y88.403 E.08403
G3 X109.048 Y89.018 I-6.31 J-.015 E.02295
G1 X110.602 Y90.572 E.0819
G3 X110.518 Y91.134 I-5.93 J-.601 E.02119
G1 X109.003 Y89.62 E.0798
G1 X108.933 Y90.196 E.02161
G1 X110.422 Y91.685 E.07848
G3 X110.309 Y92.218 I-5.556 J-.903 E.02031
G1 X108.852 Y90.761 E.07677
G1 X108.757 Y91.312 E.02084
G1 X110.191 Y92.746 E.07554
G3 X110.052 Y93.254 I-5.279 J-1.167 E.01962
G1 X108.645 Y91.848 E.07411
G1 X108.527 Y92.376 E.02017
G1 X109.912 Y93.761 E.07298
G3 X109.753 Y94.248 I-5.047 J-1.378 E.01911
G1 X108.387 Y92.883 E.07196
G3 X108.243 Y93.385 I-5.258 J-1.237 E.01948
G1 X109.593 Y94.735 E.07111
G3 X109.414 Y95.202 I-4.721 J-1.542 E.01865
G1 X108.083 Y93.871 E.07013
G3 X107.915 Y94.35 I-4.933 J-1.456 E.01891
G1 X109.234 Y95.669 E.06946
G3 X109.037 Y96.118 I-4.75 J-1.811 E.01829
G1 X107.735 Y94.816 E.06858
G3 X107.546 Y95.274 I-4.786 J-1.709 E.01845
G1 X108.838 Y96.566 E.06808
G3 X108.625 Y96.999 I-4.476 J-1.937 E.01799
G1 X107.348 Y95.722 E.06729
G3 X107.139 Y96.16 I-4.555 J-1.903 E.01807
G1 X108.408 Y97.429 E.06688
G3 X108.18 Y97.847 I-4.386 J-2.13 E.01775
G1 X106.922 Y96.59 E.06623
G3 X106.695 Y97.009 I-4.347 J-2.087 E.01777
G1 X107.946 Y98.26 E.06589
G3 X107.703 Y98.663 I-4.222 J-2.27 E.01755
G1 X106.461 Y97.422 E.06541
G3 X106.216 Y97.823 I-4.19 J-2.279 E.01753
G1 X107.452 Y99.059 E.0651
G3 X107.195 Y99.449 I-4.113 J-2.431 E.01739
G1 X105.965 Y98.219 E.06479
G3 X105.704 Y98.604 I-4.192 J-2.56 E.01735
G1 X106.928 Y99.828 E.06448
G3 X106.658 Y100.205 I-3.945 J-2.543 E.01727
G1 X105.437 Y98.984 E.06431
G3 X105.16 Y99.353 I-3.762 J-2.538 E.01721
G1 X106.375 Y100.568 E.06399
G1 X106.091 Y100.931 E.01716
G1 X104.877 Y99.716 E.06401
G3 X104.584 Y100.07 I-3.8 J-2.851 E.01711
G1 X105.793 Y101.279 E.06369
G1 X105.493 Y101.626 E.01708
G1 X104.284 Y100.417 E.06369
G3 X103.976 Y100.755 I-3.617 J-2.983 E.01706
G1 X105.182 Y101.961 E.06353
G1 X104.867 Y102.292 E.01704
G1 X103.661 Y101.086 E.06353
G3 X103.338 Y101.41 I-3.415 J-3.091 E.01704
G1 X104.544 Y102.616 E.06353
G1 X104.212 Y102.931 E.01704
G1 X103.006 Y101.725 E.06353
G3 X102.668 Y102.033 I-3.339 J-3.326 E.01706
G1 X103.877 Y103.242 E.06367
G1 X103.529 Y103.541 E.01708
G1 X102.321 Y102.333 E.06364
G3 X101.967 Y102.625 I-3.233 J-3.553 E.01711
G1 X103.181 Y103.839 E.06397
G3 X102.819 Y104.124 I-3.157 J-3.647 E.01716
G1 X101.604 Y102.909 E.064
G3 X101.235 Y103.186 I-2.87 J-3.431 E.01721
G1 X102.456 Y104.407 E.06431
G3 X102.08 Y104.677 I-2.924 J-3.68 E.01727
G1 X100.856 Y103.453 E.06448
G3 X100.47 Y103.715 I-2.962 J-3.954 E.01735
G1 X101.7 Y104.944 E.06478
G3 X101.31 Y105.201 I-2.709 J-3.697 E.0174
G1 X100.075 Y103.966 E.06507
G3 X99.673 Y104.21 I-2.694 J-3.979 E.01754
G1 X100.913 Y105.451 E.06536
G3 X100.511 Y105.695 I-2.791 J-4.138 E.01754
G1 X99.26 Y104.444 E.0659
G3 X98.842 Y104.672 I-2.468 J-4.043 E.01777
G1 X100.099 Y105.929 E.06623
G3 X99.681 Y106.158 I-2.554 J-4.167 E.01775
G1 X98.411 Y104.888 E.06688
G3 X97.974 Y105.097 I-2.338 J-4.338 E.01807
G1 X99.251 Y106.374 E.06729
G3 X98.818 Y106.588 I-2.369 J-4.26 E.01799
G1 X97.526 Y105.295 E.06808
G3 X97.068 Y105.484 I-2.165 J-4.593 E.01845
G1 X98.37 Y106.786 E.06857
G3 X97.92 Y106.983 I-2.266 J-4.562 E.01829
G1 X96.602 Y105.664 E.06946
G3 X96.123 Y105.832 I-1.937 J-4.769 E.01891
G1 X97.454 Y107.163 E.07013
G3 X96.987 Y107.342 I-2.019 J-4.564 E.01865
G1 X95.637 Y105.992 E.07112
G3 X95.135 Y106.137 I-1.747 J-5.134 E.01947
G1 X96.5 Y107.503 E.07195
G3 X96.013 Y107.662 I-1.919 J-5.048 E.0191
G1 X94.627 Y106.276 E.07301
G1 X94.099 Y106.395 E.02015
G1 X95.527 Y107.823 E.07522
G2 X95.16 Y108.102 I.332 J.819 E.01739
G1 X93.564 Y106.506 E.08406
G1 X93.014 Y106.602 E.02082
G1 X94.958 Y108.546 E.10245
G1 X94.91 Y108.698 E.00592
G1 X94.562 Y108.337 E.01868
G1 X94.298 Y108.221 E.01073
G1 X93.945 Y108.18 E.01323
G1 X92.448 Y106.682 E.07891
G1 X91.872 Y106.753 E.02161
G1 X93.39 Y108.271 E.07995
G3 X92.826 Y108.354 I-1.333 J-7.116 E.02123
G1 X91.27 Y106.798 E.08197
G3 X90.655 Y106.829 I-.631 J-6.282 E.02295
G1 X92.25 Y108.424 E.08404
G3 X91.658 Y108.478 I-.85 J-6.047 E.02217
G1 X90.024 Y106.845 E.08606
G3 X89.362 Y106.83 I-.177 J-6.66 E.02467
G1 X91.056 Y108.523 E.0892
G3 X90.427 Y108.54 I-.495 J-6.477 E.02345
G1 X88.68 Y106.794 E.09201
G3 X87.974 Y106.734 I.257 J-7.249 E.02641
G1 X89.785 Y108.546 E.09544
G1 X89.122 Y108.529 E.02471
G1 X87.237 Y106.643 E.09934
G3 X86.456 Y106.509 I.948 J-7.862 E.02952
G1 X88.432 Y108.485 E.10409
G3 X87.721 Y108.421 I.303 J-7.323 E.02659
G1 X85.635 Y106.335 E.1099
G3 X84.762 Y106.108 I1.86 J-8.954 E.03363
G1 X86.984 Y108.33 E.11708
G3 X86.213 Y108.206 I1.185 J-9.811 E.02909
G1 X83.82 Y105.813 E.12607
G3 X82.791 Y105.43 I3.363 J-10.611 E.04095
G1 X85.618 Y108.258 E.14897
G1 X85.438 Y108.338 E.00733
G1 X85.248 Y108.534 E.01019
G1 X81.616 Y104.902 E.19135
G3 X80.214 Y104.146 I6.922 J-14.524 E.05935
G1 X83.926 Y107.858 E.19555
; WIPE_START
G1 X82.512 Y106.444 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
M73 P31 R14
G1 X85.031 Y99.239 Z.6 F42000
G1 X96.078 Y67.643 Z.6
G1 Z.2
G1 E.8 F1800
G1 F6300
M204 S500
G1 X99.792 Y71.357 E.19567
G2 X98.389 Y70.601 I-8.331 J13.773 E.05939
G1 X95.478 Y67.69 E.15333
G2 X94.616 Y67.474 I-2.596 J8.539 E.03313
G1 X97.213 Y70.072 E.13685
G2 X96.183 Y69.688 I-4.398 J10.236 E.04097
G1 X93.799 Y67.304 E.1256
G2 X93.019 Y67.17 I-1.74 J7.797 E.02951
G1 X95.242 Y69.393 E.11712
G2 X94.367 Y69.165 I-2.707 J8.594 E.03368
G1 X92.282 Y67.079 E.10988
G2 X91.571 Y67.015 I-1.015 J7.26 E.0266
G1 X93.546 Y68.99 E.10406
G2 X92.766 Y68.857 I-1.75 J7.883 E.02949
G1 X90.88 Y66.971 E.09936
G1 X90.217 Y66.954 E.02471
G1 X92.029 Y68.766 E.09545
G2 X91.322 Y68.706 I-.965 J7.19 E.02642
G1 X89.578 Y66.961 E.09192
G2 X88.947 Y66.977 I-.166 J6.109 E.02353
G1 X90.641 Y68.671 E.08924
G1 X89.979 Y68.656 E.02466
G1 X88.345 Y67.021 E.08609
G2 X87.752 Y67.075 I.258 J6.112 E.02217
G1 X89.347 Y68.671 E.08405
G2 X88.732 Y68.702 I.017 J6.343 E.02295
G1 X87.176 Y67.146 E.08198
G2 X86.616 Y67.232 I.581 J5.666 E.02114
G1 X88.13 Y68.747 E.0798
G1 X87.555 Y68.817 E.02161
G1 X86.065 Y67.328 E.07849
G2 X85.532 Y67.441 I.903 J5.555 E.02031
G1 X86.988 Y68.898 E.07674
G1 X86.437 Y68.993 E.02083
G1 X85.004 Y67.559 E.07553
G2 X84.495 Y67.697 I1.131 J5.176 E.01964
G1 X85.902 Y69.105 E.07414
G1 X85.374 Y69.223 E.02016
G1 X83.989 Y67.838 E.07298
G2 X83.502 Y67.997 I1.424 J5.188 E.01911
G1 X84.867 Y69.363 E.07196
G2 X84.365 Y69.507 I1.236 J5.256 E.01948
G1 X83.015 Y68.157 E.07111
G2 X82.548 Y68.336 I1.542 J4.722 E.01865
G1 X83.879 Y69.667 E.07013
G2 X83.4 Y69.835 I1.455 J4.931 E.01891
G1 X82.081 Y68.516 E.06946
G2 X81.632 Y68.713 I1.804 J4.734 E.01829
G1 X82.934 Y70.015 E.06858
G2 X82.476 Y70.204 I1.708 J4.784 E.01845
G1 X81.184 Y68.912 E.06808
G2 X80.751 Y69.125 I1.934 J4.471 E.01799
G1 X82.028 Y70.402 E.06729
G2 X81.59 Y70.611 I1.901 J4.551 E.01807
G1 X80.321 Y69.342 E.06688
G2 X79.903 Y69.57 I2.135 J4.394 E.01775
G1 X81.16 Y70.828 E.06623
G2 X80.741 Y71.055 I2.086 J4.346 E.01777
G1 X79.49 Y69.804 E.06589
G2 X79.087 Y70.047 I2.27 J4.222 E.01755
G1 X80.328 Y71.289 E.06541
G2 X79.927 Y71.534 I2.278 J4.188 E.01753
G1 X78.691 Y70.298 E.0651
G2 X78.301 Y70.555 I2.433 J4.116 E.01739
G1 X79.531 Y71.785 E.06479
G2 X79.146 Y72.046 I2.558 J4.188 E.01735
G1 X77.922 Y70.822 E.06448
G2 X77.545 Y71.092 I2.538 J3.938 E.01727
G1 X78.766 Y72.313 E.06431
G2 X78.397 Y72.59 I2.543 J3.769 E.01721
G1 X77.182 Y71.375 E.06399
G1 X76.819 Y71.659 E.01716
G1 X78.034 Y72.873 E.06401
G2 X77.68 Y73.166 I2.85 J3.799 E.01711
G1 X76.471 Y71.957 E.06369
G1 X76.124 Y72.257 E.01708
G1 X77.333 Y73.466 E.06368
G2 X76.995 Y73.774 I2.979 J3.613 E.01706
G1 X75.789 Y72.568 E.06353
G1 X75.458 Y72.883 E.01704
G1 X76.664 Y74.089 E.06353
G2 X76.34 Y74.412 I3.095 J3.419 E.01704
G1 X75.134 Y73.206 E.06354
G1 X74.819 Y73.538 E.01703
G1 X76.025 Y74.744 E.06353
G2 X75.717 Y75.082 I3.306 J3.32 E.01706
G1 X74.508 Y73.873 E.06369
G1 X74.209 Y74.22 E.01708
G1 X75.418 Y75.429 E.06369
G2 X75.125 Y75.783 I3.51 J3.208 E.01711
G1 X73.91 Y74.568 E.06401
G1 X73.626 Y74.931 E.01716
G1 X74.841 Y76.146 E.06399
G2 X74.564 Y76.515 I3.483 J2.907 E.01721
G1 X73.343 Y75.294 E.06431
G2 X73.073 Y75.67 I3.667 J2.915 E.01727
G1 X74.297 Y76.894 E.06448
G2 X74.035 Y77.28 I3.927 J2.944 E.01735
G1 X72.806 Y76.05 E.06478
G2 X72.549 Y76.44 I3.867 J2.829 E.01739
G1 X73.785 Y77.675 E.0651
G2 X73.54 Y78.077 I3.945 J2.682 E.01753
G1 X72.298 Y76.835 E.0654
G2 X72.055 Y77.239 I3.979 J2.674 E.01755
G1 X73.306 Y78.489 E.06589
G2 X73.078 Y78.908 I4.117 J2.505 E.01777
G1 X71.821 Y77.651 E.06623
G2 X71.592 Y78.069 I4.162 J2.551 E.01775
G1 X72.862 Y79.339 E.06688
G2 X72.653 Y79.776 I4.345 J2.341 E.01807
G1 X71.376 Y78.499 E.06729
G2 X71.162 Y78.932 I4.254 J2.366 E.01799
G1 X72.455 Y80.224 E.06808
G2 X72.266 Y80.682 I4.6 J2.169 E.01845
G1 X70.964 Y79.38 E.06857
G2 X70.767 Y79.83 I4.543 J2.257 E.01829
G1 X72.086 Y81.148 E.06946
G2 X71.918 Y81.627 I4.761 J1.934 E.01891
G1 X70.587 Y80.296 E.07013
G2 X70.408 Y80.763 I4.565 J2.019 E.01865
G1 X71.758 Y82.113 E.07111
G2 X71.613 Y82.616 I5.105 J1.738 E.01948
G1 X70.248 Y81.25 E.07196
G2 X70.088 Y81.737 I5.03 J1.913 E.0191
G1 X71.474 Y83.122 E.07298
G1 X71.355 Y83.65 E.02016
G1 X69.948 Y82.243 E.07414
G2 X69.81 Y82.752 I5.014 J1.634 E.01964
G1 X71.244 Y84.185 E.07553
G1 X71.148 Y84.736 E.02083
G1 X69.691 Y83.28 E.07674
G2 X69.578 Y83.813 I5.436 J1.435 E.02031
G1 X71.068 Y85.302 E.07848
G1 X70.997 Y85.878 E.02161
G1 X69.482 Y84.363 E.07979
G2 X69.396 Y84.924 I5.577 J1.142 E.02114
G1 X70.952 Y86.48 E.08197
G2 X70.921 Y87.095 I6.273 J.631 E.02295
G1 X69.326 Y85.5 E.08404
G2 X69.272 Y86.092 I6.052 J.851 E.02217
G1 X70.905 Y87.726 E.08606
G2 X70.92 Y88.388 I6.661 J.178 E.02467
G1 X69.227 Y86.694 E.0892
G2 X69.21 Y87.323 I6.484 J.495 E.02345
G1 X70.956 Y89.07 E.09201
G2 X71.016 Y89.776 I7.259 J-.258 E.02641
G1 X69.205 Y87.965 E.0954
G1 X69.224 Y88.631 E.0248
G1 X71.107 Y90.513 E.09919
G2 X71.24 Y91.293 I8.005 J-.967 E.02948
G1 X69.265 Y89.318 E.10405
G2 X69.329 Y90.029 I7.322 J-.303 E.02659
G1 X71.415 Y92.114 E.10986
G2 X71.642 Y92.989 I8.815 J-1.829 E.03367
G1 X69.42 Y90.766 E.11709
G2 X69.554 Y91.546 I7.862 J-.946 E.0295
G1 X71.937 Y93.93 E.12556
G2 X72.32 Y94.959 I10.616 J-3.365 E.04095
G1 X69.723 Y92.363 E.1368
G2 X69.939 Y93.225 I8.743 J-1.729 E.03312
G1 X72.848 Y96.134 E.15325
G2 X73.605 Y97.538 I14.323 J-6.821 E.05945
G1 X70.213 Y94.145 E.17873
G2 X70.563 Y95.142 I10.063 J-2.975 E.03937
G1 X82.608 Y107.187 E.63457
G3 X81.505 Y106.731 I4.158 J-11.611 E.04447
G1 X71.019 Y96.245 E.55244
G2 X71.626 Y97.498 I12.943 J-5.495 E.05191
M73 P32 R14
G1 X80.252 Y106.124 E.4544
G3 X78.671 Y105.189 I12.659 J-23.224 E.06841
G1 X72.563 Y99.081 E.3218
G2 X75.241 Y102.406 I17.797 J-11.595 E.1593
G1 X77.358 Y104.523 E.11155
; WIPE_START
G1 X75.944 Y103.109 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X78.955 Y96.096 Z.6 F42000
G1 X89.307 Y71.984 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.49999
G1 F3000
M204 S500
G1 X89.693 Y71.966 E.01439
G3 X105.783 Y87.361 I.308 J15.784 E.92057
G1 X105.783 Y88.139 E.02899
G3 X88.836 Y72.006 I-15.782 J-.389 E2.71288
G1 X89.247 Y71.987 E.01533
M204 S6000
G1 X89.287 Y71.527 F42000
; FEATURE: Outer wall
G1 F3000
M204 S500
G1 X89.684 Y71.509 E.01479
G3 X106.24 Y87.35 I.318 J16.241 E.94726
G1 X106.24 Y88.15 E.02983
G3 X88.803 Y71.55 I-16.239 J-.4 E2.79144
G1 X89.227 Y71.53 E.01581
; WIPE_START
G1 X89.684 Y71.509 E-.17369
G1 X90.417 Y71.51 E-.27854
G1 X91.188 Y71.548 E-.2935
G1 X91.225 Y71.552 E-.01427
; WIPE_END
G1 E-.04 F1800
M204 S6000
G1 X98.192 Y74.67 Z.6 F42000
G1 X99.115 Y75.083 Z.6
G1 Z.2
G1 E.8 F1800
; FEATURE: Bottom surface
; LINE_WIDTH: 0.50269
G1 F6300
M204 S500
G3 X101.414 Y77.405 I-47.977 J49.794 E.12245
G3 X103.214 Y79.831 I-12.411 J11.085 E.11333
G1 X97.919 Y74.536 E.28056
G2 X96.533 Y73.801 I-10.115 J17.387 E.05878
G1 X103.949 Y81.217 E.39293
G3 X104.416 Y82.334 I-11.19 J5.335 E.04539
G1 X95.416 Y73.334 E.47689
G2 X94.428 Y72.997 I-7.551 J20.496 E.0391
G1 X104.753 Y83.322 E.54708
G3 X104.988 Y84.206 I-8.813 J2.806 E.03429
G1 X93.544 Y72.762 E.60634
G2 X92.724 Y72.593 I-2.129 J8.241 E.03136
G1 X105.157 Y85.026 E.65872
G3 X105.275 Y85.794 I-8.016 J1.625 E.02913
G1 X91.956 Y72.475 E.70569
G2 X91.235 Y72.404 I-.896 J5.39 E.02718
G1 X105.351 Y86.52 E.74794
G3 X105.391 Y87.21 I-7.115 J.758 E.02591
G1 X90.545 Y72.364 E.78661
G2 X89.89 Y72.36 I-.363 J5.011 E.02455
G1 X105.401 Y87.871 E.82185
G1 X105.386 Y88.505 E.02378
G1 X89.245 Y72.365 E.8552
G2 X88.639 Y72.409 I.034 J4.664 E.02279
G1 X105.341 Y89.111 E.88497
G3 X105.276 Y89.696 I-5.792 J-.349 E.02206
G1 X88.054 Y72.474 E.91252
G2 X87.486 Y72.557 I.587 J6.003 E.02149
G1 X105.193 Y90.264 E.93819
G3 X105.095 Y90.815 I-5.658 J-.725 E.02101
G1 X86.935 Y72.655 E.9622
G1 X86.403 Y72.774 E.0204
G1 X104.976 Y91.347 E.98405
G3 X104.841 Y91.862 I-5.277 J-1.106 E.01997
G1 X85.888 Y72.909 E1.00421
G2 X85.385 Y73.056 I1.209 J5.07 E.01965
G1 X104.694 Y92.365 E1.02307
G1 X104.532 Y92.853 E.01927
G1 X84.897 Y73.218 E1.04036
G2 X84.424 Y73.396 I1.627 J5.049 E.01892
G1 X104.354 Y93.326 E1.056
G3 X104.168 Y93.79 I-4.828 J-1.678 E.01873
G1 X83.961 Y73.582 E1.07065
G1 X83.51 Y73.782 E.01847
G1 X103.968 Y94.24 E1.08396
G3 X103.754 Y94.677 I-4.502 J-1.936 E.01821
G1 X83.073 Y73.996 E1.09575
G2 X82.645 Y74.217 I2.064 J4.518 E.01808
G1 X103.533 Y95.105 E1.10672
G1 X103.298 Y95.52 E.01787
G1 X82.23 Y74.452 E1.11627
G2 X81.826 Y74.699 I2.239 J4.13 E.01773
G1 X103.051 Y95.924 E1.12463
G3 X102.798 Y96.322 I-4.257 J-2.433 E.01765
G1 X81.428 Y74.952 E1.13227
G1 X81.047 Y75.22 E.01748
M73 P33 R14
G1 X102.53 Y96.703 E1.13826
G3 X102.254 Y97.078 I-3.928 J-2.599 E.01743
G1 X80.672 Y75.496 E1.14352
G1 X80.307 Y75.781 E.01736
G1 X101.969 Y97.443 E1.14777
G3 X101.672 Y97.796 I-3.792 J-2.896 E.01729
G1 X79.954 Y76.078 E1.15069
G2 X79.607 Y76.381 I2.824 J3.58 E.01727
G1 X101.369 Y98.143 E1.15301
G1 X101.051 Y98.476 E.01723
G1 X79.274 Y76.699 E1.15382
G2 X78.949 Y77.024 I3.276 J3.601 E.01723
G1 X100.726 Y98.801 E1.15382
G1 X100.393 Y99.118 E.01723
G1 X78.632 Y77.357 E1.15301
G2 X78.329 Y77.704 I3.286 J3.179 E.01727
G1 X100.046 Y99.421 E1.1507
G3 X99.694 Y99.719 I-3.246 J-3.491 E.01729
G1 X78.031 Y78.056 E1.14777
G1 X77.746 Y78.422 E.01736
G1 X99.328 Y100.004 E1.14353
G3 X98.954 Y100.279 I-2.974 J-3.653 E.01743
G1 X77.471 Y78.796 E1.13827
G1 X77.202 Y79.178 E.01748
M73 P33 R13
G1 X98.572 Y100.548 E1.13228
G3 X98.175 Y100.801 I-2.826 J-3.999 E.01765
G1 X76.949 Y79.575 E1.12464
G2 X76.703 Y79.979 I3.884 J2.644 E.01773
G1 X97.771 Y101.047 E1.11628
G1 X97.356 Y101.282 E.01787
G1 X76.468 Y80.394 E1.10673
G2 X76.246 Y80.823 I4.29 J2.49 E.01808
G1 X96.927 Y101.504 E1.09576
G3 X96.491 Y101.718 I-2.367 J-4.278 E.01821
G1 X76.032 Y81.259 E1.08397
G1 X75.833 Y81.71 E.01847
G1 X96.04 Y101.917 E1.07067
G3 X95.577 Y102.104 I-2.142 J-4.644 E.01873
G1 X75.646 Y82.173 E1.05602
G2 X75.468 Y82.646 I4.866 J2.098 E.01892
G1 X95.104 Y102.282 E1.04038
G1 X94.616 Y102.444 E.01927
G1 X75.306 Y83.134 E1.02309
G2 X75.159 Y83.637 I4.915 J1.71 E.01965
G1 X94.113 Y102.591 E1.00423
G3 X93.597 Y102.726 I-1.619 J-5.135 E.01997
G1 X75.024 Y84.153 E.98407
G1 X74.905 Y84.684 E.0204
G1 X93.066 Y102.845 E.96223
G3 X92.514 Y102.943 I-1.279 J-5.57 E.02101
M73 P34 R13
G1 X74.807 Y85.236 E.93822
G2 X74.724 Y85.803 I5.926 J1.156 E.02149
G1 X91.947 Y103.026 E.91255
G3 X91.362 Y103.091 I-.935 J-5.729 E.02206
G1 X74.659 Y86.388 E.88501
G1 X74.614 Y86.994 E.02276
G1 X90.756 Y103.136 E.85525
G1 X90.122 Y103.151 E.02378
G1 X74.599 Y87.628 E.82246
G2 X74.609 Y88.289 I6.703 J.226 E.02476
G1 X89.461 Y103.141 E.78692
G3 X88.771 Y103.101 I.068 J-7.162 E.02591
M73 C5
G1 X74.649 Y88.979 E.74823
G2 X74.725 Y89.705 I7.184 J-.384 E.02737
G1 X88.045 Y103.025 E.70574
G3 X87.276 Y102.907 I.856 J-8.129 E.02913
G1 X74.843 Y90.474 E.65877
G2 X75.012 Y91.293 I8.41 J-1.309 E.03136
G1 X86.457 Y102.738 E.6064
G3 X85.573 Y102.504 I1.925 J-9.059 E.03428
G1 X75.246 Y92.177 E.54715
G2 X75.583 Y93.164 I20.753 J-6.534 E.03909
G1 X84.586 Y102.167 E.47698
G3 X83.468 Y101.7 I4.215 J-11.654 E.04539
G1 X76.05 Y94.282 E.39303
G2 X76.785 Y95.667 I18.083 J-8.708 E.05877
G1 X82.083 Y100.965 E.2807
G3 X79.165 Y98.697 I7.943 J-13.232 E.13881
G1 X77.331 Y96.863 E.09717
; CHANGE_LAYER
; Z_HEIGHT: 0.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F6300
G1 X78.745 Y98.277 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 2/25
; update layer progress
M73 L2
M991 S0 P1 ;notify layer change
M106 S181.05
; open powerlost recovery
M1003 S1
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z.6 I-.662 J1.021 P1  F42000
G1 X88.496 Y104.6 Z.6
G1 Z.4
G1 E.8 F1800
; FEATURE: Support
; LINE_WIDTH: 0.42
G1 F9000
M204 S6000
G3 X88.246 Y104.803 I.068 J.339 E.05652
G3 X88.44 Y104.596 I.454 J.231 E.00882
; WIPE_START
G1 X88.763 Y104.62 E-.12302
G1 X88.912 Y104.793 E-.08685
G1 X88.893 Y105.104 E-.11856
G1 X88.781 Y105.216 E-.06033
G1 X88.642 Y105.271 E-.05668
G1 X88.367 Y105.224 E-.10624
G1 X88.229 Y104.971 E-.10939
G1 X88.246 Y104.803 E-.06409
G1 X88.309 Y104.736 E-.03484
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X91.619 Y104.622 Z.8 F42000
G1 Z.4
G1 E.8 F1800
G1 F9000
M204 S6000
G3 X91.664 Y105.231 I-.229 J.324 E.02146
G3 X91.16 Y105.194 I-.206 J-.641 E.01591
M73 P35 R13
G3 X90.651 Y104.984 I.059 J-.864 E.01723
G3 X90.746 Y104.693 I.236 J-.084 E.01012
G3 X91.568 Y104.597 I.705 J2.472 E.02555
; WIPE_START
G1 X91.755 Y104.769 E-.09675
G1 X91.794 Y104.932 E-.06349
G1 X91.664 Y105.231 E-.12415
G1 X91.308 Y105.275 E-.13616
G1 X91.16 Y105.194 E-.06424
G1 X90.885 Y105.147 E-.10624
G1 X90.651 Y104.984 E-.10831
G1 X90.635 Y104.86 E-.04749
G1 X90.654 Y104.831 E-.01318
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.793 Y97.2 Z.8 F42000
G1 X91.286 Y70.223 Z.8
G1 Z.4
G1 E.8 F1800
G1 F9000
M204 S6000
G1 X91.649 Y70.25 E.01118
G3 X91.229 Y70.22 I-.23 J.278 E.05599
; WIPE_START
G1 X91.649 Y70.25 E-.15974
G1 X91.751 Y70.397 E-.06827
G1 X91.74 Y70.733 E-.12785
G1 X91.53 Y70.894 E-.10046
G1 X91.343 Y70.887 E-.07099
G1 X91.129 Y70.732 E-.10039
G1 X91.075 Y70.587 E-.059
G1 X91.086 Y70.434 E-.05818
G1 X91.108 Y70.401 E-.01512
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.013 Y70.205 Z.8 F42000
G1 Z.4
G1 E.8 F1800
G1 F9000
M204 S6000
G3 X90.167 Y70.399 I-.098 J.236 E.00795
G3 X89.773 Y70.307 I-.211 J.011 E.02399
G3 X89.958 Y70.19 I.19 J.096 E.00708
; WIPE_START
G1 X90.135 Y70.295 E-.1199
G1 X90.167 Y70.399 E-.06368
G1 X90.069 Y70.598 E-.12986
G1 X89.866 Y70.606 E-.11893
G1 X89.766 Y70.506 E-.08279
G1 X89.773 Y70.307 E-.11656
G1 X89.958 Y70.19 E-.12828
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.681 Y70.251 Z.8 F42000
G1 Z.4
G1 E.8 F1800
G1 F9000
M204 S6000
G3 X88.821 Y70.867 I-.135 J.354 E.02291
G1 X88.402 Y70.906 E.01292
G3 X88.629 Y70.23 I.19 J-.313 E.0303
; WIPE_START
G1 X88.877 Y70.397 E-.11367
G1 X88.928 Y70.555 E-.06328
G1 X88.821 Y70.867 E-.12512
G1 X88.402 Y70.906 E-.15978
G1 X88.269 Y70.761 E-.07496
G1 X88.223 Y70.584 E-.06969
G1 X88.257 Y70.405 E-.06916
G1 X88.356 Y70.275 E-.06181
G1 X88.414 Y70.266 E-.02253
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X87.664 Y77.861 Z.8 F42000
G1 X84.579 Y109.089 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.514 Y108.929 E.00573
G1 X84.421 Y108.828 E.00453
G2 X84.089 Y108.68 I-.514 J.703 E.01216
G1 X83.979 Y108.648 E.00381
G1 X83.868 Y108.617 E.00381
G1 X83.757 Y108.585 E.00381
G1 X83.647 Y108.554 E.00381
G3 X111.755 Y87.789 I6.357 J-20.801 E3.18722
G3 X96.185 Y108.605 I-21.769 J-.052 E.92405
G1 X96.089 Y108.633 E.00332
G1 X95.993 Y108.662 E.00332
G1 X95.897 Y108.69 E.00332
G1 X95.802 Y108.718 E.00332
G1 X95.706 Y108.746 E.00332
G1 X95.486 Y108.928 E.00947
G1 X95.38 Y109.189 E.00934
G3 X84.62 Y109.19 I-5.38 J-.445 E.53304
G1 X84.601 Y109.144 E.00162
M204 S250
G1 X84.08 Y109.085 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F1959.341
M204 S5000
G1 X84.056 Y109.078 E.0008
G1 F1803.522
G1 X84.031 Y109.071 E.0008
G1 F1654.089
G1 X84.006 Y109.063 E.0008
G1 F1511.117
G1 X83.981 Y109.056 E.0008
G1 F1374.606
G1 X83.956 Y109.049 E.0008
G1 F1244.57
G1 X83.931 Y109.042 E.0008
G1 F1121.026
G1 X83.906 Y109.035 E.0008
G1 F1003.896
G1 X83.881 Y109.028 E.0008
G1 F893.239
G1 X83.856 Y109.021 E.0008
G1 F789.032
G1 X83.831 Y109.014 E.0008
G1 F691.285
G1 X83.806 Y109.007 E.0008
; FEATURE: Overhang wall
; LINE_WIDTH: 0.4
; LAYER_HEIGHT: 0.4
M106 S255
G1 F600
G3 X112.147 Y87.798 I6.199 J-21.256 E5.02303
M106 S181.05
M106 S255

G3 X96.194 Y109.01 I-22.16 J-.061 E1.45698
M106 S181.05
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
; LAYER_HEIGHT: 0.2
G1 F686.155
G1 X96.17 Y109.017 E.00075
G1 F778.089
G1 X96.147 Y109.024 E.00075
G1 F875.811
G1 X96.123 Y109.03 E.00075
G1 F979.3
G1 X96.099 Y109.037 E.00075
G1 F1088.567
G1 X96.076 Y109.044 E.00075
G1 F1203.625
G1 X96.052 Y109.051 E.00075
G1 F1324.448
G1 X96.029 Y109.057 E.00075
G1 F1451.049
G1 X96.005 Y109.064 E.00075
G1 F1583.443
G1 X95.981 Y109.071 E.00075
G1 F1721.6
G1 X95.958 Y109.077 E.00075
G1 F1865.535
G1 X95.934 Y109.084 E.00075
G1 F2015.265
G1 X95.911 Y109.091 E.00075
G1 F2170.756
G1 X95.887 Y109.097 E.00075
G1 F2329.953
G1 X95.865 Y109.108 E.00074
G1 F2519.703
G1 X95.849 Y109.131 E.00085
M73 P36 R13
G1 F2716.98
G1 X95.833 Y109.153 E.00086
G1 F2921.631
G1 X95.817 Y109.176 E.00085
G1 F3133.667
G1 X95.801 Y109.199 E.00085
G1 F3353.177
G1 X95.785 Y109.221 E.00085
G1 F3580.184
G1 X95.768 Y109.244 E.00086
G1 F7664.557
G1 X95.71 Y109.64 E.01229
G1 F9547.299
G1 X95.668 Y109.922 E.00876
G3 X84.315 Y109.839 I-5.668 J-1.183 E.48831
G1 X84.194 Y109.158 E.02126
G1 X84.181 Y109.148 E.0005
G1 X84.168 Y109.139 E.0005
G1 X84.154 Y109.13 E.0005
G1 X84.141 Y109.121 E.0005
G1 X84.132 Y109.115 E.00033
; WIPE_START
M204 S6000
G1 X84.056 Y109.078 E-.03231
G1 X84.031 Y109.071 E-.00986
G1 X84.006 Y109.063 E-.00986
G1 X83.981 Y109.056 E-.00986
G1 X83.956 Y109.049 E-.00986
G1 X83.931 Y109.042 E-.00985
G1 X83.906 Y109.035 E-.00986
G1 X83.881 Y109.028 E-.00986
G1 X83.856 Y109.021 E-.00986
G1 X83.831 Y109.014 E-.00986
G1 X83.806 Y109.007 E-.00986
G1 X83.476 Y108.912 E-.1306
G1 X82.443 Y108.566 E-.41382
G1 X82.235 Y108.485 E-.08469
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.836 Y109.179 Z.8 F42000
G1 X94.438 Y109.598 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.479 Y109.731 E.0046
G1 X94.267 Y110.471 E.02554
G1 X94.046 Y110.923 E.01668
G1 X93.584 Y111.636 E.02818
G1 X93.241 Y112.004 E.0167
G1 X92.591 Y112.552 E.02818
G1 X92.156 Y112.805 E.0167
G1 X91.376 Y113.14 E.02815
G1 X90.887 Y113.257 E.01668
G1 X90.042 Y113.351 E.0282
G1 X89.54 Y113.32 E.01671
G1 X88.705 Y113.165 E.02815
G1 X88.234 Y112.99 E.01669
G1 X87.48 Y112.599 E.02815
G1 X87.079 Y112.294 E.01673
G1 X86.471 Y111.702 E.02812
G1 X86.175 Y111.292 E.01677
G1 X85.766 Y110.551 E.0281
G3 X85.521 Y109.731 I3.908 J-1.613 E.02843
G1 X85.618 Y109.416 E.01093
G1 X85.826 Y109.226 E.00934
G1 X86.105 Y109.156 E.00953
G1 X86.218 Y109.174 E.00381
G1 X86.332 Y109.193 E.00381
G1 X86.445 Y109.211 E.00381
G1 X86.558 Y109.229 E.00381
G1 X86.672 Y109.247 E.00381
G2 X87.829 Y109.396 I25.973 J-196.863 E.03871
G2 X93.246 Y109.257 I2.152 J-21.725 E.1802
G1 X93.597 Y109.199 E.01182
G3 X93.83 Y109.166 I.192 J.532 E.00785
G1 X93.902 Y109.169 E.0024
G1 X93.975 Y109.173 E.0024
G3 X94.174 Y109.226 I.022 J.315 E.00697
G1 X94.382 Y109.416 E.00934
G1 X94.42 Y109.541 E.00435
M204 S250
G1 X94.066 Y109.713 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X94.072 Y109.754 E.00129
G1 X94.077 Y109.796 E.00129
G3 X86.117 Y110.374 I-4.077 J-1.046 E.32262
G1 X86.049 Y110.175 E.00644
G1 F7989.758
G1 X85.923 Y109.796 E.01229
G1 F3803.514
G1 X85.928 Y109.754 E.00129
G1 F3453.036
G1 X85.934 Y109.713 E.00129
G1 F3119.495
G1 X85.94 Y109.671 E.00129
G1 F2802.892
G1 X85.946 Y109.632 E.00122
G1 F2518.862
G1 X85.963 Y109.622 E.00061
G1 F2381.74
G1 X85.981 Y109.612 E.00061
G1 F2248.514
G1 X85.998 Y109.602 E.00061
G1 F2119.066
G1 X86.016 Y109.592 E.00061
G1 F1993.455
G1 X86.033 Y109.583 E.00061
G1 F1871.705
G1 X86.05 Y109.573 E.00061
G1 F1753.768
G1 X86.068 Y109.563 E.00061
G1 F1639.718
G1 X86.085 Y109.553 E.00061
G1 F1529.455
G1 X86.107 Y109.551 E.00069
G1 F1410.927
G1 X86.134 Y109.555 E.00083
G1 F1274.185
G1 X86.161 Y109.56 E.00083
G1 F1144.411
G1 X86.187 Y109.564 E.00083
G1 F1021.562
G1 X86.214 Y109.568 E.00083
G1 F905.728
G1 X86.24 Y109.573 E.00083
G1 F796.862
G1 X86.267 Y109.577 E.00083
G1 F694.963
G1 X86.294 Y109.582 E.00083
; FEATURE: Overhang wall
; LINE_WIDTH: 0.4
; LAYER_HEIGHT: 0.4
M106 S255
G1 F600
G2 X87.781 Y109.785 I7.529 J-49.422 E.07688
M106 S181.05
M106 S255

G2 X93.707 Y109.578 I2.194 J-22.03 E.30452
M106 S181.05
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
; LAYER_HEIGHT: 0.2
G1 F697.013
G1 X93.735 Y109.573 E.00085
G1 F801.33
G1 X93.762 Y109.569 E.00085
G1 F912.92
G1 X93.789 Y109.564 E.00085
G1 F1031.788
G1 X93.816 Y109.56 E.00085
G1 F1157.921
G1 X93.843 Y109.555 E.00085
G1 F1287.408
G1 X93.87 Y109.552 E.00082
G1 F1407.242
G1 X93.893 Y109.556 E.00072
G1 F1532.416
G1 X93.916 Y109.559 E.00072
G1 F1662.914
G1 X93.939 Y109.563 E.00072
G1 F1798.753
G1 X93.963 Y109.567 E.00072
G1 F1939.914
G1 X93.986 Y109.571 E.00072
G1 F2054.031
G1 X94 Y109.582 E.00057
G1 F2170.549
G1 X94.014 Y109.595 E.00056
G1 F2290.326
G1 X94.027 Y109.607 E.00056
G1 F2413.273
G1 X94.041 Y109.619 E.00056
G1 F2539.43
G1 X94.054 Y109.632 E.00056
G1 F2695.084
G1 X94.058 Y109.653 E.00067
; WIPE_START
M204 S6000
G1 X94.072 Y109.754 E-.03875
G1 X94.077 Y109.796 E-.01595
G1 X93.893 Y110.353 E-.22287
G1 X93.618 Y110.902 E-.23348
G1 X93.263 Y111.41 E-.23542
G1 X93.238 Y111.436 E-.01353
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.025 Y106.352 Z.8 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X90.015 Y106.346 E.00039
G3 X86.74 Y106.059 I-.015 J-18.599 E.1092
G3 X81.219 Y71.351 I3.261 J-18.312 E1.52619
G3 X90.926 Y106.323 I8.78 J16.396 E2.21078
G1 X90.085 Y106.35 E.02792
M204 S250
G1 X90.016 Y105.96 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X90.005 Y105.954 E.00038
G3 X86.807 Y105.672 I-.005 J-18.207 E.09878
G3 X81.412 Y71.692 I3.194 J-17.925 E1.38415
G3 X90.898 Y105.932 I8.587 J16.055 E2.00472
G1 X90.076 Y105.958 E.02526
; WIPE_START
M204 S6000
G1 X90.005 Y105.954 E-.02702
G1 X89.111 Y105.938 E-.33954
G1 X88.22 Y105.872 E-.33971
G1 X88.08 Y105.855 E-.05372
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z.8 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z0.8
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X94.886 Y109.753 F42000
G1 Z.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.434308
G1 F9198.034
M204 S6000
G3 X94.262 Y111.355 I-4.925 J-.994 E.05512
G1 X93.873 Y111.911 E.02163
G1 X93.532 Y112.282 E.01607
G1 X92.822 Y112.875 E.02951
G3 X89.511 Y113.72 I-2.848 J-4.247 E.11113
G1 X88.55 Y113.533 E.03122
G1 X87.877 Y113.273 E.02301
G1 X87.285 Y112.945 E.02158
G3 X85.128 Y109.811 I2.737 J-4.193 E.12445
; WIPE_START
G1 X85.221 Y110.199 E-.15158
G1 X85.403 Y110.711 E-.2065
G1 X85.722 Y111.33 E-.26452
G1 X85.928 Y111.627 E-.1374
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X92.752 Y108.208 Z.8 F42000
G1 X94.422 Y107.371 Z.8
G1 Z.4
G1 E.8 F1800
; LINE_WIDTH: 0.426553
G1 F9383.981
M204 S6000
G1 X94.298 Y107.419 E.00415
; LINE_WIDTH: 0.465938
G1 F8510.287
G1 X94.174 Y107.466 E.00458
; LINE_WIDTH: 0.505323
G1 F7785.425
G1 X94.05 Y107.514 E.005
; LINE_WIDTH: 0.544708
G1 F7174.352
G1 X93.926 Y107.562 E.00543
G1 X94.048 Y107.602 E.00525
; LINE_WIDTH: 0.505323
G1 F7785.425
G1 X94.17 Y107.643 E.00484
; LINE_WIDTH: 0.465938
G1 F8510.287
G1 X94.291 Y107.683 E.00443
; LINE_WIDTH: 0.42578
G1 F9402.914
G2 X94.513 Y107.752 I.759 J-2.074 E.00725
G1 X94.935 Y107.433 E.01648
; LINE_WIDTH: 0.475313
G1 F8325.769
G1 X95.043 Y107.35 E.00481
; LINE_WIDTH: 0.522398
G1 F7508.172
G1 X95.151 Y107.266 E.00533
; LINE_WIDTH: 0.52276
G1 F7502.501
G1 X94.928 Y107.298 E.00882
; LINE_WIDTH: 0.4764
G1 F8304.881
G1 X94.704 Y107.33 E.00797
; LINE_WIDTH: 0.43004
G1 F9299.442
G1 X94.481 Y107.363 E.00712
M204 S10000
G1 X90 Y109.114 F42000
; LINE_WIDTH: 0.420226
G1 F9541.346
M204 S6000
G2 X92.093 Y109.011 I-.002 J-21.394 E.06444
G1 X93.907 Y108.767 E.05629
G1 X94.365 Y108.884 E.01453
G1 X94.708 Y109.199 E.01433
G1 X94.89 Y109.727 E.01716
G3 X95.147 Y108.738 I3.339 J.34 E.03154
G1 X95.358 Y108.507 E.00963
G1 X95.695 Y108.333 E.01166
G2 X80.81 Y107.034 I-5.703 J-20.584 E3.65682
G2 X84.457 Y108.392 I10.802 J-23.425 E.11977
G1 X84.824 Y108.689 E.01453
G1 X85.008 Y109.135 E.01481
G2 X85.11 Y109.727 I3.903 J-.371 E.01849
G1 X85.268 Y109.248 E.0155
G1 X85.602 Y108.908 E.01466
G1 X86.069 Y108.765 E.015
G3 X87.907 Y109.011 I-60.096 J456.33 E.05704
G2 X89.94 Y109.112 I2.049 J-20.673 E.06259
M204 S10000
G1 X90 Y108.736 F42000
; LINE_WIDTH: 0.41999
G1 F9547.301
M204 S6000
G2 X92.054 Y108.636 I-.001 J-20.992 E.0632
G1 X93.857 Y108.393 E.05591
G3 X94.554 Y108.557 I-.111 J2.031 E.02212
G1 X94.748 Y108.717 E.00773
G1 X94.907 Y108.424 E.01024
G1 X95.182 Y108.174 E.01142
G1 X95.595 Y107.97 E.01417
G2 X80.979 Y106.697 I-5.603 J-20.22 E3.59027
G2 X84.566 Y108.031 I10.642 J-23.117 E.11769
G1 X84.77 Y108.143 E.00714
G1 X85.116 Y108.451 E.01425
G1 X85.252 Y108.717 E.00917
G1 X85.488 Y108.535 E.00917
G1 X86.043 Y108.388 E.01762
G3 X87.947 Y108.636 I-10.923 J91.572 E.05899
G2 X89.94 Y108.735 I2.009 J-20.276 E.06135
M204 S10000
G1 X90 Y108.359 F42000
; LINE_WIDTH: 0.41999
G1 F9547.302
M204 S6000
G2 X92.014 Y108.26 I-.001 J-20.59 E.062
G1 X93.807 Y108.019 E.05556
G1 X94.183 Y108.045 E.01159
G1 X94.63 Y108.168 E.01425
G1 X94.826 Y107.964 E.00867
G1 X95.304 Y107.682 E.01705
G2 X97.845 Y106.806 I-9.437 J-31.497 E.08263
G2 X83.976 Y107.458 I-7.845 J-19.053 E3.54284
G1 X84.675 Y107.67 E.02245
G1 X85.015 Y107.856 E.0119
G1 X85.374 Y108.177 E.0148
G1 X86.026 Y108.012 E.02066
G3 X87.986 Y108.26 I-6.744 J60.98 E.0607
G2 X89.94 Y108.358 I1.97 J-19.879 E.06015
M204 S10000
G1 X90.023 Y107.498 F42000
G1 F9547.302
M204 S6000
G3 X95.755 Y106.641 I-.023 J-19.746 E3.63343
G3 X90.083 Y107.496 I-5.837 J-19.468 E.17682
M204 S10000
G1 X90.014 Y107.121 F42000
; LINE_WIDTH: 0.41999
G1 F9547.301
M204 S6000
G3 X95.636 Y106.283 I-.013 J-19.369 E3.56406
G3 X90.074 Y107.119 I-5.707 J-19.034 E.17342
M204 S10000
G1 X90.005 Y106.744 F42000
G1 F9547.301
M204 S6000
G3 X95.518 Y105.925 I-.004 J-18.992 E3.49472
G3 X90.065 Y106.743 I-5.59 J-18.687 E.17001
M204 S10000
G1 X86.074 Y107.562 F42000
; LINE_WIDTH: 0.527557
G1 F7428.243
M204 S6000
G2 X88.977 Y107.902 I5.049 J-30.509 E.11546
G2 X93.748 Y107.583 I.955 J-21.571 E.18923
G1 X93.867 Y107.569 E.00472
M204 S10000
G1 X85.555 Y107.369 F42000
; LINE_WIDTH: 0.434972
G1 F9182.463
M204 S6000
G1 X85.384 Y107.353 E.0055
; LINE_WIDTH: 0.479875
G1 F8238.835
G1 X85.213 Y107.337 E.00613
; LINE_WIDTH: 0.524779
G1 F7471.076
G1 X85.041 Y107.32 E.00676
; LINE_WIDTH: 0.554785
G1 F7033.105
G1 X85 Y107.317 E.0017
; LINE_WIDTH: 0.53737
G1 F7280.818
G1 X85.132 Y107.441 E.00729
; LINE_WIDTH: 0.48743
G1 F8098.806
G1 X85.263 Y107.565 E.00655
; LINE_WIDTH: 0.428707
G1 F9331.59
G2 X85.469 Y107.753 I1.976 J-1.958 E.00877
; LINE_WIDTH: 0.433474
G1 F9217.692
G1 X85.648 Y107.694 E.006
; LINE_WIDTH: 0.47538
G1 F8324.469
G1 X85.827 Y107.635 E.00665
; LINE_WIDTH: 0.517287
G1 F7589.066
G1 X86.006 Y107.576 E.00729
; LINE_WIDTH: 0.55126
M73 P37 R13
G1 F7081.874
G1 X86.074 Y107.562 E.00286
; LINE_WIDTH: 0.54531
G1 F7165.748
G1 X85.958 Y107.519 E.00505
; LINE_WIDTH: 0.50737
G1 F7751.103
G1 X85.843 Y107.476 E.00467
; LINE_WIDTH: 0.46943
G1 F8440.6
G1 X85.727 Y107.433 E.00429
; LINE_WIDTH: 0.43149
G1 F9264.74
G1 X85.612 Y107.39 E.0039
M204 S10000
G1 X85 Y107.317 F42000
; LINE_WIDTH: 0.526026
G1 F7451.793
M204 S6000
G3 X78.008 Y103.978 I5.49 J-20.488 E.30676
G3 X95.208 Y107.248 I11.995 J-16.223 E4.2776
; WIPE_START
G1 X95.889 Y107.049 E-.26971
G1 X96.83 Y106.737 E-.37655
G1 X97.109 Y106.629 E-.11374
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X95.418 Y99.186 Z.8 F42000
G1 X89.212 Y71.881 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X89.608 Y71.864 E.01315
G3 X105.888 Y87.358 I.394 J15.886 E.82805
G1 X105.888 Y88.142 E.02599
G3 X88.84 Y71.902 I-15.886 J-.392 E2.43238
G1 X89.152 Y71.885 E.01036
M204 S250
G1 X89.193 Y71.49 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.599 Y71.472 E.01247
G3 X106.28 Y87.349 I.403 J16.278 E.78595
G1 X106.28 Y88.151 E.02467
G3 X88.812 Y71.511 I-16.278 J-.401 E2.30873
G1 X89.133 Y71.493 E.00989
; WIPE_START
M204 S6000
G1 X89.599 Y71.472 E-.17699
G1 X90.41 Y71.47 E-.30844
G1 X91.132 Y71.505 E-.27457
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X83.912 Y73.981 Z.8 F42000
G1 X80.634 Y75.105 Z.8
G1 Z.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42255
G1 F9482.917
M204 S6000
G1 X78.937 Y76.801 E.07423
G2 X76.854 Y79.421 I11.258 J11.089 E.10374
G1 X81.671 Y74.604 E.21075
G3 X82.922 Y73.89 I8.324 J13.13 E.04457
G1 X76.14 Y80.672 E.29671
G2 X75.668 Y81.681 I9.91 J5.254 E.03449
G1 X83.931 Y73.418 E.36153
G3 X84.811 Y73.075 I9.86 J24.027 E.02919
G1 X75.325 Y82.561 E.41497
G2 X75.069 Y83.354 I7.733 J2.937 E.0258
G1 X85.604 Y72.819 E.46088
G3 X86.337 Y72.622 I2.351 J7.306 E.0235
G1 X74.873 Y84.087 E.50157
G2 X74.722 Y84.775 I6.93 J1.881 E.02179
G1 X87.025 Y72.472 E.53826
G1 X87.674 Y72.359 E.02038
G1 X74.609 Y85.424 E.57156
G2 X74.531 Y86.04 I6.433 J1.134 E.0192
G1 X88.29 Y72.281 E.60193
G3 X88.879 Y72.228 I.813 J5.777 E.01832
G1 X74.478 Y86.629 E.63002
G2 X74.447 Y87.197 I5.857 J.607 E.01761
G1 X89.447 Y72.197 E.65624
G1 X89.998 Y72.183 E.01703
G1 X74.433 Y87.748 E.68092
G1 X74.446 Y88.272 E.01622
G1 X90.522 Y72.196 E.70329
G3 X91.033 Y72.222 I-.009 J5.294 E.01584
G1 X74.472 Y88.783 E.72453
G2 X74.509 Y89.283 I4.895 J-.11 E.01551
G1 X91.533 Y72.259 E.74479
G1 X92.01 Y72.318 E.01489
G1 X74.568 Y89.76 E.76308
G2 X74.636 Y90.229 I4.963 J-.478 E.01467
G1 X92.479 Y72.386 E.78063
G1 X92.937 Y72.465 E.01437
G1 X74.715 Y90.687 E.79719
G2 X74.809 Y91.13 I4.546 J-.734 E.01401
G1 X93.38 Y72.559 E.81245
G3 X93.817 Y72.659 I-.79 J4.469 E.01388
G1 X74.909 Y91.567 E.82721
G1 X75.025 Y91.988 E.0135
G1 X94.238 Y72.775 E.84052
G3 X94.652 Y72.897 I-1.002 J4.171 E.01338
G1 X75.147 Y92.402 E.85333
G1 X75.281 Y92.806 E.01314
G1 X95.056 Y73.031 E.86512
G3 X95.451 Y73.173 I-1.288 J4.202 E.01299
G1 X75.423 Y93.2 E.87618
G1 X75.572 Y93.588 E.01285
G1 X95.838 Y73.322 E.8866
G3 X96.215 Y73.482 I-1.45 J3.94 E.01267
G1 X75.732 Y93.965 E.89608
G1 X75.897 Y94.337 E.01259
G1 X96.587 Y73.647 E.90516
G3 X96.947 Y73.824 I-1.602 J3.712 E.01241
G1 X76.074 Y94.697 E.91316
G1 X76.254 Y95.054 E.01237
G1 X97.304 Y74.004 E.92091
G3 X97.648 Y74.197 I-1.808 J3.634 E.01221
G1 X76.447 Y95.398 E.92754
G1 X76.641 Y95.741 E.01219
G1 X97.991 Y74.391 E.93405
G3 X98.32 Y74.599 I-1.864 J3.314 E.01204
G1 X76.849 Y96.07 E.93935
G1 X77.057 Y96.398 E.01203
G1 X98.648 Y74.807 E.9446
G1 X98.964 Y75.029 E.01192
G1 X77.279 Y96.714 E.94868
G2 X77.501 Y97.028 I3.245 J-2.053 E.01192
G1 X99.278 Y75.251 E.95274
G1 X99.58 Y75.486 E.01183
G1 X77.736 Y97.33 E.95564
G2 X77.972 Y97.631 I3.197 J-2.257 E.01184
G1 X99.881 Y75.722 E.95851
G1 X100.17 Y75.97 E.01178
G1 X78.22 Y97.92 E.96026
G1 X78.469 Y98.208 E.01178
G1 X100.458 Y76.219 E.96199
G1 X100.733 Y76.481 E.01175
G1 X78.731 Y98.483 E.96254
G1 X78.993 Y98.757 E.01174
G1 X101.007 Y76.743 E.9631
G1 X101.269 Y77.018 E.01175
G1 X79.268 Y99.019 E.96254
G1 X79.543 Y99.282 E.01175
G1 X101.532 Y77.293 E.96199
G1 X101.78 Y77.581 E.01178
G1 X79.831 Y99.53 E.96025
G1 X80.119 Y99.779 E.01178
G1 X102.029 Y77.869 E.95851
G3 X102.264 Y78.171 I-3.079 J2.65 E.01184
G1 X80.421 Y100.014 E.95563
G1 X80.722 Y100.25 E.01183
G1 X102.5 Y78.472 E.95274
G3 X102.722 Y78.787 I-3.134 J2.446 E.01192
G1 X81.037 Y100.472 E.94868
G1 X81.352 Y100.693 E.01192
G1 X102.943 Y79.102 E.94459
G1 X103.152 Y79.431 E.01203
G1 X81.681 Y100.902 E.93934
G2 X82.01 Y101.11 I2.225 J-3.158 E.01204
G1 X103.36 Y79.76 E.93404
G1 X103.554 Y80.102 E.01219
G1 X82.352 Y101.304 E.92753
G2 X82.697 Y101.496 I2.146 J-3.432 E.01221
G1 X103.746 Y80.447 E.9209
G1 X103.926 Y80.804 E.01237
G1 X83.054 Y101.676 E.91314
G2 X83.414 Y101.853 I1.961 J-3.533 E.01241
G1 X104.103 Y81.164 E.90514
G1 X104.268 Y81.536 E.01259
G1 X83.786 Y102.018 E.89607
G2 X84.163 Y102.178 I1.829 J-3.785 E.01267
G1 X104.428 Y81.913 E.88658
G1 X104.577 Y82.3 E.01285
G1 X84.55 Y102.327 E.87616
G2 X84.945 Y102.469 I1.684 J-4.064 E.01299
M73 P38 R13
G1 X104.719 Y82.695 E.8651
G1 X104.853 Y83.098 E.01314
G1 X85.348 Y102.603 E.85331
G2 X85.763 Y102.725 I1.418 J-4.052 E.01338
G1 X104.975 Y83.513 E.8405
G1 X105.091 Y83.934 E.0135
G1 X86.184 Y102.841 E.82719
G2 X86.621 Y102.941 I1.228 J-4.374 E.01388
G1 X105.191 Y84.371 E.81243
G3 X105.285 Y84.814 I-4.445 J1.175 E.01401
G1 X87.064 Y103.035 E.79717
G1 X87.521 Y103.114 E.01437
G1 X105.364 Y85.271 E.7806
G3 X105.432 Y85.74 I-4.898 J.948 E.01467
G1 X87.99 Y103.182 E.76305
G1 X88.468 Y103.241 E.01489
G1 X105.491 Y86.218 E.74476
G3 X105.528 Y86.718 I-4.88 J.612 E.01552
G1 X88.968 Y103.278 E.7245
G2 X89.479 Y103.304 I.52 J-5.269 E.01584
G1 X105.554 Y87.229 E.70325
G1 X105.567 Y87.753 E.01622
G1 X90.003 Y103.317 E.68088
G1 X90.554 Y103.303 E.01703
M73 P38 R12
G1 X105.553 Y88.304 E.6562
G3 X105.522 Y88.872 I-5.883 J-.039 E.01761
G1 X91.122 Y103.272 E.62997
G2 X91.711 Y103.219 I-.224 J-5.831 E.01832
G1 X105.469 Y89.461 E.60188
G3 X105.39 Y90.077 I-6.491 J-.517 E.0192
G1 X92.327 Y103.14 E.57151
G1 X92.976 Y103.028 E.02038
G1 X105.278 Y90.726 E.5382
G3 X105.127 Y91.414 I-7.077 J-1.192 E.02179
G1 X93.664 Y102.877 E.50151
G2 X94.397 Y102.681 I-1.622 J-7.515 E.0235
G1 X104.931 Y92.147 E.46081
G3 X104.674 Y92.941 I-7.988 J-2.144 E.0258
G1 X95.191 Y102.424 E.41489
G2 X96.07 Y102.082 I-9 J-24.407 E.0292
G1 X104.332 Y93.82 E.36143
G3 X103.859 Y94.83 I-10.383 J-4.245 E.0345
G1 X97.08 Y101.609 E.29659
G2 X98.331 Y100.894 I-7.075 J-13.843 E.0446
G1 X103.144 Y96.081 E.21058
G3 X101.535 Y98.204 I-12.916 J-8.122 E.08253
G3 X99.369 Y100.393 I-47.366 J-44.687 E.09527
; CHANGE_LAYER
; Z_HEIGHT: 0.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F9482.917
G1 X100.783 Y98.979 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 3/25
; update layer progress
M73 L3
M991 S0 P2 ;notify layer change
M106 S188.7
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z.8 I-.633 J-1.039 P1  F42000
G1 X91.456 Y104.659 Z.8
G1 Z.6
G1 E.8 F1800
; FEATURE: Support
; LINE_WIDTH: 0.42
G1 F9000
M204 S6000
G3 X91.509 Y105.2 I-.008 J.274 E.02431
G3 X91.232 Y104.782 I-.005 J-.298 E.01832
G3 X91.4 Y104.656 I.225 J.124 E.00666
; WIPE_START
G1 X91.684 Y104.781 E-.14411
G1 X91.732 Y104.911 E-.06386
G1 X91.715 Y105.036 E-.05876
G1 X91.509 Y105.2 E-.12196
G1 X91.287 Y105.116 E-.11013
G1 X91.221 Y105.01 E-.058
G1 X91.232 Y104.782 E-.10573
G1 X91.4 Y104.656 E-.09746
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.581 Y104.657 Z1 F42000
G1 Z.6
G1 E.8 F1800
G1 F9000
M204 S6000
G3 X88.817 Y104.804 I-.002 J.266 E.00895
G3 X88.525 Y104.656 I-.245 J.121 E.04193
; WIPE_START
G1 X88.778 Y104.727 E-.11867
G1 X88.817 Y104.804 E-.0386
G1 X88.777 Y105.115 E-.14129
G1 X88.688 Y105.197 E-.05463
G1 X88.494 Y105.194 E-.08788
G1 X88.369 Y105.099 E-.07044
G1 X88.309 Y104.835 E-.12219
G1 X88.525 Y104.656 E-.1263
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.552 Y97.023 Z1 F42000
G1 X88.649 Y70.298 Z1
G1 Z.6
G1 E.8 F1800
G1 F9000
M204 S6000
G3 X88.762 Y70.776 I-.151 J.288 E.0171
G3 X88.381 Y70.785 I-.196 J-.239 E.01262
G3 X88.594 Y70.285 I.223 J-.201 E.02093
; WIPE_START
G1 X88.764 Y70.379 E-.08627
G1 X88.815 Y70.504 E-.05968
G1 X88.762 Y70.776 E-.12319
G1 X88.515 Y70.849 E-.11433
G1 X88.381 Y70.785 E-.06605
G1 X88.293 Y70.67 E-.06443
G1 X88.288 Y70.539 E-.05815
G1 X88.379 Y70.37 E-.08524
G1 X88.594 Y70.285 E-.10265
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X91.548 Y70.309 Z1 F42000
G1 Z.6
G1 E.8 F1800
G1 F9000
M204 S6000
G3 X91.394 Y70.853 I-.115 J.261 E.02509
G3 X91.23 Y70.357 I.094 J-.306 E.01876
G3 X91.498 Y70.283 I.199 J.197 E.00893
; WIPE_START
G1 X91.709 Y70.464 E-.12284
G1 X91.717 Y70.586 E-.05412
G1 X91.649 Y70.728 E-.06932
G1 X91.394 Y70.853 E-.12523
G1 X91.228 Y70.755 E-.08517
G1 X91.185 Y70.643 E-.05324
G1 X91.23 Y70.357 E-.12747
G1 X91.498 Y70.283 E-.1226
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.024 Y77.772 Z1 F42000
G1 X83.922 Y108.78 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X83.556 Y108.671 E.01266
G3 X111.897 Y87.79 I6.449 J-20.921 E3.20624
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49733
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.216 Y108.863 E.00806
G1 X83.979 Y108.796 E.00817
M204 S250
G1 X84.104 Y109.239 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F8106.808
M204 S5000
G1 X83.94 Y109.192 E.00521
G1 F6128.179
G1 X83.777 Y109.146 E.00521
G1 F4425.892
G1 X83.614 Y109.099 E.00521
G1 F3000
G1 X83.451 Y109.053 E.00521
G1 F2700
G1 X83.432 Y109.048 E.00062
G3 X112.289 Y87.8 I6.571 J-21.296 E3.02347
G3 X96.36 Y109.11 I-22.302 J-.061 E.87591
G1 F3000
G1 X96.269 Y109.136 E.00291
G1 F3760.749
G1 X96.178 Y109.162 E.00291
G1 F4607.399
G1 X96.087 Y109.188 E.00291
G1 F5539.803
G1 X95.996 Y109.213 E.00291
G1 F6558.172
G1 X95.905 Y109.239 E.00291
G1 F7362.472
G2 X95.844 Y109.271 I-.009 J.057 E.00229
G1 F7963.978
G1 X95.814 Y109.311 E.00152
G1 F8589.021
G1 X95.783 Y109.35 E.00152
G1 F9237.756
G1 X95.753 Y109.39 E.00152
G1 F9547.299
G1 X95.68 Y109.783 E.01229
G1 X95.602 Y110.204 E.01315
G3 X84.376 Y110.118 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.192 Y109.297 E.00076
G1 X84.172 Y109.283 E.00076
G1 X84.154 Y109.271 E.00065
; WIPE_START
M204 S6000
G1 X83.94 Y109.192 E-.0866
G1 X83.777 Y109.146 E-.06448
G1 X83.614 Y109.099 E-.06447
G1 X83.451 Y109.053 E-.06447
G1 X83.432 Y109.048 E-.00762
M73 P39 R12
M73 C4
G1 X82.391 Y108.699 E-.41684
G1 X82.255 Y108.646 E-.05552
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.871 Y109.148 Z1 F42000
G1 X94.196 Y109.433 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.849 J-.924 E.03357
G1 X93.721 Y111.457 E.02248
G1 X93.397 Y111.841 E.01666
G1 X92.719 Y112.463 E.03052
G1 X92.207 Y112.787 E.02011
G1 X91.59 Y113.067 E.02247
G1 X91.107 Y113.207 E.01669
G1 X90.268 Y113.343 E.02819
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.02818
G1 X88.443 Y113.071 E.01671
G1 X87.671 Y112.718 E.02815
G1 X87.256 Y112.433 E.01671
G1 X86.619 Y111.871 E.02816
G1 X86.305 Y111.478 E.01667
G1 X85.859 Y110.755 E.02818
G3 X85.563 Y109.932 I5.127 J-2.312 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X93.76 Y109.316 I3.838 J-21.937 E.2543
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.941 Y109.73 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.116 J.247 E.00266
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.02431
G3 X92.501 Y112.137 I-3.664 J-2.77 E.03876
G3 X86.201 Y110.562 I-2.5 J-3.389 E.22785
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.787 E.00519
G1 F9488.594
G1 X86.129 Y109.7 E.00525
G1 F7321.578
G1 X86.184 Y109.709 E.00171
G1 F6677.736
G1 X86.239 Y109.718 E.00171
G1 F6063.414
G1 X86.294 Y109.727 E.00171
G1 F5478.729
G1 X86.349 Y109.735 E.00171
G1 F4923.778
G1 X86.403 Y109.744 E.00171
G1 F4398.362
G1 X86.458 Y109.753 E.00171
G1 F3902.569
G1 X86.513 Y109.762 E.00171
G1 F3436.509
G1 X86.568 Y109.771 E.00171
G1 F3000
G1 X86.623 Y109.78 E.00171
G1 F2700
G2 X93.167 Y109.811 I3.38 J-22.633 E.20179
G1 X93.175 Y109.81 E.00024
G1 F3000
G1 X93.247 Y109.798 E.00225
G1 F3582.253
G1 X93.32 Y109.786 E.00225
G1 F4216.113
G1 X93.392 Y109.774 E.00225
G1 F4901.578
G1 X93.464 Y109.762 E.00225
G1 F5638.633
G1 X93.537 Y109.75 E.00225
G1 F6427.31
G1 X93.609 Y109.738 E.00225
G1 F7267.592
G1 X93.681 Y109.726 E.00225
G1 F8159.481
G1 X93.754 Y109.714 E.00225
G1 F9547.299
G3 X93.884 Y109.711 I.071 J.263 E.00403
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05521
G1 X94.037 Y109.947 E-.06473
G1 X93.789 Y110.564 E-.25266
G1 X93.389 Y111.247 E-.30061
G1 X93.241 Y111.42 E-.08678
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.025 Y106.352 Z1 F42000
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X90.015 Y106.347 E.00039
G3 X77.497 Y73.976 I-.015 J-18.6 E1.48397
G3 X94.904 Y105.689 I12.501 J13.772 E2.22835
G3 X90.926 Y106.324 I-4.904 J-17.941 E.13386
G1 X90.085 Y106.35 E.02791
M204 S250
G1 X90.016 Y105.96 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X90.005 Y105.955 E.00038
G3 X77.768 Y74.261 I-.005 J-18.208 E1.34562
G3 X94.799 Y105.311 I12.231 J13.487 E2.02038
G3 X90.898 Y105.933 I-4.799 J-17.564 E.12162
G1 X90.076 Y105.958 E.02525
; WIPE_START
M204 S6000
G1 X90.005 Y105.955 E-.02715
G1 X89.111 Y105.938 E-.33954
G1 X88.22 Y105.872 E-.33968
G1 X88.08 Y105.855 E-.05364
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z1
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    
      M400
      G90
      M83
      M204 S5000
      G0 Z2 F4000
      G0 X187 Y178 F20000
      G39 S1 X187 Y178
      G0 Z2 F4000
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
        M623
    
    M623
M623
; SKIPPABLE_END




G1 Z1.000
G1 X94.84 Y109.972 F42000
G1 Z.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.432698
G1 F9236.038
M204 S6000
G1 X94.702 Y110.447 E.01571
G1 X94.44 Y111.04 E.0206
G1 X94.024 Y111.715 E.02518
G1 X93.7 Y112.103 E.01606
G1 X93.036 Y112.719 E.02876
G3 X88.048 Y113.34 I-3.031 J-3.997 E.16723
G1 X87.442 Y113.044 E.02143
G1 X87.025 Y112.761 E.016
G1 X86.307 Y112.118 E.03061
G3 X85.471 Y110.864 I4.704 J-4.039 E.048
G1 X85.175 Y110.022 E.02833
; WIPE_START
G1 X85.471 Y110.864 E-.33892
G1 X85.718 Y111.317 E-.19616
G1 X85.989 Y111.725 E-.18616
G1 X86.053 Y111.804 E-.03876
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1 I.66 J1.022 P1  F42000
G1 X90 Y109.256 Z1
G1 Z.6
G1 E.8 F1800
; LINE_WIDTH: 0.420206
G1 F9541.838
M204 S6000
G2 X93.158 Y109.022 I-.186 J-23.979 E.09741
G1 X93.884 Y108.919 E.02257
G1 X94.312 Y109.028 E.01355
G1 X94.651 Y109.325 E.01388
G1 X94.84 Y109.972 E.02071
G1 X94.96 Y109.372 E.0188
G1 X95.143 Y108.872 E.01639
G1 X95.351 Y108.652 E.0093
G1 X95.679 Y108.486 E.0113
G2 X81.711 Y107.592 I-5.686 J-20.736 E3.71509
G2 X84.487 Y108.551 I11.376 J-28.414 E.09032
G1 X84.846 Y108.848 E.01433
G1 X85.033 Y109.338 E.01611
G2 X85.159 Y109.965 I23.115 J-4.321 E.01965
G1 X85.257 Y109.486 E.01503
G1 X85.35 Y109.332 E.00552
G1 X85.702 Y109.022 E.01443
G1 X85.938 Y108.94 E.00768
G1 X86.307 Y108.93 E.01135
G2 X89.94 Y109.254 I3.636 J-20.21 E.11228
M204 S10000
G1 X90 Y108.878 F42000
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S6000
G2 X93.108 Y108.648 I-.183 J-23.579 E.09582
G1 X93.832 Y108.546 E.02246
G3 X94.495 Y108.698 I-.065 J1.805 E.02105
G1 X94.726 Y108.883 E.00908
G1 X94.907 Y108.556 E.01149
G1 X95.177 Y108.318 E.01104
G1 X95.578 Y108.122 E.01373
G2 X81.864 Y107.247 I-5.585 J-20.372 E3.64812
G2 X84.596 Y108.191 I11.211 J-28.039 E.08886
G3 X85.156 Y108.633 I-.871 J1.675 E.02205
G1 X85.273 Y108.888 E.00861
G1 X85.565 Y108.67 E.01119
G1 X85.923 Y108.564 E.01148
G1 X86.371 Y108.558 E.01378
G2 X89.94 Y108.877 I3.572 J-19.85 E.11023
M204 S10000
G1 X89.952 Y108.5 F42000
G1 F9547.299
M204 S6000
G2 X92.997 Y108.282 I-.126 J-23.136 E.09387
G1 X93.779 Y108.172 E.02425
G1 X94.165 Y108.198 E.01191
G1 X94.603 Y108.333 E.01407
G1 X94.829 Y108.1 E.00998
G1 X95.293 Y107.832 E.01647
G2 X97.896 Y106.938 I-9.031 J-30.565 E.0846
G2 X83.931 Y107.593 I-7.896 J-19.185 E3.56726
G1 X84.706 Y107.83 E.0249
G3 X85.428 Y108.319 I-1.102 J2.401 E.0269
G1 X85.699 Y108.219 E.00889
G1 X86.237 Y108.173 E.01658
G2 X88.934 Y108.473 I4.964 J-32.429 E.08341
G1 X89.892 Y108.498 E.02944
M204 S10000
G1 X89.96 Y108.155 F42000
; LINE_WIDTH: 0.356879
G1 F11466.483
M204 S6000
G2 X93.729 Y107.825 I-.303 J-25.136 E.09689
; LINE_WIDTH: 0.388173
G1 F10427.151
G1 X94 Y107.823 E.00762
; LINE_WIDTH: 0.429818
G1 F9304.79
G1 X94.271 Y107.82 E.00854
; LINE_WIDTH: 0.450314
G1 F8836.655
G1 X94.486 Y107.868 E.0073
G1 X94.829 Y107.653 E.01343
; LINE_WIDTH: 0.397465
G1 F10153.86
G1 X95.107 Y107.54 E.00867
; LINE_WIDTH: 0.355589
G1 F11513.774
G3 X95.887 Y107.288 I1.468 J3.205 E.02093
G2 X84.039 Y107.265 I-5.887 J-19.534 E2.95985
G1 X84.808 Y107.496 E.02045
; LINE_WIDTH: 0.386038
G1 F10492.032
G1 X85.056 Y107.609 E.00762
; LINE_WIDTH: 0.427833
G1 F9352.775
G1 X85.304 Y107.722 E.00854
; LINE_WIDTH: 0.450294
G1 F8837.105
G1 X85.487 Y107.863 E.00769
G1 X85.893 Y107.815 E.01354
; LINE_WIDTH: 0.397123
G1 F10163.678
G1 X86.193 Y107.831 E.00869
; LINE_WIDTH: 0.35685
G1 F11467.535
G3 X87.003 Y107.934 I-.033 J3.462 E.02092
G2 X89.9 Y108.154 I3.169 J-22.618 E.07438
M204 S10000
G1 X90.032 Y107.843 F42000
; LINE_WIDTH: 0.358435
G1 F11409.92
M204 S6000
G3 X86.548 Y107.538 I-.039 J-19.642 E.09005
G1 X86.026 Y107.467 E.01355
; LINE_WIDTH: 0.41039
G1 F9796.718
G1 X85.753 Y107.419 E.00828
; LINE_WIDTH: 0.43595
G1 F9159.607
G1 X85.481 Y107.371 E.00886
; LINE_WIDTH: 0.427833
G1 F9352.775
G1 X85.189 Y107.278 E.00958
; LINE_WIDTH: 0.386038
G1 F10492.032
G1 X84.898 Y107.186 E.00854
; LINE_WIDTH: 0.355546
G1 F11515.382
G3 X95.863 Y106.968 I5.098 J-19.433 E2.93291
G1 X95.302 Y107.126 E.01484
; LINE_WIDTH: 0.369368
G1 F11027.807
G1 X95.003 Y107.218 E.00833
; LINE_WIDTH: 0.397463
G1 F10153.932
G1 X94.704 Y107.31 E.00904
; LINE_WIDTH: 0.41823
G1 F9592.071
G3 X93.679 Y107.505 I-1.231 J-3.685 E.03199
; LINE_WIDTH: 0.356991
G1 F11462.39
G3 X90.092 Y107.841 I-3.693 J-20.083 E.09232
M204 S10000
G1 X90.023 Y107.498 F42000
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S6000
G3 X95.754 Y106.641 I-.023 J-19.746 E3.63345
G3 X90.083 Y107.496 I-5.836 J-19.467 E.17681
M204 S10000
G1 X90.014 Y107.121 F42000
G1 F9547.299
M204 S6000
G3 X95.636 Y106.283 I-.014 J-19.369 E3.56409
G3 X90.074 Y107.119 I-5.716 J-19.1 E.17341
M204 S10000
G1 X90.005 Y106.744 F42000
G1 F9547.299
M204 S6000
G3 X95.518 Y105.925 I-.004 J-18.992 E3.49476
G3 X90.065 Y106.743 I-5.596 J-18.731 E.17
; WIPE_START
G1 X90.937 Y106.721 E-.33139
G1 X91.866 Y106.652 E-.35414
G1 X92.06 Y106.628 E-.07447
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X91.414 Y99.023 Z1 F42000
G1 X89.108 Y71.886 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X89.608 Y71.864 E.01662
G3 X105.888 Y87.358 I.394 J15.886 E.82805
G1 X105.888 Y88.142 E.02599
G3 X88.84 Y71.902 I-15.886 J-.392 E2.43238
G1 X89.048 Y71.89 E.00689
M204 S250
G1 X89.089 Y71.495 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.599 Y71.472 E.01569
G3 X106.28 Y87.349 I.403 J16.278 E.78595
G1 X106.28 Y88.151 E.02467
G3 X88.812 Y71.511 I-16.278 J-.401 E2.30873
G1 X89.029 Y71.498 E.00668
; WIPE_START
M204 S6000
G1 X89.599 Y71.472 E-.21679
G1 X90.41 Y71.47 E-.30844
G1 X91.027 Y71.5 E-.23478
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.594 Y75.39 Z1 F42000
G1 X102.643 Y78.381 Z1
G1 Z.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42255
G1 F9482.917
M204 S6000
G2 X100.454 Y76.215 I-46.913 J45.237 E.09527
G2 X98.331 Y74.606 I-10.245 J11.306 E.08253
G1 X103.144 Y79.419 E.21058
G3 X103.859 Y80.67 I-13.128 J8.326 E.0446
G1 X97.08 Y73.891 E.29659
G2 X96.07 Y73.418 I-5.256 J9.913 E.0345
G1 X104.332 Y81.68 E.36143
G3 X104.674 Y82.559 I-24.044 J9.872 E.0292
G1 X95.191 Y73.076 E.41489
G2 X94.397 Y72.819 I-2.938 J7.733 E.0258
G1 X104.931 Y83.353 E.46081
G3 X105.127 Y84.086 I-7.315 J2.354 E.0235
G1 X93.664 Y72.623 E.50151
G2 X92.976 Y72.472 I-1.879 J6.918 E.02179
G1 X105.278 Y84.774 E.5382
G1 X105.39 Y85.423 E.02038
G1 X92.327 Y72.36 E.57151
M73 P40 R12
G2 X91.711 Y72.281 I-1.136 J6.447 E.0192
G1 X105.469 Y86.039 E.60188
G3 X105.522 Y86.628 I-5.781 J.813 E.01832
G1 X91.122 Y72.228 E.62997
G2 X90.554 Y72.197 I-.608 J5.855 E.01761
G1 X105.553 Y87.196 E.6562
G1 X105.567 Y87.747 E.01703
G1 X90.003 Y72.183 E.68088
G1 X89.479 Y72.196 E.01622
G1 X105.554 Y88.271 E.70325
G3 X105.528 Y88.782 I-5.296 J-.009 E.01584
G1 X88.968 Y72.222 E.7245
G2 X88.468 Y72.259 I.113 J4.935 E.01552
G1 X105.491 Y89.282 E.74476
G1 X105.432 Y89.76 E.01489
G1 X87.99 Y72.318 E.76305
G2 X87.521 Y72.386 I.478 J4.961 E.01467
G1 X105.364 Y90.229 E.7806
G1 X105.285 Y90.686 E.01437
G1 X87.064 Y72.465 E.79717
G2 X86.621 Y72.559 I.734 J4.549 E.01401
G1 X105.191 Y91.129 E.81243
G3 X105.091 Y91.566 I-4.474 J-.791 E.01388
G1 X86.184 Y72.659 E.82719
G1 X85.763 Y72.775 E.0135
G1 X104.975 Y91.987 E.8405
G3 X104.853 Y92.402 I-4.172 J-1.002 E.01338
G1 X85.348 Y72.897 E.85331
G1 X84.945 Y73.031 E.01314
G1 X104.719 Y92.805 E.8651
G3 X104.577 Y93.2 I-4.206 J-1.289 E.01299
G1 X84.55 Y73.173 E.87616
G1 X84.163 Y73.322 E.01285
G1 X104.428 Y93.587 E.88658
G3 X104.268 Y93.964 I-3.932 J-1.447 E.01267
G1 X83.786 Y73.482 E.89607
G1 X83.414 Y73.647 E.01259
G1 X104.103 Y94.336 E.90514
G3 X103.926 Y94.696 I-3.704 J-1.598 E.01241
G1 X83.054 Y73.824 E.91314
G1 X82.697 Y74.004 E.01237
G1 X103.746 Y95.053 E.9209
G3 X103.554 Y95.398 I-3.642 J-1.812 E.01221
G1 X82.352 Y74.196 E.92753
G1 X82.01 Y74.39 E.01219
G1 X103.36 Y95.74 E.93404
G3 X103.152 Y96.069 I-3.365 J-1.896 E.01204
G1 X81.681 Y74.598 E.93934
G1 X81.352 Y74.807 E.01203
G1 X102.943 Y96.398 E.94459
G1 X102.722 Y96.713 E.01192
G1 X81.037 Y75.028 E.94868
G2 X80.722 Y75.25 I2.078 J3.28 E.01192
G1 X102.5 Y97.028 E.95274
G1 X102.264 Y97.329 E.01183
G1 X80.421 Y75.486 E.95563
G2 X80.119 Y75.721 I2.292 J3.241 E.01184
G1 X102.029 Y97.631 E.95851
G1 X101.78 Y97.919 E.01178
G1 X79.831 Y75.97 E.96025
G1 X79.543 Y76.218 E.01178
G1 X101.532 Y98.207 E.96199
G1 X101.269 Y98.482 E.01175
G1 X79.268 Y76.481 E.96254
G1 X78.993 Y76.743 E.01175
G1 X101.007 Y98.757 E.9631
G1 X100.733 Y99.019 E.01174
G1 X78.731 Y77.017 E.96254
G1 X78.469 Y77.292 E.01175
G1 X100.458 Y99.281 E.96199
G1 X100.17 Y99.53 E.01178
G1 X78.22 Y77.58 E.96026
G1 X77.972 Y77.869 E.01178
G1 X99.881 Y99.778 E.95851
G3 X99.58 Y100.014 I-2.567 J-2.971 E.01184
G1 X77.736 Y78.17 E.95564
G1 X77.501 Y78.472 E.01183
G1 X99.278 Y100.249 E.95274
G3 X98.964 Y100.471 I-2.406 J-3.077 E.01192
G1 X77.279 Y78.786 E.94869
G1 X77.057 Y79.102 E.01192
G1 X98.648 Y100.693 E.9446
G1 X98.32 Y100.901 E.01203
G1 X76.849 Y79.43 E.93935
G2 X76.641 Y79.759 I3.148 J2.219 E.01204
G1 X97.991 Y101.109 E.93405
G1 X97.648 Y101.303 E.01219
G1 X76.447 Y80.102 E.92755
G2 X76.254 Y80.446 I3.443 J2.153 E.01221
G1 X97.304 Y101.496 E.92092
G1 X96.947 Y101.676 E.01237
G1 X76.074 Y80.803 E.91316
G2 X75.897 Y81.163 I3.525 J1.957 E.01241
G1 X96.587 Y101.853 E.90516
G1 X96.215 Y102.018 E.01259
G1 X75.732 Y81.535 E.89608
G2 X75.572 Y81.912 I3.78 J1.828 E.01267
G1 X95.838 Y102.178 E.8866
G1 X95.451 Y102.327 E.01285
G1 X75.423 Y82.3 E.87618
G2 X75.281 Y82.694 I4.061 J1.684 E.01299
G1 X95.056 Y102.469 E.86512
G1 X94.652 Y102.603 E.01314
G1 X75.147 Y83.098 E.85333
G2 X75.025 Y83.512 I4.051 J1.418 E.01338
G1 X94.238 Y102.725 E.84052
G1 X93.817 Y102.841 E.0135
G1 X74.909 Y83.933 E.82721
G2 X74.809 Y84.37 I4.369 J1.227 E.01388
G1 X93.38 Y102.941 E.81245
G3 X92.937 Y103.035 I-1.179 J-4.462 E.01401
G1 X74.715 Y84.813 E.79719
G1 X74.636 Y85.271 E.01437
G1 X92.479 Y103.114 E.78063
G3 X92.01 Y103.182 I-.947 J-4.896 E.01467
G1 X74.568 Y85.74 E.76308
G1 X74.509 Y86.217 E.01489
G1 X91.533 Y103.241 E.74479
G3 X91.033 Y103.278 I-.611 J-4.862 E.01551
G1 X74.472 Y86.717 E.72453
G2 X74.446 Y87.228 I5.268 J.52 E.01584
G1 X90.522 Y103.304 E.70329
G1 X89.998 Y103.317 E.01622
G1 X74.433 Y87.752 E.68092
G1 X74.447 Y88.303 E.01703
G1 X89.447 Y103.303 E.65624
G3 X88.879 Y103.272 I.039 J-5.881 E.01761
G1 X74.478 Y88.871 E.63002
M73 P41 R12
G2 X74.531 Y89.46 I5.831 J-.223 E.01832
G1 X88.29 Y103.219 E.60193
G3 X87.674 Y103.141 I.519 J-6.513 E.0192
G1 X74.609 Y90.076 E.57157
G1 X74.722 Y90.725 E.02038
G1 X87.025 Y103.028 E.53826
G3 X86.337 Y102.878 I1.191 J-7.07 E.02179
G1 X74.873 Y91.413 E.50157
G2 X75.069 Y92.146 I7.514 J-1.621 E.0235
G1 X85.604 Y102.681 E.46088
G3 X84.811 Y102.425 I2.143 J-7.988 E.0258
G1 X75.325 Y92.939 E.41497
G2 X75.668 Y93.819 I24.363 J-8.979 E.02919
G1 X83.931 Y102.082 E.36153
G3 X82.922 Y101.61 I4.246 J-10.386 E.03449
G1 X76.14 Y94.828 E.29671
G2 X76.854 Y96.079 I13.849 J-7.076 E.04457
G1 X81.671 Y100.896 E.21075
G3 X79.052 Y98.813 I8.468 J-13.34 E.10372
G1 X77.355 Y97.116 E.07424
; CHANGE_LAYER
; Z_HEIGHT: 0.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F9482.917
G1 X78.769 Y98.53 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 4/25
; update layer progress
M73 L4
M991 S0 P3 ;notify layer change
M106 S201.45
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z1 I-1.074 J.572 P1  F42000
G1 X84.285 Y108.899 Z1
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X111.897 Y87.79 I5.787 J-21.115 E3.22945
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49733
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.111 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.891 J-21.493 E3.04525
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.118 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25112
G1 X82.491 Y108.737 E-.41561
G1 X82.262 Y108.649 E-.09327
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z1.2 F42000
G1 X94.196 Y109.433 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.85 J-.924 E.03357
G1 X93.721 Y111.457 E.02248
G1 X93.397 Y111.841 E.01667
G1 X92.707 Y112.471 E.03098
G1 X92.207 Y112.787 E.01963
G1 X91.59 Y113.067 E.02247
G1 X91.107 Y113.207 E.01669
G1 X90.268 Y113.343 E.02818
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.0282
G1 X88.443 Y113.071 E.0167
G1 X87.671 Y112.718 E.02815
G1 X87.256 Y112.433 E.01671
G1 X86.619 Y111.871 E.02816
G1 X86.305 Y111.478 E.01667
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.129 J-2.313 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X93.759 Y109.316 I3.838 J-21.808 E.25431
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.0243
G3 X92.497 Y112.139 I-3.408 J-2.515 E.03893
G3 X86.201 Y110.562 I-2.496 J-3.391 E.22771
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.787 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.012 E.23769
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05566
G1 X94.037 Y109.947 E-.06473
G1 X93.789 Y110.564 E-.25268
G1 X93.389 Y111.247 E-.30055
G1 X93.241 Y111.419 E-.08638
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.04 Y106.515 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X89.538 Y106.454 E.01678
G1 X89.255 Y106.334 E.01017
G3 X77.497 Y73.976 I.745 J-18.586 E1.45883
G3 X89.234 Y69.171 I12.501 J13.8 E.42927
G1 X89.534 Y69.052 E.0107
G1 X90.075 Y68.984 E.01808
G1 X90.533 Y69.075 E.0155
G1 X90.745 Y69.166 E.00765
G3 X96.28 Y105.26 I-.747 J18.586 E1.70103
G3 X91.837 Y106.261 I-6.604 J-18.958 E.15141
G2 X90.726 Y106.354 I.134 J8.284 E.037
G1 X90.241 Y106.498 E.01678
G1 X90.099 Y106.51 E.00473
M204 S250
G1 X90.14 Y106.119 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.653 Y106.078 E.01502
G1 X89.341 Y105.944 E.01042
G3 X77.768 Y74.261 I.659 J-18.196 E1.32525
G3 X89.334 Y69.558 I12.239 J13.527 E.39157
G1 X89.602 Y69.438 E.00901
G1 X90.024 Y69.373 E.01313
G3 X90.659 Y69.556 I-.069 J1.425 E.02048
G3 X90.669 Y105.942 I-.659 J18.193 E1.71647
G1 X90.196 Y106.1 E.01531
; WIPE_START
M204 S6000
G1 X89.653 Y106.078 E-.20685
G1 X89.341 Y105.944 E-.12888
G1 X88.227 Y105.873 E-.42427
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.2 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z1.2
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z1.2 F4000
            G39.3 S1
            G0 Z1.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X90.876 Y106.715 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Internal solid infill
G1 F9547.299
M204 S6000
G1 X90.152 Y106.905 E.02297
G1 X89.644 Y106.874 E.01565
G1 X89.125 Y106.719 E.01664
G1 X88.253 Y106.66 E.02685
G1 X88.573 Y107.103 E.0168
G1 X89.068 Y107.617 E.02191
G1 X89.536 Y107.903 E.01686
G1 X89.908 Y107.986 E.01172
G1 X90.297 Y107.946 E.01201
G1 X90.542 Y107.856 E.00801
G1 X90.973 Y107.575 E.0158
G1 X91.418 Y107.113 E.01971
G1 X91.746 Y106.66 E.0172
G1 X90.935 Y106.711 E.02496
M204 S10000
G1 X90.96 Y107.07 F42000
; LINE_WIDTH: 0.38876
G1 F10409.457
M204 S6000
G1 X90.233 Y107.251 E.02112
G1 X89.76 Y107.251 E.01334
G3 X89.062 Y107.082 I.449 J-3.388 E.02026
G1 X89.399 Y107.39 E.01286
G1 X89.705 Y107.569 E.00997
G1 X90.093 Y107.623 E.01105
G1 X90.356 Y107.552 E.00769
G1 X90.717 Y107.328 E.01197
G1 X90.919 Y107.113 E.00831
; WIPE_START
G1 X90.717 Y107.328 E-.11205
G1 X90.356 Y107.552 E-.16134
G1 X90.093 Y107.623 E-.10364
G1 X89.705 Y107.569 E-.14896
G1 X89.399 Y107.39 E-.13448
G1 X89.206 Y107.213 E-.09953
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X85.941 Y111.57 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X85.245 Y110.107 I2.757 J-2.209 E.05424
G1 X85.165 Y110.187 E.00377
G2 X89.28 Y113.748 I4.85 J-1.447 E.19058
G3 X89.514 Y113.675 I.143 J.044 E.00957
G2 X90.619 Y113.647 I.456 J-3.814 E.03679
G1 X90.72 Y113.748 E.00475
G2 X94.835 Y110.187 I-.735 J-5.008 E.19058
G1 X94.755 Y110.107 E.00376
G3 X94.055 Y111.569 I-6.678 J-2.3 E.05387
M204 S10000
G1 X97.479 Y105.155 F42000
G1 F8843.478
M204 S6000
G1 X99.442 Y107.118 E.09209
G3 X97.953 Y107.775 I-10.327 J-21.408 E.054
; WIPE_START
G1 X99.442 Y107.118 E-.6185
G1 X99.179 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X91.586 Y106.08 Z1.2 F42000
G1 X82.521 Y105.155 Z1.2
G1 Z.8
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X80.558 Y107.118 E.09209
G2 X82.047 Y107.775 I10.33 J-21.416 E.054
; WIPE_START
G1 X80.558 Y107.118 E-.6185
G1 X80.821 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X76.864 Y100.328 Z1.2 F42000
G1 X71.39 Y91.299 Z1.2
G1 Z.8
G1 E.8 F1800
G1 F8843.478
M204 S6000
G2 X71.766 Y92.882 I20.438 J-4.007 E.054
G1 X69.69 Y94.958 E.09735
G3 X68.849 Y91.876 I37.421 J-11.88 E.10598
G1 X72.919 Y95.947 E.19094
G2 X74.169 Y98.155 I18.238 J-8.863 E.08424
G1 X72.296 Y100.028 E.08787
G2 X75.932 Y104.068 I19.741 J-14.113 E.18067
G1 X77.777 Y102.223 E.08658
G2 X81.803 Y104.831 I13.716 J-16.758 E.15946
G1 X85.955 Y108.983 E.19477
G3 X86.366 Y108.986 I.195 J1.226 E.01368
G1 X88.157 Y107.195 E.08402
G2 X90.176 Y108.379 I2.076 J-1.226 E.08108
G2 X91.843 Y107.195 I-.547 J-2.537 E.06973
G1 X93.634 Y108.986 E.08402
G3 X94.045 Y108.983 I.215 J1.223 E.01368
G1 X98.197 Y104.831 E.19477
G2 X102.223 Y102.223 I-9.692 J-19.368 E.15945
G1 X104.068 Y104.068 E.08658
G2 X107.704 Y100.028 I-16.104 J-18.153 E.18067
G1 X105.831 Y98.155 E.08787
G2 X107.081 Y95.947 I-16.99 J-11.072 E.08424
G1 X111.151 Y91.876 E.19094
G3 X110.31 Y94.958 I-38.255 J-8.797 E.10598
G1 X108.234 Y92.882 E.09735
G2 X108.61 Y91.299 I-20.057 J-5.589 E.054
M204 S10000
G1 X111.53 Y86.877 F42000
G1 F8843.478
M204 S6000
G3 X111.533 Y88.505 I-16.638 J.843 E.05402
G1 X108.847 Y85.82 E.12599
G3 X108.898 Y86.454 I-6.446 J.832 E.02112
G1 X111.236 Y84.116 E.1097
G2 X109.676 Y78.972 I-23.891 J4.439 E.17866
G1 X98.778 Y68.074 E.51125
G2 X97.208 Y67.44 I-11.401 J25.994 E.05618
G1 X95.132 Y69.516 E.09735
G3 X100.405 Y71.919 I-5.168 J18.328 E.19297
G1 X102.278 Y70.046 E.08787
G3 X106.318 Y73.682 I-14.113 J19.74 E.18067
G1 X104.473 Y75.527 E.08658
G3 X107.405 Y80.271 I-14.577 J12.289 E.18566
G1 X109.368 Y78.308 E.09209
M204 S10000
G1 X92.379 Y66.335 F42000
G1 F8843.478
M204 S6000
G2 X90.755 Y66.217 I-2.512 J23.325 E.054
G1 X89.861 Y67.111 E.04195
G3 X90.143 Y67.115 I.126 J.977 E.00939
G1 X89.245 Y66.217 E.04213
G2 X87.622 Y66.335 I.856 J23.085 E.054
M204 S10000
G1 X88.249 Y68.841 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S6000
G1 X89.141 Y68.784 E.02748
G1 X89.451 Y68.669 E.01015
G1 X89.951 Y68.589 E.01558
M73 P42 R12
G1 X90.502 Y68.663 E.01706
G1 X90.879 Y68.781 E.01216
G1 X91.742 Y68.84 E.02657
G1 X91.357 Y68.315 E.02001
G1 X90.933 Y67.884 E.01857
G1 X90.461 Y67.595 E.017
G1 X90.129 Y67.517 E.01049
G1 X89.722 Y67.544 E.01252
G1 X89.322 Y67.713 E.01334
G1 X88.837 Y68.097 E.01901
G2 X88.283 Y68.792 I3.469 J3.335 E.02735
M204 S10000
G1 X89.009 Y68.44 F42000
; LINE_WIDTH: 0.383769
G1 F10561.881
M204 S6000
G3 X90.039 Y68.227 I1.525 J4.78 E.02927
G1 X90.557 Y68.295 E.01452
G1 X90.949 Y68.42 E.01143
G2 X90.291 Y67.924 I-1.477 J1.275 E.02307
G1 X89.99 Y67.878 E.00846
G1 X89.589 Y67.962 E.01137
G1 X89.048 Y68.394 E.01924
; WIPE_START
G1 X89.589 Y67.962 E-.26327
G1 X89.99 Y67.878 E-.1556
G1 X90.291 Y67.924 E-.11569
G1 X90.636 Y68.129 E-.15266
G1 X90.776 Y68.26 E-.07278
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X83.946 Y71.667 Z1.2 F42000
G1 X70.632 Y78.308 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X72.595 Y80.271 E.09209
G3 X75.527 Y75.527 I17.509 J7.545 E.18566
G1 X73.682 Y73.682 E.08658
G3 X77.722 Y70.046 I18.153 J16.105 E.18067
G1 X79.595 Y71.919 E.08787
G3 X84.868 Y69.516 I10.441 J15.925 E.19297
G1 X82.792 Y67.44 E.09735
G2 X81.222 Y68.074 I9.83 J26.627 E.05618
G1 X70.324 Y78.972 E.51125
G2 X68.764 Y84.116 I22.33 J9.583 E.17866
G1 X71.102 Y86.454 E.1097
G3 X71.153 Y85.82 I6.522 J.199 E.02112
G1 X68.467 Y88.505 E.12599
G3 X68.47 Y86.877 I16.64 J-.785 E.05402
; WIPE_START
G1 X68.467 Y88.505 E-.61858
G1 X68.73 Y88.242 E-.14143
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X74.641 Y83.413 Z1.2 F42000
G1 X89.767 Y71.056 Z1.2
G1 Z.8
G1 E.8 F1800
; FEATURE: Overhang wall
; LINE_WIDTH: 0.4
; LAYER_HEIGHT: 0.4
M106 S255
G1 F600
M204 S5000
G1 X89.766 Y70.801 E.01304
G1 X89.953 Y70.741 E.01004
G1 X90.231 Y70.803 E.01462
G1 X90.232 Y71.056 E.01294
M106 S201.45
; FEATURE: Inner wall
; LINE_WIDTH: 0.50755
; LAYER_HEIGHT: 0.2
G1 F690.618
M204 S6000
G1 X90.232 Y71.081 E.00098
; LINE_WIDTH: 0.50745
G1 F800.412
G1 X90.232 Y71.11 E.0011
; LINE_WIDTH: 0.50734
G1 F918.302
G1 X90.232 Y71.14 E.0011
; LINE_WIDTH: 0.50723
G1 F1044.289
G1 X90.232 Y71.169 E.0011
; LINE_WIDTH: 0.50711
G1 F1178.371
G1 X90.232 Y71.198 E.0011
; LINE_WIDTH: 0.507
G1 F1320.549
G1 X90.232 Y71.227 E.0011
; LINE_WIDTH: 0.50689
G1 F1470.823
G1 X90.232 Y71.256 E.0011
; LINE_WIDTH: 0.50678
G1 F1629.193
G1 X90.232 Y71.285 E.0011
; LINE_WIDTH: 0.50666
G1 F1857.941
G1 X90.247 Y71.321 E.00149
; LINE_WIDTH: 0.5022
G1 F2116.147
G1 X90.265 Y71.359 E.00157
; LINE_WIDTH: 0.49698
G1 F2391.086
G1 X90.283 Y71.397 E.00155
; LINE_WIDTH: 0.49176
G1 F2682.876
G1 X90.301 Y71.435 E.00153
; LINE_WIDTH: 0.48654
G1 F2991.36
G1 X90.318 Y71.473 E.00151
; LINE_WIDTH: 0.48132
G1 F3316.661
G1 X90.336 Y71.51 E.00149
; LINE_WIDTH: 0.4761
G1 F3658.824
G1 X90.354 Y71.548 E.00148
; LINE_WIDTH: 0.47088
G1 F4017.702
G1 X90.372 Y71.586 E.00146
; LINE_WIDTH: 0.46566
G1 F4393.45
G1 X90.39 Y71.624 E.00144
; LINE_WIDTH: 0.46044
G1 F4785.905
G1 X90.408 Y71.662 E.00142
; LINE_WIDTH: 0.45522
G1 F5195.237
G1 X90.425 Y71.699 E.00141
; LINE_WIDTH: 0.44999
G1 F8234.347
G1 X90.653 Y71.843 E.00894
G1 F8843.689
G1 X91.051 Y71.884 E.01327
G1 X91.957 Y71.987 E.03025
G3 X92.72 Y72.092 I-5.062 J39.832 E.02555
G3 X105.888 Y88.142 I-2.734 J15.67 E.75027
G3 X91.558 Y103.572 I-15.891 J-.389 E.76348
G1 X90.697 Y103.644 E.02866
G1 X90.425 Y103.801 E.0104
; LINE_WIDTH: 0.45528
G1 F8730.235
G1 X90.407 Y103.838 E.00141
; LINE_WIDTH: 0.46058
G1 F8619.451
G1 X90.389 Y103.876 E.00143
; LINE_WIDTH: 0.46588
G1 F8511.444
G1 X90.371 Y103.914 E.00145
; LINE_WIDTH: 0.47118
G1 F8406.108
G1 X90.353 Y103.952 E.00147
; LINE_WIDTH: 0.47648
G1 F8303.349
G1 X90.335 Y103.99 E.00149
; LINE_WIDTH: 0.48178
G1 F8203.072
G1 X90.317 Y104.028 E.0015
; LINE_WIDTH: 0.48708
G1 F8105.187
G1 X90.299 Y104.066 E.00152
; LINE_WIDTH: 0.49238
G1 F8009.611
G1 X90.281 Y104.104 E.00154
; LINE_WIDTH: 0.49768
G1 F7916.263
G1 X90.262 Y104.142 E.00156
; LINE_WIDTH: 0.50298
G1 F7825.067
G1 X90.244 Y104.18 E.00158
; LINE_WIDTH: 0.50663
G1 F7763.473
G2 X90.232 Y104.215 I.03 J.03 E.00146
G1 X90.232 Y104.244 E.0011
G1 X90.232 Y104.273 E.0011
; LINE_WIDTH: 0.50662
G1 X90.232 Y104.302 E.0011
; LINE_WIDTH: 0.50661
G1 X90.232 Y104.331 E.0011
; LINE_WIDTH: 0.5066
G1 X90.233 Y104.36 E.00109
G1 X90.233 Y104.389 E.0011
; LINE_WIDTH: 0.50659
G1 F7764.142
G1 X90.233 Y104.418 E.00109
; LINE_WIDTH: 0.50658
G1 F692.003
G1 X90.233 Y104.444 E.00099
; FEATURE: Overhang wall
; LINE_WIDTH: 0.4
; LAYER_HEIGHT: 0.4
M106 S255
G1 F600
M204 S5000
G1 X90.234 Y104.699 E.01304
G1 X90.036 Y104.762 E.01063
G1 X89.769 Y104.696 E.0141
G1 X89.768 Y104.444 E.0129
M106 S201.45
; FEATURE: Inner wall
; LINE_WIDTH: 0.50656
; LAYER_HEIGHT: 0.2
G1 F691.966
M204 S6000
G1 X89.768 Y104.418 E.00099
; LINE_WIDTH: 0.50657
G1 F801.667
G1 X89.768 Y104.389 E.0011
; LINE_WIDTH: 0.50658
G1 F919.436
G1 X89.768 Y104.36 E.0011
; LINE_WIDTH: 0.50659
G1 F1045.274
G1 X89.768 Y104.331 E.0011
; LINE_WIDTH: 0.5066
G1 F1179.18
G1 X89.768 Y104.302 E.0011
; LINE_WIDTH: 0.50661
G1 F1321.103
G1 X89.768 Y104.273 E.0011
; LINE_WIDTH: 0.50662
G1 F1471.142
G1 X89.768 Y104.244 E.0011
G1 F1629.249
G1 X89.768 Y104.215 E.0011
; LINE_WIDTH: 0.50663
G1 F1857.946
G1 X89.753 Y104.179 E.00149
; LINE_WIDTH: 0.50219
G1 F2116.152
G1 X89.735 Y104.141 E.00157
; LINE_WIDTH: 0.49697
G1 F2391.091
G1 X89.717 Y104.103 E.00155
; LINE_WIDTH: 0.49175
G1 F2682.817
G1 X89.699 Y104.065 E.00153
; LINE_WIDTH: 0.48653
G1 F2991.398
G1 X89.682 Y104.027 E.00151
; LINE_WIDTH: 0.48131
G1 F3316.667
G1 X89.664 Y103.99 E.00149
; LINE_WIDTH: 0.47609
G1 F3658.755
G1 X89.646 Y103.952 E.00148
; LINE_WIDTH: 0.47087
G1 F4017.709
G1 X89.628 Y103.914 E.00146
; LINE_WIDTH: 0.46565
G1 F4393.374
G1 X89.61 Y103.876 E.00144
; LINE_WIDTH: 0.46043
G1 F4785.825
G1 X89.592 Y103.838 E.00142
; LINE_WIDTH: 0.45521
G1 F5195.154
G1 X89.575 Y103.801 E.00141
; LINE_WIDTH: 0.44999
G1 F7234.368
G1 X89.424 Y103.689 E.00621
G1 F8843.689
G1 X89.209 Y103.628 E.00743
G3 X88.442 Y71.928 I.797 J-15.878 E1.57837
G1 X89.303 Y71.856 E.02866
G1 X89.575 Y71.699 E.0104
; LINE_WIDTH: 0.45673
G1 F8699.644
G1 X89.596 Y71.66 E.00153
; LINE_WIDTH: 0.46347
G1 F8560.219
G1 X89.618 Y71.62 E.00155
; LINE_WIDTH: 0.47022
G1 F8424.995
G1 X89.64 Y71.58 E.00158
; LINE_WIDTH: 0.47696
G1 F8294.166
G1 X89.661 Y71.541 E.0016
; LINE_WIDTH: 0.4837
G1 F8167.34
G1 X89.683 Y71.501 E.00163
; LINE_WIDTH: 0.49045
G1 F8044.153
G1 X89.705 Y71.461 E.00165
; LINE_WIDTH: 0.49719
G1 F7924.803
G1 X89.727 Y71.421 E.00168
; LINE_WIDTH: 0.50394
G1 F7808.772
G1 X89.748 Y71.382 E.0017
; LINE_WIDTH: 0.50984
G1 F7710.1
G1 X89.767 Y71.343 E.00163
; LINE_WIDTH: 0.50982
G1 X89.767 Y71.314 E.00111
; LINE_WIDTH: 0.50958
G1 F7714.396
G1 X89.767 Y71.285 E.00111
; LINE_WIDTH: 0.50935
G1 F7718.2
G1 X89.767 Y71.256 E.00111
; LINE_WIDTH: 0.50911
G1 F7722.174
G1 X89.767 Y71.227 E.00111
; LINE_WIDTH: 0.50888
G1 F7725.985
G1 X89.767 Y71.198 E.0011
; LINE_WIDTH: 0.50864
G1 F7729.967
G1 X89.767 Y71.169 E.0011
; LINE_WIDTH: 0.50841
G1 F7733.787
G1 X89.767 Y71.14 E.0011
; LINE_WIDTH: 0.50817
G1 F7737.775
G1 X89.767 Y71.116 E.00091
M204 S250
G1 X89.314 Y71.378 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F2164.057
M204 S5000
G1 X89.321 Y71.36 E.00058
G1 F2044.976
G1 X89.328 Y71.343 E.00058
G1 F1929.186
G1 X89.335 Y71.325 E.00058
G1 F1816.792
G1 X89.342 Y71.308 E.00058
G1 F1707.824
G1 X89.348 Y71.289 E.0006
G1 F1597.766
G1 X89.348 Y71.265 E.00076
G1 F1463.25
G1 X89.347 Y71.24 E.00076
G1 F1334.649
G1 X89.347 Y71.215 E.00076
G1 F1211.962
G1 X89.347 Y71.19 E.00076
G1 F1095.188
G1 X89.347 Y71.165 E.00076
G1 F984.329
G1 X89.347 Y71.141 E.00076
G1 F879.384
G1 X89.347 Y71.116 E.00076
G1 F780.354
G1 X89.347 Y71.091 E.00076
G1 F687.237
G1 X89.346 Y71.066 E.00076
; FEATURE: Overhang wall
; LINE_WIDTH: 0.4
; LAYER_HEIGHT: 0.4
M106 S255
G1 F600
G1 X89.344 Y70.564 E.0257
G1 X89.573 Y70.426 E.01374
G1 X89.926 Y70.313 E.01893
G1 X90.205 Y70.35 E.01441
G1 X90.619 Y70.529 E.02311
G1 X90.652 Y70.584 E.00329
G1 X90.653 Y71.066 E.02467
M106 S201.45
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
; LAYER_HEIGHT: 0.2
G1 F686.872
G1 X90.653 Y71.091 E.00076
G1 F779.654
G1 X90.653 Y71.116 E.00076
G1 F878.311
G1 X90.653 Y71.14 E.00076
G1 F982.801
G1 X90.653 Y71.165 E.00076
G1 F1093.208
G1 X90.653 Y71.19 E.00076
G1 F1209.491
G1 X90.653 Y71.214 E.00076
G1 F1331.599
G1 X90.653 Y71.239 E.00076
G1 F1459.632
G1 X90.653 Y71.264 E.00076
G1 F1593.54
G1 X90.653 Y71.289 E.00076
G1 F1726.164
G1 X90.654 Y71.312 E.00072
G1 F1831.46
G1 X90.664 Y71.327 E.00055
G1 F1939.823
G1 X90.674 Y71.342 E.00055
G1 F2051.353
G1 X90.684 Y71.357 E.00055
G1 F2165.945
G1 X90.695 Y71.372 E.00055
G1 F2283.708
G1 X90.705 Y71.387 E.00055
G1 F2404.531
G1 X90.715 Y71.402 E.00055
G1 F2528.526
G1 X90.725 Y71.417 E.00055
G1 F2655.579
G1 X90.735 Y71.432 E.00055
G1 F2785.807
G1 X90.745 Y71.447 E.00055
G1 F2919.194
G1 X90.755 Y71.462 E.00055
G1 F6681.816
G1 X91.153 Y71.502 E.01229
G1 F9547.299
G1 X91.551 Y71.543 E.01229
G1 X92.006 Y71.598 E.01408
G3 X92.787 Y71.705 I-4.594 J36.317 E.02424
G3 X106.28 Y88.151 I-2.802 J16.057 E.71213
G3 X91.596 Y103.962 I-16.284 J-.399 E.72465
G1 X91.153 Y104.002 E.01368
G1 F6654.66
G1 X90.755 Y104.038 E.01229
G1 F2901.253
G1 X90.745 Y104.054 E.00056
G1 F2767.27
G1 X90.736 Y104.069 E.00056
G1 F2636.416
G1 X90.726 Y104.085 E.00056
G1 F2508.732
G1 X90.717 Y104.1 E.00056
G1 F2384.217
G1 X90.707 Y104.116 E.00056
G1 F2262.871
G1 X90.698 Y104.131 E.00056
G1 F2144.728
G1 X90.689 Y104.147 E.00056
G1 F2029.719
G1 X90.679 Y104.162 E.00056
G1 F1917.88
G1 X90.67 Y104.178 E.00056
G1 F1809.159
G1 X90.66 Y104.193 E.00056
G1 F1703.66
G1 X90.652 Y104.211 E.00058
G1 F1597.765
G1 X90.652 Y104.235 E.00076
G1 F1463.25
G1 X90.653 Y104.26 E.00076
G1 F1334.649
G1 X90.653 Y104.285 E.00076
G1 F1211.961
G1 X90.653 Y104.31 E.00076
G1 F1095.188
G1 X90.653 Y104.335 E.00076
G1 F984.329
G1 X90.653 Y104.359 E.00076
G1 F879.384
G1 X90.653 Y104.384 E.00076
G1 F780.353
G1 X90.653 Y104.409 E.00076
G1 F687.237
G1 X90.654 Y104.434 E.00076
; FEATURE: Overhang wall
; LINE_WIDTH: 0.4
; LAYER_HEIGHT: 0.4
M106 S255
G1 F600
G1 X90.656 Y104.936 E.0257
G1 X90.426 Y105.074 E.01375
G1 X90.072 Y105.187 E.01904
G1 X89.702 Y105.125 E.01924
G1 X89.348 Y104.935 E.02057
G1 X89.348 Y104.434 E.02567
M106 S201.45
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
; LAYER_HEIGHT: 0.2
G1 F687.308
G1 X89.348 Y104.409 E.00076
G1 F780.544
G1 X89.348 Y104.384 E.00076
G1 F879.708
G1 X89.348 Y104.359 E.00076
G1 F984.844
G1 X89.348 Y104.335 E.00076
G1 F1095.867
G1 X89.348 Y104.31 E.00076
G1 F1212.818
G1 X89.348 Y104.285 E.00076
G1 F1335.698
G1 X89.348 Y104.26 E.00076
G1 F1464.559
G1 X89.348 Y104.235 E.00076
G1 F1598.137
G1 X89.348 Y104.211 E.00076
G1 F1704.123
G1 X89.341 Y104.193 E.00058
G1 F1813.489
G1 X89.334 Y104.175 E.00058
G1 F1926.222
G1 X89.327 Y104.158 E.00058
G1 F2042.413
G1 X89.32 Y104.14 E.00058
G1 F2162.005
G1 X89.313 Y104.123 E.00058
G1 F2284.915
G1 X89.306 Y104.105 E.00058
G1 F2411.31
G1 X89.299 Y104.088 E.00058
G1 F2564.583
G1 X89.286 Y104.07 E.00068
G1 F2850.685
G1 X89.25 Y104.053 E.00122
G1 F3151.843
G1 X89.214 Y104.036 E.00122
G1 F3468.193
G1 X89.178 Y104.019 E.00122
G1 F7500.284
G1 X88.78 Y103.989 E.01229
G1 F9547.299
G1 X88.404 Y103.961 E.01158
G3 X89.173 Y71.482 I1.596 J-16.211 E1.49786
G1 X89.21 Y71.464 E.00127
G1 X89.248 Y71.447 E.00127
G1 X89.285 Y71.43 E.00127
; WIPE_START
M204 S6000
G1 X89.321 Y71.36 E-.02964
G1 X89.328 Y71.343 E-.00712
G1 X89.335 Y71.325 E-.00712
G1 X89.342 Y71.308 E-.00712
G1 X89.348 Y71.289 E-.00743
G1 X89.348 Y71.265 E-.00943
G1 X89.347 Y71.24 E-.00943
G1 X89.347 Y71.215 E-.00943
G1 X89.347 Y71.19 E-.00943
G1 X89.347 Y71.165 E-.00943
G1 X89.347 Y71.141 E-.00943
G1 X89.347 Y71.116 E-.00943
G1 X89.347 Y71.091 E-.00943
G1 X89.346 Y71.066 E-.00944
G1 X89.344 Y70.564 E-.19075
G1 X89.573 Y70.426 E-.10196
G1 X89.926 Y70.313 E-.14046
G1 X90.205 Y70.35 E-.10696
G1 X90.39 Y70.43 E-.07655
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X95.291 Y73.128 Z1.2 F42000
G1 Z.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X96.79 Y73.762 I-6.113 J16.534 E.05401
G1 X103.988 Y80.96 E.33768
G3 X104.772 Y82.904 I-25.141 J11.278 E.06953
G1 X85.154 Y102.522 E.92036
G2 X87.79 Y103.142 I4.945 J-15.127 E.08995
G1 X74.608 Y89.96 E.61839
G1 X74.617 Y90.031 E.00238
G1 X92.281 Y72.367 E.82866
G3 X90.416 Y72.119 I.931 J-14.146 E.06245
G3 X90.118 Y71.848 I.169 J-.486 E.01375
G3 X89.882 Y71.848 I-.118 J-.446 E.00791
G3 X89.269 Y72.214 I-.874 J-.766 E.02409
G2 X87.719 Y72.367 I.754 J15.583 E.05169
G1 X105.383 Y90.031 E.82866
G1 X105.392 Y89.96 E.00238
G1 X92.21 Y103.142 E.61839
G2 X94.846 Y102.522 I-2.309 J-15.747 E.08995
G1 X75.228 Y82.904 E.92036
G3 X76.012 Y80.96 I25.929 J9.336 E.06953
G1 X83.21 Y73.762 E.33768
G3 X84.709 Y73.128 I7.612 J15.901 E.05401
M204 S10000
G1 X79.029 Y76.73 F42000
G1 F8843.478
M204 S6000
G2 X77.937 Y77.937 I65.769 J60.548 E.05399
G1 X99.813 Y99.813 E1.02624
G2 X103.369 Y95.693 I-9.977 J-12.208 E.18144
G1 X82.057 Y74.381 E.99981
G2 X80.703 Y75.284 I48.043 J73.446 E.05399
M204 S10000
G1 X81.503 Y100.771 F42000
G1 F8843.478
M204 S6000
G3 X80.187 Y99.813 I9.602 J-14.564 E.05401
G1 X102.063 Y77.937 E1.02624
G2 X97.943 Y74.381 I-12.208 J9.977 E.18144
G1 X76.631 Y95.693 E.99981
G3 X75.876 Y94.251 I15.176 J-8.867 E.05401
; CHANGE_LAYER
; Z_HEIGHT: 1
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X76.631 Y95.693 E-.61845
G1 X76.894 Y95.43 E-.14155
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 5/25
; update layer progress
M73 L5
M991 S0 P4 ;notify layer change
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z1.2 I-1.067 J.585 P1  F42000
G1 X84.285 Y108.899 Z1.2
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X111.897 Y87.79 I5.787 J-21.115 E3.22945
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49733
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.111 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.891 J-21.493 E3.04525
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.118 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25112
G1 X82.491 Y108.737 E-.41561
G1 X82.262 Y108.649 E-.09327
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z1.4 F42000
G1 X94.196 Y109.433 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.85 J-.924 E.03357
G1 X93.721 Y111.457 E.02248
G1 X93.397 Y111.841 E.01667
G1 X92.776 Y112.419 E.02814
G1 X92.353 Y112.695 E.01673
G1 X91.59 Y113.067 E.02817
G1 X91.107 Y113.207 E.01669
G1 X90.268 Y113.343 E.02819
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.0282
G3 X88.199 Y112.984 I2.843 J-9.838 E.02528
G3 X87.256 Y112.433 I1.582 J-3.79 E.03635
G1 X86.619 Y111.871 E.02817
G1 X86.305 Y111.478 E.01667
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.129 J-2.313 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X93.76 Y109.316 I3.838 J-21.891 E.2543
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.0243
G3 X88.376 Y112.634 I-3.393 J-2.507 E.17223
G3 X86.201 Y110.562 I1.751 J-4.016 E.09421
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.787 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.09 E.23768
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05566
G1 X94.037 Y109.947 E-.06473
G1 X93.789 Y110.564 E-.25268
G1 X93.389 Y111.247 E-.30055
G1 X93.241 Y111.419 E-.08638
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.994 Y106.884 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X89.99 Y106.884 E.00014
G1 X89.481 Y106.794 E.01715
G1 X89 Y106.542 E.01801
G1 X88.712 Y106.302 E.01245
G3 X77.518 Y101.543 I1.273 J-18.536 E.41105
G3 X88.712 Y69.198 I12.481 J-13.79 E1.44165
G1 X89.053 Y68.926 E.01448
G1 X89.56 Y68.684 E.01863
G1 X90.014 Y68.616 E.01523
G1 X90.519 Y68.706 E.01701
G1 X91 Y68.958 E.01802
G1 X91.288 Y69.198 E.01244
G3 X96.28 Y105.26 I-1.288 J18.555 E1.68298
G3 X91.837 Y106.261 I-6.604 J-18.958 E.15141
G1 X91.288 Y106.302 E.01827
G1 X90.947 Y106.574 E.01447
G1 X90.44 Y106.816 E.01863
G1 X90.054 Y106.874 E.01296
M204 S250
G1 X89.972 Y106.49 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.586 Y106.413 E.0121
G3 X88.868 Y105.92 I.816 J-1.958 E.02694
G3 X77.774 Y101.246 I1.12 J-18.159 E.37701
G3 X88.868 Y69.58 I12.225 J-13.493 E1.31098
G1 X89.237 Y69.272 E.01475
G1 X89.642 Y69.068 E.01394
G1 X90.033 Y69.011 E.01214
G1 X90.414 Y69.087 E.01195
G3 X91.132 Y69.58 I-.817 J1.958 E.02693
G3 X96.139 Y104.894 I-1.132 J18.173 E1.5304
G3 X91.789 Y105.871 I-6.463 J-18.594 E.13729
G1 X91.132 Y105.92 E.02026
G1 X90.763 Y106.228 E.01474
G1 X90.359 Y106.432 E.01392
G1 X90.032 Y106.481 E.01017
; WIPE_START
M204 S6000
G1 X89.586 Y106.413 E-.17126
G1 X89.203 Y106.205 E-.1656
G1 X88.868 Y105.92 E-.16698
G1 X88.215 Y105.872 E-.24884
G1 X88.196 Y105.87 E-.00733
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.4 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z1.4
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z1.4 F4000
            G39.3 S1
            G0 Z1.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X91.909 Y106.639 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Floating vertical shell
G1 F9547.299
M204 S6000
M73 P42 R11
G3 X91.295 Y107.513 I-7.314 J-4.48 E.03284
; Slow Down Start
G1 F1200;_EXTRUDE_SET_SPEED
G1 X91.003 Y107.85 E.01371
G1 X90.563 Y108.198 E.01723
G1 X90.266 Y108.332 E.01
G1 X89.854 Y108.35 E.01267
G1 X89.361 Y108.169 E.01616
G1 X88.919 Y107.78 E.01809
G1 X88.737 Y107.547 E.00907
; Slow Down End
G1 F9547.299
M73 P43 R11
G3 X88.096 Y106.639 I4.817 J-4.084 E.03418
G1 X88.555 Y106.682 E.01418
G1 X88.799 Y106.878 E.0096
G1 X89.381 Y107.172 E.02004
G1 X90.035 Y107.274 E.02033
G1 X90.552 Y107.183 E.01611
G1 X91.049 Y106.958 E.01677
G1 X91.445 Y106.682 E.01482
G1 X91.849 Y106.644 E.01248
M204 S10000
G1 X90.843 Y107.477 F42000
; LINE_WIDTH: 0.394029
G1 F10253.238
M204 S6000
G1 X90.229 Y107.609 E.01796
G1 X89.909 Y107.632 E.0092
G3 X89.151 Y107.485 I.402 J-4.081 E.02213
G1 X89.539 Y107.841 E.01508
G1 X89.924 Y107.991 E.01183
G1 X90.203 Y107.966 E.008
G1 X90.352 Y107.902 E.00464
G1 X90.728 Y107.612 E.0136
G1 X90.804 Y107.523 E.00335
; WIPE_START
G1 X90.728 Y107.612 E-.04455
G1 X90.352 Y107.902 E-.18057
G1 X90.203 Y107.966 E-.06161
G1 X89.924 Y107.991 E-.10624
G1 X89.539 Y107.841 E-.1571
G1 X89.151 Y107.485 E-.20028
G1 X89.175 Y107.491 E-.00964
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X94.055 Y111.569 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X94.755 Y110.107 I-5.978 J-3.761 E.05387
G1 X94.835 Y110.187 E.00376
G3 X90.72 Y113.748 I-4.85 J-1.447 E.19058
G1 X90.619 Y113.647 E.00475
G3 X89.378 Y113.65 I-.635 J-5.584 E.04126
G1 X89.28 Y113.748 E.0046
G3 X85.165 Y110.187 I.735 J-5.008 E.19058
G1 X85.245 Y110.107 E.00377
G2 X85.941 Y111.57 I3.453 J-.746 E.05424
; WIPE_START
G1 X85.511 Y110.83 E-.32559
G1 X85.245 Y110.107 E-.29254
G1 X85.165 Y110.187 E-.04316
G1 X85.255 Y110.431 E-.09871
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X82.047 Y107.775 Z1.4 F42000
G1 Z1
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X80.558 Y107.118 I8.841 J-22.072 E.054
G1 X82.521 Y105.155 E.09209
; WIPE_START
G1 X81.107 Y106.569 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.72 Y107.114 Z1.4 F42000
G1 X97.953 Y107.775 Z1.4
G1 Z1
G1 E.8 F1800
G1 F8843.478
M204 S6000
G2 X99.442 Y107.118 I-8.838 J-22.065 E.054
G1 X97.479 Y105.155 E.09209
; WIPE_START
G1 X98.893 Y106.569 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.991 Y100.13 Z1.4 F42000
G1 X108.61 Y91.299 Z1.4
G1 Z1
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X108.234 Y92.882 I-20.432 J-4.006 E.054
G1 X110.31 Y94.958 E.09735
G2 X111.151 Y91.876 I-37.413 J-11.878 E.10598
G1 X107.081 Y95.947 E.19094
G3 X105.831 Y98.155 I-18.24 J-8.864 E.08424
G1 X107.704 Y100.028 E.08787
G3 X104.068 Y104.068 I-19.74 J-14.113 E.18067
G1 X102.223 Y102.223 E.08658
G3 X98.198 Y104.83 I-13.661 J-16.679 E.15939
G1 X94.045 Y108.983 E.19484
G2 X93.634 Y108.986 I-.195 J1.226 E.01368
G1 X91.945 Y107.297 E.07924
G3 X90.347 Y108.717 I-2.674 J-1.4 E.07249
G3 X88.627 Y108.042 I-.276 J-1.825 E.0642
G3 X88.055 Y107.297 I4.14 J-3.768 E.0312
G1 X86.366 Y108.986 E.07926
G2 X85.955 Y108.983 I-.215 J1.223 E.01368
G1 X81.802 Y104.83 E.19484
G3 X77.777 Y102.223 I9.635 J-19.284 E.15939
G1 X75.932 Y104.068 E.08658
G3 X72.296 Y100.028 I16.105 J-18.153 E.18067
G1 X74.169 Y98.155 E.08787
G3 X72.919 Y95.947 I16.988 J-11.071 E.08424
G1 X68.849 Y91.876 E.19094
G2 X69.69 Y94.958 I38.263 J-8.799 E.10598
G1 X71.766 Y92.882 E.09735
G3 X71.39 Y91.299 I20.063 J-5.591 E.054
M204 S10000
G1 X68.47 Y86.877 F42000
G1 F8843.478
M204 S6000
G2 X68.467 Y88.505 I16.638 J.843 E.05402
G1 X71.153 Y85.82 E.12599
G2 X71.102 Y86.454 I6.471 J.834 E.02112
G1 X68.764 Y84.116 E.1097
G3 X70.324 Y78.972 I23.89 J4.439 E.17866
G1 X81.222 Y68.074 E.51125
G3 X82.792 Y67.44 I11.401 J25.993 E.05618
G1 X84.868 Y69.516 E.09735
G2 X79.595 Y71.919 I5.165 J18.32 E.19297
G1 X77.722 Y70.046 E.08787
G2 X73.682 Y73.682 I14.114 J19.741 E.18067
G1 X75.527 Y75.527 E.08658
G2 X72.595 Y80.271 I14.576 J12.289 E.18566
G1 X70.632 Y78.308 E.09209
; WIPE_START
G1 X72.046 Y79.722 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X78.654 Y75.902 Z1.4 F42000
G1 X91.614 Y68.409 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S6000
G1 X91.906 Y68.861 E.01653
G1 X91.445 Y68.818 E.01422
G1 X91.201 Y68.622 E.00959
G1 X90.674 Y68.347 E.01828
G2 X89.948 Y68.227 I-1.33 J5.784 E.02263
G1 X89.38 Y68.328 E.01772
G2 X88.555 Y68.818 I1.275 J3.09 E.02957
G1 X88.091 Y68.861 E.01432
G3 X88.833 Y67.84 I6.337 J3.823 E.03882
; Slow Down Start
G1 F1200;_EXTRUDE_SET_SPEED
G1 X89.043 Y67.6 E.00979
G1 X89.444 Y67.29 E.0156
G1 X89.887 Y67.153 E.01425
G1 X90.168 Y67.157 E.00862
G1 X90.635 Y67.34 E.01543
G1 X90.844 Y67.486 E.00782
G1 X91.321 Y68.008 E.02172
; Slow Down End
G1 F9547.299
G1 X91.579 Y68.36 E.01342
M204 S10000
G1 X90.844 Y68.021 F42000
; LINE_WIDTH: 0.390027
G1 F10371.457
M204 S6000
G1 X90.483 Y67.671 E.01422
G1 X90.092 Y67.514 E.01191
G1 X89.723 Y67.556 E.01049
G1 X89.563 Y67.636 E.00508
G1 X89.111 Y68.054 E.0174
G1 X89.317 Y67.975 E.00624
G1 X89.884 Y67.872 E.01631
G1 X90.083 Y67.868 E.00562
G1 X90.678 Y67.968 E.01708
G1 X90.787 Y68.003 E.00322
M204 S10000
G1 X92.379 Y66.335 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X90.755 Y66.217 I-2.512 J23.324 E.054
G1 X90.208 Y66.764 E.02566
G2 X89.788 Y66.76 I-.22 J1.08 E.01403
G1 X89.245 Y66.217 E.02547
G2 X87.622 Y66.335 I.86 J23.13 E.054
; WIPE_START
G1 X89.245 Y66.217 E-.61849
G1 X89.508 Y66.481 E-.14152
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.066 Y70.386 Z1.4 F42000
G1 X109.368 Y78.308 Z1.4
G1 Z1
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X107.405 Y80.271 E.09209
G2 X104.473 Y75.527 I-17.509 J7.545 E.18566
G1 X106.318 Y73.682 E.08658
G2 X102.278 Y70.046 I-18.153 J16.104 E.18067
G1 X100.405 Y71.919 E.08787
G2 X95.132 Y69.516 I-10.44 J15.921 E.19297
G1 X97.208 Y67.44 E.09735
G3 X98.778 Y68.074 I-9.831 J26.628 E.05618
G1 X109.676 Y78.972 E.51125
G3 X111.236 Y84.116 I-22.33 J9.583 E.17866
G1 X108.898 Y86.454 E.1097
G2 X108.847 Y85.82 I-6.497 J.197 E.02112
G1 X111.533 Y88.505 E.12599
G2 X111.53 Y86.877 I-16.64 J-.785 E.05402
; WIPE_START
G1 X111.533 Y88.505 E-.61858
G1 X111.27 Y88.242 E-.14143
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.108 Y83.738 Z1.4 F42000
G1 X88.893 Y71.885 Z1.4
G1 Z1
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X89.081 Y71.839 E.00641
G1 X89.305 Y71.642 E.00988
G1 X89.404 Y71.318 E.01123
G1 X89.403 Y70.714 E.02004
G1 X89.709 Y70.473 E.01289
G1 X90 Y70.355 E.01043
G1 X90.291 Y70.474 E.01044
G1 X90.597 Y70.714 E.01289
G1 X90.596 Y71.318 E.02005
G1 X90.695 Y71.642 E.01123
G1 X90.83 Y71.784 E.00651
G1 X91.106 Y71.895 E.00983
G3 X105.888 Y88.142 I-1.12 J15.868 E.80424
G3 X91.168 Y103.6 I-15.902 J-.405 E.77617
G1 X90.919 Y103.661 E.00851
G1 X90.695 Y103.858 E.00988
G1 X90.596 Y104.182 E.01123
G1 X90.597 Y104.786 E.02004
G3 X89.999 Y105.145 I-.912 J-.84 E.02343
G1 X89.709 Y105.027 E.01039
G1 X89.403 Y104.786 E.01292
G1 X89.404 Y104.182 E.02004
G1 X89.305 Y103.858 E.01123
G1 X89.17 Y103.716 E.00651
G1 X88.894 Y103.605 E.00983
G3 X88.832 Y71.9 I1.112 J-15.855 E1.58043
G1 X88.835 Y71.899 E.00011
M204 S250
G1 X88.803 Y71.509 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X88.937 Y71.467 E.0043
G1 X88.945 Y71.451 E.00056
G1 X88.953 Y71.435 E.00056
G1 X88.961 Y71.419 E.00056
G1 X88.969 Y71.403 E.00056
G1 X88.977 Y71.386 E.00055
G1 X88.985 Y71.37 E.00056
G1 X88.994 Y71.354 E.00056
G1 X89.002 Y71.338 E.00056
G1 X89.01 Y71.322 E.00056
G2 X89.012 Y71.234 I-.087 J-.046 E.00281
G1 F8541.478
G1 X89.011 Y71.125 E.00334
G1 F7206.404
G1 X89.011 Y71.016 E.00334
G1 F5984.72
G1 X89.011 Y70.908 E.00334
G1 F4876.424
G1 X89.011 Y70.799 E.00334
G1 F3881.518
G1 X89.011 Y70.69 E.00334
G1 F3000
G1 X89.011 Y70.582 E.00334
G3 X89.041 Y70.515 I.045 J-.02 E.00252
G1 X89.12 Y70.442 E.00331
G1 X89.199 Y70.369 E.00331
G1 X89.279 Y70.296 E.00331
G1 F2403.413
G1 X89.316 Y70.269 E.00141
G1 F2101.574
G1 X89.447 Y70.188 E.00473
G1 F1236.86
G1 X89.578 Y70.107 E.00473
M106 S255
G1 F600
G1 X89.709 Y70.026 E.00473
M106 S201.45
M106 S255
G1 X89.753 Y70 E.00157
G3 X90.287 Y70.022 I.233 J.824 E.0167
M106 S201.45
M106 S255
G1 X90.405 Y70.088 E.00416
M106 S201.45
G1 F1146.874
G1 X90.523 Y70.154 E.00416
G1 F1521.024
G3 X90.582 Y70.197 I-.082 J.176 E.00229
G1 F2978.392
G1 X90.754 Y70.343 E.00691
G1 F3000
G1 X90.926 Y70.488 E.00691
G1 X90.989 Y70.542 E.00255
G1 X90.989 Y70.582 E.00123
G1 X90.989 Y70.69 E.00334
G1 F3881.604
G1 X90.989 Y70.799 E.00334
G1 F4876.618
G1 X90.989 Y70.908 E.00334
G1 F5985.149
G1 X90.989 Y71.016 E.00334
G1 F7206.992
G1 X90.989 Y71.125 E.00334
G1 F8542.246
G1 X90.989 Y71.234 E.00334
G1 F9547.299
G2 X90.99 Y71.323 I.147 J.042 E.00277
G1 X90.996 Y71.342 E.00063
G1 X91.002 Y71.362 E.00063
G1 X91.008 Y71.382 E.00063
G1 X91.014 Y71.402 E.00063
G1 X91.02 Y71.421 E.00063
G1 X91.044 Y71.438 E.00092
G1 X91.071 Y71.455 E.00097
G1 X91.098 Y71.472 E.00097
G1 X91.125 Y71.488 E.00097
G1 X91.152 Y71.505 E.00097
G3 X106.28 Y88.151 I-1.166 J16.257 E.76276
G3 X91.197 Y103.991 I-16.295 J-.415 E.73671
G1 X91.063 Y104.033 E.0043
G1 X91.055 Y104.049 E.00056
G1 X91.047 Y104.065 E.00056
G1 X91.039 Y104.081 E.00056
G1 X91.031 Y104.097 E.00056
G1 X91.023 Y104.114 E.00055
G1 X91.015 Y104.13 E.00056
G1 X91.006 Y104.146 E.00056
G1 X90.998 Y104.162 E.00056
G1 X90.99 Y104.178 E.00056
G2 X90.989 Y104.266 I.087 J.046 E.00281
G1 F8541.862
G1 X90.989 Y104.375 E.00334
G1 F7206.757
G1 X90.989 Y104.484 E.00334
G1 F5984.934
G1 X90.989 Y104.592 E.00334
G1 F4876.521
G1 X90.989 Y104.701 E.00334
G1 F3881.604
G1 X90.989 Y104.81 E.00334
G1 F3000
G1 X90.989 Y104.918 E.00334
G3 X90.96 Y104.985 I-.045 J.02 E.00251
G1 X90.881 Y105.058 E.00329
G1 X90.802 Y105.13 E.00329
G1 X90.723 Y105.202 E.00329
G1 F2416.859
G3 X90.685 Y105.23 I-.092 J-.086 E.00147
G1 F2104.589
G1 X90.554 Y105.311 E.00474
G1 F1238.017
G1 X90.422 Y105.392 E.00474
M106 S255
G1 F600
G1 X90.291 Y105.474 E.00474
M106 S201.45
M106 S255
G1 X90.247 Y105.5 E.00157
G3 X89.715 Y105.479 I-.234 J-.812 E.01667
M106 S201.45
M106 S255
G1 X89.597 Y105.413 E.00415
M106 S201.45
G1 F1146.082
G1 X89.479 Y105.347 E.00415
G1 F1495.204
G3 X89.423 Y105.306 I.077 J-.164 E.00215
G1 F1556.941
G1 X89.249 Y105.159 E.00699
M106 S255
G1 F600
G1 X89.075 Y105.013 E.00699
M106 S201.45
M106 S255
G1 X89.011 Y104.958 E.00258
G2 X89.01 Y104.493 I-3.125 J-.228 E.01431
M106 S201.45
M106 S255
G1 X89.008 Y104.459 E.00106
M106 S201.45
G1 F722.792
G1 X89.005 Y104.424 E.00106
G1 F857.047
G1 X89.003 Y104.39 E.00106
G1 F1002.689
G1 X89 Y104.355 E.00106
G1 F1159.801
G1 X88.998 Y104.321 E.00106
G1 F1328.292
G1 X88.995 Y104.287 E.00106
G1 F1508.206
G1 X88.993 Y104.252 E.00106
G1 F1699.601
G1 X88.99 Y104.218 E.00106
G1 F1902.365
G1 X88.987 Y104.183 E.00106
G1 F2116.616
G1 X88.985 Y104.149 E.00106
G1 F2342.229
G1 X88.982 Y104.115 E.00106
G1 F2579.266
G1 X88.98 Y104.08 E.00106
G1 F2798.64
G1 X88.956 Y104.062 E.00094
G1 F3034.923
G1 X88.929 Y104.045 E.00097
G1 F3280.781
G1 X88.902 Y104.028 E.00097
G1 F3536.214
G1 X88.875 Y104.012 E.00097
G1 F3801.293
G1 X88.848 Y103.995 E.00097
G1 F7986.539
G1 X88.451 Y103.952 E.01229
G1 F9547.299
G1 X88.06 Y103.919 E.01203
G3 X88.744 Y71.513 I1.945 J-16.169 E1.47332
; WIPE_START
M204 S6000
G1 X88.937 Y71.467 E-.0755
G1 X88.945 Y71.451 E-.00687
G1 X88.953 Y71.435 E-.00686
G1 X88.961 Y71.419 E-.00687
G1 X88.969 Y71.403 E-.00686
G1 X88.977 Y71.386 E-.00686
G1 X88.985 Y71.37 E-.00687
G1 X88.994 Y71.354 E-.00686
G1 X89.002 Y71.338 E-.00687
G1 X89.01 Y71.322 E-.00686
G1 X89.012 Y71.234 E-.0335
G1 X89.011 Y71.125 E-.0413
G1 X89.011 Y71.016 E-.0413
G1 X89.011 Y70.908 E-.0413
G1 X89.011 Y70.799 E-.0413
G1 X89.011 Y70.69 E-.0413
G1 X89.011 Y70.582 E-.0413
G1 X89.011 Y70.542 E-.01522
G1 X89.041 Y70.515 E-.01509
G1 X89.12 Y70.442 E-.04096
G1 X89.199 Y70.369 E-.04095
G1 X89.279 Y70.296 E-.04096
G1 X89.316 Y70.269 E-.01745
G1 X89.447 Y70.188 E-.05854
G1 X89.578 Y70.107 E-.05855
G1 X89.698 Y70.033 E-.0537
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X84.709 Y73.128 Z1.4 F42000
G1 Z1
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X83.21 Y73.762 I6.113 J16.535 E.05401
G1 X76.012 Y80.96 E.33768
G2 X75.228 Y82.904 I25.145 J11.279 E.06953
G1 X94.846 Y102.522 E.92036
G3 X92.21 Y103.142 I-4.945 J-15.128 E.08995
G1 X105.392 Y89.96 E.61839
G1 X105.383 Y90.031 E.00238
G1 X87.719 Y72.367 E.82866
G2 X89.23 Y72.152 I-.513 J-9.016 E.05071
G2 X89.749 Y70.866 I-.672 J-1.018 E.0489
G3 X90.2 Y70.82 I.249 J.202 E.01671
G1 X90.251 Y70.866 E.00228
G2 X90.77 Y72.152 I1.191 J.267 E.04891
G1 X91.043 Y72.236 E.0095
G1 X92.281 Y72.367 E.04128
G1 X74.617 Y90.031 E.82864
G1 X74.608 Y89.96 E.00238
G1 X87.788 Y103.14 E.61829
G3 X85.154 Y102.522 I2.241 J-15.492 E.08987
G1 X104.772 Y82.904 E.92036
G2 X103.988 Y80.96 I-25.925 J9.334 E.06953
G1 X96.79 Y73.762 E.33768
G2 X95.291 Y73.128 I-7.612 J15.9 E.05401
M204 S10000
G1 X80.703 Y75.284 F42000
G1 F8843.478
M204 S6000
G3 X82.057 Y74.381 I49.397 J72.542 E.05399
G1 X103.369 Y95.693 E.99981
G3 X99.813 Y99.813 I-13.534 J-8.088 E.18144
G1 X77.937 Y77.937 E1.02624
G3 X79.029 Y76.73 I66.861 J59.341 E.05399
M204 S10000
G1 X75.876 Y94.251 F42000
G1 F8843.478
M204 S6000
G2 X76.631 Y95.693 I15.931 J-7.425 E.05401
G1 X97.943 Y74.381 E.99981
G3 X102.063 Y77.937 I-8.088 J13.534 E.18144
G1 X80.187 Y99.813 E1.02624
G2 X81.503 Y100.771 I10.917 J-13.606 E.05401
; CHANGE_LAYER
; Z_HEIGHT: 1.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X80.187 Y99.813 E-.61844
G1 X80.451 Y99.549 E-.14156
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 6/25
; update layer progress
M73 L6
M991 S0 P5 ;notify layer change
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z1.4 I-1.126 J.462 P1  F42000
M73 C3
G1 X84.285 Y108.899 Z1.4
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.864 E.00257
G3 X111.897 Y87.79 I5.787 J-21.115 E3.22946
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49732
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.112 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.891 J-21.493 E3.04526
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.118 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25117
G1 X82.491 Y108.737 E-.41559
G1 X82.262 Y108.649 E-.09323
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z1.6 F42000
G1 X94.196 Y109.433 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.85 J-.924 E.03357
G1 X93.721 Y111.457 E.02248
G1 X93.397 Y111.841 E.01667
G1 X92.776 Y112.419 E.02815
G3 X92.207 Y112.787 I-14.87 J-22.357 E.02248
G1 X91.59 Y113.067 E.02247
G1 X91.107 Y113.207 E.01669
G1 X90.268 Y113.343 E.02819
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.0282
M73 P44 R11
G1 X88.443 Y113.071 E.01669
G1 X87.671 Y112.718 E.02816
G1 X87.256 Y112.433 E.01671
G1 X86.619 Y111.871 E.02816
G1 X86.305 Y111.478 E.01667
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.124 J-2.311 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X93.759 Y109.316 I3.838 J-21.966 E.2543
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.0243
G3 X91.997 Y112.456 I-3.754 J-2.916 E.05703
G3 X86.201 Y110.562 I-1.985 J-3.741 E.20917
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.788 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.156 E.23767
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05566
G1 X94.037 Y109.947 E-.06473
G1 X93.789 Y110.564 E-.2527
G1 X93.389 Y111.247 E-.30053
G1 X93.241 Y111.419 E-.08638
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.027 Y107.226 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X89.845 Y107.236 E.00607
G1 X89.271 Y107.045 E.02006
G1 X88.68 Y106.594 E.02464
G1 X88.392 Y106.278 E.01419
G3 X77.497 Y73.977 I1.608 J-18.53 E1.4301
G3 X88.375 Y69.231 I12.453 J13.706 E.40075
G3 X89.035 Y68.604 I5.313 J4.927 E.03023
G1 X89.488 Y68.348 E.01725
G1 X90.089 Y68.266 E.0201
G1 X90.358 Y68.306 E.00902
G1 X90.881 Y68.545 E.01909
G1 X91.324 Y68.909 E.01903
G1 X91.608 Y69.222 E.01401
G3 X91.615 Y106.27 I-1.601 J18.524 E1.83103
G1 X91.32 Y106.595 E.01457
G1 X90.847 Y106.976 E.02015
G1 X90.327 Y107.209 E.01888
G1 X90.087 Y107.222 E.00798
M204 S250
G1 X90.03 Y106.829 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.788 Y106.831 E.00741
G1 X89.368 Y106.652 E.01404
G3 X88.58 Y105.899 I1.979 J-2.857 E.03361
G3 X77.768 Y74.261 I1.419 J-18.152 E1.30179
G3 X88.575 Y69.604 I12.207 J13.462 E.36822
G3 X89.231 Y68.943 I6.597 J5.893 E.02861
G1 X89.677 Y68.698 E.01565
G1 X90.212 Y68.669 E.01644
G1 X90.632 Y68.848 E.01404
G3 X91.42 Y69.601 I-1.978 J2.857 E.03361
G3 X91.422 Y105.896 I-1.413 J18.148 E1.67012
G3 X90.675 Y106.624 I-2.82 J-2.148 E.03217
G1 X90.222 Y106.828 E.01527
G1 X90.09 Y106.829 E.00406
; WIPE_START
M204 S6000
G1 X89.788 Y106.831 E-.11447
G1 X89.368 Y106.652 E-.17365
G1 X88.928 Y106.29 E-.21651
G1 X88.58 Y105.899 E-.19874
G1 X88.432 Y105.883 E-.05663
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.6 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z1.6
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z1.6 F4000
            G39.3 S1
            G0 Z1.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X92.013 Y106.621 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Floating vertical shell
G1 F9547.299
M204 S6000
G1 X91.437 Y107.563 E.0339
G1 X91.049 Y108.083 E.01995
; Slow Down Start
G1 F1200;_EXTRUDE_SET_SPEED
G1 X90.985 Y108.169 E.00329
G1 X90.618 Y108.5 E.01519
G1 X90.333 Y108.653 E.00992
G1 X89.92 Y108.723 E.01289
G3 X89.339 Y108.49 I.394 J-1.825 E.01934
G1 X88.947 Y108.093 E.01714
G1 X88.882 Y108 E.0035
; Slow Down End
G1 F9547.299
G3 X87.99 Y106.629 I8.968 J-6.811 E.05028
G1 X88.17 Y106.65 E.00558
G2 X88.909 Y107.283 I4.284 J-4.26 E.02992
G1 X89.396 Y107.511 E.01651
G1 X89.753 Y107.614 E.01142
G2 X90.499 Y107.557 I.165 J-2.742 E.02306
G1 X91.054 Y107.307 E.01871
G1 X91.58 Y106.888 E.02066
G1 X91.785 Y106.668 E.00926
G1 X91.954 Y106.633 E.00531
M204 S10000
G1 X90.778 Y107.834 F42000
; LINE_WIDTH: 0.383267
G1 F10577.467
M204 S6000
G1 X90.4 Y107.962 E.01107
G1 X89.872 Y107.986 E.01467
G1 X89.338 Y107.869 E.01516
G1 X89.156 Y107.784 E.00557
G1 X89.547 Y108.205 E.01593
G1 X89.7 Y108.288 E.00483
G1 X89.995 Y108.346 E.00833
G1 X90.181 Y108.319 E.00523
G2 X90.736 Y107.877 I-.632 J-1.36 E.01986
; WIPE_START
G1 X90.473 Y108.141 E-.14168
G1 X90.181 Y108.319 E-.12974
G1 X89.995 Y108.346 E-.0717
G1 X89.7 Y108.288 E-.11413
G1 X89.547 Y108.205 E-.06624
G1 X89.156 Y107.784 E-.21823
G1 X89.199 Y107.804 E-.01828
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X85.941 Y111.57 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X85.245 Y110.107 I2.757 J-2.209 E.05424
G1 X85.165 Y110.187 E.00377
G2 X89.28 Y113.748 I4.85 J-1.447 E.19058
G3 X89.514 Y113.675 I.143 J.044 E.00957
G2 X90.619 Y113.647 I.456 J-3.814 E.03679
G1 X90.72 Y113.748 E.00475
G2 X94.835 Y110.187 I-.735 J-5.008 E.19058
G1 X94.755 Y110.107 E.00376
G3 X94.055 Y111.569 I-6.679 J-2.3 E.05387
M204 S10000
G1 X97.479 Y105.155 F42000
G1 F8843.478
M204 S6000
G1 X99.442 Y107.118 E.09209
G3 X97.953 Y107.775 I-10.327 J-21.408 E.054
; WIPE_START
G1 X99.442 Y107.118 E-.6185
G1 X99.179 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X91.586 Y106.08 Z1.6 F42000
G1 X82.521 Y105.155 Z1.6
G1 Z1.2
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X80.558 Y107.118 E.09209
G2 X82.047 Y107.775 I10.33 J-21.416 E.054
; WIPE_START
G1 X80.558 Y107.118 E-.6185
G1 X80.821 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X87.481 Y103.126 Z1.6 F42000
G1 X108.61 Y91.299 Z1.6
G1 Z1.2
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X108.234 Y92.882 I-20.432 J-4.006 E.054
G1 X110.31 Y94.958 E.09735
G2 X111.151 Y91.876 I-37.413 J-11.878 E.10598
G1 X107.081 Y95.947 E.19094
G3 X105.831 Y98.155 I-18.24 J-8.864 E.08424
G1 X107.704 Y100.028 E.08787
G3 X104.068 Y104.068 I-19.74 J-14.113 E.18067
G1 X102.223 Y102.223 E.08658
G3 X98.197 Y104.831 I-13.688 J-16.715 E.15946
G1 X94.045 Y108.983 E.19477
G2 X93.634 Y108.986 I-.195 J1.226 E.01368
G1 X92.016 Y107.368 E.07591
G3 X90.741 Y108.901 I-3.5 J-1.615 E.0669
G3 X88.641 Y108.338 I-.753 J-1.388 E.07953
G3 X87.981 Y107.371 I6.402 J-5.083 E.03888
G1 X86.366 Y108.986 E.07576
G2 X85.955 Y108.983 I-.215 J1.223 E.01368
G1 X81.803 Y104.831 E.19477
G3 X77.777 Y102.223 I9.712 J-19.4 E.15946
G1 X75.932 Y104.068 E.08658
G3 X72.296 Y100.028 I16.105 J-18.153 E.18067
G1 X74.169 Y98.155 E.08787
G3 X72.919 Y95.947 I17.331 J-11.265 E.08424
G1 X68.849 Y91.876 E.19094
G2 X69.69 Y94.958 I38.263 J-8.799 E.10598
G1 X71.766 Y92.882 E.09735
G3 X71.39 Y91.299 I20.063 J-5.591 E.054
M204 S10000
G1 X70.632 Y78.308 F42000
G1 F8843.478
M204 S6000
G1 X72.595 Y80.271 E.09209
G3 X75.527 Y75.527 I17.509 J7.545 E.18566
G1 X73.682 Y73.682 E.08658
G3 X77.722 Y70.046 I18.153 J16.105 E.18067
G1 X79.595 Y71.919 E.08787
G3 X84.868 Y69.516 I10.444 J15.93 E.19297
G1 X82.792 Y67.44 E.09735
G2 X81.222 Y68.074 I9.83 J26.627 E.05618
G1 X70.324 Y78.972 E.51125
G2 X68.764 Y84.116 I22.33 J9.583 E.17866
G1 X71.102 Y86.454 E.1097
G3 X71.153 Y85.82 I6.522 J.199 E.02112
G1 X68.467 Y88.505 E.12599
G3 X68.47 Y86.877 I16.64 J-.785 E.05402
; WIPE_START
G1 X68.467 Y88.505 E-.61858
G1 X68.73 Y88.242 E-.14143
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X73.714 Y82.462 Z1.6 F42000
G1 X87.622 Y66.335 Z1.6
G1 Z1.2
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X89.245 Y66.217 I2.488 J23.061 E.054
G1 X89.511 Y66.483 E.01247
G3 X90.495 Y66.477 I.499 J1.134 E.03356
G1 X90.755 Y66.217 E.01222
G3 X92.379 Y66.335 I-.889 J23.45 E.054
M204 S10000
G1 X91.045 Y67.424 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S6000
G1 X91.193 Y67.585 E.00673
G3 X92.012 Y68.871 I-12.769 J9.044 E.04686
G1 X91.83 Y68.85 E.00563
G2 X91.091 Y68.217 I-4.323 J4.308 E.02994
G1 X90.514 Y67.946 E.01957
G1 X90.061 Y67.875 E.0141
G1 X89.541 Y67.927 E.01604
G1 X89.227 Y68.041 E.01029
G1 X88.7 Y68.362 E.01893
G1 X88.213 Y68.836 E.02089
G1 X87.987 Y68.879 E.00706
G1 X88.563 Y67.936 E.03394
G1 X88.954 Y67.413 E.02007
; Slow Down Start
G1 F1200;_EXTRUDE_SET_SPEED
G1 X89.012 Y67.335 E.00299
G1 X89.313 Y67.046 E.0128
G1 X89.599 Y66.88 E.01019
G1 X90.064 Y66.774 E.01464
G1 X90.254 Y66.821 E.006
G1 X90.676 Y67.02 E.01435
; Slow Down End
G1 F9547.299
G1 X91.004 Y67.379 E.01495
M204 S10000
G1 X90.788 Y67.677 F42000
; LINE_WIDTH: 0.390278
G1 F10363.973
M204 S6000
G1 X90.431 Y67.297 E.01474
G1 X90.168 Y67.172 E.00824
G2 X89.56 Y67.311 I-.12 J.877 E.01806
G1 X89.229 Y67.651 E.01342
G1 X89.506 Y67.566 E.0082
G1 X90.025 Y67.511 E.01477
G1 X90.517 Y67.574 E.01404
G1 X90.732 Y67.655 E.0065
; WIPE_START
G1 X90.517 Y67.574 E-.08724
G1 X90.025 Y67.511 E-.18851
G1 X89.506 Y67.566 E-.19834
G1 X89.229 Y67.651 E-.11002
G1 X89.552 Y67.319 E-.17588
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X95.254 Y72.393 Z1.6 F42000
G1 X111.53 Y86.877 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X111.533 Y88.505 I-16.638 J.843 E.05402
G1 X108.847 Y85.82 E.12599
G3 X108.898 Y86.454 I-6.446 J.832 E.02112
G1 X111.236 Y84.116 E.1097
G2 X109.676 Y78.972 I-23.891 J4.439 E.17866
G1 X98.778 Y68.074 E.51125
G2 X97.208 Y67.44 I-11.401 J25.994 E.05618
G1 X95.132 Y69.516 E.09735
G3 X100.405 Y71.919 I-5.169 J18.33 E.19297
G1 X102.278 Y70.046 E.08787
G3 X106.318 Y73.682 I-14.113 J19.74 E.18067
G1 X104.472 Y75.528 E.08658
G3 X107.405 Y80.271 I-14.542 J12.266 E.18566
G1 X109.368 Y78.308 E.09211
; WIPE_START
G1 X107.954 Y79.722 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X100.885 Y76.843 Z1.6 F42000
G1 X88.721 Y71.887 Z1.6
G1 Z1.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X88.896 Y71.831 E.0061
G1 X89.104 Y71.614 E.00997
G1 X89.176 Y71.334 E.00958
G1 X89.175 Y70.677 E.02181
G1 X89.528 Y70.289 E.0174
G1 X89.908 Y70.021 E.01542
G1 X90.108 Y70.035 E.00666
G1 X90.401 Y70.225 E.01159
G1 X90.825 Y70.668 E.02033
G1 X90.824 Y71.334 E.02211
G1 X90.896 Y71.614 E.00958
G1 X91.104 Y71.831 E.00997
G1 X91.33 Y71.911 E.00796
G3 X105.888 Y88.142 I-1.347 J15.853 E.79679
G3 X91.363 Y103.586 I-15.905 J-.406 E.76971
G1 X91.104 Y103.669 E.00902
G1 X90.896 Y103.886 E.00997
G1 X90.824 Y104.166 E.00958
G1 X90.825 Y104.827 E.02195
G1 X90.311 Y105.353 E.02439
G1 X90.037 Y105.486 E.0101
G1 X89.847 Y105.452 E.0064
G3 X89.175 Y104.836 I1.557 J-2.375 E.03035
G1 X89.176 Y104.166 E.02225
G1 X89.104 Y103.886 E.00958
G1 X88.896 Y103.669 E.00997
G1 X88.67 Y103.589 E.00796
G3 X88.637 Y71.914 I1.337 J-15.839 E1.56654
G1 X88.664 Y71.906 E.00092
M204 S250
G1 X88.609 Y71.523 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X88.724 Y71.47 E.0039
G1 X88.732 Y71.451 E.00062
G1 X88.74 Y71.433 E.00062
G1 X88.749 Y71.414 E.00062
G1 X88.757 Y71.396 E.00062
G1 X88.765 Y71.377 E.00062
G1 X88.773 Y71.359 E.00062
G1 X88.781 Y71.34 E.00062
G1 X88.783 Y71.208 E.00407
G1 X88.783 Y71.029 E.00551
G1 X88.783 Y70.849 E.00551
G1 X88.783 Y70.67 E.00551
G1 X88.783 Y70.529 E.00434
G1 X89.006 Y70.276 E.01036
G1 F4503.465
G3 X89.128 Y70.146 I.73 J.561 E.00548
G1 F3000
G1 X89.262 Y70.021 E.00564
G1 X89.396 Y69.895 E.00564
G3 X89.521 Y69.798 I.278 J.228 E.00492
G1 X89.636 Y69.731 E.00409
G1 X89.751 Y69.664 E.00409
G1 X89.79 Y69.641 E.00139
G1 X90.051 Y69.607 E.00808
G1 X90.163 Y69.641 E.00361
G3 X90.313 Y69.709 I-.145 J.522 E.00506
G3 X90.467 Y69.786 I-.064 J.322 E.00535
G1 X90.595 Y69.897 E.00523
G1 X90.724 Y70.008 E.00523
G1 X90.853 Y70.119 E.00523
G1 X90.861 Y70.129 E.00039
G1 F8416.354
G1 X91.217 Y70.526 E.0164
G1 F9547.299
G1 X91.217 Y70.667 E.00435
G1 X91.217 Y70.847 E.00553
G1 X91.217 Y71.027 E.00553
G1 X91.217 Y71.207 E.00553
G1 X91.219 Y71.34 E.00408
G1 X91.227 Y71.359 E.00062
G1 X91.235 Y71.377 E.00062
G1 X91.243 Y71.396 E.00062
G1 X91.251 Y71.414 E.00062
G1 X91.26 Y71.433 E.00062
G1 X91.268 Y71.451 E.00062
G1 X91.276 Y71.47 E.00062
G1 X91.379 Y71.522 E.00354
G3 X106.28 Y88.151 I-1.396 J16.242 E.75578
G3 X91.391 Y103.977 I-16.297 J-.416 E.73073
G1 X91.276 Y104.03 E.0039
G1 X91.268 Y104.049 E.00062
G1 X91.26 Y104.067 E.00062
G1 X91.251 Y104.086 E.00062
G1 X91.243 Y104.104 E.00062
G1 X91.235 Y104.123 E.00062
G1 X91.227 Y104.141 E.00062
G1 X91.219 Y104.16 E.00062
G1 X91.217 Y104.292 E.00408
G1 X91.217 Y104.472 E.00552
G1 X91.217 Y104.652 E.00552
G1 X91.217 Y104.831 E.00552
G1 F8168.159
G1 X91.217 Y104.973 E.00434
G1 X90.974 Y105.255 E.01145
G1 F3000
G3 X90.911 Y105.324 I-.373 J-.279 E.00286
G1 X90.751 Y105.476 E.0068
G3 X90.598 Y105.615 I-.419 J-.308 E.00638
G1 X90.481 Y105.688 E.00425
G1 X90.364 Y105.762 E.00425
G1 X90.247 Y105.836 E.00425
G1 X90.211 Y105.858 E.00131
G1 X89.949 Y105.893 E.0081
G1 X89.774 Y105.839 E.00562
G3 X89.629 Y105.778 I.017 J-.244 E.00493
G1 X89.543 Y105.716 E.00327
G3 X89.442 Y105.637 I.326 J-.522 E.00393
G1 X89.294 Y105.505 E.00609
G1 X89.147 Y105.373 E.00609
G3 X89.051 Y105.273 I.411 J-.49 E.00426
G1 F8532.692
G1 X88.783 Y104.975 E.01232
G1 X88.783 Y104.834 E.00436
G1 F9547.299
G1 X88.783 Y104.653 E.00554
G1 X88.783 Y104.473 E.00554
G1 X88.783 Y104.293 E.00554
G1 X88.781 Y104.16 E.00409
G1 X88.773 Y104.141 E.00062
G1 X88.765 Y104.123 E.00062
G1 X88.757 Y104.104 E.00062
G1 X88.749 Y104.086 E.00062
G1 X88.74 Y104.067 E.00062
G1 X88.732 Y104.049 E.00062
G1 X88.724 Y104.03 E.00062
G1 X88.621 Y103.978 E.00354
G3 X88.549 Y71.528 I1.386 J-16.228 E1.4847
; WIPE_START
M204 S6000
G1 X88.724 Y71.47 E-.07012
G1 X88.732 Y71.451 E-.00769
G1 X88.74 Y71.433 E-.00769
G1 X88.749 Y71.414 E-.00769
G1 X88.757 Y71.396 E-.00769
G1 X88.765 Y71.377 E-.00769
G1 X88.773 Y71.359 E-.00769
G1 X88.781 Y71.34 E-.00769
G1 X88.783 Y71.208 E-.05031
G1 X88.783 Y71.029 E-.06813
G1 X88.783 Y70.849 E-.06813
G1 X88.783 Y70.67 E-.06813
G1 X88.783 Y70.529 E-.05364
G1 X89.006 Y70.276 E-.12818
G1 X89.128 Y70.146 E-.06766
G1 X89.262 Y70.021 E-.06976
G1 X89.381 Y69.909 E-.06214
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X95.291 Y73.128 Z1.6 F42000
G1 Z1.2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X96.79 Y73.762 I-6.113 J16.534 E.05401
G1 X103.068 Y80.04 E.2945
G3 X104.474 Y83.202 I-13.402 J7.855 E.11504
G1 X85.154 Y102.522 E.90637
G2 X87.789 Y103.141 I4.91 J-14.999 E.08991
G1 X75.067 Y90.419 E.59682
G3 X74.955 Y89.693 I7.572 J-1.537 E.02436
G1 X92.281 Y72.367 E.81279
G3 X91.087 Y72.206 I-.062 J-4.04 E.04012
G3 X90.479 Y70.8 I.61 J-1.098 E.05464
G2 X89.947 Y70.389 I-.674 J.324 E.02311
G2 X89.519 Y71.425 I.429 J.784 E.04018
G3 X88.762 Y72.247 I-.941 J-.107 E.03963
G1 X87.719 Y72.367 E.03485
G1 X105.045 Y89.693 E.8128
G3 X104.933 Y90.419 I-7.685 J-.812 E.02436
G1 X92.211 Y103.141 E.59684
G2 X94.846 Y102.522 I-2.282 J-15.647 E.08992
M73 P45 R11
G1 X75.228 Y82.904 E.92036
G3 X76.012 Y80.96 I25.929 J9.336 E.06953
G1 X83.21 Y73.762 E.33768
G3 X84.709 Y73.128 I7.612 J15.901 E.05401
M204 S10000
G1 X79.029 Y76.73 F42000
G1 F8843.478
M204 S6000
G2 X77.937 Y77.937 I65.769 J60.548 E.05399
G1 X99.813 Y99.813 E1.02624
G2 X103.369 Y95.693 I-9.977 J-12.208 E.18144
G1 X82.057 Y74.381 E.99981
G2 X80.703 Y75.284 I48.043 J73.446 E.05399
M204 S10000
G1 X74.726 Y90.565 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.38292
G1 F10588.235
M204 S6000
G3 X74.526 Y89.073 I11.835 J-2.349 E.04175
M204 S10000
G1 X77.533 Y97.014 F42000
; Slow Down Start
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G3 X76.323 Y95.107 I12.454 J-9.239 E.06263
; Slow Down End
M204 S10000
G1 X78.98 Y98.721 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X80.187 Y99.813 I60.548 J-65.769 E.05399
G1 X102.063 Y77.937 E1.02624
G2 X97.943 Y74.381 I-12.208 J9.977 E.18144
G1 X76.908 Y95.416 E.98682
G3 X76.341 Y94.354 I10.644 J-6.363 E.03996
G1 X76.096 Y94.7 E.01405
M204 S10000
G1 X105.419 Y89.618 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.38292
G1 F10588.235
M204 S6000
G3 X105.112 Y91.339 I-15.872 J-1.941 E.04845
M204 S10000
G1 X103.483 Y80.039 F42000
; Slow Down Start
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G1 X104.043 Y81.104 E.03333
G3 X105.076 Y84.024 I-14.223 J6.675 E.08595
; Slow Down End
; CHANGE_LAYER
; Z_HEIGHT: 1.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F1200
G1 X104.866 Y83.236 E-.30961
G1 X104.626 Y82.512 E-.28996
G1 X104.474 Y82.118 E-.16043
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 7/25
; update layer progress
M73 L7
M991 S0 P6 ;notify layer change
M106 S160.65
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z1.6 I-.972 J-.733 P1  F42000
G1 X84.285 Y108.899 Z1.6
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X111.897 Y87.79 I5.787 J-21.115 E3.22945
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00904
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49732
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.111 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.892 J-21.493 E3.04525
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.119 I-5.602 J-1.462 E.47075
G1 X84.212 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25111
G1 X82.491 Y108.737 E-.41561
G1 X82.262 Y108.649 E-.09328
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z1.8 F42000
G1 X94.195 Y109.433 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.848 J-.923 E.03357
G1 X93.721 Y111.457 E.02248
G1 X93.397 Y111.841 E.01667
G1 X92.776 Y112.419 E.02814
G1 X92.353 Y112.695 E.01673
G1 X91.59 Y113.067 E.02818
G1 X91.107 Y113.207 E.01669
G1 X90.268 Y113.343 E.02818
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.0282
G1 X88.443 Y113.071 E.0167
G1 X87.671 Y112.718 E.02815
G1 X87.256 Y112.433 E.01671
G1 X86.62 Y111.871 E.02816
G1 X86.305 Y111.478 E.01668
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.127 J-2.312 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.376 E.00982
G1 X86.131 Y109.308 E.00905
G2 X87.718 Y109.526 I5.177 J-31.772 E.05313
G2 X93.759 Y109.316 I2.261 J-21.988 E.20116
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.0243
G3 X86.201 Y110.562 I-3.389 J-2.504 E.26652
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.787 E.00519
G1 X86.129 Y109.7 E.00525
G2 X87.669 Y109.915 I4.101 J-23.769 E.04779
G2 X93.826 Y109.702 I2.31 J-22.371 E.18989
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05566
G1 X94.037 Y109.947 E-.06472
G1 X93.789 Y110.564 E-.25267
G1 X93.389 Y111.247 E-.30056
G1 X93.241 Y111.419 E-.08639
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.919 Y107.594 Z1.8 F42000
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X89.447 Y107.489 E.01602
G1 X89.026 Y107.219 E.0166
G1 X88.491 Y106.679 E.02521
G1 X88.174 Y106.267 E.01724
G1 X87.522 Y106.182 E.02181
G3 X77.497 Y73.976 I2.482 J-18.436 E1.40091
G3 X88.162 Y69.249 I12.494 J13.791 E.3936
G3 X88.924 Y68.366 I4.421 J3.043 E.03876
G1 X89.371 Y68.054 E.01808
G1 X89.59 Y67.967 E.00782
G1 X90.083 Y67.892 E.01654
G1 X90.552 Y68.011 E.01606
G1 X90.983 Y68.288 E.01699
G1 X91.507 Y68.819 E.02474
G1 X91.826 Y69.233 E.01733
G1 X92.475 Y69.318 E.02171
G3 X91.838 Y106.251 I-2.468 J18.43 E1.79476
G3 X91.084 Y107.127 I-4.435 J-3.053 E.0384
G1 X90.63 Y107.446 E.0184
G1 X90.439 Y107.528 E.0069
G1 X89.995 Y107.611 E.01501
G1 X89.977 Y107.607 E.00058
M204 S250
G1 X89.99 Y107.211 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.969 Y107.215 E.00067
G1 X89.586 Y107.119 E.01212
G1 X89.208 Y106.864 E.01401
G3 X88.377 Y105.884 I3.846 J-4.104 E.03958
G3 X77.768 Y74.261 I1.623 J-18.136 E1.29558
G3 X88.374 Y69.62 I12.238 J13.529 E.362
G3 X89.208 Y68.636 I4.69 J3.13 E.03971
G1 X89.653 Y68.354 E.01618
G1 X90.119 Y68.291 E.01445
G1 X90.414 Y68.381 E.00948
G1 X90.8 Y68.643 E.01432
G3 X91.623 Y69.616 I-3.877 J4.115 E.03926
G3 X91.626 Y105.88 I-1.624 J18.132 E1.65733
G3 X90.8 Y106.857 I-4.714 J-3.148 E.0394
G1 X90.352 Y107.145 E.01636
G1 X90.05 Y107.2 E.00944
; WIPE_START
M204 S6000
G1 X89.969 Y107.215 E-.03112
G1 X89.586 Y107.119 E-.14984
G1 X89.208 Y106.864 E-.17328
G1 X88.759 Y106.392 E-.24767
G1 X88.509 Y106.059 E-.15809
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z1.8 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z1.8
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z1.8 F4000
            G39.3 S1
            G0 Z1.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X86.832 Y106.425 F42000
G1 Z1.4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X87.403 Y106.515 I1.195 J-5.714 E.0192
G1 X87.926 Y107.425 E.03482
G1 X86.366 Y108.986 E.07323
G2 X85.955 Y108.983 I-.215 J1.223 E.01368
G1 X81.803 Y104.831 E.19477
G3 X77.777 Y102.223 I9.712 J-19.4 E.15945
G1 X75.932 Y104.068 E.08658
G3 X72.296 Y100.028 I16.105 J-18.153 E.18067
G1 X74.169 Y98.155 E.08787
G3 X72.919 Y95.947 I17.331 J-11.265 E.08424
G1 X68.849 Y91.876 E.19094
G2 X69.69 Y94.958 I38.263 J-8.799 E.10598
G1 X71.766 Y92.882 E.09735
G3 X71.39 Y91.299 I20.063 J-5.591 E.054
M204 S10000
G1 X68.47 Y86.877 F42000
G1 F8843.478
M204 S6000
G2 X68.467 Y88.505 I16.638 J.843 E.05402
G1 X71.153 Y85.82 E.12599
G2 X71.102 Y86.454 I6.471 J.834 E.02112
G1 X68.764 Y84.116 E.1097
G3 X70.324 Y78.972 I23.89 J4.439 E.17866
G1 X81.222 Y68.074 E.51125
G3 X82.792 Y67.44 I11.401 J25.993 E.05618
G1 X84.868 Y69.516 E.09735
G2 X79.595 Y71.919 I5.169 J18.329 E.19297
G1 X77.722 Y70.046 E.08787
G2 X73.682 Y73.682 I14.114 J19.741 E.18067
G1 X75.528 Y75.528 E.08658
G2 X72.596 Y80.271 I14.542 J12.266 E.18566
G1 X70.632 Y78.308 E.09211
; WIPE_START
G1 X72.046 Y79.722 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X78.143 Y75.13 Z1.8 F42000
G1 X88.265 Y67.506 Z1.8
G1 Z1.4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X88.37 Y67.324 E.00696
G3 X89.281 Y66.253 I2.967 J1.599 E.04699
G1 X89.245 Y66.217 E.00168
G2 X87.622 Y66.335 I.868 J23.223 E.054
M204 S10000
G1 X91.735 Y67.506 F42000
G1 F8843.478
M204 S6000
G2 X90.722 Y66.251 I-3.551 J1.831 E.05388
G1 X90.755 Y66.217 E.00158
G3 X92.379 Y66.335 I-.889 J23.442 E.054
M204 S10000
G1 X91.854 Y68.56 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.47593
G1 F8313.896
M204 S6000
G1 X92.018 Y68.805 E.01039
M204 S10000
G1 X90.872 Y66.942 F42000
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S6000
G1 X91.135 Y67.293 E.01348
; LINE_WIDTH: 0.439873
G1 F9069.095
G1 X91.346 Y67.628 E.01281
; LINE_WIDTH: 0.467168
G1 F8485.614
G3 X91.854 Y68.56 I-4.409 J3.009 E.03675
; LINE_WIDTH: 0.479638
G1 F8243.315
G1 X91.847 Y68.55 E.00042
; LINE_WIDTH: 0.457091
G1 F8692.075
G1 X91.338 Y68.077 E.02344
; LINE_WIDTH: 0.41999
G1 F9547.299
G1 X90.744 Y67.671 E.02213
G1 X90.331 Y67.536 E.01334
G1 X90.005 Y67.503 E.01007
G1 X89.505 Y67.584 E.01555
G1 X89.261 Y67.667 E.00793
; LINE_WIDTH: 0.438718
G1 F9095.56
G1 X89.021 Y67.822 E.00923
; LINE_WIDTH: 0.460043
G1 F8630.545
G1 X88.78 Y67.977 E.00973
G1 X88.148 Y68.56 E.02923
; LINE_WIDTH: 0.476173
G1 F8309.242
G1 X88.154 Y68.547 E.00052
; LINE_WIDTH: 0.454419
G1 F8748.501
G1 X88.586 Y67.733 E.03089
; LINE_WIDTH: 0.41999
G1 F9547.299
G1 X88.946 Y67.172 E.0205
G1 X89.116 Y66.969 E.00811
; Slow Down Start
G1 F1200;_EXTRUDE_SET_SPEED
G1 X89.341 Y66.699 E.0108
G1 X89.709 Y66.441 E.0138
G1 X89.818 Y66.254 E.00667
G1 X90.117 Y66.253 E.00919
G1 X90.198 Y66.368 E.00432
G3 X90.797 Y66.842 I-1.616 J2.656 E.02352
; Slow Down End
G1 F9547.299
G1 X90.836 Y66.894 E.00199
M204 S10000
G1 X90.629 Y67.232 F42000
; LINE_WIDTH: 0.41992
G1 F9549.071
M204 S6000
G1 X90.402 Y66.981 E.01041
G1 X89.985 Y66.683 E.01572
G1 X89.371 Y67.224 E.02514
G1 X89.945 Y67.131 E.01785
G1 X90.441 Y67.175 E.0153
G1 X90.571 Y67.215 E.00418
M204 S10000
G1 X87.944 Y68.865 F42000
; LINE_WIDTH: 0.47143
G1 F8401.204
M204 S6000
G1 X88.115 Y68.61 E.0107
; WIPE_START
G1 X87.944 Y68.865 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X94.928 Y71.943 Z1.8 F42000
G1 X109.368 Y78.308 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X107.405 Y80.271 E.09211
G2 X104.472 Y75.528 I-17.474 J7.522 E.18566
G1 X106.318 Y73.682 E.08658
G2 X102.278 Y70.046 I-18.153 J16.104 E.18067
G1 X100.405 Y71.919 E.08787
G2 X95.132 Y69.516 I-10.442 J15.927 E.19297
G1 X97.208 Y67.44 E.09735
G3 X98.778 Y68.074 I-9.831 J26.628 E.05618
G1 X109.676 Y78.972 E.51125
G3 X111.236 Y84.116 I-22.33 J9.583 E.17866
G1 X108.898 Y86.454 E.1097
G2 X108.847 Y85.82 I-6.497 J.197 E.02112
G1 X111.533 Y88.505 E.12599
G2 X111.53 Y86.877 I-16.64 J-.785 E.05402
M204 S10000
G1 X108.61 Y91.299 F42000
G1 F8843.478
M204 S6000
G3 X108.234 Y92.882 I-20.445 J-4.009 E.054
G1 X110.31 Y94.958 E.09735
G2 X111.151 Y91.876 I-37.413 J-11.878 E.10598
G1 X107.081 Y95.947 E.19094
G3 X105.831 Y98.155 I-18.574 J-9.053 E.08424
G1 X107.704 Y100.028 E.08787
G3 X104.068 Y104.068 I-19.74 J-14.113 E.18067
G1 X102.223 Y102.223 E.08658
G3 X98.197 Y104.831 I-13.741 J-16.795 E.15945
G1 X94.045 Y108.983 E.19477
G2 X93.634 Y108.986 I-.195 J1.226 E.01368
G1 X92.071 Y107.423 E.07334
G1 X92.597 Y106.514 E.03484
G2 X93.168 Y106.425 I-.452 J-4.812 E.01917
M204 S10000
G1 X91.853 Y106.94 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.47307
G1 F8369.173
M204 S6000
G1 X92.023 Y106.686 E.01071
M204 S10000
G1 X91.853 Y106.94 F42000
; LINE_WIDTH: 0.477718
G1 F8279.716
M204 S6000
G1 X91.847 Y106.953 E.00052
; LINE_WIDTH: 0.455398
G1 F8727.747
G1 X91.392 Y107.815 E.03276
; LINE_WIDTH: 0.41999
G1 F9547.299
G1 X91.026 Y108.365 E.02029
G1 X90.868 Y108.547 E.00741
; Slow Down Start
G1 F1200;_EXTRUDE_SET_SPEED
G3 X90.322 Y109.053 I-1.391 J-.956 E.02306
G1 X90.217 Y109.246 E.00676
M73 P46 R11
G1 X89.86 Y109.225 E.011
G1 X89.727 Y109.046 E.00686
G1 X89.249 Y108.714 E.01786
G1 X89.098 Y108.514 E.00771
; Slow Down End
G1 F9547.299
G1 X88.865 Y108.208 E.01181
; LINE_WIDTH: 0.43953
G1 F9076.927
G1 X88.657 Y107.878 E.01263
; LINE_WIDTH: 0.448771
G1 F8870.262
G3 X88.16 Y106.961 I4.097 J-2.813 E.03454
G1 X88.67 Y107.43 E.02292
; LINE_WIDTH: 0.41999
G1 F9547.299
G1 X89.316 Y107.857 E.02377
G1 X89.964 Y107.999 E.02039
G1 X90.14 Y107.978 E.00545
G1 X90.739 Y107.833 E.01893
; LINE_WIDTH: 0.439233
G1 F9083.741
G1 X90.984 Y107.674 E.00944
; LINE_WIDTH: 0.463679
G1 F8555.981
G1 X91.229 Y107.515 E.01002
G1 X91.809 Y106.98 E.02703
M204 S10000
G1 X90.65 Y108.25 F42000
; LINE_WIDTH: 0.41962
G1 F9556.677
M204 S6000
G1 X90.127 Y108.366 E.01644
G1 X89.883 Y108.367 E.00748
G1 X89.358 Y108.252 E.0165
G1 X89.565 Y108.497 E.00986
G1 X90.033 Y108.824 E.0175
G1 X90.611 Y108.295 E.02404
M204 S10000
G1 X87.949 Y106.646 F42000
; LINE_WIDTH: 0.47674
G1 F8298.373
M204 S6000
G1 X88.118 Y106.899 E.01077
M204 S10000
G1 X82.047 Y107.775 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X80.558 Y107.118 I8.841 J-22.072 E.054
G1 X82.521 Y105.155 E.09209
; WIPE_START
G1 X81.107 Y106.569 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.227 Y109.318 Z1.8 F42000
G1 X94.055 Y111.569 Z1.8
G1 Z1.4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G2 X94.755 Y110.107 I-5.976 J-3.76 E.05387
G1 X94.835 Y110.187 E.00376
G3 X90.72 Y113.748 I-4.85 J-1.447 E.19058
G1 X90.619 Y113.647 E.00475
G3 X89.378 Y113.65 I-.635 J-5.585 E.04126
G1 X89.28 Y113.748 E.0046
G3 X85.165 Y110.187 I.735 J-5.008 E.19058
G1 X85.245 Y110.107 E.00377
G2 X85.941 Y111.57 I3.453 J-.746 E.05424
; WIPE_START
G1 X85.511 Y110.83 E-.32559
G1 X85.245 Y110.107 E-.29254
G1 X85.165 Y110.187 E-.04316
G1 X85.255 Y110.431 E-.09871
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X92.726 Y108.868 Z1.8 F42000
G1 X97.953 Y107.775 Z1.8
G1 Z1.4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G2 X99.442 Y107.118 I-8.838 J-22.065 E.054
G1 X97.479 Y105.155 E.09209
; WIPE_START
G1 X98.893 Y106.569 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.716 Y99.254 Z1.8 F42000
G1 X88.572 Y71.893 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X88.743 Y71.83 E.00606
G1 X88.941 Y71.606 E.00989
G1 X89.003 Y71.346 E.00889
G1 X89.003 Y70.65 E.02308
G3 X89.574 Y69.951 I4.766 J3.312 E.02995
G1 X89.916 Y69.677 E.01453
G1 X90.104 Y69.692 E.00626
G1 X90.43 Y69.958 E.01396
G1 X90.997 Y70.647 E.02959
G1 X90.997 Y71.346 E.02319
G1 X91.059 Y71.606 E.00889
G1 X91.257 Y71.83 E.00989
G1 X91.452 Y71.913 E.00705
G3 X102.04 Y77.376 I-1.536 J15.968 E.40491
G3 X105.888 Y88.142 I-12.107 J10.398 E.38786
G3 X91.506 Y103.578 I-15.894 J-.391 E.76523
G1 X91.257 Y103.67 E.00881
G1 X91.059 Y103.893 E.00987
G1 X90.997 Y104.153 E.00888
G1 X90.995 Y104.849 E.0231
G3 X90.264 Y105.703 I-3.864 J-2.569 E.03738
G1 X89.992 Y105.846 E.0102
G1 X89.72 Y105.686 E.01047
G3 X89.003 Y104.857 I3.514 J-3.767 E.03643
G1 X89.003 Y104.154 E.02331
G1 X88.941 Y103.893 E.00892
G1 X88.743 Y103.67 E.00987
G1 X88.504 Y103.579 E.00848
G3 X88.494 Y71.922 I1.502 J-15.829 E1.55687
G1 X88.516 Y71.914 E.00077
M204 S250
G1 X88.446 Y71.533 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X88.555 Y71.479 E.00375
G1 X88.565 Y71.457 E.00073
G1 F7881.259
G1 X88.574 Y71.435 E.00073
G1 F7590.93
G1 X88.583 Y71.413 E.00073
G1 F7306.159
G1 X88.592 Y71.391 E.00073
G1 F7026.724
G1 X88.601 Y71.369 E.00073
G1 F6752.843
G1 X88.61 Y71.347 E.00073
G1 F6484.304
G1 X88.611 Y71.168 E.00551
G1 F4636.955
G1 X88.611 Y70.976 E.00591
G1 F3000
G1 X88.611 Y70.783 E.00591
G1 F2700
G1 X88.611 Y70.591 E.00591
G1 F2400
G1 X88.611 Y70.52 E.0022
G1 X88.732 Y70.358 E.0062
G1 F2700
G3 X89.024 Y69.986 I2.603 J1.739 E.01454
G1 F2400
G1 X89.179 Y69.808 E.00726
G1 F2100
G3 X89.316 Y69.662 I.507 J.339 E.00618
G1 F3031.09
G1 X89.419 Y69.577 E.00409
G1 F4132.607
G1 X89.522 Y69.493 E.00409
G1 F5404.445
G1 X89.625 Y69.408 E.00409
G1 F6788.503
G3 X89.737 Y69.346 I.16 J.158 E.00399
G1 F8320.319
G1 X89.854 Y69.297 E.00391
G1 F9547.299
G1 X89.95 Y69.256 E.0032
G1 X90.147 Y69.3 E.00619
G3 X90.326 Y69.368 I.016 J.226 E.00606
G1 F7192.371
G1 X90.436 Y69.452 E.00427
G1 F5652.039
G1 X90.547 Y69.537 E.00427
G1 F4297.095
G1 X90.657 Y69.621 E.00427
G1 F3127.538
G1 X90.752 Y69.732 E.00448
G1 F2100
G1 X90.847 Y69.842 E.00448
G1 F2400
G1 X90.942 Y69.953 E.00448
G1 F2700
G1 X91.037 Y70.063 E.00448
G1 F3000
G1 X91.089 Y70.128 E.00256
G1 F2700
G1 X91.307 Y70.412 E.01099
G1 F2400
G1 X91.389 Y70.518 E.00414
G2 X91.39 Y70.888 I5.243 J.172 E.01135
G1 F2700
G1 X91.392 Y70.954 E.00204
G1 F3000
G1 X91.395 Y71.02 E.00204
G1 F3523.713
G1 X91.397 Y71.086 E.00204
G1 F4089.626
G1 X91.399 Y71.152 E.00204
G1 F4697.567
G1 X91.402 Y71.219 E.00204
G1 F5347.717
G1 X91.404 Y71.285 E.00204
G1 F6039.886
G1 X91.406 Y71.351 E.00204
G1 F6774.28
G1 X91.409 Y71.417 E.00204
G1 F7589.437
G1 X91.453 Y71.471 E.00213
G1 F8513.404
G1 X91.508 Y71.521 E.00228
G1 F9547.299
G1 X91.904 Y71.578 E.01229
G1 X92.788 Y71.701 E.02743
G3 X98.021 Y73.577 I-2.992 J16.588 E.17158
G3 X106.28 Y88.151 I-8.029 J14.178 E.54063
G3 X91.554 Y103.967 I-16.285 J-.4 E.72597
G1 X91.445 Y104.021 E.00374
G1 X91.436 Y104.043 E.00073
G1 X91.426 Y104.065 E.00073
G1 X91.417 Y104.087 E.00073
G1 X91.408 Y104.109 E.00073
G1 X91.399 Y104.131 E.00073
G1 X91.39 Y104.153 E.00073
G1 X91.389 Y104.338 E.0057
G1 X91.388 Y104.534 E.00601
G1 X91.388 Y104.729 E.00601
G1 X91.387 Y104.925 E.00601
G3 X91.366 Y105.009 I-.066 J.029 E.00288
G1 X91.296 Y105.102 E.00358
G1 X91.225 Y105.195 E.00358
G1 X91.154 Y105.287 E.00358
G1 X91.084 Y105.38 E.00358
G1 X91.013 Y105.473 E.00358
G3 X90.948 Y105.551 I-.403 J-.266 E.00314
G1 X90.904 Y105.598 E.00198
G1 X90.859 Y105.645 E.00198
G1 X90.815 Y105.692 E.00198
G1 X90.771 Y105.739 E.00198
G1 X90.726 Y105.786 E.00198
G1 X90.682 Y105.833 E.00198
G1 X90.638 Y105.88 E.00198
G1 X90.593 Y105.927 E.00198
G3 X90.506 Y105.99 I-.186 J-.165 E.00335
G1 X90.404 Y106.059 E.00377
G1 X90.303 Y106.128 E.00377
G1 X90.201 Y106.196 E.00377
G1 X90.169 Y106.218 E.0012
G1 X89.959 Y106.246 E.00649
G1 X89.837 Y106.209 E.00394
G3 X89.71 Y106.135 I.075 J-.273 E.00455
G1 X89.586 Y106.057 E.00452
G1 X89.461 Y105.979 E.00452
G3 X89.398 Y105.926 I.066 J-.144 E.00256
G1 X89.358 Y105.884 E.00177
G1 X89.319 Y105.842 E.00177
G1 X89.28 Y105.8 E.00177
G1 X89.24 Y105.758 E.00177
G1 X89.201 Y105.715 E.00177
G1 X89.162 Y105.673 E.00177
G1 X89.123 Y105.631 E.00177
G1 X89.083 Y105.589 E.00177
G1 X89.044 Y105.547 E.00177
G1 X89.018 Y105.515 E.00124
G1 X88.954 Y105.432 E.00323
G1 X88.891 Y105.348 E.00323
G1 X88.827 Y105.265 E.00323
G1 X88.763 Y105.181 E.00323
G1 X88.699 Y105.098 E.00323
G1 X88.635 Y105.014 E.00323
G3 X88.611 Y104.91 I.056 J-.068 E.00352
G1 X88.611 Y104.718 E.00592
G1 X88.611 Y104.525 E.00592
G1 X88.611 Y104.332 E.00592
G1 X88.61 Y104.153 E.00552
G1 X88.601 Y104.131 E.00073
G1 X88.592 Y104.109 E.00073
G1 X88.583 Y104.087 E.00073
G1 X88.574 Y104.065 E.00073
G1 X88.565 Y104.043 E.00073
G1 X88.555 Y104.021 E.00073
G1 X88.451 Y103.968 E.00359
G3 X88.386 Y71.539 I1.555 J-16.218 E1.47498
; WIPE_START
M204 S6000
G1 X88.555 Y71.479 E-.06821
G1 X88.565 Y71.457 E-.00905
G1 X88.574 Y71.435 E-.00905
G1 X88.583 Y71.413 E-.00905
G1 X88.592 Y71.391 E-.00905
G1 X88.601 Y71.369 E-.00905
G1 X88.61 Y71.347 E-.00905
G1 X88.611 Y71.168 E-.06818
G1 X88.611 Y70.976 E-.07307
G1 X88.611 Y70.783 E-.07307
G1 X88.611 Y70.591 E-.07307
G1 X88.611 Y70.52 E-.02718
G1 X88.732 Y70.358 E-.07669
G1 X89.024 Y69.986 E-.17968
G1 X89.139 Y69.854 E-.06653
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X82.827 Y74.146 Z1.8 F42000
G1 X79.029 Y76.73 Z1.8
G1 Z1.4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X77.937 Y77.937 I65.769 J60.548 E.05399
G1 X79.283 Y79.283 E.06315
G1 X75.445 Y83.121 E.18005
G1 X75.228 Y82.904 E.01022
G3 X76.012 Y80.96 I25.929 J9.336 E.06953
G1 X83.21 Y73.762 E.33768
G3 X87.719 Y72.367 I7.281 J15.549 E.15705
G1 X91.732 Y76.38 E.18827
G1 X92.159 Y75.953 E.02003
G1 X94.265 Y78.059 E.09879
G1 X97.943 Y74.381 E.17256
G3 X102.063 Y77.937 I-8.088 J13.534 E.18144
G1 X101.941 Y78.059 E.00572
G1 X99.815 Y75.934 E.09971
G1 X99.389 Y76.361 E.02003
G1 X96.79 Y73.762 E.12191
G2 X92.281 Y72.367 I-7.281 J15.549 E.15705
G1 X86.589 Y78.059 E.26703
G1 X84.503 Y75.973 E.09787
G1 X84.076 Y76.4 E.02003
G1 X82.057 Y74.381 E.09472
G2 X80.703 Y75.284 I48.043 J73.446 E.05399
M204 S10000
G1 X79.855 Y79.321 F42000
; FEATURE: Bridge
; LINE_WIDTH: 0.40382
; LAYER_HEIGHT: 0.4
M106 S255
G1 F1200
M204 S6000
G1 X75.626 Y83.549 E.31208
G1 X75.947 Y83.87 E.02368
G1 X80.032 Y79.785 E.30152
G1 X80.353 Y80.106 E.02368
G1 X76.268 Y84.191 E.30152
G1 X76.588 Y84.512 E.02368
G1 X84.512 Y76.588 E.58475
G1 X84.833 Y76.909 E.02368
G1 X76.909 Y84.833 E.58475
G1 X77.23 Y85.154 E.02368
G1 X85.154 Y77.23 E.58475
G1 X85.475 Y77.551 E.02368
G1 X77.551 Y85.475 E.58475
G1 X77.852 Y85.776 E.02219
G1 X74.531 Y89.096 E.24505
G1 X74.534 Y89.134 E.00197
G1 X85.796 Y77.872 E.83109
G1 X86.117 Y78.193 E.02368
G1 X74.599 Y89.711 E.85
G2 X74.68 Y90.271 I5.931 J-.577 E.02956
G1 X86.438 Y78.514 E.86766
G1 X86.758 Y78.835 E.02368
G1 X74.997 Y90.596 E.86798
G1 X75.318 Y90.917 E.02368
G1 X87.079 Y79.156 E.86798
G1 X87.4 Y79.477 E.02368
G1 X75.639 Y91.238 E.86798
G1 X75.959 Y91.559 E.02368
G1 X87.721 Y79.797 E.86798
G1 X88.042 Y80.118 E.02368
G1 X76.28 Y91.88 E.86798
G1 X76.601 Y92.201 E.02368
G1 X92.201 Y76.601 E1.15122
G1 X92.522 Y76.922 E.02368
G1 X76.922 Y92.522 E1.15122
G1 X77.243 Y92.843 E.02368
G1 X92.843 Y77.243 E1.15122
G1 X93.164 Y77.564 E.02368
G1 X77.564 Y93.164 E1.15122
G1 X77.648 Y93.248 E.00622
G1 X76.503 Y94.866 E.10343
G1 X93.485 Y77.885 E1.25316
G1 X93.805 Y78.206 E.02368
G1 X76.533 Y95.478 E1.27462
G2 X76.772 Y95.881 I4.118 J-2.161 E.02446
G1 X94.126 Y78.527 E1.28071
G1 X94.447 Y78.848 E.02368
G1 X77.021 Y96.274 E1.28601
G2 X77.282 Y96.655 I4.106 J-2.532 E.0241
G1 X94.768 Y79.168 E1.29044
G1 X95.089 Y79.489 E.02368
G1 X79.489 Y95.089 E1.15122
G1 X79.81 Y95.41 E.02368
G1 X95.41 Y79.81 E1.15122
G1 X95.731 Y80.131 E.02368
G1 X80.131 Y95.731 E1.15122
G1 X80.452 Y96.052 E.02368
G1 X99.89 Y76.614 E1.43445
G1 X100.211 Y76.935 E.02368
G1 X80.773 Y96.373 E1.43445
G1 X81.094 Y96.694 E.02368
G1 X100.532 Y77.256 E1.43445
G1 X100.852 Y77.577 E.02368
G1 X81.415 Y97.014 E1.43445
G1 X81.736 Y97.335 E.02368
G1 X101.173 Y77.898 E1.43445
G1 X101.494 Y78.219 E.02368
M73 P47 R11
G1 X82.057 Y97.656 E1.43445
G1 X82.377 Y97.977 E.02368
G1 X101.815 Y78.539 E1.43445
G1 X102.136 Y78.86 E.02368
G1 X82.698 Y98.298 E1.43445
G1 X83.019 Y98.619 E.02368
G1 X102.457 Y79.181 E1.43445
G1 X102.778 Y79.502 E.02368
G1 X87.178 Y95.102 E1.15122
G1 X87.499 Y95.423 E.02368
G1 X103.099 Y79.823 E1.15122
G1 X103.379 Y80.104 E.02072
G1 X103.458 Y80.106 E.0041
G1 X87.82 Y95.744 E1.15404
G1 X88.141 Y96.065 E.02368
G1 X103.723 Y80.482 E1.14995
G1 X103.938 Y80.909 E.02494
G1 X88.462 Y96.385 E1.14213
M73 P47 R10
G1 X88.783 Y96.706 E.02368
G1 X104.144 Y81.345 E1.1336
G1 X104.341 Y81.79 E.02539
G1 X89.104 Y97.027 E1.12446
G1 X89.424 Y97.348 E.02368
M73 P48 R10
G1 X104.52 Y82.253 E1.114
G3 X104.69 Y82.724 I-4.85 J2.022 E.02616
G1 X89.745 Y97.669 E1.10291
G1 X90.066 Y97.99 E.02368
G1 X104.85 Y83.206 E1.09102
G3 X104.991 Y83.707 I-4.906 J1.647 E.02718
G1 X90.387 Y98.311 E1.07771
G1 X90.708 Y98.632 E.02368
G1 X102.47 Y86.87 E.86798
G1 X102.791 Y87.191 E.02368
M73 C2
G1 X94.867 Y95.115 E.58475
G1 X95.188 Y95.436 E.02368
G1 X103.112 Y87.512 E.58475
G1 X103.432 Y87.833 E.02368
G1 X95.509 Y95.756 E.58475
G1 X95.83 Y96.077 E.02368
G1 X103.753 Y88.154 E.58475
G1 X104.074 Y88.475 E.02368
G1 X96.151 Y96.398 E.58475
G1 X96.471 Y96.719 E.02368
M73 P49 R10
G1 X104.395 Y88.795 E.58475
G1 X104.716 Y89.116 E.02368
G1 X96.792 Y97.04 E.58475
G1 X97.113 Y97.361 E.02368
G1 X105.037 Y89.437 E.58475
G1 X105.254 Y89.654 E.01599
G1 X105.405 Y89.684 E.00803
G1 X105.401 Y89.715 E.00165
G1 X97.434 Y97.682 E.58792
G1 X97.755 Y98.003 E.02368
G1 X105.285 Y90.473 E.55569
G3 X105.12 Y91.28 I-8.286 J-1.274 E.04299
G1 X97.933 Y98.467 E.5304
M106 S160.65
M204 S10000
G1 X96.364 Y101.935 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
; LAYER_HEIGHT: 0.2
G1 F8843.478
M204 S6000
G3 X94.846 Y102.522 I-6.476 J-14.477 E.054
G1 X91.325 Y99.001 E.16519
G1 X90.898 Y99.428 E.02003
G1 X89.573 Y98.103 E.06216
G1 X85.154 Y102.522 E.20733
G3 X80.187 Y99.813 I5.303 J-15.627 E.1886
M73 P50 R10
G1 X81.897 Y98.103 E.08022
G1 X83.242 Y99.448 E.06308
G1 X83.669 Y99.021 E.02003
G1 X87.79 Y103.142 E.19335
G3 X88.767 Y103.293 I.049 J2.91 E.03294
G3 X89.349 Y104.136 I-.538 J.995 E.03525
G1 X89.349 Y104.701 E.01875
G1 X90.063 Y105.414 E.03347
G3 X89.937 Y105.415 I-.063 J-.042 E.00492
G1 X90.65 Y104.702 E.03345
G3 X90.921 Y103.499 I1.536 J-.286 E.04205
G3 X91.378 Y103.249 I.725 J.781 E.01748
G1 X92.21 Y103.142 E.02781
G1 X97.249 Y98.103 E.23641
G1 X98.077 Y98.931 E.03885
G1 X98.504 Y98.504 E.02003
G1 X99.813 Y99.813 E.06139
G2 X103.369 Y95.693 I-9.977 J-12.208 E.18144
G1 X102.342 Y94.666 E.04818
G1 X103.494 Y93.515 E.05401
; CHANGE_LAYER
; Z_HEIGHT: 1.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X102.342 Y94.666 E-.61876
G1 X102.605 Y94.929 E-.14124
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 8/25
; update layer progress
M73 L8
M991 S0 P7 ;notify layer change
M106 S196.35
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z1.8 I-.738 J-.968 P1  F42000
G1 X84.285 Y108.899 Z1.8
G1 Z1.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X111.897 Y87.79 I5.787 J-21.115 E3.22945
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00904
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49733
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.111 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.892 J-21.493 E3.04525
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.118 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25112
G1 X82.491 Y108.737 E-.41561
G1 X82.262 Y108.649 E-.09327
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z2 F42000
G1 X94.195 Y109.433 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.848 J-.923 E.03357
G1 X93.721 Y111.457 E.02248
G3 X93.254 Y112.004 I-14.168 J-11.619 E.02385
G1 X92.776 Y112.419 E.021
G1 X92.353 Y112.695 E.01673
G1 X91.59 Y113.067 E.02818
M73 P51 R10
G1 X91.107 Y113.207 E.01669
G1 X90.268 Y113.343 E.02819
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.0282
G1 X88.443 Y113.071 E.0167
G1 X87.671 Y112.718 E.02815
G1 X87.256 Y112.433 E.01671
G1 X86.62 Y111.871 E.02816
G1 X86.305 Y111.478 E.01668
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.129 J-2.313 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X93.759 Y109.316 I3.838 J-21.967 E.25429
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.02431
G3 X92.976 Y111.726 I-6.431 J-5.119 E.01945
G3 X86.201 Y110.562 I-2.972 J-3.003 E.24675
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.787 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.156 E.23767
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05566
G1 X94.037 Y109.947 E-.06472
G1 X93.789 Y110.564 E-.25267
G1 X93.389 Y111.247 E-.3006
G1 X93.241 Y111.419 E-.08634
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.232 Y107.935 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X90.155 Y107.955 E.00266
G3 X89.833 Y107.955 I-.161 J-1.222 E.01071
G1 X89.426 Y107.808 E.01434
G1 X89.099 Y107.604 E.01279
G1 X88.663 Y107.159 E.02066
G3 X87.994 Y106.236 I7.976 J-6.491 E.03783
G3 X77.497 Y73.977 I2.008 J-18.491 E1.41662
G3 X87.998 Y69.263 I12.509 J13.814 E.38815
G3 X88.87 Y68.108 I6.49 J3.994 E.04808
G1 X89.328 Y67.733 E.01963
G1 X89.513 Y67.636 E.0069
G1 X89.97 Y67.527 E.0156
G1 X90.427 Y67.613 E.01542
G1 X90.901 Y67.896 E.0183
G1 X91.337 Y68.341 E.02068
G3 X92.007 Y69.264 I-7.983 J6.496 E.03783
G3 X92.007 Y106.236 I-2.005 J18.486 E1.80447
G3 X90.901 Y107.604 I-6.273 J-3.943 E.05847
G1 X90.428 Y107.887 E.01828
G1 X90.291 Y107.921 E.00468
M204 S250
G1 X90.064 Y107.554 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.758 Y107.541 E.00942
G1 X89.379 Y107.329 E.01335
G1 X88.943 Y106.884 E.01914
G3 X88.22 Y105.868 I9.244 J-7.341 E.03833
G3 X77.768 Y74.261 I1.784 J-18.122 E1.29058
G3 X88.222 Y69.631 I12.251 J13.549 E.3573
G1 X88.725 Y68.894 E.02745
G1 X89.171 Y68.36 E.02138
G1 X89.57 Y68.042 E.01568
G1 X89.966 Y67.92 E.01272
G1 X90.242 Y67.959 E.00859
G1 X90.621 Y68.171 E.01332
G1 X91.057 Y68.616 E.01915
G3 X91.78 Y69.632 I-9.252 J7.347 E.03833
G3 X91.78 Y105.868 I-1.781 J18.118 E1.64775
G3 X91.058 Y106.884 I-15.718 J-10.416 E.0383
G1 X90.621 Y107.329 E.01917
G1 X90.191 Y107.559 E.01497
G1 X90.124 Y107.556 E.00205
; WIPE_START
M204 S6000
G1 X89.758 Y107.541 E-.13931
G1 X89.379 Y107.329 E-.16505
G1 X88.943 Y106.884 E-.23666
G1 X88.599 Y106.422 E-.21897
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z2
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z2 F4000
            G39.3 S1
            G0 Z2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X91.715 Y107.334 F42000
G1 Z1.6
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.426075
G1 F9395.676
M204 S6000
G1 X91.944 Y106.974 E.0133
; LINE_WIDTH: 0.397305
G1 F10158.443
G1 X92.173 Y106.615 E.0123
M204 S10000
G1 X90.011 Y109.255 F42000
; LINE_WIDTH: 0.423524
G1 F9458.662
M204 S6000
G1 X89.504 Y109.243 E.01575
G1 X89.452 Y109.093 E.00494
G1 X89.242 Y108.956 E.00777
G3 X88.301 Y107.358 I12.152 J-8.231 E.05756
G1 X88.856 Y107.907 E.0242
G1 X89.379 Y108.227 E.01905
G1 X89.834 Y108.347 E.01457
G1 X90.388 Y108.314 E.01722
G1 X90.935 Y108.06 E.01871
G1 X91.184 Y107.875 E.00962
G1 X91.715 Y107.334 E.02352
G1 X91.699 Y107.357 E.00087
G3 X90.842 Y108.863 I-16.856 J-8.599 E.05375
G1 X90.628 Y109.063 E.00908
G1 X90.528 Y109.243 E.00639
G1 X90.071 Y109.254 E.01418
M204 S10000
G1 X89.795 Y108.798 F42000
; LINE_WIDTH: 0.57564
G1 F6757.772
M204 S6000
G1 X90.19 Y108.792 E.01715
M204 S10000
G1 X87.795 Y106.565 F42000
; LINE_WIDTH: 0.397325
G1 F10157.871
M204 S6000
G1 X88.027 Y106.929 E.01248
; LINE_WIDTH: 0.426135
G1 F9394.205
G1 X88.259 Y107.294 E.01349
; WIPE_START
G1 X88.027 Y106.929 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X85.941 Y111.57 Z2 F42000
G1 Z1.6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X85.245 Y110.107 I2.757 J-2.209 E.05424
G1 X85.165 Y110.187 E.00377
G2 X89.28 Y113.748 I4.85 J-1.447 E.19058
G3 X89.514 Y113.675 I.143 J.044 E.00957
G2 X90.619 Y113.647 I.456 J-3.814 E.03679
G1 X90.72 Y113.748 E.00475
G2 X94.835 Y110.187 I-.735 J-5.008 E.19058
G1 X94.755 Y110.107 E.00376
G3 X94.055 Y111.569 I-6.676 J-2.299 E.05387
; WIPE_START
G1 X94.391 Y111.03 E-.24113
G1 X94.755 Y110.107 E-.37699
G1 X94.835 Y110.187 E-.04309
G1 X94.744 Y110.431 E-.09879
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X93.171 Y106.425 Z2 F42000
G1 Z1.6
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X92.635 Y106.51 I-1.055 J-4.902 E.01801
G1 X92.106 Y107.458 E.03601
G1 X93.634 Y108.986 E.07169
G3 X94.045 Y108.983 I.215 J1.222 E.01368
G1 X98.197 Y104.831 E.19478
G2 X102.223 Y102.223 I-9.743 J-19.448 E.15944
G1 X104.068 Y104.068 E.08658
G2 X107.704 Y100.028 I-16.104 J-18.153 E.18067
G1 X105.831 Y98.155 E.08787
G2 X107.081 Y95.947 I-16.99 J-11.072 E.08424
G1 X111.151 Y91.876 E.19094
G3 X110.31 Y94.958 I-38.255 J-8.797 E.10598
G1 X108.234 Y92.882 E.09735
G2 X108.61 Y91.299 I-21.376 J-5.904 E.054
M204 S10000
G1 X111.53 Y86.877 F42000
G1 F8843.478
M204 S6000
G3 X111.533 Y88.505 I-16.638 J.843 E.05402
G1 X108.847 Y85.82 E.12599
G3 X108.898 Y86.454 I-6.446 J.832 E.02112
G1 X111.236 Y84.116 E.1097
G2 X109.676 Y78.972 I-23.891 J4.439 E.17866
G1 X98.778 Y68.074 E.51125
G2 X97.208 Y67.44 I-11.401 J25.994 E.05618
G1 X95.132 Y69.516 E.09735
G3 X100.405 Y71.919 I-5.169 J18.33 E.19297
G1 X102.278 Y70.046 E.08787
G3 X106.318 Y73.682 I-14.113 J19.74 E.18067
G1 X104.472 Y75.528 E.08658
G3 X107.405 Y80.271 I-14.542 J12.266 E.18566
G1 X109.368 Y78.308 E.09211
; WIPE_START
G1 X107.954 Y79.722 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X101.744 Y75.285 Z2 F42000
G1 X91.651 Y68.075 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.442425
G1 F9011.151
M204 S6000
G1 X91.912 Y68.48 E.01567
; LINE_WIDTH: 0.402755
G1 F10004.585
G1 X92.172 Y68.885 E.01412
M204 S10000
G1 X89.792 Y66.25 F42000
; LINE_WIDTH: 0.427431
G1 F9362.543
M204 S6000
G1 X90.496 Y66.257 E.02206
G1 X90.548 Y66.408 E.005
G1 X90.758 Y66.544 E.00784
G3 X91.651 Y68.075 I-10.184 J6.973 E.05558
G1 X91.144 Y67.593 E.02192
G1 X90.621 Y67.273 E.01921
G1 X90.275 Y67.164 E.01137
G1 X89.736 Y67.16 E.01691
G1 X89.208 Y67.345 E.01751
; LINE_WIDTH: 0.416395
G1 F9639.197
G1 X88.69 Y67.74 E.01982
G1 X88.143 Y68.382 E.02568
G3 X89.158 Y66.638 I46.149 J25.698 E.06141
G1 X89.371 Y66.438 E.00891
G1 X89.472 Y66.258 E.00627
G1 X89.732 Y66.252 E.00793
M204 S10000
G1 X89.746 Y66.702 F42000
; LINE_WIDTH: 0.56926
G1 F6839.685
M204 S6000
G1 X90.144 Y66.702 E.01709
M204 S10000
G1 X87.799 Y68.933 F42000
; LINE_WIDTH: 0.3907
G1 F10351.372
M204 S6000
G1 X88.11 Y68.432 E.01672
; WIPE_START
G1 X87.799 Y68.933 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X81.1 Y72.591 Z2 F42000
G1 X70.632 Y78.308 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X72.595 Y80.271 E.09209
G3 X75.527 Y75.527 I17.509 J7.545 E.18566
G1 X73.682 Y73.682 E.08658
G3 X77.722 Y70.046 I18.153 J16.105 E.18067
G1 X79.595 Y71.919 E.08787
G3 X84.868 Y69.516 I10.444 J15.932 E.19297
G1 X82.792 Y67.44 E.09735
G2 X81.222 Y68.074 I9.83 J26.627 E.05618
G1 X70.324 Y78.972 E.51125
G2 X68.764 Y84.116 I22.33 J9.583 E.17866
G1 X71.102 Y86.454 E.1097
G3 X71.153 Y85.82 I6.522 J.199 E.02112
G1 X68.467 Y88.505 E.12599
G3 X68.47 Y86.877 I16.64 J-.785 E.05402
M204 S10000
G1 X71.39 Y91.299 F42000
G1 F8843.478
M204 S6000
G2 X71.766 Y92.882 I20.438 J-4.007 E.054
G1 X69.69 Y94.958 E.09735
G3 X68.849 Y91.876 I37.421 J-11.88 E.10598
G1 X72.919 Y95.947 E.19094
G2 X74.169 Y98.155 I18.581 J-9.057 E.08424
G1 X72.296 Y100.028 E.08787
G2 X75.932 Y104.068 I19.741 J-14.113 E.18067
G1 X77.777 Y102.223 E.08658
G2 X81.803 Y104.831 I13.767 J-16.836 E.15944
G1 X85.955 Y108.983 E.19478
G3 X86.366 Y108.986 I.195 J1.227 E.01368
G1 X87.894 Y107.458 E.07169
G1 X87.365 Y106.51 E.03601
G3 X86.829 Y106.425 I.519 J-4.988 E.01801
M204 S10000
G1 X82.521 Y105.155 F42000
G1 F8843.478
M204 S6000
G1 X80.558 Y107.118 E.09209
G2 X82.047 Y107.775 I10.33 J-21.416 E.054
; WIPE_START
G1 X80.558 Y107.118 E-.6185
G1 X80.821 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.414 Y106.08 Z2 F42000
G1 X97.479 Y105.155 Z2
G1 Z1.6
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X99.442 Y107.118 E.09209
G3 X97.953 Y107.775 I-10.327 J-21.408 E.054
; WIPE_START
G1 X99.442 Y107.118 E-.6185
G1 X99.179 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.974 Y99.548 Z2 F42000
G1 X88.613 Y71.837 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X88.637 Y71.828 E.00084
G1 X88.82 Y71.599 E.00971
G1 X88.87 Y71.362 E.00803
G1 X88.87 Y70.637 E.02407
G3 X89.628 Y69.607 I7.467 J4.705 E.04244
G1 X89.998 Y69.308 E.01578
G1 X90.249 Y69.481 E.01012
G3 X91.13 Y70.637 I-5.701 J5.257 E.04828
G1 X91.13 Y71.362 E.02407
G1 X91.18 Y71.599 E.00803
G1 X91.278 Y71.749 E.00593
G1 X91.473 Y71.892 E.00804
G3 X93.486 Y72.244 I-9.508 J60.357 E.06777
G3 X105.888 Y88.142 I-3.49 J15.509 E.7245
G3 X91.635 Y103.562 I-15.882 J-.383 E.76096
G1 X91.363 Y103.672 E.00972
G1 X91.18 Y103.901 E.00971
G1 X91.13 Y104.138 E.00803
G1 X91.13 Y104.865 E.02413
G3 X90.253 Y106.005 I-8.108 J-5.331 E.04773
G1 X90 Y106.197 E.01055
G1 X89.723 Y105.988 E.01151
G3 X88.87 Y104.868 I5.614 J-5.156 E.04677
G1 X88.87 Y104.138 E.02421
G1 X88.82 Y103.901 E.00803
G1 X88.637 Y103.672 E.00971
G1 X88.37 Y103.563 E.00957
G3 X88.365 Y71.938 I1.629 J-15.813 E1.54814
G1 X88.558 Y71.86 E.00689
M204 S250
G1 X88.402 Y71.513 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X88.421 Y71.477 E.00125
G1 X88.439 Y71.44 E.00125
G1 X88.457 Y71.404 E.00125
G1 X88.475 Y71.367 E.00125
G1 X88.478 Y71.203 E.00504
G1 X88.478 Y71.019 E.00566
G1 X88.478 Y70.835 E.00566
G1 X88.478 Y70.65 E.00566
G1 X88.478 Y70.515 E.00416
G1 X88.518 Y70.457 E.00216
G1 X88.572 Y70.378 E.00294
G1 X88.626 Y70.3 E.00294
G1 X88.68 Y70.221 E.00294
G1 X88.734 Y70.142 E.00294
G1 X88.788 Y70.063 E.00294
G1 X88.842 Y69.985 E.00294
G1 X88.896 Y69.906 E.00294
G3 X88.991 Y69.776 I.938 J.586 E.00493
G1 X89.032 Y69.726 E.00199
G1 X89.072 Y69.675 E.00199
G1 X89.113 Y69.624 E.00199
G1 X89.153 Y69.574 E.00199
G1 X89.194 Y69.523 E.00199
G1 X89.234 Y69.472 E.00199
G1 X89.275 Y69.422 E.00199
G3 X89.322 Y69.369 I.22 J.152 E.00219
G1 X89.38 Y69.314 E.00244
G1 X89.437 Y69.259 E.00244
G1 X89.494 Y69.205 E.00244
G1 X89.552 Y69.15 E.00244
G1 X89.609 Y69.095 E.00244
G3 X89.684 Y69.043 I.13 J.109 E.00285
G1 X89.776 Y68.994 E.0032
G1 X89.868 Y68.945 E.0032
G1 X89.949 Y68.901 E.00283
G1 X90.142 Y68.937 E.00601
G1 X90.242 Y69.005 E.00373
G1 X90.342 Y69.074 E.00373
G1 X90.443 Y69.142 E.00373
G3 X90.53 Y69.206 I-.068 J.186 E.00338
G1 X90.57 Y69.254 E.00192
G1 X90.611 Y69.302 E.00192
G1 X90.651 Y69.349 E.00192
G1 X90.691 Y69.397 E.00192
G1 X90.731 Y69.445 E.00192
G1 X90.771 Y69.493 E.00192
G1 X90.811 Y69.541 E.00192
G1 X90.851 Y69.589 E.00192
G1 X90.891 Y69.637 E.00192
G1 X90.931 Y69.685 E.00192
G1 X90.971 Y69.733 E.00192
G1 X91.011 Y69.781 E.00192
G3 X91.105 Y69.908 I-.625 J.563 E.00485
G1 X91.159 Y69.986 E.00293
G1 X91.213 Y70.065 E.00293
G1 X91.267 Y70.143 E.00293
G1 X91.321 Y70.222 E.00293
G1 X91.375 Y70.3 E.00293
G1 X91.429 Y70.379 E.00293
G1 X91.483 Y70.458 E.00293
G1 X91.522 Y70.515 E.00214
G1 X91.522 Y70.65 E.00414
G1 X91.522 Y70.834 E.00567
G1 X91.522 Y71.019 E.00567
G1 X91.522 Y71.203 E.00567
G1 X91.525 Y71.367 E.00504
G1 X91.543 Y71.404 E.00125
G1 X91.561 Y71.44 E.00126
G1 X91.579 Y71.477 E.00126
G1 X91.598 Y71.513 E.00126
G3 X93.571 Y71.861 I-11.339 J70.115 E.06158
G3 X106.28 Y88.151 I-3.576 J15.892 E.68767
G3 X92.39 Y103.863 I-16.289 J-.404 E.70002
G1 X91.598 Y103.987 E.02464
G1 X91.58 Y104.023 E.00125
G1 X91.561 Y104.059 E.00125
G1 X91.543 Y104.096 E.00125
G1 X91.525 Y104.132 E.00125
G1 X91.522 Y104.291 E.00489
G1 X91.522 Y104.473 E.0056
G1 X91.522 Y104.655 E.0056
G1 X91.522 Y104.838 E.0056
G1 X91.522 Y104.986 E.00455
G1 X91.485 Y105.039 E.00199
G1 X91.44 Y105.105 E.00245
G1 X91.395 Y105.171 E.00245
G1 X91.35 Y105.237 E.00245
G1 X91.306 Y105.303 E.00245
G1 X91.261 Y105.369 E.00245
G1 X91.216 Y105.435 E.00245
G1 X91.171 Y105.501 E.00245
G1 X91.133 Y105.552 E.00195
G1 X91.076 Y105.625 E.00285
G1 X91.019 Y105.698 E.00285
G1 X90.963 Y105.771 E.00285
G1 X90.906 Y105.844 E.00285
G1 X90.849 Y105.918 E.00285
G1 X90.792 Y105.991 E.00285
G1 X90.735 Y106.064 E.00285
G3 X90.678 Y106.129 I-.242 J-.156 E.00268
G1 X90.619 Y106.185 E.00248
G1 X90.56 Y106.24 E.00248
G1 X90.502 Y106.296 E.00248
G1 X90.443 Y106.352 E.00248
G1 X90.384 Y106.407 E.00248
G3 X90.319 Y106.462 I-.117 J-.072 E.00268
G1 X90.208 Y106.515 E.00375
G1 X90.098 Y106.567 E.00375
G1 X90.055 Y106.587 E.00145
G1 X89.859 Y106.563 E.00607
G1 X89.758 Y106.494 E.00374
G1 X89.658 Y106.426 E.00374
G1 X89.557 Y106.358 E.00374
G3 X89.47 Y106.296 I.071 J-.191 E.00331
G1 X89.439 Y106.259 E.00148
G1 X89.407 Y106.223 E.00148
G1 X89.376 Y106.186 E.00148
G1 X89.344 Y106.15 E.00148
G1 X89.313 Y106.113 E.00148
G1 X89.282 Y106.077 E.00148
G1 X89.25 Y106.04 E.00148
G1 X89.219 Y106.004 E.00148
G1 X89.187 Y105.967 E.00148
G1 X89.156 Y105.931 E.00148
G1 X89.124 Y105.894 E.00148
G1 X89.093 Y105.857 E.00148
G3 X89.02 Y105.763 I.497 J-.459 E.00368
G1 X88.978 Y105.705 E.0022
G1 X88.936 Y105.646 E.0022
G1 X88.895 Y105.588 E.0022
G1 X88.853 Y105.53 E.0022
G1 X88.811 Y105.472 E.0022
G1 X88.77 Y105.414 E.0022
G1 X88.61 Y105.181 E.00868
G1 X88.478 Y104.986 E.00722
G1 X88.478 Y104.852 E.00414
G1 X88.478 Y104.667 E.00568
G1 X88.478 Y104.482 E.00568
G1 X88.478 Y104.297 E.00568
G1 X88.476 Y104.134 E.00503
G1 X88.465 Y104.103 E.001
G1 X88.453 Y104.073 E.001
G1 X88.442 Y104.043 E.001
G1 X88.43 Y104.012 E.001
G1 X88.317 Y103.951 E.00394
G3 X87.61 Y71.637 I1.687 J-16.202 E1.44665
G1 X88.343 Y71.523 E.02279
; WIPE_START
M204 S6000
G1 X88.421 Y71.477 E-.03422
G1 X88.439 Y71.44 E-.01552
G1 X88.457 Y71.404 E-.01552
G1 X88.475 Y71.367 E-.01552
G1 X88.478 Y71.203 E-.0623
G1 X88.478 Y71.019 E-.07005
G1 X88.478 Y70.835 E-.07005
M73 P52 R10
G1 X88.478 Y70.65 E-.07004
G1 X88.478 Y70.515 E-.05144
G1 X88.518 Y70.457 E-.02666
G1 X88.572 Y70.378 E-.03631
G1 X88.626 Y70.3 E-.03631
G1 X88.68 Y70.221 E-.03631
G1 X88.734 Y70.142 E-.03631
G1 X88.788 Y70.063 E-.03631
G1 X88.842 Y69.985 E-.03631
G1 X88.896 Y69.906 E-.03631
G1 X88.991 Y69.776 E-.06093
G1 X89.013 Y69.748 E-.01356
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X83.809 Y75.332 Z2 F42000
G1 X78.628 Y80.891 Z2
G1 Z1.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42211
G1 F9493.921
M204 S6000
G1 X78.379 Y81.14 E.01089
G1 X78.322 Y81.236 E.00345
G1 X78.31 Y81.745 E.01572
G1 X78.995 Y81.06 E.0299
G1 X79.531 Y81.06 E.01657
G1 X78.31 Y82.281 E.05333
G1 X78.31 Y82.817 E.01657
G1 X80.067 Y81.06 E.07677
G1 X80.603 Y81.06 E.01657
G1 X78.31 Y83.353 E.1002
G1 X78.31 Y83.89 E.01657
G1 X81.14 Y81.06 E.12363
G1 X81.676 Y81.06 E.01657
G1 X78.31 Y84.426 E.14707
G1 X78.31 Y84.962 E.01657
G1 X82.212 Y81.06 E.1705
G1 X82.748 Y81.06 E.01657
G1 X78.31 Y85.498 E.19393
G1 X78.31 Y86.035 E.01657
G1 X83.285 Y81.06 E.21737
G1 X83.821 Y81.06 E.01657
G1 X78.31 Y86.571 E.2408
G1 X78.31 Y87.107 E.01657
G1 X84.357 Y81.06 E.26423
G1 X84.893 Y81.06 E.01657
G1 X78.31 Y87.643 E.28767
G1 X78.31 Y88.18 E.01657
G1 X85.43 Y81.06 E.3111
G1 X85.966 Y81.06 E.01657
G1 X78.31 Y88.716 E.33453
G1 X78.31 Y89.252 E.01657
G1 X86.502 Y81.06 E.35797
G1 X87.038 Y81.06 E.01657
G1 X78.31 Y89.788 E.3814
G1 X78.31 Y90.325 E.01657
G1 X87.575 Y81.06 E.40483
G1 X88.111 Y81.06 E.01657
G1 X78.31 Y90.861 E.42827
G1 X78.31 Y91.397 E.01657
G1 X88.647 Y81.06 E.4517
G1 X89.183 Y81.06 E.01657
G1 X78.31 Y91.933 E.47513
G1 X78.31 Y92.47 E.01657
G1 X89.72 Y81.06 E.49857
G1 X90.256 Y81.06 E.01657
G1 X78.31 Y93.006 E.522
G1 X78.31 Y93.542 E.01657
G1 X90.792 Y81.06 E.54543
G1 X91.328 Y81.06 E.01657
G1 X78.31 Y94.078 E.56887
G2 X78.473 Y94.423 I.288 J.075 E.01277
G1 X78.497 Y94.428 E.00077
G1 X91.865 Y81.06 E.58414
G1 X92.401 Y81.06 E.01657
G1 X79.022 Y94.439 E.58461
G1 X79.559 Y94.439 E.01657
G1 X92.937 Y81.06 E.58461
G1 X93.473 Y81.06 E.01657
G1 X80.095 Y94.439 E.58461
G1 X80.631 Y94.439 E.01657
G1 X94.01 Y81.06 E.58461
G1 X94.546 Y81.06 E.01657
G1 X81.167 Y94.439 E.58461
G1 X81.704 Y94.439 E.01657
G1 X95.082 Y81.06 E.58461
G1 X95.618 Y81.06 E.01657
G1 X82.24 Y94.439 E.58461
G1 X82.776 Y94.439 E.01657
G1 X96.155 Y81.06 E.58461
G1 X96.691 Y81.06 E.01657
G1 X83.312 Y94.439 E.58461
G1 X83.849 Y94.439 E.01657
G1 X97.227 Y81.06 E.58461
G1 X97.763 Y81.06 E.01657
G1 X84.385 Y94.439 E.58461
G1 X84.921 Y94.439 E.01657
G1 X98.3 Y81.06 E.58461
G1 X98.836 Y81.06 E.01657
G1 X85.457 Y94.439 E.58461
G1 X85.994 Y94.439 E.01657
G1 X99.372 Y81.06 E.58461
G1 X99.908 Y81.06 E.01657
G1 X86.53 Y94.439 E.58461
G1 X87.066 Y94.439 E.01657
G1 X100.445 Y81.06 E.58461
G1 X100.981 Y81.06 E.01657
G1 X87.603 Y94.439 E.58461
G1 X88.139 Y94.439 E.01657
G1 X101.506 Y81.072 E.58411
G3 X101.62 Y81.137 I-.237 J.55 E.00406
G1 X101.674 Y81.225 E.00319
G1 X101.689 Y81.425 E.00621
G1 X88.675 Y94.439 E.56867
G1 X89.211 Y94.439 E.01657
G1 X101.689 Y81.961 E.54524
G1 X101.689 Y82.498 E.01657
G1 X89.748 Y94.439 E.52181
G1 X90.284 Y94.439 E.01657
G1 X101.689 Y83.034 E.49837
G1 X101.689 Y83.57 E.01657
G1 X90.82 Y94.439 E.47494
G1 X91.356 Y94.439 E.01657
G1 X101.689 Y84.106 E.45151
G1 X101.689 Y84.643 E.01657
G1 X91.893 Y94.439 E.42808
G1 X92.429 Y94.439 E.01657
G1 X101.689 Y85.179 E.40464
G1 X101.689 Y85.715 E.01657
G1 X92.965 Y94.439 E.38121
G1 X93.501 Y94.439 E.01657
G1 X101.689 Y86.251 E.35778
G1 X101.689 Y86.788 E.01657
G1 X94.038 Y94.439 E.33434
G1 X94.574 Y94.439 E.01657
G1 X101.689 Y87.324 E.31091
G1 X101.689 Y87.86 E.01657
G1 X95.11 Y94.439 E.28747
G1 X95.646 Y94.439 E.01657
G1 X101.689 Y88.396 E.26404
G1 X101.689 Y88.933 E.01657
G1 X96.183 Y94.439 E.24061
G1 X96.719 Y94.439 E.01657
G1 X101.689 Y89.469 E.21717
G1 X101.689 Y90.005 E.01657
G1 X97.255 Y94.439 E.19374
G1 X97.791 Y94.439 E.01657
G1 X101.689 Y90.541 E.17031
G1 X101.689 Y91.078 E.01657
G1 X98.328 Y94.439 E.14687
G1 X98.864 Y94.439 E.01657
G1 X101.689 Y91.614 E.12344
G1 X101.689 Y92.15 E.01657
G1 X99.4 Y94.439 E.10001
G1 X99.936 Y94.439 E.01657
G1 X101.689 Y92.686 E.07657
G1 X101.689 Y93.223 E.01657
G1 X100.473 Y94.439 E.05314
M73 P52 R9
G1 X101.009 Y94.439 E.01657
G1 X101.689 Y93.759 E.02971
G1 X101.689 Y94.189 E.01328
G1 X101.658 Y94.315 E.00403
G3 X101.375 Y94.608 I-1.171 J-.847 E.01263
M204 S10000
G1 X83.636 Y101.935 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X85.154 Y102.522 I6.476 J-14.477 E.054
G1 X92.845 Y94.831 E.36083
G1 X94.831 Y94.831 E.06587
G1 X99.813 Y99.813 E.23372
G2 X103.369 Y95.693 I-9.977 J-12.208 E.18144
G1 X102.054 Y94.378 E.0617
G2 X102.081 Y93.271 I-3.481 J-.638 E.03688
G1 X105.392 Y89.96 E.15533
G1 X105.383 Y90.031 E.00238
G1 X102.081 Y86.729 E.15491
G1 X102.081 Y85.595 E.03761
G1 X104.772 Y82.904 E.12627
G2 X103.988 Y80.96 I-25.925 J9.334 E.06953
G1 X96.79 Y73.762 E.33768
G2 X92.281 Y72.367 I-6.872 J14.228 E.15714
G1 X83.98 Y80.668 E.38943
G1 X80.668 Y80.668 E.10986
G1 X77.937 Y77.937 E.12812
G3 X82.057 Y74.381 I12.208 J9.977 E.18144
G1 X88.344 Y80.668 E.29495
G1 X91.656 Y80.668 E.10986
G1 X97.943 Y74.381 E.29495
G3 X102.063 Y77.937 I-8.088 J13.534 E.18144
G1 X99.332 Y80.668 E.12812
G1 X96.02 Y80.668 E.10986
G1 X87.719 Y72.367 E.38943
G2 X83.21 Y73.762 I2.364 J15.622 E.15714
G1 X76.012 Y80.96 E.33768
G2 X75.228 Y82.904 I25.145 J11.279 E.06953
G1 X77.918 Y85.594 E.12622
G1 X77.918 Y86.73 E.03767
G1 X74.617 Y90.031 E.15487
G1 X74.608 Y89.96 E.00238
G1 X77.918 Y93.27 E.15528
G2 X77.946 Y94.378 I3.216 J.472 E.03693
G1 X76.631 Y95.693 E.06172
G2 X80.187 Y99.813 I13.534 J-8.088 E.18144
G1 X85.169 Y94.831 E.23372
G1 X87.155 Y94.831 E.06587
G1 X94.846 Y102.522 E.36083
G2 X96.364 Y101.935 I-4.959 J-15.065 E.054
M204 S10000
G1 X81.107 Y94.831 F42000
G1 F8843.478
M204 S6000
G1 X79.479 Y94.831 E.05401
G1 X87.79 Y103.142 E.38991
G3 X88.984 Y103.523 I.137 J1.633 E.04264
G3 X89.216 Y104.568 I-1.228 J.821 E.03635
G1 X90.203 Y105.555 E.04632
G3 X89.986 Y105.764 I-1.271 J-1.11 E.01
G1 X89.802 Y105.55 E.00935
G1 X90.784 Y104.568 E.04606
G3 X91.156 Y103.394 I1.334 J-.223 E.04241
G3 X92.21 Y103.142 I.914 J1.494 E.03652
G1 X100.521 Y94.831 E.38991
G1 X98.893 Y94.831 E.05401
; CHANGE_LAYER
; Z_HEIGHT: 1.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X100.521 Y94.831 E-.61876
G1 X100.258 Y95.094 E-.14124
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 9/25
; update layer progress
M73 L9
M991 S0 P8 ;notify layer change
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z2 I-.796 J-.921 P1  F42000
G1 X84.285 Y108.899 Z2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X111.897 Y87.79 I5.787 J-21.115 E3.22945
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49733
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.111 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.892 J-21.493 E3.04525
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.118 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25112
G1 X82.491 Y108.737 E-.41561
G1 X82.262 Y108.649 E-.09327
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z2.2 F42000
G1 X94.196 Y109.433 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.851 J-.925 E.03357
G1 X93.721 Y111.457 E.02249
G1 X93.397 Y111.841 E.01666
G1 X92.776 Y112.419 E.02815
G1 X92.353 Y112.695 E.01673
G1 X91.524 Y113.092 E.0305
G1 X90.939 Y113.254 E.02014
G1 X90.268 Y113.343 E.02245
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.0282
G1 X88.443 Y113.071 E.0167
G1 X87.671 Y112.718 E.02815
G1 X87.256 Y112.433 E.01671
G1 X86.619 Y111.871 E.02816
G1 X86.305 Y111.478 E.01667
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.122 J-2.31 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X93.76 Y109.316 I3.838 J-21.909 E.2543
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
M73 P53 R9
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.02431
G3 X91.41 Y112.717 I-3.564 J-2.732 E.07674
G3 X86.201 Y110.562 I-1.408 J-3.972 E.18974
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.787 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.107 E.23768
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05566
G1 X94.037 Y109.947 E-.06473
G1 X93.789 Y110.564 E-.25268
G1 X93.389 Y111.247 E-.3006
G1 X93.241 Y111.419 E-.08633
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.565 Y108.157 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X90.476 Y108.22 E.00362
G3 X89.945 Y108.336 I-.505 J-1.032 E.01821
G1 X89.507 Y108.211 E.0151
G1 X89.312 Y108.094 E.00754
G1 X88.937 Y107.754 E.01679
G3 X87.87 Y106.224 I10.199 J-8.258 E.06192
G3 X77.508 Y73.967 I2.13 J-18.477 E1.41311
G3 X87.87 Y69.276 I12.51 J13.843 E.38341
G1 X88.177 Y68.786 E.01917
G3 X89.005 Y67.671 I6.206 J3.739 E.04614
G1 X89.417 Y67.333 E.0177
G1 X89.886 Y67.174 E.01641
G1 X90.264 Y67.199 E.01259
G1 X90.681 Y67.397 E.01529
G1 X91.17 Y67.868 E.02252
G3 X92.13 Y69.276 I-13.312 J10.115 E.05655
G3 X92.13 Y106.224 I-2.131 J18.474 E1.79629
G3 X91.377 Y107.37 I-16.414 J-9.978 E.0455
G1 X90.891 Y107.929 E.02456
G1 X90.614 Y108.123 E.01121
M204 S250
G1 X90.313 Y107.842 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X90.191 Y107.915 E.00436
G1 X89.895 Y107.933 E.0091
G1 X89.576 Y107.804 E.0106
G1 X89.201 Y107.464 E.01555
G3 X88.105 Y105.858 I12.205 J-9.507 E.05975
G3 X77.768 Y74.261 I1.901 J-18.112 E1.28707
G1 X77.771 Y74.257 E.00014
G3 X88.105 Y69.642 I12.259 J13.569 E.35358
G1 X88.507 Y68.998 E.02332
G3 X89.305 Y67.922 I5.849 J3.507 E.04121
G1 X89.698 Y67.629 E.01508
G1 X90.032 Y67.557 E.01048
G1 X90.26 Y67.608 E.00718
G1 X90.527 Y67.769 E.00957
G1 X90.893 Y68.146 E.01615
G3 X91.895 Y69.642 I-14.337 J10.683 E.05533
G3 X91.895 Y105.858 I-1.898 J18.108 E1.64073
G3 X91.055 Y107.146 I-16.95 J-10.137 E.04725
G1 X90.596 Y107.671 E.02141
G1 X90.364 Y107.811 E.00834
; WIPE_START
M204 S6000
G1 X90.191 Y107.915 E-.07678
G1 X89.895 Y107.933 E-.11254
G1 X89.576 Y107.804 E-.13107
G1 X89.201 Y107.464 E-.19232
G1 X88.806 Y106.946 E-.24729
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2.2 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z2.2
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z2.2 F4000
            G39.3 S1
            G0 Z2.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X87.23 Y106.493 F42000
G1 Z1.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X87.664 Y106.548 E.0145
G1 X87.999 Y107.064 E.02043
G1 X87.748 Y107.23 E.00996
G1 X87.881 Y107.471 E.00913
G1 X86.366 Y108.986 E.07109
G2 X85.955 Y108.983 I-.215 J1.222 E.01368
G1 X81.803 Y104.831 E.19477
G3 X77.777 Y102.223 I9.657 J-19.315 E.15946
G1 X75.932 Y104.068 E.08658
G3 X72.296 Y100.028 I16.105 J-18.153 E.18067
G1 X74.169 Y98.155 E.08787
G3 X72.919 Y95.947 I16.988 J-11.071 E.08424
G1 X68.849 Y91.876 E.19094
G2 X69.69 Y94.958 I38.263 J-8.799 E.10598
G1 X71.766 Y92.882 E.09735
M73 C1
G3 X71.39 Y91.299 I21.382 J-5.905 E.054
M204 S10000
G1 X68.47 Y86.877 F42000
G1 F8843.478
M204 S6000
G2 X68.467 Y88.505 I16.638 J.843 E.05402
G1 X71.153 Y85.82 E.12599
G2 X71.102 Y86.454 I6.471 J.834 E.02112
G1 X68.764 Y84.116 E.1097
G3 X70.324 Y78.972 I23.89 J4.439 E.17866
G1 X81.222 Y68.074 E.51125
G3 X82.792 Y67.44 I11.401 J25.993 E.05618
G1 X84.868 Y69.516 E.09736
G2 X79.595 Y71.919 I5.162 J18.316 E.19298
G1 X77.722 Y70.046 E.08787
G2 X73.682 Y73.682 I14.114 J19.741 E.18067
G1 X75.527 Y75.527 E.08658
G2 X72.595 Y80.271 I14.576 J12.289 E.18566
G1 X70.632 Y78.308 E.09209
; WIPE_START
G1 X72.046 Y79.722 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X78.541 Y75.713 Z2.2 F42000
G1 X91.516 Y67.703 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.38292
G1 F10588.235
M204 S6000
G1 X91.762 Y68.088 E.01265
M204 S10000
G1 X91.203 Y67.275 F42000
; LINE_WIDTH: 0.513258
G1 F7654.073
M204 S6000
G1 X90.87 Y66.67 E.02646
G2 X90.579 Y66.41 I-.765 J.564 E.01505
G1 X90.526 Y66.304 E.00454
G2 X89.434 Y66.31 I-.479 J12.478 E.04188
G1 X89.389 Y66.414 E.00436
; LINE_WIDTH: 0.50795
G1 F7741.436
G1 X89.294 Y66.478 E.00433
; LINE_WIDTH: 0.465648
G1 F8516.121
G1 X89.199 Y66.542 E.00394
G1 X88.714 Y67.377 E.03329
G1 X89.167 Y67.003 E.02027
; LINE_WIDTH: 0.47909
G1 F8253.663
G1 X89.409 Y66.89 E.00945
; LINE_WIDTH: 0.511876
G1 F7676.634
G1 X89.65 Y66.778 E.01017
G3 X90.379 Y66.777 I.365 J2.436 E.02796
G1 X90.686 Y66.895 E.01259
G1 X91.161 Y67.231 E.02223
; WIPE_START
G1 X90.686 Y66.895 E-.23169
G1 X90.379 Y66.777 E-.13124
G1 X89.998 Y66.751 E-.15181
G1 X89.65 Y66.778 E-.13932
G1 X89.409 Y66.89 E-.10594
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.205 Y68.14 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
; LINE_WIDTH: 0.38292
G1 F10588.235
M204 S6000
G1 X88.311 Y67.971 E.00553
; WIPE_START
G1 X88.205 Y68.14 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X95.085 Y71.446 Z2.2 F42000
G1 X109.368 Y78.308 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X107.405 Y80.271 E.09209
G2 X104.473 Y75.527 I-17.509 J7.545 E.18566
G1 X106.318 Y73.682 E.08658
G2 X102.278 Y70.046 I-18.153 J16.104 E.18067
G1 X100.405 Y71.919 E.08787
G2 X95.132 Y69.516 I-10.435 J15.913 E.19298
G1 X97.208 Y67.44 E.09736
G3 X98.778 Y68.074 I-9.831 J26.628 E.05618
G1 X109.676 Y78.972 E.51125
G3 X111.236 Y84.116 I-22.33 J9.583 E.17866
G1 X108.898 Y86.454 E.1097
G2 X108.847 Y85.82 I-6.497 J.197 E.02112
G1 X111.533 Y88.505 E.12599
G2 X111.53 Y86.877 I-16.64 J-.785 E.05402
M204 S10000
G1 X108.61 Y91.299 F42000
G1 F8843.478
M204 S6000
G3 X108.234 Y92.882 I-21.752 J-4.32 E.054
G1 X110.31 Y94.958 E.09735
G2 X111.151 Y91.876 I-37.413 J-11.878 E.10598
G1 X107.081 Y95.947 E.19094
G3 X105.831 Y98.155 I-18.24 J-8.864 E.08424
G1 X107.704 Y100.028 E.08787
G3 X104.068 Y104.068 I-19.74 J-14.113 E.18067
G1 X102.223 Y102.223 E.08658
G3 X98.197 Y104.831 I-13.683 J-16.707 E.15946
G1 X94.045 Y108.983 E.19477
G2 X93.634 Y108.986 I-.195 J1.226 E.01368
G1 X92.119 Y107.471 E.07111
G1 X92.243 Y107.245 E.00854
G1 X91.993 Y107.09 E.00976
G1 X92.337 Y106.548 E.02131
G1 X92.768 Y106.494 E.0144
M204 S10000
G1 X91.655 Y107.583 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.38292
G1 F10588.235
M204 S6000
G1 X91.761 Y107.414 E.00553
M204 S10000
G1 X91.182 Y108.257 F42000
; LINE_WIDTH: 0.508218
G1 F7736.979
M204 S6000
G1 X90.722 Y108.584 E.02143
G1 X90.347 Y108.731 E.01526
G1 X89.898 Y108.763 E.01705
G1 X89.612 Y108.698 E.01113
; LINE_WIDTH: 0.45673
G1 F8699.651
G1 X89.145 Y108.483 E.01734
G1 X88.667 Y108.057 E.02158
G2 X89.188 Y108.954 I13.633 J-7.309 E.03498
; LINE_WIDTH: 0.473755
G1 F8355.867
G1 X89.305 Y109.021 E.00474
; LINE_WIDTH: 0.510913
G1 F7692.429
G3 X89.474 Y109.195 I-.044 J.212 E.0098
G2 X90.568 Y109.194 I.538 J-10.271 E.04176
G3 X90.869 Y108.827 I1.082 J.58 E.01821
G1 X91.153 Y108.309 E.02251
; WIPE_START
G1 X90.869 Y108.827 E-.22431
G1 X90.68 Y109.021 E-.10294
G1 X90.568 Y109.194 E-.07819
G1 X89.984 Y109.217 E-.22202
G1 X89.636 Y109.202 E-.13253
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.197 Y107.341 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
; LINE_WIDTH: 0.396665
G1 F10176.823
M204 S6000
G1 X88.405 Y107.659 E.01098
; LINE_WIDTH: 0.424155
G1 F9442.995
G1 X88.614 Y107.978 E.01183
; WIPE_START
G1 X88.405 Y107.659 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X94.055 Y111.569 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X94.755 Y110.107 I-5.979 J-3.762 E.05387
G1 X94.835 Y110.187 E.00376
G3 X90.72 Y113.748 I-4.85 J-1.447 E.19058
G1 X90.619 Y113.647 E.00475
G3 X89.378 Y113.65 I-.635 J-5.584 E.04126
G1 X89.28 Y113.748 E.0046
G3 X85.165 Y110.187 I.735 J-5.008 E.19058
G1 X85.245 Y110.107 E.00377
G2 X85.941 Y111.57 I3.454 J-.746 E.05424
; WIPE_START
G1 X85.511 Y110.829 E-.32562
G1 X85.245 Y110.107 E-.29251
G1 X85.165 Y110.187 E-.04315
G1 X85.255 Y110.431 E-.09872
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X82.047 Y107.775 Z2.2 F42000
G1 Z1.8
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X80.558 Y107.118 I8.841 J-22.072 E.054
G1 X82.521 Y105.155 E.09209
; WIPE_START
G1 X81.107 Y106.569 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.72 Y107.114 Z2.2 F42000
G1 X97.953 Y107.775 Z2.2
G1 Z1.8
G1 E.8 F1800
G1 F8843.478
M204 S6000
G2 X99.442 Y107.118 I-8.838 J-22.065 E.054
G1 X97.479 Y105.155 E.09209
; WIPE_START
G1 X98.893 Y106.569 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.707 Y99.256 Z2.2 F42000
G1 X88.514 Y71.849 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X88.538 Y71.84 E.00086
G1 X88.721 Y71.611 E.00973
G1 X88.771 Y71.373 E.00804
G1 X88.77 Y70.623 E.0249
G3 X89.649 Y69.324 I14.24 J8.687 E.05204
G1 X90.004 Y68.969 E.01666
G3 X90.717 Y69.827 I-2.974 J3.195 E.03712
G1 X91.23 Y70.623 E.0314
G1 X91.229 Y71.373 E.0249
G1 X91.279 Y71.611 E.00804
G1 X91.376 Y71.761 E.00594
G1 X91.572 Y71.904 E.00806
G3 X93.486 Y72.244 I-13.68 J82.715 E.06448
G3 X105.888 Y88.142 I-3.49 J15.509 E.7245
G3 X91.733 Y103.55 I-15.878 J-.381 E.75765
G1 X91.462 Y103.66 E.00973
G1 X91.279 Y103.89 E.00973
G1 X91.229 Y104.127 E.00804
G1 X91.23 Y104.877 E.0249
G3 X90.385 Y106.132 I-14.552 J-8.896 E.05019
G1 X89.999 Y106.532 E.01842
G3 X89.29 Y105.684 I2.684 J-2.965 E.03679
G1 X88.77 Y104.877 E.03184
G1 X88.771 Y104.127 E.0249
G1 X88.721 Y103.889 E.00804
G1 X88.538 Y103.66 E.00973
G1 X88.271 Y103.55 E.00958
G3 X88.267 Y71.95 I1.726 J-15.8 E1.54148
G1 X88.459 Y71.872 E.00688
M204 S250
G1 X88.304 Y71.526 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X88.353 Y71.426 E.00341
G2 X88.379 Y71.298 I-.115 J-.09 E.00417
G1 X88.379 Y71.138 E.00493
G1 X88.379 Y70.977 E.00493
G1 X88.378 Y70.817 E.00493
G1 X88.378 Y70.656 E.00493
G1 X88.378 Y70.51 E.00449
G1 X88.429 Y70.428 E.00298
G1 X88.486 Y70.338 E.00327
G1 X88.542 Y70.248 E.00327
G1 X88.599 Y70.158 E.00327
G1 X88.656 Y70.068 E.00327
G3 X88.79 Y69.862 I4.417 J2.746 E.00755
G3 X89.141 Y69.355 I5.569 J3.472 E.01895
G1 X89.297 Y69.14 E.00816
G3 X89.354 Y69.069 I.352 J.221 E.00281
G1 X89.382 Y69.038 E.00127
G1 X89.41 Y69.008 E.00127
G1 X89.437 Y68.977 E.00127
G1 X89.465 Y68.947 E.00127
G1 X89.493 Y68.917 E.00127
G1 X89.521 Y68.886 E.00127
G1 X89.549 Y68.856 E.00127
G1 X89.577 Y68.825 E.00127
G1 X89.605 Y68.795 E.00127
G1 X89.632 Y68.764 E.00127
G3 X89.669 Y68.731 I.083 J.053 E.00154
G1 X89.743 Y68.682 E.00273
G1 X89.818 Y68.634 E.00273
G1 X89.893 Y68.586 E.00273
G1 X89.944 Y68.553 E.00188
G1 X90.046 Y68.577 E.00323
G3 X90.169 Y68.62 I.02 J.139 E.00415
G1 X90.238 Y68.681 E.00284
G1 X90.308 Y68.741 E.00284
G1 X90.378 Y68.802 E.00284
G1 X90.448 Y68.862 E.00284
G1 X90.517 Y68.922 E.00284
G3 X90.58 Y68.983 I-.105 J.171 E.00268
G1 X90.624 Y69.043 E.0023
G1 X90.669 Y69.103 E.00229
G1 X90.713 Y69.163 E.0023
G1 X90.758 Y69.223 E.0023
G1 X90.802 Y69.282 E.00229
G1 X90.847 Y69.342 E.00229
G1 X90.891 Y69.402 E.0023
G1 X90.936 Y69.462 E.0023
G1 X90.981 Y69.522 E.0023
G3 X91.218 Y69.875 I-3.058 J2.32 E.01307
G3 X91.346 Y70.071 I-4.134 J2.841 E.00719
G1 X91.403 Y70.16 E.00325
G1 X91.459 Y70.25 E.00325
G1 X91.515 Y70.339 E.00325
G1 X91.571 Y70.429 E.00325
G1 X91.622 Y70.51 E.00296
G1 X91.622 Y70.656 E.00449
G1 X91.622 Y70.817 E.00493
G1 X91.621 Y70.977 E.00493
G1 X91.621 Y71.138 E.00493
G1 X91.621 Y71.298 E.00493
G2 X91.647 Y71.426 I.141 J.038 E.00416
G1 X91.696 Y71.526 E.0034
G3 X93.571 Y71.861 I-19.696 J115.456 E.05853
G3 X106.28 Y88.151 I-3.576 J15.892 E.68767
G3 X92.39 Y103.863 I-16.289 J-.404 E.70002
G1 X91.696 Y103.974 E.02158
G1 X91.647 Y104.074 E.0034
G2 X91.621 Y104.202 I.115 J.09 E.00417
G1 X91.621 Y104.362 E.00493
G1 X91.621 Y104.523 E.00493
G1 X91.622 Y104.683 E.00493
G1 X91.622 Y104.844 E.00493
G1 X91.622 Y104.99 E.00449
G1 X91.571 Y105.072 E.00298
G1 X91.514 Y105.162 E.00327
G1 X91.458 Y105.252 E.00327
G1 X91.401 Y105.342 E.00327
G1 X91.344 Y105.433 E.00327
G3 X91.212 Y105.634 I-4.402 J-2.736 E.00741
G3 X90.703 Y106.363 I-11.518 J-7.516 E.02731
G1 X90.679 Y106.391 E.00115
G1 X90.654 Y106.42 E.00115
G1 X90.63 Y106.448 E.00115
G1 X90.605 Y106.477 E.00115
G1 X90.581 Y106.505 E.00115
G1 X90.557 Y106.534 E.00115
G1 X90.532 Y106.562 E.00115
G1 X90.508 Y106.591 E.00115
G1 X90.484 Y106.619 E.00115
G1 X90.459 Y106.648 E.00115
G1 X90.435 Y106.677 E.00115
G1 X90.411 Y106.705 E.00115
G3 X90.353 Y106.75 I-.108 J-.08 E.00228
G1 X90.265 Y106.808 E.00322
G1 X90.178 Y106.866 E.00322
G1 X90.091 Y106.924 E.00322
G1 X89.908 Y106.924 E.00561
G1 X89.827 Y106.872 E.00294
G1 X89.747 Y106.821 E.00294
G1 X89.666 Y106.769 E.00294
G3 X89.633 Y106.738 I.041 J-.075 E.00141
G1 X89.607 Y106.709 E.0012
G1 X89.581 Y106.679 E.0012
G1 X89.555 Y106.65 E.0012
G1 X89.529 Y106.621 E.0012
G1 X89.502 Y106.592 E.0012
G1 X89.476 Y106.563 E.0012
G1 X89.45 Y106.534 E.0012
G1 X89.424 Y106.505 E.0012
G1 X89.398 Y106.476 E.0012
G1 X89.371 Y106.447 E.0012
G1 X89.345 Y106.418 E.0012
G1 X89.319 Y106.389 E.0012
G1 X89.293 Y106.36 E.0012
G3 X88.791 Y105.64 I8.818 J-6.673 E.02698
G3 X88.656 Y105.433 I4.276 J-2.948 E.00759
G1 X88.599 Y105.343 E.00327
G1 X88.543 Y105.252 E.00327
G1 X88.486 Y105.162 E.00327
G1 X88.429 Y105.072 E.00327
G1 X88.378 Y104.99 E.00298
G1 X88.378 Y104.844 E.00449
G1 X88.378 Y104.683 E.00493
G1 X88.379 Y104.523 E.00493
G1 X88.379 Y104.362 E.00493
G1 X88.379 Y104.202 E.00493
G2 X88.363 Y104.082 I-.164 J-.038 E.00378
G1 X88.332 Y104 E.00271
G1 X88.219 Y103.939 E.00394
G3 X87.61 Y71.637 I1.785 J-16.19 E1.44357
G1 X88.244 Y71.535 E.01974
; WIPE_START
M204 S6000
G1 X88.353 Y71.426 E-.05843
G1 X88.379 Y71.374 E-.02219
G1 X88.379 Y71.298 E-.02885
G1 X88.379 Y71.138 E-.06097
G1 X88.379 Y70.977 E-.06097
G1 X88.378 Y70.817 E-.06097
G1 X88.378 Y70.656 E-.06097
G1 X88.378 Y70.51 E-.05553
G1 X88.429 Y70.428 E-.03683
G1 X88.486 Y70.338 E-.04044
G1 X88.542 Y70.248 E-.04045
G1 X88.599 Y70.158 E-.04045
G1 X88.656 Y70.068 E-.04044
G1 X88.79 Y69.862 E-.09342
G1 X88.879 Y69.734 E-.05907
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X94.56 Y74.83 Z2.2 F42000
G1 X101.858 Y81.377 Z2.2
G1 Z1.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42208
G1 F9494.672
M204 S6000
G1 X101.613 Y81.131 E.01074
G1 X101.523 Y81.075 E.00327
G1 X101.437 Y81.06 E.0027
G1 X101.006 Y81.06 E.01332
G1 X101.689 Y81.743 E.02985
G1 X101.689 Y82.28 E.01657
G1 X100.469 Y81.06 E.05328
G1 X99.933 Y81.06 E.01657
G1 X101.689 Y82.816 E.07671
G1 X101.689 Y83.352 E.01657
G1 X99.397 Y81.06 E.10014
G1 X98.861 Y81.06 E.01657
G1 X101.689 Y83.888 E.12357
G1 X101.689 Y84.424 E.01657
G1 X98.325 Y81.06 E.147
G1 X97.788 Y81.06 E.01657
G1 X101.689 Y84.961 E.17043
G1 X101.689 Y85.497 E.01657
G1 X97.252 Y81.06 E.19386
G1 X96.716 Y81.06 E.01657
G1 X101.689 Y86.033 E.21729
G1 X101.689 Y86.569 E.01657
G1 X96.18 Y81.06 E.24072
G1 X95.643 Y81.06 E.01657
G1 X101.689 Y87.106 E.26415
G1 X101.689 Y87.642 E.01657
G1 X95.107 Y81.06 E.28757
G1 X94.571 Y81.06 E.01657
G1 X101.689 Y88.178 E.311
G1 X101.689 Y88.714 E.01657
G1 X94.035 Y81.06 E.33443
G1 X93.499 Y81.06 E.01657
G1 X101.689 Y89.25 E.35786
G1 X101.689 Y89.787 E.01657
G1 X92.962 Y81.06 E.38129
G1 X92.426 Y81.06 E.01657
G1 X101.689 Y90.323 E.40472
G1 X101.689 Y90.859 E.01657
G1 X91.89 Y81.06 E.42815
G1 X91.354 Y81.06 E.01657
G1 X101.689 Y91.395 E.45158
G1 X101.689 Y91.931 E.01657
G1 X90.818 Y81.06 E.47501
G1 X90.281 Y81.06 E.01657
G1 X101.689 Y92.468 E.49844
G1 X101.689 Y93.004 E.01657
G1 X89.745 Y81.06 E.52187
G1 X89.209 Y81.06 E.01657
G1 X101.689 Y93.54 E.5453
G1 X101.689 Y94.076 E.01657
G1 X88.673 Y81.06 E.56873
G1 X88.137 Y81.06 E.01657
G1 X101.504 Y94.427 E.58407
G1 X100.979 Y94.439 E.01622
G1 X87.6 Y81.06 E.58457
G1 X87.064 Y81.06 E.01657
G1 X100.443 Y94.439 E.58457
G1 X99.906 Y94.439 E.01657
G1 X86.528 Y81.06 E.58457
G1 X85.992 Y81.06 E.01657
G1 X99.37 Y94.439 E.58457
G1 X98.834 Y94.439 E.01657
G1 X85.455 Y81.06 E.58457
G1 X84.919 Y81.06 E.01657
G1 X98.298 Y94.439 E.58457
G1 X97.762 Y94.439 E.01657
G1 X84.383 Y81.06 E.58457
G1 X83.847 Y81.06 E.01657
G1 X97.225 Y94.439 E.58457
G1 X96.689 Y94.439 E.01657
G1 X83.311 Y81.06 E.58457
G1 X82.774 Y81.06 E.01657
G1 X96.153 Y94.439 E.58457
M73 P54 R9
G1 X95.617 Y94.439 E.01657
G1 X82.238 Y81.06 E.58457
G1 X81.702 Y81.06 E.01657
G1 X95.08 Y94.439 E.58457
G1 X94.544 Y94.439 E.01657
G1 X81.166 Y81.06 E.58457
G1 X80.63 Y81.06 E.01657
G1 X94.008 Y94.439 E.58457
G1 X93.472 Y94.439 E.01657
G1 X80.093 Y81.06 E.58457
G1 X79.557 Y81.06 E.01657
G1 X92.936 Y94.439 E.58457
G1 X92.399 Y94.439 E.01657
G1 X79.021 Y81.06 E.58457
G1 X78.496 Y81.071 E.01623
G1 X91.863 Y94.439 E.58408
G1 X91.327 Y94.439 E.01657
G1 X78.31 Y81.422 E.56876
G1 X78.31 Y81.958 E.01657
G1 X90.791 Y94.439 E.54533
G1 X90.255 Y94.439 E.01657
G1 X78.31 Y82.494 E.5219
G1 X78.31 Y83.031 E.01657
G1 X89.718 Y94.439 E.49847
G1 X89.182 Y94.439 E.01657
G1 X78.31 Y83.567 E.47504
G1 X78.31 Y84.103 E.01657
G1 X88.646 Y94.439 E.45161
G1 X88.11 Y94.439 E.01657
G1 X78.31 Y84.639 E.42818
G1 X78.31 Y85.176 E.01657
G1 X87.573 Y94.439 E.40475
G1 X87.037 Y94.439 E.01657
G1 X78.31 Y85.712 E.38132
G1 X78.31 Y86.248 E.01657
G1 X86.501 Y94.439 E.35789
G1 X85.965 Y94.439 E.01657
G1 X78.31 Y86.784 E.33446
G1 X78.31 Y87.32 E.01657
G1 X85.429 Y94.439 E.31103
G1 X84.892 Y94.439 E.01657
G1 X78.31 Y87.857 E.2876
G1 X78.31 Y88.393 E.01657
G1 X84.356 Y94.439 E.26417
G1 X83.82 Y94.439 E.01657
G1 X78.31 Y88.929 E.24074
G1 X78.31 Y89.465 E.01657
G1 X83.284 Y94.439 E.21731
G1 X82.748 Y94.439 E.01657
G1 X78.31 Y90.001 E.19389
G1 X78.31 Y90.538 E.01657
G1 X82.211 Y94.439 E.17046
G1 X81.675 Y94.439 E.01657
G1 X78.31 Y91.074 E.14703
G1 X78.31 Y91.61 E.01657
G1 X81.139 Y94.439 E.1236
G1 X80.603 Y94.439 E.01657
G1 X78.31 Y92.146 E.10017
G1 X78.31 Y92.683 E.01657
G1 X80.066 Y94.439 E.07674
G1 X79.53 Y94.439 E.01657
G1 X78.31 Y93.219 E.05331
G1 X78.31 Y93.755 E.01657
G1 X78.994 Y94.439 E.02988
G1 X78.562 Y94.439 E.01334
G1 X78.476 Y94.424 E.00269
G1 X78.388 Y94.369 E.00321
G1 X78.141 Y94.121 E.01082
M204 S10000
G1 X96.364 Y101.935 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X94.846 Y102.522 I-6.476 J-14.477 E.054
G1 X87.155 Y94.831 E.36083
G1 X85.169 Y94.831 E.06587
G1 X80.187 Y99.813 E.23372
G3 X76.631 Y95.693 I9.977 J-12.208 E.18144
G1 X77.946 Y94.378 E.06172
G3 X77.918 Y93.27 I3.188 J-.635 E.03693
G1 X74.608 Y89.96 E.15528
G1 X74.617 Y90.031 E.00238
G1 X77.918 Y86.73 E.15487
G1 X77.918 Y85.594 E.03767
G1 X75.228 Y82.904 E.12622
G3 X76.012 Y80.96 I25.929 J9.336 E.06953
G1 X83.21 Y73.762 E.33768
G3 X87.719 Y72.367 I6.872 J14.228 E.15714
G1 X96.02 Y80.668 E.38943
G1 X99.332 Y80.668 E.10986
G1 X102.063 Y77.937 E.12812
G2 X97.943 Y74.381 I-12.208 J9.977 E.18144
G1 X91.656 Y80.668 E.29495
G1 X88.344 Y80.668 E.10986
G1 X82.057 Y74.381 E.29495
G2 X77.937 Y77.937 I8.088 J13.534 E.18144
G1 X80.668 Y80.668 E.12812
G1 X83.98 Y80.668 E.10986
G1 X92.281 Y72.367 E.38943
G3 X96.79 Y73.762 I-2.364 J15.623 E.15714
G1 X103.988 Y80.96 E.33768
G3 X104.772 Y82.904 I-25.141 J11.278 E.06953
G1 X102.081 Y85.595 E.12627
G1 X102.081 Y86.729 E.03761
G1 X105.383 Y90.031 E.15491
G1 X105.392 Y89.96 E.00238
G1 X102.081 Y93.271 E.15533
G3 X102.054 Y94.378 I-3.507 J.469 E.03688
G1 X103.369 Y95.693 E.0617
G3 X99.813 Y99.813 I-13.534 J-8.088 E.18144
G1 X94.831 Y94.831 E.23372
G1 X92.845 Y94.831 E.06587
G1 X85.154 Y102.522 E.36083
G3 X83.636 Y101.935 I4.959 J-15.065 E.054
M204 S10000
G1 X98.893 Y94.831 F42000
G1 F8843.478
M204 S6000
G1 X100.521 Y94.831 E.05401
G1 X92.21 Y103.142 E.38991
G2 X90.959 Y103.752 I-.137 J1.307 E.04863
G2 X90.883 Y104.469 I1.643 J.536 E.02409
G1 X89.696 Y105.656 E.05572
G2 X90 Y106.05 I2.37 J-1.519 E.01651
G2 X90.305 Y105.656 I-2.151 J-1.983 E.01652
G1 X89.117 Y104.469 E.05572
G2 X88.394 Y103.221 I-1.07 J-.213 E.05225
G1 X87.79 Y103.142 E.02019
G1 X79.479 Y94.831 E.38991
G1 X81.107 Y94.831 E.05401
; CHANGE_LAYER
; Z_HEIGHT: 2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X79.479 Y94.831 E-.61876
G1 X79.742 Y95.094 E-.14124
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 10/25
; update layer progress
M73 L10
M991 S0 P9 ;notify layer change
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z2.2 I-1.156 J.38 P1  F42000
G1 X84.285 Y108.899 Z2.2
G1 Z2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X93.514 Y66.142 I5.784 J-21.114 E2.20422
G3 X111.897 Y87.79 I-3.529 J21.626 E1.0249
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00904
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49733
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.111 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.892 J-21.493 E3.04525
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.119 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25112
G1 X82.491 Y108.737 E-.41561
G1 X82.262 Y108.649 E-.09327
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z2.4 F42000
G1 X94.195 Y109.433 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.848 J-.923 E.03357
G3 X93.713 Y111.469 I-14.572 J-8.646 E.02296
G1 X93.282 Y111.973 E.022
G1 X92.776 Y112.419 E.02239
G1 X92.353 Y112.695 E.01673
G1 X91.59 Y113.067 E.02818
G1 X91.107 Y113.207 E.01669
G1 X90.268 Y113.343 E.02819
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.0282
G1 X88.443 Y113.071 E.0167
G1 X87.671 Y112.718 E.02815
G1 X87.256 Y112.433 E.01671
G1 X86.62 Y111.871 E.02816
G1 X86.305 Y111.478 E.01668
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.127 J-2.312 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X93.759 Y109.316 I3.838 J-21.967 E.25429
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G3 X93.387 Y111.251 I-5.948 J-2.154 E.04486
G3 X86.201 Y110.562 I-3.386 J-2.51 E.26634
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.787 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.156 E.23767
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05566
G1 X94.037 Y109.947 E-.06472
G1 X93.789 Y110.564 E-.25267
G1 X93.387 Y111.251 E-.30236
G1 X93.242 Y111.419 E-.08458
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.633 Y108.444 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X90.519 Y108.541 E.00497
G3 X89.924 Y108.697 I-.559 J-.919 E.02072
G1 X89.504 Y108.558 E.01467
G1 X89.323 Y108.433 E.00728
G1 X88.967 Y108.067 E.01694
G3 X87.779 Y106.213 I15.703 J-11.373 E.07307
G3 X82.895 Y104.942 I2.15 J-18.271 E.16794
G3 X87.779 Y69.287 I7.104 J-17.189 E1.62259
G3 X88.969 Y67.427 I19.264 J11.02 E.07326
G1 X89.375 Y67.028 E.01887
G1 X89.646 Y66.883 E.0102
G1 X90.077 Y66.803 E.01453
G1 X90.318 Y66.862 E.00823
G1 X90.65 Y67.038 E.01246
G1 X91.11 Y67.531 E.02238
M73 P55 R9
G3 X92.221 Y69.287 I-18.052 J12.654 E.06894
G3 X92.221 Y106.213 I-2.217 J18.463 E1.79046
G3 X91.408 Y107.547 I-26.014 J-14.934 E.05181
G1 X90.926 Y108.194 E.02678
G1 X90.679 Y108.405 E.01076
M204 S250
G1 X90.355 Y108.152 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X90.196 Y108.27 E.0061
G1 X89.861 Y108.288 E.0103
G1 X89.604 Y108.159 E.00883
G1 X89.248 Y107.794 E.01569
G3 X88.02 Y105.848 I17.563 J-12.451 E.07074
G3 X83.036 Y104.576 I1.931 J-17.961 E.15857
G3 X88.02 Y69.652 I6.966 J-16.823 E1.477
G1 X88.373 Y69.047 E.02152
G3 X89.287 Y67.657 I10.581 J5.957 E.05117
G1 X89.649 Y67.308 E.01544
G1 X90.067 Y67.195 E.01329
G1 X90.412 Y67.349 E.01159
G1 X90.819 Y67.794 E.01856
G3 X91.98 Y69.652 I-20.091 J13.848 E.06733
G3 X91.98 Y105.848 I-1.976 J18.098 E1.63568
G3 X91.075 Y107.34 I-28.78 J-16.436 E.05363
G1 X90.612 Y107.959 E.02375
G1 X90.403 Y108.116 E.00802
; WIPE_START
M204 S6000
G1 X90.196 Y108.27 E-.09824
G1 X89.861 Y108.288 E-.1274
G1 X89.604 Y108.159 E-.10923
G1 X89.248 Y107.794 E-.19407
G1 X88.9 Y107.295 E-.23105
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2.4 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z2.4
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z2.4 F4000
            G39.3 S1
            G0 Z2.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X89.235 Y108.923 F42000
G1 Z2
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.58365
G1 F6657.667
M204 S6000
G1 X89.394 Y109.026 E.00835
; LINE_WIDTH: 0.624359
G1 F6191.539
G1 X89.553 Y109.129 E.00898
G1 X90 Y109.168 E.02128
; LINE_WIDTH: 0.61564
G1 F6285.794
G1 X90.256 Y109.141 E.01199
; LINE_WIDTH: 0.658
G1 F5852.897
G1 X90.511 Y109.113 E.01288
; LINE_WIDTH: 0.659955
G1 F5834.353
G1 X90.598 Y109.044 E.0056
; LINE_WIDTH: 0.621505
G1 F6222.077
G1 X90.685 Y108.974 E.00525
; LINE_WIDTH: 0.583055
G1 F6665.001
G1 X90.772 Y108.904 E.0049
; LINE_WIDTH: 0.544605
G1 F7175.818
G1 X90.859 Y108.835 E.00455
; LINE_WIDTH: 0.501637
G1 F7847.982
G1 X90.968 Y108.7 E.0065
; LINE_WIDTH: 0.45415
G1 F8754.225
G1 X91.078 Y108.565 E.00582
; LINE_WIDTH: 0.394982
G1 F10225.492
G2 X91.279 Y108.289 I-1.263 J-1.134 E.00982
M204 S10000
G1 X93.144 Y106.429 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X92.432 Y106.536 I-1.438 J-7.185 E.02392
G1 X91.958 Y107.31 E.0301
G1 X93.634 Y108.986 E.07862
G3 X94.045 Y108.983 I.215 J1.222 E.01368
G1 X98.197 Y104.831 E.19477
G2 X102.223 Y102.223 I-9.715 J-19.404 E.15945
G1 X104.068 Y104.068 E.08658
G2 X107.704 Y100.028 I-16.104 J-18.153 E.18067
G1 X105.831 Y98.155 E.08787
G2 X107.081 Y95.947 I-16.99 J-11.072 E.08424
G1 X111.151 Y91.876 E.19094
G3 X110.31 Y94.958 I-38.255 J-8.797 E.10598
G1 X108.234 Y92.882 E.09735
G2 X108.61 Y91.299 I-21.376 J-5.904 E.054
M204 S10000
G1 X111.53 Y86.877 F42000
G1 F8843.478
M204 S6000
G3 X111.533 Y88.505 I-16.638 J.843 E.05402
G1 X108.847 Y85.82 E.12599
G3 X108.898 Y86.454 I-6.446 J.832 E.02112
G1 X111.236 Y84.116 E.1097
G2 X109.676 Y78.972 I-23.891 J4.439 E.17866
G1 X98.778 Y68.074 E.51125
G2 X97.208 Y67.44 I-11.401 J25.994 E.05618
G1 X95.132 Y69.516 E.09737
G3 X100.405 Y71.919 I-5.161 J18.315 E.19298
G1 X102.278 Y70.046 E.08787
G3 X106.318 Y73.682 I-14.113 J19.74 E.18067
G1 X104.473 Y75.527 E.08658
G3 X107.405 Y80.271 I-14.576 J12.289 E.18566
G1 X109.368 Y78.308 E.09209
; WIPE_START
G1 X107.954 Y79.722 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X101.831 Y75.165 Z2.4 F42000
G1 X89.962 Y66.332 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.609515
G1 F6353.745
M204 S6000
G1 X90.215 Y66.354 E.01173
; LINE_WIDTH: 0.643985
G1 F5989.369
G1 X90.468 Y66.377 E.01245
; LINE_WIDTH: 0.636285
G1 F6067.092
G1 X90.592 Y66.46 E.00722
; LINE_WIDTH: 0.586415
G1 F6623.796
G1 X90.715 Y66.544 E.00661
; WIPE_START
G1 X90.592 Y66.46 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.687 Y67.262 Z2.4 F42000
G1 Z2
G1 E.8 F1800
; LINE_WIDTH: 0.400627
G1 F10064.112
M204 S6000
G1 X88.825 Y67.075 E.00677
; LINE_WIDTH: 0.43604
G1 F9157.51
G1 X88.963 Y66.888 E.00744
; LINE_WIDTH: 0.471454
G1 F8400.748
G1 X89.101 Y66.701 E.00811
; LINE_WIDTH: 0.512935
G1 F7659.33
G1 X89.186 Y66.632 E.00421
; LINE_WIDTH: 0.560485
G1 F6955.648
G1 X89.271 Y66.563 E.00463
; LINE_WIDTH: 0.608035
G1 F6370.385
G1 X89.357 Y66.494 E.00506
; LINE_WIDTH: 0.655585
G1 F5875.968
G1 X89.442 Y66.425 E.00549
; WIPE_START
G1 X89.357 Y66.494 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X82.902 Y70.566 Z2.4 F42000
G1 X70.632 Y78.308 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X72.595 Y80.271 E.09209
G3 X75.527 Y75.527 I17.509 J7.545 E.18566
G1 X73.682 Y73.682 E.08658
G3 X77.722 Y70.046 I18.153 J16.105 E.18067
G1 X79.595 Y71.919 E.08787
G3 X84.868 Y69.516 I10.433 J15.91 E.19298
G1 X82.792 Y67.44 E.09737
G2 X81.222 Y68.074 I9.83 J26.627 E.05618
G1 X70.324 Y78.972 E.51125
G2 X68.764 Y84.116 I22.33 J9.583 E.17866
G1 X71.102 Y86.454 E.1097
G3 X71.153 Y85.82 I6.522 J.199 E.02112
G1 X68.467 Y88.505 E.12599
G3 X68.47 Y86.877 I16.64 J-.785 E.05402
M204 S10000
G1 X71.39 Y91.299 F42000
G1 F8843.478
M204 S6000
G2 X71.766 Y92.882 I21.757 J-4.321 E.054
G1 X69.69 Y94.958 E.09735
G3 X68.849 Y91.876 I37.421 J-11.88 E.10598
G1 X72.919 Y95.947 E.19094
G2 X74.169 Y98.155 I18.238 J-8.863 E.08424
G1 X72.296 Y100.028 E.08787
G2 X75.932 Y104.068 I19.741 J-14.113 E.18067
G1 X77.777 Y102.223 E.08658
G2 X81.803 Y104.831 I13.738 J-16.791 E.15945
G1 X85.955 Y108.983 E.19477
G3 X86.366 Y108.986 I.195 J1.226 E.01368
G1 X88.038 Y107.314 E.07847
G1 X87.568 Y106.536 E.03014
G3 X86.857 Y106.43 I.723 J-7.267 E.02387
M204 S10000
G1 X82.521 Y105.155 F42000
G1 F8843.478
M204 S6000
G1 X80.558 Y107.118 E.09209
G2 X82.047 Y107.775 I10.33 J-21.416 E.054
; WIPE_START
G1 X80.558 Y107.118 E-.6185
G1 X80.821 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X85.941 Y111.57 Z2.4 F42000
G1 Z2
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X85.245 Y110.107 I2.757 J-2.209 E.05424
G1 X85.165 Y110.187 E.00377
G2 X89.28 Y113.748 I4.85 J-1.447 E.19058
G3 X89.514 Y113.675 I.143 J.044 E.00957
G2 X90.619 Y113.647 I.456 J-3.814 E.03679
G1 X90.72 Y113.748 E.00475
G2 X94.835 Y110.187 I-.735 J-5.008 E.19058
G1 X94.755 Y110.107 E.00376
G3 X94.055 Y111.569 I-6.676 J-2.299 E.05387
M204 S10000
G1 X97.479 Y105.155 F42000
G1 F8843.478
M204 S6000
G1 X99.442 Y107.118 E.09209
G3 X97.953 Y107.775 I-10.327 J-21.408 E.054
; WIPE_START
G1 X99.442 Y107.118 E-.6185
G1 X99.179 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.945 Y99.556 Z2.4 F42000
G1 X88.462 Y71.843 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X88.488 Y71.831 E.00095
G1 X88.656 Y71.6 E.00946
G1 X88.698 Y71.384 E.00732
G1 X88.698 Y70.611 E.02562
G3 X89.604 Y69.168 I23.071 J13.477 E.05655
G1 X89.997 Y68.667 E.02113
G1 X90.401 Y69.166 E.02129
G3 X91.302 Y70.611 I-26.169 J17.33 E.0565
G1 X91.302 Y71.384 E.02562
G2 X91.624 Y71.904 I.619 J-.024 E.02122
G2 X92.72 Y72.092 I1.855 J-7.517 E.03693
G3 X105.888 Y88.142 I-2.734 J15.67 E.75027
G3 X91.781 Y103.545 I-15.878 J-.381 E.75606
G1 X91.512 Y103.669 E.00983
G1 X91.344 Y103.9 E.00946
G1 X91.302 Y104.116 E.00732
G1 X91.302 Y104.889 E.02562
G3 X90.275 Y106.512 I-22.916 J-13.365 E.06373
G1 X90.001 Y106.837 E.01412
G3 X89.381 Y106.004 I3.292 J-3.094 E.03451
G3 X88.698 Y104.889 I32.086 J-20.428 E.04339
G1 X88.698 Y104.116 E.02562
G2 X88.424 Y103.623 I-.628 J.026 E.01941
G1 X88.197 Y103.541 E.00801
G3 X88.219 Y71.955 I1.8 J-15.792 E1.53738
G1 X88.408 Y71.868 E.0069
M204 S250
G1 X88.238 Y71.529 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G2 X88.306 Y71.204 I-.312 J-.235 E.01055
G1 X88.306 Y71.023 E.00554
G1 X88.306 Y70.843 E.00554
G1 X88.306 Y70.663 E.00554
G3 X88.383 Y70.374 I.278 J-.08 E.00965
G1 X88.47 Y70.23 E.00516
G1 X88.556 Y70.086 E.00516
G1 X88.643 Y69.943 E.00516
G3 X89.438 Y68.722 I41.543 J26.184 E.04475
G1 X89.462 Y68.693 E.00117
G1 X89.487 Y68.664 E.00117
G1 X89.512 Y68.635 E.00117
G1 X89.536 Y68.606 E.00117
G1 X89.561 Y68.576 E.00117
G1 X89.586 Y68.547 E.00117
G1 X89.611 Y68.518 E.00117
G1 X89.635 Y68.489 E.00117
G1 X89.66 Y68.46 E.00117
G1 X89.685 Y68.431 E.00117
G1 X89.709 Y68.401 E.00117
G1 X89.734 Y68.372 E.00117
G1 X89.759 Y68.343 E.00117
G1 X89.813 Y68.303 E.00208
G1 X89.871 Y68.262 E.00218
G1 X89.929 Y68.221 E.00218
G1 X89.947 Y68.209 E.00067
G1 X90.025 Y68.22 E.00242
G3 X90.133 Y68.27 I.018 J.103 E.00388
G1 X90.193 Y68.325 E.0025
G1 X90.252 Y68.38 E.0025
G1 X90.312 Y68.435 E.0025
G1 X90.372 Y68.49 E.0025
G3 X90.42 Y68.538 I-.106 J.152 E.00209
G1 X90.447 Y68.575 E.00142
G1 X90.475 Y68.612 E.00142
G1 X90.503 Y68.649 E.00142
G1 X90.53 Y68.686 E.00142
G1 X90.558 Y68.723 E.00142
G1 X90.586 Y68.76 E.00142
G1 X90.613 Y68.797 E.00142
G1 X90.641 Y68.834 E.00142
G1 X90.669 Y68.871 E.00142
G1 X90.697 Y68.908 E.00142
G1 X90.724 Y68.945 E.00142
G3 X91.357 Y69.943 I-18.041 J12.141 E.03631
G1 X91.444 Y70.087 E.00516
G1 X91.53 Y70.23 E.00516
G1 X91.617 Y70.374 E.00516
G3 X91.694 Y70.663 I-.201 J.209 E.00965
G1 X91.694 Y70.843 E.00554
G1 X91.694 Y71.023 E.00554
G1 X91.694 Y71.204 E.00554
G2 X91.762 Y71.529 I.38 J.09 E.01055
G1 X92.006 Y71.589 E.00771
G3 X106.28 Y88.151 I-2.01 J16.164 E.7365
G3 X92.006 Y103.911 I-16.284 J-.405 E.71182
G1 X91.762 Y103.971 E.00772
G2 X91.694 Y104.296 I.312 J.235 E.01055
G1 X91.694 Y104.477 E.00554
G1 X91.694 Y104.657 E.00554
G1 X91.694 Y104.837 E.00554
G3 X91.617 Y105.126 I-.278 J.08 E.00965
G1 X91.53 Y105.27 E.00516
G1 X91.444 Y105.414 E.00516
G1 X91.357 Y105.558 E.00516
G3 X90.554 Y106.792 I-43.317 J-27.304 E.04525
G1 X90.53 Y106.82 E.00112
G1 X90.507 Y106.848 E.00112
G1 X90.483 Y106.875 E.00112
G1 X90.459 Y106.903 E.00112
G1 X90.436 Y106.931 E.00112
G1 X90.412 Y106.959 E.00112
G1 X90.389 Y106.986 E.00112
G1 X90.365 Y107.014 E.00112
G1 X90.341 Y107.042 E.00112
G1 X90.318 Y107.07 E.00112
G1 X90.294 Y107.097 E.00112
G1 X90.271 Y107.125 E.00112
G1 X90.244 Y107.154 E.00122
G1 X90.189 Y107.198 E.00215
G1 X90.134 Y107.242 E.00215
G3 X90.04 Y107.279 I-.088 J-.088 E.0032
G3 X89.93 Y107.274 I-.053 J-.058 E.00375
G1 X89.863 Y107.235 E.0024
G1 X89.795 Y107.196 E.0024
G1 X89.766 Y107.166 E.00127
G1 X89.741 Y107.136 E.0012
G1 X89.715 Y107.107 E.0012
G1 X89.69 Y107.077 E.0012
G1 X89.664 Y107.047 E.0012
G1 X89.639 Y107.018 E.0012
G1 X89.613 Y106.988 E.0012
G1 X89.588 Y106.959 E.0012
G1 X89.562 Y106.929 E.0012
G1 X89.537 Y106.899 E.0012
G1 X89.511 Y106.87 E.0012
G1 X89.486 Y106.84 E.0012
G1 X89.46 Y106.81 E.0012
G3 X89.417 Y106.754 I.22 J-.214 E.00218
G3 X88.643 Y105.558 I18.65 J-12.907 E.04379
G1 X88.557 Y105.414 E.00517
G1 X88.47 Y105.27 E.00517
G1 X88.383 Y105.126 E.00517
G3 X88.306 Y104.837 I.201 J-.208 E.00965
G1 X88.306 Y104.657 E.00554
G1 X88.306 Y104.477 E.00554
G1 X88.306 Y104.297 E.00554
G2 X88.238 Y103.971 I-.38 J-.09 E.01055
G1 X87.994 Y103.911 E.00771
G3 X87.994 Y71.589 I2.012 J-16.161 E1.4481
G1 X88.179 Y71.543 E.00588
; WIPE_START
M204 S6000
G1 X88.306 Y71.384 E-.07736
G1 X88.306 Y71.204 E-.06847
G1 X88.306 Y71.023 E-.06847
G1 X88.306 Y70.843 E-.06847
G1 X88.306 Y70.663 E-.06847
G1 X88.306 Y70.502 E-.06101
G1 X88.383 Y70.374 E-.05687
G1 X88.47 Y70.23 E-.06383
G1 X88.556 Y70.086 E-.06383
G1 X88.643 Y69.943 E-.06383
G1 X88.781 Y69.72 E-.09941
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X83.647 Y75.368 Z2.4 F42000
G1 X78.628 Y80.891 Z2.4
G1 Z2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42211
G1 F9493.921
M204 S6000
G1 X78.379 Y81.14 E.01089
G1 X78.322 Y81.236 E.00345
G1 X78.31 Y81.745 E.01572
G1 X78.995 Y81.06 E.0299
G1 X79.531 Y81.06 E.01657
G1 X78.31 Y82.281 E.05333
G1 X78.31 Y82.817 E.01657
G1 X80.067 Y81.06 E.07677
G1 X80.603 Y81.06 E.01657
G1 X78.31 Y83.353 E.1002
G1 X78.31 Y83.89 E.01657
G1 X81.14 Y81.06 E.12363
G1 X81.676 Y81.06 E.01657
G1 X78.31 Y84.426 E.14707
G1 X78.31 Y84.962 E.01657
G1 X82.212 Y81.06 E.1705
G1 X82.748 Y81.06 E.01657
G1 X78.31 Y85.498 E.19393
G1 X78.31 Y86.035 E.01657
G1 X83.285 Y81.06 E.21737
G1 X83.821 Y81.06 E.01657
G1 X78.31 Y86.571 E.2408
G1 X78.31 Y87.107 E.01657
G1 X84.357 Y81.06 E.26423
G1 X84.893 Y81.06 E.01657
G1 X78.31 Y87.643 E.28767
G1 X78.31 Y88.18 E.01657
G1 X85.43 Y81.06 E.3111
G1 X85.966 Y81.06 E.01657
G1 X78.31 Y88.716 E.33453
G1 X78.31 Y89.252 E.01657
G1 X86.502 Y81.06 E.35797
G1 X87.038 Y81.06 E.01657
G1 X78.31 Y89.788 E.3814
G1 X78.31 Y90.325 E.01657
G1 X87.575 Y81.06 E.40483
G1 X88.111 Y81.06 E.01657
G1 X78.31 Y90.861 E.42827
G1 X78.31 Y91.397 E.01657
G1 X88.647 Y81.06 E.4517
G1 X89.183 Y81.06 E.01657
G1 X78.31 Y91.933 E.47513
G1 X78.31 Y92.47 E.01657
G1 X89.72 Y81.06 E.49857
G1 X90.256 Y81.06 E.01657
G1 X78.31 Y93.006 E.522
G1 X78.31 Y93.542 E.01657
G1 X90.792 Y81.06 E.54543
G1 X91.328 Y81.06 E.01657
G1 X78.31 Y94.078 E.56887
G2 X78.473 Y94.423 I.288 J.075 E.01277
G1 X78.497 Y94.428 E.00077
G1 X91.865 Y81.06 E.58414
G1 X92.401 Y81.06 E.01657
G1 X79.022 Y94.439 E.58461
G1 X79.559 Y94.439 E.01657
G1 X92.937 Y81.06 E.58461
G1 X93.473 Y81.06 E.01657
G1 X80.095 Y94.439 E.58461
G1 X80.631 Y94.439 E.01657
G1 X94.01 Y81.06 E.58461
G1 X94.546 Y81.06 E.01657
G1 X81.167 Y94.439 E.58461
G1 X81.704 Y94.439 E.01657
G1 X95.082 Y81.06 E.58461
G1 X95.618 Y81.06 E.01657
G1 X82.24 Y94.439 E.58461
G1 X82.776 Y94.439 E.01657
G1 X96.155 Y81.06 E.58461
G1 X96.691 Y81.06 E.01657
G1 X83.312 Y94.439 E.58461
G1 X83.849 Y94.439 E.01657
G1 X97.227 Y81.06 E.58461
G1 X97.763 Y81.06 E.01657
G1 X84.385 Y94.439 E.58461
G1 X84.921 Y94.439 E.01657
G1 X98.3 Y81.06 E.58461
G1 X98.836 Y81.06 E.01657
G1 X85.457 Y94.439 E.58461
G1 X85.994 Y94.439 E.01657
G1 X99.372 Y81.06 E.58461
G1 X99.908 Y81.06 E.01657
G1 X86.53 Y94.439 E.58461
G1 X87.066 Y94.439 E.01657
G1 X100.445 Y81.06 E.58461
G1 X100.981 Y81.06 E.01657
G1 X87.603 Y94.439 E.58461
G1 X88.139 Y94.439 E.01657
G1 X101.506 Y81.072 E.58411
G3 X101.62 Y81.137 I-.237 J.55 E.00406
G1 X101.674 Y81.225 E.00319
G1 X101.689 Y81.425 E.00621
G1 X88.675 Y94.439 E.56867
G1 X89.211 Y94.439 E.01657
G1 X101.689 Y81.961 E.54524
G1 X101.689 Y82.498 E.01657
G1 X89.748 Y94.439 E.52181
G1 X90.284 Y94.439 E.01657
G1 X101.689 Y83.034 E.49837
G1 X101.689 Y83.57 E.01657
G1 X90.82 Y94.439 E.47494
G1 X91.356 Y94.439 E.01657
G1 X101.689 Y84.106 E.45151
G1 X101.689 Y84.643 E.01657
G1 X91.893 Y94.439 E.42808
G1 X92.429 Y94.439 E.01657
M73 P56 R9
G1 X101.689 Y85.179 E.40464
G1 X101.689 Y85.715 E.01657
G1 X92.965 Y94.439 E.38121
G1 X93.501 Y94.439 E.01657
G1 X101.689 Y86.251 E.35778
G1 X101.689 Y86.788 E.01657
G1 X94.038 Y94.439 E.33434
G1 X94.574 Y94.439 E.01657
G1 X101.689 Y87.324 E.31091
G1 X101.689 Y87.86 E.01657
G1 X95.11 Y94.439 E.28747
G1 X95.646 Y94.439 E.01657
G1 X101.689 Y88.396 E.26404
G1 X101.689 Y88.933 E.01657
G1 X96.183 Y94.439 E.24061
G1 X96.719 Y94.439 E.01657
G1 X101.689 Y89.469 E.21717
G1 X101.689 Y90.005 E.01657
G1 X97.255 Y94.439 E.19374
G1 X97.791 Y94.439 E.01657
G1 X101.689 Y90.541 E.17031
G1 X101.689 Y91.078 E.01657
G1 X98.328 Y94.439 E.14687
G1 X98.864 Y94.439 E.01657
G1 X101.689 Y91.614 E.12344
G1 X101.689 Y92.15 E.01657
G1 X99.4 Y94.439 E.10001
G1 X99.936 Y94.439 E.01657
G1 X101.689 Y92.686 E.07657
G1 X101.689 Y93.223 E.01657
G1 X100.473 Y94.439 E.05314
G1 X101.009 Y94.439 E.01657
G1 X101.689 Y93.759 E.02971
G1 X101.689 Y94.189 E.01328
G1 X101.658 Y94.315 E.00403
G3 X101.375 Y94.608 I-1.171 J-.847 E.01263
M204 S10000
G1 X83.636 Y101.935 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X85.154 Y102.522 I6.476 J-14.477 E.054
G1 X92.845 Y94.831 E.36083
G1 X94.831 Y94.831 E.06587
G1 X99.813 Y99.813 E.23372
G2 X103.369 Y95.693 I-9.977 J-12.208 E.18144
G1 X102.054 Y94.378 E.0617
G2 X102.081 Y93.271 I-3.481 J-.638 E.03688
G1 X105.392 Y89.96 E.15533
G1 X105.383 Y90.031 E.00238
G1 X102.081 Y86.729 E.15491
G1 X102.081 Y85.595 E.03761
G1 X104.772 Y82.904 E.12627
G2 X103.988 Y80.96 I-25.925 J9.334 E.06953
G1 X96.79 Y73.762 E.33768
G2 X92.281 Y72.367 I-6.872 J14.227 E.15714
G1 X83.98 Y80.668 E.38943
G1 X80.668 Y80.668 E.10986
G1 X77.937 Y77.937 E.12812
G3 X82.057 Y74.381 I12.208 J9.977 E.18144
G1 X88.344 Y80.668 E.29495
G1 X91.656 Y80.668 E.10986
G1 X97.943 Y74.381 E.29495
G3 X102.063 Y77.937 I-8.088 J13.534 E.18144
G1 X99.332 Y80.668 E.12812
G1 X96.02 Y80.668 E.10986
G1 X87.719 Y72.367 E.38943
G2 X83.21 Y73.762 I2.363 J15.622 E.15714
G1 X76.012 Y80.96 E.33768
G2 X75.228 Y82.904 I25.145 J11.279 E.06953
G1 X77.918 Y85.594 E.12622
G1 X77.918 Y86.73 E.03767
G1 X74.617 Y90.031 E.15487
G1 X74.608 Y89.96 E.00238
G1 X77.918 Y93.27 E.15528
G2 X77.946 Y94.378 I3.216 J.472 E.03693
G1 X76.631 Y95.693 E.06172
G2 X80.187 Y99.813 I13.534 J-8.088 E.18144
G1 X85.169 Y94.831 E.23372
G1 X87.155 Y94.831 E.06587
G1 X94.846 Y102.522 E.36083
G2 X96.364 Y101.935 I-4.959 J-15.065 E.054
M204 S10000
G1 X81.107 Y94.831 F42000
G1 F8843.478
M204 S6000
G1 X79.479 Y94.831 E.05401
G1 X87.791 Y103.142 E.38991
G3 X88.98 Y103.773 I.11 J1.229 E.04723
G3 X89.044 Y104.396 I-1.579 J.477 E.02091
G1 X90.38 Y105.732 E.06266
G3 X90 Y106.3 I-6.515 J-3.937 E.02267
G3 X89.62 Y105.732 I5.952 J-4.393 E.02269
G1 X90.956 Y104.396 E.06267
G3 X92.209 Y103.142 I1.107 J-.147 E.06793
G1 X100.521 Y94.831 E.38991
G1 X98.893 Y94.831 E.05401
; CHANGE_LAYER
; Z_HEIGHT: 2.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X100.521 Y94.831 E-.61876
G1 X100.258 Y95.094 E-.14124
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 11/25
; update layer progress
M73 L11
M991 S0 P10 ;notify layer change
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z2.4 I-.796 J-.921 P1  F42000
G1 X84.285 Y108.899 Z2.4
G1 Z2.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X87.854 Y65.961 I5.786 J-21.115 E2.01589
G1 X88.659 Y65.902 E.02677
G1 X89.058 Y65.875 E.01327
; LINE_WIDTH: 0.496165
G1 F7942.725
G1 X89.532 Y65.887 E.01751
; LINE_WIDTH: 0.54234
G1 F7208.362
G2 X90.283 Y65.882 I.347 J-4.48 E.03058
; LINE_WIDTH: 0.496165
G1 F7942.725
G1 X90.559 Y65.866 E.01024
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X91.074 Y65.885 E.01709
G3 X111.897 Y87.79 I-1.084 J21.88 E1.1063
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49733
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.111 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.892 J-21.493 E3.04525
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.119 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25112
G1 X82.491 Y108.737 E-.41561
G1 X82.262 Y108.649 E-.09327
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z2.6 F42000
G1 X94.196 Y109.433 Z2.6
G1 Z2.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.85 J-.924 E.03357
G1 X93.721 Y111.457 E.02249
G1 X93.397 Y111.841 E.01666
G1 X92.776 Y112.419 E.02814
G3 X92.207 Y112.787 I-14.698 J-22.091 E.02248
G1 X91.59 Y113.067 E.02247
G1 X91.107 Y113.207 E.01669
G1 X90.268 Y113.343 E.02818
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.02818
G1 X88.443 Y113.071 E.01671
G1 X87.671 Y112.718 E.02815
G1 X87.256 Y112.433 E.01671
G1 X86.62 Y111.871 E.02816
G1 X86.305 Y111.478 E.01667
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.127 J-2.312 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X88.926 Y109.614 I3.971 J-23.319 E.09332
G1 X89.483 Y109.635 E.0185
; LINE_WIDTH: 0.494935
G1 F7964.338
G1 X89.739 Y109.619 E.00942
; LINE_WIDTH: 0.53988
G1 F7244.044
G3 X90.444 Y109.614 I.378 J3.933 E.0286
; LINE_WIDTH: 0.494935
G1 F7964.338
G1 X90.894 Y109.626 E.01658
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X91.293 Y109.599 E.01327
G1 X92.145 Y109.535 E.02836
G2 X93.759 Y109.316 I-2.32 J-23.188 E.05405
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.02431
G3 X91.997 Y112.456 I-3.753 J-2.915 E.05703
G3 X86.201 Y110.562 I-1.985 J-3.741 E.20917
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.787 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.157 E.23767
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05566
G1 X94.037 Y109.947 E-.06472
G1 X93.789 Y110.564 E-.25268
G1 X93.389 Y111.247 E-.3006
G1 X93.241 Y111.419 E-.08634
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.734 Y108.671 Z2.6 F42000
G1 Z2.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X90.563 Y108.849 E.0082
; LINE_WIDTH: 0.49858
G1 F7900.628
G1 X90.288 Y109.026 E.01215
; LINE_WIDTH: 0.53988
G1 F7244.044
G1 X89.988 Y109.106 E.01257
G1 X89.827 Y109.045 E.00696
; LINE_WIDTH: 0.494935
G1 F7964.338
G1 X89.667 Y108.984 E.00633
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X89.293 Y108.723 E.01511
G1 X88.952 Y108.292 E.01822
G3 X87.717 Y106.206 I32.695 J-20.777 E.08045
G3 X77.497 Y73.976 I2.287 J-18.46 E1.4074
G3 X87.717 Y69.294 I12.517 J13.827 E.37878
G3 X89.102 Y66.999 I22.498 J12.008 E.08897
G1 X89.407 Y66.673 E.01477
; LINE_WIDTH: 0.48074
G1 F8222.557
G1 X89.686 Y66.498 E.01176
; LINE_WIDTH: 0.51154
G1 F7682.131
G1 X89.852 Y66.448 E.00661
; LINE_WIDTH: 0.54234
G1 F7208.362
G1 X90.017 Y66.397 E.00705
G1 X90.191 Y66.462 E.00754
; LINE_WIDTH: 0.496165
G1 F7942.725
G1 X90.364 Y66.528 E.00684
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X90.707 Y66.777 E.01406
G1 X91.048 Y67.208 E.01823
G3 X92.284 Y69.294 I-33.378 J21.183 E.08045
G3 X92.283 Y106.206 I-2.279 J18.456 E1.78633
G3 X90.901 Y108.496 I-22.905 J-12.255 E.08878
G1 X90.775 Y108.627 E.00602
M204 S250
G1 X90.45 Y108.405 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X90.287 Y108.57 E.00715
G1 X89.966 Y108.67 E.0103
G1 X89.652 Y108.522 E.01068
G1 X89.297 Y108.101 E.01692
G3 X87.96 Y105.841 I33.37 J-21.261 E.08071
G3 X77.768 Y74.261 I2.044 J-18.095 E1.28255
G3 X87.96 Y69.659 I12.251 J13.548 E.34923
G1 X88.728 Y68.315 E.04758
G3 X89.427 Y67.219 I10.621 J5.999 E.03996
G1 X89.687 Y66.947 E.01156
G1 X90.048 Y66.835 E.0116
G1 X90.159 Y66.862 E.00353
G1 X90.401 Y67.023 E.00892
G1 X90.716 Y67.417 E.01549
G3 X92.04 Y69.659 I-35.095 J22.234 E.08004
G3 X92.04 Y105.841 I-2.035 J18.091 E1.63199
G3 X90.574 Y108.28 I-24.115 J-12.829 E.08747
G1 X90.492 Y108.362 E.00357
; WIPE_START
M204 S6000
G1 X90.287 Y108.57 E-.11122
G1 X89.966 Y108.67 E-.12732
G1 X89.652 Y108.522 E-.13209
G1 X89.297 Y108.101 E-.20925
G1 X89.044 Y107.7 E-.18011
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2.6 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z2.6
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z2.6 F4000
            G39.3 S1
            G0 Z2.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X86.85 Y106.428 F42000
G1 Z2.2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X87.502 Y106.528 I1.367 J-6.804 E.02189
G1 X87.985 Y107.367 E.03213
G1 X86.36 Y108.992 E.07621
G2 X85.956 Y108.984 I-.217 J.727 E.01358
G1 X81.803 Y104.831 E.19482
G3 X77.777 Y102.223 I9.712 J-19.4 E.15944
G1 X75.932 Y104.068 E.08658
G3 X72.296 Y100.029 I16.104 J-18.152 E.18067
G1 X74.169 Y98.155 E.08788
G3 X72.921 Y95.949 I16.776 J-10.945 E.08415
G1 X68.848 Y91.876 E.19104
G2 X69.69 Y94.958 I38.248 J-8.795 E.10599
G1 X71.766 Y92.882 E.09736
G3 X71.39 Y91.299 I20.64 J-5.727 E.054
M204 S10000
G1 X68.47 Y86.878 F42000
G1 F8843.478
M204 S6000
G2 X68.467 Y88.505 I16.638 J.843 E.05402
G1 X71.153 Y85.82 E.126
G2 X71.102 Y86.454 I6.465 J.833 E.02112
G1 X68.764 Y84.115 E.10971
G3 X70.324 Y78.972 I23.892 J4.44 E.17865
G1 X81.222 Y68.074 E.51127
G3 X82.792 Y67.44 I11.402 J25.996 E.05617
G1 X84.868 Y69.516 E.09738
G2 X79.595 Y71.919 I5.159 J18.312 E.19298
G1 X77.721 Y70.046 E.08788
G2 X73.682 Y73.682 I14.113 J19.741 E.18067
G1 X75.528 Y75.528 E.0866
G2 X72.595 Y80.271 I14.555 J12.277 E.18566
G1 X70.632 Y78.308 E.0921
; WIPE_START
M73 P57 R9
G1 X72.046 Y79.722 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X78.161 Y75.154 Z2.6 F42000
G1 X88.323 Y67.563 Z2.6
G1 Z2.2
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X89.338 Y66.31 I3.943 J2.158 E.05377
G2 X89.066 Y66.221 I-.184 J.1 E.01046
G2 X87.632 Y66.334 I.296 J13.006 E.04775
; WIPE_START
G1 X89.066 Y66.221 E-.54676
G1 X89.255 Y66.227 E-.07188
G1 X89.338 Y66.31 E-.04468
G1 X89.153 Y66.485 E-.09668
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X91.677 Y67.562 Z2.6 F42000
G1 Z2.2
G1 E.8 F1800
G1 F8843.478
M204 S6000
G2 X90.663 Y66.309 I-4.085 J2.269 E.05374
G1 X90.755 Y66.217 E.00433
G3 X92.379 Y66.335 I-2.404 J44.266 E.054
M204 S10000
G1 X109.368 Y78.308 F42000
G1 F8843.478
M204 S6000
G1 X107.405 Y80.271 E.0921
G2 X104.473 Y75.527 I-17.503 J7.541 E.18566
G1 X106.318 Y73.682 E.08658
G2 X102.279 Y70.046 I-18.153 J16.105 E.18067
G1 X100.405 Y71.919 E.08788
G2 X95.132 Y69.516 I-10.433 J15.911 E.19298
G1 X97.208 Y67.44 E.09738
G3 X98.778 Y68.074 I-9.838 J26.644 E.05617
G1 X109.676 Y78.972 E.51127
G3 X111.236 Y84.116 I-22.332 J9.583 E.17865
G1 X108.898 Y86.454 E.10971
G2 X108.847 Y85.82 I-6.508 J.198 E.02112
G1 X111.533 Y88.505 E.126
G2 X111.53 Y86.878 I-16.641 J-.785 E.05402
M204 S10000
G1 X108.61 Y91.299 F42000
G1 F8843.478
M204 S6000
G3 X108.234 Y92.882 I-20.433 J-4.006 E.054
G1 X110.31 Y94.958 E.09736
G2 X111.152 Y91.876 I-37.426 J-11.882 E.10599
G1 X107.079 Y95.949 E.19104
G3 X105.831 Y98.155 I-18.021 J-8.736 E.08415
G1 X107.704 Y100.029 E.08788
G3 X104.068 Y104.068 I-19.741 J-14.114 E.18067
G1 X102.223 Y102.223 E.08658
G3 X98.197 Y104.831 I-13.714 J-16.755 E.15944
G1 X94.044 Y108.984 E.19483
G2 X93.64 Y108.992 I-.187 J.735 E.01358
G1 X92.013 Y107.365 E.07632
G1 X92.497 Y106.528 E.03208
G2 X93.151 Y106.428 I-.716 J-6.913 E.02194
M204 S10000
G1 X97.953 Y107.775 F42000
G1 F8843.478
M204 S6000
G2 X99.442 Y107.118 I-8.837 J-22.063 E.054
G1 X97.479 Y105.155 E.0921
M204 S10000
M73 P57 R8
G1 X94.057 Y111.569 F42000
G1 F8843.478
M204 S6000
G2 X94.755 Y110.107 I-6.896 J-4.192 E.05385
G1 X94.836 Y110.187 E.00377
G3 X90.72 Y113.748 I-4.85 J-1.447 E.19058
G1 X90.616 Y113.643 E.00492
G3 X89.377 Y113.651 I-.651 J-5.061 E.0412
G1 X89.28 Y113.748 E.00455
G3 X85.164 Y110.187 I.735 J-5.008 E.19058
G1 X85.245 Y110.107 E.00378
G2 X85.946 Y111.567 I3.428 J-.748 E.05421
; WIPE_START
G1 X85.527 Y110.865 E-.31057
G1 X85.245 Y110.107 E-.3074
G1 X85.164 Y110.187 E-.04325
G1 X85.255 Y110.431 E-.09878
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X82.047 Y107.775 Z2.6 F42000
G1 Z2.2
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X80.558 Y107.118 I8.843 J-22.076 E.054
G1 X82.521 Y105.155 E.0921
; WIPE_START
G1 X81.107 Y106.569 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X82.703 Y99.105 Z2.6 F42000
G1 X88.606 Y71.501 Z2.6
G1 Z2.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X88.647 Y71.395 E.00379
G1 X88.647 Y70.606 E.02614
G3 X89.99 Y68.412 I26.049 J14.439 E.08537
G3 X90.606 Y69.333 I-5.342 J4.239 E.03678
G1 X91.353 Y70.606 E.04899
G1 X91.355 Y71.423 E.0271
G1 X91.494 Y71.768 E.01235
G1 X91.803 Y71.955 E.01194
G3 X100.73 Y76.021 I-1.917 J16.041 E.33063
G3 X105.896 Y87.802 I-10.777 J11.749 E.43923
G3 X91.807 Y103.545 I-15.906 J-.06 E.7664
G1 X91.492 Y103.733 E.01218
G1 X91.353 Y104.11 E.01332
G1 X91.353 Y104.894 E.026
G3 X90.001 Y107.073 I-20.259 J-11.065 E.08513
G3 X89.393 Y106.165 I5.896 J-4.597 E.03628
G1 X88.647 Y104.894 E.0489
G1 X88.647 Y104.11 E.02599
G1 X88.508 Y103.733 E.01332
G1 X88.197 Y103.545 E.01203
G1 X86.893 Y103.341 E.04379
G3 X88.193 Y71.955 I3.108 J-15.591 E1.49281
G1 X88.506 Y71.768 E.0121
G1 X88.585 Y71.558 E.00748
M204 S250
G1 X88.255 Y71.39 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X88.255 Y71.038 E.0108
G1 X88.255 Y70.687 E.0108
G1 X88.255 Y70.5 E.00575
G1 X88.423 Y70.212 E.01024
G1 X88.741 Y69.672 E.01926
G3 X89.364 Y68.64 I23.629 J13.558 E.03705
G1 X89.4 Y68.586 E.002
G1 X89.436 Y68.532 E.002
G1 X89.472 Y68.478 E.002
G1 X89.509 Y68.424 E.002
G1 X89.545 Y68.369 E.002
G1 X89.581 Y68.315 E.002
G1 X89.617 Y68.261 E.002
G1 X89.653 Y68.207 E.002
G1 X89.691 Y68.163 E.00178
G1 X89.728 Y68.12 E.00176
G1 X89.766 Y68.077 E.00176
G1 X89.804 Y68.034 E.00176
G1 X89.841 Y67.99 E.00176
G1 X89.879 Y67.947 E.00176
G1 X89.917 Y67.904 E.00176
G1 X89.948 Y67.868 E.00146
G1 X90.038 Y67.866 E.00276
G1 X90.073 Y67.903 E.00158
G1 X90.115 Y67.948 E.00187
G1 X90.156 Y67.992 E.00187
G1 X90.198 Y68.036 E.00187
G1 X90.24 Y68.081 E.00187
G1 X90.281 Y68.125 E.00187
G1 X90.323 Y68.17 E.00187
G3 X90.36 Y68.219 I-.125 J.132 E.0019
G1 X90.394 Y68.271 E.00191
G1 X90.429 Y68.322 E.00191
G1 X90.463 Y68.374 E.00191
G1 X90.497 Y68.426 E.00191
G1 X90.531 Y68.478 E.00191
G1 X90.566 Y68.529 E.00191
G1 X90.6 Y68.581 E.00191
G1 X90.634 Y68.633 E.00191
G3 X91.256 Y69.665 I-25.355 J15.96 E.03703
G1 X91.574 Y70.208 E.01933
G1 X91.745 Y70.5 E.0104
G1 X91.745 Y70.688 E.0058
G1 X91.745 Y71.039 E.01078
G1 X91.745 Y71.39 E.01078
G2 X91.901 Y71.576 I.189 J0 E.00809
G3 X106.28 Y88.151 I-1.905 J16.177 E.73976
G3 X92.012 Y103.91 I-16.285 J-.406 E.71162
G1 X91.814 Y103.965 E.00632
G1 X91.745 Y104.11 E.00494
G1 X91.745 Y104.461 E.01078
G1 X91.745 Y104.812 E.01078
G1 X91.745 Y105 E.0058
G1 X91.575 Y105.29 E.01031
G1 X91.26 Y105.828 E.01917
G3 X90.856 Y106.505 I-9.649 J-5.297 E.02422
G1 X90.798 Y106.593 E.00325
G1 X90.741 Y106.682 E.00325
G1 X90.684 Y106.771 E.00325
G1 X90.627 Y106.86 E.00325
G1 X90.569 Y106.949 E.00325
G1 X90.512 Y107.038 E.00325
G1 X90.455 Y107.127 E.00325
G1 X90.397 Y107.215 E.00325
G1 X90.34 Y107.304 E.00325
G3 X90.289 Y107.371 I-.183 J-.087 E.00258
G1 X90.245 Y107.415 E.00192
G1 X90.201 Y107.459 E.00192
G1 X90.157 Y107.504 E.00192
G1 X90.113 Y107.548 E.00192
G1 X90.069 Y107.593 E.00192
G1 X90.026 Y107.636 E.00189
G1 X89.912 Y107.606 E.00361
G1 X89.884 Y107.572 E.00135
G1 X89.857 Y107.538 E.00135
G1 X89.829 Y107.504 E.00135
G1 X89.801 Y107.47 E.00135
G1 X89.773 Y107.436 E.00135
G1 X89.745 Y107.402 E.00135
G1 X89.717 Y107.368 E.00135
G1 X89.689 Y107.334 E.00135
G1 X89.661 Y107.3 E.00135
G1 X89.633 Y107.266 E.00135
G1 X89.606 Y107.232 E.00135
G3 X89.533 Y107.121 I.412 J-.351 E.00408
G1 X89.42 Y106.943 E.00646
G1 X89.308 Y106.766 E.00645
G1 X89.196 Y106.588 E.00645
G3 X88.756 Y105.854 I10.945 J-7.049 E.02631
G1 X88.429 Y105.297 E.01985
G1 X88.255 Y105 E.01057
G1 X88.255 Y104.813 E.00575
G1 X88.255 Y104.462 E.0108
G1 X88.255 Y104.11 E.0108
G2 X88.099 Y103.924 I-.189 J0 E.00809
G3 X87.988 Y71.59 I1.907 J-16.174 E1.45117
G1 X88.186 Y71.535 E.00632
G1 X88.229 Y71.444 E.0031
; WIPE_START
M204 S6000
G1 X88.255 Y71.038 E-.15454
G1 X88.255 Y70.687 E-.13361
G1 X88.255 Y70.5 E-.07108
G1 X88.423 Y70.212 E-.12669
G1 X88.741 Y69.672 E-.23814
G1 X88.79 Y69.591 E-.03594
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.779 Y76.96 Z2.6 F42000
G1 X91.895 Y81.093 Z2.6
G1 Z2.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X101.452 Y81.093 E.31703
G1 X101.597 Y81.154 E.00522
G1 X101.656 Y81.297 E.00511
G1 X101.656 Y94.202 E.42807
G1 X101.597 Y94.345 E.00512
G1 X101.452 Y94.406 E.00522
G1 X78.547 Y94.406 E.75978
G1 X78.39 Y94.331 E.00576
G1 X78.343 Y94.202 E.00456
G1 X78.343 Y84.351 E.32676
G1 X78.343 Y81.297 E.10131
G1 X78.402 Y81.154 E.00511
G1 X78.547 Y81.093 E.00522
G1 X91.835 Y81.093 E.44077
M204 S10000
G1 X100.78 Y81.316 F42000
; FEATURE: Top surface
; LINE_WIDTH: 0.42
G1 F9547.055
M204 S2000
G1 X101.433 Y81.969 E.02839
G1 X101.433 Y82.503
G1 X100.246 Y81.316 E.05157
G1 X99.713 Y81.316
G1 X101.433 Y83.036 E.07474
G1 X101.433 Y83.569
G1 X99.18 Y81.316 E.09791
G1 X98.647 Y81.316
G1 X101.433 Y84.102 E.12109
G1 X101.433 Y84.636
G1 X98.113 Y81.316 E.14426
G1 X97.58 Y81.316
G1 X101.433 Y85.169 E.16743
G1 X101.433 Y85.702
G1 X97.047 Y81.316 E.1906
G1 X96.514 Y81.316
G1 X101.433 Y86.235 E.21378
G1 X101.433 Y86.769
G1 X95.98 Y81.316 E.23695
G1 X95.447 Y81.316
G1 X101.433 Y87.302 E.26012
G1 X101.433 Y87.835
G1 X94.914 Y81.316 E.28329
G1 X94.381 Y81.316
G1 X101.433 Y88.368 E.30647
G1 X101.433 Y88.902
G1 X93.847 Y81.316 E.32964
G1 X93.314 Y81.316
G1 X101.433 Y89.435 E.35281
G1 X101.433 Y89.968
G1 X92.781 Y81.316 E.37598
G1 X92.248 Y81.316
G1 X101.433 Y90.501 E.39916
G1 X101.433 Y91.035
G1 X91.714 Y81.316 E.42233
G1 X91.181 Y81.316
G1 X101.433 Y91.568 E.4455
G1 X101.433 Y92.101
G1 X90.648 Y81.316 E.46867
G1 X90.115 Y81.316
G1 X101.433 Y92.634 E.49185
G1 X101.433 Y93.168
G1 X89.581 Y81.316 E.51502
G1 X89.048 Y81.316
G1 X101.433 Y93.701 E.53819
G1 X101.382 Y94.183
G1 X88.515 Y81.316 E.55915
G1 X87.982 Y81.316
G1 X100.849 Y94.183 E.55915
G1 X100.316 Y94.183
G1 X87.448 Y81.316 E.55915
G1 X86.915 Y81.316
G1 X99.782 Y94.183 E.55915
G1 X99.249 Y94.183
G1 X86.382 Y81.316 E.55915
G1 X85.848 Y81.316
G1 X98.716 Y94.183 E.55915
G1 X98.183 Y94.183
G1 X85.315 Y81.316 E.55915
G1 X84.782 Y81.316
G1 X97.649 Y94.183 E.55915
G1 X97.116 Y94.183
G1 X84.249 Y81.316 E.55915
G1 X83.715 Y81.316
G1 X96.583 Y94.183 E.55915
G1 X96.049 Y94.183
G1 X83.182 Y81.316 E.55915
G1 X82.649 Y81.316
G1 X95.516 Y94.183 E.55915
G1 X94.983 Y94.183
G1 X82.116 Y81.316 E.55915
G1 X81.582 Y81.316
G1 X94.45 Y94.183 E.55915
G1 X93.916 Y94.183
G1 X81.049 Y81.316 E.55915
G1 X80.516 Y81.316
G1 X93.383 Y94.183 E.55915
G1 X92.85 Y94.183
G1 X79.983 Y81.316 E.55915
G1 X79.449 Y81.316
G1 X92.317 Y94.183 E.55915
G1 X91.783 Y94.183
G1 X78.916 Y81.316 E.55915
G1 X78.566 Y81.499
G1 X91.25 Y94.183 E.55119
G1 X90.717 Y94.183
G1 X78.566 Y82.032 E.52802
G1 X78.566 Y82.565
G1 X90.184 Y94.183 E.50485
G1 X89.65 Y94.183
G1 X78.566 Y83.099 E.48168
G1 X78.566 Y83.632
G1 X89.117 Y94.183 E.4585
G1 X88.584 Y94.183
G1 X78.566 Y84.165 E.43533
G1 X78.566 Y84.698
G1 X88.051 Y94.183 E.41216
G1 X87.517 Y94.183
G1 X78.566 Y85.232 E.38899
G1 X78.566 Y85.765
G1 X86.984 Y94.183 E.36581
G1 X86.451 Y94.183
G1 X78.566 Y86.298 E.34264
G1 X78.566 Y86.831
G1 X85.918 Y94.183 E.31947
M73 P58 R8
G1 X85.384 Y94.183
G1 X78.566 Y87.365 E.2963
G1 X78.566 Y87.898
G1 X84.851 Y94.183 E.27312
G1 X84.318 Y94.183
G1 X78.566 Y88.431 E.24995
G1 X78.566 Y88.964
G1 X83.785 Y94.183 E.22678
G1 X83.251 Y94.183
G1 X78.566 Y89.498 E.2036
G1 X78.566 Y90.031
G1 X82.718 Y94.183 E.18043
G1 X82.185 Y94.183
G1 X78.566 Y90.564 E.15726
G1 X78.566 Y91.097
G1 X81.652 Y94.183 E.13409
G1 X81.118 Y94.183
G1 X78.566 Y91.631 E.11091
G1 X78.566 Y92.164
G1 X80.585 Y94.183 E.08774
G1 X80.052 Y94.183
G1 X78.566 Y92.697 E.06457
G1 X78.566 Y93.231
G1 X79.518 Y94.183 E.0414
G1 X78.985 Y94.183
G1 X78.566 Y93.764 E.01822
; WIPE_START
M204 S6000
G1 X78.985 Y94.183 E-.22537
G1 X79.518 Y94.183 E-.20264
G1 X78.901 Y93.565 E-.33199
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X84.075 Y99.177 Z2.6 F42000
G1 X90.327 Y105.957 Z2.6
G1 Z2.2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X90.003 Y106.47 I-7.061 J-4.102 E.02013
G3 X89.57 Y105.782 I7.898 J-5.447 E.02698
G1 X91.011 Y104.341 E.06762
G1 X91.008 Y104.799 E.01521
G1 X90.43 Y105.782 E.03782
G1 X88.989 Y104.341 E.06761
G2 X87.778 Y103.129 I-1.097 J-.114 E.06506
G1 X79.4 Y94.751 E.39303
G1 X81.028 Y94.751 E.05401
M204 S10000
G1 X98.972 Y94.751 F42000
G1 F8843.478
M204 S6000
G1 X100.6 Y94.751 E.05401
G1 X92.221 Y103.131 E.39311
G2 X94.847 Y102.523 I-3.047 J-19.112 E.08949
G1 X87.075 Y94.751 E.36456
G1 X85.249 Y94.751 E.0606
G1 X80.187 Y99.813 E.23745
G3 X76.631 Y95.693 I9.977 J-12.208 E.18144
G1 X78.012 Y94.312 E.06481
G3 X77.998 Y93.349 I3.231 J-.531 E.03204
G1 X74.608 Y89.96 E.15901
G1 X74.617 Y90.031 E.00238
G1 X77.998 Y86.651 E.1586
G1 X77.998 Y85.674 E.03241
G1 X75.227 Y82.903 E.12995
G3 X76.012 Y80.96 I25.918 J9.332 E.06952
G1 X83.21 Y73.762 E.3377
G3 X87.729 Y72.377 I6.709 J13.825 E.15739
G1 X96.099 Y80.748 E.39269
G1 X99.252 Y80.748 E.10459
G1 X102.063 Y77.937 E.13185
G2 X97.943 Y74.381 I-12.208 J9.978 E.18144
G1 X91.576 Y80.748 E.29868
G1 X88.424 Y80.748 E.10459
G1 X82.057 Y74.381 E.29868
G2 X77.937 Y77.937 I8.088 J13.534 E.18144
G1 X80.748 Y80.748 E.13185
G1 X83.901 Y80.748 E.10459
G1 X92.27 Y72.378 E.39263
G3 X96.79 Y73.762 I-2.17 J15.161 E.15742
G1 X103.988 Y80.96 E.3377
G3 X104.773 Y82.903 I-25.14 J11.277 E.06952
G1 X102.001 Y85.675 E.13
G1 X102.001 Y86.65 E.03234
G1 X105.383 Y90.031 E.15864
G1 X105.392 Y89.96 E.00238
G1 X102.001 Y93.35 E.15906
G3 X101.987 Y94.311 I-3.242 J.431 E.03198
G1 X103.369 Y95.693 E.06485
G3 X99.813 Y99.813 I-13.533 J-8.088 E.18144
G1 X94.751 Y94.751 E.23745
G1 X92.925 Y94.751 E.0606
G1 X85.153 Y102.523 E.36456
G3 X83.636 Y101.935 I4.957 J-15.059 E.054
; CHANGE_LAYER
; Z_HEIGHT: 2.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X85.153 Y102.523 E-.61838
G1 X85.417 Y102.259 E-.14163
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 12/25
; update layer progress
M73 L12
M991 S0 P11 ;notify layer change
M106 S201.45
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z2.6 I-1.2 J-.205 P1  F42000
G1 X84.285 Y108.899 Z2.6
G1 Z2.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X87.877 Y65.956 I5.787 J-21.116 E2.01675
G1 X88.537 Y65.907 E.02192
G1 X88.935 Y65.878 E.01327
; LINE_WIDTH: 0.4891
G1 F8068.493
G2 X90.325 Y65.88 I1.787 J-1068.837 E.05053
; LINE_WIDTH: 0.48897
G1 F8070.844
G1 X91.075 Y65.879 E.02724
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X91.473 Y65.911 E.01327
G1 X92.354 Y65.981 E.02931
G3 X106.286 Y73.116 I-2.401 J21.859 E.53086
G3 X111.897 Y87.79 I-16.387 J14.675 E.53289
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49733
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.112 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X93.71 Y65.778 I5.888 J-21.491 E2.08245
G3 X112.289 Y87.8 I-3.724 J21.989 E.96247
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.119 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25113
G1 X82.491 Y108.737 E-.41561
G1 X82.262 Y108.649 E-.09326
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z2.8 F42000
G1 X94.195 Y109.433 Z2.8
G1 Z2.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G1 X94.337 Y110.288 E.01207
G1 X94.078 Y110.881 E.02147
G1 X93.721 Y111.457 E.02249
G1 X93.397 Y111.841 E.01666
G1 X92.776 Y112.419 E.02814
G1 X92.353 Y112.695 E.01673
G1 X91.59 Y113.067 E.02818
G1 X91.107 Y113.207 E.01669
G1 X90.268 Y113.343 E.02818
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.02818
G1 X88.443 Y113.071 E.01671
G1 X87.671 Y112.718 E.02815
G1 X87.256 Y112.433 E.01671
G1 X86.62 Y111.871 E.02816
G1 X86.305 Y111.478 E.01667
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.128 J-2.312 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X87.648 Y109.512 I4.633 J-28.65 E.05077
G1 X88.527 Y109.589 E.02927
G1 X88.925 Y109.621 E.01327
; LINE_WIDTH: 0.48897
G1 F8070.844
G1 X89.275 Y109.621 E.0127
G1 X89.675 Y109.62 E.01454
; LINE_WIDTH: 0.4891
G1 F8068.493
G3 X91.065 Y109.622 I-.397 J1068.875 E.05053
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X91.463 Y109.593 E.01327
G1 X92.122 Y109.539 E.02192
G2 X93.759 Y109.316 I-2.393 J-23.712 E.05483
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.965 Y110.164 E.00702
G3 X86.201 Y110.562 I-3.965 J-1.417 E.3044
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.788 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.157 E.23767
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05567
G1 X94.037 Y109.947 E-.06471
G1 X93.965 Y110.164 E-.08687
G1 X93.719 Y110.722 E-.23166
G1 X93.389 Y111.247 E-.23554
G1 X93.243 Y111.418 E-.08555
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.53 Y109.091 Z2.8 F42000
G1 Z2.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.49521
G1 F7959.495
M204 S6000
G1 X90.418 Y109.166 E.00496
G1 X89.7 Y109.175 E.02646
; LINE_WIDTH: 0.4891
G1 F8068.493
G1 X89.257 Y108.95 E.01807
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X89.049 Y108.608 E.01327
G1 X88.768 Y108.131 E.01835
G3 X87.68 Y106.201 I53.655 J-31.523 E.07351
G3 X84.6 Y105.551 I2.477 J-19.359 E.10452
G3 X87.68 Y69.299 I5.4 J-17.798 E1.67934
G3 X89.201 Y66.629 I49.568 J26.479 E.10196
G1 X89.257 Y66.55 E.00318
; LINE_WIDTH: 0.49521
G1 F7959.495
G1 X89.582 Y66.334 E.01437
G1 X90.3 Y66.325 E.02646
; LINE_WIDTH: 0.4891
G1 F8068.493
G1 X90.743 Y66.55 E.01807
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X90.951 Y66.892 E.01327
G1 X91.232 Y67.369 E.01835
G3 X92.32 Y69.299 I-53.62 J31.503 E.07351
G3 X92.32 Y106.201 I-2.316 J18.451 E1.78384
G3 X90.799 Y108.871 I-49.502 J-26.441 E.10196
G1 X90.743 Y108.95 E.00318
; LINE_WIDTH: 0.49521
G1 F7959.495
G1 X90.58 Y109.058 E.00721
M204 S250
G1 X90.307 Y108.759 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X90.3 Y108.763 E.00025
G1 X89.696 Y108.763 E.01855
G1 X89.541 Y108.674 E.00549
G3 X87.925 Y105.836 I71.372 J-42.5 E.10034
G3 X84.718 Y105.177 I1.935 J-17.547 E.10074
G1 X84.714 Y105.176 E.00014
G3 X87.925 Y69.664 I5.286 J-17.423 E1.5289
G3 X89.538 Y66.829 I57.372 J30.773 E.10022
G1 X89.7 Y66.737 E.00573
G1 X90.304 Y66.737 E.01855
G1 X90.459 Y66.826 E.00549
G3 X92.075 Y69.664 I-71.343 J42.483 E.10034
G3 X92.075 Y105.836 I-2.069 J18.086 E1.62981
G3 X90.462 Y108.671 I-57.343 J-30.757 E.10022
G1 X90.359 Y108.729 E.00363
; WIPE_START
M204 S6000
G1 X90.3 Y108.763 E-.02593
G1 X89.696 Y108.763 E-.22943
G1 X89.541 Y108.674 E-.06795
G1 X89.101 Y107.939 E-.32552
G1 X88.958 Y107.684 E-.11118
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z2.8 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z2.8
M73 P59 R8
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z2.8 F4000
            G39.3 S1
            G0 Z2.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X93.152 Y106.421 F42000
G1 Z2.4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X92.538 Y106.52 E.0206
G1 X92.048 Y107.4 E.03341
G1 X93.64 Y108.992 E.07468
G3 X94.044 Y108.984 I.217 J.727 E.01358
G1 X98.197 Y104.831 E.19483
G2 X102.223 Y102.223 I-9.689 J-19.363 E.15944
G1 X104.068 Y104.068 E.08658
G2 X107.704 Y100.029 I-16.104 J-18.153 E.18067
G1 X105.831 Y98.155 E.08788
G2 X107.079 Y95.949 I-16.773 J-10.943 E.08415
G1 X111.152 Y91.876 E.19104
G3 X110.31 Y94.958 I-38.265 J-8.799 E.10599
G1 X108.234 Y92.882 E.09736
G2 X108.61 Y91.299 I-20.058 J-5.59 E.054
M204 S10000
G1 X111.53 Y86.878 F42000
G1 F8843.478
M204 S6000
G3 X111.533 Y88.505 I-16.638 J.843 E.05402
G1 X108.847 Y85.82 E.126
G3 X108.898 Y86.454 I-6.458 J.833 E.02112
G1 X111.236 Y84.116 E.10971
G2 X109.676 Y78.972 I-23.892 J4.44 E.17865
G1 X98.778 Y68.074 E.51127
G2 X97.208 Y67.44 I-11.414 J26.027 E.05617
G1 X95.132 Y69.516 E.09738
G3 X100.405 Y71.919 I-5.16 J18.312 E.19298
G1 X102.279 Y70.046 E.08788
G3 X106.318 Y73.682 I-14.114 J19.741 E.18067
G1 X104.473 Y75.527 E.08658
G3 X107.404 Y80.272 I-14.561 J12.276 E.18567
G1 X109.368 Y78.308 E.09213
; WIPE_START
G1 X107.954 Y79.722 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.047 Y86.779 Z2.8 F42000
G1 X97.479 Y105.155 Z2.8
G1 Z2.4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X99.442 Y107.118 E.0921
G3 X97.953 Y107.775 I-10.326 J-21.407 E.054
; WIPE_START
G1 X99.442 Y107.118 E-.6185
G1 X99.179 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X91.989 Y109.415 Z2.8 F42000
G1 X85.946 Y111.567 Z2.8
G1 Z2.4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X85.245 Y110.107 I2.726 J-2.207 E.05421
G1 X85.164 Y110.187 E.00378
G2 X89.28 Y113.748 I4.85 J-1.447 E.19058
G3 X89.574 Y113.678 I.172 J.07 E.01171
G2 X90.619 Y113.647 I.411 J-3.724 E.0348
G1 X90.72 Y113.748 E.00475
G2 X94.836 Y110.187 I-.735 J-5.008 E.19058
G1 X94.755 Y110.107 E.00377
G3 X94.058 Y111.57 I-7.063 J-2.469 E.05386
; WIPE_START
G1 X94.364 Y111.083 E-.2186
G1 X94.755 Y110.107 E-.39946
G1 X94.836 Y110.187 E-.04317
G1 X94.745 Y110.431 E-.09876
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X87.737 Y107.406 Z2.8 F42000
G1 X82.521 Y105.155 Z2.8
G1 Z2.4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X80.558 Y107.118 E.0921
G2 X82.047 Y107.775 I10.332 J-21.419 E.054
; WIPE_START
G1 X80.558 Y107.118 E-.6185
G1 X80.821 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X76.864 Y100.328 Z2.8 F42000
G1 X71.39 Y91.299 Z2.8
G1 Z2.4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G2 X71.766 Y92.882 I20.468 J-4.014 E.054
G1 X69.69 Y94.958 E.09736
G3 X68.848 Y91.876 I37.406 J-11.876 E.10599
G1 X72.919 Y95.947 E.19096
G2 X74.169 Y98.155 I18.58 J-9.057 E.08423
G1 X72.296 Y100.029 E.08788
G2 X75.932 Y104.068 I19.74 J-14.113 E.18067
G1 X77.777 Y102.223 E.08658
G2 X81.803 Y104.831 I13.738 J-16.791 E.15944
G1 X85.956 Y108.984 E.19482
G3 X86.36 Y108.992 I.187 J.735 E.01358
G1 X87.952 Y107.4 E.07469
G1 X87.462 Y106.52 E.03341
G1 X86.848 Y106.421 E.0206
; WIPE_START
G1 X87.462 Y106.52 E-.23601
G1 X87.952 Y107.4 E-.38276
G1 X87.689 Y107.663 E-.14124
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X83.855 Y101.063 Z2.8 F42000
G1 X70.632 Y78.308 Z2.8
G1 Z2.4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X72.595 Y80.271 E.0921
G3 X75.527 Y75.527 I17.5 J7.539 E.18566
G1 X73.682 Y73.682 E.08658
G3 X77.721 Y70.046 I18.153 J16.104 E.18067
G1 X79.595 Y71.919 E.08788
G3 X84.868 Y69.516 I10.442 J15.926 E.19297
G1 X82.792 Y67.44 E.09736
G2 X81.222 Y68.074 I9.832 J26.63 E.05617
G1 X70.324 Y78.972 E.51127
G2 X68.764 Y84.115 I22.332 J9.583 E.17865
G1 X71.102 Y86.454 E.10971
G3 X71.153 Y85.82 I6.515 J.199 E.02112
G1 X68.467 Y88.505 E.126
G3 X68.47 Y86.878 I16.641 J-.785 E.05402
; WIPE_START
G1 X68.467 Y88.505 E-.61858
G1 X68.73 Y88.242 E-.14143
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X74.591 Y83.353 Z2.8 F42000
G1 X88.37 Y71.861 Z2.8
G1 Z2.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X88.394 Y71.85 E.00088
G1 X88.569 Y71.62 E.00958
G1 X88.615 Y71.394 E.00764
G1 X88.615 Y70.606 E.02614
G1 X89.61 Y68.871 E.06634
G3 X89.995 Y68.222 I15.389 J8.699 E.02504
G1 X90.281 Y68.681 E.01792
G1 X91.385 Y70.606 E.07361
G1 X91.385 Y71.394 E.02614
G1 X91.431 Y71.62 E.00764
G1 X91.606 Y71.85 E.00958
G1 X91.876 Y71.968 E.00979
G1 X93.107 Y72.159 E.04131
G3 X105.896 Y87.803 I-3.122 J15.602 E.72623
G3 X91.865 Y103.534 I-15.889 J-.049 E.76451
G1 X91.606 Y103.65 E.00943
G1 X91.431 Y103.88 E.00959
G1 X91.385 Y104.106 E.00764
G1 X91.385 Y104.894 E.02614
G1 X90.39 Y106.629 E.06634
G3 X90.002 Y107.282 I-15.497 J-8.761 E.0252
G1 X88.615 Y104.894 E.09162
G1 X88.615 Y104.106 E.02613
G1 X88.569 Y103.88 E.00764
G1 X88.394 Y103.65 E.00959
G1 X88.124 Y103.532 E.00979
G1 X86.893 Y103.341 E.04131
G3 X88.135 Y71.966 I3.108 J-15.589 E1.4907
G1 X88.315 Y71.885 E.00656
M204 S250
G1 X88.151 Y71.542 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X88.223 Y71.394 E.00505
G1 X88.223 Y70.501 E.02743
G1 X89.376 Y68.491 E.07122
G3 X89.887 Y67.66 I17.966 J10.475 E.02997
G1 X90.108 Y67.66 E.00678
G1 X90.617 Y68.48 E.02966
G1 X91.777 Y70.501 E.07161
G1 X91.777 Y71.394 E.02742
G2 X91.937 Y71.58 I.189 J0 E.00821
G1 X93.18 Y71.773 E.03866
G3 X106.288 Y87.813 I-3.195 J15.987 E.68967
G3 X92.39 Y103.863 I-16.301 J-.072 E.71046
G1 X91.849 Y103.958 E.01689
G1 X91.777 Y104.106 E.00505
G1 X91.777 Y104.999 E.02742
G1 X90.782 Y106.733 E.06145
G3 X90.113 Y107.84 I-21.632 J-12.32 E.03973
G1 X89.892 Y107.84 E.00681
G1 X89.521 Y107.256 E.02127
G1 X88.223 Y104.998 E.08
G1 X88.223 Y104.106 E.02742
G2 X88.063 Y103.92 I-.189 J0 E.00821
G1 X86.82 Y103.727 E.03866
G3 X87.61 Y71.637 I3.186 J-15.976 E1.40014
G1 X88.092 Y71.552 E.01504
; WIPE_START
M204 S6000
G1 X88.223 Y71.394 E-.07803
G1 X88.223 Y70.501 E-.33919
G1 X88.672 Y69.719 E-.34278
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X85.767 Y76.777 Z2.8 F42000
G1 X78.596 Y94.196 Z2.8
G1 Z2.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X78.527 Y94.142 E.0029
G1 X78.448 Y94.017 E.00492
G1 X78.395 Y93.773 E.00826
G1 X78.395 Y81.726 E.39964
G1 X78.47 Y81.44 E.00981
G1 X78.568 Y81.312 E.00534
G1 X78.732 Y81.199 E.0066
G1 X78.976 Y81.145 E.00828
G1 X100.976 Y81.145 E.72976
G3 X101.267 Y81.199 I.024 J.689 E.00992
G1 X101.431 Y81.312 E.0066
G1 X101.579 Y81.558 E.00953
G1 X101.604 Y82.279 E.02394
G1 X101.604 Y93.773 E.38127
G1 X101.529 Y94.059 E.00981
G3 X101.267 Y94.3 I-.505 J-.286 E.01199
G1 X101.023 Y94.354 E.00828
G1 X79.023 Y94.354 E.72976
G3 X78.732 Y94.301 I-.024 J-.69 E.00991
G1 X78.644 Y94.232 E.00369
M204 S250
G1 X78.83 Y93.893 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X78.787 Y93.773 E.00391
G1 X78.787 Y81.773 E.36872
G3 X78.843 Y81.591 I.246 J-.024 E.00602
G1 X78.976 Y81.537 E.00439
G1 X100.976 Y81.537 E.67598
G3 X101.156 Y81.591 I.024 J.247 E.00593
G1 X101.212 Y81.726 E.00447
G1 X101.212 Y93.726 E.36872
G3 X101.156 Y93.908 I-.246 J.024 E.00602
G1 X101.023 Y93.962 E.00439
G1 X78.976 Y93.962 E.67745
G1 X78.884 Y93.919 E.0031
; WIPE_START
M204 S6000
G1 X78.787 Y93.773 E-.06647
G1 X78.787 Y91.948 E-.69353
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X80.976 Y94.7 Z2.8 F42000
G1 Z2.4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X79.348 Y94.7 E.05401
G1 X87.776 Y103.128 E.39539
G3 X88.961 Y104.313 I.115 J1.07 E.06369
G1 X90.458 Y105.81 E.07024
G1 X91.039 Y104.802 E.0386
G1 X91.039 Y104.313 E.01622
G1 X89.541 Y105.811 E.07026
G1 X89.999 Y106.607 E.03048
G1 X90.353 Y105.992 E.02354
; WIPE_START
G1 X89.999 Y106.607 E-.26964
G1 X89.541 Y105.811 E-.34912
G1 X89.804 Y105.548 E-.14124
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X94.747 Y99.732 Z2.8 F42000
G1 X99.024 Y94.7 Z2.8
G1 Z2.4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X100.652 Y94.7 E.05401
G1 X92.221 Y103.131 E.39553
G2 X94.847 Y102.523 I-3.051 J-19.126 E.08949
G1 X87.024 Y94.7 E.36697
G1 X85.3 Y94.7 E.05719
G1 X80.187 Y99.813 E.23986
G3 X76.631 Y95.693 I9.977 J-12.208 E.18144
G1 X78.144 Y94.18 E.07097
G3 X78.049 Y93.401 I2.028 J-.642 E.02619
G1 X74.608 Y89.96 E.16143
G1 X74.617 Y90.031 E.00238
G1 X78.049 Y86.599 E.16101
G1 X78.049 Y85.725 E.02899
G1 X75.227 Y82.903 E.13237
G3 X76.012 Y80.96 I25.948 J9.343 E.06952
G1 X83.21 Y73.762 E.33771
G3 X87.729 Y72.377 I6.71 J13.827 E.15739
G1 X96.151 Y80.799 E.39511
G1 X99.201 Y80.799 E.10117
G1 X102.063 Y77.937 E.13426
G2 X97.943 Y74.381 I-12.208 J9.978 E.18144
G1 X91.525 Y80.799 E.30109
G1 X88.475 Y80.799 E.10117
G1 X82.057 Y74.381 E.30109
G2 X77.937 Y77.937 I8.088 J13.534 E.18144
G1 X80.801 Y80.801 E.13437
G3 X83.849 Y80.799 I2.097 J787.121 E.1011
G1 X92.269 Y72.379 E.39501
G3 X96.79 Y73.762 I-2.158 J15.131 E.15744
G1 X103.988 Y80.96 E.33771
G3 X104.773 Y82.903 I-25.16 J11.285 E.06952
G1 X101.95 Y85.726 E.13241
G1 X101.95 Y86.598 E.02893
G1 X105.383 Y90.031 E.16106
G1 X105.392 Y89.96 E.00238
G1 X101.95 Y93.402 E.16147
G3 X101.856 Y94.18 I-2.125 J.137 E.02614
G1 X103.369 Y95.693 E.07101
G3 X99.813 Y99.813 I-13.533 J-8.088 E.18144
G1 X94.7 Y94.7 E.23986
G1 X92.976 Y94.7 E.05719
G1 X85.153 Y102.523 E.36697
G3 X83.636 Y101.935 I4.96 J-15.067 E.054
; CHANGE_LAYER
; Z_HEIGHT: 2.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X85.153 Y102.523 E-.61838
G1 X85.417 Y102.259 E-.14163
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 13/25
; update layer progress
M73 L13
M991 S0 P12 ;notify layer change
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z2.8 I-1.2 J-.205 P1  F42000
G1 X84.285 Y108.899 Z2.8
G1 Z2.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X87.877 Y65.956 I5.788 J-21.116 E2.0167
G1 X88.536 Y65.907 E.02191
G1 X88.935 Y65.878 E.01327
; LINE_WIDTH: 0.48832
G1 F8082.623
G2 X90.388 Y65.881 I1.235 J-287.376 E.05275
; LINE_WIDTH: 0.4882
G1 F8084.801
G1 X91.075 Y65.879 E.0249
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X91.473 Y65.908 E.01327
G1 X92.146 Y65.958 E.02237
G3 X111.897 Y87.79 I-2.162 J21.806 E1.0708
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49733
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.112 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
M73 P60 R8
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.891 J-21.493 E3.0453
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.118 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25113
G1 X82.491 Y108.737 E-.41561
G1 X82.262 Y108.649 E-.09326
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z3 F42000
G1 X94.196 Y109.433 Z3
G1 Z2.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.849 J-.924 E.03357
G1 X93.721 Y111.457 E.02248
G1 X93.397 Y111.841 E.01666
G1 X92.776 Y112.419 E.02814
G1 X92.353 Y112.695 E.01673
G1 X91.59 Y113.067 E.02817
G1 X91.107 Y113.207 E.01669
G1 X90.268 Y113.343 E.02819
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.0282
G1 X88.443 Y113.071 E.0167
G1 X87.671 Y112.718 E.02815
G1 X87.256 Y112.433 E.01671
G1 X86.62 Y111.871 E.02816
G1 X86.305 Y111.478 E.01667
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.125 J-2.311 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X87.855 Y109.534 I4.557 J-27.969 E.05768
G1 X88.527 Y109.592 E.02236
G1 X88.925 Y109.621 E.01327
; LINE_WIDTH: 0.4882
G1 F8084.801
G1 X89.212 Y109.621 E.01039
G1 X89.612 Y109.619 E.01451
; LINE_WIDTH: 0.48832
G1 F8082.623
G3 X91.065 Y109.622 I.218 J289.018 E.05275
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X91.464 Y109.592 E.01327
G1 X92.168 Y109.534 E.02344
G2 X93.76 Y109.316 I-2.439 J-23.701 E.05328
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.02431
G3 X86.201 Y110.562 I-3.388 J-2.504 E.26652
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.788 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.157 E.23767
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05567
G1 X94.037 Y109.947 E-.06473
G1 X93.789 Y110.564 E-.25267
G1 X93.389 Y111.247 E-.30061
G1 X93.241 Y111.419 E-.08633
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X87.67 Y106.203 Z3 F42000
G1 X87.666 Y106.199 Z3
G1 Z2.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G3 X80.449 Y71.788 I2.333 J-18.452 E1.52792
G3 X87.666 Y69.301 I9.579 J16.084 E.25502
G1 X89.129 Y66.645 E.10055
G1 X89.219 Y66.523 E.00503
; LINE_WIDTH: 0.49443
G1 F7973.246
G1 X89.519 Y66.334 E.01304
G1 X90.363 Y66.326 E.03105
; LINE_WIDTH: 0.48832
G1 F8082.623
G1 X90.781 Y66.523 E.0168
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X90.982 Y66.869 E.01327
G1 X91.245 Y67.324 E.01743
G3 X92.209 Y69.076 I-59.211 J33.736 E.06634
G1 X92.333 Y69.3 E.00849
G3 X92.333 Y106.2 I-2.329 J18.45 E1.78299
G1 X90.871 Y108.854 E.10053
G1 X90.781 Y108.977 E.00504
; LINE_WIDTH: 0.49443
G1 F7973.246
G1 X90.481 Y109.166 E.01304
G1 X89.637 Y109.174 E.03105
; LINE_WIDTH: 0.48832
G1 F8082.623
G1 X89.219 Y108.977 E.0168
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X89.018 Y108.631 E.01327
G1 X88.755 Y108.176 E.01743
G3 X87.79 Y106.424 I59.286 J-33.797 E.06634
G1 X87.695 Y106.252 E.00652
M204 S250
G1 X87.913 Y105.835 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X80.642 Y72.129 I2.086 J-18.087 E1.39133
G3 X87.913 Y69.665 I9.386 J15.741 E.23765
G1 X89.472 Y66.835 E.0993
G1 X89.6 Y66.741 E.00488
G1 X90.363 Y66.737 E.02343
G1 X90.528 Y66.835 E.0059
G1 X92.086 Y69.665 E.09928
G3 X92.086 Y105.835 I-2.081 J18.085 E1.62912
G1 X90.528 Y108.665 E.09928
G1 X90.4 Y108.759 E.00488
G1 X89.637 Y108.763 E.02343
G1 X89.472 Y108.665 E.00589
G1 X87.942 Y105.887 E.09745
; WIPE_START
M204 S6000
G1 X87.333 Y105.763 E-.23621
G1 X86.452 Y105.611 E-.33978
G1 X85.979 Y105.505 E-.18401
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z3
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z3 F4000
            G39.3 S1
            G0 Z3 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X86.847 Y106.421 F42000
G1 Z2.6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X87.447 Y106.518 E.02015
G1 X87.939 Y107.412 E.03386
G1 X86.36 Y108.992 E.07409
G2 X85.956 Y108.984 I-.217 J.727 E.01358
G1 X81.803 Y104.831 E.19483
G3 X77.777 Y102.223 I9.688 J-19.362 E.15943
G1 X75.932 Y104.068 E.08658
G3 X72.296 Y100.029 I16.104 J-18.152 E.18067
G1 X74.169 Y98.155 E.08788
G3 X72.919 Y95.947 I16.988 J-11.071 E.08422
G1 X68.848 Y91.876 E.19096
G2 X69.69 Y94.958 I38.248 J-8.795 E.10599
G1 X71.766 Y92.882 E.09739
G3 X71.391 Y91.298 I19.511 J-5.467 E.054
M204 S10000
G1 X68.47 Y86.878 F42000
G1 F8843.478
M204 S6000
G2 X68.467 Y88.505 I16.638 J.843 E.05402
G1 X71.153 Y85.82 E.126
G2 X71.102 Y86.454 I6.505 J.838 E.02112
G1 X68.764 Y84.115 E.1097
G3 X70.324 Y78.972 I23.892 J4.44 E.17865
G1 X81.222 Y68.074 E.51127
G3 X82.792 Y67.44 I11.402 J25.996 E.05617
G1 X84.868 Y69.516 E.09738
G2 X79.595 Y71.919 I5.16 J18.313 E.19298
G1 X77.721 Y70.046 E.08788
G2 X73.682 Y73.682 I14.113 J19.741 E.18067
G1 X75.527 Y75.527 E.08658
G2 X72.595 Y80.271 I14.571 J12.285 E.18566
G1 X70.632 Y78.308 E.0921
; WIPE_START
G1 X72.046 Y79.722 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X74.609 Y86.911 Z3 F42000
G1 X82.047 Y107.775 Z3
G1 Z2.6
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X80.558 Y107.118 I8.843 J-22.076 E.054
G1 X82.521 Y105.155 E.0921
; WIPE_START
G1 X81.107 Y106.569 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.227 Y109.318 Z3 F42000
G1 X94.058 Y111.57 Z3
G1 Z2.6
G1 E.8 F1800
G1 F8843.478
M204 S6000
G2 X94.755 Y110.107 I-6.369 J-3.933 E.05386
G1 X94.836 Y110.187 E.00377
G3 X90.72 Y113.748 I-4.85 J-1.447 E.19058
G1 X90.616 Y113.643 E.00492
G3 X89.377 Y113.651 I-.651 J-5.061 E.0412
G1 X89.28 Y113.748 E.00455
G3 X85.164 Y110.187 I.735 J-5.008 E.19058
G1 X85.245 Y110.107 E.00377
G2 X85.946 Y111.567 I3.385 J-.728 E.05422
; WIPE_START
G1 X85.527 Y110.865 E-.31055
G1 X85.245 Y110.107 E-.30741
G1 X85.164 Y110.187 E-.04324
G1 X85.255 Y110.431 E-.09881
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X92.726 Y108.868 Z3 F42000
G1 X97.953 Y107.775 Z3
G1 Z2.6
G1 E.8 F1800
G1 F8843.478
M204 S6000
G2 X99.442 Y107.118 I-8.837 J-22.063 E.054
G1 X97.478 Y105.154 E.09213
; WIPE_START
G1 X98.893 Y106.568 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.99 Y100.129 Z3 F42000
G1 X108.61 Y91.299 Z3
G1 Z2.6
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X108.234 Y92.882 I-21.019 J-4.143 E.054
G1 X110.31 Y94.958 E.09736
G2 X111.152 Y91.876 I-37.423 J-11.881 E.10599
G1 X107.081 Y95.947 E.19096
G3 X105.831 Y98.155 I-18.235 J-8.862 E.08423
G1 X107.704 Y100.029 E.08788
G3 X104.068 Y104.068 I-19.74 J-14.113 E.18067
G1 X102.223 Y102.223 E.08658
G3 X98.196 Y104.831 I-13.697 J-16.727 E.15947
G1 X94.044 Y108.984 E.19479
G2 X93.64 Y108.992 I-.187 J.735 E.01358
G1 X92.06 Y107.412 E.07411
G1 X92.552 Y106.518 E.03384
G1 X93.152 Y106.421 E.02017
; WIPE_START
G1 X92.552 Y106.518 E-.23107
G1 X92.06 Y107.412 E-.38769
G1 X92.323 Y107.675 E-.14124
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.154 Y101.074 Z3 F42000
G1 X109.368 Y78.308 Z3
G1 Z2.6
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X107.405 Y80.271 E.0921
G2 X104.473 Y75.527 I-17.499 J7.539 E.18566
G1 X106.318 Y73.682 E.08658
G2 X102.279 Y70.046 I-18.153 J16.105 E.18067
G1 X100.405 Y71.919 E.08788
G2 X95.132 Y69.516 I-10.441 J15.925 E.19297
G1 X97.208 Y67.44 E.09736
G3 X98.778 Y68.074 I-9.844 J26.661 E.05617
G1 X109.676 Y78.972 E.51127
G3 X111.236 Y84.116 I-22.331 J9.583 E.17865
G1 X108.898 Y86.454 E.10971
G2 X108.847 Y85.82 I-6.508 J.198 E.02112
G1 X111.533 Y88.505 E.126
G2 X111.53 Y86.878 I-16.641 J-.785 E.05402
; WIPE_START
G1 X111.533 Y88.505 E-.61858
G1 X111.27 Y88.242 E-.14143
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.593 Y93.344 Z3 F42000
G1 X90 Y107.358 Z3
G1 Z2.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X88.602 Y104.891 E.09406
G1 X88.602 Y104.104 E.0261
G1 X88.557 Y103.88 E.00759
G1 X88.383 Y103.65 E.00957
G1 X88.111 Y103.531 E.00985
G1 X86.893 Y103.341 E.04087
G3 X88.122 Y71.967 I3.106 J-15.589 E1.49035
G1 X88.383 Y71.85 E.0095
G1 X88.557 Y71.62 E.00957
G1 X88.602 Y71.396 E.00759
G1 X88.602 Y70.609 E.0261
G1 X90 Y68.142 E.09406
G1 X91.398 Y70.609 E.09406
G1 X91.398 Y71.396 E.0261
G1 X91.443 Y71.62 E.00759
G1 X91.617 Y71.85 E.00957
G1 X91.889 Y71.969 E.00985
G1 X93.107 Y72.159 E.04087
G3 X105.896 Y87.803 I-3.121 J15.602 E.72623
G3 X91.878 Y103.533 I-15.889 J-.049 E.76408
G1 X91.617 Y103.65 E.0095
G1 X91.443 Y103.88 E.00957
G1 X91.398 Y104.104 E.00759
G1 X91.398 Y104.891 E.0261
G1 X90.03 Y107.306 E.09207
M204 S250
G1 X89.822 Y107.84 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X88.21 Y104.995 E.10049
G1 X88.21 Y104.104 E.02735
G1 X88.166 Y103.983 E.00396
G1 X88.05 Y103.918 E.00407
G1 X86.82 Y103.727 E.03826
G3 X87.61 Y71.637 I3.186 J-15.976 E1.40015
G1 X88.139 Y71.543 E.0165
G1 X88.21 Y71.396 E.00503
G1 X88.21 Y70.505 E.02735
G1 X89.822 Y67.66 E.10049
G1 X90.178 Y67.66 E.01092
G1 X91.79 Y70.505 E.10049
G1 X91.79 Y71.396 E.02735
G1 X91.834 Y71.517 E.00396
G1 X91.95 Y71.582 E.00407
G1 X93.18 Y71.773 E.03826
G3 X106.288 Y87.813 I-3.195 J15.987 E.68967
G3 X92.39 Y103.863 I-16.301 J-.072 E.71046
G1 X91.861 Y103.957 E.0165
G1 X91.79 Y104.104 E.00503
G1 X91.79 Y104.995 E.02735
G1 X90.178 Y107.84 E.10049
G1 X89.882 Y107.84 E.00907
; WIPE_START
M204 S6000
G1 X88.869 Y106.116 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X85.959 Y99.06 Z3 F42000
G1 X78.623 Y81.274 Z3
G1 Z2.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X78.732 Y81.199 E.00437
G1 X78.976 Y81.145 E.00828
G1 X100.976 Y81.145 E.72976
G3 X101.267 Y81.199 I.024 J.689 E.00992
G1 X101.431 Y81.312 E.0066
G1 X101.579 Y81.558 E.00953
G1 X101.604 Y82.279 E.02394
G1 X101.604 Y93.773 E.38127
G1 X101.529 Y94.059 E.00981
G3 X101.267 Y94.3 I-.505 J-.286 E.01199
G1 X101.023 Y94.354 E.00828
G1 X84.946 Y94.354 E.5333
G1 X78.976 Y94.354 E.19805
G1 X78.732 Y94.301 E.00827
G1 X78.527 Y94.142 E.00858
G1 X78.448 Y94.017 E.00492
G1 X78.395 Y93.773 E.00826
G1 X78.395 Y81.726 E.39964
G1 X78.47 Y81.44 E.00981
G3 X78.568 Y81.312 I.505 J.286 E.00536
G1 X78.574 Y81.308 E.00024
M204 S250
G1 X78.843 Y81.591 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X78.976 Y81.537 E.00439
G1 X100.976 Y81.537 E.67598
G3 X101.156 Y81.591 I.024 J.247 E.00593
G1 X101.212 Y81.726 E.00447
M73 P61 R8
G1 X101.212 Y93.726 E.36872
G3 X101.156 Y93.908 I-.246 J.024 E.00602
G1 X101.023 Y93.962 E.00439
G1 X84.946 Y93.962 E.494
G1 X78.976 Y93.962 E.18346
G1 X78.83 Y93.893 E.00495
G1 X78.787 Y93.773 E.00391
G1 X78.787 Y81.773 E.36872
G3 X78.811 Y81.642 I.246 J-.024 E.00416
; WIPE_START
M204 S6000
G1 X78.976 Y81.537 E-.0743
G1 X80.78 Y81.537 E-.6857
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X80.894 Y89.169 Z3 F42000
G1 X80.976 Y94.7 Z3
G1 Z2.6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X79.348 Y94.7 E.05401
G1 X87.777 Y103.129 E.39541
G3 X85.153 Y102.523 I2.947 J-18.736 E.08939
G1 X92.976 Y94.7 E.36697
G1 X94.7 Y94.7 E.05719
G1 X99.813 Y99.813 E.23986
G2 X103.369 Y95.693 I-9.977 J-12.207 E.18144
G1 X101.856 Y94.18 E.07101
G2 X101.95 Y93.402 I-2.031 J-.641 E.02614
G1 X105.392 Y89.96 E.16147
G1 X105.383 Y90.031 E.00238
G1 X101.95 Y86.598 E.16106
G1 X101.95 Y85.726 E.02893
G1 X104.773 Y82.903 E.13241
G2 X103.988 Y80.96 I-25.944 J9.342 E.06952
G1 X96.79 Y73.762 E.33771
G2 X92.27 Y72.379 I-6.681 J13.757 E.15743
G1 X83.849 Y80.799 E.39502
G2 X80.801 Y80.801 I-.951 J787.123 E.1011
G1 X77.937 Y77.937 E.13437
G3 X82.057 Y74.381 I12.208 J9.978 E.18144
G1 X88.475 Y80.799 E.30109
G1 X91.525 Y80.799 E.10117
G1 X97.943 Y74.381 E.30109
G3 X102.063 Y77.937 I-8.088 J13.534 E.18144
G1 X99.201 Y80.799 E.13426
G1 X96.151 Y80.799 E.10117
G1 X87.728 Y72.376 E.39512
G2 X83.21 Y73.762 I2.197 J15.225 E.15738
G1 X76.012 Y80.96 E.33771
G2 X75.227 Y82.903 I25.163 J11.286 E.06952
G1 X78.049 Y85.725 E.13237
G1 X78.049 Y86.599 E.02899
G1 X74.617 Y90.031 E.16101
G1 X74.608 Y89.96 E.00238
G1 X78.049 Y93.401 E.16143
G2 X78.144 Y94.18 I2.122 J.138 E.02619
G1 X76.631 Y95.693 E.07097
G2 X80.187 Y99.813 I13.534 J-8.088 E.18144
G1 X85.3 Y94.7 E.23986
G1 X87.024 Y94.7 E.05719
G1 X94.847 Y102.523 E.36697
G2 X96.364 Y101.935 I-4.959 J-15.065 E.054
M204 S10000
G1 X99.024 Y94.7 F42000
G1 F8843.478
M204 S6000
G1 X100.652 Y94.7 E.05401
G1 X92.22 Y103.132 E.39555
G2 X91.052 Y104.3 I-.111 J1.057 E.06277
G1 X89.528 Y105.824 E.07149
G1 X88.948 Y104.8 E.03903
G1 X88.948 Y104.3 E.01659
G1 X90.472 Y105.824 E.07149
G1 X90 Y106.657 E.03175
G1 X89.669 Y106.073 E.02226
; CHANGE_LAYER
; Z_HEIGHT: 2.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X90 Y106.657 E-.25503
G1 X90.472 Y105.824 E-.36373
G1 X90.209 Y105.561 E-.14124
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 14/25
; update layer progress
M73 L14
M991 S0 P13 ;notify layer change
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z3 I-.597 J-1.06 P1  F42000
G1 X84.285 Y108.899 Z3
G1 Z2.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X87.877 Y65.956 I5.787 J-21.116 E2.01675
G1 X88.537 Y65.907 E.02192
G1 X88.935 Y65.878 E.01327
; LINE_WIDTH: 0.4891
G1 F8068.493
G2 X90.325 Y65.88 I1.787 J-1068.873 E.05053
; LINE_WIDTH: 0.48897
G1 F8070.844
G1 X91.075 Y65.879 E.02724
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X91.473 Y65.911 E.01327
G1 X92.353 Y65.981 E.02926
G3 X106.286 Y73.116 I-2.399 J21.859 E.53091
G3 X111.897 Y87.79 I-16.387 J14.675 E.53289
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49733
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.112 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X93.71 Y65.778 I5.888 J-21.491 E2.08245
G3 X112.289 Y87.8 I-3.724 J21.989 E.96247
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.118 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25113
G1 X82.491 Y108.737 E-.41561
G1 X82.262 Y108.649 E-.09326
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z3.2 F42000
G1 X94.196 Y109.433 Z3.2
G1 Z2.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G1 X94.337 Y110.288 E.01208
G1 X94.078 Y110.881 E.02147
G1 X93.721 Y111.457 E.02249
G1 X93.397 Y111.841 E.01666
G1 X92.776 Y112.419 E.02815
G1 X92.353 Y112.695 E.01673
G1 X91.59 Y113.067 E.02817
G1 X91.107 Y113.207 E.01669
G1 X90.268 Y113.343 E.02819
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.0282
G1 X88.443 Y113.071 E.0167
G1 X87.671 Y112.718 E.02815
G1 X87.256 Y112.433 E.01671
G1 X86.619 Y111.871 E.02816
G1 X86.305 Y111.478 E.01667
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.123 J-2.31 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X87.646 Y109.512 I4.635 J-28.664 E.05073
G1 X88.527 Y109.589 E.02931
G1 X88.925 Y109.621 E.01327
; LINE_WIDTH: 0.48897
G1 F8070.844
G1 X89.275 Y109.621 E.0127
G1 X89.675 Y109.62 E.01454
; LINE_WIDTH: 0.4891
G1 F8068.493
G3 X91.065 Y109.622 I-.397 J1068.839 E.05053
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X91.463 Y109.593 E.01327
G1 X92.122 Y109.539 E.02191
G2 X93.76 Y109.316 I-2.393 J-23.712 E.05483
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.965 Y110.164 E.00702
G3 X86.201 Y110.562 I-3.965 J-1.417 E.3044
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.788 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.156 E.23767
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05567
G1 X94.037 Y109.947 E-.06473
G1 X93.965 Y110.164 E-.08688
G1 X93.719 Y110.722 E-.23165
G1 X93.389 Y111.247 E-.23554
G1 X93.243 Y111.418 E-.08554
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X87.68 Y106.201 Z3.2 F42000
G1 Z2.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G3 X84.6 Y105.551 I2.478 J-19.36 E.10452
G3 X87.68 Y69.299 I5.4 J-17.798 E1.67934
G3 X89.201 Y66.629 I49.537 J26.461 E.10196
G1 X89.257 Y66.55 E.00318
; LINE_WIDTH: 0.49521
G1 F7959.495
G1 X89.582 Y66.334 E.01437
G1 X90.3 Y66.325 E.02646
; LINE_WIDTH: 0.4891
G1 F8068.493
G1 X90.743 Y66.55 E.01807
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X90.951 Y66.892 E.01327
G1 X91.232 Y67.369 E.01835
G3 X92.32 Y69.299 I-53.657 J31.524 E.07351
G3 X92.32 Y106.201 I-2.316 J18.451 E1.78384
G3 X90.799 Y108.871 I-49.568 J-26.479 E.10196
G1 X90.743 Y108.95 E.00318
; LINE_WIDTH: 0.49521
G1 F7959.495
G1 X90.418 Y109.166 E.01437
G1 X89.7 Y109.175 E.02646
; LINE_WIDTH: 0.4891
G1 F8068.493
G1 X89.257 Y108.95 E.01807
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X89.049 Y108.608 E.01327
G1 X88.768 Y108.131 E.01835
G3 X87.708 Y106.254 I53.624 J-31.505 E.07152
M204 S250
G1 X87.925 Y105.836 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X84.718 Y105.177 I1.935 J-17.546 E.10074
G1 X84.714 Y105.176 E.00014
G3 X87.925 Y69.664 I5.286 J-17.423 E1.5289
G3 X89.538 Y66.829 I57.343 J30.757 E.10022
G1 X89.7 Y66.737 E.00573
G1 X90.304 Y66.737 E.01855
G1 X90.46 Y66.826 E.00549
G3 X92.075 Y69.664 I-71.352 J42.488 E.10034
G3 X92.075 Y105.836 I-2.069 J18.086 E1.62981
G3 X90.462 Y108.671 I-57.372 J-30.773 E.10022
G1 X90.3 Y108.763 E.00573
G1 X89.696 Y108.763 E.01855
G1 X89.541 Y108.674 E.00549
G3 X87.954 Y105.889 I71.335 J-42.479 E.0985
; WIPE_START
M204 S6000
G1 X87.333 Y105.763 E-.2408
G1 X86.452 Y105.611 E-.33977
G1 X85.991 Y105.508 E-.17943
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.2 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z3.2
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z3.2 F4000
            G39.3 S1
            G0 Z3.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X82.521 Y105.155 F42000
G1 Z2.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X80.558 Y107.118 E.0921
G2 X82.047 Y107.775 I10.332 J-21.419 E.054
; WIPE_START
G1 X80.558 Y107.118 E-.6185
G1 X80.821 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X85.946 Y111.567 Z3.2 F42000
G1 Z2.8
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X85.245 Y110.107 I2.727 J-2.208 E.05421
G1 X85.164 Y110.187 E.00378
G2 X89.28 Y113.748 I4.85 J-1.447 E.19058
G3 X89.574 Y113.678 I.172 J.07 E.01171
G2 X90.619 Y113.647 I.411 J-3.724 E.0348
G1 X90.72 Y113.748 E.00475
G2 X94.836 Y110.187 I-.735 J-5.008 E.19058
G1 X94.755 Y110.107 E.00377
G3 X94.058 Y111.57 I-7.065 J-2.47 E.05386
; WIPE_START
G1 X94.364 Y111.083 E-.21861
G1 X94.755 Y110.107 E-.39946
G1 X94.836 Y110.187 E-.04316
G1 X94.745 Y110.431 E-.09877
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X93.152 Y106.421 Z3.2 F42000
G1 Z2.8
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X92.538 Y106.52 E.0206
G1 X92.048 Y107.4 E.03341
G1 X93.64 Y108.992 E.07468
G3 X94.044 Y108.984 I.217 J.727 E.01358
G1 X98.197 Y104.831 E.19482
G2 X102.223 Y102.223 I-9.689 J-19.363 E.15944
G1 X104.068 Y104.068 E.08658
G2 X107.704 Y100.029 I-16.104 J-18.153 E.18067
G1 X105.831 Y98.155 E.08788
G2 X107.079 Y95.949 I-16.773 J-10.943 E.08415
G1 X111.152 Y91.876 E.19104
G3 X110.31 Y94.958 I-38.265 J-8.799 E.10599
G1 X108.234 Y92.882 E.09736
G2 X108.61 Y91.299 I-20.058 J-5.59 E.054
M204 S10000
G1 X111.53 Y86.878 F42000
G1 F8843.478
M204 S6000
G3 X111.533 Y88.505 I-16.638 J.843 E.05402
G1 X108.847 Y85.82 E.126
G3 X108.898 Y86.454 I-6.458 J.833 E.02112
G1 X111.236 Y84.116 E.10971
G2 X109.676 Y78.972 I-23.892 J4.44 E.17865
G1 X98.778 Y68.074 E.51127
G2 X97.208 Y67.44 I-11.414 J26.027 E.05617
G1 X95.132 Y69.516 E.09738
G3 X100.405 Y71.919 I-5.16 J18.312 E.19298
G1 X102.279 Y70.046 E.08788
G3 X106.318 Y73.682 I-14.114 J19.741 E.18067
G1 X104.473 Y75.527 E.08658
G3 X107.404 Y80.272 I-14.561 J12.276 E.18567
G1 X109.368 Y78.308 E.09213
; WIPE_START
G1 X107.954 Y79.722 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.047 Y86.779 Z3.2 F42000
G1 X97.479 Y105.155 Z3.2
G1 Z2.8
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X99.442 Y107.118 E.0921
G3 X97.953 Y107.775 I-10.326 J-21.407 E.054
; WIPE_START
G1 X99.442 Y107.118 E-.6185
G1 X99.179 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X92.519 Y103.127 Z3.2 F42000
G1 X71.39 Y91.299 Z3.2
G1 Z2.8
G1 E.8 F1800
G1 F8843.478
M204 S6000
G2 X71.766 Y92.882 I20.468 J-4.014 E.054
G1 X69.69 Y94.958 E.09736
G3 X68.848 Y91.876 I37.406 J-11.876 E.10599
G1 X72.919 Y95.947 E.19096
G2 X74.169 Y98.155 I18.58 J-9.057 E.08423
G1 X72.296 Y100.029 E.08788
G2 X75.932 Y104.068 I19.74 J-14.113 E.18067
G1 X77.777 Y102.223 E.08658
G2 X81.803 Y104.831 I13.738 J-16.791 E.15944
G1 X85.956 Y108.984 E.19482
G3 X86.36 Y108.992 I.187 J.735 E.01358
G1 X87.952 Y107.4 E.07469
G1 X87.462 Y106.52 E.03341
G1 X86.848 Y106.421 E.0206
; WIPE_START
G1 X87.462 Y106.52 E-.23601
G1 X87.952 Y107.4 E-.38275
G1 X87.689 Y107.663 E-.14124
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X83.855 Y101.063 Z3.2 F42000
G1 X70.632 Y78.308 Z3.2
M73 P61 R7
G1 Z2.8
G1 E.8 F1800
M73 P62 R7
G1 F8843.478
M204 S6000
G1 X72.595 Y80.271 E.0921
G3 X75.527 Y75.527 I17.5 J7.539 E.18566
G1 X73.682 Y73.682 E.08658
G3 X77.721 Y70.046 I18.153 J16.104 E.18067
G1 X79.595 Y71.919 E.08788
G3 X84.868 Y69.516 I10.442 J15.926 E.19297
G1 X82.792 Y67.44 E.09736
G2 X81.222 Y68.074 I9.832 J26.63 E.05617
G1 X70.324 Y78.972 E.51127
G2 X68.764 Y84.115 I22.332 J9.583 E.17865
G1 X71.102 Y86.454 E.10971
G3 X71.153 Y85.82 I6.515 J.199 E.02112
G1 X68.467 Y88.505 E.126
G3 X68.47 Y86.878 I16.641 J-.785 E.05402
; WIPE_START
G1 X68.467 Y88.505 E-.61858
G1 X68.73 Y88.242 E-.14143
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X74.417 Y93.332 Z3.2 F42000
G1 X90.003 Y107.281 Z3.2
G1 Z2.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X89.819 Y106.989 E.01144
G1 X88.615 Y104.894 E.08016
G1 X88.615 Y104.106 E.02613
G1 X88.569 Y103.88 E.00764
G1 X88.394 Y103.65 E.00959
G1 X88.124 Y103.532 E.00979
G1 X86.893 Y103.341 E.04131
G3 X88.135 Y71.966 I3.108 J-15.589 E1.4907
G1 X88.394 Y71.85 E.00943
G1 X88.569 Y71.62 E.00958
G1 X88.615 Y71.394 E.00764
G1 X88.615 Y70.606 E.02616
G3 X89.995 Y68.222 I77.771 J43.429 E.09138
G1 X90.281 Y68.681 E.01795
G1 X91.385 Y70.606 E.0736
G1 X91.385 Y71.394 E.02614
G1 X91.431 Y71.62 E.00764
G1 X91.606 Y71.85 E.00958
G1 X91.876 Y71.968 E.00979
G1 X93.107 Y72.159 E.04131
G3 X105.896 Y87.803 I-3.122 J15.602 E.72623
G3 X91.865 Y103.534 I-15.889 J-.049 E.76451
G1 X91.606 Y103.65 E.00943
G1 X91.431 Y103.88 E.00959
G1 X91.385 Y104.106 E.00764
G1 X91.385 Y104.894 E.02614
G1 X90.39 Y106.629 E.06634
G3 X90.034 Y107.23 I-15.493 J-8.759 E.02316
M204 S250
G1 X89.892 Y107.84 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.483 Y107.191 E.02356
G1 X88.223 Y104.998 E.07771
G1 X88.223 Y104.106 E.02742
G2 X88.063 Y103.92 I-.189 J0 E.00821
G1 X86.82 Y103.727 E.03866
G3 X87.61 Y71.637 I3.186 J-15.976 E1.40014
G1 X88.151 Y71.542 E.01689
G1 X88.223 Y71.394 E.00505
G1 X88.223 Y70.501 E.02743
G3 X89.886 Y67.66 I52.533 J28.834 E.10117
G1 X90.108 Y67.66 E.00682
G1 X90.618 Y68.48 E.02967
G1 X91.777 Y70.501 E.0716
G1 X91.777 Y71.394 E.02742
G2 X91.937 Y71.58 I.189 J0 E.00821
G1 X93.18 Y71.773 E.03866
G3 X106.288 Y87.813 I-3.195 J15.987 E.68967
G3 X92.39 Y103.863 I-16.301 J-.072 E.71046
G1 X91.849 Y103.958 E.01689
G1 X91.777 Y104.106 E.00505
G1 X91.777 Y104.999 E.02742
G1 X90.782 Y106.733 E.06145
G3 X90.113 Y107.84 I-20.95 J-11.908 E.03973
G1 X89.952 Y107.84 E.00495
; WIPE_START
M204 S6000
G1 X89.483 Y107.191 E-.30414
G1 X88.885 Y106.151 E-.45586
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X94.406 Y100.88 Z3.2 F42000
G1 X101.376 Y94.225 Z3.2
G1 Z2.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X101.267 Y94.3 E.00437
G1 X101.023 Y94.354 E.00828
G1 X79.023 Y94.354 E.72976
G3 X78.732 Y94.301 I-.024 J-.69 E.00991
G1 X78.527 Y94.142 E.00858
G1 X78.448 Y94.017 E.00492
G1 X78.395 Y93.773 E.00826
G1 X78.395 Y88.426 E.17737
G1 X78.395 Y81.726 E.22227
G1 X78.47 Y81.44 E.00981
G3 X78.732 Y81.199 I.505 J.286 E.01199
G1 X78.976 Y81.145 E.00828
G1 X100.976 Y81.145 E.72976
G3 X101.267 Y81.199 I.024 J.689 E.00992
G1 X101.431 Y81.312 E.0066
G1 X101.579 Y81.558 E.00953
G1 X101.604 Y82.279 E.02394
G1 X101.604 Y93.773 E.38127
G1 X101.529 Y94.059 E.00981
G3 X101.431 Y94.187 I-.505 J-.286 E.00536
G1 X101.425 Y94.191 E.00024
M204 S250
G1 X101.156 Y93.908 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X101.023 Y93.962 E.00439
G1 X78.976 Y93.962 E.67745
G1 X78.83 Y93.893 E.00495
G1 X78.787 Y93.773 E.00391
G1 X78.787 Y88.426 E.1643
G1 X78.787 Y81.726 E.20589
G1 X78.843 Y81.591 E.00448
G1 X78.976 Y81.537 E.00439
G1 X100.976 Y81.537 E.67598
G3 X101.156 Y81.591 I.024 J.247 E.00593
G1 X101.212 Y81.726 E.00447
G1 X101.212 Y93.726 E.36872
G3 X101.188 Y93.857 I-.246 J.024 E.00416
; WIPE_START
M204 S6000
G1 X101.023 Y93.962 E-.0743
G1 X99.219 Y93.962 E-.6857
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.024 Y94.7 Z3.2 F42000
G1 Z2.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X100.652 Y94.7 E.05401
G1 X92.221 Y103.131 E.39553
G2 X94.847 Y102.523 I-3.051 J-19.126 E.08949
G1 X87.024 Y94.7 E.36697
G1 X85.3 Y94.7 E.05719
G1 X80.187 Y99.813 E.23986
G3 X76.631 Y95.693 I9.977 J-12.208 E.18144
G1 X78.144 Y94.18 E.07097
G3 X78.049 Y93.401 I2.028 J-.642 E.02619
G1 X74.608 Y89.96 E.16143
G1 X74.617 Y90.031 E.00238
G1 X78.049 Y86.599 E.16101
G1 X78.049 Y85.725 E.02899
G1 X75.227 Y82.903 E.13237
G3 X76.012 Y80.96 I25.948 J9.343 E.06952
G1 X83.21 Y73.762 E.33771
G3 X87.729 Y72.377 I6.71 J13.827 E.15739
G1 X96.151 Y80.799 E.39511
G1 X99.201 Y80.799 E.10117
G1 X102.063 Y77.937 E.13426
G2 X97.943 Y74.381 I-12.208 J9.978 E.18144
G1 X91.525 Y80.799 E.30109
G1 X88.475 Y80.799 E.10117
G1 X82.057 Y74.381 E.30109
G2 X77.937 Y77.937 I8.088 J13.534 E.18144
G1 X80.801 Y80.801 E.13437
G3 X83.849 Y80.799 I2.097 J787.121 E.1011
G1 X92.269 Y72.379 E.39501
G3 X96.79 Y73.762 I-2.158 J15.131 E.15744
G1 X103.988 Y80.96 E.33771
G3 X104.773 Y82.903 I-25.16 J11.285 E.06952
G1 X101.95 Y85.726 E.13241
G1 X101.95 Y86.598 E.02893
G1 X105.383 Y90.031 E.16106
G1 X105.392 Y89.96 E.00238
G1 X101.95 Y93.402 E.16147
G3 X101.856 Y94.18 I-2.125 J.137 E.02614
G1 X103.369 Y95.693 E.07101
G3 X99.813 Y99.813 I-13.533 J-8.088 E.18144
G1 X94.7 Y94.7 E.23986
G1 X92.976 Y94.7 E.05719
G1 X85.153 Y102.523 E.36697
G3 X83.636 Y101.935 I4.96 J-15.067 E.054
M204 S10000
G1 X80.976 Y94.7 F42000
G1 F8843.478
M204 S6000
G1 X79.348 Y94.7 E.05401
G1 X87.776 Y103.128 E.39539
G3 X88.961 Y104.313 I.115 J1.07 E.06369
G1 X90.458 Y105.81 E.07024
G1 X91.039 Y104.802 E.0386
G1 X91.039 Y104.313 E.01622
G1 X89.541 Y105.811 E.07027
G1 X89.999 Y106.607 E.03048
G1 X90.353 Y105.993 E.02353
; CHANGE_LAYER
; Z_HEIGHT: 3
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X89.999 Y106.607 E-.26959
G1 X89.541 Y105.811 E-.34917
G1 X89.804 Y105.548 E-.14124
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 15/25
; update layer progress
M73 L15
M991 S0 P14 ;notify layer change
M106 S175.95
; PAUSE_PRINTING
M400 U1

; OBJECT_ID: 19785
M204 S10000
G17
G3 Z3.2 I-.632 J-1.04 P1  F42000
G1 X84.285 Y108.899 Z3.2
G1 Z3
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X87.587 Y65.987 I5.788 J-21.116 E2.00701
G1 X88.568 Y65.91 E.03264
G1 X88.966 Y65.878 E.01327
; LINE_WIDTH: 0.49494
G1 F7964.25
G1 X89.486 Y65.887 E.01915
; LINE_WIDTH: 0.53989
G1 F7243.898
G2 X90.261 Y65.881 I.349 J-4.685 E.03143
; LINE_WIDTH: 0.49494
G1 F7964.25
G1 X90.517 Y65.865 E.00942
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X91.074 Y65.885 E.0185
G3 X111.897 Y87.79 I-1.084 J21.88 E1.1063
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49732
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.112 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.892 J-21.493 E3.04525
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.118 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25113
G1 X82.491 Y108.737 E-.41561
G1 X82.262 Y108.649 E-.09326
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z3.4 F42000
G1 X94.196 Y109.433 Z3.4
G1 Z3
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
M73 C0
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.85 J-.924 E.03357
G1 X93.721 Y111.457 E.02249
G1 X93.397 Y111.841 E.01666
G1 X92.776 Y112.419 E.02816
G1 X92.353 Y112.695 E.01672
G1 X91.59 Y113.067 E.02817
G1 X91.107 Y113.207 E.0167
G1 X90.268 Y113.343 E.02818
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.02819
G1 X88.443 Y113.071 E.01671
G1 X87.671 Y112.718 E.02815
G1 X87.256 Y112.433 E.01671
G1 X86.619 Y111.871 E.02816
G1 X86.305 Y111.478 E.01667
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.126 J-2.312 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X88.926 Y109.614 I3.974 J-23.343 E.09332
G1 X89.441 Y109.634 E.01709
; LINE_WIDTH: 0.49617
G1 F7942.637
G1 X89.717 Y109.618 E.01024
; LINE_WIDTH: 0.54235
G1 F7208.217
G3 X90.378 Y109.615 I.343 J3.461 E.02692
; LINE_WIDTH: 0.49617
G1 F7942.637
G1 X90.762 Y109.629 E.01419
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X91.161 Y109.604 E.01327
G1 X92.146 Y109.537 E.03274
G2 X93.178 Y109.415 I-2.242 J-23.286 E.03448
G1 X93.759 Y109.316 E.01958
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.02431
G3 X86.201 Y110.562 I-3.388 J-2.504 E.26652
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.788 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.226 Y109.804 I3.871 J-22.009 E.21901
G1 X93.826 Y109.702 E.01871
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05567
G1 X94.037 Y109.947 E-.06472
G1 X93.789 Y110.564 E-.25268
G1 X93.389 Y111.247 E-.3006
G1 X93.241 Y111.419 E-.08633
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.72 Y108.998 Z3.4 F42000
G1 Z3
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.54042
G1 F7236.181
M204 S6000
G1 X89.683 Y108.979 E.00167
; LINE_WIDTH: 0.495205
G1 F7959.583
G1 X89.443 Y108.854 E.00998
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X89.293 Y108.723 E.0066
G1 X88.952 Y108.292 E.01823
G3 X87.716 Y106.206 I33.385 J-21.187 E.08045
G3 X77.497 Y73.976 I2.287 J-18.46 E1.40739
G3 X87.717 Y69.294 I12.517 J13.827 E.37878
G3 X89.008 Y67.128 I26.592 J14.374 E.08365
G1 X89.341 Y66.737 E.01707
; LINE_WIDTH: 0.46001
G1 F8631.231
G1 X89.62 Y66.539 E.01161
; LINE_WIDTH: 0.49995
G1 F7876.945
G1 X89.816 Y66.466 E.00779
; LINE_WIDTH: 0.53989
G1 F7243.898
G1 X90.012 Y66.394 E.00847
G1 X90.173 Y66.455 E.00696
; LINE_WIDTH: 0.49494
G1 F7964.25
G1 X90.333 Y66.516 E.00633
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X90.707 Y66.777 E.01511
G1 X91.048 Y67.208 E.01823
G3 X92.284 Y69.294 I-32.684 J20.77 E.08044
G3 X92.283 Y106.206 I-2.279 J18.456 E1.78634
G1 X91.614 Y107.376 E.0447
G3 X90.82 Y108.597 I-9.501 J-5.316 E.04836
G1 X90.487 Y108.903 E.01499
; LINE_WIDTH: 0.48365
G1 F8168.267
G1 X90.385 Y108.964 E.00425
; LINE_WIDTH: 0.51731
G1 F7588.693
G1 X90.284 Y109.025 E.00458
; LINE_WIDTH: 0.55097
G1 F7085.917
G1 X90.182 Y109.086 E.0049
G1 X89.924 Y109.103 E.01072
; LINE_WIDTH: 0.54042
G1 F7236.181
G1 X89.773 Y109.025 E.00687
M204 S250
G1 X89.901 Y108.648 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.794 Y108.589 E.00375
G1 X89.687 Y108.531 E.00375
G3 X89.585 Y108.458 I.036 J-.158 E.00396
G1 X89.551 Y108.416 E.00164
G1 X89.518 Y108.375 E.00164
G1 X89.485 Y108.333 E.00164
G1 X89.451 Y108.292 E.00164
G1 X89.418 Y108.25 E.00164
G1 X89.384 Y108.208 E.00164
G1 X89.351 Y108.167 E.00164
G1 X89.318 Y108.125 E.00164
G3 X87.96 Y105.841 I33.591 J-21.509 E.08166
G3 X77.768 Y74.261 I2.044 J-18.095 E1.28254
G3 X87.96 Y69.659 I12.251 J13.548 E.34922
G3 X89.337 Y67.341 I28.127 J15.133 E.08286
G1 X89.377 Y67.299 E.00178
G1 X89.416 Y67.258 E.00178
G1 X89.456 Y67.216 E.00178
G1 X89.496 Y67.174 E.00178
G1 X89.536 Y67.132 E.00178
G1 X89.576 Y67.09 E.00178
G1 X89.616 Y67.048 E.00178
G1 X89.656 Y67.006 E.00178
G1 X89.695 Y66.964 E.00178
G1 X89.735 Y66.922 E.00178
M73 P63 R7
G1 X89.75 Y66.914 E.00052
; LINE_WIDTH: 0.41998
G1 X89.833 Y66.891 E.00264
G1 X89.916 Y66.868 E.00264
G1 X89.999 Y66.844 E.00264
; LINE_WIDTH: 0.41999
G3 X90.108 Y66.862 I.045 J.067 E.00376
G1 X90.212 Y66.917 E.0036
G1 X90.316 Y66.972 E.0036
G3 X90.415 Y67.042 I-.031 J.15 E.00385
G1 X90.449 Y67.084 E.00164
G1 X90.482 Y67.125 E.00164
G1 X90.516 Y67.167 E.00164
G1 X90.549 Y67.209 E.00164
G1 X90.582 Y67.25 E.00164
G1 X90.616 Y67.292 E.00164
G1 X90.649 Y67.333 E.00164
G1 X90.682 Y67.375 E.00164
G3 X92.04 Y69.659 I-32.943 J21.123 E.08166
G3 X92.04 Y105.841 I-2.035 J18.091 E1.63199
G3 X90.877 Y107.829 I-30.728 J-16.626 E.07079
G1 X90.826 Y107.903 E.00275
G1 X90.775 Y107.976 E.00275
G1 X90.724 Y108.049 E.00275
G1 X90.672 Y108.123 E.00275
G1 X90.621 Y108.196 E.00275
G1 X90.57 Y108.269 E.00275
G1 X90.519 Y108.343 E.00275
G1 X90.15 Y108.643 E.01461
G1 X90.124 Y108.646 E.0008
G1 X89.98 Y108.661 E.00446
G3 X89.957 Y108.667 I-.03 J-.064 E.00074
; WIPE_START
M204 S6000
G1 X89.794 Y108.589 E-.06855
G1 X89.687 Y108.531 E-.04633
G1 X89.585 Y108.458 E-.04769
G1 X89.551 Y108.416 E-.02027
G1 X89.518 Y108.375 E-.02028
G1 X89.485 Y108.333 E-.02028
G1 X89.451 Y108.292 E-.02028
G1 X89.418 Y108.25 E-.02027
G1 X89.384 Y108.208 E-.02028
G1 X89.351 Y108.167 E-.02028
G1 X89.318 Y108.125 E-.02028
G1 X88.855 Y107.401 E-.32648
G1 X88.713 Y107.153 E-.10872
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.4 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z3.4
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z3.4 F4000
            G39.3 S1
            G0 Z3.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X86.85 Y106.429 F42000
G1 Z3
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X87.502 Y106.528 I1.366 J-6.793 E.02189
G1 X87.985 Y107.367 E.03213
G1 X86.36 Y108.992 E.07621
G2 X85.956 Y108.984 I-.217 J.727 E.01358
G1 X81.803 Y104.831 E.1948
G3 X77.777 Y102.223 I9.712 J-19.4 E.15945
G1 X75.932 Y104.068 E.08658
G3 X72.296 Y100.028 I16.105 J-18.153 E.18067
G1 X74.169 Y98.155 E.08787
G3 X72.921 Y95.948 I16.777 J-10.945 E.08416
G1 X68.849 Y91.876 E.19102
G2 X69.69 Y94.958 I38.263 J-8.799 E.10598
G1 X71.766 Y92.882 E.09735
G3 X71.39 Y91.299 I20.645 J-5.728 E.054
M204 S10000
G1 X68.47 Y86.877 F42000
G1 F8843.478
M204 S6000
G2 X68.467 Y88.505 I16.638 J.843 E.05402
G1 X71.153 Y85.82 E.12599
G2 X71.102 Y86.454 I6.471 J.834 E.02112
G1 X68.764 Y84.116 E.1097
G3 X70.324 Y78.972 I23.89 J4.439 E.17866
G1 X81.222 Y68.074 E.51125
G3 X82.792 Y67.44 I11.401 J25.993 E.05618
G1 X84.868 Y69.516 E.09737
G2 X79.595 Y71.919 I5.159 J18.312 E.19298
G1 X77.722 Y70.046 E.08787
G2 X73.682 Y73.682 I14.114 J19.741 E.18067
G1 X75.528 Y75.528 E.08659
G2 X72.595 Y80.271 I14.555 J12.277 E.18566
G1 X70.632 Y78.308 E.09209
; WIPE_START
G1 X72.046 Y79.722 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X78.16 Y75.153 Z3.4 F42000
G1 X88.319 Y67.56 Z3.4
G1 Z3
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X89.343 Y66.315 I4.173 J2.385 E.05373
G1 X89.25 Y66.222 E.00434
G2 X87.627 Y66.334 I.55 J19.77 E.054
; WIPE_START
G1 X89.25 Y66.222 E-.61838
G1 X89.343 Y66.315 E-.04972
G1 X89.143 Y66.452 E-.0919
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X91.677 Y67.562 Z3.4 F42000
G1 Z3
G1 E.8 F1800
G1 F8843.478
M204 S6000
G2 X90.663 Y66.309 I-3.47 J1.771 E.05386
G1 X90.755 Y66.217 E.00432
G3 X92.379 Y66.335 I-.152 J13.336 E.05403
M204 S10000
G1 X109.368 Y78.308 F42000
G1 F8843.478
M204 S6000
G1 X107.405 Y80.271 E.09209
G2 X104.473 Y75.527 I-17.503 J7.541 E.18566
G1 X106.318 Y73.682 E.08658
G2 X102.278 Y70.046 I-18.153 J16.104 E.18067
G1 X100.405 Y71.919 E.08787
G2 X95.132 Y69.516 I-10.434 J15.911 E.19298
G1 X97.208 Y67.44 E.09737
G3 X98.778 Y68.074 I-9.831 J26.628 E.05618
G1 X109.676 Y78.972 E.51125
G3 X111.236 Y84.116 I-22.33 J9.583 E.17866
G1 X108.898 Y86.454 E.1097
G2 X108.847 Y85.82 I-6.497 J.197 E.02112
G1 X111.533 Y88.505 E.12599
G2 X111.53 Y86.877 I-16.64 J-.785 E.05402
M204 S10000
G1 X108.61 Y91.299 F42000
G1 F8843.478
M204 S6000
G3 X108.234 Y92.882 I-20.438 J-4.007 E.054
G1 X110.31 Y94.958 E.09735
G2 X111.151 Y91.876 I-37.413 J-11.878 E.10598
G1 X107.08 Y95.948 E.19102
G3 X105.831 Y98.155 I-18.023 J-8.737 E.08416
G1 X107.704 Y100.028 E.08787
G3 X104.068 Y104.068 I-19.74 J-14.113 E.18067
G1 X102.223 Y102.223 E.08658
G3 X98.197 Y104.831 I-13.714 J-16.755 E.15945
G1 X94.044 Y108.984 E.19481
G2 X93.64 Y108.992 I-.187 J.736 E.01358
G1 X92.011 Y107.363 E.07642
G1 X92.496 Y106.528 E.03204
G2 X93.151 Y106.428 I-.717 J-6.926 E.02198
M204 S10000
G1 X97.953 Y107.775 F42000
G1 F8843.478
M204 S6000
G2 X99.442 Y107.118 I-8.838 J-22.065 E.054
G1 X97.479 Y105.155 E.09209
M204 S10000
G1 X94.058 Y111.57 F42000
G1 F8843.478
M204 S6000
G2 X94.755 Y110.107 I-6.37 J-3.934 E.05386
G1 X94.835 Y110.187 E.00376
G3 X90.72 Y113.748 I-4.85 J-1.447 E.19058
G1 X90.616 Y113.643 E.00491
G3 X89.377 Y113.651 I-.651 J-5.061 E.0412
G1 X89.28 Y113.748 E.00454
G3 X85.165 Y110.187 I.735 J-5.008 E.19058
G1 X85.245 Y110.107 E.00377
G2 X85.946 Y111.567 I3.428 J-.748 E.05421
; WIPE_START
G1 X85.527 Y110.865 E-.31058
G1 X85.245 Y110.107 E-.30739
G1 X85.165 Y110.187 E-.04316
G1 X85.256 Y110.431 E-.09886
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X82.047 Y107.775 Z3.4 F42000
G1 Z3
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X80.558 Y107.118 I8.841 J-22.072 E.054
G1 X82.521 Y105.155 E.09209
; WIPE_START
G1 X81.107 Y106.569 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.725 Y107.028 Z3.4 F42000
G1 X90 Y107.105 Z3.4
G1 Z3
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X89.975 Y107.076 E.00127
G3 X88.647 Y104.894 I26.365 J-17.536 E.08477
G1 X88.647 Y104.11 E.026
G2 X88.161 Y103.537 I-.581 J0 E.0271
G1 X86.893 Y103.341 E.04255
G3 X88.167 Y71.962 I3.108 J-15.589 E1.49179
G1 X88.435 Y71.838 E.0098
G1 X88.604 Y71.608 E.00948
G1 X88.647 Y71.39 E.00735
G1 X88.647 Y70.606 E.026
G3 X89.994 Y68.399 I28.074 J15.626 E.08579
G1 X90.09 Y68.515 E.00499
G3 X91.353 Y70.606 I-31.19 J20.276 E.08105
G1 X91.353 Y71.39 E.02599
G2 X91.839 Y71.963 I.581 J0 E.0271
G3 X105.888 Y88.142 I-1.845 J15.791 E.77991
G3 X91.833 Y103.538 I-15.877 J-.38 E.75433
G1 X91.565 Y103.662 E.0098
G1 X91.396 Y103.892 E.00948
G1 X91.353 Y104.11 E.00735
G1 X91.353 Y104.894 E.02599
G3 X90.033 Y107.056 I-25.125 J-13.857 E.08405
M204 S250
G1 X89.968 Y107.635 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.662 Y107.314 E.01362
G3 X88.255 Y105 I27.686 J-18.423 E.08325
G1 X88.255 Y104.11 E.02736
G2 X88.099 Y103.924 I-.189 J0 E.00809
G3 X87.988 Y71.59 I1.907 J-16.174 E1.45117
G1 X88.186 Y71.535 E.00632
G1 X88.255 Y71.39 E.00494
G1 X88.255 Y70.5 E.02736
G3 X89.589 Y68.296 I31.361 J17.493 E.07917
G1 X89.951 Y67.866 E.01727
G1 X90.082 Y67.89 E.00409
G1 X90.408 Y68.285 E.01572
G3 X91.745 Y70.5 I-33.039 J21.463 E.07952
G1 X91.745 Y71.39 E.02735
G2 X91.901 Y71.576 I.189 J0 E.00809
G3 X106.28 Y88.151 I-1.905 J16.177 E.73976
G3 X92.012 Y103.91 I-16.285 J-.406 E.71162
G1 X91.814 Y103.965 E.00632
G1 X91.745 Y104.11 E.00494
G1 X91.745 Y105 E.02735
G3 X90.343 Y107.299 I-26.796 J-14.776 E.08276
G1 X90.051 Y107.632 E.01361
G1 X90.027 Y107.633 E.00073
; WIPE_START
M204 S6000
G1 X89.662 Y107.314 E-.18429
G1 X89.063 Y106.377 E-.42295
G1 X88.859 Y106.03 E-.15276
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X91.127 Y103.677 Z3.4 F42000
G1 Z3
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.407989
G1 F9861.157
M204 S6000
G1 X91.076 Y103.75 E.00264
G1 X90.964 Y104.163 E.01274
G1 X90.962 Y104.748 E.01739
; LINE_WIDTH: 0.406687
G1 F9896.445
G1 X90.925 Y104.855 E.00336
G1 X90.659 Y105.263 E.01443
M204 S10000
G1 X89.739 Y105.677 F42000
; Slow Down Start
; LINE_WIDTH: 0.454327
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G1 X90.025 Y105.781 E.01022
G1 X90.191 Y105.726 E.00587
G1 X90.626 Y105.313 E.0201
G1 X90.604 Y105.345 E.00131
G3 X90.001 Y106.365 I-12.853 J-6.91 E.03974
G3 X89.377 Y105.319 I14.36 J-9.267 E.04085
G1 X89.696 Y105.635 E.01507
; Slow Down End
M204 S10000
G1 X89.368 Y105.306 F42000
; LINE_WIDTH: 0.438676
G1 F9096.518
M204 S6000
G3 X89.037 Y104.755 I4.37 J-2.992 E.02075
; LINE_WIDTH: 0.402366
G1 F10015.415
G1 X89.038 Y104.184 E.01672
G1 X88.983 Y103.884 E.00892
; LINE_WIDTH: 0.407545
G1 F9873.158
G1 X88.949 Y103.816 E.00226
; LINE_WIDTH: 0.443755
G1 F8981.252
G1 X88.914 Y103.748 E.00248
M204 S10000
G1 X89.197 Y103.526 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X89.428 Y104.713 I-1.416 J.892 E.04102
G2 X90 Y105.365 I8.874 J-7.203 E.02878
G1 X89.994 Y105.358 E.00031
G2 X90.57 Y104.705 I-2.145 J-2.475 E.02899
G3 X90.797 Y103.534 I1.655 J-.287 E.04046
M204 S10000
G1 X98.944 Y94.779 F42000
G1 F8843.478
M204 S6000
G1 X100.573 Y94.779 E.05401
G1 X92.209 Y103.142 E.39233
G2 X94.846 Y102.522 I-2.329 J-15.822 E.08997
G1 X87.103 Y94.779 E.36324
G1 X85.221 Y94.779 E.06245
G1 X80.187 Y99.813 E.23613
G3 X76.631 Y95.693 I9.977 J-12.208 E.18144
G1 X78.085 Y94.239 E.0682
G3 X77.97 Y93.322 I1.985 J-.715 E.03093
G1 X74.608 Y89.96 E.1577
G1 X74.617 Y90.031 E.00238
G1 X77.97 Y86.678 E.15728
G1 X77.97 Y85.646 E.03426
G1 X75.228 Y82.904 E.12864
G3 X76.012 Y80.96 I25.929 J9.336 E.06953
G1 X83.21 Y73.762 E.33768
G3 X87.719 Y72.367 I6.872 J14.228 E.15714
G1 X96.072 Y80.72 E.39184
G1 X99.28 Y80.72 E.10644
G1 X102.063 Y77.937 E.13053
G2 X97.943 Y74.381 I-12.208 J9.977 E.18144
G1 X91.604 Y80.72 E.29737
G1 X88.396 Y80.72 E.10644
G1 X82.057 Y74.381 E.29737
G2 X77.937 Y77.937 I8.088 J13.534 E.18144
G1 X80.722 Y80.722 E.13064
G3 X83.928 Y80.72 I2.216 J829.129 E.10636
G1 X92.27 Y72.378 E.3913
G3 X96.79 Y73.762 I-2.165 J15.148 E.15744
G1 X103.988 Y80.96 E.33768
G3 X104.772 Y82.904 I-25.141 J11.278 E.06953
G1 X102.029 Y85.647 E.12868
G1 X102.029 Y86.677 E.03419
G1 X105.383 Y90.031 E.15733
G1 X105.392 Y89.96 E.00238
G1 X102.029 Y93.323 E.15774
G3 X101.915 Y94.239 I-2.101 J.202 E.03088
G1 X103.369 Y95.693 E.06824
G3 X99.813 Y99.813 I-13.534 J-8.088 E.18144
G1 X94.779 Y94.779 E.23613
G1 X92.897 Y94.779 E.06245
G1 X85.154 Y102.522 E.36324
G2 X87.777 Y103.129 I5.579 J-18.157 E.08939
G1 X79.427 Y94.779 E.39169
G1 X81.056 Y94.779 E.05401
; WIPE_START
G1 X79.427 Y94.779 E-.61876
G1 X79.69 Y95.042 E-.14124
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.4 I1.212 J-.113 P1  F42000
G1 X78.401 Y81.206 Z3.4
G1 Z3
G1 E.8 F1800
; FEATURE: Bridge
; LINE_WIDTH: 0.40485
; LAYER_HEIGHT: 0.4
M106 S255
G1 F1200
M204 S6000
G1 X78.401 Y93.762 E.65856
G1 X78.46 Y94.031 E.01445
G2 X78.856 Y94.33 I.492 J-.241 E.02698
G1 X78.856 Y81.169 E.69026
G1 X78.908 Y81.154 E.00287
G1 X79.31 Y81.153 E.02109
G1 X79.31 Y94.351 E.69219
G1 X79.765 Y94.351 E.02386
G1 X79.765 Y81.153 E.69223
G1 X80.22 Y81.152 E.02386
G1 X80.22 Y94.351 E.69228
G1 X80.675 Y94.351 E.02386
G1 X80.675 Y81.151 E.69233
G1 X81.13 Y81.15 E.02386
G1 X81.13 Y94.351 E.69237
G1 X81.585 Y94.351 E.02386
G1 X81.585 Y81.149 E.69242
G1 X82.04 Y81.148 E.02386
G1 X82.04 Y94.351 E.69246
G1 X82.494 Y94.351 E.02386
G1 X82.494 Y81.148 E.69246
G1 X82.949 Y81.148 E.02386
G1 X82.949 Y94.351 E.69246
G1 X83.404 Y94.351 E.02386
G1 X83.404 Y81.148 E.69246
G1 X83.859 Y81.148 E.02386
G1 X83.859 Y94.351 E.69246
G1 X84.314 Y94.351 E.02386
G1 X84.314 Y81.148 E.69246
G1 X84.769 Y81.148 E.02386
G1 X84.769 Y94.351 E.69246
G1 X85.224 Y94.351 E.02386
G1 X85.224 Y81.148 E.69246
G1 X85.678 Y81.148 E.02386
G1 X85.678 Y94.351 E.69246
G1 X86.133 Y94.351 E.02386
G1 X86.133 Y81.148 E.69246
G1 X86.588 Y81.148 E.02386
G1 X86.588 Y94.351 E.69246
G1 X87.043 Y94.351 E.02386
G1 X87.043 Y81.148 E.69246
G1 X87.498 Y81.148 E.02386
G1 X87.498 Y94.351 E.69246
G1 X87.953 Y94.351 E.02386
G1 X87.953 Y81.148 E.69246
G1 X88.407 Y81.148 E.02386
G1 X88.407 Y94.351 E.69246
G1 X88.862 Y94.351 E.02386
G1 X88.862 Y81.148 E.69246
G1 X89.317 Y81.148 E.02386
G1 X89.317 Y94.351 E.69246
G1 X89.772 Y94.351 E.02386
G1 X89.772 Y81.148 E.69246
G1 X90.227 Y81.148 E.02386
G1 X90.227 Y94.351 E.69246
G1 X90.682 Y94.351 E.02386
G1 X90.682 Y81.148 E.69246
G1 X91.137 Y81.148 E.02386
G1 X91.137 Y94.351 E.69246
G1 X91.591 Y94.351 E.02386
G1 X91.591 Y81.148 E.69246
G1 X92.046 Y81.148 E.02386
M73 P64 R7
G1 X92.046 Y94.351 E.69246
G1 X92.501 Y94.351 E.02386
G1 X92.501 Y81.148 E.69246
G1 X92.956 Y81.148 E.02386
G1 X92.956 Y94.351 E.69246
G1 X93.411 Y94.351 E.02386
G1 X93.411 Y81.148 E.69246
G1 X93.866 Y81.148 E.02386
G1 X93.866 Y94.351 E.69246
G1 X94.321 Y94.351 E.02386
G1 X94.321 Y81.148 E.69246
G1 X94.775 Y81.148 E.02386
G1 X94.775 Y94.351 E.69246
G1 X95.23 Y94.351 E.02386
G1 X95.23 Y81.148 E.69246
G1 X95.685 Y81.148 E.02386
G1 X95.685 Y94.351 E.69246
G1 X96.14 Y94.351 E.02386
G1 X96.14 Y81.148 E.69246
G1 X96.595 Y81.148 E.02386
G1 X96.595 Y94.351 E.69246
G1 X97.05 Y94.351 E.02386
G1 X97.05 Y81.148 E.69246
G1 X97.504 Y81.148 E.02386
G1 X97.504 Y94.351 E.69246
G1 X97.959 Y94.351 E.02386
G1 X97.959 Y81.148 E.69246
G1 X98.414 Y81.148 E.02386
G1 X98.414 Y94.351 E.69246
G1 X98.869 Y94.351 E.02386
G1 X98.869 Y81.148 E.69246
G1 X99.324 Y81.148 E.02386
G1 X99.324 Y94.351 E.69246
G1 X99.779 Y94.351 E.02386
G1 X99.779 Y81.148 E.69246
G1 X100.234 Y81.148 E.02386
G1 X100.234 Y94.351 E.69246
M73 P65 R7
G1 X100.688 Y94.351 E.02386
G1 X100.688 Y81.148 E.69246
G3 X101.143 Y81.169 I.164 J1.387 E.02399
G1 X101.143 Y94.33 E.69027
G2 X101.539 Y94.031 I-.097 J-.54 E.02699
G1 X101.598 Y93.763 E.0144
G1 X101.598 Y81.206 E.65861
M106 S175.95
M204 S10000
G1 X91.112 Y71.804 F42000
; Slow Down Start
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.408617
; LAYER_HEIGHT: 0.2
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G1 X91.06 Y71.719 E.00297
G1 X90.965 Y71.377 E.01058
G1 X90.963 Y70.748 E.01874
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.437114
;_EXTRUDE_SET_SPEED
G1 X90.948 Y70.71 E.00131
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.47598
;_EXTRUDE_SET_SPEED
G1 X90.934 Y70.672 E.00144
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.514847
;_EXTRUDE_SET_SPEED
G1 X90.92 Y70.634 E.00157
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.39739
;_EXTRUDE_SET_SPEED
G1 X90.465 Y69.973 E.02317
; Slow Down End
M204 S10000
G1 X90.431 Y69.924 F42000
; Slow Down Start
; LINE_WIDTH: 0.514168
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G1 X90.257 Y69.827 E.00765
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.482972
;_EXTRUDE_SET_SPEED
G1 X90.082 Y69.731 E.00715
G1 X89.894 Y69.735 E.00676
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.476089
;_EXTRUDE_SET_SPEED
G1 X89.564 Y69.928 E.0135
G1 X89.69 Y69.656 E.01057
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.463215
;_EXTRUDE_SET_SPEED
G1 X90 Y69.138 E.02069
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.473943
;_EXTRUDE_SET_SPEED
G1 X90.099 Y69.296 E.00657
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.499831
;_EXTRUDE_SET_SPEED
G3 X90.405 Y69.87 I-2.551 J1.724 E.02426
; Slow Down End
M204 S10000
G1 X89.564 Y69.928 F42000
; Slow Down Start
; LINE_WIDTH: 0.51236
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G1 X89.391 Y70.19 E.01202
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.47464
;_EXTRUDE_SET_SPEED
G1 X89.218 Y70.453 E.01105
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.43692
;_EXTRUDE_SET_SPEED
G1 X89.045 Y70.715 E.01009
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.42075
;_EXTRUDE_SET_SPEED
G1 X89.04 Y71.044 E.01013
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.397801
;_EXTRUDE_SET_SPEED
G3 X88.976 Y71.645 I-1.515 J.141 E.01758
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.407637
;_EXTRUDE_SET_SPEED
G1 X88.952 Y71.687 E.00144
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.45707
;_EXTRUDE_SET_SPEED
G1 X88.928 Y71.729 E.00163
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.506504
;_EXTRUDE_SET_SPEED
G1 X88.904 Y71.77 E.00183
; Slow Down End
; CHANGE_LAYER
; Z_HEIGHT: 3.2
; LAYER_HEIGHT: 0.2
; WIPE_START
M73 P66 R7
G1 F1200
G1 X88.928 Y71.729 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 16/25
; update layer progress
M73 L16
M991 S0 P15 ;notify layer change
M106 S196.35
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z3.4 I-1.208 J-.151 P1  F42000
G1 X84.285 Y108.899 Z3.4
G1 Z3.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X111.897 Y87.79 I5.787 J-21.115 E3.22945
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.234 Y110.067 E.02515
G3 X84.637 Y109.352 I-5.233 J-1.319 E.49814
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.112 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.892 J-21.493 E3.04525
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.119 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25113
G1 X82.491 Y108.737 E-.41561
M73 P66 R6
G1 X82.262 Y108.649 E-.09326
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X87.779 Y106.213 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G3 X82.895 Y104.942 I2.15 J-18.271 E.16794
G3 X87.779 Y69.287 I7.104 J-17.189 E1.62259
G3 X88.969 Y67.427 I19.161 J10.954 E.07327
G1 X89.374 Y67.029 E.01884
G1 X89.645 Y66.884 E.01018
G1 X90.076 Y66.803 E.01456
G1 X90.496 Y66.942 E.01467
G1 X90.677 Y67.067 E.00728
G1 X91.033 Y67.433 E.01694
G3 X92.221 Y69.287 I-15.712 J11.379 E.07307
G3 X92.221 Y106.213 I-2.217 J18.463 E1.79046
G3 X91.637 Y107.19 I-29.109 J-16.739 E.03774
G3 X90.821 Y108.306 I-5.707 J-3.318 E.04595
G1 X90.47 Y108.572 E.01461
G3 X89.923 Y108.696 I-.506 J-.962 E.0188
G1 X89.682 Y108.638 E.00823
G1 X89.35 Y108.462 E.01246
G1 X88.89 Y107.969 E.02238
G3 X87.809 Y106.265 I18.053 J-12.655 E.06695
M204 S250
G1 X88.022 Y105.852 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X88.02 Y105.848 E.00015
G3 X83.036 Y104.576 I1.931 J-17.961 E.15857
G3 X88.02 Y69.652 I6.966 J-16.823 E1.477
G1 X88.372 Y69.05 E.02144
G3 X89.287 Y67.657 I10.592 J5.961 E.05126
G1 X89.315 Y67.629 E.0012
G1 X89.344 Y67.602 E.0012
G1 X89.372 Y67.575 E.0012
G1 X89.4 Y67.548 E.0012
G1 X89.428 Y67.521 E.0012
G1 X89.457 Y67.494 E.0012
G1 X89.485 Y67.467 E.0012
G1 X89.513 Y67.44 E.0012
G1 X89.541 Y67.412 E.0012
G1 X89.569 Y67.385 E.0012
G1 X89.598 Y67.358 E.0012
G1 X89.626 Y67.331 E.0012
G3 X89.664 Y67.305 I.043 J.022 E.00149
G1 X89.749 Y67.281 E.00272
G1 X89.835 Y67.258 E.00272
G1 X89.92 Y67.235 E.00272
G1 X90.006 Y67.212 E.00272
G3 X90.11 Y67.214 I.051 J.066 E.00346
G1 X90.17 Y67.241 E.00201
G1 X90.229 Y67.267 E.00201
G1 X90.289 Y67.294 E.00201
G1 X90.349 Y67.32 E.00201
G3 X90.402 Y67.347 I-.007 J.079 E.00188
G1 X90.431 Y67.377 E.00128
G1 X90.46 Y67.407 E.00128
G1 X90.49 Y67.437 E.00128
M73 P67 R6
G1 X90.519 Y67.467 E.00128
G1 X90.548 Y67.497 E.00128
G1 X90.577 Y67.527 E.00128
G1 X90.606 Y67.557 E.00128
G1 X90.635 Y67.587 E.00128
G1 X90.664 Y67.617 E.00128
G1 X90.694 Y67.647 E.00128
G1 X90.723 Y67.677 E.00128
G1 X90.752 Y67.706 E.00128
G3 X91.98 Y69.652 I-17.567 J12.454 E.07074
G3 X91.98 Y105.848 I-1.976 J18.098 E1.63568
G3 X90.907 Y107.587 I-24.093 J-13.68 E.06281
G1 X90.869 Y107.633 E.00183
G1 X90.83 Y107.679 E.00183
G1 X90.792 Y107.725 E.00183
G1 X90.754 Y107.771 E.00183
G1 X90.716 Y107.817 E.00183
G1 X90.678 Y107.863 E.00183
G1 X90.64 Y107.909 E.00183
G1 X90.602 Y107.955 E.00183
G1 X90.564 Y108.001 E.00183
G1 X90.526 Y108.047 E.00183
G3 X90.47 Y108.086 I-.088 J-.066 E.00214
G1 X90.41 Y108.124 E.00218
G1 X90.35 Y108.162 E.00218
G1 X90.29 Y108.2 E.00218
G1 X90.231 Y108.238 E.00218
G1 X90.171 Y108.276 E.00218
G1 X89.855 Y108.285 E.00971
G1 X89.829 Y108.272 E.00089
G1 X89.769 Y108.239 E.00209
G1 X89.709 Y108.207 E.00209
G1 X89.65 Y108.174 E.00209
G1 X89.59 Y108.142 E.00209
G3 X89.545 Y108.107 I.027 J-.081 E.00178
G1 X89.512 Y108.071 E.00151
G1 X89.479 Y108.034 E.00152
G1 X89.445 Y107.998 E.00151
G1 X89.412 Y107.961 E.00152
G1 X89.379 Y107.925 E.00152
G1 X89.346 Y107.888 E.00151
G1 X89.313 Y107.852 E.00152
G1 X89.28 Y107.815 E.00152
G1 X89.247 Y107.779 E.00152
G1 X89.214 Y107.742 E.00152
G3 X88.693 Y106.966 I19.091 J-13.359 E.02872
G1 X88.053 Y105.903 E.03811
; WIPE_START
M204 S6000
G1 X88.02 Y105.848 E-.0246
G1 X87.33 Y105.763 E-.26414
G1 X86.452 Y105.611 E-.33855
G1 X86.111 Y105.535 E-.13272
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X92.986 Y108.85 Z3.6 F42000
G1 X94.196 Y109.433 Z3.6
G1 Z3.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.85 J-.924 E.03357
G1 X93.721 Y111.457 E.02249
G1 X93.397 Y111.841 E.01666
G1 X92.776 Y112.419 E.02815
G1 X92.353 Y112.695 E.01673
G1 X91.59 Y113.067 E.02817
G1 X91.107 Y113.207 E.01669
G1 X90.268 Y113.343 E.02818
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.02818
G1 X88.441 Y113.071 E.01677
G1 X87.671 Y112.718 E.0281
G1 X87.256 Y112.433 E.01671
G1 X86.562 Y111.808 E.03097
G3 X85.563 Y109.932 I3.536 J-3.089 E.07111
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X93.759 Y109.316 I3.838 J-21.837 E.25431
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.02431
G3 X86.871 Y111.566 I-3.391 J-2.528 E.22901
G3 X86.201 Y110.562 I3.129 J-2.816 E.03724
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.787 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.123 E.23768
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05567
G1 X94.037 Y109.947 E-.06472
G1 X93.789 Y110.564 E-.25268
G1 X93.389 Y111.247 E-.3006
G1 X93.241 Y111.419 E-.08633
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.6 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z3.6
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z3.6 F4000
            G39.3 S1
            G0 Z3.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X94.84 Y109.845 F42000
G1 Z3.2
G1 E.8 F1800
; Slow Down Start
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.47389
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G1 X94.842 Y109.872 E.00097
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.43673
;_EXTRUDE_SET_SPEED
G1 X94.843 Y109.9 E.00088
G3 X94.281 Y111.317 I-4.467 J-.95 E.04915
G1 X94.006 Y111.74 E.01618
G1 X93.523 Y112.292 E.02355
G1 X93.014 Y112.736 E.02168
G3 X92.135 Y113.263 I-3.218 J-4.367 E.03296
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.43129
;_EXTRUDE_SET_SPEED
G1 X91.614 Y113.476 E.01779
G3 X88.024 Y113.329 I-1.601 J-4.81 E.11624
G1 X87.416 Y113.029 E.02148
G1 X86.866 Y112.64 E.02131
G1 X86.307 Y112.118 E.0242
G3 X85.457 Y110.832 I4.604 J-3.964 E.04894
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.44295
;_EXTRUDE_SET_SPEED
G1 X85.314 Y110.422 E.01415
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.4686
;_EXTRUDE_SET_SPEED
G1 X85.171 Y110.012 E.01506
G1 X85.161 Y109.9 E.00389
; Slow Down End
M204 S10000
G1 X82.521 Y105.155 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X80.558 Y107.118 E.09209
G2 X82.047 Y107.775 I10.33 J-21.416 E.054
; WIPE_START
G1 X80.558 Y107.118 E-.6185
G1 X80.821 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.373 Y107.961 Z3.6 F42000
G1 X91.198 Y108.375 Z3.6
G1 Z3.2
G1 E.8 F1800
; Slow Down Start
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.404287
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G1 X91.131 Y108.456 E.00309
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.44702
;_EXTRUDE_SET_SPEED
G1 X91.065 Y108.537 E.00345
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.489754
;_EXTRUDE_SET_SPEED
G1 X90.998 Y108.618 E.00382
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.532487
;_EXTRUDE_SET_SPEED
G1 X90.932 Y108.699 E.00418
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.57522
;_EXTRUDE_SET_SPEED
G1 X90.865 Y108.78 E.00455
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.559338
;_EXTRUDE_SET_SPEED
G1 X90.799 Y108.861 E.00441
G1 X90.456 Y109.118 E.01804
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.631191
;_EXTRUDE_SET_SPEED
G1 X90 Y109.169 E.02198
G1 X89.659 Y109.138 E.01639
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.618004
;_EXTRUDE_SET_SPEED
G1 X89.639 Y109.136 E.00094
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.57705
;_EXTRUDE_SET_SPEED
G1 X89.619 Y109.134 E.00088
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.536097
;_EXTRUDE_SET_SPEED
G1 X89.599 Y109.133 E.00081
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.624407
;_EXTRUDE_SET_SPEED
G1 X89.549 Y109.1 E.00285
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.5805
;_EXTRUDE_SET_SPEED
G1 X89.499 Y109.067 E.00263
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.536594
;_EXTRUDE_SET_SPEED
G1 X89.448 Y109.034 E.00242
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.492687
;_EXTRUDE_SET_SPEED
G1 X89.398 Y109.001 E.0022
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.44878
;_EXTRUDE_SET_SPEED
G1 X89.348 Y108.969 E.00199
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.404874
;_EXTRUDE_SET_SPEED
G1 X89.297 Y108.936 E.00177
; Slow Down End
; WIPE_START
G1 X89.348 Y108.969 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X93.142 Y106.43 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X92.432 Y106.536 I-1.46 J-7.357 E.02383
G1 X91.965 Y107.317 E.03019
G1 X93.634 Y108.986 E.07834
G3 X94.045 Y108.983 I.215 J1.223 E.01368
G1 X98.197 Y104.831 E.19477
G2 X102.223 Y102.223 I-9.715 J-19.404 E.15945
G1 X104.068 Y104.068 E.08658
G2 X107.704 Y100.028 I-16.104 J-18.153 E.18067
G1 X105.831 Y98.155 E.08787
G2 X107.081 Y95.947 I-16.99 J-11.072 E.08424
G1 X111.151 Y91.876 E.19094
G3 X110.31 Y94.958 I-38.255 J-8.797 E.10598
G1 X108.234 Y92.882 E.09735
G2 X108.61 Y91.299 I-21.376 J-5.904 E.054
M204 S10000
G1 X111.53 Y86.877 F42000
G1 F8843.478
M204 S6000
G3 X111.533 Y88.505 I-16.638 J.843 E.05402
G1 X108.847 Y85.82 E.12599
G3 X108.898 Y86.454 I-6.446 J.832 E.02112
G1 X111.236 Y84.116 E.1097
G2 X109.676 Y78.972 I-23.891 J4.439 E.17866
G1 X98.778 Y68.074 E.51125
G2 X97.208 Y67.44 I-11.401 J25.994 E.05618
G1 X95.132 Y69.516 E.09737
G3 X100.405 Y71.919 I-5.161 J18.315 E.19298
G1 X102.278 Y70.046 E.08787
G3 X106.318 Y73.682 I-14.113 J19.74 E.18067
G1 X104.473 Y75.527 E.08658
G3 X107.405 Y80.271 I-14.576 J12.289 E.18566
G1 X109.368 Y78.308 E.09209
; WIPE_START
G1 X107.954 Y79.722 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X101.712 Y75.329 Z3.6 F42000
G1 X89.275 Y66.575 Z3.6
G1 Z3.2
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.53494
G1 F7316.776
M204 S6000
G1 X89.559 Y66.377 E.01387
; LINE_WIDTH: 0.658588
G1 F5847.306
G1 X90.065 Y66.332 E.02551
; LINE_WIDTH: 0.600262
G1 F6459.239
G1 X90.431 Y66.391 E.01684
G1 X90.703 Y66.565 E.01463
; WIPE_START
G1 X90.431 Y66.391 E-.35334
G1 X90.065 Y66.332 E-.40666
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X83.567 Y70.336 Z3.6 F42000
G1 X70.632 Y78.308 Z3.6
G1 Z3.2
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X72.595 Y80.271 E.09209
G3 X75.527 Y75.527 I17.509 J7.545 E.18566
G1 X73.682 Y73.682 E.08658
G3 X77.722 Y70.046 I18.153 J16.105 E.18067
G1 X79.595 Y71.919 E.08787
G3 X84.868 Y69.516 I10.433 J15.91 E.19298
G1 X82.792 Y67.44 E.09737
G2 X81.222 Y68.074 I9.83 J26.627 E.05618
G1 X70.324 Y78.972 E.51125
G2 X68.764 Y84.116 I22.33 J9.583 E.17866
G1 X71.102 Y86.454 E.1097
G3 X71.153 Y85.82 I6.522 J.199 E.02112
G1 X68.467 Y88.505 E.12599
G3 X68.47 Y86.877 I16.64 J-.785 E.05402
M204 S10000
G1 X71.39 Y91.299 F42000
G1 F8843.478
M204 S6000
G2 X71.766 Y92.882 I21.757 J-4.321 E.054
G1 X69.69 Y94.958 E.09735
G3 X68.849 Y91.876 I37.421 J-11.88 E.10598
G1 X72.919 Y95.947 E.19094
G2 X74.169 Y98.155 I18.238 J-8.863 E.08424
G1 X72.296 Y100.028 E.08787
G2 X75.932 Y104.068 I19.741 J-14.113 E.18067
G1 X77.777 Y102.223 E.08658
G2 X81.803 Y104.831 I13.738 J-16.791 E.15945
G1 X85.955 Y108.983 E.19477
G3 X86.366 Y108.986 I.195 J1.225 E.01368
G1 X88.035 Y107.317 E.07832
G1 X87.568 Y106.536 E.03019
G3 X86.858 Y106.43 I.748 J-7.454 E.02382
; WIPE_START
G1 X87.568 Y106.536 E-.27279
G1 X88.035 Y107.317 E-.3459
G1 X87.772 Y107.58 E-.14132
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X95.177 Y105.73 Z3.6 F42000
G1 X97.479 Y105.155 Z3.6
G1 Z3.2
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X99.442 Y107.118 E.09209
G3 X97.953 Y107.775 I-10.327 J-21.408 E.054
; WIPE_START
G1 X99.442 Y107.118 E-.6185
G1 X99.179 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X91.546 Y106.839 Z3.6 F42000
G1 X90 Y106.836 Z3.6
G1 Z3.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X89.811 Y106.627 E.00935
G3 X88.698 Y104.889 I19.327 J-13.596 E.0685
G1 X88.698 Y104.116 E.02562
G2 X88.424 Y103.623 I-.628 J.026 E.01941
G1 X88.197 Y103.541 E.00801
G3 X88.219 Y71.955 I1.8 J-15.792 E1.53738
G1 X88.488 Y71.831 E.00983
G1 X88.656 Y71.6 E.00946
G1 X88.698 Y71.384 E.00732
G1 X88.698 Y70.611 E.02562
G3 X89.725 Y68.988 I22.906 J13.359 E.06374
G1 X89.997 Y68.666 E.01397
G1 X90.137 Y68.806 E.00657
G3 X91.302 Y70.611 I-17.626 J12.659 E.0713
G1 X91.302 Y71.384 E.02562
G2 X91.624 Y71.904 I.619 J-.024 E.02122
G2 X92.72 Y72.092 I1.855 J-7.517 E.03693
G3 X105.888 Y88.142 I-2.734 J15.67 E.75027
G3 X91.781 Y103.545 I-15.878 J-.381 E.75606
G1 X91.512 Y103.669 E.00983
G1 X91.344 Y103.9 E.00946
G1 X91.302 Y104.116 E.00732
G1 X91.302 Y104.889 E.02562
G3 X90.263 Y106.529 I-22.469 J-13.093 E.06442
G1 X90.039 Y106.791 E.01143
M204 S250
G1 X90.01 Y107.295 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.854 Y107.237 E.00509
G1 X89.503 Y106.871 E.01559
G3 X88.306 Y104.998 I20.511 J-14.421 E.06834
G1 X88.306 Y104.116 E.02708
G1 X88.238 Y103.971 E.00493
G1 X87.994 Y103.911 E.00771
G3 X87.994 Y71.589 I2.012 J-16.161 E1.4481
G1 X88.238 Y71.529 E.00772
G1 X88.306 Y71.384 E.00493
G1 X88.306 Y70.502 E.02708
G3 X89.423 Y68.736 I24.339 J14.148 E.06424
G1 X89.753 Y68.348 E.01565
G1 X89.947 Y68.204 E.00742
G1 X90.085 Y68.229 E.00432
G1 X90.438 Y68.554 E.01474
G3 X91.694 Y70.502 I-18.752 J13.462 E.07127
G1 X91.694 Y71.384 E.02708
G1 X91.762 Y71.529 E.00493
G1 X92.006 Y71.589 E.00771
G3 X106.28 Y88.151 I-2.01 J16.164 E.7365
G3 X92.006 Y103.911 I-16.284 J-.405 E.71182
G1 X91.762 Y103.971 E.00772
G1 X91.694 Y104.116 E.00493
G1 X91.694 Y104.998 E.02708
G3 X90.564 Y106.782 I-23.899 J-13.88 E.06492
G1 X90.207 Y107.196 E.01679
G1 X90.063 Y107.268 E.00495
; WIPE_START
M204 S6000
G1 X89.854 Y107.237 E-.08024
G1 X89.503 Y106.871 E-.19285
G1 X89.053 Y106.218 E-.30134
G1 X88.798 Y105.802 E-.18557
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.753 Y104.938 Z3.6 F42000
G1 Z3.2
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.546464
G1 F7149.333
M204 S6000
G1 X90.841 Y104.759 E.00817
G1 X90.85 Y104.214 E.0224
; LINE_WIDTH: 0.51609
G1 F7608.259
G1 X90.916 Y103.876 E.01326
; LINE_WIDTH: 0.475124
G1 F8329.413
G1 X90.961 Y103.81 E.00282
; LINE_WIDTH: 0.44109
G1 F9041.365
G1 X91.006 Y103.744 E.0026
; LINE_WIDTH: 0.407057
G1 F9886.397
G1 X91.051 Y103.677 E.00237
M204 S10000
G1 X90.753 Y104.938 F42000
; LINE_WIDTH: 0.514406
G1 F7635.433
M204 S6000
G3 X90.004 Y106.131 I-14.491 J-8.266 E.05413
; LINE_WIDTH: 0.535218
G1 F7312.651
G1 X89.874 Y105.944 E.00911
; LINE_WIDTH: 0.54587
G1 F7157.78
G1 X89.744 Y105.758 E.00931
G1 X89.5 Y105.268 E.02245
G1 X89.775 Y105.425 E.01297
; LINE_WIDTH: 0.515654
G1 F7615.278
G1 X90.064 Y105.481 E.01134
G1 X90.347 Y105.334 E.0123
G1 X90.71 Y104.98 E.01954
M204 S10000
G1 X89.013 Y103.729 F42000
; LINE_WIDTH: 0.44975
G1 F8848.905
M204 S6000
G1 X89.075 Y103.915 E.00648
; LINE_WIDTH: 0.49233
G1 F8010.503
G1 X89.136 Y104.1 E.00716
; LINE_WIDTH: 0.527651
G1 F7426.801
G1 X89.149 Y104.717 E.02435
G1 X89.213 Y104.876 E.00679
; LINE_WIDTH: 0.54861
G1 F7118.986
G1 X89.338 Y105.047 E.00871
; LINE_WIDTH: 0.58831
G1 F6600.781
G1 X89.463 Y105.217 E.00939
M204 S10000
G1 X98.944 Y94.779 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X100.573 Y94.779 E.05401
G1 X92.209 Y103.142 E.39233
G2 X94.846 Y102.522 I-2.327 J-15.816 E.08997
G1 X87.103 Y94.779 E.36324
G1 X85.221 Y94.779 E.06245
G1 X80.187 Y99.813 E.23613
G3 X76.631 Y95.693 I9.977 J-12.208 E.18144
G1 X78.085 Y94.239 E.0682
G3 X77.97 Y93.322 I1.985 J-.715 E.03093
G1 X74.608 Y89.96 E.1577
G1 X74.617 Y90.031 E.00238
G1 X77.97 Y86.678 E.15728
G1 X77.97 Y85.646 E.03426
G1 X75.228 Y82.904 E.12864
G3 X76.012 Y80.96 I25.929 J9.336 E.06953
G1 X83.21 Y73.762 E.33768
G3 X87.719 Y72.367 I6.872 J14.227 E.15714
G1 X96.072 Y80.72 E.39184
G1 X99.28 Y80.72 E.10644
G1 X102.063 Y77.937 E.13053
G2 X97.943 Y74.381 I-12.208 J9.977 E.18144
G1 X91.604 Y80.72 E.29737
G1 X88.396 Y80.72 E.10644
G1 X82.057 Y74.381 E.29737
G2 X77.937 Y77.937 I8.088 J13.534 E.18144
G1 X80.722 Y80.722 E.13064
G3 X83.928 Y80.72 I2.216 J829.129 E.10636
G1 X92.281 Y72.367 E.39184
G3 X96.79 Y73.762 I-2.363 J15.622 E.15714
G1 X103.988 Y80.96 E.33768
G3 X104.772 Y82.904 I-25.141 J11.278 E.06953
G1 X102.029 Y85.647 E.12868
G1 X102.029 Y86.677 E.03419
G1 X105.383 Y90.031 E.15733
G1 X105.392 Y89.96 E.00238
G1 X102.029 Y93.323 E.15774
G3 X101.915 Y94.239 I-2.101 J.202 E.03088
G1 X103.369 Y95.693 E.06824
G3 X99.813 Y99.813 I-13.534 J-8.088 E.18144
G1 X94.779 Y94.779 E.23613
G1 X92.897 Y94.779 E.06245
G1 X85.154 Y102.522 E.36324
G2 X87.791 Y103.142 I4.964 J-15.194 E.08997
G1 X79.427 Y94.779 E.39233
G1 X81.056 Y94.779 E.05401
M204 S10000
G1 X78.206 Y81.631 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42101
G1 F9521.543
M204 S6000
G3 X78.722 Y81.169 I1.758 J1.447 E.02139
G1 X78.902 Y81.118 E.00577
G3 X79.254 Y81.117 I.18 J1.269 E.01089
G1 X78.362 Y82.01 E.03889
G1 X78.362 Y82.544 E.01647
G1 X79.79 Y81.116 E.06223
G1 X80.326 Y81.115 E.01651
G1 X78.362 Y83.079 E.08558
G1 X78.362 Y83.614 E.01647
G1 X80.862 Y81.114 E.10892
G1 X81.397 Y81.113 E.01651
G1 X78.362 Y84.148 E.13226
G1 X78.362 Y84.683 E.01647
G1 X81.933 Y81.112 E.15561
G1 X82.468 Y81.112 E.01647
G1 X78.362 Y85.218 E.1789
G1 X78.362 Y85.752 E.01647
G1 X83.002 Y81.112 E.2022
G1 X83.537 Y81.112 E.01647
G1 X78.362 Y86.287 E.2255
G1 X78.362 Y86.822 E.01647
G1 X84.072 Y81.112 E.2488
G1 X84.607 Y81.112 E.01647
G1 X78.362 Y87.357 E.27209
G1 X78.362 Y87.891 E.01647
G1 X85.141 Y81.112 E.29539
G1 X85.676 Y81.112 E.01647
G1 X78.362 Y88.426 E.31869
G1 X78.362 Y88.961 E.01647
G1 X86.211 Y81.112 E.34199
G1 X86.745 Y81.112 E.01647
G1 X78.362 Y89.495 E.36529
G1 X78.362 Y90.03 E.01647
G1 X87.28 Y81.112 E.38858
G1 X87.815 Y81.112 E.01647
G1 X78.362 Y90.565 E.41188
G1 X78.362 Y91.099 E.01647
G1 X88.349 Y81.112 E.43518
G1 X88.884 Y81.112 E.01647
G1 X78.362 Y91.634 E.45848
G1 X78.362 Y92.169 E.01647
G1 X89.419 Y81.112 E.48177
G1 X89.954 Y81.112 E.01647
G1 X78.362 Y92.704 E.50507
G1 X78.362 Y93.238 E.01647
G1 X90.488 Y81.112 E.52837
G1 X91.023 Y81.112 E.01647
M73 P68 R6
G1 X78.365 Y93.77 E.55153
G1 X78.426 Y94.045 E.00868
G1 X78.509 Y94.161 E.00439
G1 X91.558 Y81.112 E.56856
G1 X92.092 Y81.112 E.01647
G1 X78.841 Y94.363 E.5774
G1 X78.981 Y94.387 E.00439
G1 X79.351 Y94.387 E.01142
G1 X92.627 Y81.112 E.57843
G1 X93.162 Y81.112 E.01647
G1 X79.886 Y94.387 E.57843
G1 X80.421 Y94.387 E.01647
G1 X93.696 Y81.112 E.57843
G1 X94.231 Y81.112 E.01647
G1 X80.956 Y94.387 E.57843
G1 X81.49 Y94.387 E.01647
G1 X94.766 Y81.112 E.57843
G1 X95.301 Y81.112 E.01647
G1 X82.025 Y94.387 E.57843
G1 X82.56 Y94.387 E.01647
G1 X95.835 Y81.112 E.57843
G1 X96.37 Y81.112 E.01647
G1 X83.094 Y94.387 E.57843
G1 X83.629 Y94.387 E.01647
G1 X96.905 Y81.112 E.57843
G1 X97.439 Y81.112 E.01647
G1 X84.164 Y94.387 E.57843
G1 X84.698 Y94.387 E.01647
G1 X97.974 Y81.112 E.57843
G1 X98.509 Y81.112 E.01647
G1 X85.233 Y94.387 E.57843
G1 X85.768 Y94.387 E.01647
G1 X99.043 Y81.112 E.57843
G1 X99.578 Y81.112 E.01647
G1 X86.303 Y94.387 E.57843
G1 X86.837 Y94.387 E.01647
G1 X100.113 Y81.112 E.57843
G1 X100.648 Y81.112 E.01647
G1 X87.372 Y94.387 E.57843
G1 X87.907 Y94.387 E.01647
G1 X101.158 Y81.135 E.5774
G3 X101.454 Y81.291 I-.084 J.517 E.01046
G1 X101.49 Y81.338 E.00185
G1 X88.441 Y94.387 E.56856
G1 X88.976 Y94.387 E.01647
G1 X101.636 Y81.728 E.5516
G1 X101.637 Y82.261 E.01643
G1 X89.511 Y94.387 E.52837
G1 X90.045 Y94.387 E.01647
G1 X101.637 Y82.795 E.50507
G1 X101.637 Y83.33 E.01647
G1 X90.58 Y94.387 E.48177
G1 X91.115 Y94.387 E.01647
G1 X101.637 Y83.865 E.45848
G1 X101.637 Y84.4 E.01647
G1 X91.65 Y94.387 E.43518
G1 X92.184 Y94.387 E.01647
G1 X101.637 Y84.934 E.41188
G1 X101.637 Y85.469 E.01647
G1 X92.719 Y94.387 E.38858
G1 X93.254 Y94.387 E.01647
G1 X101.637 Y86.004 E.36529
G1 X101.637 Y86.538 E.01647
G1 X93.788 Y94.387 E.34199
G1 X94.323 Y94.387 E.01647
G1 X101.637 Y87.073 E.31869
G1 X101.637 Y87.608 E.01647
G1 X94.858 Y94.387 E.29539
G1 X95.392 Y94.387 E.01647
G1 X101.637 Y88.142 E.2721
G1 X101.637 Y88.677 E.01647
G1 X95.927 Y94.387 E.2488
G1 X96.462 Y94.387 E.01647
G1 X101.637 Y89.212 E.2255
G1 X101.637 Y89.747 E.01647
G1 X96.997 Y94.387 E.2022
G1 X97.531 Y94.387 E.01647
G1 X101.637 Y90.281 E.1789
G1 X101.637 Y90.816 E.01647
G1 X98.066 Y94.387 E.15561
G1 X98.601 Y94.387 E.01647
G1 X101.637 Y91.351 E.13231
G1 X101.637 Y91.885 E.01647
G1 X99.135 Y94.387 E.10901
G1 X99.67 Y94.387 E.01647
G1 X101.637 Y92.42 E.08571
G1 X101.637 Y92.955 E.01647
G1 X100.205 Y94.387 E.06242
G1 X100.739 Y94.387 E.01647
G1 X101.637 Y93.489 E.03912
G1 X101.637 Y93.756 E.00821
G1 X101.562 Y94.067 E.00987
G3 X101.11 Y94.552 I-2.35 J-1.741 E.02045
M204 S10000
G1 X90.785 Y70.622 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.533696
G1 F7335.334
M204 S6000
G1 X90.851 Y70.782 E.00692
G1 X90.853 Y71.355 E.02294
G1 X90.891 Y71.54 E.00754
M204 S10000
G1 X90.304 Y70.155 F42000
; LINE_WIDTH: 0.519238
G1 F7557.978
M204 S6000
G1 X90.413 Y70.219 E.00489
G1 X90.785 Y70.622 E.02129
G2 X89.996 Y69.371 I-15.086 J8.645 E.05743
G2 X89.425 Y70.325 I4.791 J3.513 E.04325
G1 X89.697 Y70.146 E.01266
; LINE_WIDTH: 0.523856
G1 F7485.404
G1 X89.828 Y70.06 E.00615
G1 X90.075 Y70.021 E.0098
G1 X90.253 Y70.125 E.00807
M204 S10000
G1 X89.09 Y71.618 F42000
; LINE_WIDTH: 0.53064
G1 F7381.284
M204 S6000
G1 X89.145 Y71.38 E.00969
G1 X89.149 Y70.789 E.02352
G1 X89.205 Y70.64 E.00633
; LINE_WIDTH: 0.5542
G1 F7041.152
G1 X89.39 Y70.375 E.01346
; CHANGE_LAYER
; Z_HEIGHT: 3.4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F7041.152
G1 X89.205 Y70.64 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 17/25
; update layer progress
M73 L17
M991 S0 P16 ;notify layer change
M106 S198.9
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z3.6 I-1.207 J-.155 P1  F42000
G1 X84.285 Y108.899 Z3.6
G1 Z3.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X111.897 Y87.79 I5.787 J-21.115 E3.22945
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.234 Y110.067 E.02515
G3 X84.637 Y109.352 I-5.233 J-1.319 E.49816
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.112 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.892 J-21.493 E3.04525
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.119 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25113
G1 X82.491 Y108.737 E-.41561
G1 X82.262 Y108.649 E-.09326
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z3.8 F42000
G1 X94.196 Y109.433 Z3.8
G1 Z3.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.848 J-.923 E.03357
G1 X93.721 Y111.457 E.02248
G1 X93.397 Y111.841 E.01667
G1 X92.776 Y112.419 E.02815
G3 X91.973 Y112.898 I-3.155 J-4.38 E.03104
G3 X90.939 Y113.254 I-1.833 J-3.645 E.03638
G1 X90.268 Y113.343 E.02246
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.02818
G1 X88.442 Y113.071 E.01675
G1 X87.671 Y112.718 E.02811
G1 X87.256 Y112.433 E.01671
G1 X86.62 Y111.871 E.02816
G1 X86.305 Y111.478 E.01668
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.127 J-2.312 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.376 E.00982
G1 X86.131 Y109.308 E.00905
G2 X93.759 Y109.316 I3.838 J-21.932 E.2543
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.0243
G3 X91.997 Y112.456 I-3.754 J-2.916 E.05703
G1 X91.814 Y112.539 E.00616
G3 X86.201 Y110.562 I-1.822 J-3.785 E.20323
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.787 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.155 E.23767
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05567
G1 X94.037 Y109.947 E-.06472
G1 X93.789 Y110.564 E-.25268
G1 X93.389 Y111.247 E-.30056
G1 X93.241 Y111.419 E-.08638
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X87.87 Y106.224 Z3.8 F42000
G1 Z3.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G3 X82.895 Y70.558 I2.135 J-18.478 E1.62543
G3 X87.87 Y69.276 I7.042 J17.02 E.17097
G1 X88.178 Y68.786 E.01919
G3 X89.004 Y67.671 I6.197 J3.733 E.04611
G1 X89.417 Y67.333 E.01771
G1 X89.913 Y67.178 E.01722
G1 X90.237 Y67.197 E.01076
G1 X90.609 Y67.346 E.01329
G1 X91.063 Y67.746 E.02007
G3 X92.13 Y69.276 I-10.197 J8.257 E.06192
G3 X92.13 Y106.224 I-2.131 J18.474 E1.7963
G3 X91.135 Y107.674 I-12.635 J-7.605 E.05836
G1 X90.742 Y108.057 E.0182
G1 X90.318 Y108.281 E.01591
G3 X89.782 Y108.307 I-.317 J-1.019 E.01802
G1 X89.363 Y108.128 E.0151
G1 X89.193 Y108.004 E.00698
G1 X88.83 Y107.632 E.01723
G3 X87.901 Y106.276 I13.308 J-10.112 E.05456
M204 S250
G1 X88.108 Y105.863 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X88.105 Y105.858 E.00018
G3 X83.036 Y70.924 I1.9 J-18.111 E1.47957
G3 X88.105 Y69.642 I6.953 J16.819 E.16123
G3 X88.945 Y68.354 I16.95 J10.137 E.04725
G1 X88.987 Y68.303 E.00203
G1 X89.03 Y68.253 E.00203
G1 X89.072 Y68.202 E.00203
G1 X89.114 Y68.151 E.00203
G1 X89.156 Y68.101 E.00203
G1 X89.199 Y68.05 E.00203
G1 X89.241 Y67.999 E.00203
G1 X89.283 Y67.949 E.00203
G3 X89.334 Y67.902 I.122 J.08 E.00215
G1 X89.393 Y67.858 E.00226
G1 X89.452 Y67.814 E.00226
G1 X89.511 Y67.77 E.00226
G1 X89.57 Y67.727 E.00226
G1 X89.63 Y67.683 E.00226
G1 X89.689 Y67.639 E.00226
G3 X89.817 Y67.61 I.091 J.106 E.00419
G1 X89.971 Y67.587 E.00481
G1 X90.105 Y67.567 E.00415
G1 X90.167 Y67.592 E.00206
G1 X90.239 Y67.621 E.00239
G1 X90.311 Y67.65 E.00239
G1 X90.383 Y67.679 E.00239
G3 X90.436 Y67.707 I-.011 J.086 E.00188
G1 X90.464 Y67.732 E.00116
G1 X90.492 Y67.758 E.00116
G1 X90.52 Y67.783 E.00116
G1 X90.548 Y67.808 E.00116
G1 X90.576 Y67.834 E.00116
G1 X90.604 Y67.859 E.00116
G1 X90.631 Y67.884 E.00116
G1 X90.659 Y67.91 E.00116
G1 X90.687 Y67.935 E.00116
G1 X90.715 Y67.96 E.00116
G1 X90.743 Y67.986 E.00116
G1 X90.771 Y68.011 E.00116
G3 X91.895 Y69.642 I-11.151 J8.887 E.06089
G3 X91.895 Y105.858 I-1.898 J18.108 E1.64074
G3 X90.823 Y107.438 I-14.106 J-8.422 E.05868
G1 X90.793 Y107.465 E.00123
G1 X90.764 Y107.492 E.00123
G1 X90.735 Y107.52 E.00123
G1 X90.706 Y107.547 E.00123
G1 X90.677 Y107.574 E.00123
G1 X90.648 Y107.601 E.00123
M73 P69 R6
G1 X90.618 Y107.629 E.00123
G1 X90.589 Y107.656 E.00123
G1 X90.56 Y107.683 E.00123
G1 X90.531 Y107.711 E.00123
G1 X90.502 Y107.738 E.00123
G1 X90.473 Y107.765 E.00123
G1 X90.444 Y107.793 E.00123
G3 X90.378 Y107.82 I-.066 J-.065 E.00223
G1 X90.305 Y107.848 E.00241
G1 X90.232 Y107.876 E.00241
G1 X90.159 Y107.903 E.00241
G1 X90.085 Y107.931 E.00241
G3 X90.031 Y107.934 I-.029 J-.047 E.00173
G1 X89.909 Y107.916 E.00381
G1 X89.786 Y107.899 E.00381
G3 X89.691 Y107.862 I-.005 J-.13 E.00321
G1 X89.613 Y107.815 E.00281
G1 X89.534 Y107.768 E.00281
G3 X89.467 Y107.724 I.05 J-.152 E.0025
G1 X89.437 Y107.693 E.00132
G1 X89.407 Y107.662 E.00132
G1 X89.377 Y107.631 E.00132
G1 X89.347 Y107.601 E.00132
G1 X89.317 Y107.57 E.00132
G1 X89.287 Y107.539 E.00132
G1 X89.257 Y107.508 E.00132
G1 X89.227 Y107.477 E.00132
G1 X89.197 Y107.447 E.00132
G1 X89.167 Y107.416 E.00132
G1 X89.137 Y107.385 E.00132
G3 X88.759 Y106.87 I12.464 J-9.534 E.01964
G1 X88.141 Y105.914 E.03497
; WIPE_START
M204 S6000
G1 X88.105 Y105.858 E-.02501
G1 X87.333 Y105.763 E-.29576
G1 X86.452 Y105.611 E-.33978
G1 X86.196 Y105.554 E-.09946
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z3.8 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z3.8
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z3.8 F4000
            G39.3 S1
            G0 Z3.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X86.869 Y106.432 F42000
G1 Z3.4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X87.664 Y106.548 I1.615 J-8.331 E.02664
G1 X88.11 Y107.241 E.02738
G1 X86.366 Y108.986 E.08186
G2 X86.033 Y108.97 I-.234 J1.405 E.01108
G1 X86.001 Y108.853 E.00404
G1 X85.774 Y108.802 E.00771
G1 X81.803 Y104.831 E.18628
G3 X77.777 Y102.223 I9.706 J-19.391 E.15945
G1 X75.932 Y104.068 E.08658
G3 X72.296 Y100.028 I16.105 J-18.153 E.18067
G1 X74.169 Y98.155 E.08787
G3 X72.919 Y95.947 I16.988 J-11.071 E.08424
G1 X68.849 Y91.876 E.19094
G2 X69.69 Y94.958 I38.263 J-8.799 E.10598
G1 X71.766 Y92.882 E.09735
G3 X71.39 Y91.299 I21.382 J-5.905 E.054
M204 S10000
G1 X68.47 Y86.877 F42000
G1 F8843.478
M204 S6000
G2 X68.467 Y88.505 I16.638 J.843 E.05402
G1 X71.153 Y85.82 E.12599
G2 X71.102 Y86.454 I6.471 J.834 E.02112
G1 X68.764 Y84.116 E.1097
G3 X70.324 Y78.972 I23.89 J4.439 E.17866
G1 X81.222 Y68.074 E.51125
G3 X82.792 Y67.44 I11.401 J25.993 E.05618
G1 X84.868 Y69.516 E.09736
G2 X79.595 Y71.919 I5.162 J18.316 E.19298
G1 X77.722 Y70.046 E.08787
G2 X73.682 Y73.682 I14.114 J19.741 E.18067
G1 X75.527 Y75.527 E.08658
G2 X72.595 Y80.271 I14.576 J12.289 E.18566
G1 X70.632 Y78.308 E.09209
; WIPE_START
G1 X72.046 Y79.722 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X78.142 Y75.129 Z3.8 F42000
G1 X88.261 Y67.503 Z3.8
G1 Z3.4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X88.27 Y67.486 E.00064
G3 X89.286 Y66.258 I3.149 J1.568 E.05334
G1 X89.245 Y66.217 E.00191
G2 X87.622 Y66.335 I.878 J23.33 E.054
M204 S10000
G1 X90.87 Y67 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.483743
G1 F8166.546
M204 S6000
G1 X91.022 Y67.17 E.00818
; LINE_WIDTH: 0.450326
G1 F8836.394
G1 X91.299 Y67.481 E.01385
; LINE_WIDTH: 0.38292
G1 F10588.235
G1 X91.454 Y67.699 E.00739
M204 S10000
G1 X90.87 Y67 F42000
; LINE_WIDTH: 0.473297
G1 F8364.768
M204 S6000
G1 X90.672 Y66.738 E.01151
G1 X90.242 Y66.46 E.01797
G3 X90.113 Y66.269 I8.566 J-5.903 E.00808
; LINE_WIDTH: 0.444743
G1 F8959.179
G1 X89.848 Y66.397 E.00964
; LINE_WIDTH: 0.408168
G1 F9856.331
G1 X89.584 Y66.526 E.00876
; LINE_WIDTH: 0.411086
G1 F9778.198
G1 X89.531 Y66.591 E.00251
; LINE_WIDTH: 0.453498
G1 F8768.127
G1 X89.478 Y66.656 E.0028
; LINE_WIDTH: 0.49591
G1 F7947.196
G1 X89.426 Y66.721 E.00309
; LINE_WIDTH: 0.538322
G1 F7266.826
G1 X89.373 Y66.786 E.00338
; LINE_WIDTH: 0.580734
G1 F6693.765
G1 X89.321 Y66.852 E.00367
; LINE_WIDTH: 0.584074
G1 F6652.459
G1 X89.391 Y66.842 E.00311
; LINE_WIDTH: 0.54834
G1 F7122.789
G1 X89.461 Y66.833 E.00291
; LINE_WIDTH: 0.512607
G1 F7664.684
G1 X89.531 Y66.824 E.0027
; LINE_WIDTH: 0.477264
G1 F8288.374
G1 X89.59 Y66.83 E.00212
; LINE_WIDTH: 0.44231
G1 F9013.747
G1 X89.65 Y66.837 E.00194
; LINE_WIDTH: 0.423671
G1 F9455.019
G1 X89.709 Y66.843 E.00185
G1 X90.048 Y66.753 E.01086
; LINE_WIDTH: 0.47518
G1 F8328.33
G1 X90.385 Y66.811 E.01205
G1 X90.814 Y66.978 E.01624
; WIPE_START
G1 X90.385 Y66.811 E-.43627
G1 X90.048 Y66.753 E-.32373
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.507 Y67.752 Z3.8 F42000
G1 Z3.4
G1 E.8 F1800
; LINE_WIDTH: 0.401013
G1 F10053.252
M204 S6000
G1 X88.68 Y67.539 E.008
; LINE_WIDTH: 0.427164
G1 F9369.051
G1 X89.069 Y67.061 E.01929
; LINE_WIDTH: 0.50036
G1 F7869.884
G1 X89.275 Y66.89 E.00999
M204 S10000
G1 X91.735 Y67.506 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X90.722 Y66.251 I-3.556 J1.835 E.05389
G1 X90.755 Y66.217 E.00158
G3 X92.379 Y66.335 I-.89 J23.452 E.054
M204 S10000
G1 X109.368 Y78.308 F42000
G1 F8843.478
M204 S6000
G1 X107.405 Y80.271 E.09209
G2 X104.473 Y75.527 I-17.509 J7.545 E.18566
G1 X106.318 Y73.682 E.08658
G2 X102.278 Y70.046 I-18.153 J16.104 E.18067
G1 X100.405 Y71.919 E.08787
G2 X95.132 Y69.516 I-10.435 J15.913 E.19298
G1 X97.208 Y67.44 E.09736
G3 X98.778 Y68.074 I-9.831 J26.628 E.05618
G1 X109.676 Y78.972 E.51125
G3 X111.236 Y84.116 I-22.33 J9.583 E.17866
G1 X108.898 Y86.454 E.1097
G2 X108.847 Y85.82 I-6.497 J.197 E.02112
G1 X111.533 Y88.505 E.12599
G2 X111.53 Y86.877 I-16.64 J-.785 E.05402
M204 S10000
G1 X108.61 Y91.299 F42000
G1 F8843.478
M204 S6000
G3 X108.234 Y92.882 I-21.752 J-4.32 E.054
G1 X110.31 Y94.958 E.09735
G2 X111.151 Y91.876 I-37.413 J-11.878 E.10598
G1 X107.081 Y95.947 E.19094
G3 X105.831 Y98.155 I-18.24 J-8.864 E.08424
G1 X107.704 Y100.028 E.08787
G3 X104.068 Y104.068 I-19.74 J-14.113 E.18067
G1 X102.223 Y102.223 E.08658
G3 X98.197 Y104.831 I-13.683 J-16.707 E.15946
G1 X94.226 Y108.802 E.18628
G1 X93.995 Y108.854 E.00786
G1 X93.965 Y108.97 E.00398
G2 X93.634 Y108.986 I-.095 J1.435 E.01101
G1 X91.888 Y107.24 E.08194
G1 X92.336 Y106.548 E.02735
G2 X93.131 Y106.432 I-.821 J-8.448 E.02667
M204 S10000
G1 X91.305 Y108.001 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.38292
G1 F10588.235
M204 S6000
G1 X91.445 Y107.806 E.00665
M204 S10000
G1 X90.88 Y108.491 F42000
; LINE_WIDTH: 0.50232
G1 F7836.308
M204 S6000
G1 X90.324 Y108.732 E.02268
G1 X89.758 Y108.739 E.02119
G1 X89.317 Y108.6 E.01733
G1 X89.083 Y108.446 E.01048
G1 X89.335 Y108.749 E.01475
G1 X89.756 Y109.02 E.01875
G1 X89.885 Y109.204 E.00841
G1 X90.13 Y109.188 E.00916
G1 X90.847 Y108.541 E.03618
; WIPE_START
G1 X90.13 Y109.188 E-.36722
G1 X89.885 Y109.204 E-.09298
G1 X89.756 Y109.02 E-.08538
G1 X89.335 Y108.749 E-.19035
G1 X89.294 Y108.7 E-.02407
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X85.159 Y109.965 Z3.8 F42000
G1 Z3.4
G1 E.8 F1800
; LINE_WIDTH: 0.431878
G1 F9255.503
M204 S6000
G2 X86.287 Y112.097 I4.906 J-1.231 E.07719
G1 X86.646 Y112.451 E.01598
G1 X87.414 Y113.028 E.03046
G1 X88.133 Y113.378 E.02533
G1 X88.772 Y113.596 E.02141
G2 X91.017 Y113.633 I1.206 J-4.997 E.07174
G1 X91.671 Y113.46 E.02144
G1 X92.135 Y113.265 E.01596
G1 X92.933 Y112.796 E.02933
G2 X94.823 Y110.03 I-2.98 J-4.064 E.10825
M204 S10000
G1 X94.84 Y109.972 F42000
; Slow Down Start
; LINE_WIDTH: 0.415026
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G2 X94.672 Y109.387 I-5.803 J1.35 E.01847
G1 X94.442 Y109.147 E.01008
G1 X95.095 Y109 E.02031
G2 X94.852 Y109.913 I4.889 J1.79 E.02871
; Slow Down End
; WIPE_START
G1 X94.968 Y109.374 E-.20972
G1 X95.095 Y109 E-.15014
G1 X94.442 Y109.147 E-.25452
G1 X94.672 Y109.387 E-.12631
G1 X94.686 Y109.436 E-.01931
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X87.065 Y109.859 Z3.8 F42000
G1 X85.159 Y109.965 Z3.8
G1 Z3.4
G1 E.8 F1800
; LINE_WIDTH: 0.412969
G1 F9728.456
M204 S6000
G1 X85.232 Y109.633 E.01025
G3 X85.355 Y109.338 I.497 J.035 E.00981
G1 X85.56 Y109.147 E.00842
G1 X84.903 Y109 E.02029
G3 X85.146 Y109.906 I-5.966 J2.085 E.02832
; WIPE_START
G1 X85.046 Y109.455 E-.17549
G1 X84.903 Y109 E-.18141
G1 X85.56 Y109.147 E-.25574
G1 X85.355 Y109.338 E-.10617
G1 X85.299 Y109.431 E-.04118
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X82.047 Y107.775 Z3.8 F42000
G1 Z3.4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X80.558 Y107.118 I8.841 J-22.072 E.054
G1 X82.521 Y105.155 E.09209
; WIPE_START
G1 X81.107 Y106.569 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.72 Y107.114 Z3.8 F42000
G1 X97.953 Y107.775 Z3.8
G1 Z3.4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G2 X99.442 Y107.118 I-8.838 J-22.065 E.054
G1 X97.479 Y105.155 E.09209
; WIPE_START
G1 X98.893 Y106.569 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X91.261 Y106.537 Z3.8 F42000
G1 X89.999 Y106.531 Z3.8
G1 Z3.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G3 X89.29 Y105.683 I2.629 J-2.919 E.03681
G1 X88.77 Y104.877 E.0318
G1 X88.771 Y104.127 E.0249
G1 X88.721 Y103.889 E.00804
G1 X88.538 Y103.66 E.00973
G1 X88.271 Y103.55 E.00958
G3 X88.267 Y71.95 I1.726 J-15.8 E1.54148
G1 X88.538 Y71.84 E.00973
G1 X88.721 Y71.61 E.00973
G1 X88.771 Y71.373 E.00804
G1 X88.77 Y70.623 E.0249
G3 X89.649 Y69.324 I14.171 J8.641 E.05205
G1 X90.002 Y68.97 E.01659
G1 X90.042 Y69 E.00167
G3 X90.713 Y69.822 I-2.96 J3.102 E.03529
G1 X91.23 Y70.623 E.03161
G1 X91.229 Y71.373 E.0249
G1 X91.279 Y71.611 E.00804
G1 X91.376 Y71.761 E.00594
G1 X91.572 Y71.904 E.00806
G3 X93.486 Y72.244 I-13.68 J82.715 E.06448
G3 X105.888 Y88.142 I-3.49 J15.509 E.7245
G3 X91.733 Y103.55 I-15.878 J-.381 E.75765
G1 X91.462 Y103.66 E.00973
G1 X91.279 Y103.89 E.00973
G1 X91.229 Y104.127 E.00804
G1 X91.23 Y104.877 E.0249
G3 X90.394 Y106.122 I-14.97 J-9.154 E.04975
G1 X90.041 Y106.488 E.01688
M204 S250
G1 X90.075 Y106.932 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.913 Y106.929 E.00499
G1 X89.61 Y106.728 E.01117
G3 X88.68 Y105.472 I7.025 J-6.175 E.04808
G1 X88.378 Y104.99 E.01748
G1 X88.379 Y104.126 E.02654
G1 X88.332 Y104 E.00414
G1 X88.219 Y103.939 E.00394
G3 X87.61 Y71.637 I1.785 J-16.19 E1.44357
G1 X88.304 Y71.526 E.02158
G1 X88.379 Y71.374 E.0052
G1 X88.378 Y70.51 E.02654
G3 X89.278 Y69.167 I14.866 J8.989 E.0497
G1 X89.655 Y68.74 E.01749
G1 X89.945 Y68.552 E.01061
G1 X90.094 Y68.571 E.00461
G1 X90.344 Y68.737 E.00924
G3 X91.32 Y70.029 I-5.887 J5.464 E.04983
G1 X91.622 Y70.51 E.01747
G1 X91.621 Y71.374 E.02654
G1 X91.696 Y71.526 E.0052
G3 X93.571 Y71.861 I-19.696 J115.456 E.05853
G3 X106.28 Y88.151 I-3.576 J15.892 E.68767
G3 X92.39 Y103.863 I-16.289 J-.404 E.70002
G1 X91.696 Y103.974 E.02158
G1 X91.621 Y104.126 E.0052
G1 X91.622 Y104.99 E.02654
G3 X90.717 Y106.347 I-16.937 J-10.313 E.05015
G1 X90.39 Y106.728 E.01542
G1 X90.126 Y106.899 E.00968
; WIPE_START
M204 S6000
G1 X89.913 Y106.929 E-.08164
G1 X89.61 Y106.728 E-.13814
G1 X89.282 Y106.347 E-.19113
G1 X88.761 Y105.59 E-.34908
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.603 Y104.2 Z3.8 F42000
G1 Z3.4
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.499248
G1 F7889.069
M204 S6000
G1 X90.642 Y104.138 E.00273
; LINE_WIDTH: 0.5376
G1 F7277.436
G1 X90.681 Y104.077 E.00296
; LINE_WIDTH: 0.575952
G1 F6753.818
G1 X90.721 Y104.015 E.00319
; LINE_WIDTH: 0.614304
G1 F6300.492
G1 X90.76 Y103.953 E.00342
; LINE_WIDTH: 0.611267
G1 F6334.162
G1 X90.762 Y103.973 E.00094
; LINE_WIDTH: 0.56684
G1 F6871.278
G1 X90.764 Y103.993 E.00087
; LINE_WIDTH: 0.522414
G1 F7507.925
G1 X90.766 Y104.013 E.00079
; LINE_WIDTH: 0.477987
G1 F8274.593
G1 X90.768 Y104.033 E.00072
; LINE_WIDTH: 0.43356
G1 F9215.646
G1 X90.771 Y104.053 E.00065
; LINE_WIDTH: 0.460589
G1 F8619.269
G1 X90.863 Y104.346 E.01044
; LINE_WIDTH: 0.36892
G1 F11042.945
G1 X90.862 Y104.77 E.01128
; LINE_WIDTH: 0.392144
G1 F10308.59
G1 X90.795 Y104.873 E.00349
; LINE_WIDTH: 0.43167
G1 F9260.45
G1 X90.729 Y104.977 E.00389
; LINE_WIDTH: 0.471197
G1 F8405.781
G1 X90.662 Y105.08 E.00428
; LINE_WIDTH: 0.394235
G1 F10247.214
G1 X90.581 Y105.178 E.00365
; LINE_WIDTH: 0.440865
G1 F9046.477
G1 X90.499 Y105.276 E.00413
; LINE_WIDTH: 0.487495
G1 F8097.622
G1 X90.418 Y105.373 E.00461
; LINE_WIDTH: 0.526198
G1 F7449.128
G3 X90 Y105.849 I-7.208 J-5.914 E.02492
; LINE_WIDTH: 0.537982
G1 F7271.827
G1 X89.95 Y105.783 E.00333
; LINE_WIDTH: 0.499064
G1 F7892.249
G1 X89.899 Y105.718 E.00307
; LINE_WIDTH: 0.460147
G1 F8628.412
G1 X89.848 Y105.653 E.00281
; LINE_WIDTH: 0.421229
G1 F9516.037
G1 X89.797 Y105.588 E.00255
; LINE_WIDTH: 0.534424
G1 F7324.461
G1 X89.708 Y105.494 E.00519
; LINE_WIDTH: 0.488392
G1 F8081.33
G1 X89.619 Y105.4 E.0047
; LINE_WIDTH: 0.442359
G1 F9012.646
G1 X89.53 Y105.306 E.00422
; LINE_WIDTH: 0.396327
G1 F10186.578
G1 X89.441 Y105.211 E.00373
; LINE_WIDTH: 0.385075
G1 F10521.549
G1 X89.139 Y104.77 E.01491
; LINE_WIDTH: 0.39498
G1 F10225.554
G1 X89.139 Y104.702 E.00196
; LINE_WIDTH: 0.438318
G1 F9104.762
G1 X89.138 Y104.633 E.0022
; LINE_WIDTH: 0.481656
G1 F8205.393
G1 X89.138 Y104.565 E.00245
; LINE_WIDTH: 0.524995
G1 F7467.73
G1 X89.138 Y104.497 E.00269
; LINE_WIDTH: 0.568333
G1 F6851.76
G1 X89.138 Y104.428 E.00293
; LINE_WIDTH: 0.488341
G1 F8082.248
G1 X89.137 Y104.36 E.00248
G1 X89.243 Y103.966 E.01479
; LINE_WIDTH: 0.61126
G1 F6334.236
G1 X89.253 Y103.981 E.00083
; LINE_WIDTH: 0.5671
G1 F6867.87
G1 X89.264 Y103.995 E.00076
; LINE_WIDTH: 0.52294
G1 F7499.688
G1 X89.274 Y104.01 E.0007
; LINE_WIDTH: 0.47878
G1 F8259.533
G1 X89.284 Y104.024 E.00064
; LINE_WIDTH: 0.43462
G1 F9190.707
G1 X89.295 Y104.039 E.00057
; Slow Down Start
; LINE_WIDTH: 0.499156
G1 F1200;_EXTRUDE_SET_SPEED
G3 X89.397 Y104.233 I-.593 J.438 E.00819
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.430796
;_EXTRUDE_SET_SPEED
G1 X89.43 Y104.296 E.00226
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.386175
;_EXTRUDE_SET_SPEED
G1 X89.463 Y104.36 E.002
G1 X89.464 Y104.672 E.00872
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.394358
;_EXTRUDE_SET_SPEED
G1 X89.527 Y104.75 E.00289
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.440953
;_EXTRUDE_SET_SPEED
G1 X89.591 Y104.829 E.00328
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.487548
;_EXTRUDE_SET_SPEED
G1 X89.654 Y104.908 E.00366
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.534143
;_EXTRUDE_SET_SPEED
G1 X89.717 Y104.986 E.00404
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.432261
;_EXTRUDE_SET_SPEED
G1 X90 Y105.173 E.01074
G1 X90.344 Y104.946 E.01309
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.38152
;_EXTRUDE_SET_SPEED
G1 X90.509 Y104.739 E.00729
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.379769
;_EXTRUDE_SET_SPEED
G1 X90.519 Y104.607 E.00362
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.415805
;_EXTRUDE_SET_SPEED
G1 X90.529 Y104.476 E.004
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.451842
;_EXTRUDE_SET_SPEED
G1 X90.539 Y104.345 E.00439
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.389134
;_EXTRUDE_SET_SPEED
G1 X90.546 Y104.33 E.00046
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.43356
;_EXTRUDE_SET_SPEED
G1 X90.552 Y104.315 E.00052
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.477987
;_EXTRUDE_SET_SPEED
G1 X90.558 Y104.299 E.00058
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.522414
;_EXTRUDE_SET_SPEED
G1 X90.564 Y104.284 E.00064
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.56684
;_EXTRUDE_SET_SPEED
G1 X90.57 Y104.269 E.0007
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.611267
;_EXTRUDE_SET_SPEED
G1 X90.577 Y104.254 E.00075
; Slow Down End
M204 S10000
G1 X101.304 Y93.628 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X103.369 Y95.693 E.0969
G3 X99.813 Y99.813 I-13.534 J-8.088 E.18144
G1 X94.054 Y94.054 E.27018
G1 X93.622 Y94.054 E.0143
G1 X85.154 Y102.522 E.39729
G2 X87.79 Y103.142 I4.962 J-15.187 E.08996
G1 X74.608 Y89.96 E.61841
G1 X74.617 Y90.031 E.00238
G1 X78.695 Y85.953 E.19133
G1 X78.695 Y86.371 E.01389
G1 X75.228 Y82.904 E.16269
G3 X76.012 Y80.96 I25.929 J9.336 E.06953
G1 X83.21 Y73.762 E.33768
G3 X87.719 Y72.367 I6.872 J14.228 E.15714
G1 X96.797 Y81.445 E.42589
G1 X98.555 Y81.445 E.05829
G1 X102.063 Y77.937 E.16458
G2 X97.943 Y74.381 I-12.208 J9.977 E.18144
G1 X90.879 Y81.445 E.33141
G1 X89.121 Y81.445 E.05829
G1 X82.057 Y74.381 E.33141
G2 X77.937 Y77.937 I8.088 J13.534 E.18144
G1 X81.445 Y81.445 E.16458
G1 X83.203 Y81.445 E.05829
G1 X92.281 Y72.367 E.42589
G3 X96.79 Y73.762 I-2.364 J15.623 E.15714
G1 X103.988 Y80.96 E.33768
G3 X104.772 Y82.904 I-25.141 J11.278 E.06953
G1 X101.304 Y86.372 E.16273
G1 X101.304 Y85.952 E.01396
G1 X105.383 Y90.031 E.19138
G1 X105.392 Y89.96 E.00238
G1 X92.21 Y103.142 E.61841
G2 X94.846 Y102.522 I-2.325 J-15.807 E.08996
G1 X86.378 Y94.054 E.39729
G1 X85.946 Y94.054 E.0143
G1 X80.187 Y99.813 E.27018
G3 X76.631 Y95.693 I9.977 J-12.208 E.18144
G1 X78.695 Y93.629 E.09685
M204 S10000
G1 X79.269 Y93.831 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42032
G1 F9538.95
M204 S6000
G1 X79.088 Y93.65 E.00789
G1 X79.088 Y93.116 E.01641
G1 X79.633 Y93.661 E.02372
G1 X80.167 Y93.661 E.01641
G1 X79.088 Y92.582 E.04693
G1 X79.088 Y92.049 E.01641
G1 X80.7 Y93.661 E.07015
G1 X81.234 Y93.661 E.01641
G1 X79.088 Y91.515 E.09336
G1 X79.088 Y90.981 E.01641
G1 X81.768 Y93.661 E.11657
G1 X82.302 Y93.661 E.01641
G1 X79.088 Y90.447 E.13978
G1 X79.088 Y89.914 E.01641
G1 X82.835 Y93.661 E.163
G1 X83.369 Y93.661 E.01641
G1 X79.088 Y89.38 E.18621
G1 X79.088 Y88.846 E.01641
G1 X83.903 Y93.661 E.20942
G1 X84.436 Y93.661 E.01641
G1 X79.088 Y88.313 E.23263
G1 X79.088 Y87.779 E.01641
G1 X84.97 Y93.661 E.25585
G1 X85.504 Y93.661 E.01641
G1 X79.088 Y87.245 E.27906
G1 X79.088 Y86.711 E.01641
G1 X86.038 Y93.661 E.30227
G1 X86.571 Y93.661 E.01641
G1 X79.088 Y86.178 E.32548
G1 X79.088 Y85.644 E.01641
G1 X87.105 Y93.661 E.3487
G1 X87.639 Y93.661 E.01641
G1 X79.088 Y85.11 E.37191
G1 X79.088 Y84.577 E.01641
G1 X88.173 Y93.661 E.39512
G1 X88.706 Y93.661 E.01641
G1 X79.088 Y84.043 E.41834
G1 X79.088 Y83.509 E.01641
G1 X89.24 Y93.661 E.44155
G1 X89.774 Y93.661 E.01641
G1 X79.088 Y82.975 E.46476
G1 X79.088 Y82.442 E.01641
G1 X90.307 Y93.661 E.48797
G1 X90.841 Y93.661 E.01641
G1 X79.088 Y81.908 E.51119
G1 X79.099 Y81.837 E.00219
G1 X79.551 Y81.837 E.0139
G1 X91.375 Y93.661 E.51425
G1 X91.909 Y93.661 E.01641
G1 X80.085 Y81.837 E.51425
G1 X80.618 Y81.837 E.01641
G1 X92.442 Y93.661 E.51425
G1 X92.976 Y93.661 E.01641
G1 X81.152 Y81.837 E.51425
G1 X81.686 Y81.837 E.01641
G1 X93.51 Y93.661 E.51425
G1 X94.043 Y93.662 E.01641
G1 X82.219 Y81.837 E.51425
G1 X82.753 Y81.837 E.01641
G1 X94.577 Y93.662 E.51425
G1 X95.111 Y93.662 E.01641
G1 X83.287 Y81.837 E.51425
G1 X83.821 Y81.837 E.01641
G1 X95.645 Y93.662 E.51425
G1 X96.178 Y93.662 E.01641
G1 X84.354 Y81.837 E.51425
G1 X84.888 Y81.837 E.01641
G1 X96.712 Y93.662 E.51425
G1 X97.246 Y93.662 E.01641
G1 X85.422 Y81.837 E.51425
G1 X85.956 Y81.837 E.01641
G1 X97.78 Y93.662 E.51425
G1 X98.313 Y93.662 E.01641
G1 X86.489 Y81.837 E.51425
G1 X87.023 Y81.837 E.01641
G1 X98.847 Y93.662 E.51425
G1 X99.381 Y93.662 E.01641
G1 X87.557 Y81.837 E.51425
G1 X88.09 Y81.837 E.01641
G1 X99.914 Y93.662 E.51425
G1 X100.448 Y93.662 E.01641
G1 X88.624 Y81.837 E.51425
M73 P70 R6
G1 X89.158 Y81.837 E.01641
G1 X100.912 Y93.591 E.51119
G1 X100.912 Y93.057 E.01641
G1 X89.692 Y81.837 E.48797
G1 X90.225 Y81.837 E.01641
G1 X100.912 Y92.524 E.46476
G1 X100.912 Y91.99 E.01641
G1 X90.759 Y81.837 E.44155
G1 X91.293 Y81.837 E.01641
G1 X100.912 Y91.456 E.41834
G1 X100.912 Y90.923 E.01641
G1 X91.827 Y81.837 E.39512
G1 X92.36 Y81.837 E.01641
G1 X100.912 Y90.389 E.37191
G1 X100.912 Y89.855 E.01641
G1 X92.894 Y81.837 E.3487
G1 X93.428 Y81.837 E.01641
G1 X100.912 Y89.321 E.32549
G1 X100.912 Y88.788 E.01641
G1 X93.961 Y81.837 E.30227
G1 X94.495 Y81.837 E.01641
G1 X100.912 Y88.254 E.27906
G1 X100.912 Y87.72 E.01641
G1 X95.029 Y81.837 E.25585
G1 X95.563 Y81.837 E.01641
G1 X100.912 Y87.186 E.23263
G1 X100.912 Y86.653 E.01641
G1 X96.096 Y81.837 E.20942
G1 X96.63 Y81.837 E.01641
G1 X100.912 Y86.119 E.18621
G1 X100.912 Y85.585 E.01641
G1 X97.164 Y81.837 E.163
G1 X97.697 Y81.837 E.01641
G1 X100.912 Y85.052 E.13978
G1 X100.912 Y84.518 E.01641
G1 X98.231 Y81.837 E.11657
G1 X98.765 Y81.837 E.01641
G1 X100.912 Y83.984 E.09336
G1 X100.912 Y83.45 E.01641
G1 X99.299 Y81.837 E.07015
G1 X99.832 Y81.837 E.01641
G1 X100.912 Y82.917 E.04693
G1 X100.912 Y82.383 E.01641
G1 X100.366 Y81.837 E.02372
G1 X100.9 Y81.837 E.01641
G1 X101.081 Y82.019 E.00789
M204 S10000
G1 X89.395 Y71.313 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.432293
G1 F9245.636
M204 S6000
G1 X89.317 Y71.445 E.00486
; LINE_WIDTH: 0.473444
G1 F8361.916
G1 X89.238 Y71.577 E.00538
G1 X89.137 Y71.183 E.01425
; LINE_WIDTH: 0.37151
G1 F10955.902
G1 X89.143 Y70.731 E.01211
; LINE_WIDTH: 0.401132
G1 F10049.936
G1 X89.191 Y70.654 E.00265
; LINE_WIDTH: 0.439314
G1 F9081.879
G1 X89.239 Y70.578 E.00293
; LINE_WIDTH: 0.477497
G1 F8283.931
G1 X89.287 Y70.501 E.00321
; LINE_WIDTH: 0.515679
G1 F7614.878
G1 X89.335 Y70.424 E.00349
; LINE_WIDTH: 0.394479
G1 F10240.11
G1 X89.437 Y70.307 E.00446
; LINE_WIDTH: 0.442277
G1 F9014.508
G1 X89.54 Y70.189 E.00506
; LINE_WIDTH: 0.490074
G1 F8050.922
G1 X89.642 Y70.072 E.00567
; LINE_WIDTH: 0.54068
G1 F7232.413
G2 X89.99 Y69.641 I-3.828 J-3.448 E.02248
; LINE_WIDTH: 0.540932
G1 F7228.753
G1 X90.048 Y69.713 E.00376
; LINE_WIDTH: 0.499254
G1 F7888.963
G1 X90.106 Y69.786 E.00344
; LINE_WIDTH: 0.457577
G1 F8681.889
G1 X90.165 Y69.858 E.00313
; LINE_WIDTH: 0.415899
G1 F9652.024
G1 X90.223 Y69.93 E.00281
; LINE_WIDTH: 0.526732
G1 F7440.919
G1 X90.31 Y70.023 E.00505
; LINE_WIDTH: 0.482634
G1 F8187.144
G1 X90.398 Y70.117 E.00459
; LINE_WIDTH: 0.438537
G1 F9099.728
G1 X90.485 Y70.21 E.00413
; LINE_WIDTH: 0.384461
G1 F10540.48
G1 X90.572 Y70.304 E.00356
G1 X90.835 Y70.689 E.01299
; LINE_WIDTH: 0.389425
G1 F10389.461
G1 X90.845 Y70.854 E.00466
; LINE_WIDTH: 0.423495
G1 F9459.371
G1 X90.855 Y71.019 E.00511
; LINE_WIDTH: 0.457565
G1 F8682.126
G1 X90.865 Y71.183 E.00557
; LINE_WIDTH: 0.38986
G1 F10376.458
G1 X90.856 Y71.205 E.00067
; LINE_WIDTH: 0.432798
G1 F9233.67
G1 X90.847 Y71.227 E.00075
; LINE_WIDTH: 0.475736
G1 F8317.625
G1 X90.838 Y71.249 E.00083
; LINE_WIDTH: 0.518675
G1 F7566.933
G1 X90.83 Y71.27 E.00091
; LINE_WIDTH: 0.561613
G1 F6940.529
G1 X90.821 Y71.292 E.00099
; LINE_WIDTH: 0.554698
G1 F7034.303
G2 X90.761 Y71.577 I.696 J.293 E.01219
; LINE_WIDTH: 0.604551
G1 F6409.905
G1 X90.755 Y71.568 E.0005
; LINE_WIDTH: 0.561613
G1 F6940.529
G1 X90.748 Y71.559 E.00046
; LINE_WIDTH: 0.518675
G1 F7566.933
G1 X90.741 Y71.551 E.00043
; LINE_WIDTH: 0.475736
G1 F8317.625
G1 X90.735 Y71.542 E.00039
; LINE_WIDTH: 0.432798
G1 F9233.67
G1 X90.728 Y71.533 E.00035
; Slow Down Start
; LINE_WIDTH: 0.510948
G1 F1200;_EXTRUDE_SET_SPEED
G3 X90.605 Y71.308 I.611 J-.479 E.00984
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.427546
;_EXTRUDE_SET_SPEED
G1 X90.572 Y71.246 E.00219
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.373906
;_EXTRUDE_SET_SPEED
G1 X90.539 Y71.184 E.00189
G1 X90.538 Y70.847 E.0091
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.391315
;_EXTRUDE_SET_SPEED
G1 X90.501 Y70.787 E.00201
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.436305
;_EXTRUDE_SET_SPEED
G1 X90.463 Y70.726 E.00227
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.481295
;_EXTRUDE_SET_SPEED
G1 X90.426 Y70.666 E.00254
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.441193
;_EXTRUDE_SET_SPEED
G1 X90.388 Y70.606 E.0023
G1 X90.027 Y70.338 E.0146
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.525032
;_EXTRUDE_SET_SPEED
G1 X89.992 Y70.349 E.00142
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.477534
;_EXTRUDE_SET_SPEED
G1 X89.958 Y70.36 E.00128
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.430037
;_EXTRUDE_SET_SPEED
G1 X89.923 Y70.37 E.00114
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.424333
;_EXTRUDE_SET_SPEED
G1 X89.889 Y70.381 E.00113
G1 X89.506 Y70.725 E.01599
; Slow Down End
; LINE_WIDTH: 0.38106
G1 F10646.504
G1 X89.5 Y70.803 E.00215
; LINE_WIDTH: 0.425598
G1 F9407.4
G1 X89.493 Y70.881 E.00243
; LINE_WIDTH: 0.470136
G1 F8426.654
G1 X89.486 Y70.959 E.00272
; LINE_WIDTH: 0.514675
G1 F7631.093
G1 X89.48 Y71.036 E.003
; LINE_WIDTH: 0.559213
G1 F6972.792
G1 X89.473 Y71.114 E.00328
; LINE_WIDTH: 0.603751
G1 F6419.048
G1 X89.467 Y71.192 E.00357
; LINE_WIDTH: 0.392391
G1 F10301.285
G1 X89.446 Y71.227 E.00115
; LINE_WIDTH: 0.432293
G1 F9245.636
G1 X89.425 Y71.261 E.00128
M204 S10000
G1 X89.08 Y71.833 F42000
; LINE_WIDTH: 0.509804
G1 F7710.706
M204 S6000
G1 X89.122 Y71.764 E.00306
; LINE_WIDTH: 0.55629
G1 F7012.487
G1 X89.164 Y71.696 E.00337
; LINE_WIDTH: 0.602777
G1 F6430.218
G1 X89.207 Y71.628 E.00367
; CHANGE_LAYER
; Z_HEIGHT: 3.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F6430.218
G1 X89.164 Y71.696 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 18/25
; update layer progress
M73 L18
M991 S0 P17 ;notify layer change
M106 S201.45
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z3.8 I-1.207 J-.158 P1  F42000
G1 X84.285 Y108.899 Z3.8
G1 Z3.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X111.897 Y87.79 I5.787 J-21.115 E3.22945
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.234 Y110.067 E.02516
G3 X84.637 Y109.352 I-5.233 J-1.319 E.49816
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.112 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.892 J-21.493 E3.04525
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.118 I-5.602 J-1.462 E.47075
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25115
G1 X82.491 Y108.737 E-.41559
G1 X82.262 Y108.649 E-.09326
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z4 F42000
G1 X94.196 Y109.433 Z4
G1 Z3.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.851 J-.925 E.03357
G1 X93.721 Y111.457 E.02248
G1 X93.397 Y111.841 E.01666
G1 X92.776 Y112.419 E.02815
G1 X92.353 Y112.695 E.01673
G1 X91.59 Y113.067 E.02816
G1 X91.107 Y113.207 E.0167
G1 X90.268 Y113.343 E.02818
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.0282
G1 X88.442 Y113.071 E.01673
G1 X87.671 Y112.718 E.02812
G3 X87.048 Y112.279 I5.64 J-8.676 E.0253
G3 X86.305 Y111.478 I2.587 J-3.143 E.03632
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.125 J-2.312 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X93.76 Y109.316 I3.838 J-21.966 E.2543
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.02431
G3 X87.318 Y111.995 I-3.39 J-2.505 E.21031
G3 X86.201 Y110.562 I3.105 J-3.574 E.05618
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.788 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.156 E.23767
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05566
G1 X94.037 Y109.947 E-.06473
G1 X93.789 Y110.564 E-.25266
G1 X93.389 Y111.247 E-.30062
G1 X93.241 Y111.419 E-.08633
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X87.993 Y106.236 Z4 F42000
G1 Z3.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G3 X77.497 Y73.976 I2.008 J-18.491 E1.41662
G3 X87.998 Y69.263 I12.509 J13.814 E.38815
G3 X88.939 Y68.042 I6.134 J3.751 E.05122
G1 X89.408 Y67.688 E.0195
G1 X89.609 Y67.598 E.00729
G1 X90.059 Y67.529 E.0151
G1 X90.426 Y67.613 E.01251
G1 X90.901 Y67.896 E.01833
G1 X91.337 Y68.341 E.02066
G3 X92.007 Y69.264 I-7.982 J6.495 E.03783
G3 X92.007 Y106.236 I-2.005 J18.486 E1.80448
G3 X90.901 Y107.604 I-6.274 J-3.943 E.05847
G1 X90.427 Y107.887 E.01831
G3 X89.832 Y107.955 I-.433 J-1.152 E.02007
G1 X89.426 Y107.809 E.01429
G1 X89.099 Y107.604 E.0128
G1 X88.663 Y107.159 E.02067
G3 X88.026 Y106.287 I7.991 J-6.502 E.03584
M204 S250
G1 X88.22 Y105.869 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X88.22 Y105.868 E.00003
G3 X77.768 Y74.261 I1.784 J-18.122 E1.29058
G3 X88.222 Y69.631 I12.252 J13.549 E.3573
G1 X88.776 Y68.835 E.02982
G1 X88.826 Y68.776 E.00238
G1 X88.876 Y68.717 E.00238
G1 X88.927 Y68.659 E.00238
G1 X88.977 Y68.6 E.00238
G1 X89.027 Y68.541 E.00238
G1 X89.078 Y68.482 E.00238
G1 X89.128 Y68.424 E.00238
G1 X89.178 Y68.365 E.00238
G1 X89.229 Y68.306 E.00238
G3 X89.304 Y68.248 I.158 J.128 E.00294
G1 X89.383 Y68.191 E.00301
G1 X89.462 Y68.134 E.00301
G1 X89.542 Y68.076 E.00301
G1 X89.621 Y68.019 E.00301
G3 X89.724 Y67.983 I.093 J.102 E.00344
G1 X89.838 Y67.957 E.00359
G1 X89.952 Y67.932 E.00359
G3 X90.079 Y67.93 I.065 J.151 E.00399
G1 X90.208 Y67.953 E.00403
G3 X90.309 Y67.996 I-.012 J.166 E.00343
G1 X90.399 Y68.047 E.00319
G1 X90.49 Y68.098 E.00319
G1 X90.58 Y68.148 E.00319
G3 X90.64 Y68.19 I-.042 J.124 E.00228
G1 X90.675 Y68.226 E.00152
G1 X90.71 Y68.261 E.00153
G1 X90.744 Y68.297 E.00152
G1 X90.779 Y68.332 E.00152
G1 X90.814 Y68.368 E.00153
G1 X90.849 Y68.403 E.00153
G1 X90.883 Y68.438 E.00153
G1 X90.918 Y68.474 E.00152
G1 X90.953 Y68.509 E.00153
G1 X90.988 Y68.545 E.00153
G1 X91.022 Y68.58 E.00152
G3 X91.78 Y69.632 I-11.341 J8.97 E.03984
G3 X91.78 Y105.868 I-1.781 J18.118 E1.64775
G3 X91.057 Y106.885 I-15.663 J-10.377 E.03833
G1 X91.022 Y106.92 E.00152
G1 X90.988 Y106.955 E.00152
G1 X90.953 Y106.991 E.00152
G1 X90.918 Y107.026 E.00152
G1 X90.883 Y107.062 E.00152
G1 X90.849 Y107.097 E.00152
G1 X90.814 Y107.132 E.00152
G1 X90.779 Y107.168 E.00152
G1 X90.744 Y107.203 E.00152
G1 X90.71 Y107.239 E.00152
G1 X90.675 Y107.274 E.00152
G1 X90.64 Y107.31 E.00152
G3 X90.579 Y107.351 I-.097 J-.077 E.00231
G1 X90.486 Y107.401 E.00324
G1 X90.393 Y107.451 E.00324
G1 X90.3 Y107.501 E.00324
G1 X90.207 Y107.55 E.00324
G1 X90.014 Y107.552 E.00595
G1 X89.757 Y107.541 E.00789
G1 X89.69 Y107.503 E.00236
G1 X89.6 Y107.453 E.00317
G1 X89.51 Y107.402 E.00317
G1 X89.42 Y107.352 E.00317
G3 X89.36 Y107.31 I.042 J-.123 E.00228
G1 X89.325 Y107.274 E.00153
G1 X89.291 Y107.239 E.00153
G1 X89.256 Y107.203 E.00153
G1 X89.221 Y107.168 E.00153
G1 X89.186 Y107.132 E.00153
G1 X89.151 Y107.097 E.00153
G1 X89.117 Y107.061 E.00153
G1 X89.082 Y107.026 E.00153
G1 X89.047 Y106.991 E.00153
G1 X89.012 Y106.955 E.00153
G1 X88.977 Y106.92 E.00153
G3 X88.487 Y106.262 I11.358 J-8.982 E.02522
G1 X88.254 Y105.919 E.01274
; WIPE_START
M204 S6000
G1 X88.22 Y105.868 E-.02313
G1 X87.328 Y105.763 E-.34121
G1 X86.452 Y105.611 E-.33802
G1 X86.304 Y105.578 E-.05765
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z4
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z4 F4000
            G39.3 S1
            G0 Z4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X82.521 Y105.155 F42000
G1 Z3.6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X80.558 Y107.118 E.09209
G2 X82.047 Y107.775 I10.33 J-21.416 E.054
; WIPE_START
G1 X80.558 Y107.118 E-.6185
G1 X80.821 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X85.159 Y109.965 Z4 F42000
G1 Z3.6
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.432285
G1 F9245.831
M204 S6000
G1 X85.457 Y110.832 E.02909
G2 X88.024 Y113.33 I4.545 J-2.103 E.11623
G1 X88.715 Y113.578 E.02328
G2 X93.523 Y112.292 I1.265 J-4.902 E.16511
G1 X94.006 Y111.74 E.02328
G2 X94.823 Y110.03 I-4.34 J-3.124 E.06045
M204 S10000
G1 X95.095 Y109 F42000
; LINE_WIDTH: 0.412947
G1 F9729.04
M204 S6000
G1 X94.442 Y109.147 E.0202
G1 X94.672 Y109.387 E.01002
G1 X94.84 Y109.972 E.01836
G3 X95.076 Y109.057 I4.002 J.545 E.02858
; WIPE_START
G1 X94.968 Y109.374 E-.12734
G1 X94.84 Y109.972 E-.23253
G1 X94.672 Y109.387 E-.23138
G1 X94.442 Y109.147 E-.12631
G1 X94.551 Y109.122 E-.04243
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X86.949 Y109.804 Z4 F42000
G1 X85.159 Y109.965 Z4
G1 Z3.6
G1 E.8 F1800
; LINE_WIDTH: 0.411894
G1 F9756.786
M204 S6000
G1 X85.264 Y109.489 E.01464
G3 X85.56 Y109.147 I.75 J.35 E.01377
G1 X84.903 Y109 E.02023
G3 X85.146 Y109.906 I-5.158 J1.868 E.02825
; WIPE_START
G1 X85.046 Y109.455 E-.17546
G1 X84.903 Y109 E-.18141
G1 X85.56 Y109.147 E-.25574
G1 X85.355 Y109.338 E-.10616
G1 X85.299 Y109.431 E-.04123
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X92.501 Y106.903 Z4 F42000
G1 X97.479 Y105.155 Z4
G1 Z3.6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G1 X99.442 Y107.118 E.09209
G3 X97.953 Y107.775 I-10.327 J-21.408 E.054
; WIPE_START
G1 X99.442 Y107.118 E-.6185
G1 X99.179 Y106.855 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X103.193 Y100.363 Z4 F42000
G1 X111.53 Y86.877 Z4
G1 Z3.6
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X111.533 Y88.505 I-16.638 J.843 E.05402
G1 X108.847 Y85.82 E.12599
G3 X108.898 Y86.454 I-6.446 J.832 E.02112
G1 X111.236 Y84.116 E.1097
M73 P71 R6
G2 X109.676 Y78.972 I-23.891 J4.439 E.17866
G1 X98.778 Y68.074 E.51125
G2 X97.208 Y67.44 I-11.401 J25.994 E.05618
G1 X95.132 Y69.516 E.09735
G3 X100.405 Y71.919 I-5.171 J18.336 E.19297
G1 X102.278 Y70.046 E.08787
G3 X106.318 Y73.682 I-14.113 J19.74 E.18067
G1 X104.473 Y75.527 E.08658
G3 X107.405 Y80.271 I-14.576 J12.289 E.18566
G1 X109.368 Y78.308 E.09209
M204 S10000
G1 X92.379 Y66.335 F42000
G1 F8843.478
M204 S6000
G2 X90.755 Y66.217 I-2.513 J23.335 E.054
G1 X89.754 Y67.218 E.04697
G3 X90.23 Y67.202 I.265 J.817 E.01601
G1 X89.245 Y66.217 E.04622
G2 X87.622 Y66.335 I.872 J23.262 E.054
M204 S10000
G1 X70.632 Y78.308 F42000
G1 F8843.478
M204 S6000
G1 X72.595 Y80.271 E.09209
G3 X75.527 Y75.527 I17.509 J7.545 E.18566
G1 X73.682 Y73.682 E.08658
G3 X77.722 Y70.046 I18.153 J16.105 E.18067
G1 X79.595 Y71.919 E.08787
G3 X84.868 Y69.516 I10.444 J15.932 E.19297
G1 X82.792 Y67.44 E.09735
G2 X81.222 Y68.074 I9.83 J26.627 E.05618
G1 X70.324 Y78.972 E.51125
G2 X68.764 Y84.116 I22.33 J9.583 E.17866
G1 X71.102 Y86.454 E.1097
G3 X71.153 Y85.82 I6.522 J.199 E.02112
G1 X68.467 Y88.505 E.12599
G3 X68.47 Y86.877 I16.64 J-.785 E.05402
M204 S10000
G1 X71.39 Y91.299 F42000
G1 F8843.478
M204 S6000
G2 X71.766 Y92.882 I20.438 J-4.007 E.054
G1 X69.69 Y94.958 E.09735
G3 X68.849 Y91.876 I37.421 J-11.88 E.10598
G1 X72.919 Y95.947 E.19094
G2 X74.169 Y98.155 I18.581 J-9.057 E.08424
G1 X72.296 Y100.028 E.08787
G2 X75.932 Y104.068 I19.741 J-14.113 E.18067
G1 X77.777 Y102.223 E.08658
G2 X81.803 Y104.831 I13.767 J-16.836 E.15944
G1 X85.774 Y108.802 E.18629
G1 X86.001 Y108.853 E.00771
G1 X86.033 Y108.97 E.00404
G3 X86.366 Y108.986 I.099 J1.42 E.01108
G1 X88.213 Y107.139 E.08669
G2 X89.808 Y108.301 I2.169 J-1.301 E.06724
G2 X91.141 Y107.853 I.171 J-1.699 E.04806
G2 X91.787 Y107.139 I-2.204 J-2.641 E.03206
G1 X93.634 Y108.986 E.08669
G3 X93.965 Y108.97 I.235 J1.419 E.01101
G1 X93.995 Y108.854 E.00398
G1 X94.226 Y108.802 E.00786
G1 X98.197 Y104.831 E.18629
G2 X102.223 Y102.223 I-9.743 J-19.448 E.15944
G1 X104.068 Y104.068 E.08658
G2 X107.704 Y100.028 I-16.104 J-18.153 E.18067
G1 X105.831 Y98.155 E.08787
G2 X107.081 Y95.947 I-16.99 J-11.072 E.08424
G1 X111.151 Y91.876 E.19094
G3 X110.31 Y94.958 I-38.255 J-8.797 E.10598
G1 X108.234 Y92.882 E.09735
G2 X108.61 Y91.299 I-21.376 J-5.904 E.054
; WIPE_START
G1 X108.234 Y92.882 E-.6185
G1 X108.498 Y93.146 E-.1415
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.261 Y97.546 Z4 F42000
G1 X89.998 Y106.199 Z4
G1 Z3.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X89.716 Y105.981 E.01183
G3 X88.87 Y104.868 I5.689 J-5.198 E.04644
G1 X88.87 Y104.138 E.02421
G1 X88.82 Y103.901 E.00803
G1 X88.637 Y103.672 E.00971
G1 X88.37 Y103.563 E.00957
G3 X88.365 Y71.938 I1.629 J-15.813 E1.54814
G1 X88.637 Y71.828 E.00972
G1 X88.82 Y71.599 E.00971
G1 X88.87 Y71.362 E.00803
G1 X88.87 Y70.635 E.02413
G3 X89.75 Y69.492 I7.189 J4.625 E.04788
G1 X89.986 Y69.309 E.00992
G1 X90.25 Y69.481 E.01045
G3 X91.13 Y70.637 I-5.697 J5.253 E.04824
G1 X91.13 Y71.362 E.02407
G1 X91.18 Y71.599 E.00803
G1 X91.278 Y71.749 E.00593
G1 X91.473 Y71.892 E.00804
G3 X93.486 Y72.244 I-9.508 J60.357 E.06777
G3 X105.888 Y88.142 I-3.49 J15.509 E.7245
G3 X91.635 Y103.562 I-15.882 J-.383 E.76096
G1 X91.363 Y103.672 E.00972
G1 X91.18 Y103.901 E.00971
G1 X91.13 Y104.138 E.00803
G1 X91.13 Y104.865 E.02413
G3 X90.26 Y105.999 I-8.253 J-5.435 E.04745
G1 X90.046 Y106.163 E.00893
M204 S250
G1 X90.047 Y106.588 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X89.867 Y106.569 I-.049 J-.392 E.00561
G1 X89.469 Y106.296 E.01481
G3 X88.478 Y104.986 I7.896 J-7.006 E.05052
G1 X88.478 Y104.138 E.02608
G1 X88.43 Y104.012 E.00413
G1 X88.317 Y103.951 E.00394
G3 X87.61 Y71.637 I1.687 J-16.202 E1.44665
G1 X88.402 Y71.513 E.02464
G1 X88.478 Y71.362 E.00519
G1 X88.478 Y70.514 E.02605
G3 X89.598 Y69.086 I7.35 J4.61 E.05586
G1 X89.943 Y68.913 E.01187
G1 X90.123 Y68.929 E.00557
G1 X90.522 Y69.196 E.01475
G3 X91.522 Y70.515 I-6.507 J5.97 E.05093
G1 X91.522 Y71.362 E.02603
G1 X91.598 Y71.513 E.00519
G3 X93.571 Y71.861 I-11.339 J70.115 E.06158
G3 X106.28 Y88.151 I-3.576 J15.892 E.68767
G3 X92.39 Y103.863 I-16.289 J-.404 E.70002
G1 X91.598 Y103.987 E.02464
G1 X91.522 Y104.138 E.00519
G1 X91.522 Y104.986 E.02605
G3 X90.459 Y106.355 I-8.482 J-5.483 E.05334
G1 X90.213 Y106.527 E.00924
G3 X90.106 Y106.576 I-.215 J-.331 E.00363
; WIPE_START
M204 S6000
G1 X89.867 Y106.569 E-.09075
G1 X89.469 Y106.296 E-.18321
G1 X89.056 Y105.813 E-.24161
G1 X88.687 Y105.286 E-.24442
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.526 Y103.719 Z4 F42000
G1 Z3.6
G1 E.8 F1800
; FEATURE: Floating vertical shell
G1 F9547.299
M204 S6000
G1 X90.623 Y103.646 E.00373
G1 X90.932 Y103.595 E.00962
G1 X90.848 Y103.7 E.00413
G1 X90.738 Y104.138 E.01387
G1 X90.738 Y104.741 E.01855
G3 X89.994 Y105.704 I-7.431 J-4.975 E.03739
G3 X89.262 Y104.746 I4.716 J-4.365 E.03709
G1 X89.262 Y104.188 E.01714
G1 X89.19 Y103.779 E.01278
G1 X89.068 Y103.595 E.00677
G1 X89.32 Y103.624 E.00778
G1 X89.528 Y103.738 E.00728
G2 X89.851 Y104.157 I1.124 J-.532 E.0164
G1 X90.097 Y104.165 E.00756
G1 X90.262 Y104.067 E.00591
G1 X90.401 Y103.813 E.00889
G1 X90.478 Y103.755 E.00295
M204 S10000
G1 X90.169 Y104.848 F42000
; Slow Down Start
; LINE_WIDTH: 0.44631
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G1 X89.982 Y105.09 E.01004
G1 X89.665 Y104.641 E.01807
G1 X89.652 Y104.46 E.00595
G1 X89.742 Y104.532 E.00379
G1 X89.903 Y104.555 E.00534
G1 X90.264 Y104.531 E.01188
G1 X90.348 Y104.462 E.00356
G1 X90.335 Y104.631 E.00557
G1 X90.205 Y104.8 E.007
; Slow Down End
; WIPE_START
G1 X90.335 Y104.631 E-.08096
G1 X90.348 Y104.462 E-.0644
G1 X90.264 Y104.531 E-.04111
G1 X89.903 Y104.555 E-.13729
G1 X89.742 Y104.532 E-.06171
G1 X89.652 Y104.46 E-.04385
G1 X89.665 Y104.641 E-.06875
G1 X89.982 Y105.09 E-.20892
G1 X90.067 Y104.979 E-.05301
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X83.217 Y101.613 Z4 F42000
G1 X81.503 Y100.771 Z4
G1 Z3.6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X80.187 Y99.813 I9.602 J-14.564 E.05401
G1 X102.063 Y77.937 E1.02624
G2 X97.943 Y74.381 I-12.208 J9.977 E.18144
G1 X76.631 Y95.693 E.99981
G3 X75.876 Y94.251 I15.176 J-8.867 E.05401
M204 S10000
G1 X79.029 Y76.73 F42000
G1 F8843.478
M204 S6000
G2 X77.937 Y77.937 I65.769 J60.548 E.05399
G1 X99.813 Y99.813 E1.02624
G2 X103.369 Y95.693 I-9.977 J-12.208 E.18144
G1 X82.057 Y74.381 E.99981
G2 X80.703 Y75.284 I48.043 J73.446 E.05399
M204 S10000
G1 X90.537 Y71.794 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S6000
G1 X90.709 Y71.89 E.00606
M73 P71 R5
G1 X90.936 Y71.91 E.00699
G1 X90.812 Y71.729 E.00672
G1 X90.74 Y71.327 E.01257
G1 X90.738 Y70.759 E.01745
G2 X90.001 Y69.796 I-5.484 J3.432 E.03731
G2 X89.262 Y70.759 I9.893 J8.361 E.03733
G1 X89.259 Y71.431 E.02067
G1 X89.152 Y71.8 E.0118
G1 X89.068 Y71.905 E.00413
G1 X89.369 Y71.859 E.00935
G1 X89.605 Y71.689 E.00896
G1 X89.75 Y71.457 E.00839
G1 X89.91 Y71.368 E.00563
G1 X90.138 Y71.374 E.00701
G3 X90.43 Y71.733 I-.942 J1.065 E.0143
G1 X90.485 Y71.764 E.00193
M204 S10000
G1 X90.191 Y70.674 F42000
; Slow Down Start
; LINE_WIDTH: 0.45937
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G1 X90.002 Y70.416 E.01086
G1 X89.658 Y70.889 E.01985
G1 X89.657 Y71.066 E.00601
G1 X89.758 Y70.991 E.00425
G3 X90.237 Y70.99 I.243 J1.267 E.01636
G1 X90.343 Y71.069 E.00448
G1 X90.327 Y70.861 E.00708
G1 X90.226 Y70.723 E.00582
; Slow Down End
; WIPE_START
G1 X90.327 Y70.861 E-.06512
G1 X90.343 Y71.069 E-.07932
G1 X90.237 Y70.99 E-.05021
G1 X90.09 Y70.971 E-.05622
G1 X89.758 Y70.991 E-.12654
G1 X89.657 Y71.066 E-.04757
G1 X89.658 Y70.889 E-.06734
G1 X90.002 Y70.416 E-.22227
G1 X90.073 Y70.512 E-.0454
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X95.291 Y73.128 Z4 F42000
G1 Z3.6
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X96.79 Y73.762 I-6.113 J16.534 E.05401
G1 X103.988 Y80.96 E.33768
G3 X104.772 Y82.904 I-25.141 J11.278 E.06953
G1 X85.154 Y102.522 E.92036
G2 X87.79 Y103.142 I4.959 J-15.179 E.08996
G1 X74.608 Y89.96 E.61841
G1 X74.617 Y90.031 E.00238
G1 X92.281 Y72.367 E.82866
G3 X91.349 Y72.214 I-.074 J-2.473 E.03153
G1 X91.278 Y72.332 E.00456
G3 X90 Y71.804 I-.203 J-1.319 E.04824
G3 X88.718 Y72.334 I-1.098 J-.839 E.04823
G1 X88.647 Y72.216 E.00458
G3 X87.719 Y72.367 I-1.802 J-8.136 E.03121
G1 X105.383 Y90.031 E.82866
G1 X105.392 Y89.96 E.00238
G1 X92.21 Y103.142 E.61841
G2 X94.846 Y102.522 I-2.323 J-15.799 E.08996
G1 X75.228 Y82.904 E.92036
G3 X76.012 Y80.96 I25.929 J9.336 E.06953
G1 X83.21 Y73.762 E.33768
G3 X84.709 Y73.128 I7.612 J15.901 E.05401
; CHANGE_LAYER
; Z_HEIGHT: 3.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8843.478
G1 X83.21 Y73.762 E-.61845
G1 X82.947 Y74.025 E-.14155
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 19/25
; update layer progress
M73 L19
M991 S0 P18 ;notify layer change
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z4 I-1.216 J.047 P1  F42000
G1 X84.285 Y108.899 Z4
G1 Z3.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X111.897 Y87.79 I5.787 J-21.115 E3.22945
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49733
G1 X84.527 Y109.077 E.00982
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.112 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.892 J-21.493 E3.04525
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.118 I-5.602 J-1.462 E.47076
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25113
G1 X82.491 Y108.737 E-.41561
G1 X82.262 Y108.649 E-.09326
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z4.2 F42000
G1 X94.196 Y109.433 Z4.2
G1 Z3.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01326
G3 X94.078 Y110.881 I-3.848 J-.924 E.03357
G1 X93.721 Y111.457 E.02248
G1 X93.397 Y111.841 E.01666
G1 X92.776 Y112.419 E.02815
G1 X92.353 Y112.695 E.01673
G1 X91.59 Y113.067 E.02816
G1 X91.107 Y113.207 E.0167
G1 X90.268 Y113.343 E.02818
G1 X89.765 Y113.337 E.01667
G1 X88.923 Y113.223 E.02819
G1 X88.443 Y113.071 E.01671
G1 X87.671 Y112.718 E.02815
G3 X86.923 Y112.16 I2.853 J-4.608 E.03099
G3 X85.563 Y109.932 I3.085 J-3.413 E.0878
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X93.759 Y109.316 I3.838 J-21.967 E.25429
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.02431
G3 X87.34 Y112.013 I-3.394 J-2.535 E.20915
G1 X87.194 Y111.876 E.00614
G3 X86.201 Y110.562 I3.052 J-3.338 E.05089
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.788 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.156 E.23767
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05566
G1 X94.037 Y109.947 E-.06472
G1 X93.789 Y110.564 E-.25267
G1 X93.389 Y111.247 E-.30061
G1 X93.241 Y111.419 E-.08633
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.174 Y106.267 Z4.2 F42000
G1 Z3.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X87.525 Y106.182 E.02171
G3 X77.518 Y73.958 I2.474 J-18.434 E1.40209
G3 X88.162 Y69.249 I12.473 J13.81 E.39267
M73 P72 R5
G3 X88.916 Y68.373 I4.435 J3.054 E.0384
G1 X89.37 Y68.054 E.01839
G1 X89.559 Y67.973 E.00684
G1 X90.005 Y67.888 E.01507
G1 X90.553 Y68.011 E.0186
G1 X90.974 Y68.281 E.0166
G1 X91.509 Y68.821 E.02521
G1 X91.826 Y69.233 E.01724
G1 X92.478 Y69.318 E.02181
G3 X91.838 Y106.251 I-2.471 J18.429 E1.79466
G3 X91.076 Y107.134 I-4.421 J-3.043 E.03876
G1 X90.629 Y107.446 E.01808
G1 X90.438 Y107.528 E.00689
G1 X89.986 Y107.612 E.01525
G1 X89.448 Y107.489 E.01832
G1 X89.017 Y107.212 E.01699
G1 X88.493 Y106.681 E.02474
G1 X88.211 Y106.315 E.01534
M204 S250
G1 X88.346 Y105.881 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X87.785 Y105.821 E.01734
G3 X77.774 Y74.254 I2.22 J-18.075 E1.27742
G3 X88.374 Y69.62 I12.232 J13.535 E.36172
G1 X88.784 Y69.083 E.02074
G1 X88.824 Y69.042 E.00176
G1 X88.863 Y69 E.00176
G1 X88.902 Y68.959 E.00176
G1 X88.941 Y68.917 E.00176
G1 X88.981 Y68.875 E.00176
G1 X89.02 Y68.834 E.00176
G1 X89.059 Y68.792 E.00176
G1 X89.098 Y68.751 E.00176
G1 X89.138 Y68.709 E.00176
G1 X89.177 Y68.668 E.00176
G3 X89.239 Y68.618 I.132 J.101 E.00248
G1 X89.336 Y68.555 E.00355
G1 X89.433 Y68.493 E.00355
G1 X89.531 Y68.43 E.00355
G1 X89.628 Y68.368 E.00355
G3 X89.775 Y68.332 I.117 J.16 E.00477
G1 X89.934 Y68.302 E.00498
G3 X90.109 Y68.304 I.085 J.192 E.00553
G1 X90.235 Y68.336 E.004
G1 X90.361 Y68.368 E.004
G3 X90.473 Y68.421 I-.018 J.183 E.0039
G1 X90.576 Y68.49 E.00379
G1 X90.678 Y68.559 E.00379
G1 X90.78 Y68.628 E.00379
G3 X90.825 Y68.671 I-.075 J.123 E.00193
G1 X90.863 Y68.711 E.00168
G1 X90.901 Y68.751 E.00168
G1 X90.939 Y68.79 E.00168
G1 X90.976 Y68.83 E.00169
G1 X91.014 Y68.87 E.00168
G1 X91.052 Y68.91 E.00168
G1 X91.09 Y68.949 E.00168
G1 X91.127 Y68.989 E.00169
G1 X91.165 Y69.029 E.00168
G1 X91.203 Y69.069 E.00168
G1 X91.623 Y69.616 E.0212
G3 X91.626 Y105.88 I-1.624 J18.132 E1.65732
G1 X91.216 Y106.416 E.02073
G1 X91.177 Y106.458 E.00175
G1 X91.137 Y106.499 E.00175
G1 X91.098 Y106.541 E.00175
G1 X91.059 Y106.582 E.00175
G1 X91.02 Y106.623 E.00175
G1 X90.98 Y106.665 E.00175
G1 X90.941 Y106.706 E.00175
G1 X90.902 Y106.748 E.00175
G1 X90.863 Y106.789 E.00175
G1 X90.824 Y106.831 E.00175
G3 X90.773 Y106.876 I-.117 J-.079 E.00212
G1 X90.673 Y106.94 E.00364
G1 X90.573 Y107.004 E.00364
G1 X90.473 Y107.068 E.00364
G1 X90.373 Y107.132 E.00364
G3 X90.218 Y107.169 I-.123 J-.169 E.00504
G1 X90.047 Y107.2 E.00532
G3 X89.893 Y107.198 I-.076 J-.169 E.00488
G1 X89.766 Y107.165 E.00403
G1 X89.639 Y107.132 E.00403
G3 X89.529 Y107.08 I.019 J-.18 E.00379
G1 X89.433 Y107.015 E.00359
G1 X89.336 Y106.949 E.00359
G1 X89.239 Y106.884 E.00359
G3 X89.178 Y106.833 I.083 J-.164 E.00246
G1 X89.139 Y106.793 E.0017
G1 X89.101 Y106.753 E.0017
G1 X89.063 Y106.713 E.0017
G1 X89.025 Y106.673 E.0017
G1 X88.987 Y106.633 E.0017
G1 X88.949 Y106.592 E.0017
G1 X88.911 Y106.552 E.0017
G1 X88.873 Y106.512 E.0017
G1 X88.835 Y106.472 E.0017
G1 X88.797 Y106.432 E.0017
G1 X88.395 Y105.907 E.02033
; WIPE_START
M204 S6000
G1 X87.785 Y105.821 E-.23397
G1 X86.869 Y105.683 E-.35191
G1 X86.42 Y105.594 E-.17412
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4.2 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z4.2
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z4.2 F4000
            G39.3 S1
            G0 Z4.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X85.159 Y109.965 F42000
G1 Z3.8
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.433891
G1 F9207.843
M204 S6000
G1 X85.457 Y110.832 E.02921
G2 X87.865 Y113.265 I4.625 J-2.168 E.11121
G1 X88.715 Y113.579 E.02887
G2 X93.523 Y112.292 I1.265 J-4.901 E.16579
G1 X94.006 Y111.739 E.02338
G2 X94.823 Y110.03 I-4.339 J-3.123 E.06069
M204 S10000
G1 X95.095 Y109 F42000
; LINE_WIDTH: 0.412963
G1 F9728.616
M204 S6000
G1 X94.442 Y109.147 E.0202
G1 X94.672 Y109.387 E.01002
G1 X94.84 Y109.972 E.01836
G3 X95.076 Y109.057 I4.005 J.546 E.02857
; WIPE_START
G1 X94.968 Y109.374 E-.12733
G1 X94.84 Y109.972 E-.23251
G1 X94.672 Y109.387 E-.23135
G1 X94.442 Y109.147 E-.12631
G1 X94.551 Y109.122 E-.04249
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X86.949 Y109.804 Z4.2 F42000
G1 X85.159 Y109.965 Z4.2
G1 Z3.8
G1 E.8 F1800
; LINE_WIDTH: 0.41193
G1 F9755.831
M204 S6000
G1 X85.264 Y109.489 E.01464
G3 X85.56 Y109.147 I.75 J.35 E.01377
G1 X84.903 Y109 E.02024
G3 X85.146 Y109.906 I-5.157 J1.868 E.02825
; WIPE_START
G1 X85.046 Y109.455 E-.17547
G1 X84.903 Y109 E-.18139
G1 X85.56 Y109.147 E-.25573
G1 X85.355 Y109.338 E-.10615
G1 X85.299 Y109.431 E-.04126
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X82.047 Y107.775 Z4.2 F42000
G1 Z3.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X80.558 Y107.118 I8.841 J-22.072 E.054
G1 X82.521 Y105.155 E.09209
; WIPE_START
G1 X81.107 Y106.569 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.739 Y106.617 Z4.2 F42000
G1 X91.97 Y106.637 Z4.2
G1 Z3.8
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.407515
G1 F9873.97
M204 S6000
G1 X91.772 Y106.898 E.00975
; LINE_WIDTH: 0.456705
G1 F8700.171
G1 X91.573 Y107.16 E.01106
; LINE_WIDTH: 0.428318
G1 F9340.993
G1 X91.499 Y107.243 E.00349
; LINE_WIDTH: 0.468794
G1 F8453.205
G1 X91.425 Y107.326 E.00386
; LINE_WIDTH: 0.50927
G1 F7719.524
G1 X91.352 Y107.409 E.00422
; LINE_WIDTH: 0.549746
G1 F7103.03
G1 X91.278 Y107.492 E.00459
; LINE_WIDTH: 0.590222
G1 F6577.721
G1 X91.204 Y107.574 E.00496
; LINE_WIDTH: 0.456705
G1 F8700.171
G1 X91.018 Y107.726 E.00807
; LINE_WIDTH: 0.407515
G1 F9873.97
G1 X90.833 Y107.878 E.00711
M204 S10000
G1 X90.786 Y107.916 F42000
; Slow Down Start
; LINE_WIDTH: 0.59044
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G1 X90.138 Y107.976 E.02906
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.415601
;_EXTRUDE_SET_SPEED
G3 X89.576 Y107.901 I-.128 J-1.181 E.01739
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.414354
;_EXTRUDE_SET_SPEED
G1 X89.499 Y107.91 E.00233
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.4554
;_EXTRUDE_SET_SPEED
G1 X89.423 Y107.919 E.00259
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.496447
;_EXTRUDE_SET_SPEED
G1 X89.346 Y107.927 E.00285
; Slow Down End
; Slow Down Start
;_EXTRUDE_SET_SPEED
G1 X89.3 Y107.933 E.00172
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.4554
;_EXTRUDE_SET_SPEED
G1 X89.253 Y107.938 E.00157
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.414354
;_EXTRUDE_SET_SPEED
G1 X89.207 Y107.943 E.00141
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.59157
;_EXTRUDE_SET_SPEED
G1 X89.505 Y108.256 E.01933
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.408358
;_EXTRUDE_SET_SPEED
G1 X89.918 Y108.347 E.01258
G1 X90.251 Y108.331 E.00992
G1 X90.648 Y108.117 E.01344
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.512469
;_EXTRUDE_SET_SPEED
G1 X90.683 Y108.066 E.00235
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.551665
;_EXTRUDE_SET_SPEED
G1 X90.718 Y108.015 E.00255
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.590862
;_EXTRUDE_SET_SPEED
G1 X90.752 Y107.965 E.00274
; Slow Down End
M204 S10000
G1 X89.18 Y107.897 F42000
; LINE_WIDTH: 0.594906
G1 F6521.905
M204 S6000
G1 X89.099 Y107.827 E.00481
; LINE_WIDTH: 0.551358
G1 F7080.51
G1 X89.018 Y107.758 E.00443
; LINE_WIDTH: 0.50781
G1 F7743.767
G1 X88.936 Y107.689 E.00405
; LINE_WIDTH: 0.464262
G1 F8544.128
G1 X88.855 Y107.62 E.00367
; LINE_WIDTH: 0.420714
G1 F9529.004
G1 X88.774 Y107.55 E.00329
; LINE_WIDTH: 0.48367
G1 F8167.895
G1 X88.641 Y107.399 E.00722
; LINE_WIDTH: 0.44337
G1 F8989.887
G1 X88.509 Y107.248 E.00656
; LINE_WIDTH: 0.40307
G1 F9995.836
G1 X88.377 Y107.097 E.0059
; LINE_WIDTH: 0.420714
G1 F9529.004
G1 X88.312 Y107.012 E.00328
; LINE_WIDTH: 0.464262
G1 F8544.128
G1 X88.247 Y106.927 E.00366
; LINE_WIDTH: 0.50781
G1 F7743.767
G1 X88.183 Y106.842 E.00404
; LINE_WIDTH: 0.551358
G1 F7080.51
G1 X88.118 Y106.757 E.00442
; LINE_WIDTH: 0.594906
G1 F6521.905
G1 X88.054 Y106.673 E.0048
; WIPE_START
G1 X88.118 Y106.757 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X95.71 Y107.543 Z4.2 F42000
G1 X97.953 Y107.775 Z4.2
G1 Z3.8
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X99.442 Y107.118 I-8.838 J-22.065 E.054
G1 X97.479 Y105.155 E.09209
; WIPE_START
G1 X98.893 Y106.569 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.99 Y100.13 Z4.2 F42000
G1 X108.61 Y91.299 Z4.2
G1 Z3.8
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X108.234 Y92.882 I-20.445 J-4.009 E.054
G1 X110.31 Y94.958 E.09735
G2 X111.151 Y91.876 I-37.413 J-11.878 E.10598
G1 X107.081 Y95.947 E.19094
G3 X105.831 Y98.155 I-18.574 J-9.053 E.08424
G1 X107.704 Y100.028 E.08787
G3 X104.068 Y104.068 I-19.74 J-14.113 E.18067
G1 X102.223 Y102.223 E.08658
G3 X98.197 Y104.831 I-13.741 J-16.795 E.15945
G1 X94.226 Y108.802 E.18628
G1 X93.995 Y108.854 E.00786
G1 X93.965 Y108.97 E.00398
G2 X93.634 Y108.986 I-.095 J1.435 E.01101
G1 X91.945 Y107.297 E.07926
G1 X91.896 Y107.373 E.00301
G3 X90.302 Y108.732 I-2.715 J-1.57 E.07082
G3 X88.436 Y107.824 I-.198 J-1.965 E.07247
G3 X88.053 Y107.299 I5 J-4.051 E.02157
G1 X86.366 Y108.986 E.07917
G2 X86.033 Y108.97 I-.234 J1.405 E.01107
G1 X86.001 Y108.853 E.00404
G1 X85.774 Y108.802 E.00772
G1 X81.803 Y104.831 E.18628
G3 X77.777 Y102.223 I9.712 J-19.4 E.15945
G1 X75.932 Y104.068 E.08658
G3 X72.296 Y100.028 I16.105 J-18.153 E.18067
G1 X74.169 Y98.155 E.08787
G3 X72.919 Y95.947 I17.331 J-11.265 E.08424
G1 X68.849 Y91.876 E.19094
G2 X69.69 Y94.958 I38.263 J-8.799 E.10598
G1 X71.766 Y92.882 E.09735
G3 X71.39 Y91.299 I20.063 J-5.591 E.054
M204 S10000
G1 X68.47 Y86.877 F42000
G1 F8843.478
M204 S6000
G2 X68.467 Y88.505 I16.638 J.843 E.05402
G1 X71.153 Y85.82 E.12599
G2 X71.102 Y86.454 I6.471 J.834 E.02112
G1 X68.764 Y84.116 E.1097
G3 X70.324 Y78.972 I23.89 J4.439 E.17866
G1 X81.222 Y68.074 E.51125
G3 X82.792 Y67.44 I11.401 J25.993 E.05618
G1 X84.868 Y69.516 E.09735
G2 X79.595 Y71.919 I5.169 J18.329 E.19297
G1 X77.722 Y70.046 E.08787
G2 X73.682 Y73.682 I14.114 J19.741 E.18067
G1 X75.528 Y75.528 E.08658
G2 X72.596 Y80.271 I14.542 J12.266 E.18566
G1 X70.632 Y78.308 E.09211
; WIPE_START
G1 X72.046 Y79.722 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X78.455 Y75.577 Z4.2 F42000
G1 X90.796 Y67.594 Z4.2
G1 Z3.8
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.60602
G1 F6393.181
M204 S6000
G1 X91.335 Y68.062 E.03275
; LINE_WIDTH: 0.43952
G1 F9077.156
G1 X91.78 Y68.596 E.02247
; LINE_WIDTH: 0.38292
G1 F10588.235
G1 X91.935 Y68.814 E.0074
M204 S10000
G1 X90.247 Y67.17 F42000
; Slow Down Start
; LINE_WIDTH: 0.412346
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G1 X90.003 Y67.138 E.00743
G1 X89.614 Y67.21 E.01191
G1 X89.38 Y67.35 E.0082
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.46435
;_EXTRUDE_SET_SPEED
G1 X89.21 Y67.586 E.01001
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.590162
;_EXTRUDE_SET_SPEED
G1 X89.728 Y67.554 E.02318
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.411064
;_EXTRUDE_SET_SPEED
G1 X90.011 Y67.504 E.0086
G1 X90.532 Y67.582 E.01582
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.495421
;_EXTRUDE_SET_SPEED
G1 X90.608 Y67.585 E.00279
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.532402
;_EXTRUDE_SET_SPEED
G1 X90.683 Y67.589 E.00302
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.564674
;_EXTRUDE_SET_SPEED
G1 X90.74 Y67.591 E.0024
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.603902
;_EXTRUDE_SET_SPEED
G1 X90.796 Y67.594 E.00258
G1 X90.606 Y67.348 E.01422
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.461943
;_EXTRUDE_SET_SPEED
G1 X90.453 Y67.272 E.00581
; Slow Down End
; Slow Down Start
; LINE_WIDTH: 0.431968
;_EXTRUDE_SET_SPEED
G1 X90.301 Y67.197 E.00539
; Slow Down End
M204 S10000
G1 X88.003 Y68.899 F42000
; LINE_WIDTH: 0.38292
G1 F10588.235
M204 S6000
G1 X88.609 Y68.124 E.02724
; LINE_WIDTH: 0.45464
G1 F8743.807
G1 X89.031 Y67.716 E.01969
; LINE_WIDTH: 0.58444
G1 F6647.954
G1 X89.161 Y67.622 E.00709
M204 S10000
G1 X92.379 Y66.335 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X90.755 Y66.217 I-2.513 J23.332 E.054
G1 X90.206 Y66.766 E.02575
G2 X89.803 Y66.776 I-.185 J.69 E.01356
G1 X89.245 Y66.217 E.0262
G2 X87.622 Y66.335 I.869 J23.227 E.054
; WIPE_START
G1 X89.245 Y66.217 E-.61849
G1 X89.508 Y66.48 E-.14151
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.066 Y70.386 Z4.2 F42000
G1 X109.368 Y78.308 Z4.2
G1 Z3.8
G1 E.8 F1800
G1 F8843.478
M204 S6000
G1 X107.405 Y80.271 E.09211
G2 X104.472 Y75.528 I-17.474 J7.522 E.18566
G1 X106.318 Y73.682 E.08658
G2 X102.278 Y70.046 I-18.153 J16.104 E.18067
G1 X100.405 Y71.919 E.08787
G2 X95.132 Y69.516 I-10.442 J15.927 E.19297
G1 X97.208 Y67.44 E.09735
G3 X98.778 Y68.074 I-9.831 J26.628 E.05618
G1 X109.676 Y78.972 E.51125
G3 X111.236 Y84.116 I-22.33 J9.583 E.17866
G1 X108.898 Y86.454 E.1097
G2 X108.847 Y85.82 I-6.497 J.197 E.02112
G1 X111.533 Y88.505 E.12599
G2 X111.53 Y86.877 I-16.64 J-.785 E.05402
; WIPE_START
G1 X111.533 Y88.505 E-.61858
G1 X111.27 Y88.242 E-.14143
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.389 Y93.108 Z4.2 F42000
G1 X89.992 Y105.847 Z4.2
G1 Z3.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X89.699 Y105.665 E.01143
G3 X89.003 Y104.857 I3.592 J-3.796 E.03545
G1 X89.003 Y104.154 E.02331
G1 X88.941 Y103.893 E.00892
G1 X88.743 Y103.67 E.00987
G1 X88.499 Y103.579 E.00866
G3 X88.494 Y71.922 I1.508 J-15.829 E1.55663
G1 X88.743 Y71.83 E.00882
G1 X88.941 Y71.606 E.00989
G1 X89.003 Y71.346 E.00889
G1 X89.003 Y70.65 E.02308
G3 X89.569 Y69.956 I5.433 J3.854 E.02972
G1 X89.916 Y69.677 E.01477
G1 X90.104 Y69.692 E.00625
G1 X90.434 Y69.963 E.01415
G1 X90.997 Y70.647 E.0294
G1 X90.997 Y71.346 E.02319
G1 X91.059 Y71.606 E.00889
G1 X91.257 Y71.83 E.00989
G1 X91.452 Y71.913 E.00705
G3 X102.04 Y77.376 I-1.536 J15.968 E.40491
G3 X105.888 Y88.142 I-12.107 J10.398 E.38786
G3 X91.506 Y103.578 I-15.894 J-.391 E.76523
G1 X91.257 Y103.67 E.00881
G1 X91.059 Y103.893 E.00987
G1 X90.997 Y104.153 E.00888
G1 X90.995 Y104.849 E.02309
G3 X90.259 Y105.709 I-3.879 J-2.579 E.03765
G1 X90.045 Y105.819 E.00797
M204 S250
G1 X90.073 Y106.23 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.83 Y106.219 E.00749
G1 X89.418 Y105.939 E.01528
G3 X88.611 Y104.983 I4.064 J-4.25 E.03853
G1 X88.611 Y104.154 E.02545
G1 X88.555 Y104.021 E.00445
G1 X88.451 Y103.968 E.00359
G3 X88.446 Y71.533 I1.555 J-16.218 E1.47683
G1 X88.555 Y71.479 E.00375
G1 X88.611 Y71.346 E.00445
G1 X88.611 Y70.52 E.02538
G3 X89.276 Y69.696 I5.827 J4.023 E.03254
G1 X89.66 Y69.379 E.01532
G1 X89.95 Y69.256 E.00967
G1 X90.273 Y69.328 E.01016
G1 X90.657 Y69.621 E.01483
G3 X91.389 Y70.518 I-7.716 J7.043 E.03562
G2 X91.409 Y71.43 I12.846 J.175 E.02803
G1 X91.508 Y71.521 E.00412
G3 X98.021 Y73.577 I-1.712 J16.768 E.21132
G3 X106.28 Y88.151 I-8.029 J14.178 E.54063
G3 X91.554 Y103.967 I-16.285 J-.4 E.72597
G1 X91.445 Y104.021 E.00374
G1 X91.389 Y104.154 E.00444
G1 X91.387 Y104.982 E.02545
G3 X90.581 Y105.94 I-4.912 J-3.316 E.03854
G1 X90.304 Y106.145 E.0106
G1 X90.129 Y106.21 E.00571
; WIPE_START
M204 S6000
G1 X89.83 Y106.219 E-.11396
G1 X89.418 Y105.939 E-.18901
G1 X89.025 Y105.525 E-.21695
G1 X88.642 Y105.023 E-.24008
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.809 Y103.593 Z4.2 F42000
G1 Z3.8
G1 E.8 F1800
; FEATURE: Floating vertical shell
G1 F9547.299
M204 S6000
G1 X90.735 Y103.677 E.00343
G1 X90.605 Y104.152 E.01513
G1 X90.604 Y104.716 E.01733
G3 X90.02 Y105.392 I-4.585 J-3.369 E.02745
G1 X89.98 Y105.392 E.00124
G1 X89.395 Y104.724 E.02727
G1 X89.395 Y104.219 E.01552
G1 X89.306 Y103.757 E.01445
G1 X89.183 Y103.584 E.00653
G2 X90.749 Y103.595 I.929 J-20.779 E.04811
M204 S10000
G1 X90.227 Y104.005 F42000
; LINE_WIDTH: 0.458976
G1 F8652.693
M204 S6000
G1 X89.776 Y104.016 E.0153
G1 X89.792 Y104.517 E.01698
G1 X89.835 Y104.644 E.00454
G1 X90.001 Y104.845 E.00883
G1 X90.207 Y104.582 E.01134
G1 X90.223 Y104.065 E.01752
M204 S10000
G1 X75.876 Y94.251 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X76.631 Y95.693 I15.931 J-7.425 E.05401
G1 X97.943 Y74.381 E.99981
G3 X102.063 Y77.937 I-8.088 J13.534 E.18144
G1 X80.187 Y99.813 E1.02624
G2 X81.503 Y100.771 I10.917 J-13.606 E.05401
M204 S10000
G1 X80.703 Y75.284 F42000
G1 F8843.478
M204 S6000
G3 X82.057 Y74.381 I49.397 J72.542 E.05399
G1 X103.369 Y95.693 E.99981
G3 X99.813 Y99.813 I-13.534 J-8.088 E.18144
G1 X77.937 Y77.937 E1.02624
G3 X79.029 Y76.73 I66.861 J59.341 E.05399
M204 S10000
G1 X84.709 Y73.128 F42000
G1 F8843.478
M204 S6000
G2 X83.21 Y73.762 I6.113 J16.535 E.05401
G1 X76.012 Y80.96 E.33768
G2 X75.228 Y82.904 I25.145 J11.279 E.06953
G1 X94.846 Y102.522 E.92036
G3 X92.21 Y103.142 I-4.956 J-15.168 E.08996
G1 X105.392 Y89.96 E.6184
G1 X105.383 Y90.031 E.00238
G1 X87.719 Y72.367 E.82866
G2 X88.764 Y72.207 I.059 J-3.115 E.03526
G1 X88.831 Y72.326 E.00452
G3 X91.169 Y72.326 I1.169 J15.112 E.07764
G1 X91.236 Y72.207 E.00452
G2 X92.281 Y72.367 I.986 J-2.954 E.03526
G1 X74.617 Y90.031 E.82866
G1 X74.608 Y89.96 E.00238
G1 X87.79 Y103.142 E.6184
G3 X85.154 Y102.522 I2.32 J-15.789 E.08996
G1 X104.772 Y82.904 E.92036
G2 X103.988 Y80.96 I-25.925 J9.334 E.06953
G1 X96.79 Y73.762 E.33768
G2 X95.291 Y73.128 I-7.612 J15.9 E.05401
M204 S10000
G1 X90.815 Y71.914 F42000
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S6000
G1 X90.695 Y71.749 E.00627
G1 X90.608 Y71.415 E.01062
G1 X90.605 Y70.782 E.01945
G1 X90.115 Y70.194 E.02351
G1 X89.999 Y70.107 E.00446
G1 X89.864 Y70.217 E.00533
G1 X89.395 Y70.786 E.02266
G1 X89.392 Y71.415 E.01934
G1 X89.265 Y71.821 E.01309
G1 X89.218 Y71.905 E.00295
G1 X90.322 Y71.896 E.03393
G3 X90.755 Y71.912 I.065 J4.101 E.01332
M204 S10000
G1 X90.222 Y71.499 F42000
; LINE_WIDTH: 0.460995
G1 F8610.902
M204 S6000
G1 X90.208 Y70.926 E.0195
G1 X90 Y70.676 E.0111
G1 X89.792 Y70.929 E.01116
G1 X89.778 Y71.502 E.01954
G1 X90.162 Y71.499 E.01307
; CHANGE_LAYER
; Z_HEIGHT: 4
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F8610.902
G1 X89.778 Y71.502 E-.14574
G1 X89.792 Y70.929 E-.21791
G1 X90 Y70.676 E-.12443
G1 X90.208 Y70.926 E-.12378
G1 X90.217 Y71.316 E-.14815
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 20/25
; update layer progress
M73 L20
M991 S0 P19 ;notify layer change
M106 S188.7
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z4.2 I-1.202 J-.19 P1  F42000
G1 X84.285 Y108.899 Z4.2
G1 Z4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X84.216 Y108.863 E.00257
G3 X111.897 Y87.79 I5.787 J-21.115 E3.22945
G3 X95.691 Y108.898 I-21.929 J-.061 E.94852
G1 X95.477 Y109.071 E.00911
G1 X95.367 Y109.32 E.00905
G1 X95.227 Y110.09 E.02594
G3 X84.637 Y109.352 I-5.227 J-1.341 E.49733
G1 X84.527 Y109.077 E.00982
M73 P73 R5
G1 X84.432 Y108.976 E.00462
G1 X84.338 Y108.927 E.0035
M204 S250
G1 X84.112 Y109.241 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X112.289 Y87.8 I5.892 J-21.493 E3.04524
G3 X95.858 Y109.252 I-22.3 J-.061 E.89193
G1 X95.753 Y109.39 E.00531
G1 X95.602 Y110.204 E.02544
G3 X84.376 Y110.118 I-5.602 J-1.462 E.47076
G1 X84.213 Y109.311 E.02533
G1 X84.161 Y109.275 E.00192
; WIPE_START
M204 S6000
G1 X83.53 Y109.08 E-.25113
G1 X82.491 Y108.737 E-.41561
G1 X82.262 Y108.649 E-.09327
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.878 Y109.15 Z4.4 F42000
G1 X94.195 Y109.433 Z4.4
G1 Z4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X94.332 Y109.552 E.00599
G1 X94.437 Y109.938 E.01325
G3 X94.148 Y110.723 I-3.197 J-.73 E.02783
G1 X93.721 Y111.457 E.02817
G1 X93.397 Y111.841 E.01667
G1 X92.776 Y112.419 E.02815
G1 X92.353 Y112.695 E.01673
G1 X91.59 Y113.067 E.02817
G1 X91.107 Y113.207 E.0167
G1 X90.268 Y113.343 E.02818
G1 X89.765 Y113.337 E.01668
G1 X88.923 Y113.223 E.0282
G1 X88.443 Y113.071 E.0167
G1 X87.671 Y112.718 E.02815
G1 X87.256 Y112.433 E.01671
G1 X86.619 Y111.871 E.02816
G1 X86.305 Y111.478 E.01667
G1 X85.859 Y110.755 E.02817
G3 X85.563 Y109.932 I5.125 J-2.312 E.02906
G1 X85.651 Y109.578 E.01209
G1 X85.867 Y109.377 E.00982
G1 X86.131 Y109.308 E.00905
G2 X93.759 Y109.316 I3.838 J-21.967 E.2543
G1 X94.003 Y109.326 E.00809
G1 X94.126 Y109.373 E.00437
G1 X94.15 Y109.394 E.00106
M204 S250
G1 X93.945 Y109.721 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G3 X94.012 Y109.779 I-.087 J.167 E.00275
G1 X94.037 Y109.947 E.00523
G1 X93.789 Y110.564 E.02043
G1 X93.389 Y111.247 E.02431
G3 X86.201 Y110.562 I-3.389 J-2.504 E.26652
G1 X85.966 Y109.956 E.01999
G1 X85.982 Y109.787 E.00519
G1 X86.129 Y109.7 E.00525
G2 X93.826 Y109.702 I3.855 J-22.157 E.23767
G3 X93.887 Y109.702 I.032 J.186 E.00189
; WIPE_START
M204 S6000
G1 X94.012 Y109.779 E-.05567
G1 X94.037 Y109.947 E-.06472
G1 X93.789 Y110.564 E-.25264
G1 X93.389 Y111.247 E-.3006
G1 X93.241 Y111.419 E-.08638
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.392 Y106.278 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G3 X77.518 Y73.958 I1.613 J-18.532 E1.43087
G3 X88.375 Y69.231 I12.433 J13.725 E.39982
G1 X88.784 Y68.81 E.01945
G1 X89.321 Y68.428 E.02185
G1 X89.51 Y68.347 E.00684
G1 X90.008 Y68.251 E.01681
G1 X90.358 Y68.306 E.01176
G1 X90.881 Y68.545 E.01909
G1 X91.324 Y68.909 E.01903
G1 X91.608 Y69.222 E.014
G3 X91.615 Y106.27 I-1.601 J18.524 E1.83103
G1 X91.32 Y106.595 E.01456
G1 X90.847 Y106.976 E.02016
G1 X90.327 Y107.209 E.01888
G1 X89.845 Y107.236 E.01604
G1 X89.271 Y107.045 E.02006
G1 X88.68 Y106.594 E.02464
G1 X88.432 Y106.323 E.0122
M204 S250
G1 X88.462 Y105.886 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X87.329 Y105.757 E.03504
G3 X77.774 Y74.254 I2.674 J-18.011 E1.26325
G3 X88.575 Y69.604 I12.2 J13.467 E.36795
G1 X88.622 Y69.554 E.00211
G1 X88.669 Y69.504 E.00211
G1 X88.716 Y69.454 E.00211
G1 X88.763 Y69.404 E.00211
G1 X88.81 Y69.354 E.00211
G1 F8646.697
G1 X88.858 Y69.304 E.00211
G1 F7784.451
G1 X88.905 Y69.254 E.00211
G1 F6967.484
G1 X88.952 Y69.204 E.00211
G1 F6195.796
G1 X88.999 Y69.154 E.00211
G1 F5469.316
G1 X89.046 Y69.104 E.00211
G1 F4788.119
G3 X89.119 Y69.047 I.173 J.145 E.00287
G1 F3941.49
G1 X89.207 Y68.985 E.0033
G1 F3063.013
G1 X89.295 Y68.924 E.0033
G1 F2295.093
G1 X89.383 Y68.863 E.0033
G1 F1637.848
G1 X89.471 Y68.801 E.0033
G1 F1091.188
G3 X89.581 Y68.745 I.126 J.111 E.00388
M106 S255
G1 F600
G1 X89.753 Y68.704 E.00545
M106 S188.7
M106 S255
G1 X89.926 Y68.664 E.00545
M106 S188.7
M106 S255
G3 X90.154 Y68.662 I.116 J.305 E.00717
M106 S188.7
M106 S255
G3 X90.309 Y68.711 I-.009 J.297 E.00504
M106 S188.7
M106 S255
G1 X90.429 Y68.762 E.00401
M106 S188.7
G1 F1125.127
G1 X90.549 Y68.813 E.00401
G1 F1650.36
G3 X90.642 Y68.856 I-.027 J.179 E.00318
G1 F1882.14
G1 X90.672 Y68.881 E.00122
G1 F2129.145
G1 X90.703 Y68.906 E.00122
G1 F2391.374
G1 X90.734 Y68.932 E.00122
G1 F2668.828
G1 X90.765 Y68.957 E.00122
G1 F2961.505
G1 X90.796 Y68.982 E.00122
G1 F3269.407
G1 X90.826 Y69.008 E.00122
G1 F3592.534
G1 X90.857 Y69.033 E.00122
G1 F3930.885
G1 X90.888 Y69.058 E.00122
G1 F4284.46
G1 X90.919 Y69.083 E.00122
G1 F4653.26
G1 X90.949 Y69.109 E.00122
G1 F5037.284
G1 X90.98 Y69.134 E.00122
G1 F5436.532
G1 X91.011 Y69.159 E.00122
G1 F5851.005
G1 X91.042 Y69.184 E.00122
G1 F9547.299
G1 X91.42 Y69.601 E.01728
G3 X91.422 Y105.896 I-1.413 J18.148 E1.67012
G1 X91.045 Y106.314 E.01728
G1 F5863.56
G1 X91.016 Y106.338 E.00115
G1 F5474.458
G1 X90.988 Y106.362 E.00115
G1 F5098.714
G1 X90.959 Y106.386 E.00115
G1 F4736.254
G1 X90.93 Y106.41 E.00115
G1 F4387.228
G1 X90.902 Y106.433 E.00115
G1 F4051.558
G1 X90.873 Y106.457 E.00115
G1 F3729.245
G1 X90.845 Y106.481 E.00115
G1 F3420.176
G1 X90.816 Y106.505 E.00115
G1 F3124.583
G1 X90.787 Y106.529 E.00115
G1 F2842.347
G1 X90.759 Y106.553 E.00115
G1 F2573.469
G1 X90.73 Y106.577 E.00115
G1 F2317.896
G1 X90.702 Y106.601 E.00115
G1 F2075.735
G1 X90.668 Y106.627 E.00129
G1 F1818.313
G1 X90.549 Y106.681 E.00402
G1 F1126.82
G1 X90.429 Y106.734 E.00402
M106 S255
G1 F600
G1 X90.31 Y106.788 E.00402
M106 S188.7
M106 S255
G1 X90.222 Y106.828 E.00298
G1 X89.788 Y106.831 E.01331
G1 X89.691 Y106.789 E.00325
M106 S188.7
M106 S255
G1 X89.57 Y106.738 E.00403
M106 S188.7
G1 F1128.021
G1 X89.449 Y106.687 E.00403
G1 F1647.838
G3 X89.358 Y106.644 I.027 J-.177 E.00315
G1 F1879.147
G1 X89.327 Y106.619 E.00122
G1 F2125.642
G1 X89.296 Y106.593 E.00122
G1 F2387.281
G1 X89.266 Y106.568 E.00122
G1 F2664.201
G1 X89.235 Y106.543 E.00122
G1 F2956.255
G1 X89.204 Y106.518 E.00122
G1 F3263.445
G1 X89.173 Y106.492 E.00122
G1 F3585.87
G1 X89.143 Y106.467 E.00122
G1 F3923.48
G1 X89.112 Y106.442 E.00122
G1 F4276.289
G1 X89.081 Y106.417 E.00122
G1 F4644.273
G1 X89.051 Y106.391 E.00122
G1 F5027.442
G1 X89.02 Y106.366 E.00122
G1 F5425.733
G1 X88.989 Y106.341 E.00122
G1 F5839.273
G1 X88.958 Y106.316 E.00122
G1 F9547.299
G1 X88.58 Y105.899 E.01728
G1 X88.522 Y105.893 E.00181
; WIPE_START
M204 S6000
G1 X87.329 Y105.757 E-.4562
G1 X86.541 Y105.626 E-.3038
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4.4 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z4.4
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z4.4 F4000
            G39.3 S1
            G0 Z4.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X84.596 Y108.661 F42000
G1 Z4
G1 E.8 F1800
; Slow Down Start
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.38292
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G1 X84.313 Y108.515 E.00883
G3 X100.151 Y106.743 I5.695 J-20.766 E3.29608
G3 X95.683 Y108.516 I-10.307 J-19.457 E.13347
G1 X95.5 Y108.596 E.00553
; Slow Down End
M204 S10000
G1 X93.91 Y108.955 F42000
; Slow Down Start
G1 F1200;_EXTRUDE_SET_SPEED
M204 S6000
G1 X93.698 Y108.96 E.00588
G3 X86.837 Y109.052 I-3.715 J-21.102 E.19092
G1 X86.095 Y108.958 E.02072
; Slow Down End
; WIPE_START
G1 X86.837 Y109.052 E-.28424
G1 X87.889 Y109.183 E-.40285
G1 X88.08 Y109.197 E-.07291
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X94.157 Y111.173 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.42
G1 F9547.055
M204 S2000
G1 X94.887 Y110.443 E.03174
G1 X95.068 Y109.728
G1 X94.603 Y110.194 E.02025
G1 X94.584 Y109.679
G1 X95.278 Y108.985 E.03017
G1 X94.403 Y109.327
G1 X95.026 Y108.704 E.02708
; WIPE_START
M204 S6000
G1 X94.403 Y109.327 E-.33487
G1 X95.278 Y108.985 E-.35706
G1 X95.152 Y109.112 E-.06807
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X91.693 Y113.637 Z4.4 F42000
G1 Z4
G1 E.8 F1800
G1 F9547.055
M204 S2000
G1 X92.423 Y112.907 E.03174
G1 X91.457 Y113.34
G1 X90.97 Y113.826 E.02114
G1 X90.355 Y113.909
G1 X90.764 Y113.499 E.01779
G1 X90.163 Y113.567
G1 X89.811 Y113.919 E.01529
G1 X89.32 Y113.876
G1 X89.642 Y113.554 E.014
G1 X89.173 Y113.49
G1 X88.869 Y113.794 E.01323
G1 X88.45 Y113.68
G1 X88.732 Y113.399 E.01225
G1 X88.329 Y113.267
G1 X88.058 Y113.539 E.01181
G1 X87.689 Y113.375
G1 X87.959 Y113.105 E.01173
G1 X87.602 Y112.929
G1 X87.341 Y113.189 E.01132
G1 X87.022 Y112.976
G1 X87.28 Y112.717 E.01125
G1 X86.97 Y112.494
G1 X86.72 Y112.744 E.01086
G1 X86.436 Y112.495
G1 X86.688 Y112.242 E.01098
G1 X86.417 Y111.98
G1 X86.169 Y112.228 E.01079
G1 X85.929 Y111.936
G1 X86.183 Y111.681 E.01105
G1 X85.961 Y111.37
G1 X85.706 Y111.625 E.01109
G1 X85.501 Y111.297
G1 X85.765 Y111.032 E.01149
G1 X85.587 Y110.678
G1 X85.316 Y110.948 E.01174
G1 X85.16 Y110.571
G1 X85.438 Y110.293 E.01205
G1 X85.359 Y109.839
M73 P74 R5
G1 X85.03 Y110.168 E.01433
G1 X84.931 Y109.733
G1 X85.594 Y109.071 E.02878
G1 X85.344 Y108.787
G1 X84.844 Y109.287 E.02174
M204 S10000
G1 X94.363 Y109.079 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.147447
G1 F15000
M204 S6000
G1 X94.243 Y109.143 E.00115
G1 X94.102 Y109.126 E.00121
M204 S10000
G1 X94.563 Y108.9 F42000
; LINE_WIDTH: 0.144494
G1 F15000
M204 S6000
G1 X94.296 Y108.856 E.00225
M204 S10000
G1 X95.395 Y108.842 F42000
; LINE_WIDTH: 0.124145
G1 F15000
M204 S6000
G1 X95.296 Y108.9 E.00076
G2 X95.283 Y108.996 I.571 J.126 E.00064
; WIPE_START
G1 X95.296 Y108.9 E-.34783
G1 X95.395 Y108.842 E-.41217
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X94.668 Y110.26 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.167937
G1 F15000
M204 S6000
G1 X94.581 Y110.394 E.00163
; LINE_WIDTH: 0.147066
G1 X94.515 Y110.491 E.001
; LINE_WIDTH: 0.107795
G1 X94.449 Y110.588 E.00062
M204 S10000
G1 X94.182 Y111.472 F42000
; LINE_WIDTH: 0.43572
G1 F9164.981
M204 S6000
G3 X92.722 Y112.932 I-3.998 J-2.537 E.06664
; LINE_WIDTH: 0.42152
G1 F9508.734
G1 X92.575 Y112.907 E.0046
; LINE_WIDTH: 0.388553
G1 F10415.691
G1 X92.428 Y112.882 E.0042
; WIPE_START
G1 X92.575 Y112.907 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X94.691 Y110.931 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.0905276
G1 F15000
M204 S6000
G1 X94.672 Y110.96 E.00013
; LINE_WIDTH: 0.117822
G1 X94.571 Y111.096 E.00104
; LINE_WIDTH: 0.167674
G1 X94.47 Y111.233 E.00173
; LINE_WIDTH: 0.217525
G1 X94.369 Y111.369 E.00242
; LINE_WIDTH: 0.243543
G1 X94.361 Y111.378 E.00018
; LINE_WIDTH: 0.268821
G1 X94.317 Y111.401 E.00093
; LINE_WIDTH: 0.317162
G1 F13127.099
G1 X94.272 Y111.425 E.00113
; LINE_WIDTH: 0.365503
G1 F11159.935
G1 X94.227 Y111.448 E.00133
; LINE_WIDTH: 0.406305
G1 F9906.859
G1 X94.182 Y111.472 E.0015
G1 X94.132 Y111.178 E.00884
; WIPE_START
G1 X94.182 Y111.472 E-.64979
G1 X94.227 Y111.448 E-.11021
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X91.056 Y113.45 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.107043
G1 F15000
M204 S6000
G3 X90.836 Y113.571 I-1.761 J-2.949 E.00131
; WIPE_START
G1 X91.056 Y113.45 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X85.899 Y109.128 Z4.4 F42000
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.155672
G1 F15000
M204 S6000
G1 X85.749 Y109.145 E.00139
G1 X85.619 Y109.076 E.00134
M204 S10000
G1 X85.42 Y109.538 F42000
; LINE_WIDTH: 0.0920173
G1 F15000
M204 S6000
G2 X85.28 Y109.76 I1.276 J.962 E.00105
M204 S10000
G1 X84.997 Y108.868 F42000
; LINE_WIDTH: 0.161663
G1 F15000
M204 S6000
G1 X85.019 Y108.758 E.00108
G1 X84.894 Y108.671 E.00147
M204 S10000
G1 X100.599 Y106.074 F42000
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X99.161 Y106.837 I-8.619 J-14.503 E.05402
G1 X97.765 Y105.441 E.06551
G1 X97.446 Y105.582 E.01157
G1 X94.414 Y108.614 E.14221
G3 X94.022 Y108.597 I-.172 J-.609 E.01326
G2 X93.308 Y108.66 I-.172 J2.14 E.02387
G1 X91.843 Y107.195 E.06871
G3 X90.154 Y108.38 I-2.2 J-1.34 E.07043
G3 X88.157 Y107.195 I.083 J-2.416 E.08036
G1 X86.692 Y108.66 E.06871
G2 X85.745 Y108.649 I-.49 J1.45 E.03193
G1 X85.586 Y108.614 E.00542
G1 X82.554 Y105.582 E.14221
G1 X82.235 Y105.441 E.01157
G1 X80.839 Y106.837 E.06551
G3 X79.401 Y106.074 I7.183 J-15.27 E.05402
; WIPE_START
G1 X80.839 Y106.837 E-.61858
G1 X81.102 Y106.574 E-.14142
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X76.851 Y100.235 Z4.4 F42000
G1 X71.066 Y91.609 Z4.4
G1 Z4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G2 X71.459 Y93.189 I15.918 J-3.125 E.05402
G1 X69.989 Y94.659 E.06897
G3 X69.342 Y92.37 I20.716 J-7.093 E.07895
G1 X72.169 Y95.197 E.13263
G2 X73.895 Y98.429 I21.767 J-9.55 E.12165
G1 X72.566 Y99.758 E.06235
G2 X76.199 Y103.801 I19.394 J-13.774 E.1807
G1 X77.51 Y102.49 E.06149
G2 X78.795 Y103.488 I12.816 J-15.173 E.054
; WIPE_START
G1 X77.51 Y102.49 E-.61845
G1 X77.247 Y102.753 E-.14155
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X73.129 Y96.327 Z4.4 F42000
G1 X68.923 Y89.763 Z4.4
G1 Z4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X68.835 Y88.137 I16.53 J-1.705 E.05402
G1 X70.74 Y86.232 E.08937
G1 X70.75 Y86.102 E.00433
G1 X69.09 Y84.442 E.07786
G3 X69.406 Y82.845 I16.077 J2.351 E.05402
; WIPE_START
G1 X69.09 Y84.442 E-.61857
G1 X69.353 Y84.705 E-.14144
; WIPE_END
G1 E-.03999 F1800
M204 S10000
G1 X74.897 Y79.459 Z4.4 F42000
G1 X86.141 Y68.816 Z4.4
G1 Z4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G2 X84.561 Y69.209 I11.818 J50.901 E.054
G1 X83.091 Y67.739 E.06897
G2 X80.425 Y68.872 I12.671 J33.54 E.09612
G1 X71.122 Y78.175 E.43642
G1 X70.913 Y78.589 E.01539
G1 X72.309 Y79.985 E.06551
G3 X75.26 Y75.26 I17.745 J7.797 E.18544
G1 X73.949 Y73.949 E.06149
G3 X77.992 Y70.316 I17.815 J15.759 E.1807
G1 X79.321 Y71.645 E.06235
G3 X80.716 Y70.805 I9.21 J13.705 E.05402
; WIPE_START
G1 X79.321 Y71.645 E-.61858
G1 X79.058 Y71.382 E-.14142
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X86.413 Y69.342 Z4.4 F42000
G1 X90.99 Y68.072 Z4.4
G1 Z4
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.59802
G1 F6485.318
M204 S6000
G1 X91.4 Y68.419 E.0243
; LINE_WIDTH: 0.48924
G1 F8065.962
G1 X91.76 Y68.83 E.01985
; LINE_WIDTH: 0.384176
G1 F10549.281
G1 X91.881 Y68.886 E.00371
G1 X92.128 Y68.915 E.00693
; Slow Down Start
; LINE_WIDTH: 0.38292
G1 F1200;_EXTRUDE_SET_SPEED
G3 X92.804 Y106.504 I-2.129 J18.839 E1.51306
G1 X92.121 Y106.579 E.01903
; Slow Down End
; LINE_WIDTH: 0.384234
G1 F10547.47
G1 X91.889 Y106.604 E.00651
G1 X91.767 Y106.661 E.00373
G1 X91.388 Y107.089 E.01591
; LINE_WIDTH: 0.49646
G1 F7937.558
G1 X91.022 Y107.404 E.01784
M204 S10000
G1 X89.01 Y107.428 F42000
; LINE_WIDTH: 0.59806
G1 F6484.851
M204 S6000
G1 X88.6 Y107.081 E.02432
; LINE_WIDTH: 0.4892
G1 F8066.685
G1 X88.24 Y106.67 E.01983
; LINE_WIDTH: 0.38412
G1 F10550.997
G1 X88.119 Y106.614 E.00371
G1 X87.85 Y106.582 E.00755
; Slow Down Start
; LINE_WIDTH: 0.38292
G1 F1200;_EXTRUDE_SET_SPEED
G3 X87.195 Y68.996 I2.151 J-18.836 E1.51243
G1 X87.828 Y68.925 E.01763
; Slow Down End
; LINE_WIDTH: 0.38367
G1 F10564.928
G1 X88.11 Y68.893 E.00789
G1 X88.225 Y68.843 E.00349
G1 X88.631 Y68.398 E.01674
; LINE_WIDTH: 0.45516
G1 F8732.776
G1 X89.048 Y68.034 E.01859
M204 S10000
G1 X90.99 Y68.072 F42000
; LINE_WIDTH: 0.574526
G1 F6771.933
M204 S6000
G1 X90.939 Y68.003 E.00372
; LINE_WIDTH: 0.527538
G1 F7428.532
G1 X90.887 Y67.934 E.00339
; LINE_WIDTH: 0.48055
G1 F8226.127
G1 X90.836 Y67.865 E.00307
; LINE_WIDTH: 0.433562
G1 F9215.599
G1 X90.784 Y67.797 E.00274
; LINE_WIDTH: 0.382783
G1 F10592.5
G1 X90.733 Y67.728 E.00238
G1 X90.443 Y67.578 E.00904
; LINE_WIDTH: 0.409146
G1 F9830.007
G1 X89.991 Y67.491 E.01372
G1 X89.601 Y67.564 E.01185
G1 X89.403 Y67.65 E.00643
; LINE_WIDTH: 0.433937
G1 F9206.779
G1 X89.327 Y67.737 E.0037
; LINE_WIDTH: 0.482589
G1 F8187.982
G1 X89.25 Y67.825 E.00416
; LINE_WIDTH: 0.531242
G1 F7372.196
G1 X89.174 Y67.913 E.00462
; LINE_WIDTH: 0.579894
G1 F6704.239
G1 X89.098 Y68.001 E.00509
G1 X89.25 Y67.979 E.0067
; LINE_WIDTH: 0.531242
G1 F7372.196
G1 X89.401 Y67.958 E.00609
; LINE_WIDTH: 0.482589
G1 F8187.982
G1 X89.553 Y67.936 E.00549
; LINE_WIDTH: 0.419077
G1 F9570.472
G2 X90.002 Y67.865 I-1.216 J-9.105 E.01394
; LINE_WIDTH: 0.390665
G1 F10352.414
G1 X90.503 Y67.97 E.01451
; LINE_WIDTH: 0.390885
G1 F10345.869
G1 X90.589 Y67.988 E.00248
; LINE_WIDTH: 0.436915
G1 F9137.172
G1 X90.674 Y68.006 E.00281
; LINE_WIDTH: 0.482945
G1 F8181.353
G1 X90.76 Y68.024 E.00314
; LINE_WIDTH: 0.528975
G1 F7406.569
G1 X90.846 Y68.042 E.00347
; LINE_WIDTH: 0.575005
G1 F6765.836
G1 X90.932 Y68.059 E.0038
; WIPE_START
G1 X90.846 Y68.042 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.49 Y75.666 Z4.4 F42000
G1 X89.01 Y107.428 Z4.4
G1 Z4
G1 E.8 F1800
; LINE_WIDTH: 0.574575
G1 F6771.309
M204 S6000
G1 X89.061 Y107.497 E.00372
; LINE_WIDTH: 0.527605
G1 F7427.504
G1 X89.113 Y107.566 E.00339
; LINE_WIDTH: 0.480635
G1 F8224.53
G1 X89.164 Y107.635 E.00307
; LINE_WIDTH: 0.433665
G1 F9213.17
G1 X89.216 Y107.704 E.00274
; LINE_WIDTH: 0.390545
G1 F10356.007
G1 X89.267 Y107.772 E.00243
G2 X89.86 Y107.99 I.715 J-1.032 E.01809
; LINE_WIDTH: 0.404409
G1 F9958.829
M73 P75 R5
G1 X90.16 Y107.982 E.00884
G1 X90.576 Y107.86 E.01277
; LINE_WIDTH: 0.37037
G1 F10994.046
G1 X90.716 Y107.782 E.00428
; LINE_WIDTH: 0.388061
G1 F10430.52
G1 X90.768 Y107.714 E.0024
; LINE_WIDTH: 0.434403
G1 F9195.801
G1 X90.82 Y107.646 E.00273
; LINE_WIDTH: 0.480745
G1 F8222.463
G1 X90.873 Y107.579 E.00305
; LINE_WIDTH: 0.527087
G1 F7435.452
G1 X90.925 Y107.511 E.00337
; LINE_WIDTH: 0.573429
G1 F6785.936
G1 X90.977 Y107.444 E.00369
; LINE_WIDTH: 0.574426
G1 F6773.207
G1 X90.868 Y107.467 E.00481
; LINE_WIDTH: 0.530078
G1 F7389.8
G1 X90.76 Y107.49 E.00441
; LINE_WIDTH: 0.48573
G1 F8129.898
G1 X90.651 Y107.514 E.00401
; LINE_WIDTH: 0.441382
G1 F9034.738
G1 X90.543 Y107.537 E.00361
; LINE_WIDTH: 0.393298
G1 F10274.631
G1 X89.851 Y107.623 E.0199
; LINE_WIDTH: 0.38917
G1 F10397.113
G1 X89.497 Y107.53 E.01033
; LINE_WIDTH: 0.391024
G1 F10341.738
G1 X89.411 Y107.512 E.00248
; LINE_WIDTH: 0.437032
G1 F9134.46
G1 X89.326 Y107.494 E.00281
; LINE_WIDTH: 0.48304
G1 F8179.588
G1 X89.24 Y107.476 E.00314
; LINE_WIDTH: 0.529048
G1 F7405.457
G1 X89.154 Y107.458 E.00347
; LINE_WIDTH: 0.575056
G1 F6765.188
G1 X89.068 Y107.441 E.0038
; WIPE_START
G1 X89.154 Y107.458 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.403 Y105.071 Z4.4 F42000
G1 X101.205 Y103.489 Z4.4
G1 Z4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G2 X102.49 Y102.49 I-11.766 J-16.464 E.054
G1 X103.801 Y103.801 E.06148
G2 X107.434 Y99.758 I-15.76 J-17.816 E.1807
G1 X106.105 Y98.429 E.06235
G2 X107.832 Y95.196 I-21.693 J-13.669 E.12169
G1 X110.658 Y92.37 E.13257
G3 X110.011 Y94.659 I-21.361 J-4.803 E.07895
G1 X108.541 Y93.189 E.06897
G2 X108.934 Y91.609 I-15.51 J-4.701 E.05402
M204 S10000
G1 X110.594 Y82.845 F42000
G1 F8843.478
M204 S6000
G3 X110.91 Y84.442 I-15.763 J3.948 E.05402
G1 X109.25 Y86.102 E.07786
G1 X109.26 Y86.232 E.00433
G1 X111.165 Y88.137 E.08937
G3 X111.077 Y89.763 I-16.615 J-.08 E.05402
; WIPE_START
G1 X111.165 Y88.137 E-.61859
G1 X110.902 Y87.874 E-.14141
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X106.607 Y81.564 Z4.4 F42000
G1 X99.284 Y70.805 Z4.4
G1 Z4
G1 E.8 F1800
G1 F8843.478
M204 S6000
G3 X100.679 Y71.645 I-7.812 J14.539 E.05402
G1 X102.008 Y70.316 E.06235
G3 X106.051 Y73.949 I-13.772 J19.392 E.1807
G1 X104.74 Y75.26 E.06149
G3 X107.691 Y79.985 I-14.796 J12.523 E.18544
G1 X109.087 Y78.589 E.06551
G1 X108.878 Y78.175 E.01539
G1 X99.575 Y68.872 E.43642
G2 X96.909 Y67.739 I-15.333 J32.397 E.09613
G1 X95.439 Y69.209 E.06897
G1 X94.989 Y69.084 E.0155
G2 X93.859 Y68.816 I-5.844 J22.132 E.03851
M204 S10000
G1 X92.013 Y66.673 F42000
G1 F8843.478
M204 S6000
G2 X90.387 Y66.585 I-1.706 J16.533 E.05402
G1 X89.854 Y67.118 E.025
G3 X90.142 Y67.115 I.152 J.641 E.00964
G1 X89.614 Y66.586 E.02481
G2 X87.988 Y66.673 I.053 J16.252 E.05402
; WIPE_START
G1 X89.614 Y66.586 E-.61857
G1 X89.877 Y66.849 E-.14143
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.899 Y74.481 Z4.4 F42000
G1 X89.987 Y105.477 Z4.4
G1 Z4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X89.925 Y105.476 E.00206
G1 X89.559 Y105.244 E.01435
G1 X89.175 Y104.836 E.01858
G1 X89.176 Y104.166 E.02225
G1 X89.104 Y103.886 E.00958
G1 X88.896 Y103.669 E.00997
G1 X88.67 Y103.589 E.00796
G3 X88.637 Y71.914 I1.337 J-15.839 E1.56654
G1 X88.896 Y71.831 E.00902
G1 X89.104 Y71.614 E.00997
G1 X89.176 Y71.334 E.00958
G1 X89.175 Y70.677 E.02181
G1 X89.628 Y70.206 E.02168
G1 X89.961 Y70.004 E.01292
G1 X90.118 Y70.033 E.00528
G1 X90.414 Y70.237 E.01194
G1 X90.825 Y70.668 E.01975
G1 X90.824 Y71.334 E.0221
G1 X90.896 Y71.614 E.00958
G1 X91.104 Y71.831 E.00997
G1 X91.33 Y71.911 E.00796
G3 X105.888 Y88.142 I-1.347 J15.853 E.79679
G3 X91.363 Y103.586 I-15.905 J-.406 E.76971
G1 X91.104 Y103.669 E.00902
G1 X90.896 Y103.886 E.00997
G1 X90.824 Y104.166 E.00958
G1 X90.825 Y104.827 E.02195
G1 X90.441 Y105.233 E.01852
G1 X90.086 Y105.479 E.01432
G1 X90.047 Y105.478 E.00132
M204 S250
G1 X89.945 Y105.892 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.67 Y105.808 E.00884
G3 X88.783 Y104.976 I2.869 J-3.949 E.03747
G1 X88.784 Y104.165 E.0249
G1 X88.722 Y104.026 E.00469
G1 X88.621 Y103.978 E.00342
G3 X88.609 Y71.523 I1.386 J-16.228 E1.48654
G1 X88.722 Y71.474 E.00379
G1 X88.784 Y71.335 E.00469
G1 X88.783 Y70.529 E.02477
G3 X89.535 Y69.772 I3.365 J2.594 E.03286
G1 X89.916 Y69.614 E.01267
G1 X90.269 Y69.665 E.01098
G3 X91.217 Y70.526 I-1.981 J3.132 E.03955
G1 X91.216 Y71.335 E.02485
G1 X91.278 Y71.474 E.00469
G1 X91.379 Y71.522 E.00342
G3 X106.28 Y88.151 I-1.396 J16.242 E.75578
G3 X91.391 Y103.977 I-16.297 J-.416 E.73073
G1 X91.278 Y104.026 E.00379
G1 X91.216 Y104.165 E.00469
G1 X91.217 Y104.973 E.02481
G3 X90.611 Y105.608 I-3.41 J-2.646 E.02703
G1 X90.211 Y105.858 E.01449
G1 X90.004 Y105.885 E.00641
; WIPE_START
M204 S6000
G1 X89.67 Y105.808 E-.13037
G1 X89.482 Y105.672 E-.08802
G1 X89.125 Y105.355 E-.18163
G1 X88.783 Y104.976 E-.19405
G1 X88.783 Y104.539 E-.16593
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X91.815 Y97.534 Z4.4 F42000
G1 X100.705 Y76.997 Z4.4
G1 Z4
G1 E.8 F1800
; FEATURE: Sparse infill
; LINE_WIDTH: 0.45
G1 F8843.478
M204 S6000
G3 X101.794 Y78.206 I-48.732 J44.995 E.05399
G1 X80.456 Y99.544 E1.00102
G3 X76.908 Y95.416 I9.64 J-11.876 E.18153
G1 X97.666 Y74.658 E.97384
G1 X103.068 Y80.04 E.25293
G3 X104.474 Y83.202 I-13.404 J7.856 E.11504
G1 X85.452 Y102.224 E.89237
G2 X87.331 Y102.683 I7.747 J-27.63 E.06419
G1 X75.067 Y90.419 E.57536
G3 X74.955 Y89.693 I7.569 J-1.537 E.02436
G1 X91.941 Y72.708 E.79682
G3 X90.511 Y72.29 I-.125 J-2.227 E.05037
G3 X90.103 Y70.954 I1.238 J-1.109 E.04781
G1 X89.994 Y70.843 E.00516
G2 X89.898 Y70.951 I.306 J.37 E.00481
G3 X88.514 Y72.648 I-1.395 J.276 E.08293
G1 X88.057 Y72.705 E.01527
G1 X105.045 Y89.693 E.79694
G3 X104.933 Y90.419 I-7.679 J-.811 E.02436
G1 X92.669 Y102.683 E.57536
G2 X94.548 Y102.224 I-5.86 J-28.06 E.06419
G1 X75.526 Y83.202 E.89237
G3 X76.932 Y80.04 I14.81 J4.693 E.11504
G1 X82.334 Y74.658 E.25293
G1 X103.092 Y95.416 E.97384
G3 X99.544 Y99.544 I-13.189 J-7.748 E.18153
G1 X78.206 Y78.206 E1.00102
G3 X79.295 Y76.997 I49.825 J43.791 E.05399
; WIPE_START
G1 X78.206 Y78.206 E-.61844
G1 X78.469 Y78.469 E-.14156
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X84.868 Y74.309 Z4.4 F42000
G1 X90.342 Y70.751 Z4.4
G1 Z4
G1 E.8 F1800
; FEATURE: Floating vertical shell
; LINE_WIDTH: 0.38292
G1 F10588.235
M204 S6000
G1 X90.38 Y70.871 E.00349
G1 X90.382 Y71.376 E.01401
G1 X90.525 Y71.812 E.01271
G1 X90.824 Y72.097 E.01143
; Slow Down Start
G1 F1200;_EXTRUDE_SET_SPEED
G1 X91.246 Y72.264 E.01258
G3 X92.28 Y103.117 I-1.252 J15.486 E1.25405
G1 X91.244 Y103.248 E.02892
G2 X90.888 Y103.398 I.097 J.727 E.01083
; Slow Down End
G1 F10588.235
G1 X90.666 Y103.523 E.00706
G1 X90.494 Y103.75 E.00789
G1 X90.379 Y104.191 E.01264
G1 X90.366 Y104.698 E.01404
G3 X90.148 Y105.005 I-.445 J-.086 E.01076
G1 X89.962 Y104.972 E.00523
G1 X89.621 Y104.644 E.01312
G1 X89.614 Y104.137 E.01406
G1 X89.478 Y103.691 E.0129
G1 X89.176 Y103.403 E.01157
; Slow Down Start
G1 F1200;_EXTRUDE_SET_SPEED
G1 X88.754 Y103.236 E.01258
G3 X87.72 Y72.383 I1.252 J-15.486 E1.25405
G1 X88.756 Y72.252 E.02892
G2 X89.112 Y72.102 I-.097 J-.727 E.01083
; Slow Down End
G1 F10588.235
G1 X89.334 Y71.977 E.00706
G1 X89.506 Y71.753 E.00783
G1 X89.618 Y71.376 E.01088
G1 X89.62 Y70.873 E.01394
G1 X89.713 Y70.658 E.00648
; CHANGE_LAYER
; Z_HEIGHT: 4.2
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F10588.235
G1 X89.62 Y70.873 E-.10662
G1 X89.618 Y71.376 E-.22945
G1 X89.506 Y71.753 E-.17903
G1 X89.334 Y71.977 E-.12876
G1 X89.112 Y72.102 E-.11614
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 21/25
; update layer progress
M73 L21
M991 S0 P20 ;notify layer change
M106 S153
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z4.4 I-1.207 J.152 P1  F42000
G1 X93.786 Y109.311 Z4.4
G1 Z4.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X93.213 Y109.412 E.0193
G3 X111.494 Y83.573 I-3.21 J-21.657 E3.38965
G3 X111.897 Y87.79 I-21.758 J4.207 E.14074
G3 X94.273 Y109.228 I-21.894 J-.036 E.99704
G1 X93.845 Y109.301 E.0144
M204 S250
G1 X93.853 Y109.698 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X93.27 Y109.799 E.01817
G3 X111.88 Y83.507 I-3.267 J-22.045 E3.19632
G3 X112.289 Y87.8 I-22.137 J4.273 E.13272
G3 X94.349 Y109.612 I-22.286 J-.046 E.93982
G1 X93.912 Y109.688 E.01364
; WIPE_START
M204 S6000
G1 X93.27 Y109.799 E-.24749
G1 X92.185 Y109.933 E-.41559
G1 X91.93 Y109.952 E-.09692
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.408 Y106.279 Z4.6 F42000
G1 Z4.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X88.191 Y106.259 E.0072
G3 X77.518 Y101.543 I1.793 J-18.493 E.39372
G3 X88.712 Y69.198 I12.481 J-13.79 E1.44165
G1 X89.053 Y68.926 E.01447
G1 X89.56 Y68.684 E.01863
G1 X90.01 Y68.614 E.01512
G1 X90.519 Y68.706 E.01714
G1 X91 Y68.958 E.01801
G1 X91.288 Y69.198 E.01245
G3 X91.288 Y106.302 I-1.283 J18.552 E1.85274
G1 X90.947 Y106.574 E.01448
G1 X90.44 Y106.816 E.01863
G1 X89.986 Y106.886 E.01524
G1 X89.481 Y106.794 E.01702
G1 X89 Y106.542 E.01802
G1 X88.712 Y106.302 E.01244
G1 X88.467 Y106.284 E.00813
M204 S250
G1 X88.436 Y105.89 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X88.215 Y105.873 E.00681
G3 X77.774 Y101.246 I1.83 J-18.224 E.35685
G3 X88.54 Y69.604 I12.225 J-13.493 E1.30085
G1 X88.869 Y69.58 E.01011
G1 F6143.093
G1 X88.899 Y69.554 E.00122
G1 F5718.746
G1 X88.93 Y69.529 E.00122
G1 F5309.507
G1 X88.96 Y69.503 E.00122
M73 P76 R5
G1 F4915.535
G1 X88.991 Y69.478 E.00122
G1 F4536.676
G1 X89.021 Y69.452 E.00122
G1 F4173.077
G1 X89.052 Y69.427 E.00122
G1 F3824.598
G1 X89.082 Y69.401 E.00122
G1 F3491.373
G1 X89.113 Y69.376 E.00122
G1 F3173.273
G1 X89.143 Y69.35 E.00122
G1 F2870.422
G1 X89.174 Y69.325 E.00122
G1 F2582.703
G1 X89.204 Y69.299 E.00122
G1 F2310.225
G1 X89.235 Y69.274 E.00122
G1 F2052.885
G1 X89.366 Y69.207 E.00452
G1 F1233.785
G1 X89.503 Y69.138 E.00471
M106 S255
G1 F600
G1 X89.64 Y69.068 E.00471
M106 S153
M106 S255
G1 X89.892 Y69.03 E.00784
M106 S153
M106 S255
G3 X90.136 Y69.031 I.121 J.336 E.00766
M106 S153
M106 S255
G1 X90.334 Y69.071 E.00619
M106 S153
M106 S255
G3 X90.496 Y69.132 I-.018 J.294 E.00541
M106 S153
G1 F1254.031
G1 X90.635 Y69.207 E.00484
G1 F2146.386
G1 X90.773 Y69.282 E.00484
G1 F2510.33
G3 X90.818 Y69.313 I-.051 J.122 E.00169
G1 F2747.556
G1 X90.843 Y69.335 E.00103
G1 F2995.442
G1 X90.869 Y69.356 E.00103
G1 F3254.031
G1 X90.894 Y69.378 E.00103
G1 F3523.326
G1 X90.92 Y69.4 E.00103
G1 F3803.325
G1 X90.945 Y69.421 E.00103
G1 F4093.961
G1 X90.971 Y69.443 E.00103
G1 F4395.426
G1 X90.996 Y69.464 E.00103
G1 F4707.538
G1 X91.021 Y69.486 E.00103
G1 F5030.354
G1 X91.047 Y69.508 E.00103
G1 F5363.875
G1 X91.072 Y69.529 E.00103
G1 F5708.1
G1 X91.098 Y69.551 E.00103
M73 P76 R4
G1 F6063.018
G1 X91.123 Y69.573 E.00103
G1 F9547.299
G1 X91.522 Y69.606 E.01229
G1 X91.785 Y69.626 E.00811
G3 X91.789 Y105.867 I-1.79 J18.121 E1.64744
G1 X91.53 Y105.891 E.00797
G1 X91.132 Y105.92 E.01229
G1 F6145.476
G1 X91.122 Y105.929 E.0004
G1 F6005.23
G1 X91.094 Y105.951 E.0011
G1 F5627.151
G1 X91.067 Y105.974 E.0011
G1 F5261.505
G1 X91.039 Y105.997 E.0011
G1 F4908.066
G1 X91.012 Y106.02 E.0011
G1 F4566.987
G1 X90.984 Y106.043 E.0011
G1 F4238.132
G1 X90.957 Y106.066 E.0011
G1 F3921.552
G1 X90.929 Y106.089 E.0011
G1 F3617.323
G1 X90.902 Y106.112 E.0011
G1 F3325.316
G1 X90.874 Y106.135 E.0011
G1 F3045.605
G1 X90.847 Y106.158 E.0011
G1 F2778.227
G1 X90.82 Y106.181 E.0011
G1 F2523.078
G1 X90.792 Y106.204 E.0011
G1 F2280.267
G1 X90.765 Y106.227 E.0011
G1 F2049.65
G1 X90.634 Y106.293 E.00451
G1 F1232.783
G1 X90.497 Y106.362 E.00471
M106 S255
G1 F600
G1 X90.36 Y106.431 E.00471
M106 S153
M106 S255
G1 X90.105 Y106.47 E.00792
M106 S153
M106 S255
G3 X89.861 Y106.469 I-.121 J-.336 E.00767
M106 S153
M106 S255
G1 X89.666 Y106.429 E.00613
M106 S153
M106 S255
G3 X89.504 Y106.368 I.019 J-.295 E.00539
M106 S153
G1 F1254.278
G1 X89.365 Y106.293 E.00484
G1 F2147.087
G1 X89.227 Y106.218 E.00484
G1 F2512.552
G3 X89.182 Y106.187 I.051 J-.123 E.00169
G1 F2750.14
G1 X89.156 Y106.165 E.00103
G1 F2998.403
G1 X89.131 Y106.143 E.00103
G1 F3257.452
G1 X89.105 Y106.122 E.00103
G1 F3527.287
G1 X89.08 Y106.1 E.00103
G1 F3807.802
G1 X89.054 Y106.078 E.00103
G1 F4099.048
G1 X89.029 Y106.057 E.00103
G1 F4400.956
G1 X89.004 Y106.035 E.00103
G1 F4713.663
G1 X88.978 Y106.014 E.00103
G1 F5037.102
G1 X88.953 Y105.992 E.00103
G1 F5371.273
G1 X88.927 Y105.97 E.00103
G1 F5716.242
G1 X88.902 Y105.949 E.00103
G1 F6071.878
G1 X88.876 Y105.927 E.00103
G1 F9547.299
G1 X88.496 Y105.895 E.01172
; WIPE_START
M204 S6000
G1 X88.215 Y105.873 E-.10708
G1 X87.333 Y105.763 E-.33794
G1 X86.516 Y105.622 E-.31498
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4.6 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z4.6
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z4.6 F4000
            G39.3 S1
            G0 Z4.6 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X89.798 Y107.261 F42000
G1 Z4.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.46245
G1 F8581.031
M204 S6000
G1 X90.067 Y107.281 E.0092
; WIPE_START
G1 X89.798 Y107.261 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X82.64 Y104.613 Z4.6 F42000
G1 X72.745 Y100.953 Z4.6
G1 Z4.2
G1 E.8 F1800
; FEATURE: Bridge
; LINE_WIDTH: 0.40323
; LAYER_HEIGHT: 0.4
M106 S255
G1 F1200
M204 S6000
G1 X74.829 Y103.025 E.15288
G2 X78.248 Y105.784 I15.538 J-15.755 E.22899
G1 X72.031 Y99.605 E.45609
G3 X71.082 Y98.023 I15.477 J-10.354 E.09599
G1 X79.851 Y106.738 E.64324
G2 X81.114 Y107.355 I7.363 J-13.471 E.07312
G1 X70.447 Y96.752 E.78253
G3 X69.976 Y95.645 I11.295 J-5.455 E.06259
G1 X82.225 Y107.82 E.89859
G1 X82.642 Y107.981 E.02324
G2 X83.232 Y108.182 I2.294 J-5.781 E.03244
G1 X69.608 Y94.641 E.99941
G3 X69.317 Y93.712 I9.487 J-3.485 E.05064
G1 X84.161 Y108.467 E1.08897
G1 X84.654 Y108.604 E.02661
G2 X85.034 Y108.695 I1.111 J-3.784 E.0203
G1 X80.442 Y104.131 E.33686
G2 X81.822 Y104.864 I7.972 J-13.344 E.08138
G1 X85.86 Y108.877 E.29621
G1 X86.638 Y109.012 E.04108
G1 X82.968 Y105.363 E.26928
G2 X83.983 Y105.734 I4.295 J-10.192 E.05629
G1 X87.384 Y109.114 E.24948
G2 X88.106 Y109.193 I1.148 J-7.179 E.03781
G1 X84.913 Y106.019 E.23424
G2 X85.776 Y106.237 I2.571 J-8.343 E.04631
G1 X88.801 Y109.244 E.22189
G2 X89.467 Y109.267 I.618 J-8.125 E.0347
G1 X86.587 Y106.405 E.21126
G1 X86.686 Y106.422 E.00523
G2 X87.358 Y106.532 I1.467 J-6.871 E.03541
G1 X90.12 Y109.277 E.20265
G1 X90.748 Y109.262 E.03266
G1 X88.091 Y106.622 E.19487
G2 X88.567 Y106.659 I1.767 J-19.238 E.02481
G1 X88.779 Y106.941 E.01833
G1 X89.241 Y107.421 E.03471
G2 X89.832 Y107.713 I.956 J-1.194 E.03455
G1 X91.36 Y109.232 E.11212
G1 X91.959 Y109.188 E.03123
G1 X90.402 Y107.641 E.11419
G2 X90.791 Y107.388 I-.537 J-1.251 E.02424
G1 X92.537 Y109.124 E.12811
G1 X93.109 Y109.053 E.02997
G1 X91.105 Y107.061 E.147
G2 X91.39 Y106.706 I-1.113 J-1.186 E.02379
G1 X93.659 Y108.96 E.1664
G2 X94.206 Y108.866 I-.68 J-5.56 E.02893
G1 X91.944 Y106.617 E.16594
G1 X92.516 Y106.547 E.02999
G1 X94.731 Y108.748 E.16243
G2 X95.254 Y108.629 I-.947 J-5.382 E.02794
G1 X93.075 Y106.463 E.15986
G1 X93.623 Y106.369 E.02893
G1 X95.757 Y108.49 E.15654
G2 X96.259 Y108.35 I-1.223 J-5.369 E.02714
G1 X94.15 Y106.254 E.15469
G2 X94.673 Y106.134 I-.917 J-5.191 E.02789
G1 X96.742 Y108.191 E.1518
G1 X97.224 Y108.031 E.02645
G1 X95.175 Y105.995 E.15033
G2 X95.671 Y105.848 I-1.238 J-5.107 E.0269
G1 X97.689 Y107.854 E.14801
G1 X98.152 Y107.675 E.02582
G1 X96.153 Y105.689 E.14659
G2 X96.626 Y105.52 I-1.488 J-4.925 E.02615
G1 X98.6 Y107.481 E.14476
G1 X99.045 Y107.285 E.02531
G1 X97.089 Y105.341 E.14343
G2 X97.541 Y105.151 I-1.744 J-4.769 E.0255
G1 X99.478 Y107.076 E.14209
G1 X99.904 Y106.861 E.02486
G1 X97.986 Y104.954 E.14075
G2 X98.417 Y104.744 I-1.942 J-4.531 E.02498
G1 X100.324 Y106.639 E.13987
G1 X100.733 Y106.407 E.02449
G1 X98.844 Y104.529 E.13859
G2 X99.258 Y104.301 I-2.059 J-4.221 E.02458
G1 X101.14 Y106.172 E.13808
G1 X101.533 Y105.923 E.02418
G1 X99.667 Y104.069 E.13686
G2 X100.063 Y103.824 I-2.287 J-4.133 E.02425
G1 X101.925 Y105.675 E.13661
G2 X102.303 Y105.411 I-2.51 J-4.001 E.02398
G1 X100.456 Y103.575 E.13552
G2 X100.836 Y103.313 I-2.577 J-4.156 E.02401
G1 X102.679 Y105.146 E.13525
G2 X103.046 Y104.871 I-2.642 J-3.907 E.02384
G1 X101.212 Y103.049 E.1345
G2 X101.576 Y102.771 I-2.572 J-3.739 E.02381
G1 X103.406 Y104.59 E.13428
G2 X103.762 Y104.305 I-2.663 J-3.676 E.02374
G1 X101.936 Y102.49 E.13393
G2 X102.285 Y102.197 I-2.817 J-3.711 E.02369
G1 X104.106 Y104.008 E.13359
M73 P77 R4
G1 X104.45 Y103.71 E.02365
G1 X102.629 Y101.901 E.13357
G2 X102.962 Y101.592 I-2.965 J-3.536 E.02361
G1 X104.779 Y103.398 E.13328
G1 X105.107 Y103.086 E.02359
G1 X103.29 Y101.28 E.13328
G2 X103.609 Y100.958 I-3.07 J-3.362 E.02359
G1 X105.425 Y102.763 E.13322
G1 X105.738 Y102.435 E.02359
G1 X103.922 Y100.63 E.13322
G2 X104.225 Y100.292 I-3.319 J-3.29 E.02362
G1 X106.045 Y102.101 E.13353
G1 X106.342 Y101.757 E.02364
G1 X104.522 Y99.948 E.13354
G2 X104.811 Y99.596 I-3.501 J-3.163 E.0237
G1 X106.639 Y101.414 E.13416
G2 X106.92 Y101.054 I-3.507 J-3.027 E.02376
G1 X105.092 Y99.236 E.13414
G2 X105.365 Y98.869 I-3.472 J-2.863 E.02384
G1 X107.201 Y100.694 E.13471
G2 X107.471 Y100.323 I-3.675 J-2.96 E.02387
G1 X105.629 Y98.492 E.13512
G2 X105.886 Y98.109 I-3.909 J-2.899 E.02403
G1 X107.736 Y99.947 E.13568
G2 X107.994 Y99.565 I-3.771 J-2.833 E.02401
G1 X106.135 Y97.717 E.13642
G2 X106.376 Y97.317 I-3.92 J-2.636 E.02429
G1 X108.243 Y99.173 E.13697
G1 X108.317 Y99.056 E.00722
G2 X108.489 Y98.779 I-2.711 J-1.884 E.01697
G1 X106.607 Y96.909 E.13807
G2 X106.831 Y96.492 I-4.094 J-2.464 E.02462
G1 X108.721 Y98.37 E.13865
G1 X108.952 Y97.961 E.02445
G1 X107.045 Y96.066 E.13991
G2 X107.25 Y95.631 I-4.313 J-2.299 E.02504
G1 X109.17 Y97.538 E.1408
G1 X109.384 Y97.113 E.02481
G1 X107.447 Y95.187 E.14212
G2 X107.632 Y94.732 I-4.568 J-2.13 E.02556
G1 X109.587 Y96.675 E.14341
G1 X109.784 Y96.232 E.02525
G1 X107.811 Y94.271 E.14474
G2 X107.975 Y93.795 I-10.039 J-3.734 E.02619
G1 X109.972 Y95.78 E.1465
G1 X110.15 Y95.318 E.02575
G1 X108.134 Y93.314 E.14793
G2 X108.275 Y92.815 I-5.069 J-1.705 E.02697
G1 X110.322 Y94.85 E.15019
G1 X110.481 Y94.369 E.02637
G1 X108.412 Y92.312 E.15179
G1 X108.529 Y91.789 E.02787
G1 X110.635 Y93.883 E.15451
G1 X110.774 Y93.382 E.02705
G1 X108.638 Y91.259 E.1567
G1 X108.733 Y90.714 E.02878
G1 X110.909 Y92.877 E.15964
G1 X111.026 Y92.354 E.02786
G1 X108.811 Y90.152 E.16251
G1 X108.823 Y90.053 E.00523
G2 X108.88 Y89.582 I-4.781 J-.814 E.02468
G1 X111.138 Y91.827 E.16568
G1 X111.232 Y91.281 E.0288
G1 X108.924 Y88.987 E.16937
G2 X108.954 Y88.377 I-6.224 J-.613 E.03174
G1 X111.319 Y90.728 E.17352
G1 X111.39 Y90.16 E.02982
G1 X108.969 Y87.754 E.17756
G2 X108.953 Y87.099 I-6.788 J-.161 E.03411
G1 X111.448 Y89.578 E.18299
G1 X111.491 Y88.983 E.03107
G1 X108.917 Y86.424 E.18885
G2 X108.857 Y85.725 I-7.171 J.261 E.03648
G1 X111.515 Y88.367 E.19497
G2 X111.53 Y87.743 I-6.264 J-.462 E.0325
G1 X108.768 Y84.997 E.20264
G2 X108.636 Y84.227 I-7.911 J.959 E.04068
G1 X111.514 Y87.088 E.21115
G2 X111.484 Y86.419 I-6.828 J-.031 E.03484
G1 X108.463 Y83.417 E.22162
G2 X108.239 Y82.555 I-8.707 J1.806 E.04636
G1 X111.434 Y85.73 E.23435
G2 X111.348 Y85.006 I-7.257 J.488 E.03794
G1 X107.949 Y81.628 E.24934
G2 X107.574 Y80.615 I-10.434 J3.296 E.05622
G1 X111.239 Y84.259 E.26892
G2 X111.102 Y83.483 I-7.797 J.98 E.04099
G1 X107.062 Y79.468 E.29639
G2 X106.328 Y78.099 I-14.153 J6.708 E.08082
G1 X110.917 Y82.661 E.33665
G2 X110.683 Y81.789 I-13.686 J3.211 E.04698
G1 X95.838 Y67.033 E1.08906
G2 X94.965 Y66.805 I-2.739 J8.703 E.04692
G1 X99.557 Y71.368 E.33681
G2 X98.176 Y70.635 I-7.972 J13.345 E.08136
G1 X94.139 Y66.622 E.29617
G1 X93.361 Y66.488 E.04108
G1 X97.031 Y70.136 E.26926
G2 X96.016 Y69.766 I-4.235 J10.038 E.05625
G1 X92.615 Y66.386 E.2495
G2 X91.893 Y66.307 I-1.145 J7.159 E.0378
G1 X95.085 Y69.48 E.23421
G2 X94.223 Y69.262 I-2.58 J8.389 E.0463
G1 X91.199 Y66.256 E.22188
G2 X90.532 Y66.233 I-.829 J14.199 E.03469
G1 X93.412 Y69.095 E.21125
G2 X92.642 Y68.968 I-1.692 J7.88 E.04064
G1 X89.88 Y66.224 E.20256
G1 X89.252 Y66.238 E.0327
G1 X91.908 Y68.878 E.19483
G2 X91.433 Y68.841 I-2.215 J24.916 E.02476
G1 X91.221 Y68.559 E.01835
G1 X90.759 Y68.079 E.03468
G2 X90.152 Y67.772 I-.952 J1.131 E.03569
G1 X88.639 Y66.268 E.11101
G1 X88.04 Y66.312 E.03123
G1 X89.584 Y67.847 E.11327
G1 X89.205 Y68.109 E.02398
G1 X87.462 Y66.376 E.12789
G1 X86.89 Y66.447 E.02997
G1 X88.897 Y68.441 E.14719
G2 X88.604 Y68.789 I1.519 J1.577 E.0237
G1 X86.341 Y66.54 E.16602
G2 X85.793 Y66.634 I.691 J5.621 E.02892
G1 X88.055 Y68.883 E.16594
G1 X87.483 Y68.953 E.03
G1 X85.269 Y66.752 E.16243
G2 X84.745 Y66.871 I.942 J5.358 E.02793
G1 X86.924 Y69.037 E.15986
G1 X86.377 Y69.131 E.02893
G1 X84.243 Y67.011 E.15654
G2 X83.74 Y67.15 I1.207 J5.31 E.02714
G1 X85.849 Y69.246 E.15469
G2 X85.327 Y69.366 I.916 J5.184 E.02789
G1 X83.258 Y67.31 E.15179
G1 X82.775 Y67.469 E.02645
G1 X84.824 Y69.506 E.15033
G2 X84.328 Y69.652 I1.239 J5.111 E.0269
G1 X82.311 Y67.646 E.14801
G1 X81.848 Y67.825 E.02582
G1 X83.846 Y69.812 E.14659
G2 X83.373 Y69.98 I1.49 J4.927 E.02615
G1 X81.4 Y68.019 E.14476
G1 X80.955 Y68.216 E.02531
G1 X82.91 Y70.159 E.14343
G2 X82.459 Y70.349 I1.747 J4.774 E.0255
G1 X80.522 Y68.424 E.14209
G1 X80.095 Y68.639 E.02486
G1 X82.014 Y70.546 E.14075
G2 X81.582 Y70.757 I1.945 J4.538 E.02498
M73 P78 R4
G1 X79.676 Y68.861 E.13987
G1 X79.266 Y69.093 E.02449
G1 X81.155 Y70.971 E.13859
G2 X80.742 Y71.199 I2.06 J4.222 E.02458
G1 X78.86 Y69.328 E.13808
G1 X78.467 Y69.577 E.02418
G1 X80.332 Y71.431 E.13685
G2 X79.936 Y71.677 I2.285 J4.13 E.02425
G1 X78.074 Y69.826 E.13661
G2 X77.697 Y70.089 I2.49 J3.971 E.02398
G1 X79.544 Y71.926 E.13552
G2 X79.164 Y72.187 I2.575 J4.152 E.02401
G1 X77.32 Y70.354 E.13525
G2 X76.954 Y70.629 I2.645 J3.91 E.02384
G1 X78.787 Y72.451 E.1345
G2 X78.424 Y72.729 I2.574 J3.742 E.02381
G1 X76.593 Y70.91 E.13428
G1 X76.511 Y70.974 E.00545
G2 X76.238 Y71.196 I2.064 J2.823 E.01829
G1 X78.064 Y73.01 E.13393
G2 X77.715 Y73.303 I2.826 J3.722 E.02369
G1 X75.894 Y71.493 E.13359
G1 X75.55 Y71.79 E.02365
G1 X77.371 Y73.6 E.13357
G2 X77.038 Y73.908 I4.827 J5.547 E.02361
G1 X75.221 Y72.102 E.13328
G1 X74.893 Y72.415 E.02359
G1 X76.709 Y74.22 E.13328
G2 X76.39 Y74.542 I3.065 J3.358 E.02359
G1 X74.574 Y72.737 E.13322
G1 X74.262 Y73.066 E.02359
G1 X76.078 Y74.871 E.13322
G2 X75.774 Y75.208 I3.322 J3.293 E.02362
G1 X73.954 Y73.399 E.13353
G1 X73.657 Y73.743 E.02364
G1 X75.478 Y75.552 E.13354
G2 X75.189 Y75.905 I3.499 J3.161 E.0237
G1 X73.36 Y74.087 E.13416
G2 X73.08 Y74.447 I3.388 J2.934 E.02376
G1 X74.908 Y76.264 E.13414
G2 X74.635 Y76.632 I3.478 J2.867 E.02384
G1 X72.799 Y74.807 E.13471
G2 X72.529 Y75.177 I3.679 J2.963 E.02387
G1 X74.371 Y77.008 E.13512
G2 X74.114 Y77.392 I5.499 J3.965 E.02403
G1 X72.264 Y75.553 E.13568
G2 X72.006 Y75.935 I3.768 J2.83 E.02401
G1 X73.865 Y77.784 E.13642
G2 X73.624 Y78.183 I3.926 J2.639 E.02429
G1 X71.757 Y76.327 E.13697
G2 X71.51 Y76.721 I3.836 J2.678 E.02419
G1 X73.392 Y78.592 E.13807
G2 X73.169 Y79.009 I4.094 J2.464 E.02462
G1 X71.279 Y77.13 E.13866
G1 X71.047 Y77.539 E.02445
G1 X72.955 Y79.435 E.13991
G2 X72.749 Y79.87 I4.323 J2.304 E.02504
G1 X70.83 Y77.962 E.1408
G1 X70.616 Y78.388 E.02481
G1 X72.553 Y80.314 E.14212
G2 X72.367 Y80.768 I4.563 J2.128 E.02556
G1 X70.413 Y78.825 E.14341
G1 X70.216 Y79.269 E.02525
G1 X72.189 Y81.23 E.14474
G2 X72.025 Y81.706 I9.49 J3.543 E.02619
G1 X70.028 Y79.721 E.1465
G1 X69.849 Y80.183 E.02575
G1 X71.866 Y82.187 E.14793
G2 X71.725 Y82.685 I5.068 J1.705 E.02698
G1 X69.677 Y80.65 E.1502
G1 X69.519 Y81.132 E.02637
G1 X71.588 Y83.188 E.1518
G1 X71.471 Y83.711 E.02787
G1 X69.365 Y81.618 E.15452
G1 X69.226 Y82.119 E.02705
G1 X71.362 Y84.242 E.1567
G1 X71.267 Y84.787 E.02878
G1 X69.091 Y82.624 E.15964
G1 X68.974 Y83.146 E.02786
G1 X71.189 Y85.348 E.16252
G1 X71.159 Y85.59 E.01268
G2 X71.12 Y85.919 I3.336 J.563 E.01723
G1 X68.862 Y83.674 E.16569
G1 X68.767 Y84.219 E.0288
G1 X71.076 Y86.514 E.16937
G2 X71.046 Y87.123 I6.225 J.613 E.03174
G1 X68.681 Y84.772 E.17352
G1 X68.61 Y85.341 E.02983
G1 X71.031 Y87.747 E.17756
G2 X71.047 Y88.402 I6.505 J.167 E.03411
G1 X68.552 Y85.923 E.18299
G1 X68.508 Y86.518 E.03107
G1 X71.083 Y89.077 E.18886
G1 X71.1 Y89.31 E.01218
G2 X71.143 Y89.775 I4.781 J-.203 E.0243
G1 X68.485 Y87.134 E.19498
G2 X68.47 Y87.758 I6.415 J.465 E.0325
G1 X71.232 Y90.504 E.20265
G2 X71.364 Y91.274 I7.86 J-.951 E.04068
G1 X68.486 Y88.413 E.21116
G1 X68.494 Y88.751 E.01759
G2 X68.516 Y89.081 I3.396 J-.055 E.01725
G1 X71.537 Y92.084 E.22163
G2 X71.761 Y92.946 I8.698 J-1.803 E.04637
G1 X68.567 Y89.771 E.23437
G2 X68.652 Y90.495 I7.276 J-.491 E.03794
G1 X72.051 Y93.873 E.24936
G2 X72.427 Y94.886 I16.131 J-5.412 E.05621
G1 X68.761 Y91.242 E.26894
G2 X68.898 Y92.018 I7.786 J-.979 E.041
G1 X72.939 Y96.034 E.29643
G1 X73.133 Y96.42 E.02249
G2 X73.673 Y97.402 I10.171 J-4.948 E.05834
G1 X68.816 Y92.575 E.35631
M106 S153
; WIPE_START
G1 X70.234 Y93.985 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X74.805 Y87.872 Z4.6 F42000
G1 X89.336 Y68.436 Z4.6
G1 Z4.2
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.401075
; LAYER_HEIGHT: 0.2
G1 F10051.514
M204 S6000
G1 X89.558 Y68.337 E.0071
; LINE_WIDTH: 0.451296
G1 F8815.417
G3 X90.13 Y68.225 I.435 J.712 E.01982
M204 S10000
G1 X96.446 Y66.999 F42000
; FEATURE: Bridge
; LINE_WIDTH: 0.40323
; LAYER_HEIGHT: 0.4
M106 S255
G1 F1200
M204 S6000
M73 P79 R4
G1 X110.392 Y80.86 E1.02307
G2 X110.024 Y79.856 I-10.189 J3.159 E.05567
G1 X97.774 Y67.679 E.89872
G3 X98.885 Y68.145 I-4.301 J11.822 E.06273
G1 X109.554 Y78.749 E.78267
G2 X108.918 Y77.479 I-25.669 J12.044 E.07393
G1 X100.159 Y68.768 E.64272
G3 X101.75 Y69.715 I-8.752 J16.521 E.09634
G1 X107.971 Y75.897 E.45633
G2 X106.643 Y74.091 I-22.208 J14.927 E.11667
G1 X106.561 Y73.996 E.00656
G2 X105.276 Y72.581 I-15.355 J12.647 E.09947
G1 X103.086 Y70.403 E.16069
M106 S153
; WIPE_START
G1 X104.504 Y71.813 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X101.464 Y78.814 Z4.6 F42000
G1 X90.028 Y105.144 Z4.6
G1 Z4.2
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
; LAYER_HEIGHT: 0.2
G1 F8843.689
M204 S6000
G1 X89.841 Y105.103 E.00633
G1 X89.403 Y104.791 E.01785
G1 X89.404 Y104.182 E.02019
G1 X89.305 Y103.858 E.01123
G1 X89.17 Y103.716 E.00651
G1 X88.894 Y103.605 E.00983
G3 X88.832 Y71.9 I1.112 J-15.855 E1.58043
G1 X89.081 Y71.839 E.00851
G1 X89.305 Y71.642 E.00988
G1 X89.404 Y71.318 E.01123
G1 X89.403 Y70.714 E.02005
G1 X89.557 Y70.573 E.0069
G1 X89.884 Y70.375 E.01269
G1 X90.056 Y70.365 E.00572
G1 X90.291 Y70.473 E.0086
G1 X90.597 Y70.714 E.0129
G1 X90.596 Y71.318 E.02004
G1 X90.695 Y71.642 E.01123
G1 X90.83 Y71.784 E.00651
G1 X91.106 Y71.895 E.00983
G3 X105.888 Y88.142 I-1.12 J15.868 E.80424
G3 X91.168 Y103.6 I-15.902 J-.405 E.77617
G1 X90.919 Y103.661 E.00851
G1 X90.695 Y103.858 E.00988
G1 X90.596 Y104.182 E.01123
G1 X90.597 Y104.786 E.02004
G1 X90.351 Y104.997 E.01075
G1 X90.082 Y105.119 E.00979
M204 S250
G1 X90.061 Y105.541 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.815 Y105.519 E.00757
G1 X89.443 Y105.324 E.01293
G1 X89.011 Y104.965 E.01724
G2 X88.98 Y104.077 I-5.929 J-.233 E.02734
G1 X88.848 Y103.995 E.00475
G3 X88.803 Y71.509 I1.158 J-16.245 E1.49948
G1 X88.936 Y71.47 E.00424
G1 X89.012 Y71.318 E.0052
G1 X89.011 Y70.542 E.02387
G1 X89.291 Y70.284 E.01169
G1 X89.75 Y70.001 E.01657
G3 X90.248 Y70 I.25 J.695 E.0156
G1 X90.544 Y70.166 E.01045
G1 X90.989 Y70.542 E.01789
G1 X90.988 Y71.318 E.02386
G1 X91.021 Y71.423 E.00338
G1 X91.152 Y71.505 E.00475
G3 X106.28 Y88.151 I-1.166 J16.257 E.76276
G3 X91.197 Y103.991 I-16.295 J-.415 E.73671
G1 X91.064 Y104.03 E.00424
G1 X90.988 Y104.182 E.0052
G1 X90.989 Y104.958 E.02386
G3 X90.416 Y105.415 I-1.808 J-1.68 E.02257
G1 X90.117 Y105.521 E.00975
; WIPE_START
M204 S6000
G1 X89.815 Y105.519 E-.11472
G1 X89.443 Y105.324 E-.15988
G1 X89.011 Y104.965 E-.21326
G1 X89.011 Y104.503 E-.17534
G1 X88.992 Y104.249 E-.09679
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X82.502 Y100.233 Z4.6 F42000
G1 X77.278 Y97.001 Z4.6
G1 Z4.2
G1 E.8 F1800
; FEATURE: Bridge
; LINE_WIDTH: 0.40014
; LAYER_HEIGHT: 0.4
M106 S255
G1 F1200
M204 S6000
G2 X79.57 Y99.258 I61.431 J-60.116 E.1648
G1 X79.953 Y99.587 E.02584
G2 X82.004 Y101.064 I9.877 J-11.555 E.12967
G1 X76.741 Y95.833 E.38018
G3 X75.993 Y94.454 I15.58 J-9.351 E.0804
G1 X83.383 Y101.8 E.53384
G2 X84.489 Y102.265 I5.311 J-11.088 E.06152
G1 X75.519 Y93.349 E.64797
G1 X75.5 Y93.298 E.0028
G3 X75.176 Y92.373 I9.538 J-3.857 E.05023
G1 X85.47 Y102.605 E.74363
G2 X86.347 Y102.842 I8.37 J-29.181 E.04658
G1 X74.927 Y91.491 E.82498
G3 X74.751 Y90.681 I8.141 J-2.197 E.04249
G1 X87.159 Y103.015 E.89636
G2 X87.916 Y103.132 I1.279 J-5.746 E.03926
G1 X74.625 Y89.921 E.96014
G1 X74.58 Y89.559 E.01869
G3 X74.539 Y89.201 I3.503 J-.582 E.01848
G1 X88.631 Y103.208 E1.01801
G3 X89.413 Y103.443 I.024 J1.338 E.04253
G1 X89.619 Y103.659 E.01531
G1 X89.771 Y104.158 E.02668
G1 X89.771 Y104.341 E.00941
G1 X90.132 Y104.7 E.02608
G2 X90.229 Y104.624 I-.135 J-.274 E.00636
G1 X90.229 Y104.162 E.0237
G1 X74.489 Y88.517 E1.13707
G1 X74.473 Y87.866 E.03336
G1 X90.376 Y103.674 E1.14889
G1 X90.605 Y103.424 E.01734
G1 X90.703 Y103.364 E.0059
G1 X74.482 Y87.241 E1.1718
G3 X74.514 Y86.638 I10.079 J.229 E.03095
G1 X91.207 Y103.23 E1.2059
G1 X91.432 Y103.213 E.01159
G2 X91.788 Y103.173 I-.243 J-3.765 E.01834
G1 X74.566 Y86.054 E1.24415
G1 X74.636 Y85.489 E.02916
G1 X92.352 Y103.099 E1.27984
G1 X92.896 Y103.005 E.02828
G1 X74.729 Y84.947 E1.31242
G3 X74.836 Y84.419 I5.424 J.821 E.02764
G1 X93.423 Y102.894 E1.34275
G2 X93.937 Y102.77 I-.994 J-5.261 E.0271
G1 X74.955 Y83.903 E1.37126
G1 X75.093 Y83.405 E.02646
G1 X94.437 Y102.632 E1.3974
G2 X94.918 Y102.476 I-3.92 J-12.941 E.02594
G1 X75.244 Y82.921 E1.42125
G3 X75.406 Y82.446 I5.051 J1.451 E.02568
G1 X95.391 Y102.311 E1.44373
G1 X95.851 Y102.134 E.02526
G1 X75.582 Y81.987 E1.46419
M73 P80 R4
G3 X75.77 Y81.54 I4.679 J1.7 E.0249
G1 X96.296 Y101.942 E1.4828
G1 X96.344 Y101.92 E.00269
G2 X96.734 Y101.742 I-1.598 J-4.009 E.02197
G1 X75.966 Y81.099 E1.5003
G1 X76.179 Y80.676 E.02426
G1 X97.158 Y101.529 E1.51553
G2 X97.571 Y101.305 I-2.092 J-4.358 E.02409
G1 X76.399 Y80.26 E1.52951
G1 X76.629 Y79.854 E.02391
G1 X97.978 Y101.075 E1.54229
G2 X98.368 Y100.828 I-2.3 J-4.062 E.02366
G1 X76.872 Y79.461 E1.55289
G1 X76.955 Y79.33 E.00798
G3 X77.121 Y79.074 I2.748 J1.598 E.01561
G1 X98.753 Y100.575 E1.56268
G1 X99.126 Y100.312 E.02342
G1 X77.384 Y78.701 E1.57069
G3 X77.654 Y78.335 I5.051 J3.446 E.02332
G1 X99.489 Y100.038 E1.57739
G1 X99.847 Y99.759 E.02325
G1 X77.933 Y77.977 E1.58308
G3 X78.224 Y77.632 I3.71 J2.832 E.02315
G1 X100.189 Y99.465 E1.58677
G2 X100.527 Y99.165 I-2.794 J-3.485 E.02312
G1 X78.52 Y77.291 E1.58975
G1 X78.831 Y76.966 E.02307
G1 X100.852 Y98.854 E1.59084
G2 X101.169 Y98.534 I-3.227 J-3.512 E.02307
G1 X79.148 Y76.646 E1.59084
G1 X79.473 Y76.335 E.02307
G1 X101.48 Y98.209 E1.58975
G2 X101.776 Y97.868 I-12.185 J-10.894 E.02312
G1 X79.811 Y76.035 E1.58677
G1 X80.153 Y75.741 E.02313
G1 X102.067 Y97.523 E1.58308
G1 X102.346 Y97.165 E.02323
G1 X80.511 Y75.462 E1.57739
G3 X80.874 Y75.188 I2.944 J3.526 E.02331
G1 X102.616 Y96.799 E1.57069
G1 X102.879 Y96.426 E.0234
G1 X81.247 Y74.925 E1.56268
G3 X81.632 Y74.672 I5.049 J7.266 E.02357
G1 X103.128 Y96.039 E1.55289
G2 X103.371 Y95.646 I-3.772 J-2.607 E.02369
G1 X82.022 Y74.425 E1.54229
G1 X82.429 Y74.195 E.02395
G1 X103.601 Y95.24 E1.52951
G2 X103.821 Y94.824 I-4.172 J-2.472 E.02412
G1 X82.842 Y73.971 E1.51553
G1 X83.266 Y73.758 E.02431
G1 X104.034 Y94.401 E1.5003
G2 X104.23 Y93.96 I-4.407 J-2.221 E.02469
G1 X83.704 Y73.558 E1.4828
M73 P81 R3
G3 X84.149 Y73.366 I2.186 J4.462 E.02486
G1 X104.418 Y93.513 E1.46419
G1 X104.595 Y93.054 E.0252
G1 X84.609 Y73.189 E1.44373
G3 X85.082 Y73.024 I1.968 J4.871 E.02565
G1 X104.756 Y92.579 E1.42125
G2 X104.907 Y92.095 I-4.733 J-1.747 E.026
G1 X85.563 Y72.868 E1.3974
G1 X86.063 Y72.73 E.02655
G1 X105.045 Y91.597 E1.37125
G2 X105.164 Y91.081 I-5.162 J-1.467 E.02715
G1 X86.577 Y72.606 E1.34275
G3 X87.104 Y72.495 I1.394 J5.301 E.02759
G1 X105.271 Y90.553 E1.31241
G2 X105.364 Y90.01 I-5.675 J-1.252 E.0282
G1 X87.648 Y72.401 E1.27984
G3 X88.212 Y72.327 I1.851 J11.961 E.02916
G1 X105.434 Y89.446 E1.24414
M73 P82 R3
G2 X105.486 Y88.862 I-5.715 J-.799 E.03002
G1 X88.793 Y72.27 E1.2059
G2 X89.297 Y72.136 I-.026 J-1.111 E.02696
G1 X105.518 Y88.259 E1.1718
G2 X105.527 Y87.634 I-6.327 J-.411 E.03204
G1 X89.623 Y71.826 E1.14894
G1 X89.768 Y71.415 E.0223
G1 X89.768 Y71.335 E.00409
G1 X105.511 Y86.983 E1.13727
G1 X105.461 Y86.299 E.03516
G1 X91.369 Y72.292 E1.01801
G1 X92.084 Y72.368 E.03685
G1 X105.375 Y85.579 E.96014
G2 X105.249 Y84.819 I-24.31 J3.647 E.03948
G1 X92.841 Y72.485 E.89636
G3 X93.653 Y72.658 I-1.341 J8.325 E.04253
G1 X105.073 Y84.009 E.82497
G2 X104.824 Y83.127 I-30.98 J8.256 E.04694
G1 X94.53 Y72.895 E.74363
G3 X95.511 Y73.235 I-3.599 J11.957 E.05321
M73 P83 R3
G1 X104.481 Y82.151 E.64796
G2 X104.007 Y81.046 I-17.585 J6.879 E.06162
G1 X96.617 Y73.7 E.53383
G3 X97.984 Y74.429 I-9.59 J19.647 E.07937
G1 X103.259 Y79.667 E.38087
G1 X103.181 Y79.545 E.00739
G2 X100.982 Y76.769 I-13.494 J8.432 E.18184
G1 X99.179 Y74.978 E.13022
M106 S153
; WIPE_START
G1 X100.598 Y76.387 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X93.756 Y73.005 Z4.6 F42000
G1 X90.434 Y71.363 Z4.6
G1 Z4.2
G1 E.8 F1800
M106 S255
G1 F1200
M204 S6000
G1 X89.722 Y70.655 E.05145
M106 S153
; CHANGE_LAYER
; Z_HEIGHT: 4.4
; LAYER_HEIGHT: 0.2
; WIPE_START
M73 P84 R3
G1 F1200
G1 X90.434 Y71.363 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 22/25
; update layer progress
M73 L22
M991 S0 P21 ;notify layer change
M106 S191.25
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z4.6 I-1.212 J.107 P1  F42000
G1 X93.777 Y109.313 Z4.6
G1 Z4.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X93.213 Y109.412 E.01902
G3 X111.494 Y83.573 I-3.21 J-21.657 E3.38965
G3 X111.897 Y87.79 I-21.758 J4.207 E.14074
G3 X94.273 Y109.228 I-21.894 J-.036 E.99704
G1 X93.837 Y109.303 E.01468
M204 S250
G1 X93.844 Y109.699 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X93.27 Y109.799 E.01791
M73 P85 R3
G3 X111.88 Y83.507 I-3.267 J-22.045 E3.19632
G3 X112.289 Y87.8 I-22.137 J4.273 E.13272
G3 X94.349 Y109.612 I-22.286 J-.046 E.93982
G1 X93.903 Y109.689 E.0139
; WIPE_START
M204 S6000
G1 X93.27 Y109.799 E-.24426
G1 X92.185 Y109.933 E-.41559
G1 X91.922 Y109.952 E-.10015
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.467 Y106.282 Z4.8 F42000
G1 Z4.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X88.191 Y106.26 E.00916
G3 X77.497 Y73.976 I1.809 J-18.512 E1.42344
M73 P85 R2
G3 X89.234 Y69.171 I12.502 J13.8 E.42927
G1 X89.531 Y69.053 E.01061
G1 X90.077 Y68.983 E.01825
G1 X90.533 Y69.075 E.01544
M73 P86 R2
G1 X90.745 Y69.166 E.00765
G3 X91.837 Y106.261 I-.749 J18.585 E1.85232
G2 X90.727 Y106.353 I.139 J8.36 E.03697
G1 X90.241 Y106.498 E.01682
G1 X90.039 Y106.516 E.00672
G1 X89.538 Y106.454 E.01676
G1 X89.255 Y106.334 E.01018
G1 X88.527 Y106.286 E.02423
M204 S250
G1 X88.493 Y105.89 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X88.437 Y105.886 E.00172
G1 X88.365 Y105.882 E.00223
G1 X88.292 Y105.877 E.00223
G3 X77.768 Y74.261 I1.708 J-18.129 E1.29299
G3 X88.375 Y69.618 I12.216 J13.472 E.36209
G1 X88.54 Y69.608 E.00506
G1 F7581.319
G1 X88.704 Y69.597 E.00506
G1 F5723.132
G1 X88.869 Y69.587 E.00506
G1 F4125.833
G1 X88.973 Y69.581 E.00321
G1 F3247.964
G1 X89.008 Y69.578 E.00107
G1 F2978.831
G1 X89.043 Y69.576 E.00107
G1 F2721.264
G1 X89.077 Y69.574 E.00107
G1 F2475.411
G1 X89.112 Y69.572 E.00107
G1 F2241.195
G1 X89.147 Y69.57 E.00107
G1 F2018.613
G1 X89.182 Y69.568 E.00107
G1 F1807.614
G1 X89.216 Y69.565 E.00107
G1 F1608.315
G1 X89.251 Y69.563 E.00107
G1 F1420.654
G1 X89.286 Y69.561 E.00107
G1 F1244.631
G1 X89.321 Y69.559 E.00107
G1 F1080.2
G2 X89.433 Y69.514 I-.004 J-.172 E.00379
M106 S255
G1 F600
G1 X89.594 Y69.441 E.00544
M106 S191.25
M106 S255
M73 P87 R2
G1 X89.88 Y69.394 E.00889
M106 S191.25
M106 S255
G3 X90.171 Y69.398 I.141 J.419 E.00912
M106 S191.25
M106 S255
G3 X90.425 Y69.455 I.004 J.571 E.00806
M106 S191.25
M106 S255
G1 X90.581 Y69.523 E.00525
M106 S191.25
G1 F1073.921
G2 X90.695 Y69.559 I.107 J-.141 E.00374
G1 F1428.081
G1 X90.768 Y69.563 E.00223
G1 F1832.622
G1 X90.84 Y69.568 E.00223
G1 F2287.551
G1 X90.912 Y69.572 E.00223
G1 F2792.861
G1 X90.985 Y69.577 E.00223
G1 F3348.56
G1 X91.057 Y69.582 E.00223
G1 F3954.645
G1 X91.129 Y69.586 E.00223
G1 F4611.108
G1 X91.202 Y69.591 E.00223
G1 F5317.962
G1 X91.274 Y69.595 E.00223
G1 F6075.194
G1 X91.346 Y69.6 E.00223
G1 F6882.818
G1 X91.418 Y69.605 E.00223
G1 F7740.82
G1 X91.491 Y69.609 E.00223
G1 F8649.213
G1 X91.563 Y69.614 E.00223
G1 F9547.299
G1 X91.635 Y69.618 E.00223
G1 X91.708 Y69.623 E.00223
G3 X91.643 Y105.881 I-1.704 J18.126 E1.65452
G1 X91.497 Y105.89 E.00449
G1 F8211.499
G1 X91.352 Y105.899 E.00449
G1 F6479.056
G1 X91.206 Y105.908 E.00449
G1 F4951.537
G1 X91.06 Y105.917 E.00449
G1 F3629.149
G1 X91 Y105.921 E.00185
G1 F3143.186
G1 X90.964 Y105.923 E.00109
G1 F2872.944
G1 X90.929 Y105.926 E.00109
G1 F2614.842
G1 X90.893 Y105.928 E.00109
G1 F2368.82
G1 X90.858 Y105.93 E.00109
G1 F2135.017
G1 X90.822 Y105.932 E.00109
G1 F1913.357
G1 X90.787 Y105.934 E.00109
G1 F1703.842
G1 X90.751 Y105.937 E.00109
G1 F1506.472
G1 X90.716 Y105.939 E.00109
G1 F1321.252
G1 X90.68 Y105.941 E.00109
G1 F1148.173
G2 X90.551 Y105.981 I.011 J.263 E.00421
M106 S255
G1 F600
G1 X90.378 Y106.039 E.00559
M106 S191.25
M106 S255
G1 X90.206 Y106.097 E.00559
M106 S191.25
M106 S255
G1 X90.139 Y106.119 E.00217
G1 X89.956 Y106.104 E.00566
M106 S191.25
M106 S255
G1 X89.653 Y106.078 E.00934
G1 X89.592 Y106.052 E.00202
M106 S191.25
M106 S255
G1 X89.424 Y105.98 E.00563
M106 S191.25
G1 F1101.877
G2 X89.305 Y105.941 I-.113 J.148 E.00394
G1 F1460.396
G1 X89.232 Y105.937 E.00223
G1 F1869.269
G1 X89.16 Y105.932 E.00223
G1 F2328.536
G1 X89.088 Y105.928 E.00223
G1 F2838.206
G1 X89.015 Y105.923 E.00223
G1 F3398.276
G1 X88.943 Y105.918 E.00223
G1 F4008.738
G1 X88.871 Y105.914 E.00223
G1 F4669.605
G1 X88.798 Y105.909 E.00223
G1 F5380.972
G1 X88.726 Y105.905 E.00223
G1 F6142.637
G1 X88.654 Y105.9 E.00223
G1 F6954.707
G1 X88.581 Y105.895 E.00223
G1 F7293.245
G1 X88.553 Y105.894 E.00089
; WIPE_START
M204 S6000
G1 X88.437 Y105.886 E-.04407
G1 X88.365 Y105.882 E-.02753
G1 X88.292 Y105.877 E-.02753
G1 X87.333 Y105.763 E-.36709
G1 X86.571 Y105.631 E-.29378
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z4.8 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z4.8
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z4.8 F4000
            G39.3 S1
            G0 Z4.8 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X89.097 Y67.495 F42000
G1 Z4.4
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.58215
G1 F6676.186
M204 S6000
G1 X89.429 Y67.461 E.01468
; LINE_WIDTH: 0.526381
G1 F7446.313
G1 X89.761 Y67.427 E.01316
G1 X90.469 Y67.446 E.02788
; WIPE_START
G1 X89.761 Y67.427 E-.51632
G1 X89.429 Y67.461 E-.24368
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.774 Y75.086 Z4.8 F42000
G1 X91.204 Y106.694 Z4.8
G1 Z4.4
G1 E.8 F1800
; LINE_WIDTH: 0.41999
G1 F9547.301
M204 S6000
G1 X90.876 Y106.715 E.01011
G1 X90.152 Y106.905 E.02299
G1 X89.644 Y106.874 E.01563
G1 X89.174 Y106.723 E.01518
G3 X89.141 Y68.784 I.826 J-18.97 E1.78113
G1 X89.45 Y68.669 E.01013
G1 X89.95 Y68.588 E.01555
G1 X90.441 Y68.64 E.01518
G1 X90.828 Y68.777 E.01262
G3 X91.264 Y106.69 I-.821 J18.968 E1.76883
M204 S10000
G1 X91.228 Y107.07 F42000
G1 F9547.301
M204 S6000
G2 X90.123 Y107.286 I2.985 J18.168 E.03458
G1 X89.615 Y107.25 E.01565
G1 X89.1 Y107.095 E.01653
G3 X89.059 Y68.412 I.899 J-19.343 E1.81267
G1 X89.39 Y68.297 E.01075
G1 X89.889 Y68.216 E.01555
G1 X90.44 Y68.256 E.01696
G1 X91.026 Y68.413 E.01865
G3 X91.287 Y107.066 I-1.016 J19.334 E1.79838
M204 S10000
G1 X91.251 Y107.447 F42000
G1 F9547.301
M204 S6000
G1 X90.323 Y107.639 E.02914
G1 X90.032 Y107.661 E.00894
G1 X89.359 Y107.58 E.02084
G1 X88.961 Y107.464 E.01273
G3 X88.734 Y68.055 I1.029 J-19.711 E1.83502
G2 X89.329 Y67.925 I-.1 J-1.885 E.01882
G1 X89.829 Y67.844 E.01555
G1 X90.481 Y67.881 E.02007
G1 X90.983 Y68.032 E.0161
G3 X91.311 Y107.443 I-.974 J19.715 E1.83538
M204 S10000
G1 X91.273 Y107.793 F42000
; LINE_WIDTH: 0.381429
G1 F10634.894
M204 S6000
G1 X91.209 Y107.827 E.00202
; LINE_WIDTH: 0.425565
G1 F9408.199
G1 X91.144 Y107.862 E.00228
; LINE_WIDTH: 0.469702
G1 F8435.227
G1 X91.08 Y107.896 E.00254
; LINE_WIDTH: 0.513839
G1 F7644.638
G1 X91.015 Y107.931 E.00281
; LINE_WIDTH: 0.557975
G1 F6989.545
G1 X90.951 Y107.966 E.00307
; LINE_WIDTH: 0.602112
G1 F6437.865
G1 X90.886 Y108 E.00333
G1 X90.954 Y108.018 E.00321
; LINE_WIDTH: 0.557975
G1 F6989.545
G1 X91.023 Y108.036 E.00295
; LINE_WIDTH: 0.513839
G1 F7644.638
G1 X91.091 Y108.054 E.0027
; LINE_WIDTH: 0.469702
G1 F8435.227
G1 X91.159 Y108.072 E.00245
; LINE_WIDTH: 0.425565
G1 F9408.199
G1 X91.227 Y108.09 E.00219
; LINE_WIDTH: 0.355666
G1 F11510.971
G1 X91.295 Y108.108 E.00179
G2 X91.098 Y67.377 I-1.29 J-20.36 E1.57259
G1 X90.852 Y67.383 E.00625
; LINE_WIDTH: 0.416664
G1 F9632.279
G1 X90.745 Y67.405 E.00335
; LINE_WIDTH: 0.46495
G1 F8530.199
G1 X90.637 Y67.426 E.00378
; LINE_WIDTH: 0.513237
G1 F7654.417
G1 X90.529 Y67.448 E.00422
; LINE_WIDTH: 0.515008
G1 F7625.705
G1 X90.655 Y67.506 E.00535
; LINE_WIDTH: 0.470263
G1 F8424.157
G1 X90.781 Y67.565 E.00485
; LINE_WIDTH: 0.425518
G1 F9409.367
G1 X90.907 Y67.624 E.00434
; LINE_WIDTH: 0.355637
G1 F11512.029
G1 X91.033 Y67.683 E.00355
G3 X91.333 Y107.788 I-1.031 J20.062 E1.54793
M204 S10000
G1 X90.886 Y108 F42000
; LINE_WIDTH: 0.606934
G1 F6382.828
M204 S6000
G1 X90.717 Y108.022 E.00784
; LINE_WIDTH: 0.57244
G1 F6798.611
G1 X90.548 Y108.043 E.00736
; LINE_WIDTH: 0.528069
G1 F7420.404
G1 X90.379 Y108.064 E.00674
G1 X89.613 Y108.058 E.03028
M204 S10000
G1 X90 Y108.501 F42000
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S6000
G2 X88.982 Y108.476 I-.003 J-20.749 E3.97443
G1 X89.94 Y108.5 E.02946
M204 S10000
G1 X90 Y108.878 F42000
G1 F9547.299
M204 S6000
G2 X88.963 Y108.853 I-.003 J-21.126 E4.04667
G1 X89.94 Y108.877 E.03003
M204 S10000
G1 X90 Y109.256 F42000
G1 F9547.299
M204 S6000
G2 X88.945 Y109.23 I-.003 J-21.503 E4.11892
G1 X89.94 Y109.254 E.03059
M204 S10000
G1 X88.05 Y107.747 F42000
; LINE_WIDTH: 0.355551
G1 F11515.168
M204 S6000
G3 X88.711 Y67.709 I1.951 J-19.993 E1.52503
; LINE_WIDTH: 0.384181
G1 F10549.11
G1 X88.788 Y67.666 E.00245
; LINE_WIDTH: 0.433603
G1 F9214.632
G1 X88.866 Y67.623 E.0028
; LINE_WIDTH: 0.483025
G1 F8179.866
G1 X88.943 Y67.581 E.00316
; LINE_WIDTH: 0.532447
G1 F7354.038
G1 X89.02 Y67.538 E.00351
; LINE_WIDTH: 0.581869
G1 F6679.668
G1 X89.097 Y67.495 E.00387
G1 X89.015 Y67.475 E.00368
; LINE_WIDTH: 0.532447
G1 F7354.038
G1 X88.934 Y67.454 E.00335
; LINE_WIDTH: 0.483025
G1 F8179.866
G1 X88.853 Y67.434 E.00301
; LINE_WIDTH: 0.433603
G1 F9214.632
G1 X88.771 Y67.413 E.00267
; LINE_WIDTH: 0.384181
G1 F10549.11
G1 X88.69 Y67.393 E.00233
; LINE_WIDTH: 0.355648
G1 F11511.63
G2 X88.915 Y108.124 I1.307 J20.359 E1.57238
G1 X89.209 Y108.123 E.00749
; LINE_WIDTH: 0.407599
G1 F9871.714
G1 X89.324 Y108.101 E.00347
; LINE_WIDTH: 0.456975
G1 F8694.497
G1 X89.438 Y108.079 E.00394
; LINE_WIDTH: 0.506352
G1 F7768.136
G1 X89.553 Y108.058 E.0044
; LINE_WIDTH: 0.509468
G1 F7716.256
G1 X89.428 Y108.004 E.00518
; LINE_WIDTH: 0.466323
G1 F8502.548
G1 X89.303 Y107.95 E.0047
; LINE_WIDTH: 0.423178
G1 F9467.269
G1 X89.178 Y107.896 E.00422
; LINE_WIDTH: 0.360196
G1 F11346.586
G1 X89.053 Y107.843 E.00352
G1 X88.11 Y107.753 E.02449
; WIPE_START
G1 X89.053 Y107.843 E-.66449
G1 X89.178 Y107.896 E-.09551
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.035 Y104.762 Z4.8 F42000
G1 Z4.4
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.50752
G1 F7748.601
M204 S6000
G1 X89.769 Y104.696 E.01039
G1 X89.768 Y104.211 E.01838
; LINE_WIDTH: 0.50663
G1 F7763.473
G1 X89.671 Y104.006 E.00857
; LINE_WIDTH: 0.47831
G1 F8268.449
G1 X89.575 Y103.801 E.00805
; LINE_WIDTH: 0.44999
G1 F8843.689
G2 X89.209 Y103.628 I-.415 J.406 E.01371
G3 X88.442 Y71.928 I.797 J-15.878 E1.57837
G1 X89.303 Y71.856 E.02866
G1 X89.575 Y71.699 E.0104
; LINE_WIDTH: 0.479915
G1 F8238.08
G1 X89.671 Y71.523 E.00715
; LINE_WIDTH: 0.50984
G1 F7710.1
G1 X89.767 Y71.347 E.00764
G1 X89.766 Y70.801 E.02077
; LINE_WIDTH: 0.5075
G1 F7748.935
G1 X89.952 Y70.741 E.00739
G1 X90.231 Y70.803 E.01085
G1 X90.232 Y71.289 E.01839
; LINE_WIDTH: 0.50664
G1 F7763.305
G1 X90.329 Y71.494 E.00857
; LINE_WIDTH: 0.478315
G1 F8268.354
G1 X90.425 Y71.699 E.00805
; LINE_WIDTH: 0.44999
G1 F8843.689
G1 X90.653 Y71.843 E.00894
G3 X92.72 Y72.092 I-3.758 J39.976 E.06907
G3 X105.888 Y88.142 I-2.734 J15.67 E.75027
G3 X91.558 Y103.572 I-15.891 J-.389 E.76348
G1 X90.697 Y103.644 E.02866
G1 X90.425 Y103.801 E.0104
; LINE_WIDTH: 0.47831
G1 F8268.449
G1 X90.329 Y104.003 E.00797
; LINE_WIDTH: 0.50663
G1 F7763.473
G1 X90.232 Y104.206 E.00849
; LINE_WIDTH: 0.50752
G1 F7748.601
G1 X90.234 Y104.699 E.01865
G1 X90.092 Y104.744 E.00563
M204 S250
G1 X90.071 Y105.188 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.7 Y105.125 E.01154
G1 X89.348 Y104.935 E.0123
G1 X89.348 Y104.211 E.02226
G1 X89.294 Y104.074 E.00451
G1 X89.178 Y104.019 E.00395
G3 X89.173 Y71.482 I.821 J-16.269 E1.52173
G1 X89.294 Y71.426 E.00411
G1 X89.348 Y71.294 E.00437
G1 X89.344 Y70.564 E.02242
G1 X89.574 Y70.426 E.00825
G1 X89.924 Y70.314 E.01131
G1 X90.203 Y70.35 E.00864
G1 X90.619 Y70.529 E.01391
G1 X90.652 Y70.584 E.00199
G1 X90.653 Y71.31 E.0223
G1 X90.755 Y71.462 E.00561
G3 X92.787 Y71.705 I-3.343 J36.453 E.0629
G3 X106.28 Y88.151 I-2.802 J16.057 E.71213
G3 X91.596 Y103.962 I-16.284 J-.399 E.72465
G1 X90.755 Y104.038 E.02597
G1 X90.652 Y104.206 E.00604
G1 X90.656 Y104.936 E.02242
G1 X90.426 Y105.075 E.00825
G1 X90.128 Y105.169 E.00963
; WIPE_START
M204 S6000
G1 X89.7 Y105.125 E-.16334
G1 X89.348 Y104.935 E-.15215
G1 X89.348 Y104.211 E-.27524
G1 X89.294 Y104.074 E-.05573
G1 X89.178 Y104.019 E-.0488
G1 X89.009 Y104.006 E-.06474
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.589 Y103.009 Z4.8 F42000
G1 Z4.4
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.42
G1 F9547.055
M204 S2000
G1 X89.808 Y103.79 E.03394
G1 X89.553 Y103.512
G1 X90.188 Y102.876 E.02761
M204 S10000
G1 X89.899 Y102.847 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.235002
G1 F15000
M204 S6000
G1 X89.66 Y102.998 E.00442
; LINE_WIDTH: 0.261313
G1 X89.569 Y103.06 E.00197
; LINE_WIDTH: 0.307475
G1 F13607.777
G1 X89.46 Y103.133 E.00282
; LINE_WIDTH: 0.354928
G1 F11538.174
G2 X89.296 Y103.269 I1.846 J2.405 E.00541
; LINE_WIDTH: 0.34906
G1 F11759.356
G1 X89.314 Y103.297 E.00084
; LINE_WIDTH: 0.301571
G1 F13918.395
G1 X89.333 Y103.326 E.00071
; LINE_WIDTH: 0.254082
G1 F15000
G1 X89.351 Y103.354 E.00058
; LINE_WIDTH: 0.206594
G1 X89.369 Y103.383 E.00045
; LINE_WIDTH: 0.159105
G1 X89.387 Y103.411 E.00032
; LINE_WIDTH: 0.107816
G1 X89.494 Y103.479 E.00067
M204 S10000
G1 X90.875 Y103.209 F42000
; LINE_WIDTH: 0.183103
G1 F15000
M204 S6000
G1 X90.561 Y103.401 E.0042
; LINE_WIDTH: 0.156066
G1 X90.457 Y103.472 E.00116
; LINE_WIDTH: 0.113302
G2 X90.256 Y103.646 I.644 J.943 E.00153
; LINE_WIDTH: 0.118096
M73 P88 R2
G1 X90.173 Y103.76 E.00086
; LINE_WIDTH: 0.162097
G1 X90.09 Y103.874 E.00137
; LINE_WIDTH: 0.207969
G1 X90 Y103.998 E.00206
; LINE_WIDTH: 0.214058
G1 X89.971 Y103.982 E.00046
; LINE_WIDTH: 0.177157
G1 X89.943 Y103.967 E.00036
; LINE_WIDTH: 0.140256
G1 X89.914 Y103.951 E.00026
; LINE_WIDTH: 0.104994
G1 X89.837 Y103.845 E.00066
M204 S10000
G1 X90.787 Y103.116 F42000
; LINE_WIDTH: 0.297273
G1 F14153.573
M204 S6000
G1 X90.766 Y103.29 E.00364
G2 X90.383 Y103.482 I2.455 J5.386 E.00888
M204 S10000
G1 X99.369 Y100.393 F42000
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42255
G1 F9482.917
M204 S6000
G2 X101.535 Y98.204 I-45.18 J-46.856 E.09526
G2 X103.144 Y96.081 I-11.307 J-10.245 E.08252
G1 X98.331 Y100.894 E.21057
G3 X97.08 Y101.609 I-8.326 J-13.127 E.0446
G1 X103.859 Y94.83 E.29659
G2 X104.332 Y93.82 I-9.915 J-5.257 E.0345
G1 X96.07 Y102.082 E.36143
G3 X95.191 Y102.424 I-9.879 J-24.063 E.0292
G1 X104.674 Y92.941 E.41489
G2 X104.931 Y92.147 I-7.739 J-2.939 E.0258
G1 X94.397 Y102.681 E.46081
G3 X93.664 Y102.877 I-2.354 J-7.313 E.0235
G1 X105.127 Y91.414 E.50151
G2 X105.278 Y90.726 I-6.933 J-1.882 E.02179
G1 X92.976 Y103.028 E.5382
G1 X92.327 Y103.14 E.02038
G1 X105.39 Y90.077 E.57151
G2 X105.469 Y89.461 I-6.418 J-1.133 E.0192
G1 X91.711 Y103.219 E.60188
G3 X91.128 Y103.266 I-.724 J-5.395 E.01812
G1 X105.522 Y88.872 E.62971
G2 X105.553 Y88.304 I-5.859 J-.608 E.01761
G1 X90.896 Y102.961 E.64125
G1 X90.808 Y102.896 E.00337
G2 X90.553 Y102.767 I-.717 J1.1 E.00887
G1 X105.567 Y87.753 E.65684
G1 X105.554 Y87.229 E.01622
G1 X90.125 Y102.658 E.67501
G1 X89.96 Y102.654 E.00508
G2 X89.486 Y102.76 I.057 J1.367 E.01513
G1 X105.528 Y86.718 E.70184
G2 X105.491 Y86.218 I-4.899 J.11 E.01552
G1 X88.468 Y103.241 E.74476
G1 X87.99 Y103.182 E.01488
G1 X105.432 Y85.74 E.76305
G2 X105.364 Y85.271 I-4.97 J.479 E.01467
G1 X87.521 Y103.114 E.7806
G1 X87.064 Y103.035 E.01437
G1 X105.285 Y84.814 E.79717
G2 X105.191 Y84.371 I-4.537 J.732 E.01401
G1 X86.621 Y102.941 E.81243
G3 X86.184 Y102.841 I.787 J-4.46 E.01388
G1 X105.091 Y83.934 E.82719
G1 X104.975 Y83.513 E.0135
G1 X85.763 Y102.725 E.8405
G3 X85.348 Y102.603 I1.004 J-4.177 E.01338
G1 X104.853 Y83.098 E.85331
G1 X104.719 Y82.695 E.01314
G1 X84.945 Y102.469 E.8651
G3 X84.55 Y102.327 I1.29 J-4.207 E.01299
G1 X104.577 Y82.3 E.87616
G1 X104.428 Y81.913 E.01285
G1 X84.163 Y102.178 E.88658
G3 X83.786 Y102.018 I1.449 J-3.937 E.01267
G1 X104.268 Y81.536 E.89607
G1 X104.103 Y81.164 E.01259
G1 X83.414 Y101.853 E.90514
G3 X83.054 Y101.676 I1.6 J-3.708 E.01241
G1 X103.926 Y80.804 E.91314
G1 X103.746 Y80.447 E.01237
G1 X82.697 Y101.496 E.9209
G3 X82.352 Y101.304 I1.806 J-3.632 E.01221
G1 X103.554 Y80.102 E.92753
G1 X103.36 Y79.76 E.01219
G1 X82.01 Y101.11 E.93404
G3 X81.681 Y100.902 I1.896 J-3.364 E.01204
G1 X103.152 Y79.431 E.93934
G1 X102.943 Y79.102 E.01203
G1 X81.352 Y100.693 E.94459
G1 X81.037 Y100.472 E.01192
G1 X102.722 Y78.787 E.94868
G2 X102.5 Y78.472 I-3.296 J2.088 E.01192
G1 X80.722 Y100.25 E.95274
G1 X80.421 Y100.014 E.01183
G1 X102.264 Y78.171 E.95563
G2 X102.029 Y77.869 I-3.251 J2.3 E.01184
G1 X80.119 Y99.779 E.95851
G1 X79.831 Y99.53 E.01178
G1 X101.78 Y77.581 E.96025
G1 X101.532 Y77.293 E.01178
G1 X79.543 Y99.282 E.96199
G1 X79.268 Y99.019 E.01175
G1 X101.269 Y77.018 E.96254
G1 X101.007 Y76.743 E.01175
G1 X78.993 Y98.757 E.9631
G1 X78.731 Y98.483 E.01174
G1 X100.733 Y76.481 E.96254
G1 X100.458 Y76.219 E.01175
G1 X78.469 Y98.208 E.96199
G1 X78.22 Y97.92 E.01178
G1 X100.17 Y75.97 E.96026
G1 X99.881 Y75.722 E.01178
G1 X77.972 Y97.631 E.95851
G3 X77.736 Y97.33 I3.028 J-2.611 E.01184
G1 X99.58 Y75.486 E.95564
G1 X99.278 Y75.251 E.01183
G1 X77.501 Y97.028 E.95274
G3 X77.279 Y96.714 I3.13 J-2.443 E.01192
G1 X98.964 Y75.029 E.94868
G1 X98.648 Y74.807 E.01192
G1 X77.057 Y96.398 E.9446
G1 X76.849 Y96.07 E.01203
G1 X98.32 Y74.599 E.93935
G2 X97.991 Y74.391 I-2.207 J3.127 E.01204
G1 X76.641 Y95.741 E.93405
G1 X76.447 Y95.398 E.01219
G1 X97.648 Y74.197 E.92755
G2 X97.304 Y74.004 I-2.149 J3.435 E.01221
G1 X76.254 Y95.054 E.92092
G1 X76.074 Y94.697 E.01237
G1 X96.947 Y73.824 E.91316
G2 X96.587 Y73.647 I-1.96 J3.531 E.01241
G1 X75.897 Y94.337 E.90516
G1 X75.732 Y93.965 E.01259
G1 X96.215 Y73.482 E.89608
G2 X95.838 Y73.322 I-1.828 J3.78 E.01267
G1 X75.572 Y93.588 E.8866
G1 X75.423 Y93.2 E.01285
G1 X95.451 Y73.173 E.87618
G2 X95.056 Y73.031 I-1.685 J4.065 E.01299
G1 X75.281 Y92.806 E.86512
G1 X75.147 Y92.402 E.01314
G1 X94.652 Y72.897 E.85333
G2 X94.238 Y72.775 I-1.418 J4.051 E.01338
G1 X75.025 Y91.988 E.84052
G1 X74.909 Y91.567 E.0135
G1 X93.817 Y72.659 E.82721
G2 X93.38 Y72.559 I-1.223 J4.35 E.01388
G1 X74.809 Y91.13 E.81245
G3 X74.715 Y90.687 I4.453 J-1.177 E.01401
G1 X92.937 Y72.465 E.79719
G1 X92.479 Y72.386 E.01437
G1 X74.636 Y90.229 E.78063
G3 X74.568 Y89.76 I4.897 J-.948 E.01467
G1 X92.01 Y72.318 E.76308
G1 X91.533 Y72.259 E.01488
G1 X74.509 Y89.283 E.74479
G3 X74.472 Y88.783 I4.86 J-.611 E.01551
G1 X91.036 Y72.218 E.72469
G1 X90.657 Y72.188 E.01178
G1 X90.563 Y72.155 E.00307
G1 X74.446 Y88.272 E.7051
G1 X74.433 Y87.748 E.01622
G1 X90.223 Y71.958 E.69078
G1 X90.183 Y71.929 E.00152
G1 X90.01 Y71.634 E.01057
G1 X74.447 Y87.197 E.68085
G3 X74.478 Y86.629 I5.888 J.039 E.01761
G1 X88.879 Y72.228 E.63004
G2 X88.29 Y72.281 I.235 J5.928 E.01833
G1 X74.531 Y86.04 E.60193
G3 X74.609 Y85.424 I6.501 J.517 E.0192
G1 X87.674 Y72.359 E.57157
G1 X87.025 Y72.472 E.02038
G1 X74.722 Y84.775 E.53826
G3 X74.872 Y84.087 I7.082 J1.193 E.02179
G1 X86.337 Y72.622 E.50157
G2 X85.604 Y72.819 I1.619 J7.507 E.0235
G1 X75.069 Y83.354 E.46088
G3 X75.325 Y82.561 I7.987 J2.143 E.0258
G1 X84.811 Y73.075 E.41497
G2 X83.931 Y73.418 I8.991 J24.395 E.02919
G1 X75.668 Y81.681 E.36153
G3 X76.14 Y80.672 I10.386 J4.246 E.03449
G1 X82.922 Y73.89 E.29671
G2 X81.671 Y74.604 I7.07 J13.838 E.04457
G1 X76.854 Y79.421 E.21075
G3 X78.937 Y76.802 I13.34 J8.469 E.10371
G1 X80.634 Y75.105 E.07426
; CHANGE_LAYER
; Z_HEIGHT: 4.6
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F9482.917
G1 X79.22 Y76.519 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 23/25
; update layer progress
M73 L23
M991 S0 P22 ;notify layer change
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z4.8 I-1.112 J.494 P1  F42000
G1 X93.771 Y109.312 Z4.8
G1 Z4.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X93.119 Y109.424 E.02192
G3 X111.494 Y83.573 I-3.115 J-21.67 E3.38628
G3 X111.897 Y87.79 I-21.758 J4.207 E.14074
G3 X94.177 Y109.245 I-21.893 J-.036 E1.00025
G1 X93.83 Y109.302 E.01167
M204 S250
G1 X93.836 Y109.699 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
M73 P89 R2
G1 F9547.299
M204 S5000
G1 X93.168 Y109.813 E.02083
G3 X111.88 Y83.507 I-3.164 J-22.059 E3.1929
G3 X112.289 Y87.8 I-22.137 J4.273 E.13272
G3 X94.244 Y109.632 I-22.284 J-.046 E.94309
G1 X93.895 Y109.689 E.01086
; WIPE_START
M204 S6000
G1 X93.168 Y109.813 E-.28039
G1 X92.08 Y109.941 E-.41622
G1 X91.913 Y109.952 E-.06339
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.034 Y106.351 Z5 F42000
G1 Z4.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X90.014 Y106.348 E.00067
G3 X77.497 Y73.976 I-.017 J-18.599 E1.48408
G1 X78.188 Y73.38 E.03028
G3 X90.926 Y106.324 I11.809 J14.369 E2.33176
G1 X90.094 Y106.35 E.02762
M204 S250
G1 X90.032 Y105.959 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X89.977 Y105.959 E.00168
G1 X89.891 Y105.957 E.00266
G1 X89.804 Y105.955 E.00266
G1 X89.718 Y105.953 E.00266
G1 X89.631 Y105.951 E.00266
G1 X89.544 Y105.949 E.00266
G1 X89.458 Y105.946 E.00266
G1 X89.371 Y105.944 E.00266
G1 X89.285 Y105.942 E.00266
G1 X89.198 Y105.94 E.00266
G3 X77.768 Y74.261 I.808 J-18.193 E1.32074
G3 X89.189 Y69.56 I12.256 J13.556 E.38711
G1 X89.275 Y69.558 E.00266
G1 X89.362 Y69.556 E.00266
G1 X89.448 Y69.554 E.00266
G1 X89.535 Y69.552 E.00266
G1 X89.622 Y69.549 E.00266
G1 X89.708 Y69.547 E.00266
G1 X89.795 Y69.545 E.00266
G1 X89.881 Y69.543 E.00266
G1 X89.968 Y69.541 E.00266
G1 X90.023 Y69.541 E.00168
G1 X90.109 Y69.543 E.00266
G1 X90.196 Y69.545 E.00266
G1 X90.282 Y69.547 E.00266
G1 X90.369 Y69.549 E.00266
G1 X90.456 Y69.551 E.00266
G1 X90.542 Y69.554 E.00266
G1 X90.629 Y69.556 E.00266
G1 X90.715 Y69.558 E.00266
G1 X90.802 Y69.56 E.00266
G3 X90.811 Y105.94 I-.8 J18.19 E1.70812
G1 X90.725 Y105.942 E.00266
G1 X90.638 Y105.944 E.00266
G1 X90.551 Y105.946 E.00266
G1 X90.465 Y105.948 E.00266
G1 X90.378 Y105.951 E.00266
G1 X90.292 Y105.953 E.00266
G1 X90.205 Y105.955 E.00266
G1 X90.119 Y105.957 E.00266
G1 X90.092 Y105.958 E.00082
; WIPE_START
M204 S6000
G1 X89.977 Y105.959 E-.04355
G1 X89.891 Y105.957 E-.03292
G1 X89.804 Y105.955 E-.03291
G1 X89.718 Y105.953 E-.03292
G1 X89.631 Y105.951 E-.03292
G1 X89.544 Y105.949 E-.03291
G1 X89.458 Y105.946 E-.03292
G1 X89.371 Y105.944 E-.03292
G1 X89.285 Y105.942 E-.03291
G1 X89.198 Y105.94 E-.03292
G1 X88.22 Y105.872 E-.37255
G1 X88.095 Y105.857 E-.04765
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z5 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z5
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z5 F4000
            G39.3 S1
            G0 Z5 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X89.933 Y109.254 F42000
G1 Z4.6
G1 E.8 F1800
; FEATURE: Internal solid infill
G1 F9547.299
M204 S6000
G2 X88.879 Y109.225 I.064 J-21.502 E4.11875
G1 X89.873 Y109.252 E.03057
M204 S10000
G1 X89.943 Y108.877 F42000
G1 F9547.299
M204 S6000
G2 X88.907 Y108.849 I.054 J-21.125 E4.04652
G1 X89.883 Y108.875 E.03
M204 S10000
G1 X89.952 Y108.5 F42000
G1 F9547.299
M204 S6000
G2 X88.934 Y108.473 I.045 J-20.748 E3.97432
G1 X89.892 Y108.498 E.02943
M204 S10000
G1 X89.96 Y108.155 F42000
; LINE_WIDTH: 0.355531
G1 F11515.942
M204 S6000
G2 X88.96 Y108.129 I.039 J-20.403 E3.24019
G1 X89.9 Y108.154 E.02397
M204 S10000
G1 X90.032 Y107.843 F42000
; LINE_WIDTH: 0.355521
G1 F11516.304
M204 S6000
G3 X91.017 Y107.817 I-.036 J-20.091 E3.19041
G1 X90.092 Y107.841 E.02358
M204 S10000
G1 X90.023 Y107.498 F42000
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S6000
G3 X90.992 Y107.473 I-.029 J-19.746 E3.78237
G1 X90.083 Y107.496 E.02793
M204 S10000
G1 X90.014 Y107.121 F42000
G1 F9547.299
M204 S6000
G3 X90.964 Y107.097 I-.02 J-19.369 E3.71015
G1 X90.074 Y107.12 E.02736
M204 S10000
G1 X90.005 Y106.744 F42000
G1 F9547.299
M204 S6000
G3 X90.937 Y106.721 I-.011 J-18.992 E3.638
G1 X90.065 Y106.743 E.0268
; WIPE_START
G1 X90.937 Y106.721 E-.33141
G1 X91.866 Y106.652 E-.35414
G1 X92.06 Y106.628 E-.07445
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.088 Y100.111 Z5 F42000
G1 X75.988 Y80.26 Z5
G1 Z4.6
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X76.172 Y79.925 E.01269
G3 X105.888 Y87.358 I13.83 J7.825 E1.37156
G1 X105.888 Y88.142 E.02599
G3 X75.811 Y80.599 I-15.886 J-.392 E1.889
G1 X75.96 Y80.313 E.0107
M204 S250
G1 X75.642 Y80.075 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X75.831 Y79.731 E.01205
G3 X106.28 Y87.349 I14.172 J8.019 E1.30183
G1 X106.28 Y88.151 E.02467
G3 X75.461 Y80.423 I-16.278 J-.401 E1.79297
G1 X75.614 Y80.128 E.0102
; WIPE_START
M204 S6000
G1 X75.831 Y79.731 E-.17179
G1 X76.247 Y79.028 E-.31072
G1 X76.653 Y78.421 E-.27749
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X76.939 Y86.048 Z5 F42000
G1 X77.355 Y97.116 Z5
G1 Z4.6
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42255
G1 F9482.917
M204 S6000
G1 X79.052 Y98.813 E.07424
G2 X81.671 Y100.896 I11.088 J-11.257 E.10372
G1 X76.854 Y96.079 E.21075
G3 X76.14 Y94.828 I13.135 J-8.327 E.04457
G1 X82.922 Y101.61 E.29671
G2 X83.931 Y102.082 I5.255 J-9.914 E.03449
G1 X75.668 Y93.819 E.36153
G3 X75.325 Y92.939 I24.021 J-9.858 E.02919
G1 X84.811 Y102.425 E.41497
G2 X85.604 Y102.681 I2.936 J-7.731 E.0258
G1 X75.069 Y92.146 E.46088
G3 X74.873 Y91.413 I7.318 J-2.354 E.0235
G1 X86.337 Y102.878 E.50157
G2 X87.025 Y103.028 I1.878 J-6.919 E.02179
G1 X74.722 Y90.725 E.53826
G1 X74.609 Y90.076 E.02038
G1 X87.674 Y103.141 E.57157
G2 X88.29 Y103.219 I1.134 J-6.435 E.0192
G1 X74.531 Y89.46 E.60193
G3 X74.478 Y88.871 I5.778 J-.813 E.01832
G1 X88.879 Y103.272 E.63002
G2 X89.447 Y103.303 I.607 J-5.85 E.01761
G1 X74.447 Y88.303 E.65624
M73 P90 R2
G1 X74.433 Y87.752 E.01703
G1 X89.998 Y103.317 E.68092
G1 X90.522 Y103.304 E.01622
G1 X74.446 Y87.228 E.70329
G3 X74.472 Y86.717 I5.294 J.009 E.01584
G1 X91.033 Y103.278 E.72453
G2 X91.533 Y103.241 I-.111 J-4.899 E.01551
G1 X74.509 Y86.217 E.74479
G1 X74.568 Y85.74 E.01489
G1 X92.01 Y103.182 E.76308
G2 X92.479 Y103.114 I-.478 J-4.963 E.01467
G1 X74.636 Y85.271 E.78063
G1 X74.715 Y84.813 E.01437
G1 X92.937 Y103.035 E.79719
G2 X93.38 Y102.941 I-.737 J-4.557 E.01401
G1 X74.809 Y84.37 E.81245
G3 X74.909 Y83.933 I4.468 J.79 E.01388
G1 X93.817 Y102.841 E.82721
G1 X94.238 Y102.725 E.0135
G1 X75.025 Y83.512 E.84052
G3 X75.147 Y83.098 I4.174 J1.003 E.01338
G1 X94.652 Y102.603 E.85333
G1 X95.056 Y102.469 E.01314
G1 X75.281 Y82.694 E.86512
G3 X75.423 Y82.3 I4.203 J1.289 E.01299
G1 X95.451 Y102.327 E.87618
G1 X95.838 Y102.178 E.01285
G1 X75.572 Y81.912 E.8866
G3 X75.732 Y81.535 I3.94 J1.451 E.01267
G1 X96.215 Y102.018 E.89608
G1 X96.587 Y101.853 E.01259
G1 X75.897 Y81.163 E.90516
G3 X76.074 Y80.803 I3.702 J1.597 E.01241
G1 X96.947 Y101.676 E.91316
G1 X97.304 Y101.496 E.01237
G1 X76.254 Y80.446 E.92092
G3 X76.447 Y80.102 I3.636 J1.809 E.01221
G1 X97.648 Y101.303 E.92755
G1 X97.991 Y101.109 E.01219
G1 X76.641 Y79.759 E.93405
G3 X76.849 Y79.43 I3.356 J1.89 E.01204
G1 X98.32 Y100.901 E.93935
G1 X98.648 Y100.693 E.01203
G1 X77.057 Y79.102 E.9446
G1 X77.279 Y78.786 E.01192
G1 X98.964 Y100.471 E.94869
G2 X99.278 Y100.249 I-2.091 J-3.299 E.01192
G1 X77.501 Y78.472 E.95274
G1 X77.736 Y78.17 E.01183
G1 X99.58 Y100.014 E.95564
G2 X99.881 Y99.778 I-2.266 J-3.207 E.01184
G1 X77.972 Y77.869 E.95851
G1 X78.22 Y77.58 E.01178
G1 X100.17 Y99.53 E.96026
G1 X100.458 Y99.281 E.01178
G1 X78.469 Y77.292 E.96199
G1 X78.731 Y77.017 E.01175
G1 X100.733 Y99.019 E.96254
G1 X101.007 Y98.757 E.01174
G1 X78.993 Y76.743 E.9631
G1 X79.268 Y76.481 E.01175
G1 X101.269 Y98.482 E.96254
G1 X101.532 Y98.207 E.01175
G1 X79.543 Y76.218 E.96199
G1 X79.831 Y75.97 E.01178
G1 X101.78 Y97.919 E.96025
G1 X102.029 Y97.631 E.01178
G1 X80.119 Y75.721 E.95851
M73 P90 R1
G3 X80.421 Y75.486 I2.593 J3.005 E.01184
G1 X102.264 Y97.329 E.95563
G1 X102.5 Y97.028 E.01183
G1 X80.722 Y75.25 E.95274
G3 X81.037 Y75.028 I2.392 J3.058 E.01192
G1 X102.722 Y96.713 E.94868
G1 X102.943 Y96.398 E.01192
G1 X81.352 Y74.807 E.94459
G1 X81.681 Y74.598 E.01203
G1 X103.152 Y96.069 E.93934
G2 X103.36 Y95.74 I-3.158 J-2.225 E.01204
G1 X82.01 Y74.39 E.93404
G1 X82.352 Y74.196 E.01219
G1 X103.554 Y95.398 E.92753
G2 X103.746 Y95.053 I-3.449 J-2.156 E.01221
G1 X82.697 Y74.004 E.9209
G1 X83.054 Y73.824 E.01237
G1 X103.926 Y94.696 E.91314
G2 X104.103 Y94.336 I-3.527 J-1.958 E.01241
G1 X83.414 Y73.647 E.90514
G1 X83.786 Y73.482 E.01259
G1 X104.268 Y93.964 E.89607
G2 X104.428 Y93.587 I-3.772 J-1.824 E.01267
G1 X84.163 Y73.322 E.88658
G1 X84.55 Y73.173 E.01285
G1 X104.577 Y93.2 E.87616
G2 X104.719 Y92.805 I-4.064 J-1.684 E.01299
G1 X84.945 Y73.031 E.8651
G1 X85.348 Y72.897 E.01314
G1 X104.853 Y92.402 E.85331
G2 X104.975 Y91.987 I-4.05 J-1.417 E.01338
G1 X85.763 Y72.775 E.8405
G1 X86.184 Y72.659 E.0135
G1 X105.091 Y91.566 E.82719
G2 X105.191 Y91.129 I-4.374 J-1.228 E.01388
G1 X86.621 Y72.559 E.81243
G3 X87.064 Y72.465 I1.177 J4.455 E.01401
G1 X105.285 Y90.686 E.79717
G1 X105.364 Y90.229 E.01437
G1 X87.521 Y72.386 E.7806
G3 X87.99 Y72.318 I.947 J4.893 E.01467
G1 X105.432 Y89.76 E.76305
G1 X105.491 Y89.282 E.01489
G1 X88.468 Y72.259 E.74476
G3 X88.968 Y72.222 I.613 J4.898 E.01552
G1 X105.528 Y88.782 E.7245
G2 X105.554 Y88.271 I-5.27 J-.52 E.01584
G1 X89.479 Y72.196 E.70325
G1 X90.003 Y72.183 E.01622
G1 X105.567 Y87.747 E.68088
G1 X105.553 Y87.196 E.01703
G1 X90.554 Y72.197 E.6562
G3 X91.122 Y72.228 I-.04 J5.886 E.01761
G1 X105.522 Y86.628 E.62997
G2 X105.469 Y86.039 I-5.834 J.224 E.01832
G1 X91.711 Y72.281 E.60188
M73 P91 R1
G3 X92.327 Y72.36 I-.521 J6.525 E.0192
G1 X105.39 Y85.423 E.57151
G1 X105.278 Y84.774 E.02038
G1 X92.976 Y72.472 E.5382
G3 X93.664 Y72.623 I-1.191 J7.069 E.02179
G1 X105.127 Y84.086 E.50151
G2 X104.931 Y83.353 I-7.512 J1.621 E.0235
G1 X94.397 Y72.819 E.46081
G3 X95.191 Y73.076 I-2.144 J7.99 E.0258
G1 X104.674 Y82.559 E.41489
G2 X104.332 Y81.68 I-24.386 J8.992 E.0292
G1 X96.07 Y73.418 E.36143
G3 X97.08 Y73.891 I-4.247 J10.386 E.0345
G1 X103.859 Y80.67 E.29659
G2 X103.144 Y79.419 I-13.843 J7.075 E.0446
G1 X98.331 Y74.606 E.21058
G3 X100.454 Y76.215 I-8.122 J12.916 E.08253
G3 X102.643 Y78.381 I-44.724 J47.403 E.09527
; CHANGE_LAYER
; Z_HEIGHT: 4.8
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F9482.917
G1 X101.229 Y76.967 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 24/25
; update layer progress
M73 L24
M991 S0 P23 ;notify layer change
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z5 I-1.185 J-.276 P1  F42000
G1 X93.739 Y109.173 Z5
G1 Z4.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X93.102 Y109.285 E.02148
G3 X110.843 Y81.523 I-3.098 J-21.53 E3.29346
G3 X111.73 Y86.722 I-21.838 J6.404 E.17535
G3 X94.154 Y109.107 I-21.727 J1.034 E1.02913
G1 X93.799 Y109.164 E.01195
M204 S250
G1 X93.805 Y109.56 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X93.15 Y109.674 E.02043
G3 X111.221 Y81.418 I-3.146 J-21.919 E3.10574
G3 X112.122 Y86.712 I-22.231 J6.51 E.16538
G3 X94.221 Y109.493 I-22.119 J1.044 E.97044
G1 X93.864 Y109.55 E.01111
; WIPE_START
M204 S6000
G1 X93.15 Y109.674 E-.2755
G1 X92.07 Y109.799 E-.41311
G1 X91.882 Y109.812 E-.0714
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.035 Y106.351 Z5.2 F42000
G1 Z4.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X90.014 Y106.347 E.00069
G3 X82.895 Y70.558 I-.012 J-18.6 E1.6968
G1 X83.72 Y70.24 E.02932
G3 X90.926 Y106.324 I6.283 J17.507 E2.12021
G1 X90.095 Y106.35 E.0276
M204 S250
G1 X90.025 Y105.959 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X90.005 Y105.955 E.00064
G3 X83.036 Y70.924 I-.001 J-18.208 E1.53799
G1 X83.865 Y70.604 E.0273
G3 X90.898 Y105.933 I6.138 J17.142 E1.92252
G1 X90.085 Y105.958 E.02498
; WIPE_START
M204 S6000
G1 X90.005 Y105.955 E-.03052
G1 X89.111 Y105.938 E-.33948
G1 X88.22 Y105.872 E-.33969
G1 X88.088 Y105.856 E-.05031
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z5.2 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z5.2
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z5.2 F4000
            G39.3 S1
            G0 Z5.2 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X89.936 Y109.112 F42000
G1 Z4.8
G1 E.8 F1800
; FEATURE: Internal solid infill
G1 F9547.299
M204 S6000
G2 X88.889 Y109.083 I.064 J-21.36 E4.09152
G1 X89.876 Y109.11 E.03034
M204 S10000
G1 X89.946 Y108.735 F42000
G1 F9547.299
M204 S6000
G2 X88.917 Y108.707 I.055 J-20.983 E4.01931
G1 X89.886 Y108.733 E.02977
M204 S10000
G1 X89.955 Y108.358 F42000
G1 F9547.299
M204 S6000
G2 X88.945 Y108.331 I.046 J-20.606 E3.94712
G1 X89.895 Y108.356 E.0292
M204 S10000
G1 X89.966 Y107.928 F42000
; LINE_WIDTH: 0.525923
G1 F7453.372
M204 S6000
G2 X88.977 Y107.902 I.038 J-20.176 E4.9505
G1 X89.906 Y107.926 E.03658
M204 S10000
G1 X90.023 Y107.498 F42000
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S6000
G3 X90.992 Y107.473 I-.029 J-19.746 E3.78235
G1 X90.083 Y107.496 E.02793
M204 S10000
G1 X90.014 Y107.121 F42000
G1 F9547.299
M204 S6000
G3 X90.964 Y107.097 I-.02 J-19.369 E3.71014
G1 X90.074 Y107.119 E.02737
M204 S10000
G1 X90.004 Y106.744 F42000
G1 F9547.299
M204 S6000
G3 X90.936 Y106.721 I-.011 J-18.992 E3.63799
G1 X90.064 Y106.743 E.0268
; WIPE_START
G1 X90.936 Y106.721 E-.33148
G1 X91.866 Y106.652 E-.35422
G1 X92.06 Y106.628 E-.0743
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X94.601 Y99.431 Z5.2 F42000
G1 X102.284 Y77.673 Z5.2
G1 Z4.8
G1 E.8 F1800
; FEATURE: Inner wall
; LINE_WIDTH: 0.44999
G1 F8843.689
M204 S6000
G1 X102.527 Y77.971 E.01276
G3 X105.888 Y87.358 I-12.525 J9.779 E.33642
G1 X105.888 Y88.142 E.02599
G3 X102.04 Y77.376 I-15.886 J-.392 E2.924
G1 X102.246 Y77.627 E.01076
M204 S250
G1 X102.587 Y77.425 F42000
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X102.837 Y77.73 E.01211
G3 X106.28 Y87.349 I-12.834 J10.02 E.31932
G1 X106.28 Y88.151 E.02467
G3 X102.337 Y77.12 I-16.278 J-.401 E2.77535
G1 X102.549 Y77.378 E.01027
; WIPE_START
M204 S6000
G1 X102.837 Y77.73 E-.17255
G1 X103.32 Y78.382 E-.30856
G1 X103.728 Y78.992 E-.27889
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.202 Y77.725 Z5.2 F42000
G1 X80.634 Y75.105 Z5.2
G1 Z4.8
G1 E.8 F1800
; FEATURE: Internal solid infill
; LINE_WIDTH: 0.42255
G1 F9482.917
M204 S6000
G1 X78.937 Y76.801 E.07423
M73 P92 R1
G2 X76.854 Y79.421 I11.258 J11.089 E.10374
G1 X81.671 Y74.604 E.21075
G3 X82.922 Y73.89 I8.324 J13.13 E.04457
G1 X76.14 Y80.672 E.29671
G2 X75.668 Y81.681 I9.91 J5.254 E.03449
G1 X83.931 Y73.418 E.36153
G3 X84.811 Y73.075 I9.86 J24.027 E.02919
G1 X75.325 Y82.561 E.41497
G2 X75.069 Y83.354 I7.733 J2.937 E.0258
G1 X85.604 Y72.819 E.46088
G3 X86.337 Y72.622 I2.351 J7.306 E.0235
G1 X74.873 Y84.087 E.50157
G2 X74.722 Y84.775 I6.93 J1.881 E.02179
G1 X87.025 Y72.472 E.53826
G1 X87.674 Y72.359 E.02038
G1 X74.609 Y85.424 E.57156
G2 X74.531 Y86.04 I6.433 J1.134 E.0192
G1 X88.29 Y72.281 E.60193
G3 X88.879 Y72.228 I.813 J5.777 E.01832
G1 X74.478 Y86.629 E.63002
G2 X74.447 Y87.197 I5.857 J.607 E.01761
G1 X89.447 Y72.197 E.65624
G1 X89.998 Y72.183 E.01703
G1 X74.433 Y87.748 E.68092
G1 X74.446 Y88.272 E.01622
G1 X90.522 Y72.196 E.70329
G3 X91.033 Y72.222 I-.009 J5.294 E.01584
G1 X74.472 Y88.783 E.72453
G2 X74.509 Y89.283 I4.895 J-.11 E.01551
G1 X91.533 Y72.259 E.74479
G1 X92.01 Y72.318 E.01489
G1 X74.568 Y89.76 E.76308
G2 X74.636 Y90.229 I4.963 J-.478 E.01467
G1 X92.479 Y72.386 E.78063
G1 X92.937 Y72.465 E.01437
G1 X74.715 Y90.687 E.79719
G2 X74.809 Y91.13 I4.546 J-.734 E.01401
G1 X93.38 Y72.559 E.81245
G3 X93.817 Y72.659 I-.79 J4.469 E.01388
G1 X74.909 Y91.567 E.82721
G1 X75.025 Y91.988 E.0135
G1 X94.238 Y72.775 E.84052
G3 X94.652 Y72.897 I-1.002 J4.171 E.01338
G1 X75.147 Y92.402 E.85333
G1 X75.281 Y92.806 E.01314
G1 X95.056 Y73.031 E.86512
G3 X95.451 Y73.173 I-1.288 J4.202 E.01299
G1 X75.423 Y93.2 E.87618
G1 X75.572 Y93.588 E.01285
G1 X95.838 Y73.322 E.8866
G3 X96.215 Y73.482 I-1.45 J3.94 E.01267
G1 X75.732 Y93.965 E.89608
G1 X75.897 Y94.337 E.01259
G1 X96.587 Y73.647 E.90516
G3 X96.947 Y73.824 I-1.602 J3.712 E.01241
G1 X76.074 Y94.697 E.91316
G1 X76.254 Y95.054 E.01237
G1 X97.304 Y74.004 E.92091
G3 X97.648 Y74.197 I-1.808 J3.634 E.01221
G1 X76.447 Y95.398 E.92754
G1 X76.641 Y95.741 E.01219
G1 X97.991 Y74.391 E.93405
G3 X98.32 Y74.599 I-1.864 J3.314 E.01204
G1 X76.849 Y96.07 E.93935
G1 X77.057 Y96.398 E.01203
G1 X98.648 Y74.807 E.9446
G1 X98.964 Y75.029 E.01192
G1 X77.279 Y96.714 E.94868
G2 X77.501 Y97.028 I3.245 J-2.053 E.01192
G1 X99.278 Y75.251 E.95274
G1 X99.58 Y75.486 E.01183
G1 X77.736 Y97.33 E.95564
G2 X77.972 Y97.631 I3.197 J-2.257 E.01184
G1 X99.881 Y75.722 E.95851
G1 X100.17 Y75.97 E.01178
G1 X78.22 Y97.92 E.96026
G1 X78.469 Y98.208 E.01178
G1 X100.458 Y76.219 E.96199
G1 X100.733 Y76.481 E.01175
G1 X78.731 Y98.483 E.96254
G1 X78.993 Y98.757 E.01174
G1 X101.007 Y76.743 E.9631
G1 X101.269 Y77.018 E.01175
G1 X79.268 Y99.019 E.96254
G1 X79.543 Y99.282 E.01175
G1 X101.532 Y77.293 E.96199
G1 X101.78 Y77.581 E.01178
G1 X79.831 Y99.53 E.96025
G1 X80.119 Y99.779 E.01178
G1 X102.029 Y77.869 E.95851
G3 X102.264 Y78.171 I-3.079 J2.65 E.01184
G1 X80.421 Y100.014 E.95563
G1 X80.722 Y100.25 E.01183
G1 X102.5 Y78.472 E.95274
G3 X102.722 Y78.787 I-3.134 J2.446 E.01192
G1 X81.037 Y100.472 E.94868
G1 X81.352 Y100.693 E.01192
G1 X102.943 Y79.102 E.94459
G1 X103.152 Y79.431 E.01203
G1 X81.681 Y100.902 E.93934
G2 X82.01 Y101.11 I2.225 J-3.158 E.01204
G1 X103.36 Y79.76 E.93404
G1 X103.554 Y80.102 E.01219
G1 X82.352 Y101.304 E.92753
G2 X82.697 Y101.496 I2.146 J-3.432 E.01221
G1 X103.746 Y80.447 E.9209
G1 X103.926 Y80.804 E.01237
G1 X83.054 Y101.676 E.91314
G2 X83.414 Y101.853 I1.961 J-3.533 E.01241
G1 X104.103 Y81.164 E.90514
G1 X104.268 Y81.536 E.01259
G1 X83.786 Y102.018 E.89607
M73 P93 R1
G2 X84.163 Y102.178 I1.829 J-3.785 E.01267
G1 X104.428 Y81.913 E.88658
G1 X104.577 Y82.3 E.01285
G1 X84.55 Y102.327 E.87616
G2 X84.945 Y102.469 I1.684 J-4.064 E.01299
G1 X104.719 Y82.695 E.8651
G1 X104.853 Y83.098 E.01314
G1 X85.348 Y102.603 E.85331
G2 X85.763 Y102.725 I1.418 J-4.052 E.01338
G1 X104.975 Y83.513 E.8405
G1 X105.091 Y83.934 E.0135
G1 X86.184 Y102.841 E.82719
G2 X86.621 Y102.941 I1.228 J-4.374 E.01388
G1 X105.191 Y84.371 E.81243
G3 X105.285 Y84.814 I-4.445 J1.175 E.01401
G1 X87.064 Y103.035 E.79717
G1 X87.521 Y103.114 E.01437
G1 X105.364 Y85.271 E.7806
G3 X105.432 Y85.74 I-4.898 J.948 E.01467
G1 X87.99 Y103.182 E.76305
G1 X88.468 Y103.241 E.01489
G1 X105.491 Y86.218 E.74476
G3 X105.528 Y86.718 I-4.88 J.612 E.01552
G1 X88.968 Y103.278 E.7245
G2 X89.479 Y103.304 I.52 J-5.269 E.01584
G1 X105.554 Y87.229 E.70325
G1 X105.567 Y87.753 E.01622
G1 X90.003 Y103.317 E.68088
G1 X90.554 Y103.303 E.01703
G1 X105.553 Y88.304 E.6562
G3 X105.522 Y88.872 I-5.883 J-.039 E.01761
G1 X91.122 Y103.272 E.62997
G2 X91.711 Y103.219 I-.224 J-5.831 E.01832
G1 X105.469 Y89.461 E.60188
G3 X105.39 Y90.077 I-6.491 J-.517 E.0192
G1 X92.327 Y103.14 E.57151
G1 X92.976 Y103.028 E.02038
G1 X105.278 Y90.726 E.5382
G3 X105.127 Y91.414 I-7.077 J-1.192 E.02179
G1 X93.664 Y102.877 E.50151
G2 X94.397 Y102.681 I-1.622 J-7.515 E.0235
G1 X104.931 Y92.147 E.46081
G3 X104.674 Y92.941 I-7.988 J-2.144 E.0258
G1 X95.191 Y102.424 E.41489
G2 X96.07 Y102.082 I-9 J-24.407 E.0292
G1 X104.332 Y93.82 E.36143
G3 X103.859 Y94.83 I-10.383 J-4.245 E.0345
G1 X97.08 Y101.609 E.29659
G2 X98.331 Y100.894 I-7.075 J-13.843 E.0446
G1 X103.144 Y96.081 E.21058
G3 X101.535 Y98.204 I-12.916 J-8.122 E.08253
G3 X99.369 Y100.393 I-47.366 J-44.687 E.09527
; CHANGE_LAYER
; Z_HEIGHT: 5
; LAYER_HEIGHT: 0.2
; WIPE_START
G1 F9482.917
G1 X100.783 Y98.979 E-.76
; WIPE_END
G1 E-.04 F1800
; layer num/total_layer_count: 25/25
; update layer progress
M73 L25
M991 S0 P24 ;notify layer change
M106 S188.7
; OBJECT_ID: 19785
M204 S10000
G17
G3 Z5.2 I-.998 J-.696 P1  F42000
G1 X93.721 Y109.107 Z5.2
G1 Z5
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X93.092 Y109.218 E.01961
G3 X111.285 Y83.607 I-3.088 J-21.46 E3.10627
G3 X111.686 Y87.794 I-21.624 J4.183 E.12942
G3 X94.144 Y109.04 I-21.681 J-.037 E.91736
G1 X93.78 Y109.097 E.01131
; WIPE_START
M204 S6000
G1 X93.092 Y109.218 E-.26531
G1 X92.036 Y109.338 E-.404
G1 X91.798 Y109.355 E-.09069
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.025 Y105.959 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F9547.299
M204 S5000
G1 X90.005 Y105.956 E.00065
G3 X77.768 Y74.261 I-.007 J-18.207 E1.34571
G1 X77.771 Y74.257 E.00014
G1 X78.444 Y73.677 E.02732
G3 X90.898 Y105.933 I11.553 J14.072 E2.11441
G1 X90.085 Y105.958 E.02498
; WIPE_START
M204 S6000
G1 X90.005 Y105.956 E-.03066
G1 X89.111 Y105.938 E-.33946
G1 X88.22 Y105.872 E-.33967
G1 X88.089 Y105.856 E-.0502
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z5.4 I1.217 J0 P1  F42000
;===================== date: 20250206 =====================

; don't support timelapse gcode in spiral_mode and by object sequence for I3 structure printer
; SKIPPABLE_START
; SKIPTYPE: timelapse
M622.1 S1 ; for prev firmware, default turned on
M1002 judge_flag timelapse_record_flag
M622 J1
G92 E0
G1 Z5.4
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos
M400
M1004 S5 P1  ; external shutter
M400 P300
M971 S11 C11 O0
G92 E0
G1 X0 F18000
M623

; SKIPTYPE: head_wrap_detect
M622.1 S1
M1002 judge_flag g39_3rd_layer_detect_flag
M622 J1
    ; enable nozzle clog detect at 3rd layer
    


    M622.1 S1
    M1002 judge_flag g39_detection_flag
    M622 J1
      
        M622.1 S0
        M1002 judge_flag g39_mass_exceed_flag
        M622 J1
        
            G392 S0
            M400
            G90
            M83
            M204 S5000
            G0 Z5.4 F4000
            G39.3 S1
            G0 Z5.4 F4000
            G392 S0
          
        M623
    
    M623
M623
; SKIPPABLE_END




G1 X102.674 Y70.412 F42000
G1 Z5
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.42
G1 F9547.055
M204 S2000
G1 X107.338 Y75.076 E.20266
; WIPE_START
M204 S6000
G1 X105.924 Y73.662 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X108.401 Y76.673 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F9547.055
M204 S2000
G1 X101.077 Y69.349 E.31825
; WIPE_START
M204 S6000
G1 X102.492 Y70.763 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.878 Y68.682 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F9547.055
M204 S2000
G1 X109.068 Y77.872 E.39933
G1 X109.567 Y78.905
G1 X98.845 Y68.183 E.46593
G1 X97.918 Y67.789
G1 X109.961 Y79.832 E.52329
G1 X110.28 Y80.685
G1 X97.065 Y67.47 E.57425
G1 X96.27 Y67.208
G1 X110.542 Y81.48 E.62019
G1 X110.749 Y82.22
G1 X95.53 Y67.001 E.66136
M73 P94 R1
G1 X94.821 Y66.825
G1 X100.908 Y72.912 E.2645
; WIPE_START
M204 S6000
G1 X99.494 Y71.498 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.346 Y71.884 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F9547.055
M204 S2000
G1 X94.137 Y66.675 E.22636
G1 X93.492 Y66.562
G1 X98.188 Y71.258 E.20406
G1 X97.196 Y70.8
G1 X92.864 Y66.468 E.18827
G1 X92.256 Y66.393
G1 X96.314 Y70.451 E.17635
G1 X95.509 Y70.179
G1 X91.673 Y66.344 E.16668
G1 X91.099 Y66.303
G1 X94.759 Y69.963 E.15906
G1 X94.053 Y69.789
G1 X90.547 Y66.284 E.15232
G1 X90.002 Y66.272
G1 X93.379 Y69.65 E.14675
G1 X92.734 Y69.538
G1 X89.481 Y66.285 E.14137
G1 X88.96 Y66.297
G1 X92.124 Y69.461 E.1375
G1 X91.532 Y69.401
G1 X88.463 Y66.333 E.13335
G1 X87.966 Y66.369
G1 X90.956 Y69.359 E.12991
G1 X90.407 Y69.343
G1 X87.488 Y66.425 E.12684
G1 X87.013 Y66.483
G1 X89.866 Y69.336 E.12397
G1 X89.346 Y69.349
G1 X86.552 Y66.555 E.12142
G1 X86.098 Y66.634
G1 X88.838 Y69.374 E.11909
G1 X88.341 Y69.411
G1 X85.65 Y66.72 E.11695
G1 X85.215 Y66.817
G1 X87.86 Y69.463 E.11497
G1 X87.385 Y69.521
G1 X84.779 Y66.915 E.11326
G1 X84.362 Y67.031
G1 X86.927 Y69.596 E.11149
G1 X86.473 Y69.675
G1 X83.944 Y67.147 E.10988
G1 X83.536 Y67.272
G1 X86.034 Y69.77 E.10857
G1 X85.599 Y69.868
G1 X83.135 Y67.404 E.10706
G1 X82.735 Y67.537
G1 X85.178 Y69.98 E.10616
G1 X84.761 Y70.096
G1 X82.35 Y67.686 E.10474
G1 X81.966 Y67.834
G1 X84.355 Y70.224 E.10385
G1 X83.954 Y70.356
G1 X81.589 Y67.991 E.1028
G1 X81.219 Y68.154
G1 X83.563 Y70.499 E.10187
G1 X83.179 Y70.647
G1 X80.85 Y68.318 E.1012
G1 X80.494 Y68.495
G1 X82.8 Y70.802 E.10023
G1 X82.431 Y70.966
G1 X80.139 Y68.674 E.09958
G1 X79.788 Y68.856
G1 X82.064 Y71.132 E.09889
G1 X81.709 Y71.31
G1 X79.447 Y69.049 E.09827
G1 X79.107 Y69.242
G1 X81.354 Y71.489 E.09764
G1 X81.012 Y71.68
G1 X78.774 Y69.443 E.09725
G1 X78.448 Y69.649
G1 X80.672 Y71.873 E.09665
G1 X80.34 Y72.074
G1 X78.121 Y69.856 E.0964
G1 X77.806 Y70.074
G1 X80.014 Y72.281 E.09592
G1 X79.69 Y72.492
G1 X77.493 Y70.294 E.09548
G1 X77.181 Y70.516
G1 X79.377 Y72.712 E.09542
G1 X79.064 Y72.932
G1 X76.882 Y70.749 E.09483
G1 X76.582 Y70.983
G1 X78.763 Y73.164 E.09477
G1 X78.464 Y73.398
G1 X76.287 Y71.221 E.0946
G1 X76.001 Y71.468
G1 X78.171 Y73.639 E.09432
G1 X77.885 Y73.885
G1 X75.714 Y71.715 E.09431
G1 X75.435 Y71.969
G1 X77.6 Y74.134 E.09408
G1 X77.327 Y74.394
G1 X75.162 Y72.229 E.09409
G1 X74.888 Y72.489
G1 X77.054 Y74.654 E.09409
G1 X76.79 Y74.923
G1 X74.625 Y72.758 E.09409
G1 X74.365 Y73.032
G1 X76.53 Y75.197 E.09408
G1 X76.274 Y75.474
G1 X74.105 Y73.305 E.09427
G1 X73.857 Y73.59
G1 X76.027 Y75.76 E.09431
G1 X75.78 Y76.047
G1 X73.61 Y73.876 E.09432
G1 X73.364 Y74.164
G1 X75.545 Y76.345 E.09477
G1 X75.311 Y76.645
G1 X73.131 Y74.464 E.09477
G1 X72.897 Y74.763
G1 X75.085 Y76.952 E.09509
G1 X74.865 Y77.265
G1 X72.668 Y75.068 E.09547
G1 X72.448 Y75.381
G1 X74.647 Y77.58 E.09559
G1 X74.441 Y77.907
G1 X72.227 Y75.694 E.09617
G1 X72.015 Y76.015
G1 X74.234 Y78.233 E.0964
G1 X74.039 Y78.571
G1 X71.809 Y76.341 E.09691
G1 X71.602 Y76.668
G1 X73.846 Y78.912 E.09751
G1 X73.661 Y79.26
G1 X71.407 Y77.006 E.09792
G1 X71.214 Y77.347
G1 X73.482 Y79.615 E.09854
G1 X73.307 Y79.973
G1 X71.024 Y77.69 E.09922
G1 X70.846 Y78.045
G1 X73.144 Y80.343 E.09986
G1 X72.98 Y80.713
G1 X70.667 Y78.399 E.10053
G1 X70.496 Y78.762
G1 X72.832 Y81.097 E.10149
G1 X72.683 Y81.482
G1 X70.333 Y79.131 E.10216
G1 X70.169 Y79.501
G1 X72.548 Y81.88 E.1034
G1 X72.416 Y82.281
G1 X70.019 Y79.884 E.10416
G1 X69.87 Y80.269
G1 X72.295 Y82.694 E.10536
G1 X72.179 Y83.111
G1 X69.728 Y80.66 E.10653
G1 X69.596 Y81.061
G1 X72.075 Y83.54 E.10772
G1 X71.977 Y83.976
G1 X69.464 Y81.462 E.10923
G1 X69.346 Y81.877
G1 X71.891 Y84.422 E.11059
G1 X71.812 Y84.877
G1 X69.23 Y82.295 E.11219
G1 X69.122 Y82.72
G1 X71.746 Y85.344 E.11401
G1 X71.687 Y85.819
G1 X69.024 Y83.156 E.11571
G1 X68.928 Y83.593
G1 X71.645 Y86.309 E.11805
G1 X71.608 Y86.806
G1 X68.849 Y84.047 E.11989
G1 X68.77 Y84.501
G1 X71.593 Y87.324 E.12268
G1 X71.585 Y87.849
G1 X68.707 Y84.972 E.12505
G1 X68.649 Y85.447
G1 X71.599 Y88.396 E.12818
G1 X71.628 Y88.959
G1 X68.603 Y85.934 E.13142
G1 X68.567 Y86.431
G1 X71.67 Y89.534 E.13486
G1 X71.744 Y90.141
G1 X68.541 Y86.938 E.13918
G1 X68.528 Y87.459
G1 X71.837 Y90.767 E.14379
G1 X71.953 Y91.417
G1 X68.527 Y87.991 E.1489
G1 X68.54 Y88.538
G1 X72.107 Y92.104 E.15499
G1 X72.303 Y92.833
G1 X68.569 Y89.099 E.16225
G1 X68.611 Y89.675
G1 X72.545 Y93.608 E.17093
G1 X72.848 Y94.445
G1 X68.676 Y90.273 E.18132
G1 X68.751 Y90.881
G1 X73.236 Y95.367 E.19493
G1 X73.745 Y96.409
G1 X68.862 Y91.525 E.21223
G1 X68.989 Y92.186
G1 X74.517 Y97.714 E.24023
; WIPE_START
M204 S6000
G1 X73.103 Y96.299 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X76.137 Y99.867 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F9547.055
M204 S2000
G1 X69.143 Y92.873 E.30394
; WIPE_START
M204 S6000
G1 X70.557 Y94.287 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X77.359 Y90.826 Z5.4 F42000
G1 X104.838 Y76.842 Z5.4
G1 Z5
G1 E.8 F1800
G1 F9547.055
M204 S2000
G1 X110.925 Y82.929 E.2645
G1 X111.075 Y83.613
G1 X105.866 Y78.404 E.22637
; WIPE_START
M204 S6000
G1 X107.28 Y79.818 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X106.492 Y79.562 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F9547.055
M204 S2000
G1 X111.188 Y84.258 E.20406
G1 X111.282 Y84.886
G1 X106.95 Y80.554 E.18827
G1 X107.299 Y81.436
G1 X111.357 Y85.494 E.17635
M73 P95 R1
G1 X111.407 Y86.078
G1 X107.571 Y82.241 E.16672
G1 X107.787 Y82.991
G1 X111.45 Y86.653 E.15916
G1 X111.466 Y87.203
G1 X107.961 Y83.697 E.15232
G1 X108.1 Y84.371
G1 X111.479 Y87.75 E.14683
G1 X111.466 Y88.27
G1 X108.212 Y85.016 E.14141
G1 X108.289 Y85.626
G1 X111.453 Y88.79 E.1375
G1 X111.417 Y89.287
G1 X108.349 Y86.218 E.13335
G1 X108.391 Y86.794
G1 X111.381 Y89.784 E.12992
G1 X111.325 Y90.262
G1 X108.407 Y87.344 E.12681
G1 X108.414 Y87.884
G1 X111.267 Y90.737 E.12398
G1 X111.195 Y91.198
G1 X108.401 Y88.404 E.12142
G1 X108.376 Y88.912
G1 X111.116 Y91.652 E.11909
G1 X111.03 Y92.1
G1 X108.339 Y89.409 E.11695
G1 X108.287 Y89.89
G1 X110.933 Y92.535 E.11497
G1 X110.835 Y92.971
G1 X108.229 Y90.365 E.11326
G1 X108.154 Y90.823
G1 X110.719 Y93.388 E.11149
G1 X110.603 Y93.806
G1 X108.075 Y91.277 E.10988
G1 X107.98 Y91.716
G1 X110.478 Y94.214 E.10857
G1 X110.346 Y94.615
G1 X107.882 Y92.151 E.10706
G1 X107.77 Y92.572
G1 X110.213 Y95.015 E.10616
G1 X110.064 Y95.4
G1 X107.654 Y92.989 E.10474
G1 X107.526 Y93.395
G1 X109.916 Y95.784 E.10385
G1 X109.759 Y96.161
G1 X107.394 Y93.796 E.10281
G1 X107.251 Y94.187
G1 X109.596 Y96.531 E.10187
G1 X109.432 Y96.9
G1 X107.103 Y94.571 E.1012
G1 X106.948 Y94.95
G1 X109.255 Y97.256 E.10023
G1 X109.076 Y97.611
G1 X106.784 Y95.319 E.09958
G1 X106.618 Y95.686
G1 X108.894 Y97.962 E.09889
G1 X108.701 Y98.303
G1 X106.44 Y96.041 E.09827
G1 X106.261 Y96.396
G1 X108.508 Y98.643 E.09764
G1 X108.308 Y98.976
G1 X106.07 Y96.738 E.09725
G1 X105.877 Y97.078
G1 X108.101 Y99.302 E.09665
G1 X107.894 Y99.629
G1 X105.676 Y97.41 E.0964
G1 X105.469 Y97.736
M73 P95 R0
G1 X107.676 Y99.944 E.09592
G1 X107.456 Y100.257
G1 X105.258 Y98.06 E.09548
G1 X105.038 Y98.373
G1 X107.234 Y100.569 E.09542
G1 X107.001 Y100.868
G1 X104.818 Y98.686 E.09483
G1 X104.586 Y98.987
G1 X106.767 Y101.168 E.09477
G1 X106.529 Y101.463
G1 X104.352 Y99.286 E.0946
G1 X104.112 Y99.579
G1 X106.282 Y101.749 E.09432
G1 X106.035 Y102.036
G1 X103.865 Y99.865 E.09431
G1 X103.616 Y100.15
G1 X105.781 Y102.315 E.09408
G1 X105.521 Y102.588
G1 X103.356 Y100.423 E.09409
G1 X103.096 Y100.696
G1 X105.261 Y102.862 E.09409
G1 X104.992 Y103.125
G1 X102.827 Y100.96 E.09409
G1 X102.553 Y101.22
G1 X104.718 Y103.385 E.09408
G1 X104.445 Y103.645
G1 X102.276 Y101.476 E.09427
G1 X101.99 Y101.723
G1 X104.16 Y103.893 E.09431
G1 X103.874 Y104.14
G1 X101.703 Y101.97 E.09432
G1 X101.405 Y102.205
G1 X103.586 Y104.386 E.09477
G1 X103.286 Y104.619
G1 X101.105 Y102.439 E.09477
G1 X100.798 Y102.665
G1 X102.987 Y104.853 E.09509
G1 X102.682 Y105.082
G1 X100.485 Y102.885 E.09547
G1 X100.17 Y103.103
G1 X102.369 Y105.302 E.09559
G1 X102.056 Y105.523
G1 X99.843 Y103.309 E.09617
G1 X99.517 Y103.516
G1 X101.735 Y105.735 E.0964
G1 X101.409 Y105.942
G1 X99.179 Y103.711 E.09691
G1 X98.838 Y103.904
G1 X101.082 Y106.148 E.09751
G1 X100.744 Y106.343
G1 X98.49 Y104.089 E.09792
G1 X98.135 Y104.268
G1 X100.403 Y106.536 E.09854
G1 X100.06 Y106.726
G1 X97.777 Y104.443 E.09922
G1 X97.407 Y104.606
G1 X99.705 Y106.904 E.09986
G1 X99.351 Y107.083
G1 X97.037 Y104.77 E.10053
G1 X96.653 Y104.918
G1 X98.988 Y107.254 E.1015
G1 X98.619 Y107.417
G1 X96.268 Y105.067 E.10216
G1 X95.87 Y105.202
G1 X98.249 Y107.581 E.1034
G1 X97.866 Y107.731
G1 X95.469 Y105.334 E.10416
G1 X95.056 Y105.455
G1 X97.481 Y107.88 E.10537
G1 X97.09 Y108.022
G1 X94.639 Y105.571 E.10653
G1 X94.21 Y105.675
G1 X96.689 Y108.154 E.10772
G1 X96.288 Y108.286
G1 X93.774 Y105.773 E.10923
G1 X93.328 Y105.859
G1 X95.873 Y108.404 E.11059
G1 X95.455 Y108.52
G1 X92.873 Y105.938 E.11219
G1 X92.406 Y106.004
G1 X95.03 Y108.628 E.11401
G1 X94.594 Y108.726
G1 X91.931 Y106.063 E.11571
G1 X91.441 Y106.105
G1 X94.157 Y108.822 E.11805
G1 X93.703 Y108.901
G1 X90.944 Y106.142 E.11989
G1 X90.426 Y106.157
G1 X93.249 Y108.98 E.12268
G1 X92.778 Y109.043
G1 X89.901 Y106.165 E.12505
G1 X89.354 Y106.151
G1 X92.303 Y109.101 E.12818
G1 X91.816 Y109.147
G1 X88.791 Y106.122 E.13143
G1 X88.216 Y106.08
G1 X91.319 Y109.183 E.13486
G1 X90.812 Y109.209
G1 X87.609 Y106.006 E.13918
G1 X86.983 Y105.913
G1 X90.291 Y109.222 E.14379
G1 X89.759 Y109.223
G1 X86.333 Y105.797 E.1489
G1 X85.646 Y105.643
G1 X89.212 Y109.21 E.15499
G1 X88.651 Y109.181
G1 X84.917 Y105.447 E.16225
G1 X84.142 Y105.205
G1 X88.075 Y109.139 E.17093
G1 X87.477 Y109.074
G1 X83.305 Y104.902 E.18132
G1 X82.383 Y104.514
G1 X86.869 Y108.999 E.19493
G1 X86.225 Y108.888
G1 X81.341 Y104.005 E.21223
; WIPE_START
M204 S6000
G1 X82.755 Y105.419 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X80.036 Y103.233 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F9547.055
M204 S2000
G1 X85.564 Y108.761 E.24023
G1 X84.877 Y108.607
G1 X77.883 Y101.613 E.30393
; WIPE_START
M204 S6000
G1 X79.297 Y103.027 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X84.146 Y108.41 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F9547.055
M204 S2000
G1 X69.34 Y93.604 E.64338
G1 X69.573 Y94.369
G1 X83.381 Y108.177 E.60002
G1 X82.569 Y107.899
G1 X69.851 Y95.181 E.55265
G1 X70.195 Y96.058
G1 X81.692 Y107.555 E.49961
G1 X80.725 Y107.121
G1 X70.629 Y97.025 E.43871
G1 X71.202 Y98.132
G1 X79.618 Y106.548 E.36569
; WIPE_START
M204 S6000
G1 X78.204 Y105.133 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X78.284 Y105.747 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F9547.055
M204 S2000
G1 X72.003 Y99.466 E.27296
M204 S10000
G1 X72.064 Y99.405 F42000
; FEATURE: Gap infill
; LINE_WIDTH: 0.204388
G1 F15000
M204 S6000
G1 X71.908 Y99.21 E.00328
; LINE_WIDTH: 0.157903
G1 X71.752 Y99.016 E.00234
; LINE_WIDTH: 0.111418
G1 X71.596 Y98.821 E.00139
; WIPE_START
G1 X71.752 Y99.016 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X70.612 Y97.034 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.20758
G1 F15000
M204 S6000
G1 X70.639 Y96.892 E.00194
; LINE_WIDTH: 0.195622
G1 X70.568 Y96.789 E.00155
; LINE_WIDTH: 0.152638
G1 X70.498 Y96.686 E.00112
; LINE_WIDTH: 0.109654
G1 X70.427 Y96.583 E.00068
; WIPE_START
G1 X70.498 Y96.686 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X71.339 Y89.1 Z5.4 F42000
G1 X71.898 Y84.054 Z5.4
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.0968322
G1 F15000
M204 S6000
G1 X71.945 Y84.21 E.00071
; WIPE_START
G1 X71.898 Y84.054 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X71.627 Y86.787 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.0895464
G1 F15000
M204 S6000
G1 X71.533 Y86.997 E.00088
; WIPE_START
G1 X71.627 Y86.787 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X71.782 Y90.425 Z5.4 F42000
M73 P96 R0
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.0923663
G1 F15000
M204 S6000
G1 X71.769 Y90.195 E.00093
; WIPE_START
G1 X71.782 Y90.425 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X72.402 Y93.176 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.11783
G1 F15000
M204 S6000
G1 X72.237 Y92.899 E.00197
; WIPE_START
G1 X72.402 Y93.176 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X73.004 Y94.842 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.0972698
G1 F15000
M204 S6000
G3 X72.783 Y94.511 I12.261 J-8.442 E.00176
; WIPE_START
G1 X73.004 Y94.842 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X74.053 Y96.955 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.110394
G1 F15000
M204 S6000
G1 X73.93 Y96.793 E.00112
; LINE_WIDTH: 0.15486
G1 X73.807 Y96.632 E.00185
; LINE_WIDTH: 0.199326
G1 X73.684 Y96.47 E.00259
; WIPE_START
G1 X73.807 Y96.632 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X75.008 Y98.442 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.111485
G1 F15000
M204 S6000
G1 X74.827 Y98.227 E.00157
; LINE_WIDTH: 0.158379
G1 X74.644 Y98.009 E.00268
; LINE_WIDTH: 0.204872
G1 X74.456 Y97.774 E.00396
; WIPE_START
G1 X74.644 Y98.009 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X77.823 Y101.673 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.21981
G1 F15000
M204 S6000
G1 X76.935 Y100.818 E.01777
G1 X76.077 Y99.927 E.01782
; WIPE_START
G1 X76.935 Y100.818 E-.46987
G1 X77.485 Y101.347 E-.29013
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X79.976 Y103.294 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.20463
G1 F15000
M204 S6000
G1 X79.739 Y103.104 E.004
; LINE_WIDTH: 0.163357
G1 X79.578 Y102.969 E.00205
; LINE_WIDTH: 0.127215
G1 X79.418 Y102.835 E.00144
; LINE_WIDTH: 0.0986582
G1 X79.308 Y102.742 E.00065
; WIPE_START
G1 X79.418 Y102.835 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X81.28 Y104.066 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.199331
G1 F15000
M204 S6000
G1 X81.118 Y103.943 E.00259
; LINE_WIDTH: 0.154869
G1 X80.957 Y103.82 E.00185
; LINE_WIDTH: 0.110406
G1 X80.795 Y103.697 E.00112
; WIPE_START
G1 X80.957 Y103.82 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X82.321 Y104.576 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.197327
G1 F15000
M204 S6000
G1 X82.216 Y104.504 E.0016
; LINE_WIDTH: 0.16626
G1 X82.109 Y104.43 E.0013
; LINE_WIDTH: 0.134756
G1 X82.021 Y104.366 E.00082
; LINE_WIDTH: 0.103692
G1 X81.933 Y104.302 E.00054
; WIPE_START
G1 X82.021 Y104.366 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X85.654 Y105.626 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.191844
G1 F15000
M204 S6000
G1 X85.513 Y105.671 E.0018
G1 X85.315 Y105.558 E.00276
; WIPE_START
G1 X85.513 Y105.671 E-.45985
G1 X85.654 Y105.626 E-.30015
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X80.133 Y106.823 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.109487
G1 F15000
M204 S6000
G1 X80.015 Y106.737 E.00079
; LINE_WIDTH: 0.152112
G1 X79.897 Y106.652 E.0013
; LINE_WIDTH: 0.198049
G1 X79.679 Y106.486 E.00346
M204 S10000
G1 X78.929 Y106.154 F42000
; LINE_WIDTH: 0.11141
G1 F15000
M204 S6000
G1 X78.734 Y105.998 E.00139
; LINE_WIDTH: 0.157898
G1 X78.54 Y105.842 E.00234
; LINE_WIDTH: 0.204387
G1 X78.345 Y105.686 E.00328
; WIPE_START
G1 X78.54 Y105.842 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X77.329 Y105.088 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.0991564
G1 F15000
M204 S6000
G1 X77.214 Y104.991 E.00069
; LINE_WIDTH: 0.131687
G1 X76.95 Y104.758 E.00254
; LINE_WIDTH: 0.174812
G1 X76.687 Y104.525 E.00378
; LINE_WIDTH: 0.217936
G1 X76.424 Y104.292 E.00502
; LINE_WIDTH: 0.258703
G1 X76.039 Y103.935 E.00923
; LINE_WIDTH: 0.297106
G1 F14162.903
G1 X75.655 Y103.578 E.01087
; LINE_WIDTH: 0.329381
G1 F12567.185
G3 X74.173 Y102.095 I28.947 J-30.429 E.04893
; LINE_WIDTH: 0.297114
G1 F14162.458
G1 X73.815 Y101.711 E.01087
; LINE_WIDTH: 0.258719
G1 F15000
G1 X73.458 Y101.327 E.00923
; LINE_WIDTH: 0.217965
G1 X73.225 Y101.063 E.00502
; LINE_WIDTH: 0.174834
G1 X72.992 Y100.8 E.00378
; LINE_WIDTH: 0.131703
G1 X72.759 Y100.536 E.00254
; LINE_WIDTH: 0.0991569
G1 X72.662 Y100.421 E.00069
; WIPE_START
G1 X72.759 Y100.536 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X79.661 Y97.278 Z5.4 F42000
G1 X110.844 Y82.558 Z5.4
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.0901313
G1 F15000
M204 S6000
G1 X110.691 Y82.279 E.00123
; WIPE_START
G1 X110.844 Y82.558 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X109.759 Y79.337 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.111828
G1 F15000
M204 S6000
G1 X109.68 Y79.221 E.00079
; LINE_WIDTH: 0.159107
G1 X109.6 Y79.106 E.00133
; LINE_WIDTH: 0.197711
G1 X109.505 Y78.967 E.00212
; WIPE_START
G1 X109.6 Y79.106 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X108.717 Y77.227 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.110892
G1 F15000
M204 S6000
G1 X108.591 Y77.062 E.00115
; LINE_WIDTH: 0.156325
G1 X108.466 Y76.897 E.00191
; LINE_WIDTH: 0.201758
G1 X108.341 Y76.733 E.00268
M204 S10000
G1 X107.887 Y75.863 F42000
; LINE_WIDTH: 0.0917106
G1 F15000
M204 S6000
G1 X107.853 Y75.821 E.00022
; LINE_WIDTH: 0.118136
G1 X107.661 Y75.592 E.00183
; LINE_WIDTH: 0.163916
G1 X107.469 Y75.364 E.00294
; LINE_WIDTH: 0.209696
G1 X107.277 Y75.136 E.00405
; WIPE_START
G1 X107.469 Y75.364 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X104.826 Y76.854 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.181248
G1 F15000
M204 S6000
G1 X104.834 Y76.746 E.00122
; LINE_WIDTH: 0.20911
G1 X104.836 Y76.709 E.00051
; LINE_WIDTH: 0.216111
G1 X104.642 Y76.49 E.00412
; LINE_WIDTH: 0.180489
G1 X104.449 Y76.271 E.00328
; LINE_WIDTH: 0.144743
G1 X104.254 Y76.051 E.00244
; LINE_WIDTH: 0.107515
G1 X103.881 Y75.65 E.00288
; WIPE_START
G1 X104.254 Y76.051 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X105.927 Y78.342 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.218883
G1 F15000
M204 S6000
G1 X105.853 Y78.245 E.00175
; LINE_WIDTH: 0.193296
G1 X105.729 Y78.09 E.00244
; LINE_WIDTH: 0.151242
G1 X105.605 Y77.935 E.00175
; LINE_WIDTH: 0.109188
G1 X105.48 Y77.78 E.00107
; WIPE_START
G1 X105.605 Y77.935 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X106.553 Y79.501 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.19609
G1 F15000
M204 S6000
G1 X106.452 Y79.361 E.00216
; LINE_WIDTH: 0.152924
G1 X106.351 Y79.221 E.00155
; LINE_WIDTH: 0.109758
G1 X106.249 Y79.08 E.00094
; WIPE_START
G1 X106.351 Y79.221 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X107.012 Y80.491 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.191949
G1 F15000
M204 S6000
G1 X106.927 Y80.368 E.00182
; LINE_WIDTH: 0.150445
G1 X106.842 Y80.245 E.00131
; LINE_WIDTH: 0.108941
G1 X106.758 Y80.121 E.00081
; WIPE_START
G1 X106.842 Y80.245 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X106.075 Y73.515 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.113707
G1 F15000
M204 S6000
G2 X104.235 Y71.675 I-23.642 J21.803 E.01501
; WIPE_START
G1 X105.171 Y72.58 E-.49448
G1 X105.656 Y73.082 E-.26552
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.1 Y73.869 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.107585
G1 F15000
M204 S6000
G1 X101.698 Y73.495 E.0029
; LINE_WIDTH: 0.144881
G1 X101.479 Y73.301 E.00243
; LINE_WIDTH: 0.180504
G1 X101.26 Y73.107 E.00328
; LINE_WIDTH: 0.21531
G1 X101.041 Y72.914 E.00411
G1 X101.004 Y72.916 E.00053
; LINE_WIDTH: 0.180987
G1 X100.896 Y72.924 E.00122
; WIPE_START
G1 X101.004 Y72.916 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.97 Y72.27 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.109193
G1 F15000
M204 S6000
G1 X99.815 Y72.145 E.00107
; LINE_WIDTH: 0.151239
G1 X99.66 Y72.021 E.00175
; LINE_WIDTH: 0.193737
G1 X99.501 Y71.894 E.0025
; LINE_WIDTH: 0.219021
G1 X99.408 Y71.823 E.00169
M204 S10000
G1 X98.67 Y71.501 F42000
; LINE_WIDTH: 0.109746
G1 F15000
M204 S6000
G1 X98.529 Y71.399 E.00094
; LINE_WIDTH: 0.152918
G1 X98.389 Y71.298 E.00155
; LINE_WIDTH: 0.196089
G1 X98.249 Y71.197 E.00216
; WIPE_START
G1 X98.389 Y71.298 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X93.683 Y69.708 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.129432
G1 F15000
M204 S6000
G1 X93.447 Y69.582 E.00189
; WIPE_START
G1 X93.683 Y69.708 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X86.086 Y70.439 Z5.4 F42000
G1 X83 Y70.735 Z5.4
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.103262
G1 F15000
M204 S6000
G1 X82.933 Y70.722 E.00033
G1 X82.846 Y70.782 E.00052
; WIPE_START
G1 X82.933 Y70.722 E-.46227
G1 X83 Y70.735 E-.29773
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X90.254 Y68.363 Z5.4 F42000
G1 X94.756 Y66.89 Z5.4
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.0962542
G1 F15000
M204 S6000
G1 X94.504 Y66.752 E.00125
; WIPE_START
G1 X94.756 Y66.89 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X99.816 Y68.744 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.192918
G1 F15000
M204 S6000
G1 X99.654 Y68.627 E.00245
; LINE_WIDTH: 0.143348
G1 X99.492 Y68.509 E.00164
; LINE_WIDTH: 0.103372
G1 X99.396 Y68.44 E.00058
; WIPE_START
G1 X99.492 Y68.509 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X101.017 Y69.409 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.201758
G1 F15000
M204 S6000
G1 X100.853 Y69.284 E.00268
; LINE_WIDTH: 0.156321
G1 X100.688 Y69.159 E.00191
; LINE_WIDTH: 0.110884
G1 X100.523 Y69.033 E.00115
; WIPE_START
G1 X100.688 Y69.159 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X102.614 Y70.473 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.209678
G1 F15000
M204 S6000
G1 X102.386 Y70.281 E.00405
; LINE_WIDTH: 0.163901
G1 X102.157 Y70.089 E.00294
; LINE_WIDTH: 0.118124
G1 X101.929 Y69.897 E.00183
; LINE_WIDTH: 0.0917008
G1 X101.887 Y69.863 E.00022
; WIPE_START
G1 X101.929 Y69.897 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X96.92 Y75.655 Z5.4 F42000
G1 X77.413 Y98.075 Z5.4
G1 Z5
G1 E.8 F1800
; FEATURE: Outer wall
; LINE_WIDTH: 0.41999
G1 F9547.299
M204 S5000
G1 X77.165 Y97.769 E.01211
G3 X106.28 Y87.349 I12.836 J-10.019 E1.89115
G1 X106.28 Y88.151 E.02467
G3 X77.665 Y98.379 I-16.279 J-.401 E1.20371
G1 X77.451 Y98.122 E.01026
; WIPE_START
M204 S6000
G1 X77.165 Y97.769 E-.17254
G1 X76.68 Y97.118 E-.30854
G1 X76.272 Y96.508 E-.27892
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X82.779 Y92.519 Z5.4 F42000
G1 X103.86 Y79.597 Z5.4
G1 Z5
G1 E.8 F1800
; FEATURE: Top surface
; LINE_WIDTH: 0.42
G1 F9547.055
M204 S2000
G1 X98.153 Y73.89 E.24801
; WIPE_START
M204 S6000
G1 X99.567 Y75.304 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X97.007 Y73.277 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F9547.055
M204 S2000
G1 X104.473 Y80.743 E.32442
G1 X104.9 Y81.703
G1 X96.047 Y72.85 E.38469
G1 X95.199 Y72.535
G1 X105.215 Y82.551 E.43525
G1 X105.459 Y83.329
G1 X94.421 Y72.291 E.47965
G1 X93.699 Y72.102
G1 X105.648 Y84.051 E.51922
G1 X105.794 Y84.73
G1 X93.02 Y71.956 E.5551
G1 X92.375 Y71.845
G1 X105.905 Y85.375 E.58796
G1 X105.982 Y85.985
G1 X91.765 Y71.768 E.61779
G1 X91.179 Y71.715
G1 X106.035 Y86.571 E.64553
G1 X106.067 Y87.137
G1 X90.613 Y71.683 E.67156
G1 X90.078 Y71.68
G1 X106.081 Y87.684 E.69542
G1 X106.071 Y88.207
G1 X89.548 Y71.684 E.71799
G1 X89.031 Y71.7
G1 X106.05 Y88.719 E.73956
G1 X106.014 Y89.216
G1 X88.534 Y71.736 E.75957
G1 X88.055 Y71.79
G1 X105.96 Y89.695 E.77805
G1 X105.898 Y90.167
G1 X87.583 Y71.852 E.79588
G1 X87.128 Y71.931
G1 X105.819 Y90.622 E.81222
G1 X105.733 Y91.068
G1 X86.682 Y72.017 E.82788
G1 X86.246 Y72.115
G1 X105.635 Y91.504 E.84257
G1 X105.526 Y91.928
G1 X85.822 Y72.224 E.85625
G1 X85.404 Y72.339
G1 X105.411 Y92.346 E.86938
G1 X105.281 Y92.749
G1 X85.001 Y72.469 E.88127
G1 X84.6 Y72.602
G1 X105.148 Y93.15 E.89291
G1 X105 Y93.535
G1 X84.215 Y72.75 E.90325
G1 X83.83 Y72.899
G1 X104.851 Y93.92 E.91347
G1 X104.688 Y94.289
G1 X83.461 Y73.062 E.92242
G1 X83.092 Y73.227
G1 X104.523 Y94.658 E.93126
G1 X104.344 Y95.012
G1 X82.738 Y73.406 E.93891
G1 X82.384 Y73.586
G1 X104.164 Y95.366 E.94644
G1 X103.972 Y95.706
G1 X82.044 Y73.778 E.95287
G1 X81.705 Y73.972
G1 X103.778 Y96.046 E.95919
G1 X103.571 Y96.372
G1 X81.378 Y74.179 E.96437
G1 X81.053 Y74.387
G1 X103.363 Y96.697 E.9695
G1 X103.143 Y97.01
G1 X80.74 Y74.607 E.97353
G1 X80.427 Y74.827
G1 X102.923 Y97.323 E.97756
G1 X102.689 Y97.623
G1 X80.127 Y75.061 E.98044
G1 X79.827 Y75.295
G1 X102.455 Y97.923 E.98329
G1 X102.21 Y98.21
G1 X79.54 Y75.54 E.98513
G1 X79.253 Y75.787
G1 X101.963 Y98.497 E.98685
G1 X101.705 Y98.772
G1 X78.978 Y76.045 E.98762
G1 X78.705 Y76.305
G1 X101.445 Y99.045 E.98817
G1 X101.175 Y99.309
G1 X78.441 Y76.575 E.98793
G1 X78.181 Y76.847
G1 X100.903 Y99.569 E.98738
G1 X100.621 Y99.821
G1 X77.929 Y77.129 E.98609
G1 X77.682 Y77.415
G1 X100.335 Y100.068 E.98437
G1 X100.041 Y100.308
G1 X77.442 Y77.709 E.98204
G1 X77.208 Y78.008
G1 X99.742 Y100.542 E.97918
G1 X99.436 Y100.769
G1 X76.981 Y78.314 E.97579
G1 X76.76 Y78.627
G1 X99.123 Y100.99 E.97176
G1 X98.805 Y101.205
G1 X76.545 Y78.945 E.96727
G1 X76.338 Y79.271
G1 X98.479 Y101.412 E.96209
G1 X98.147 Y101.613
G1 X76.137 Y79.603 E.95647
G1 X75.944 Y79.943
G1 X97.807 Y101.806 E.95005
G1 X97.461 Y101.994
G1 X75.756 Y80.289 E.94321
G1 X75.577 Y80.643
G1 X97.107 Y102.173 E.93555
G1 X96.747 Y102.346
G1 X75.404 Y81.003 E.92745
G1 X75.24 Y81.373
G1 X96.377 Y102.51 E.91849
M73 P97 R0
G1 X96.001 Y102.667
G1 X75.083 Y81.749 E.90901
G1 X74.934 Y82.133
G1 X95.617 Y102.816 E.89874
G1 X95.224 Y102.956
G1 X74.794 Y82.526 E.8878
G1 X74.661 Y82.926
G1 X94.824 Y103.089 E.87617
G1 X94.413 Y103.211
G1 X74.539 Y83.337 E.86362
G1 X74.423 Y83.755
G1 X93.995 Y103.327 E.85048
G1 X93.563 Y103.428
G1 X74.322 Y84.187 E.83612
G1 X74.225 Y84.623
G1 X93.127 Y103.525 E.82139
G1 X92.672 Y103.604
G1 X74.146 Y85.078 E.80505
G1 X74.074 Y85.539
G1 X92.211 Y103.676 E.78818
G1 X91.737 Y103.735
G1 X74.015 Y86.013 E.77013
G1 X73.971 Y86.502
G1 X91.248 Y103.779 E.75079
G1 X90.749 Y103.814
G1 X73.936 Y87.001 E.73061
G1 X73.923 Y87.521
G1 X90.229 Y103.827 E.70856
G1 X89.694 Y103.825
G1 X73.925 Y88.056 E.68522
G1 X73.942 Y88.607
G1 X89.143 Y103.808 E.66058
G1 X88.568 Y103.766
G1 X73.984 Y89.182 E.63375
G1 X74.051 Y89.782
G1 X87.968 Y103.699 E.60473
G1 X87.342 Y103.606
G1 X74.144 Y90.408 E.57354
G1 X74.266 Y91.064
G1 X86.686 Y103.484 E.53973
G1 X85.992 Y103.323
G1 X74.427 Y91.758 E.50259
G1 X74.637 Y92.501
G1 X85.249 Y103.113 E.46115
G1 X84.44 Y102.837
G1 X74.913 Y93.31 E.414
G1 X75.275 Y94.206
G1 X83.544 Y102.475 E.35932
G1 X82.522 Y101.985
G1 X75.765 Y95.228 E.29362
; WIPE_START
M204 S6000
G1 X77.179 Y96.643 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X76.525 Y96.522 Z5.4 F42000
G1 Z5
G1 E.8 F1800
G1 F9547.055
M204 S2000
G1 X81.228 Y101.225 E.2044
; WIPE_START
M204 S6000
G1 X79.814 Y99.811 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X85.509 Y94.729 Z5.4 F42000
G1 X103.359 Y78.8 Z5.4
G1 Z5
G1 E.8 F1800
; FEATURE: Gap infill
; LINE_WIDTH: 0.109578
G1 F15000
M204 S6000
G1 X103.194 Y78.603 E.00139
; LINE_WIDTH: 0.152382
G1 X103.028 Y78.407 E.00229
; LINE_WIDTH: 0.195187
G1 X102.863 Y78.211 E.00318
; LINE_WIDTH: 0.240683
G1 X102.603 Y77.916 E.00634
; LINE_WIDTH: 0.288879
G1 F14636.619
G1 X102.342 Y77.621 E.00788
; LINE_WIDTH: 0.327514
G1 F12649.6
G1 X102.076 Y77.334 E.00908
; LINE_WIDTH: 0.375592
G1 F10821.492
G2 X100.703 Y75.941 I-25.205 J23.46 E.05303
; LINE_WIDTH: 0.356571
G1 F11477.732
G1 X100.416 Y75.674 E.01001
; LINE_WIDTH: 0.327508
G1 F12649.881
G1 X100.129 Y75.408 E.00908
; LINE_WIDTH: 0.288881
G1 F14636.463
G1 X99.834 Y75.147 E.00788
; LINE_WIDTH: 0.240687
G1 F15000
G1 X99.539 Y74.887 E.00634
; LINE_WIDTH: 0.195184
G1 X99.343 Y74.722 E.00318
; LINE_WIDTH: 0.152379
G1 X99.147 Y74.556 E.00229
; LINE_WIDTH: 0.109575
G1 X98.95 Y74.391 E.00139
M204 S10000
G1 X98.092 Y73.951 F42000
; LINE_WIDTH: 0.200215
G1 F15000
M204 S6000
G1 X97.929 Y73.827 E.00261
; LINE_WIDTH: 0.155397
M73 P98 R0
G1 X97.767 Y73.704 E.00187
; LINE_WIDTH: 0.110578
G1 X97.605 Y73.58 E.00112
M204 S10000
G1 X96.946 Y73.339 F42000
; LINE_WIDTH: 0.212852
G1 F15000
M204 S6000
G1 X96.849 Y73.269 E.00165
; LINE_WIDTH: 0.188045
G1 X96.753 Y73.203 E.00138
; LINE_WIDTH: 0.148098
G1 X96.657 Y73.137 E.001
; LINE_WIDTH: 0.10815
G1 X96.561 Y73.071 E.00062
; WIPE_START
G1 X96.657 Y73.137 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X89.043 Y72.603 Z5.4 F42000
G1 X85.374 Y72.346 Z5.4
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.0941618
G1 F15000
M204 S6000
G1 X85.229 Y72.43 E.0007
; WIPE_START
G1 X85.374 Y72.346 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X81.974 Y79.179 Z5.4 F42000
G1 X74.975 Y93.248 Z5.4
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.200867
G1 F15000
M204 S6000
G1 X74.774 Y92.938 E.00476
; WIPE_START
G1 X74.975 Y93.248 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X75.826 Y95.167 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.196106
G1 F15000
M204 S6000
G1 X75.725 Y95.027 E.00216
; LINE_WIDTH: 0.152934
G1 X75.623 Y94.887 E.00155
; LINE_WIDTH: 0.109761
G1 X75.522 Y94.746 E.00094
; WIPE_START
G1 X75.623 Y94.887 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X76.585 Y96.461 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.209887
G1 F15000
M204 S6000
G1 X76.464 Y96.31 E.00263
; LINE_WIDTH: 0.174213
G1 X76.343 Y96.159 E.00207
; LINE_WIDTH: 0.138539
G1 X76.222 Y96.008 E.00151
; LINE_WIDTH: 0.104436
G1 X76.136 Y95.894 E.00072
; WIPE_START
G1 X76.222 Y96.008 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X80.196 Y100.49 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.102902
G1 F15000
M204 S6000
G1 X80.007 Y100.323 E.00123
; LINE_WIDTH: 0.132352
G1 X79.819 Y100.156 E.00183
; LINE_WIDTH: 0.161691
G1 X79.53 Y99.888 E.00381
; LINE_WIDTH: 0.21002
G3 X78.129 Y98.508 I23.593 J-25.347 E.02678
; LINE_WIDTH: 0.190915
G1 X77.862 Y98.22 E.00475
; LINE_WIDTH: 0.16169
G1 X77.594 Y97.931 E.00381
; LINE_WIDTH: 0.132353
G1 X77.427 Y97.743 E.00183
; LINE_WIDTH: 0.102892
G1 X77.26 Y97.554 E.00123
; WIPE_START
G1 X77.427 Y97.743 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X81.856 Y101.614 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.104436
G1 F15000
M204 S6000
G1 X81.742 Y101.528 E.00072
; LINE_WIDTH: 0.138539
G1 X81.591 Y101.407 E.00151
; LINE_WIDTH: 0.174221
G1 X81.44 Y101.286 E.00207
; LINE_WIDTH: 0.209903
G1 X81.289 Y101.165 E.00263
; WIPE_START
G1 X81.44 Y101.286 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X83.964 Y102.658 Z5.4 F42000
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.15302
G1 F15000
M204 S6000
G1 X83.785 Y102.535 E.00195
; LINE_WIDTH: 0.192765
G1 X83.606 Y102.413 E.00265
; WIPE_START
G1 X83.785 Y102.535 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G1 X88.923 Y96.892 Z5.4 F42000
G1 X104.17 Y80.145 Z5.4
G1 Z5
G1 E.8 F1800
; LINE_WIDTH: 0.101681
G1 F15000
M204 S6000
G1 X104.102 Y80.057 E.00053
; LINE_WIDTH: 0.128693
G1 X104.035 Y79.968 E.00078
; LINE_WIDTH: 0.162303
G1 X103.917 Y79.813 E.00189
; LINE_WIDTH: 0.202514
G1 X103.799 Y79.658 E.00253
; close powerlost recovery
M1003 S0
; WIPE_START
G1 F15000
G1 X103.917 Y79.813 E-.76
; WIPE_END
G1 E-.04 F1800
M204 S10000
G17
G3 Z5.4 I1.217 J0 P1  F42000
M106 S0
M981 S0 P20000 ; close spaghetti detector
; FEATURE: Custom
; MACHINE_END_GCODE_START
; filament end gcode 

;===== date: 20260513 =====================
;turn off nozzle clog detect
G392 S0

M400 ; wait for buffer to clear
G92 E0 ; zero the extruder
G90
G1 Z5.4 F900 ; lower z a little
G1 X0 Y90.3021 F18000 ; move to safe pos
G1 X-13.0 F3000 ; move to safe pos

M1002 judge_flag timelapse_record_flag
M622 J1
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M400 P100
M971 S11 C11 O0
M991 S0 P-1 ;end timelapse at safe pos
M623


M140 S0 ; turn off bed
M106 S0 ; turn off fan
M106 P2 S0 ; turn off remote part cooling fan
M106 P3 S0 ; turn off chamber cooling fan

;G1 X27 F15000 ; wipe

; pull back filament to AMS
M620 S255
G1 X181 F12000
T255
G1 X0 F18000
G1 X-13.0 F3000
G1 X0 F18000 ; wipe
M621 S255

M104 S0 ; turn off hotend

M400 ; wait all motion done
M17 S
M17 Z0.4 ; lower z motor current to reduce impact if there is something in the bottom

    G1 Z105 F600
    G1 Z103

M400 P100
M17 R ; restore z current

G90
G1 X-13 Y180 F3600

G91
G1 Z-1 F600
G90
M83

M220 S100  ; Reset feedrate magnitude
M201.2 K1.0 ; Reset acc magnitude
M73.2   R1.0 ;Reset left time magnitude
M1002 set_gcode_claim_speed_level : 0

;=====printer finish  sound=========
M17
M400 S1
M1006 S1
M1006 A0 B20 L100 C37 D20 M100 E42 F20 N100
M1006 A0 B10 L100 C44 D10 M100 E44 F10 N100
M1006 A0 B10 L100 C46 D10 M100 E46 F10 N100
M1006 A44 B20 L100 C39 D20 M100 E48 F20 N100
M1006 A0 B10 L100 C44 D10 M100 E44 F10 N100
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B10 L100 C39 D10 M100 E39 F10 N100
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B10 L100 C44 D10 M100 E44 F10 N100
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A0 B10 L100 C39 D10 M100 E39 F10 N100
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A44 B10 L100 C0 D10 M100 E48 F10 N100
M1006 A0 B10 L100 C0 D10 M100 E0 F10 N100
M1006 A44 B20 L100 C41 D20 M100 E49 F20 N100
M1006 A0 B20 L100 C0 D20 M100 E0 F20 N100
M1006 A0 B20 L100 C37 D20 M100 E37 F20 N100
M1006 W
;=====printer finish  sound=========
M400 S1
M18 X Y Z
M73 P100 R0
; EXECUTABLE_BLOCK_END

