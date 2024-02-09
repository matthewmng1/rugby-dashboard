import React, { useEffect, useState } from 'react'
import RugbyApi from '../api/api';
import MatchCard from '../components/MatchCard';

const Home = () => {
    const [matches, setMatches] = useState([]);
    const [matchInfo, setMatchInfo] = useState([])


  useEffect(() => {
    async function getMatches(){
      try{
        const matches = await RugbyApi.getMatches()
        console.log(matches)
        setMatches(matches);
      }catch (e){
        throw new Error(e);
      }
    }
  getMatches();
  }, []);

    return (
        <div>
          <div>Home</div>
          <div>
            {matches.map(m => (
              <MatchCard 
                key={m.match_id}
                match_id={m.match_id}
                match_date={m.match_date}
                home_team_name={m.home_team_name}
                away_team_name={m.away_team_name} 
                home_team_score={m.home_team_score}
                away_team_score={m.away_team_score}
              />
            ))}
          </div>
        </div>
    )
    // Create a home page
    // Have each match displayed in a box with the team names, scores, date, etc. 
    // Each "box" should be a link that holds the match_id
    // when clicked, takes you to the match page
    // the match page will display all players of each team
      // each player will be a link
      // link to show player info / show match statistics
}

export default Home