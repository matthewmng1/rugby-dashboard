from flask import jsonify
from models import Match

def register_match_routes(app):
	@app.route('/get-match-data', methods = [ 'GET' ])
	def get_match_data():
		match_data = Match.query.all()
		serialized_data = []

		for match in match_data:
			data = {
				'match_id': match.match_id,
				'match_date': match.match_date.strftime('%Y-%m-%d'),
				'home_team_id': match.team_1_id,
				'away_team_id': match.team_2_id,
				'home_team_name': match.team_1_name,
				'away_team_name': match.team_2_name,
				'home_team_score': match.team_1_score,
				'away_team_score': match.team_2_score
			}
			serialized_data.append(data)
		return jsonify({"Matches": serialized_data})
	
	@app.route('/get-match-data/<int:match_id>', methods = ['GET'])
	def get_match_data_by_id(match_id):
		match = Match.query.get(match_id)
		if match:
			serialized_data = {
				'match_id': match.match_id,
				'match_date': match.match_date.strftime('%Y-%m-%d'),
				'home_team_id': match.team_1_id,
				'away_team_id': match.team_2_id,
				'home_team_name': match.team_1_name,
				'away_team_name': match.team_2_name,
				'home_team_score': match.team_1_score,
				'away_team_score': match.team_2_score
			}
			return jsonify(serialized_data), 200
		else:
			return jsonify({'error': 'Match not found'}), 404

	



    