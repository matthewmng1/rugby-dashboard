import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import RugbyApi from '../api/api'

const Player = () => {
    const { match_id, player_id } = useParams()
    const [player, setPlayer] = useState([])

    console.log(match_id, player_id)
    useEffect(() => {
        async function getPlayerMatchInfo(){
            const player = await RugbyApi.getPlayerMatchInfo(match_id, player_id)
            if(player){
                setPlayer(player)
            }
        }
        getPlayerMatchInfo()
    }, [])

    return (
        <div className='player-main'>
            <div className='player-container'>
                <div className='player-header'>
                    <h1>{player.player_name}</h1>
                    <h2>{player.team_name}</h2>
                    <h3>{player.player_position}</h3>
                </div>
                <div className='player-statistics'>
                    <div className='scoring-container'>
                        {/* two columns, left side has statistic name, right side has numeric value */}
                    </div>
                    <div className='attacking-container'>

                    </div>
                    <div className='defending-container'>

                    </div>
                </div>
            </div>
        </div>
    )
    }

// player main
    // player container
        // player header
            // player name, player position, team
        // player stats
            // overall score
            // total minutes played

            // scoring - tries, try assists, conversion goals, penalty goals, drop goals
            // attacking - passes, carries/runs, metres run, clean breaks, defenders beaten, offloads
            // defending - turnovers conceded, tackles, missed tackles, lineouts won
            // 

export default Player