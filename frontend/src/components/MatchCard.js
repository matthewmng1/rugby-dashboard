import React from "react";
import { Link } from "react-router-dom";


function MatchCard({
    match_id, 
    match_date, 
    home_team_name, 
    away_team_name, 
    home_team_score, 
    away_team_score
}){
  
  return (
    <Link to={`/match/${match_id}`} className="matchcard-link">
      <li className="matchcard">
        <div className="matchcard-content">
          <div className="match-date">{new Date(match_date).toLocaleDateString("en-US", {
              year: "numeric",
              month: "long",
              day: "numeric"
            })}
          </div>
          <div className="home-team-name">{home_team_name}</div>
          <div className="hometeam-score">{home_team_score}</div>
          <p>-</p>
          <div className="awayteam-score">{away_team_score}</div>
          <div className="away-team-name">{away_team_name}</div>
        </div>
      </li>
    </Link>
  );
}

export default MatchCard