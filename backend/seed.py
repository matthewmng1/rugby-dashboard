import psycopg2 
import os

# Connect to the default PostgreSQL database
conn_default = psycopg2.connect(database="postgres", user='matthewng', password='password', host='127.0.0.1', port='5432')
conn_default.autocommit = True  # Set autocommit to True for executing DDL statements

# Create a cursor for executing SQL commands
cursor_default = conn_default.cursor()

# Drop and recreate the rugbydb database
cursor_default.execute("DROP DATABASE IF EXISTS rugbydb")
cursor_default.execute("CREATE DATABASE rugbydb")

# Close the cursor and connection to the default database
cursor_default.close()
conn_default.close()

csv_file_name = 'match_data.csv'
script_directory = os.path.dirname(os.path.realpath(__file__))
match_csv_path_file = os.path.join(script_directory, 'CSV/match_data.csv')
team_csv_path_file = os.path.join(script_directory, 'CSV/team_data.csv')
player_csv_path_file = os.path.join(script_directory, 'CSV/player_data.csv')
  
conn = psycopg2.connect(database="rugbydb", 
                        user='matthewng', password='password',  
                        host='127.0.0.1', port='5432'
) 

conn.autocommit = True
cursor = conn.cursor()
  
sqlMatch = '''CREATE TABLE MATCH_DATA(
  match_id int PRIMARY KEY,\
  match_date DATE,\
  team_1_id int NOT NULL,\
  team_2_id int NOT NULL,\
  team_1_name text NOT NULL,\
  team_2_name text NOT NULL,\
  team_1_score int NOT NULL,\
  team_2_score int NOT NULL 
  
  );'''

sqlTeam = '''CREATE TABLE TEAM_MATCH_DATA(
  match_id int,
  team_id int,
  team_name text, 
  team_score int
  );'''
  
sqlPlayer = '''CREATE TABLE PLAYER_MATCH_DATA(
  match_id int,
  team_id int,
  team_name text, 
  player_id int,
  player_name text,
  player_position text,
  player_minutesplayed int,
  player_index_score numeric,
  tackles int,
  tackle_errors int,
  carries int,
  carry_errors int,
  metres_carried int,
  passes int,
  pass_errors int,
  tries_scored int,
  ruck_entries int,
  ruck_errors int,
  lineout_throws int,
  lineout_throw_errors int,
  lineout_contests_won int,
  lineout_contest_errors int,
  goal_kicks_made int,
  goal_kicks_errors int,
  kicks int,
  kick_errors int,
  reception_success int,
  reception_failure int
)'''
  
cursor.execute(sqlMatch) 
cursor.execute(sqlTeam) 
cursor.execute(sqlPlayer) 

  
matchCopy = f'''COPY MATCH_DATA(
  match_id,
  match_date,
  team_1_id,
  team_2_id,
  team_1_name,
  team_2_name,
  team_1_score,
  team_2_score) 
FROM '{match_csv_path_file}' 
DELIMITER ',' 
CSV HEADER;'''

teamCopy = f'''COPY TEAM_MATCH_DATA(
  match_id,
  team_id,
  team_name,
  team_score)
FROM '{team_csv_path_file}'
DELIMITER ','
CSV HEADER;'''

playerCopy = f'''COPY PLAYER_MATCH_DATA(
  match_id,
  team_id,
  team_name, 
  player_id,
  player_name,
  player_position,
  player_minutesPlayed,
  player_index_score,
  tackles,
  tackle_errors,
  carries,
  carry_errors,
  metres_carried,
  passes,
  pass_errors,
  tries_scored,
  ruck_entries,
  ruck_errors,
  lineout_throws,
  lineout_throw_errors,
  lineout_contests_won,
  lineout_contest_errors,
  goal_kicks_made,
  goal_kicks_errors,
  kicks,
  kick_errors,
  reception_success,
  reception_failure)
FROM '{player_csv_path_file}'
DELIMITER ','
CSV HEADER;'''

cursor.execute(matchCopy)
cursor.execute(teamCopy)
cursor.execute(playerCopy)

conn.commit() 
conn.close() 