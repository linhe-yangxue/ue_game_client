return {
	['spell_id'] = '11101201',
	['groups'] = {
		[1] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = -4, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.75657153129578, ['outTangent'] = 2.75657153129578, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.042315848171711, ['outTangent'] = 0.042315848171711, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 1
		},
		[2] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'attack', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 26
		},
		[3] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'attack', ['anim_speed'] = 1},
			['anim_name'] = '',
			['according_anim_name'] = true,
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 1, ['inTangent'] = -0.961069583892822, ['outTangent'] = -0.961069583892822, ['tangentMode'] = 0},
					[2] = {['time'] = 0.175152584910393, ['value'] = 1.00066208839417, ['inTangent'] = -0.122492380440235, ['outTangent'] = -0.122492380440235, ['tangentMode'] = 0},
					[3] = {['time'] = 0.232590973377228, ['value'] = -0.0865835100412369, ['inTangent'] = 0.34815901517868, ['outTangent'] = 0.34815901517868, ['tangentMode'] = 0},
					[4] = {['time'] = 0.384150236845016, ['value'] = 0.00275713205337524, ['inTangent'] = 0.942464828491211, ['outTangent'] = 0.942464828491211, ['tangentMode'] = 0},
					[5] = {['time'] = 0.39596027135849, ['value'] = 1.4421694278717, ['inTangent'] = 0.484756022691727, ['outTangent'] = 0.484756022691727, ['tangentMode'] = 0},
					[6] = {['time'] = 0.527270615100861, ['value'] = 0.172660410404205, ['inTangent'] = -0.80141544342041, ['outTangent'] = -0.80141544342041, ['tangentMode'] = 0},
					[7] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.915470004081726, ['outTangent'] = 0.915470004081726, ['tangentMode'] = 0}
				}
			},
			['last_time'] = 30,
			['spell_action_type'] = 'SetAnimSpeedCurve',
			['happen_frame'] = 26
		},
		[4] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['rotate_model'] = false,
			['end_euler'] = {0.00, 0.00, 12.00},
			['enemy_end_euler'] = {0.00, 0.00, -12.00},
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0.0595555603504181, ['outTangent'] = 0.0595555603504181, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 2.41199445724487, ['outTangent'] = 2.41199445724487, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitRotateAnim',
			['happen_frame'] = 37
		},
		[5] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = -0.5, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.44177794456482, ['outTangent'] = 2.44177794456482, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0282101277261972, ['outTangent'] = 0.0282101277261972, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 38
		},
		[6] = {
			['effect_id'] = '1111012029',
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['from_pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 11, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 6, ['offset_coefficient_first'] = 2.40000009536743, ['offset_coefficient_second'] = 1.20000004768372}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['to_pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 10, ['ghost_id'] = 0, ['unit_body_type_first'] = 7, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 2.40000009536743, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['fly_data'] = {['fly_speed'] = 100},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 0.0303396284580231, ['outTangent'] = 0.0303396284580231, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 2.58677840232849, ['outTangent'] = 2.58677840232849, ['tangentMode'] = 0}
				}
			},
			['scale_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.41200017929077, ['outTangent'] = 2.41200017929077, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0584728009998798, ['outTangent'] = 0.0584728009998798, ['tangentMode'] = 0}
				}
			},
			['effect_scale'] = 0.5,
			['effect_vector_scale'] = {1.00, 1.00, 1.00},
			['end_scale'] = 4,
			['end_vector_scale'] = {1.00, 1.00, 1.00},
			['cause_event_id'] = 1,
			['effect_index'] = 0,
			['spell_action_type'] = 'LauchBullet',
			['happen_frame'] = 39
		},
		[7] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['rotate_model'] = false,
			['end_euler'] = {0.00, 0.00, 0.00},
			['enemy_end_euler'] = {0.00, 0.00, 0.00},
			['target_type'] = {['target_type'] = 2, ['segment'] = 1, ['ghost_id'] = 0},
			['change_time'] = 3,
			['change_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.69914293289185, ['outTangent'] = 2.69914293289185, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0303391981869936, ['outTangent'] = 0.0303391981869936, ['tangentMode'] = 0}
				}
			},
			['spell_action_type'] = 'UnitRotateAnim',
			['happen_frame'] = 40
		},
		[8] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2100007',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 41
		},
		[9] = {
			['trigger_event_id'] = 1,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 5, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 6, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 1, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.79650068283081, ['outTangent'] = 2.79650068283081, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 8.71310840011574E-06, ['outTangent'] = 8.71310840011574E-06, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 44
		},
		[10] = {
			['trigger_event_id'] = 1,
			['trigger_event_delay'] = 1,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 5, ['segment'] = 1, ['ghost_id'] = 0},
			['pos_data'] = {['condition'] = 1, ['pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['second_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}, ['third_pos'] = {['pos_type'] = 1, ['ghost_id'] = 0, ['unit_body_type_first'] = 1, ['unit_body_type_second'] = 1, ['offset_coefficient_first'] = 0, ['offset_coefficient_second'] = 0}},
			['change_time'] = 15,
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.14400029182434, ['outTangent'] = 2.14400029182434, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0.0527213849127293, ['outTangent'] = 0.0527213849127293, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 45
		},
		[11] = {
			['trigger_event_id'] = 1,
			['trigger_event_delay'] = 0,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['end_color'] = {0.8584906,0.8584906,0.8584906,1},
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
			['happen_frame'] = 45
		},
		[12] = {
			['trigger_event_id'] = 0,
			['trigger_event_delay'] = 0,
			['sound_id'] = '2200007',
			['sound_size'] = 1,
			['spell_action_type'] = 'PlaySound',
			['happen_frame'] = 45
		},
		[13] = {
			['trigger_event_id'] = 1,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 5, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['spell_action_type'] = 'PlayAnim',
			['happen_frame'] = 48
		},
		[14] = {
			['trigger_event_id'] = 1,
			['trigger_event_delay'] = 0,
			['target_type'] = {['target_type'] = 5, ['segment'] = 1, ['ghost_id'] = 0},
			['anim_data'] = {['anim_name'] = 'hit', ['anim_speed'] = 1},
			['anim_name'] = '',
			['according_anim_name'] = true,
			['speed_curve'] = {
				['preWrapMode'] = 8,
				['postWrapMode'] = 8,
				['keys'] = {
					[1] = {['time'] = 0, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[2] = {['time'] = 0.0980398282408714, ['value'] = 0.996443927288055, ['inTangent'] = -0.410678893327713, ['outTangent'] = -0.410678893327713, ['tangentMode'] = 0},
					[3] = {['time'] = 0.178650587797165, ['value'] = 0.09466552734375, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0},
					[4] = {['time'] = 0.23925444483757, ['value'] = 0.0981961563229561, ['inTangent'] = 0.00542766693979502, ['outTangent'] = 0.00542766693979502, ['tangentMode'] = 0},
					[5] = {['time'] = 0.567603409290314, ['value'] = 0.997108042240143, ['inTangent'] = 0.249691128730774, ['outTangent'] = 0.249691128730774, ['tangentMode'] = 0},
					[6] = {['time'] = 1, ['value'] = 1.00595855712891, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['last_time'] = 30,
			['spell_action_type'] = 'SetAnimSpeedCurve',
			['happen_frame'] = 48
		},
		[15] = {
			['trigger_event_id'] = 1,
			['trigger_event_delay'] = 0.129999995231628,
			['replace_action'] = false,
			['target_type'] = {['target_type'] = 3, ['segment'] = 1, ['ghost_id'] = 0},
			['end_color'] = {0,0.5951867,1,1},
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
			['happen_frame'] = 48
		},
		[16] = {
			['trigger_event_id'] = 1,
			['trigger_event_delay'] = 0.300000011920929,
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
			['happen_frame'] = 53
		},
		[17] = {
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
					[1] = {['time'] = 0, ['value'] = 0, ['inTangent'] = 2.5356924533844, ['outTangent'] = 2.5356924533844, ['tangentMode'] = 0},
					[2] = {['time'] = 1, ['value'] = 1, ['inTangent'] = 0, ['outTangent'] = 0, ['tangentMode'] = 0}
				}
			},
			['shadow_fllow_type'] = 'NormalFollow',
			['is_limit_edge'] = false,
			['limit_edge_offset_left'] = 0,
			['limit_edge_offset_right'] = 0,
			['spell_action_type'] = 'UnitMove',
			['happen_frame'] = 80
		},
		[18] = {
			['spell_action_type'] = 'CaculateDeath',
			['happen_frame'] = 124
		},
		[19] = {
			['spell_action_type'] = 'SpellEnd',
			['happen_frame'] = 129
		}
	}
}