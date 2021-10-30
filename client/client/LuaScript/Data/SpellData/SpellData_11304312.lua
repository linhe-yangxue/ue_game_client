return {
	['spell_id'] = '11304312',
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
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'skill', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 27
		},
		[8] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1113043111',
			['is_attach_target'] = true,
			['level_type'] = 'SortByPos',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 2, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 1.39999997615814, ['offset_coefficient_second'] = 0.600000023841858}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 37,
			['effect_scale'] = 0.649999976158142,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, -20.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 100,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 52
		},
		[9] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000092',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 52
		},
		[10] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['effect_index'] = 100,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 2, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 2, ['offset_coefficient_second'] = 0, ['fix_pos'] = {-9.10, -26.03, 0.00}, ['enemy_fix_pos'] = {10.65, 4.48, 0.00}}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 36,
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.76576042175293, ['outTangent'] = 2.76576042175293, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'EffectMove',
			['happen_frame'] = 53
		},
		[11] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000113',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 81
		},
		[12] = {
			['hit_segment'] = 1,
			['delay1'] = 0.400000005960464,
			['delay2'] = 0.200000002980232,
			['delay3'] = 0.300000011920929,
			['delay4'] = 0,
			['delay5'] = 0.300000011920929,
			['delay6'] = 0,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 89
		},
		[13] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1110431112',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 2, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 2, ['offset_coefficient_second'] = 0, ['fix_pos'] = {-9.10, -26.03, 0.00}, ['enemy_fix_pos'] = {10.65, 4.48, 0.00}}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 3,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 89
		},
		[14] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1113043122',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0, ['fix_pos'] = {-9.10, -26.03, 0.00}, ['enemy_fix_pos'] = {10.65, 4.48, 0.00}}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 0,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 89
		},
		[15] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.400000005960464, [2] = 0.200000002980232, [3] = 0.300000011920929, [4] = 0, [5] = 0.300000011920929, [6] = 0}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['end_color'] = {0.3882353,0.8313726,0.3803922,1},
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
			['happen_frame'] = 90
		},
		[16] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.400000005960464, [2] = 0.200000002980232, [3] = 0.300000011920929, [4] = 0, [5] = 0.300000011920929, [6] = 0}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['happen_frame'] = 91
		},
		[17] = {
			['hit_segment'] = 2,
			['delay1'] = 0.300000011920929,
			['delay2'] = 0,
			['delay3'] = 0.25,
			['delay4'] = 0.200000002980232,
			['delay5'] = 0.200000002980232,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 105
		},
		[18] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.300000011920929, [2] = 0, [3] = 0.25, [4] = 0.200000002980232, [5] = 0.200000002980232, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['end_color'] = {0.3882353,0.8313726,0.3803922,1},
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
		[19] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.300000011920929, [2] = 0, [3] = 0.25, [4] = 0.200000002980232, [5] = 0.200000002980232, [6] = 0.150000005960464}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['happen_frame'] = 106
		},
		[20] = {
			['hit_segment'] = 3,
			['delay1'] = 0.300000011920929,
			['delay2'] = 0.400000005960464,
			['delay3'] = 0.200000002980232,
			['delay4'] = 0.300000011920929,
			['delay5'] = 0,
			['delay6'] = 0,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 121
		},
		[21] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.300000011920929, [2] = 0.400000005960464, [3] = 0.200000002980232, [4] = 0.300000011920929, [5] = 0, [6] = 0}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['end_color'] = {0.3882353,0.8313726,0.3803922,1},
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
			['happen_frame'] = 121
		},
		[22] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.300000011920929, [2] = 0.400000005960464, [3] = 0.200000002980232, [4] = 0.300000011920929, [5] = 0, [6] = 0}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['happen_frame'] = 122
		},
		[23] = {
			['hit_segment'] = 4,
			['delay1'] = 0.300000011920929,
			['delay2'] = 0,
			['delay3'] = 0.400000005960464,
			['delay4'] = 0,
			['delay5'] = 0.100000001490116,
			['delay6'] = 0.300000011920929,
			['use_opposite'] = true,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 137
		},
		[24] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.300000011920929, [2] = 0, [3] = 0.400000005960464, [4] = 0, [5] = 0.100000001490116, [6] = 0.300000011920929}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['end_color'] = {0.3882353,0.8313726,0.3803922,1},
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
		[25] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.300000011920929, [2] = 0, [3] = 0.400000005960464, [4] = 0, [5] = 0.100000001490116, [6] = 0.300000011920929}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['happen_frame'] = 138
		},
		[26] = {
			['hit_segment'] = 5,
			['delay1'] = 0.300000011920929,
			['delay2'] = 0,
			['delay3'] = 0.400000005960464,
			['delay4'] = 0,
			['delay5'] = 0.200000002980232,
			['delay6'] = 0.025000000372529,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 153
		},
		[27] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.300000011920929, [2] = 0, [3] = 0.400000005960464, [4] = 0, [5] = 0.200000002980232, [6] = 0.025000000372529}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['end_color'] = {0.3882353,0.8313726,0.3803922,1},
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
			['happen_frame'] = 153
		},
		[28] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0.300000011920929, [2] = 0, [3] = 0.400000005960464, [4] = 0, [5] = 0.200000002980232, [6] = 0.025000000372529}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
		[29] = {
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
			['happen_frame'] = 164
		},
		[30] = {
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
			['happen_frame'] = 164
		},
		[31] = {
			['hit_segment'] = 6,
			['delay1'] = 0,
			['delay2'] = 0.0500000007450581,
			['delay3'] = 0.100000001490116,
			['delay4'] = 0.150000005960464,
			['delay5'] = 0.200000002980232,
			['delay6'] = 0.25,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 172
		},
		[32] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.100000001490116, [4] = 0.150000005960464, [5] = 0.200000002980232, [6] = 0.25}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['end_color'] = {0.3882353,0.8313726,0.3803922,1},
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
			['happen_frame'] = 172
		},
		[33] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.100000001490116, [4] = 0.150000005960464, [5] = 0.200000002980232, [6] = 0.25}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['happen_frame'] = 173
		},
		[34] = {
			['spell_action_type'] = 'CaculateDeath',
			['happen_frame'] = 206
		},
		[35] = {
			['spell_action_type'] = 'SpellEnd',
			['happen_frame'] = 210
		}
	}
}