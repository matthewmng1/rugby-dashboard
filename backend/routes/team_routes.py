from flask import jsonify
from models import Team

def register_team_routes(app):
	@app.route('/get-team-match-data', methods = [ 'GET' ])
	def get_team_match_data():
		team_data = Team.query.all()
		serialized_data = []
		for team in team_data:
			data = {
				'match_id': team.match_id,
				'team_id': team.team_id,
				'team_name': team.team_name,
				'team_score': team.team_score,
			}
			serialized_data.append(data)
		return jsonify({"Teams": serialized_data})
	
	@app.route('/get-team-by-id/<int:team_id>', methods = ['GET'])
	def get_team_by_id(team_id):
		team = Team.query.get(team_id)
		if team:
			serialized_data = {
				'match_id': team.match_id,
				'team_id': team.team_id,
				'team_name': team.team_name,
				'team_score': team.team_score
			}
			return jsonify(serialized_data), 200
		else:
			return jsonify({'error': 'Team not found'}), 404
		
	@app.route('/get-teams-by-match-id/<int:match_id>', methods = ['GET'])
	def get_teams_by_match_id(match_id):
		teams = Team.query.filter_by(match_id=match_id).all()
		if teams:
			serialized_data = []
			for team in teams:
				data = {
					'match_id': team.match_id,
					'team_id': team.team_id,
					'team_name': team.team_name,
					'team_score': team.team_score
				}
				serialized_data.append(data)
			return jsonify({"teams": serialized_data}), 200
		else:
			return jsonify({'error': 'Teams not found for the given match_id'}), 404
		
			