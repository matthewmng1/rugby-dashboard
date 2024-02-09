import React, { useEffect, useState } from 'react'
import { useParams } from 'react-router-dom'
import RugbyApi from '../api/api'
import DefenseCard from '../components/DefenseCard'
import OffenseCard from '../components/OffenseCard'

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
                <div className='statistics-container'>
                    <OffenseCard
                        carries={player.carries}
                        carryErrors={player.carry_errors}
                        goalKicks={player.goal_kicks_made}
                        goalKickErrors={player.goal_kicks_errors}
                        passes={player.passes}
                        passErrors={player.pass_errors}
                        triesScored={player.tries_scored}
                        lineoutThrows={player.lineout_throws}
                        lineoutThrowErrors={player.lineout_throw_errors}
                        metresCarried={player.metres_carried}
                    />
                    <DefenseCard
                        tackles={player.tackles}
                        tackleErrors={player.tackle_errors}
                        kicks={player.kicks}
                        kickErrors={player.kick_errors}
                        lineoutContestsWon={player.lineout_contests_won}
                        lineoutContestErrors={player.lineout_contest_errors}
                        receptionSuccess={player.reception_success}
                        receptionError={player.reception_failure}
                        ruckEntries={player.ruck_entries}
                        ruckErrors={player.ruck_errors}
                    />
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