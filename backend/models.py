from flask_sqlalchemy import SQLAlchemy

db = SQLAlchemy()

def connect_db(app):
	db.app = app
	db.init_app(app)

class Match(db.Model):
    __tablename__ = "match_data"
    match_id = db.Column(db.Integer, primary_key=True)
    match_date = db.Column(db.Date, nullable=False)
    team_1_id = db.Column(db.Integer, nullable=False)
    team_2_id = db.Column(db.Integer, nullable=False)
    team_1_name = db.Column(db.Text, nullable=False)
    team_2_name = db.Column(db.Text, nullable=False)
    team_1_score = db.Column(db.Integer, nullable=False)
    team_2_score = db.Column(db.Integer, nullable=False)

    teams = db.relationship('Team', backref='match_data', lazy=True)
    players = db.relationship('Player', backref='match_data', lazy=True)


class Team(db.Model):
	__tablename__ = "team_match_data"
	match_id = db.Column(db.Integer, db.ForeignKey('match_data.match_id'))
	team_id = db.Column(db.Integer, nullable=False, primary_key=True)
	team_name = db.Column(db.Text, nullable=False)
	team_score = db.Column(db.Integer, nullable=False)

class Player(db.Model):
	__tablename__ = "player_match_data"
	match_id = db.Column(db.Integer, db.ForeignKey('match_data.match_id'))
	team_id = db.Column(db.Integer, nullable=False)
	team_name = db.Column(db.Text, nullable=False)
	player_id = db.Column(db.Integer, nullable=False, primary_key=True)
	player_name = db.Column(db.Text, nullable=False)
	player_position = db.Column(db.Text, nullable=False)
	player_minutesplayed = db.Column(db.Integer, nullable=False)
	player_index_score = db.Column(db.Numeric, nullable=False)
	tackles = db.Column(db.Integer, nullable=False)
	tackle_errors = db.Column(db.Integer, nullable=False)
	carries = db.Column(db.Integer, nullable=False)
	carry_errors = db.Column(db.Integer, nullable=False)
	metres_carried = db.Column(db.Integer, nullable=False)
	passes = db.Column(db.Integer, nullable=False)
	pass_errors = db.Column(db.Integer, nullable=False)
	tries_scored = db.Column(db.Integer, nullable=False)
	ruck_entries = db.Column(db.Integer, nullable=False)
	ruck_errors = db.Column(db.Integer, nullable=False)
	lineout_throws = db.Column(db.Integer, nullable=False)
	lineout_throw_errors = db.Column(db.Integer, nullable=False)
	lineout_contests_won = db.Column(db.Integer, nullable=False)
	lineout_contest_errors = db.Column(db.Integer, nullable=False)
	goal_kicks_made = db.Column(db.Integer, nullable=False)
	goal_kicks_errors = db.Column(db.Integer, nullable=False)
	kicks = db.Column(db.Integer, nullable=False)
	kick_errors = db.Column(db.Integer, nullable=False)
	reception_success = db.Column(db.Integer, nullable=False)
	reception_failure = db.Column(db.Integer, nullable=False)