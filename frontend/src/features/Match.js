import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom';
import RugbyApi from '../api/api';
import PlayerMatchCard from '../components/PlayerMatchCard';

const Match = () => {
    const {match_id} = useParams()
    const [matchInfo, setMatchInfo] = useState([])
    const [players, setPlayers] = useState([])

    useEffect(() => {
        async function getMatchInfo(){
            try{
                const match = await RugbyApi.getMatchInfo(match_id)
                setMatchInfo(match);
            }catch (e){
                throw new Error(e);
            }
        }
        getMatchInfo();
    }, []);

    useEffect(() => {
        async function getPlayersFromMatch(){
            try{
                const players = await RugbyApi.getPlayersFromMatch(match_id)
                setPlayers(players)
            } catch(e){
                throw new Error(e)
            }
        }
        getPlayersFromMatch()
    }, [])

    // for(let player of players){
    //     if(player.team_id === matchInfo.home_team_id) homeTeamPlayers.push(player)
    //     else awayTeamPlayers.push(player)
    // }
    // console.log(homeTeamPlayers[0])

    const homeTeamPlayers = players.filter(player => player.team_id === matchInfo.home_team_id);
    const awayTeamPlayers = players.filter(player => player.team_id === matchInfo.away_team_id);

  return (
    <div className='match-main'>
        <div className='match-container'>
            <div className='match-header'>
                {matchInfo.match_date} {matchInfo.match_id}
            </div>
            <div className='match-info-container'>
                <div className='home-container'>
                    <div className='team-name'>{matchInfo.home_team_name}</div>
                    <div className='team-score'>{matchInfo.home_team_score}</div>
                    <div className='team-players'>
                        {homeTeamPlayers.map(player => (
                            <PlayerMatchCard 
                                key={player.player_id}
                                match_id={player.match_id}
                                player_id={player.player_id}
                                player_index_score={player.player_index_score}
                                player_name={player.player_name}
                                player_position={player.player_position}
                                team_id={player.team_id}
                                team_name={player.team_name}
                            />
                        ))}
                    </div>
                </div>
                <div className='away-container'>
                    <div className='team-name'>{matchInfo.away_team_name}</div>
                    <div className='team-score'>{matchInfo.away_team_score}</div>
                    <div className='team-players'>
                        {awayTeamPlayers.map(player => (
                            <PlayerMatchCard 
                                key={player.player_id}
                                match_id={player.match_id}
                                player_id={player.player_id}
                                player_index_score={player.player_index_score}
                                player_name={player.player_name}
                                player_position={player.player_position}
                                team_id={player.team_id}
                                team_name={player.team_name}
                            />
                        ))}
                    </div>
                </div>

            </div>
        </div>
    </div>
  )
}

export default Match