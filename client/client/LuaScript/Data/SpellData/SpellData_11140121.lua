return {
	['spell_id'] = '11140121',
	['groups'] = {
		[1] = {},
		[2] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'attack', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 9
		},
		[3] = {
			['effect_id'] = '1111401211',
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['from_pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 2, ['offset_coefficient_first'] = 1.29999995231628, ['offset_coefficient_second'] = 1}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['to_pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 2, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 1, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['fly_data'] = {['fly_time'] = 0.5},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 0, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['effect_scale'] = 1.20000004768372,
			['effect_vector_scale'] = {1.00, 1.00, 1.00},
			['end_scale'] = 1.5,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['cause_event_id'] = 0,
			['effect_index'] = 0,
			['spell_action_type'] = 'LauchBullet',
			['happen_frame'] = 16
		},
		[4] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2000001',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 16
		},
		[5] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 31
		},
		[6] = {
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
			['happen_frame'] = 31
		},
		[7] = {
			['hit_segment'] = 1,
			['delay1'] = 0,
			['delay2'] = 0,
			['delay3'] = 0,
			['delay4'] = 0,
			['delay5'] = 0,
			['delay6'] = 0,
			['use_opposite'] = false,
			['spell_action_type'] = 'SetHitHappenTime',
			['happen_frame'] = 31
		},
		[8] = {
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
			['change_time'] = 6,
			['is_add'] = false,
			['spell_action_type'] = 'UnitColorAnim',
			['happen_frame'] = 34
		},
		[9] = {
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
			['happen_frame'] = 40
		},
		[10] = {
			['spell_action_type'] = 'CaculateDeath',
			['happen_frame'] = 66
		},
		[11] = {
			['spell_action_type'] = 'SpellEnd',
			['happen_frame'] = 71
		}
	}
}