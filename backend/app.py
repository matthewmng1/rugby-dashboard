import os
from flask import Flask; 
from flask_sqlalchemy import SQLAlchemy;
from routes.match_routes import register_match_routes
from routes.team_routes import register_team_routes
from routes.player_routes import register_player_routes
from models import db, connect_db
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

app.config['SECRET_KEY'] = "abcdef"

app.config['SQLALCHEMY_DATABASE_URI'] = 'postgresql:///rugbydb'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = connect_db(app)

register_match_routes(app)
register_team_routes(app)
register_player_routes(app)


if __name__ == "__main__": # just added for development. In production, debug=False or remove
    # app.run(debug=True)
    app.run(host="localhost", port=8000, debug=True)

