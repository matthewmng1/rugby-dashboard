import React from 'react'
import { Link } from 'react-router-dom'

function PlayerMatchCard({
    match_id, 
    player_id, 
    player_index_score, 
    player_name, 
    player_position, 
    team_id, 
    team_name
}){
  return (
    <Link to={`/match/${match_id}/player/${player_id}`}>
        <div>
            <div>Name: {player_name}</div>
            <div>Team: {team_name}</div>
            <div>Position: {player_position}</div>
            <div>Match Score: {player_index_score}</div>
        </div>
    </Link>
  )
}

export default PlayerMatchCard