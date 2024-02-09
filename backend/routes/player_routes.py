from flask import jsonify
from models import Player

def register_player_routes(app):
	@app.route('/get-all-players', methods = ['GET'])
	def get_player_match_data():
		player_data = Player.query.all()
		serialized_data = []

		for player in player_data:
			data = {
				'match_id': player.match_id,
				'team_id': player.team_id,
				'team_name': player.team_name, 
				'player_id': player.player_id,
				'player_name': player.player_name,
				'player_position': player.player_position,
				'player_minutesPlayed': player.player_minutesplayed,
				'player_index_score': player.player_index_score,
				'tackles': player.tackles,
				'tackle_errors': player.tackle_errors,
				'carries': player.carries,
				'carry_errors': player.carry_errors,
				'metres_carried': player.metres_carried,
				'passes': player.passes,
				'pass_errors': player.pass_errors,
				'tries_scored': player.tries_scored,
				'ruck_entries': player.ruck_entries,
				'ruck_errors': player.ruck_errors,
				'lineout_throws': player.lineout_throws,
				'lineout_throw_errors': player.lineout_throw_errors,
				'lineout_contests_won': player.lineout_contests_won,
				'lineout_contest_errors': player.lineout_contest_errors,
				'goal_kicks_made': player.goal_kicks_made,
				'goal_kicks_errors': player.goal_kicks_errors,
				'kicks': player.kicks,
				'kick_errors': player.kick_errors,
				'reception_success': player.reception_success,
				'reception_failure': player.reception_failure
			}
			serialized_data.append(data)
		return jsonify({"Players": serialized_data})
	
	# single playerinfo by id, player_id
	@app.route('/get-player-by-id/<int:player_id>', methods = ['GET'])
	def get_player_by_id(player_id):
		player = Player.query.get(player_id)
		if player:
			serialized_data = {
				'team_name': player.team_name,
				'team_id': player.team_id,
				'player_id': player.player_id,
				'player_name': player.player_name,
				'player_position': player.player_position
			}
		return jsonify(serialized_data)

	# players from a match, match_id
	@app.route('/get-players-by-match/<int:match_id>', methods = ['GET'])
	def get_players_by_match_id(match_id):
		players = Player.query.filter_by(match_id=match_id).all()
		if players:
			serialized_data = []
			for player in players: 
				data = {
					'match_id': player.match_id,
					'team_id': player.team_id,
					'team_name': player.team_name,
					'player_id': player.player_id,
					'player_name': player.player_name,
					'player_position': player.player_position,
					'player_index_score': player.player_index_score
				}
				serialized_data.append(data)
		return jsonify({'players': serialized_data})
		
	# single player match info, player_id and match_id
	@app.route('/get-player-match-data/<int:match_id>/<int:player_id>', methods = ['GET'])
	def get_player_match_data_by_ids(match_id, player_id):
		player = Player.query.filter_by(match_id=match_id,player_id=player_id).all()[0]
		if player: 
			serialized_data = {
				'match_id': player.match_id,
				'team_id': player.team_id,
				'team_name': player.team_name, 
				'player_id': player.player_id,
				'player_name': player.player_name,
				'player_position': player.player_position,
				'player_minutesPlayed': player.player_minutesplayed,
				'player_index_score': player.player_index_score,
				'tackles': player.tackles,
				'tackle_errors': player.tackle_errors,
				'carries': player.carries,
				'carry_errors': player.carry_errors,
				'metres_carried': player.metres_carried,
				'passes': player.passes,
				'pass_errors': player.pass_errors,
				'tries_scored': player.tries_scored,
				'ruck_entries': player.ruck_entries,
				'ruck_errors': player.ruck_errors,
				'lineout_throws': player.lineout_throws,
				'lineout_throw_errors': player.lineout_throw_errors,
				'lineout_contests_won': player.lineout_contests_won,
				'lineout_contest_errors': player.lineout_contest_errors,
				'goal_kicks_made': player.goal_kicks_made,
				'goal_kicks_errors': player.goal_kicks_errors,
				'kicks': player.kicks,
				'kick_errors': player.kick_errors,
				'reception_success': player.reception_success,
				'reception_failure': player.reception_failure
			}
		return jsonify(serialized_data)
		# if player:
			
	# # players from a team in a match, team_id and match_id
	@app.route('/get-team-players-from-match/<int:team_id>/<int:match_id>', methods = ['GET'])
	def get_team_players_from_match(team_id, match_id):
		players = Player.query.filter_by(team_id=team_id,match_id=match_id).all()
		if players:
			serialized_data = []
			for player in players:
				data = {
					'match_id': player.match_id,
					'team_id': player.team_id,
					'team_name': player.team_name,
					'player_id': player.player_id,
					'player_name': player.player_name,
					'player_position': player.player_position,
					'player_index_score': player.player_index_score
				}
				serialized_data.append(data)
		return jsonify(serialized_data)
				
