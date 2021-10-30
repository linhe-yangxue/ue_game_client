return {
	['spell_id'] = '13500302',
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
			['happen_frame'] = 19
		},
		[6] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 1, ['segment'] = 1, ['ghost_id'] = 0},
			['effect_id'] = '1135003112',
			['is_attach_target'] = true,
			['level_type'] = 'MaxLevel',
			['level_offset'] = 0,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 9, ['unit_body_type_second'] = 2, ['offset_coefficient_first'] = 1.5, ['offset_coefficient_second'] = 2}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['life_time'] = 12,
			['effect_scale'] = 1,
			['vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_vector_scale'] = {1.00, 1.00, 1.00},
			['start_euler'] = {0.00, 0.00, 0.00},
			['enemy_start_euler'] = {0.00, 0.00, 0.00},
			['effect_index'] = 1,
			['spell_action_type'] = 'PlayEffect',
			['happen_frame'] = 28
		},
		[7] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['effect_index'] = 1,
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 2, ['unit_body_type_second'] = 9, ['offset_coefficient_first'] = 1, ['offset_coefficient_second'] = 1}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'EffectMove',
			['happen_frame'] = 29
		},
		[8] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['end_scale'] = 1.29999995231628,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['enemy_end_vector_scale'] = {1.00, 1.00, 1.00},
			['effect_index'] = 1,
			['change_time'] = 9,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'EffectScaleAnim',
			['happen_frame'] = 29
		},
		[9] = {
			['trigger_event_id'] = 2,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'skill', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 32
		},
		[10] = {
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.300000011920929, [3] = 0.600000023841858, [4] = 0, [5] = 0.300000011920929, [6] = 0.600000023841858}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.600000023841858, [4] = 0.600000023841858, [2] = 0.300000011920929, [5] = 0.300000011920929, [3] = 0, [6] = 0}, ['ghost_id'] = 0},
			['cause_event_id'] = 2,
			['spell_action_type'] = 'TriggerAction',
			['happen_frame'] = 32
		},
		[11] = {
			['trigger_event_id'] = 12,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000083',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 36
		},
		[12] = {
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.300000011920929, [3] = 0.600000023841858, [4] = 0, [5] = 0.300000011920929, [6] = 0.600000023841858}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.600000023841858, [4] = 0.600000023841858, [2] = 0.300000011920929, [5] = 0.300000011920929, [3] = 0, [6] = 0}, ['ghost_id'] = 0},
			['cause_event_id'] = 12,
			['spell_action_type'] = 'TriggerAction',
			['happen_frame'] = 36
		},
		[13] = {
			['effect_id'] = '1135003112',
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.300000011920929, [3] = 0.600000023841858, [4] = 0, [5] = 0.300000011920929, [6] = 0.600000023841858}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.600000023841858, [4] = 0.600000023841858, [2] = 0.300000011920929, [5] = 0.300000011920929, [3] = 0, [6] = 0}, ['ghost_id'] = 0},
			['from_pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 2, ['unit_body_type_second'] = 9, ['offset_coefficient_first'] = 1, ['offset_coefficient_second'] = 1}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['to_pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 2, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 1, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['fly_data'] = {['fly_time'] = 0.300000011920929},
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
			['scale_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 1, ['outTangent'] = 1, ['tangentMode'] = 0}
				}
			},
			['effect_scale'] = 1.29999995231628,
			['effect_vector_scale'] = {1.00, 1.00, 1.00},
			['end_scale'] = 1,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['cause_event_id'] = 0,
			['effect_index'] = 0,
			['spell_action_type'] = 'LauchBullet',
			['happen_frame'] = 38
		},
		[14] = {
			['trigger_event_id'] = 11,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000148',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 39
		},
		[15] = {
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.300000011920929, [3] = 0.600000023841858, [4] = 0, [5] = 0.300000011920929, [6] = 0.600000023841858}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.600000023841858, [4] = 0.600000023841858, [2] = 0.300000011920929, [5] = 0.300000011920929, [3] = 0, [6] = 0}, ['ghost_id'] = 0},
			['cause_event_id'] = 11,
			['spell_action_type'] = 'TriggerAction',
			['happen_frame'] = 39
		},
		[16] = {},
		[17] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.300000011920929, [3] = 0.600000023841858, [4] = 0, [5] = 0.300000011920929, [6] = 0.600000023841858}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['happen_frame'] = 42
		},
		[18] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.300000011920929, [3] = 0.600000023841858, [4] = 0, [5] = 0.300000011920929, [6] = 0.600000023841858}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['change_time'] = 6,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 45
		},
		[19] = {
			['hit_segment'] = 1,
			['delay1'] = 0,
			['delay2'] = 0.300000011920929,
			['delay3'] = 0.600000023841858,
			['delay4'] = 0,
			['delay5'] = 0.300000011920929,
			['delay6'] = 0.600000023841858,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 47
		},
		[20] = {},
		[21] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.300000011920929, [3] = 0.600000023841858, [4] = 0, [5] = 0.300000011920929, [6] = 0.600000023841858}, ['use_opposite'] = false, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 47
		},
		[22] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000108',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 47
		},
		[23] = {
			['trigger_event_id'] = 3,
			['trigger_event_delay'] = 0,
			['shake_time'] = 0.100000001490116,
			['shake_range'] = 0.300000011920929,
			['spell_action_type'] = 'ShakeScreen',
			['happen_frame'] = 47
		},
		[24] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000079',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 47
		},
		[25] = {
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.300000011920929, [3] = 0.600000023841858, [4] = 0, [5] = 0.300000011920929, [6] = 0.600000023841858}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.600000023841858, [4] = 0.600000023841858, [2] = 0.300000011920929, [5] = 0.300000011920929, [3] = 0, [6] = 0}, ['ghost_id'] = 0},
			['cause_event_id'] = 13,
			['spell_action_type'] = 'TriggerAction',
			['happen_frame'] = 47
		},
		[26] = {
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.300000011920929, [3] = 0.600000023841858, [4] = 0, [5] = 0.300000011920929, [6] = 0.600000023841858}, ['use_opposite'] = true, ['enemy_delay_list'] = {[1] = 0.600000023841858, [4] = 0.600000023841858, [2] = 0.300000011920929, [5] = 0.300000011920929, [3] = 0, [6] = 0}, ['ghost_id'] = 0},
			['cause_event_id'] = 3,
			['spell_action_type'] = 'TriggerAction',
			['happen_frame'] = 47
		},
		[27] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['use_delay'] = true, ['delay_list'] = {[1] = 0, [2] = 0.300000011920929, [3] = 0.600000023841858, [4] = 0, [5] = 0.300000011920929, [6] = 0.600000023841858}, ['use_opposite'] = false, ['ghost_id'] = 0},
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
			['happen_frame'] = 50
		},
		[28] = {},
		[29] = {},
		[30] = {},
		[31] = {},
		[32] = {},
		[33] = {},
		[34] = {
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
			['happen_frame'] = 102
		},
		[35] = {
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
			['happen_frame'] = 102
		},
		[36] = {
			['spell_action_type'] = 'CaculateDeath',
			['happen_frame'] = 113
		},
		[37] = {
			['spell_action_type'] = 'SpellEnd',
			['happen_frame'] = 115
		}
	}
}