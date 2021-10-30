return {
	['spell_id'] = '11205112',
	['groups'] = {
		[1] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1200000000',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 24,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 1
		},
		[2] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['end_color'] = {0.2470588,0.2470588,0.2470588,1},
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 34},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 34}
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
			['sound_id'] = '2000145',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 1
		},
		[5] = {},
		[6] = {
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['spell_action_type'] = 'ShowSpellName',
			['happen_frame'] = 18
		},
		[7] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 2, ['offset_coefficient_first'] = -5, ['offset_coefficient_second'] = -0.200000002980232, ['fix_pos'] = {10.80, 4.60, 0.00}, ['enemy_fix_pos'] = {-8.95, -26.30, 0.00}}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.47434782981873, ['outTangent'] = 2.47434782981873, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 29
		},
		[8] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'skill_heji', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 55
		},
		[9] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {0,0.5882353,1,0.3921569},
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
			['happen_frame'] = 71
		},
		[10] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1120511113',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 2, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 1.20000004768372, ['offset_coefficient_second'] = 0.200000002980232}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 0,
			['effect_scale'] = 2,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 100,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 71
		},
		[11] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 0.5,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 100,
			['change_time'] = 24,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.71000003814697, ['outTangent'] = 2.71000003814697, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0677500516176224, ['outTangent'] = 0.0677500516176224, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 72
		},
		[12] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000021',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 73
		},
		[13] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000019',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 92
		},
		[14] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {1,1,1,0.5882353},
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
			['happen_frame'] = 95
		},
		[15] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000020',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 95
		},
		[16] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 0.699999988079071,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 100,
			['change_time'] = 9,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.71000003814697, ['outTangent'] = 2.71000003814697, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0677500516176224, ['outTangent'] = 0.0677500516176224, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 96
		},
		[17] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {0,0.5882353,1,0.3921569},
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
			['happen_frame'] = 97
		},
		[18] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {1,1,1,0.5882353},
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
			['happen_frame'] = 99
		},
		[19] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000020',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 99
		},
		[20] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {0,0.3888446,0.6037736,0.1960784},
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
			['happen_frame'] = 101
		},
		[21] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000020',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 103
		},
		[22] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1120511122',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 2, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 1.20000004768372, ['offset_coefficient_second'] = 0.200000002980232}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 45,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 105
		},
		[23] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['effect_id'] = '1120511112',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 2, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 1, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 3,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 105
		},
		[24] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 105
		},
		[25] = {},
		[26] = {
			['hit_segment'] = 1,
			['delay1'] = 0.119999997317791,
			['delay2'] = 0.100000001490116,
			['delay3'] = 0.0299999993294477,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.0799999982118607,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 105
		},
		[27] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['is_add'] = true,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 105
		},
		[28] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['end_color'] = {0,0.5261209,1,1},
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
			['happen_frame'] = 106
		},
		[29] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000020',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 107
		},
		[30] = {},
		[31] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['happen_frame'] = 109
		},
		[32] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000020',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 111
		},
		[33] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['effect_id'] = '1120511112',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 2, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 1, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 3,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 115
		},
		[34] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 115
		},
		[35] = {},
		[36] = {
			['hit_segment'] = 2,
			['delay1'] = 0.119999997317791,
			['delay2'] = 0.100000001490116,
			['delay3'] = 0.0299999993294477,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.0799999982118607,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 115
		},
		[37] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['is_add'] = true,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 115
		},
		[38] = {},
		[39] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['end_color'] = {0,0.5261209,1,1},
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
			['happen_frame'] = 116
		},
		[40] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000020',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 119
		},
		[41] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['happen_frame'] = 119
		},
		[42] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000020',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 123
		},
		[43] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['effect_id'] = '1120511112',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 2, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 1, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 3,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 125
		},
		[44] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 125
		},
		[45] = {},
		[46] = {
			['hit_segment'] = 3,
			['delay1'] = 0.119999997317791,
			['delay2'] = 0.100000001490116,
			['delay3'] = 0.0299999993294477,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.0799999982118607,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 125
		},
		[47] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['is_add'] = true,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 125
		},
		[48] = {},
		[49] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['end_color'] = {0,0.5261209,1,1},
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
			['happen_frame'] = 126
		},
		[50] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000020',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 127
		},
		[51] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['happen_frame'] = 129
		},
		[52] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000020',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 132
		},
		[53] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['effect_id'] = '1120511112',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 2, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 1, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 3,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 136
		},
		[54] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 136
		},
		[55] = {},
		[56] = {
			['hit_segment'] = 4,
			['delay1'] = 0.119999997317791,
			['delay2'] = 0.100000001490116,
			['delay3'] = 0.0299999993294477,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.0799999982118607,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 136
		},
		[57] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000020',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 136
		},
		[58] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['is_add'] = true,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 136
		},
		[59] = {},
		[60] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['end_color'] = {0,0.5261209,1,1},
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
			['happen_frame'] = 137
		},
		[61] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000020',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 140
		},
		[62] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['happen_frame'] = 140
		},
		[63] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {0,0.5882353,1,0},
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
			['happen_frame'] = 142
		},
		[64] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000020',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 144
		},
		[65] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['effect_id'] = '1120511112',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 2, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 1, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 3,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 147
		},
		[66] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 147
		},
		[67] = {},
		[68] = {
			['hit_segment'] = 5,
			['delay1'] = 0.119999997317791,
			['delay2'] = 0.100000001490116,
			['delay3'] = 0.0299999993294477,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.0799999982118607,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 147
		},
		[69] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['is_add'] = true,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 147
		},
		[70] = {},
		[71] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000020',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 148
		},
		[72] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['end_color'] = {0,0.5261209,1,1},
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
			['happen_frame'] = 148
		},
		[73] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['happen_frame'] = 151
		},
		[74] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000020',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 152
		},
		[75] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.119999997317791, [2] = 0.100000001490116, [3] = 0.0299999993294477, [4] = 0.0500000007450581, [5] = 0.0799999982118607, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['change_time'] = 6,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 162
		},
		[76] = {},
		[77] = {},
		[78] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.71000003814697, ['outTangent'] = 2.71000003814697, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0338750779628754, ['outTangent'] = 0.0338750779628754, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 175
		},
		[79] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['end_color'] = {1,1,1,1},
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 34},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 34}
				}
			},
			['change_time'] = 24,
			['spell_action_type'] = 'GameBackgroundColorAnim',
			['happen_frame'] = 175
		},
		[80] = {
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
			['happen_frame'] = 175
		},
		[81] = {
			['spell_action_type'] = 'CaculateDeath',
			['happen_frame'] = 223
		},
		[82] = {
			['spell_action_type'] = 'SpellEnd',
			['happen_frame'] = 229
		}
	}
}