return {
	['spell_id'] = '11140123',
	['groups'] = {
		[1] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000145',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 1
		},
		[2] = {
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
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 24,
			['effect_scale'] = 1.20000004768372,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 1
		},
		[5] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 4, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1200000000',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 12, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 24,
			['effect_scale'] = 1.20000004768372,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 1
		},
		[6] = {
			['trigger_event_id'] = 2000145,
			['trigger_event_delay'] = 0,
			['sound_id'] = '0',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 1
		},
		[7] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 4, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 10, ['offset_coefficient_first'] = -2, ['offset_coefficient_second'] = -2, ['fix_pos'] = {-14.15, 16.90, 0.00}, ['enemy_fix_pos'] = {12.15, -37.45, 0.00}}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.6800000667572, ['outTangent'] = 2.6800000667572, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 30
		},
		[8] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 10, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = -2, ['fix_pos'] = {-14.15, 16.90, 0.00}, ['enemy_fix_pos'] = {12.15, -37.45, 0.00}}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.6800000667572, ['outTangent'] = 2.6800000667572, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 30
		},
		[9] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'skill', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 60
		},
		[10] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '11110510312',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = 1.5, ['offset_coefficient_second'] = 2}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 0,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 75
		},
		[11] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000001',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 75
		},
		[12] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1111401222',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 2.09999990463257, ['offset_coefficient_second'] = 0.5}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 3,
			['effect_scale'] = 0.5,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 75
		},
		[13] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 75
		},
		[14] = {
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
			['change_time'] = 0,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 75
		},
		[15] = {
			['hit_segment'] = 1,
			['delay1'] = 0,
			['delay2'] = 0,
			['delay3'] = 0,
			['delay4'] = 0,
			['delay5'] = 0,
			['delay6'] = 0,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 75
		},
		[16] = {
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
			['change_time'] = 0,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 76
		},
		[17] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1111401222',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = 0.5, ['offset_coefficient_second'] = 2.09999990463257}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 3,
			['effect_scale'] = 0.5,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 77
		},
		[18] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '11110510312',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = 1.5, ['offset_coefficient_second'] = 2}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 0,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 78
		},
		[19] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000001',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 78
		},
		[20] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 78
		},
		[21] = {
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
			['change_time'] = 0,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 78
		},
		[22] = {
			['hit_segment'] = 2,
			['delay1'] = 0,
			['delay2'] = 0,
			['delay3'] = 0,
			['delay4'] = 0,
			['delay5'] = 0,
			['delay6'] = 0,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 78
		},
		[23] = {
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
			['change_time'] = 0,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 79
		},
		[24] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1111401222',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 2.09999990463257, ['offset_coefficient_second'] = 0.5}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 3,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 90
		},
		[25] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1111401221',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 2.09999990463257, ['offset_coefficient_second'] = 0.100000001490116}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 90,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 55,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 90
		},
		[26] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '11110510312',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = 1.5, ['offset_coefficient_second'] = 2}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 0,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 91
		},
		[27] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000001',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 91
		},
		[28] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 91
		},
		[29] = {
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
			['change_time'] = 0,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 91
		},
		[30] = {
			['hit_segment'] = 3,
			['delay1'] = 0,
			['delay2'] = 0,
			['delay3'] = 0,
			['delay4'] = 0,
			['delay5'] = 0,
			['delay6'] = 0,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 91
		},
		[31] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1.5,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 91
		},
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
			['change_time'] = 0,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 92
		},
		[33] = {},
		[34] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 94
		},
		[35] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000160',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 95
		},
		[36] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 6, ['segment'] = 1, ['ghost_id'] = 0},
			['layer'] = -1,
			['spell_action_type'] = 'SetUnitLayer',
			['happen_frame'] = 99
		},
		[37] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1.5,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 99
		},
		[38] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2100076',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 100
		},
		[39] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 102
		},
		[40] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 4, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'skill', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 104
		},
		[41] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 4, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'skill', ['anim_speed'] = 1},
			['anim_name'] = '',
			['according_anim_name'] = true,
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = -0.0025634765625, ['value'] = 0.671063244342804, ['inTangent'] = -0.330529630184174, ['outTangent'] = -0.330529630184174, ['tangentMode'] = 0},
					[2] = {['time'] = 0.173788204789162, ['value'] = 0.113303422927856, ['inTangent'] = -0.499421268701553, ['outTangent'] = -0.499421268701553, ['tangentMode'] = 0},
					[3] = {['time'] = 0.534784972667694, ['value'] = 0.93718159198761, ['inTangent'] = -0.512838125228882, ['outTangent'] = -0.512838125228882, ['tangentMode'] = 0},
					[4] = {['time'] = 0.678420901298523, ['value'] = 0.199252784252167, ['inTangent'] = -1.76350998878479, ['outTangent'] = -1.76350998878479, ['tangentMode'] = 0},
					[5] = {['time'] = 1, ['value'] = 0.400000005960464, ['inTangent'] = 1.99995052814484, ['outTangent'] = 1.99995052814484, ['tangentMode'] = 0}
				}
			},
			['last_time'] = 54,
			['spell_action_type'] = 'SetAnimSpeedCurve',
			['happen_frame'] = 104
		},
		[42] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1.5,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 107
		},
		[43] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 110
		},
		[44] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1.5,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 115
		},
		[45] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 118
		},
		[46] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1.5,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 123
		},
		[47] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 126
		},
		[48] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1.5,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 131
		},
		[49] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1111022012',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 12, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 2.5}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 10,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 100,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 132
		},
		[50] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1111022012',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 12, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 3.40000009536743}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 10,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 101,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 132
		},
		[51] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1111022012',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 12, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 1.60000002384186}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 10,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 102,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 132
		},
		[52] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 4, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 12, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = -0.800000011920929, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 6,
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 3.36218214035034, ['outTangent'] = 3.36218214035034, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0595556199550629, ['outTangent'] = 0.0595556199550629, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 132
		},
		[53] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['effect_index'] = 100,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 12, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = 11, ['offset_coefficient_second'] = 2.5}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 9,
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = -0.0321600027382374, ['outTangent'] = -0.0321600027382374, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1.78666341304779, ['outTangent'] = 1.78666341304779, ['tangentMode'] = 0}
				}
			},
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'EffectMove',
			['happen_frame'] = 133
		},
		[54] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['effect_index'] = 101,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 12, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = 11, ['offset_coefficient_second'] = 3.40000009536743}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 9,
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = -0.0321600027382374, ['outTangent'] = -0.0321600027382374, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1.78666341304779, ['outTangent'] = 1.78666341304779, ['tangentMode'] = 0}
				}
			},
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'EffectMove',
			['happen_frame'] = 133
		},
		[55] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['effect_index'] = 102,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 12, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = 11, ['offset_coefficient_second'] = 1.60000002384186}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 9,
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = -0.0321600027382374, ['outTangent'] = -0.0321600027382374, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1.78666341304779, ['outTangent'] = 1.78666341304779, ['tangentMode'] = 0}
				}
			},
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'EffectMove',
			['happen_frame'] = 133
		},
		[56] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 134
		},
		[57] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.0799999982118607, [4] = 0, [5] = 0.0500000007450581, [6] = 0.0850000008940697}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.0799999982118607, [4] = 0.0850000008940697, [2] = 0.0500000007450581, [5] = 0.0500000007450581, [3] = 0, [6] = 0}, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 4, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 6,
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
			['is_limit_edge'] = true,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 137
		},
		[58] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.0799999982118607, [4] = 0, [5] = 0, [6] = 0}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.0799999982118607, [4] = 0, [2] = 0.0500000007450581, [5] = 0, [3] = 0, [6] = 0}, ['ghost_id'] = 0},
			['effect_id'] = '1111022015',
			['is_attach_target'] = false,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 1.54999995231628, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 0,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 137
		},
		[59] = {
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
			['happen_frame'] = 137
		},
		[60] = {
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
			['happen_frame'] = 138
		},
		[61] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1.5,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 140
		},
		[62] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1111022014',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 12, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = 10.5, ['offset_coefficient_second'] = 2.5}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 36,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 100,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 142
		},
		[63] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1111022014',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 12, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = 10.5, ['offset_coefficient_second'] = 3.40000009536743}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 36,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 100,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 142
		},
		[64] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1111022014',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 12, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = 10.5, ['offset_coefficient_second'] = 1.60000002384186}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 36,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 100,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 142
		},
		[65] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['shake_time'] = 0.300000011920929,
			['shake_range'] = 2,
			['spell_action_type'] = 'ShakeScreen',
			['happen_frame'] = 143
		},
		[66] = {
			['hit_segment'] = 4,
			['delay1'] = 0,
			['delay2'] = 0,
			['delay3'] = 0,
			['delay4'] = 0,
			['delay5'] = 0,
			['delay6'] = 0,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 143
		},
		[67] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0, [4] = 0, [2] = 0, [5] = 0, [3] = 0, [6] = 0}, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 1.20000004768372, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
			['happen_frame'] = 143
		},
		[68] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 143
		},
		[69] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1111022016',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 1.54999995231628, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 18,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 180.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 103,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 144
		},
		[70] = {
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
			['happen_frame'] = 144
		},
		[71] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {1,0,0,0.2352941},
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
			['happen_frame'] = 144
		},
		[72] = {
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
			['happen_frame'] = 145
		},
		[73] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {1,0,0,0.1176471},
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
			['happen_frame'] = 146
		},
		[74] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['end_color'] = {1,0,0,0},
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 24,
			['spell_action_type'] = 'MaskColorAnim',
			['happen_frame'] = 148
		},
		[75] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1.5,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 148
		},
		[76] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 151
		},
		[77] = {
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
			['happen_frame'] = 154
		},
		[78] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1.5,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 157
		},
		[79] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 160
		},
		[80] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1.5,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 166
		},
		[81] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 169
		},
		[82] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 2.5,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 55,
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 175
		},
		[83] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 4, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.6800000667572, ['outTangent'] = 2.6800000667572, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 180
		},
		[84] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.0799999982118607, [4] = 0, [5] = 0, [6] = 0}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.0799999982118607, [4] = 0, [2] = 0.0500000007450581, [5] = 0, [3] = 0, [6] = 0}, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.6800000667572, ['outTangent'] = 2.6800000667572, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 180
		},
		[85] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.6800000667572, ['outTangent'] = 2.6800000667572, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 180
		},
		[86] = {},
		[87] = {
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
			['happen_frame'] = 180
		},
		[88] = {
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
			['happen_frame'] = 180
		},
		[89] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 6, ['segment'] = 1, ['ghost_id'] = 0},
			['layer'] = 0,
			['spell_action_type'] = 'SetUnitLayer',
			['happen_frame'] = 191
		},
		[90] = {
			['spell_action_type'] = 'CaculateDeath',
			['happen_frame'] = 231
		},
		[91] = {
			['spell_action_type'] = 'SpellEnd',
			['happen_frame'] = 235
		}
	}
}