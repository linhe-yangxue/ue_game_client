return {
	['spell_id'] = '11406103',
	['groups'] = {
		[1] = {
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
		[4] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 4, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1200000000',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 12, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
			['target_type'] = {['target_type'] = 4, ['segment'] = 1, ['ghost_id'] = 0},
			['spell_action_type'] = 'ShowSpellName',
			['happen_frame'] = 18
		},
		[7] = {
			['left_pos'] = {0.00, 0.00, 0.00},
			['right_pos'] = {0.00, 0.00, 0.00},
			['spell_action_type'] = 'ShowTogherAttackEffect',
			['happen_frame'] = 25
		},
		[8] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = -6, ['offset_coefficient_second'] = -1, ['fix_pos'] = {10.80, 4.60, 0.00}, ['enemy_fix_pos'] = {-8.95, -26.30, 0.00}}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.35457158088684, ['outTangent'] = 2.35457158088684, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 87
		},
		[9] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 4, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = -5, ['offset_coefficient_second'] = -2, ['fix_pos'] = {10.80, 4.60, 0.00}, ['enemy_fix_pos'] = {-8.95, -26.30, 0.00}}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.35457158088684, ['outTangent'] = 2.35457158088684, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 91
		},
		[10] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'skill', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 112
		},
		[11] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1114061011',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 7, ['offset_coefficient_first'] = 0.800000011920929, ['offset_coefficient_second'] = 2.29999995231628}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 96,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 100,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 125
		},
		[12] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_euler'] = {0.00, 0.00, 15.00},
			['enemy_end_euler'] = {0.00, 180.00, 15.00},
			['effect_index'] = 100,
			['change_time'] = 15,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.61300039291382, ['outTangent'] = 2.61300039291382, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0510476678609848, ['outTangent'] = 0.0510476678609848, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectRotateAnim',
			['happen_frame'] = 126
		},
		[13] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 131
		},
		[14] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.7830189,0.7830189,0.7830189,1},
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
			['happen_frame'] = 131
		},
		[15] = {
			['hit_segment'] = 1,
			['delay1'] = 0,
			['delay2'] = 0.0500000007450581,
			['delay3'] = 0.200000002980232,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.100000001490116,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = true,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 131
		},
		[16] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.945098,0.4139002,0,1},
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
			['happen_frame'] = 132
		},
		[17] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
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
			['happen_frame'] = 135
		},
		[18] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_euler'] = {0.00, 0.00, -15.00},
			['enemy_end_euler'] = {0.00, 180.00, -15.00},
			['effect_index'] = 100,
			['change_time'] = 30,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.042315848171711, ['outTangent'] = 0.042315848171711, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectRotateAnim',
			['happen_frame'] = 141
		},
		[19] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 142
		},
		[20] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.7830189,0.7830189,0.7830189,1},
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
			['happen_frame'] = 142
		},
		[21] = {
			['hit_segment'] = 2,
			['delay1'] = 0,
			['delay2'] = 0.0500000007450581,
			['delay3'] = 0.200000002980232,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.100000001490116,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = true,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 142
		},
		[22] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.945098,0.4139002,0,1},
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
			['happen_frame'] = 143
		},
		[23] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
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
			['happen_frame'] = 146
		},
		[24] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 153
		},
		[25] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.7830189,0.7830189,0.7830189,1},
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
		[26] = {
			['hit_segment'] = 3,
			['delay1'] = 0,
			['delay2'] = 0.0500000007450581,
			['delay3'] = 0.200000002980232,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.100000001490116,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = true,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 153
		},
		[27] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.945098,0.4139002,0,1},
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
			['happen_frame'] = 154
		},
		[28] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
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
			['happen_frame'] = 157
		},
		[29] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 165
		},
		[30] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.7830189,0.7830189,0.7830189,1},
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
			['happen_frame'] = 165
		},
		[31] = {
			['hit_segment'] = 4,
			['delay1'] = 0,
			['delay2'] = 0.0500000007450581,
			['delay3'] = 0.200000002980232,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.100000001490116,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = true,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 165
		},
		[32] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.945098,0.4139002,0,1},
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
			['happen_frame'] = 166
		},
		[33] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
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
			['happen_frame'] = 169
		},
		[34] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_euler'] = {0.00, 0.00, 15.00},
			['enemy_end_euler'] = {0.00, 180.00, 15.00},
			['effect_index'] = 100,
			['change_time'] = 30,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.042315848171711, ['outTangent'] = 0.042315848171711, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectRotateAnim',
			['happen_frame'] = 171
		},
		[35] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 177
		},
		[36] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.7830189,0.7830189,0.7830189,1},
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
			['happen_frame'] = 177
		},
		[37] = {
			['hit_segment'] = 5,
			['delay1'] = 0,
			['delay2'] = 0.0500000007450581,
			['delay3'] = 0.200000002980232,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.100000001490116,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = true,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 177
		},
		[38] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.945098,0.4139002,0,1},
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
			['happen_frame'] = 178
		},
		[39] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 4, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'skill_heji', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 180
		},
		[40] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
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
			['happen_frame'] = 181
		},
		[41] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 189
		},
		[42] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.7830189,0.7830189,0.7830189,1},
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
			['happen_frame'] = 189
		},
		[43] = {
			['hit_segment'] = 6,
			['delay1'] = 0,
			['delay2'] = 0.0500000007450581,
			['delay3'] = 0.200000002980232,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.100000001490116,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = true,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 189
		},
		[44] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.945098,0.4139002,0,1},
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
			['happen_frame'] = 190
		},
		[45] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
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
			['happen_frame'] = 193
		},
		[46] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1114052016',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 12, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 2.40000009536743, ['offset_coefficient_second'] = 0.800000011920929}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 27,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 180.00},
			['enemy_start_euler'] = {0.00, 0.00, -180.00},
			['effect_index'] = 101,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 196
		},
		[47] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_euler'] = {0.00, 0.00, 0.00},
			['enemy_end_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 101,
			['change_time'] = 13,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectRotateAnim',
			['happen_frame'] = 197
		},
		[48] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['effect_index'] = 101,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0, ['fix_pos'] = {10.80, 4.60, 0.00}, ['enemy_fix_pos'] = {-8.95, -26.30, 0.00}}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 26,
			['move_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1.44720005989075, ['outTangent'] = 1.44720005989075, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = -1.43837451934814, ['outTangent'] = -1.43837451934814, ['tangentMode'] = 0}
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
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'EffectMove',
			['happen_frame'] = 197
		},
		[49] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_euler'] = {0.00, 0.00, 0.00},
			['enemy_end_euler'] = {0.00, 180.00, 0.00},
			['effect_index'] = 100,
			['change_time'] = 20,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.61300039291382, ['outTangent'] = 2.61300039291382, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0510476678609848, ['outTangent'] = 0.0510476678609848, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectRotateAnim',
			['happen_frame'] = 201
		},
		[50] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 201
		},
		[51] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.7830189,0.7830189,0.7830189,1},
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
			['happen_frame'] = 201
		},
		[52] = {
			['hit_segment'] = 7,
			['delay1'] = 0,
			['delay2'] = 0.0500000007450581,
			['delay3'] = 0.200000002980232,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.100000001490116,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = true,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 201
		},
		[53] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.945098,0.4139002,0,1},
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
			['happen_frame'] = 202
		},
		[54] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
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
			['happen_frame'] = 205
		},
		[55] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_euler'] = {0.00, 0.00, 180.00},
			['enemy_end_euler'] = {0.00, 0.00, 180.00},
			['effect_index'] = 101,
			['change_time'] = 13,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectRotateAnim',
			['happen_frame'] = 210
		},
		[56] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 213
		},
		[57] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.7830189,0.7830189,0.7830189,1},
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
			['happen_frame'] = 213
		},
		[58] = {
			['hit_segment'] = 8,
			['delay1'] = 0,
			['delay2'] = 0.0500000007450581,
			['delay3'] = 0.200000002980232,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.100000001490116,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = true,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 213
		},
		[59] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.945098,0.4139002,0,1},
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
			['happen_frame'] = 214
		},
		[60] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
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
			['happen_frame'] = 217
		},
		[61] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.7830189,0.7830189,0.7830189,1},
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
			['happen_frame'] = 222
		},
		[62] = {},
		[63] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {0.8867924,0.3879753,0,0.1176471},
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 3.07617425918579, ['outTangent'] = 3.07617425918579, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.103742018342018, ['outTangent'] = 0.103742018342018, ['tangentMode'] = 0}
				}
			},
			['change_time'] = 8,
			['spell_action_type'] = 'MaskColorAnim',
			['happen_frame'] = 223
		},
		[64] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1114052017',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 9, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0, ['fix_pos'] = {10.80, 4.60, 0.00}, ['enemy_fix_pos'] = {-8.95, -26.30, 0.00}}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 48,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 0,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 223
		},
		[65] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.945098,0.4156863,0,1},
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
			['happen_frame'] = 223
		},
		[66] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
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
			['happen_frame'] = 226
		},
		[67] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 227
		},
		[68] = {
			['hit_segment'] = 9,
			['delay1'] = 0,
			['delay2'] = 0.0500000007450581,
			['delay3'] = 0.200000002980232,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.100000001490116,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = true,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 227
		},
		[69] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['end_color'] = {0.7924528,0.7924528,0.7924528,0.2352941},
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
			['happen_frame'] = 231
		},
		[70] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['shake_time'] = 0.400000005960464,
			['shake_range'] = 2,
			['spell_action_type'] = 'ShakeScreen',
			['happen_frame'] = 231
		},
		[71] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {0.7924528,0.7924528,0.1084016,0.2352941},
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
			['happen_frame'] = 233
		},
		[72] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {1,0.5423229,0,0},
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
			['happen_frame'] = 234
		},
		[73] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.7830189,0.7830189,0.7830189,1},
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
			['happen_frame'] = 234
		},
		[74] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.945098,0.4156863,0,1},
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
			['happen_frame'] = 235
		},
		[75] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['end_color'] = {1,0.5423229,0,0.1176471},
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
			['happen_frame'] = 237
		},
		[76] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
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
			['happen_frame'] = 238
		},
		[77] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 244
		},
		[78] = {
			['hit_segment'] = 10,
			['delay1'] = 0,
			['delay2'] = 0.0500000007450581,
			['delay3'] = 0.200000002980232,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.100000001490116,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = true,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 244
		},
		[79] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.7830189,0.7830189,0.7830189,1},
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
			['happen_frame'] = 246
		},
		[80] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.945098,0.4156863,0,1},
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
			['happen_frame'] = 247
		},
		[81] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
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
			['happen_frame'] = 250
		},
		[82] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_color'] = {1,0.5423229,0,0},
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
			['happen_frame'] = 251
		},
		[83] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.7830189,0.7830189,0.7830189,1},
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
			['happen_frame'] = 258
		},
		[84] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.945098,0.4156863,0,1},
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
			['happen_frame'] = 259
		},
		[85] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 261
		},
		[86] = {
			['hit_segment'] = 11,
			['delay1'] = 0,
			['delay2'] = 0.0500000007450581,
			['delay3'] = 0.200000002980232,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.100000001490116,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = true,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 261
		},
		[87] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
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
			['happen_frame'] = 262
		},
		[88] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['spell_action_type'] = 'ShowBuff',
			['happen_frame'] = 269
		},
		[89] = {
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.41200017929077, ['outTangent'] = 2.41200017929077, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0342122800648212, ['outTangent'] = 0.0342122800648212, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 271
		},
		[90] = {
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.35457158088684, ['outTangent'] = 2.35457158088684, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 271
		},
		[91] = {
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
			['happen_frame'] = 271
		},
		[92] = {
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
			['happen_frame'] = 271
		},
		[93] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = true,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.7830189,0.7830189,0.7830189,1},
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
			['happen_frame'] = 277
		},
		[94] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 278
		},
		[95] = {
			['hit_segment'] = 12,
			['delay1'] = 0,
			['delay2'] = 0.0500000007450581,
			['delay3'] = 0.200000002980232,
			['delay4'] = 0.0500000007450581,
			['delay5'] = 0.100000001490116,
			['delay6'] = 0.150000005960464,
			['use_opposite'] = true,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 278
		},
		[96] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
			['end_color'] = {0.945098,0.4156863,0,1},
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
			['happen_frame'] = 278
		},
		[97] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.0500000007450581, [3] = 0.200000002980232, [4] = 0.0500000007450581, [5] = 0.100000001490116, [6] = 0.150000005960464}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.200000002980232, [4] = 0.150000005960464, [2] = 0.0500000007450581, [5] = 0.100000001490116, [3] = 0, [6] = 0.0500000007450581}, ['ghost_id'] = 0},
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
			['happen_frame'] = 281
		},
		[98] = {},
		[99] = {},
		[100] = {},
		[101] = {},
		[102] = {},
		[103] = {},
		[104] = {},
		[105] = {},
		[106] = {},
		[107] = {
			['spell_action_type'] = 'CaculateDeath',
			['happen_frame'] = 321
		},
		[108] = {
			['spell_action_type'] = 'SpellEnd',
			['happen_frame'] = 323
		},
		[109] = {},
		[110] = {},
		[111] = {},
		[112] = {}
	}
}