import React from 'react'

function OffenseCard ({
    carries, 
    carryErrors, 
    goalKicks, 
    goalKickErrors, 
    passes, 
    passErrors, 
    triesScored, 
    lineoutThrows, 
    lineoutThrowErrors, 
    metresCarried
}){
  return (
    <div className='offense-card-main'>
        <div className='offense-card-container'>
            <div className='offense-card-header'>Scoring & Attacking</div>
            <table>
                <tbody>
                    <tr>
                        <td>Carries</td>
                        <td>{carries}</td>
                    </tr>
                    <tr>
                        <td>Carry Errors</td>
                        <td>{carryErrors}</td>
                    </tr>
                    <tr>
                        <td>Goal Kicks</td>
                        <td>{goalKicks}</td>
                    </tr>
                    <tr>
                        <td>Goal Kick Errors</td>
                        <td>{goalKickErrors}</td>
                    </tr>
                    <tr>
                        <td>Passes</td>
                        <td>{passes}</td>
                    </tr>
                    <tr>
                        <td>Pass Errors</td>
                        <td>{passErrors}</td>
                    </tr>
                    <tr>
                        <td>Tries Scored</td>
                        <td>{triesScored}</td>
                    </tr>
                    <tr>
                        <td>Successful Lineout Throws</td>
                        <td>{lineoutThrows}</td>
                    </tr>
                    <tr>
                        <td>Lineout Throw Errors</td>
                        <td>{lineoutThrowErrors}</td>
                    </tr>
                    <tr>
                        <td>Meters Carried</td>
                        <td>{metresCarried}</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
  )
}

export default OffenseCard

// Offense:
// Carries: 4
// Carry Errors: 0
// Goal Kicks Made: 2
// Goal Kicks Errors: 3
// Passes: 20
// Pass Errors: 0
// Tries Scored: 1
// Lineout Throw Errors: 0
// Lineout Throws: 0
// Metres Carried: 0