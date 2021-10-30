return {
	['spell_id'] = '11206202',
	['groups'] = {
		[1] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['end_color'] = {0.2588235,0.2588235,0.2588235,1},
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 24,
			['spell_action_type'] = 'GameBackgroundColorAnim',
			['happen_frame'] = 1
		},
		[2] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 6, ['segment'] = 1, ['ghost_id'] = 0},
			['end_color'] = {0.2588235,0.2588235,0.2588235,1},
			['is_change_hud'] = true,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 24,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 1
		},
		[3] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000145',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 1
		},
		[4] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1200000000',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 0,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 1
		},
		[5] = {
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['spell_action_type'] = 'ShowSpellName',
			['happen_frame'] = 18
		},
		[6] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 2, ['pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = -3, ['offset_coefficient_second'] = 0, ['fix_pos'] = {8.60, 0.30, 0.00}, ['enemy_fix_pos'] = {-6.65, -23.40, 0.00}}, ['second_pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = -3, ['offset_coefficient_second'] = 0, ['fix_pos'] = {13.49, 8.54, 0.00}, ['enemy_fix_pos'] = {-11.60, -30.60, 0.00}}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 24,
			['move_speed'] = 0,
			['relative_dis'] = 0,
			['move_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.81400012969971, ['outTangent'] = 2.81400012969971, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0263603013008833, ['outTangent'] = 0.0263603013008833, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 25
		},
		[7] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['unit_id'] = 0,
			['start_size'] = {1.00, 1.00, 1.00},
			['start_color'] = {1,1,1,1},
			['stop_anim'] = false,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['last_time'] = 90,
			['ghost_id'] = 1,
			['spell_action_type'] = 'CreateGhost',
			['happen_frame'] = 49
		},
		[8] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['unit_id'] = 0,
			['start_size'] = {1.00, 1.00, 1.00},
			['start_color'] = {1,1,1,1},
			['stop_anim'] = false,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['last_time'] = 90,
			['ghost_id'] = 2,
			['spell_action_type'] = 'CreateGhost',
			['happen_frame'] = 49
		},
		[9] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'skill', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 50
		},
		[10] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['anim_data'] = {['anim_name'] = 'skill', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 50
		},
		[11] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['anim_data'] = {['anim_name'] = 'skill', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 50
		},
		[12] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'skill', ['anim_speed'] = 1},
			['anim_name'] = '',
			['according_anim_name'] = true,
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 1.00787353515625, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 0.327114403247833, ['value'] = 1.00787353515625, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[3] = {['time'] = 0.368410289287567, ['value'] = 2.00787353515625, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[4] = {['time'] = 0.453722059726715, ['value'] = 2.00787353515625, ['inTangent'] = -0.37485346198082, ['outTangent'] = -0.37485346198082, ['tangentMode'] = 0},
					[5] = {['time'] = 0.454437732696533, ['value'] = 1.00825333595276, ['inTangent'] = -0.389888525009155, ['outTangent'] = -0.389888525009155, ['tangentMode'] = 0},
					[6] = {['time'] = 0.484299629926682, ['value'] = 1.00209701061249, ['inTangent'] = -2.25479769706726, ['outTangent'] = -2.25479769706726, ['tangentMode'] = 0},
					[7] = {['time'] = 0.486055344343185, ['value'] = 0.131349086761475, ['inTangent'] = -0.220257997512817, ['outTangent'] = -0.220257997512817, ['tangentMode'] = 0},
					[8] = {['time'] = 0.602916777133942, ['value'] = 0.136668920516968, ['inTangent'] = 1.59440982341766, ['outTangent'] = 1.59440982341766, ['tangentMode'] = 0},
					[9] = {['time'] = 0.654019892215729, ['value'] = 1.0078022480011, ['inTangent'] = 0.251684963703156, ['outTangent'] = 0.251684963703156, ['tangentMode'] = 0},
					[10] = {['time'] = 0.814723551273346, ['value'] = 1.01238214969635, ['inTangent'] = -0.0802259147167206, ['outTangent'] = -0.0802259147167206, ['tangentMode'] = 0},
					[11] = {['time'] = 0.835853040218353, ['value'] = 0.059089720249176, ['inTangent'] = -0.0534153506159782, ['outTangent'] = -0.0534153506159782, ['tangentMode'] = 0},
					[12] = {['time'] = 0.980425179004669, ['value'] = 0.386016011238098, ['inTangent'] = 5.95474529266357, ['outTangent'] = 5.95474529266357, ['tangentMode'] = 0},
					[13] = {['time'] = 0.983381807804108, ['value'] = 0.861789107322693, ['inTangent'] = 2.66984963417053, ['outTangent'] = 2.66984963417053, ['tangentMode'] = 0},
					[14] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['last_time'] = 60,
			['spell_action_type'] = 'SetAnimSpeedCurve',
			['happen_frame'] = 51
		},
		[13] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['anim_data'] = {['anim_name'] = 'skill', ['anim_speed'] = 1},
			['anim_name'] = '',
			['according_anim_name'] = true,
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 1.00787353515625, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 0.327114403247833, ['value'] = 1.00787353515625, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[3] = {['time'] = 0.368410289287567, ['value'] = 2.00787353515625, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[4] = {['time'] = 0.453722059726715, ['value'] = 2.00787353515625, ['inTangent'] = -0.37485346198082, ['outTangent'] = -0.37485346198082, ['tangentMode'] = 0},
					[5] = {['time'] = 0.454437732696533, ['value'] = 1.00825333595276, ['inTangent'] = -0.389888525009155, ['outTangent'] = -0.389888525009155, ['tangentMode'] = 0},
					[6] = {['time'] = 0.484299629926682, ['value'] = 1.00209701061249, ['inTangent'] = -2.25479769706726, ['outTangent'] = -2.25479769706726, ['tangentMode'] = 0},
					[7] = {['time'] = 0.486055344343185, ['value'] = 0.131349086761475, ['inTangent'] = -0.220257997512817, ['outTangent'] = -0.220257997512817, ['tangentMode'] = 0},
					[8] = {['time'] = 0.602916777133942, ['value'] = 0.136668920516968, ['inTangent'] = 1.59440982341766, ['outTangent'] = 1.59440982341766, ['tangentMode'] = 0},
					[9] = {['time'] = 0.654019892215729, ['value'] = 1.0078022480011, ['inTangent'] = 0.251684963703156, ['outTangent'] = 0.251684963703156, ['tangentMode'] = 0},
					[10] = {['time'] = 0.814723551273346, ['value'] = 1.01238214969635, ['inTangent'] = -0.0802259147167206, ['outTangent'] = -0.0802259147167206, ['tangentMode'] = 0},
					[11] = {['time'] = 0.835853040218353, ['value'] = 0.059089720249176, ['inTangent'] = -0.0534153506159782, ['outTangent'] = -0.0534153506159782, ['tangentMode'] = 0},
					[12] = {['time'] = 0.980425179004669, ['value'] = 0.386016011238098, ['inTangent'] = 5.95474529266357, ['outTangent'] = 5.95474529266357, ['tangentMode'] = 0},
					[13] = {['time'] = 0.983381807804108, ['value'] = 0.861789107322693, ['inTangent'] = 2.66984963417053, ['outTangent'] = 2.66984963417053, ['tangentMode'] = 0},
					[14] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['last_time'] = 60,
			['spell_action_type'] = 'SetAnimSpeedCurve',
			['happen_frame'] = 51
		},
		[14] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['anim_data'] = {['anim_name'] = 'skill', ['anim_speed'] = 1},
			['anim_name'] = '',
			['according_anim_name'] = true,
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 1.00787353515625, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 0.327114403247833, ['value'] = 1.00787353515625, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[3] = {['time'] = 0.368410289287567, ['value'] = 2.00787353515625, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[4] = {['time'] = 0.453722059726715, ['value'] = 2.00787353515625, ['inTangent'] = -0.37485346198082, ['outTangent'] = -0.37485346198082, ['tangentMode'] = 0},
					[5] = {['time'] = 0.454437732696533, ['value'] = 1.00825333595276, ['inTangent'] = -0.389888525009155, ['outTangent'] = -0.389888525009155, ['tangentMode'] = 0},
					[6] = {['time'] = 0.484299629926682, ['value'] = 1.00209701061249, ['inTangent'] = -2.25479769706726, ['outTangent'] = -2.25479769706726, ['tangentMode'] = 0},
					[7] = {['time'] = 0.486055344343185, ['value'] = 0.131349086761475, ['inTangent'] = -0.220257997512817, ['outTangent'] = -0.220257997512817, ['tangentMode'] = 0},
					[8] = {['time'] = 0.602916777133942, ['value'] = 0.136668920516968, ['inTangent'] = 1.59440982341766, ['outTangent'] = 1.59440982341766, ['tangentMode'] = 0},
					[9] = {['time'] = 0.654019892215729, ['value'] = 1.0078022480011, ['inTangent'] = 0.251684963703156, ['outTangent'] = 0.251684963703156, ['tangentMode'] = 0},
					[10] = {['time'] = 0.814723551273346, ['value'] = 1.01238214969635, ['inTangent'] = -0.0802259147167206, ['outTangent'] = -0.0802259147167206, ['tangentMode'] = 0},
					[11] = {['time'] = 0.835853040218353, ['value'] = 0.059089720249176, ['inTangent'] = -0.0534153506159782, ['outTangent'] = -0.0534153506159782, ['tangentMode'] = 0},
					[12] = {['time'] = 0.980425179004669, ['value'] = 0.386016011238098, ['inTangent'] = 5.95474529266357, ['outTangent'] = 5.95474529266357, ['tangentMode'] = 0},
					[13] = {['time'] = 0.983381807804108, ['value'] = 0.861789107322693, ['inTangent'] = 2.66984963417053, ['outTangent'] = 2.66984963417053, ['tangentMode'] = 0},
					[14] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['last_time'] = 60,
			['spell_action_type'] = 'SetAnimSpeedCurve',
			['happen_frame'] = 51
		},
		[15] = {
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['show_time'] = 12,
			['ghost_interval'] = 0.00999999977648258,
			['ghost_lifetime'] = 0.200000002980232,
			['start_color'] = {1,1,1,0.2352941},
			['end_color'] = {1,1,1,0},
			['spell_action_type'] = 'ShowGhost',
			['happen_frame'] = 54
		},
		[16] = {
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['show_time'] = 12,
			['ghost_interval'] = 0.00999999977648258,
			['ghost_lifetime'] = 0.200000002980232,
			['start_color'] = {1,1,1,0.2352941},
			['end_color'] = {1,1,1,0},
			['spell_action_type'] = 'ShowGhost',
			['happen_frame'] = 54
		},
		[17] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 10, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 0.899999976158142, ['offset_coefficient_second'] = -1.70000004768372}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 18,
			['move_speed'] = 0,
			['relative_dis'] = 0,
			['move_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.41200017929077, ['outTangent'] = 2.41200017929077, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 54
		},
		[18] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 10, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = -0.899999976158142, ['offset_coefficient_second'] = 1.70000004768372}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 18,
			['move_speed'] = 0,
			['relative_dis'] = 0,
			['move_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.41200017929077, ['outTangent'] = 2.41200017929077, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 54
		},
		[19] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000107',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 55
		},
		[20] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000107',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 57
		},
		[21] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000107',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 59
		},
		[22] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000140',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 62
		},
		[23] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000135',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 63
		},
		[24] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000139',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 65
		},
		[25] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000135',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 66
		},
		[26] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1112062013',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 2, ['offset_coefficient_second'] = 0.400000005960464}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 6,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 71
		},
		[27] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['end_color'] = {0.8867924,0.8867924,0.8867924,1},
			['is_change_hud'] = false,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 0,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 71
		},
		[28] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1112062013',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 14, ['ghost_id'] = 1, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 1.79999995231628, ['offset_coefficient_second'] = 0.400000005960464}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 6,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 71
		},
		[29] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1112062013',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 14, ['ghost_id'] = 2, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 1.79999995231628, ['offset_coefficient_second'] = 0.400000005960464}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 6,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 71
		},
		[30] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1112062012',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 1.60000002384186, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 0,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 72
		},
		[31] = {
			['hit_segment'] = 1,
			['delay1'] = 0,
			['delay2'] = 0,
			['delay3'] = 0,
			['delay4'] = 0,
			['delay5'] = 0,
			['delay6'] = 0,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 72
		},
		[32] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['end_color'] = {1,0,0,1},
			['is_change_hud'] = false,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 3,
			['is_add'] = true,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 72
		},
		[33] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 3},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 72
		},
		[34] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1112062012',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 2.20000004768372, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 0,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 74
		},
		[35] = {
			['hit_segment'] = 2,
			['delay1'] = 0,
			['delay2'] = 0,
			['delay3'] = 0,
			['delay4'] = 0,
			['delay5'] = 0,
			['delay6'] = 0,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 74
		},
		[36] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 74
		},
		[37] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['end_color'] = {0.009433985,0.009433985,0.009433985,1},
			['is_change_hud'] = false,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 15,
			['is_add'] = true,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 75
		},
		[38] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 0.80, 1.00},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0.0315294191241264, ['outTangent'] = 0.0315294191241264, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 2.38605999946594, ['outTangent'] = 2.38605999946594, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitScaleAnim',
			['happen_frame'] = 79
		},
		[39] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['rotate_model'] = false,
			['end_euler'] = {0.00, 0.00, 8.00},
			['enemy_end_euler'] = {0.00, 0.00, -8.00},
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = -0.0349565260112286, ['outTangent'] = -0.0349565260112286, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1.70849764347076, ['outTangent'] = 1.70849764347076, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitRotateAnim',
			['happen_frame'] = 79
		},
		[40] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 0.80, 1.00},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0.0315294191241264, ['outTangent'] = 0.0315294191241264, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 2.38605999946594, ['outTangent'] = 2.38605999946594, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitScaleAnim',
			['happen_frame'] = 79
		},
		[41] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['rotate_model'] = false,
			['end_euler'] = {0.00, 0.00, 8.00},
			['enemy_end_euler'] = {0.00, 0.00, -8.00},
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = -0.0349565260112286, ['outTangent'] = -0.0349565260112286, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1.70849764347076, ['outTangent'] = 1.70849764347076, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitRotateAnim',
			['happen_frame'] = 79
		},
		[42] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 0.80, 1.00},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0.0315294191241264, ['outTangent'] = 0.0315294191241264, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 2.38605999946594, ['outTangent'] = 2.38605999946594, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitScaleAnim',
			['happen_frame'] = 79
		},
		[43] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['rotate_model'] = false,
			['end_euler'] = {0.00, 0.00, 8.00},
			['enemy_end_euler'] = {0.00, 0.00, -8.00},
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = -0.0349565260112286, ['outTangent'] = -0.0349565260112286, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1.70849764347076, ['outTangent'] = 1.70849764347076, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitRotateAnim',
			['happen_frame'] = 79
		},
		[44] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = -2, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 15,
			['move_speed'] = 0,
			['relative_dis'] = 0,
			['move_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1.6719799041748, ['outTangent'] = 1.6719799041748, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = -1.60508894920349, ['outTangent'] = -1.60508894920349, ['tangentMode'] = 0}
				}
			},
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1.65394294261932, ['outTangent'] = 1.65394294261932, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.667471408843994, ['outTangent'] = 0.667471408843994, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 83
		},
		[45] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.87142872810364, ['outTangent'] = 2.87142872810364, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitScaleAnim',
			['happen_frame'] = 83
		},
		[46] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['rotate_model'] = false,
			['end_euler'] = {0.00, 0.00, 0.00},
			['enemy_end_euler'] = {0.00, 0.00, 0.00},
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['change_time'] = 15,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = -0.0349565260112286, ['outTangent'] = -0.0349565260112286, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1.70849764347076, ['outTangent'] = 1.70849764347076, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitRotateAnim',
			['happen_frame'] = 83
		},
		[47] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 14, ['ghost_id'] = 1, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = -2, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 15,
			['move_speed'] = 0,
			['relative_dis'] = 0,
			['move_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1.6719799041748, ['outTangent'] = 1.6719799041748, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = -1.60508894920349, ['outTangent'] = -1.60508894920349, ['tangentMode'] = 0}
				}
			},
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1.65394294261932, ['outTangent'] = 1.65394294261932, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.667471408843994, ['outTangent'] = 0.667471408843994, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 83
		},
		[48] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.87142872810364, ['outTangent'] = 2.87142872810364, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitScaleAnim',
			['happen_frame'] = 83
		},
		[49] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['rotate_model'] = false,
			['end_euler'] = {0.00, 0.00, 0.00},
			['enemy_end_euler'] = {0.00, 0.00, 0.00},
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['change_time'] = 15,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = -0.0349565260112286, ['outTangent'] = -0.0349565260112286, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1.70849764347076, ['outTangent'] = 1.70849764347076, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitRotateAnim',
			['happen_frame'] = 83
		},
		[50] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 14, ['ghost_id'] = 2, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = -2, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 15,
			['move_speed'] = 0,
			['relative_dis'] = 0,
			['move_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1.6719799041748, ['outTangent'] = 1.6719799041748, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = -1.60508894920349, ['outTangent'] = -1.60508894920349, ['tangentMode'] = 0}
				}
			},
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1.65394294261932, ['outTangent'] = 1.65394294261932, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.667471408843994, ['outTangent'] = 0.667471408843994, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 83
		},
		[51] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.87142872810364, ['outTangent'] = 2.87142872810364, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitScaleAnim',
			['happen_frame'] = 83
		},
		[52] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['rotate_model'] = false,
			['end_euler'] = {0.00, 0.00, 0.00},
			['enemy_end_euler'] = {0.00, 0.00, 0.00},
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['change_time'] = 15,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = -0.0349565260112286, ['outTangent'] = -0.0349565260112286, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1.70849764347076, ['outTangent'] = 1.70849764347076, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitRotateAnim',
			['happen_frame'] = 83
		},
		[53] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['end_color'] = {1,1,1,1},
			['is_change_hud'] = false,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 15,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 85
		},
		[54] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000134',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 87
		},
		[55] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000134',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 87
		},
		[56] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000134',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 87
		},
		[57] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000141',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 89
		},
		[58] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000138',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 89
		},
		[59] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000135',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 92
		},
		[60] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000135',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 92
		},
		[61] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['end_scale'] = 1,
			['end_vector_scale'] = {1.20, 0.80, 1.00},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0.0315294191241264, ['outTangent'] = 0.0315294191241264, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 2.38605999946594, ['outTangent'] = 2.38605999946594, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitScaleAnim',
			['happen_frame'] = 97
		},
		[62] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['end_scale'] = 1,
			['end_vector_scale'] = {1.20, 0.80, 1.00},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0.0315294191241264, ['outTangent'] = 0.0315294191241264, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 2.38605999946594, ['outTangent'] = 2.38605999946594, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitScaleAnim',
			['happen_frame'] = 97
		},
		[63] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['end_scale'] = 1,
			['end_vector_scale'] = {1.20, 0.80, 1.00},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0.0315294191241264, ['outTangent'] = 0.0315294191241264, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 2.38605999946594, ['outTangent'] = 2.38605999946594, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitScaleAnim',
			['happen_frame'] = 97
		},
		[64] = {
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['show_time'] = 3,
			['ghost_interval'] = 0.00999999977648258,
			['ghost_lifetime'] = 0.200000002980232,
			['start_color'] = {1,1,1,0.2352941},
			['end_color'] = {1,1,1,0},
			['spell_action_type'] = 'ShowGhost',
			['happen_frame'] = 99
		},
		[65] = {
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['show_time'] = 3,
			['ghost_interval'] = 0.00999999977648258,
			['ghost_lifetime'] = 0.200000002980232,
			['start_color'] = {1,1,1,0.2352941},
			['end_color'] = {1,1,1,0},
			['spell_action_type'] = 'ShowGhost',
			['happen_frame'] = 99
		},
		[66] = {
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['show_time'] = 3,
			['ghost_interval'] = 0.00999999977648258,
			['ghost_lifetime'] = 0.200000002980232,
			['start_color'] = {1,1,1,0.2352941},
			['end_color'] = {1,1,1,0},
			['spell_action_type'] = 'ShowGhost',
			['happen_frame'] = 99
		},
		[67] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['shake_time'] = 0.100000001490116,
			['shake_range'] = 3,
			['spell_action_type'] = 'ShakeScreen',
			['happen_frame'] = 99
		},
		[68] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1112062016',
			['is_attach_target'] = false,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 1.5, ['offset_coefficient_second'] = 1.20000004768372}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 6,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 100
		},
		[69] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 2, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 3,
			['move_speed'] = 0,
			['relative_dis'] = 0,
			['move_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.56088900566101, ['outTangent'] = 2.56088900566101, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0656327232718468, ['outTangent'] = 0.0656327232718468, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 100
		},
		[70] = {
			['hit_segment'] = 3,
			['delay1'] = 0,
			['delay2'] = 0,
			['delay3'] = 0,
			['delay4'] = 0,
			['delay5'] = 0,
			['delay6'] = 0,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 100
		},
		[71] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1112062015',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0.5, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 0,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 100
		},
		[72] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1112062012',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 1.5, ['offset_coefficient_second'] = 1}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 0,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 100
		},
		[73] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['effect_id'] = '1112062016',
			['is_attach_target'] = false,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 14, ['ghost_id'] = 1, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 1.79999995231628, ['offset_coefficient_second'] = 1.20000004768372}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 6,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 100
		},
		[74] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 14, ['ghost_id'] = 1, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 2, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 3,
			['move_speed'] = 0,
			['relative_dis'] = 0,
			['move_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.56088900566101, ['outTangent'] = 2.56088900566101, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0656327232718468, ['outTangent'] = 0.0656327232718468, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 100
		},
		[75] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1112062015',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 14, ['ghost_id'] = 1, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0.5, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 0,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 100
		},
		[76] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 0.5},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 100
		},
		[77] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['effect_id'] = '1112062016',
			['is_attach_target'] = false,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 14, ['ghost_id'] = 2, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 1.79999995231628, ['offset_coefficient_second'] = 1.20000004768372}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 6,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 100
		},
		[78] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 14, ['ghost_id'] = 2, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 2, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 3,
			['move_speed'] = 0,
			['relative_dis'] = 0,
			['move_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.56088900566101, ['outTangent'] = 2.56088900566101, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0656327232718468, ['outTangent'] = 0.0656327232718468, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 100
		},
		[79] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['end_color'] = {0.9056604,0.9056604,0.9056604,1},
			['is_change_hud'] = false,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 0,
			['is_add'] = true,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 100
		},
		[80] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {1,0.01960784,1,0.2352941},
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 0,
			['spell_action_type'] = 'MaskColorAnim',
			['happen_frame'] = 100
		},
		[81] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.87142872810364, ['outTangent'] = 2.87142872810364, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitScaleAnim',
			['happen_frame'] = 101
		},
		[82] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.87142872810364, ['outTangent'] = 2.87142872810364, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitScaleAnim',
			['happen_frame'] = 101
		},
		[83] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['end_color'] = {1,0,0,1},
			['is_change_hud'] = false,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 3,
			['is_add'] = true,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 101
		},
		[84] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.87142872810364, ['outTangent'] = 2.87142872810364, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitScaleAnim',
			['happen_frame'] = 101
		},
		[85] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1112062015',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 14, ['ghost_id'] = 2, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0.5, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 0,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 101
		},
		[86] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {1,0.01960784,1,0.1176471},
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 0,
			['spell_action_type'] = 'MaskColorAnim',
			['happen_frame'] = 102
		},
		[87] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0.5, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 18,
			['move_speed'] = 0,
			['relative_dis'] = 0,
			['move_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.63712024688721, ['outTangent'] = 2.63712024688721, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0303391981869936, ['outTangent'] = 0.0303391981869936, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 103
		},
		[88] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['end_color'] = {1,1,1,0},
			['is_change_hud'] = false,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = -0.0684255436062813, ['outTangent'] = -0.0684255436062813, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 2.00999689102173, ['outTangent'] = 2.00999689102173, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 15,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 103
		},
		[89] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['end_color'] = {1,1,1,0},
			['is_change_hud'] = false,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 2.48980188369751, ['outTangent'] = 2.48980188369751, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 15,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 103
		},
		[90] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 14, ['ghost_id'] = 1, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0.5, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 18,
			['move_speed'] = 0,
			['relative_dis'] = 0,
			['move_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.63712024688721, ['outTangent'] = 2.63712024688721, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0303391981869936, ['outTangent'] = 0.0303391981869936, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 103
		},
		[91] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 14, ['ghost_id'] = 2, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0.5, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 18,
			['move_speed'] = 0,
			['relative_dis'] = 0,
			['move_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.63712024688721, ['outTangent'] = 2.63712024688721, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0303391981869936, ['outTangent'] = 0.0303391981869936, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 103
		},
		[92] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {1,0.01960784,1,0},
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 18,
			['spell_action_type'] = 'MaskColorAnim',
			['happen_frame'] = 104
		},
		[93] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['end_color'] = {0,0,0,1},
			['is_change_hud'] = false,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 15,
			['is_add'] = true,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 108
		},
		[94] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 1},
			['is_show'] = false,
			['spell_action_type'] = 'ShowOrHideShadow',
			['happen_frame'] = 110
		},
		[95] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 7, ['segment'] = 1, ['ghost_id'] = 2},
			['is_show'] = false,
			['spell_action_type'] = 'ShowOrHideShadow',
			['happen_frame'] = 110
		},
		[96] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['end_color'] = {1,1,1,1},
			['is_change_hud'] = false,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 15,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 118
		},
		[97] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0, ['fix_pos'] = {13.49, 8.54, 0.00}, ['enemy_fix_pos'] = {-11.60, -30.60, 0.00}}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 24,
			['move_speed'] = 0,
			['relative_dis'] = 0,
			['move_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.81400012969971, ['outTangent'] = 2.81400012969971, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0263603013008833, ['outTangent'] = 0.0263603013008833, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 138
		},
		[98] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['end_color'] = {1,1,1,1},
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 24,
			['spell_action_type'] = 'GameBackgroundColorAnim',
			['happen_frame'] = 138
		},
		[99] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 6, ['segment'] = 1, ['ghost_id'] = 0},
			['end_color'] = {1,1,1,1},
			['is_change_hud'] = true,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 24,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 138
		},
		[100] = {
			['spell_action_type'] = 'CaculateDeath',
			['happen_frame'] = 187
		},
		[101] = {
			['spell_action_type'] = 'SpellEnd',
			['happen_frame'] = 191
		}
	}
}