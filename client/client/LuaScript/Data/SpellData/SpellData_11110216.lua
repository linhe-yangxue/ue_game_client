return {
	['spell_id'] = '11110216',
	['groups'] = {
		[1] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1200000000',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 24,
			['effect_scale'] = 1.20000004768372,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 0
		},
		[2] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['end_color'] = {0.2470588,0.2470588,0.2470588,1},
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
			['happen_frame'] = 0
		},
		[3] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 6, ['segment'] = 1, ['ghost_id'] = 0},
			['end_color'] = {0.2470588,0.2470588,0.2470588,1},
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
			['happen_frame'] = 0
		},
		[4] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000145',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 0
		},
		[5] = {
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['spell_action_type'] = 'ShowSpellName',
			['happen_frame'] = 17
		},
		[6] = {
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['show_time'] = 36,
			['ghost_interval'] = 0.0500000007450581,
			['ghost_lifetime'] = 0.300000011920929,
			['start_color'] = {0,2.541177,2.996078,1},
			['end_color'] = {1,1,1,0},
			['spell_action_type'] = 'ShowGhost',
			['happen_frame'] = 40
		},
		[7] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000080',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 40
		},
		[8] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'skill', ['anim_speed'] = 0.600000023841858},
			['anim_name'] = 'skill2',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 44
		},
		[9] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 3, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NotFollowY',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 54
		},
		[10] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['end_color'] = {1,1,1,0},
			['is_change_hud'] = true,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 18,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 54
		},
		[11] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000015',
			['sound_size'] = 0.600000023841858,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 54
		},
		[12] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['is_show'] = false,
			['spell_action_type'] = 'ShowOrHideShadow',
			['happen_frame'] = 71
		},
		[13] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'attack', ['anim_speed'] = 0},
			['anim_name'] = 'skill2',
			['according_anim_name'] = true,
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['last_time'] = 48,
			['spell_action_type'] = 'SetAnimSpeedCurve',
			['happen_frame'] = 72
		},
		[14] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '11110510308',
			['is_attach_target'] = false,
			['level_type'] = 'MinLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = -0.5, ['offset_coefficient_second'] = 2.79999995231628, ['fix_pos'] = {9.65, 6.45, 0.00}, ['enemy_fix_pos'] = {-11.05, -25.30, 0.00}}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 60,
			['effect_scale'] = 1.5,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 99
		},
		[15] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000018',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 99
		},
		[16] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'skill', ['anim_speed'] = 0.600000023841858},
			['anim_name'] = 'skill2',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 117
		},
		[17] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 5, ['offset_coefficient_second'] = 0, ['fix_pos'] = {9.65, 6.45, 0.00}, ['enemy_fix_pos'] = {-11.05, -25.30, 0.00}}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 0,
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 128
		},
		[18] = {},
		[19] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
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
			['change_time'] = 12,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 128
		},
		[20] = {
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['show_time'] = 9,
			['ghost_interval'] = 0.0500000007450581,
			['ghost_lifetime'] = 0.300000011920929,
			['start_color'] = {0,2.541177,2.996078,1},
			['end_color'] = {1,1,1,0},
			['spell_action_type'] = 'ShowGhost',
			['happen_frame'] = 128
		},
		[21] = {
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['show_time'] = 12,
			['ghost_interval'] = 0.0500000007450581,
			['ghost_lifetime'] = 0.300000011920929,
			['start_color'] = {0,2.541177,2.996078,1},
			['end_color'] = {1,1,1,0},
			['spell_action_type'] = 'ShowGhost',
			['happen_frame'] = 128
		},
		[22] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0, ['fix_pos'] = {9.65, 6.45, 0.00}, ['enemy_fix_pos'] = {-11.05, -25.30, 0.00}}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 9,
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'BeelineFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 131
		},
		[23] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000134',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 131
		},
		[24] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['is_show'] = true,
			['spell_action_type'] = 'ShowOrHideShadow',
			['happen_frame'] = 131
		},
		[25] = {
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
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 131
		},
		[26] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000015',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 134
		},
		[27] = {
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
			['change_time'] = 3,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 134
		},
		[28] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000084',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 137
		},
		[29] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 137
		},
		[30] = {
			['hit_segment'] = 1,
			['delay1'] = 0,
			['delay2'] = 0,
			['delay3'] = 0,
			['delay4'] = 0,
			['delay5'] = 0,
			['delay6'] = 0,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 137
		},
		[31] = {},
		[32] = {
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
			['change_time'] = 3,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 150
		},
		[33] = {
			['spell_action_type'] = 'CaculateDeath',
			['happen_frame'] = 179
		},
		[34] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 9,
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 200
		},
		[35] = {
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
			['change_time'] = 9,
			['spell_action_type'] = 'GameBackgroundColorAnim',
			['happen_frame'] = 200
		},
		[36] = {
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
			['change_time'] = 9,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 200
		},
		[37] = {
			['spell_action_type'] = 'SpellEnd',
			['happen_frame'] = 222
		}
	}
}