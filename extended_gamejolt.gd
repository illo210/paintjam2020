extends "res://addons/gamejolt_api_v2/main.gd"

signal api_fetch_rank(data)

const PARAMETERS_BIS = {
	auth = ['*user_token=', '*username='],
	fetch_user = ['*username=', '*user_id='],
	sessions = ['*username=', '*user_token='],
	trophy_fetch = ['*username=', '*user_token=', '*achieved=', '*trophy_id='],
	trophy_add = ['*username=', '*user_token=', '*trophy_id='],
	scores_fetch = ['*username=', '*user_token=', '*limit=', '*table_id='],
	scores_add = ['*score=', '*sort=', '*username=', '*user_token=', '*guest=', '*table_id='],
	fetch_tables = [],
	fetch_rank = ['*sort=', '*table_id='],
	fetch_data = ['*key=', '*username=', '*user_token='],
	set_data = ['*key=', '*data=', '*username=', '*user_token='],
	update_data = ['*key=', '*operation=', '*value=', '*username=', '*user_token='],
	remove_data = ['*key='],
	get_data_keys = ['*username=', '*user_token=']
}
const BASE_URLS_BIS = { 
	auth = 'http://gamejolt.com/api/game/v1/users/auth/',
	fetch_user = 'http://gamejolt.com/api/game/v1/users/',
	session_open = 'http://gamejolt.com/api/game/v1/sessions/open/',
	session_ping = 'http://gamejolt.com/api/game/v1/sessions/ping/',
	session_close = 'http://gamejolt.com/api/game/v1/sessions/close/',
	trophy = 'http://gamejolt.com/api/game/v1/trophies/',
	trophy_add = 'http://gamejolt.com/api/game/v1/trophies/add-achieved/',
	scores_fetch = 'http://gamejolt.com/api/game/v1/scores/',
	scores_add = 'http://gamejolt.com/api/game/v1/scores/add/',
	fetch_tables = 'http://gamejolt.com/api/game/v1/scores/tables/',
	fetch_rank = 'http://api.gamejolt.com/api/game/v1_2/scores/get-rank/',
	fetch_data = 'http://gamejolt.com/api/game/v1/data-store/',
	set_data = 'http://gamejolt.com/api/game/v1/data-store/set/',
	update_data = 'http://gamejolt.com/api/game/v1/data-store/update/',
	remove_data = 'http://gamejolt.com/api/game/v1/data-store/remove/',
	get_data_keys = 'http://gamejolt.com/api/game/v1/data-store/get-keys/'
}

func get_ranking(score, table_id=48992):
	if busy: return
	busy = true
	var url = compose_url('fetch_rank/fetch_rank/fetch_rank', [score, table_id])
	request(url)
	pass
	
func compose_url(type, args):
	var types = type.split('/')
	request_type = types[2]
	var final_url = BASE_URLS_BIS[types[1]]
	var c = -1 # at this point of coding one of my earbuds died. one-eared music :(
	var empty_counter = 0
	for i in PARAMETERS_BIS[types[0]]:
		c += 1
		if !str(args[c]).empty() and str(args[c]) != '0':
			empty_counter += 1
			if empty_counter == 1:
				var parameter = i.replace('*', '?')
				final_url += parameter + str(args[c]).percent_encode()
			else:
				var parameter = i.replace('*', '&')
				final_url += parameter + str(args[c]).percent_encode()
	if empty_counter == 0:
		final_url += '?format=json'
	else:
		final_url += '&format=json'
	final_url += '&game_id=' + str(game_id)
	var s = final_url + private_key
	s = s.md5_text()
	print(final_url + '&signature=' + s)
	return final_url + '&signature=' + s
