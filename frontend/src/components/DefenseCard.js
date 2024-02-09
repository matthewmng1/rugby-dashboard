import React from 'react'

function DefenseCard({
    tackles,
    tackleErrors,
    kicks,
    kickErrors,
    lineoutContestsWon,
    lineoutContestErrors,
    receptionSuccess,
    receptionError,
    ruckEntries,
    ruckErrors
}) {
  return (
    <div className='defense-card-main'>
        <div className='defense-card-container'>
            <div className='defense-card-header'>Defending & Tactical</div>
            <table>
                <tbody>
                    <tr>
                        <td>Tackles</td>
                        <td>{tackles}</td>
                    </tr>
                    <tr>
                        <td>Tackle Errors</td>
                        <td>{tackleErrors}</td>
                    </tr>
                    <tr>
                        <td>Kicks</td>
                        <td>{kicks}</td>
                    </tr>
                    <tr>
                        <td>Kick Errors</td>
                        <td>{kickErrors}</td>
                    </tr>
                    <tr>
                        <td>Lineout Contests Won</td>
                        <td>{lineoutContestsWon}</td>
                    </tr>
                    <tr>
                        <td>Lineout Contest Errors</td>
                        <td>{lineoutContestErrors}</td>
                    </tr>
                    <tr>
                        <td>Reception Success</td>
                        <td>{receptionSuccess}</td>
                    </tr>
                    <tr>
                        <td>Reception Errors</td>
                        <td>{receptionError}</td>
                    </tr>
                    <tr>
                        <td>Ruck Entries</td>
                        <td>{ruckEntries}</td>
                    </tr>
                    <tr>
                        <td>Ruck Errors</td>
                        <td>{ruckErrors}</td>
                    </tr>
                </tbody>
            </table>
        </div>
    </div>
  )
}

export default DefenseCard



// Defense & Tactical:
// Lineout Contest Errors: 0
// Lineout Contests Won: 0
// Tackle Errors: 2
// Tackles: 10
// Kicks: 10
// Kick Errors: 0
// Reception Success: 5
// Reception Failure: 0
// Ruck Entries: 1
// Ruck Errors: 0
