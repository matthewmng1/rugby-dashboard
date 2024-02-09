import axios from "axios";

const BASE_URL = process.env.REACT_APP_BASE_URL || "http://localhost:8000"

class RugbyApi {

  static async request(endpoint, data = {}, method = "get") {
    console.debug("API Call:", endpoint, data, method);

    const url = `${BASE_URL}${endpoint}`;
    const params = (method === "get")
      ? data
      : {};

    try{
      return (await axios({ url, method, data, params })).data;
    } catch(e){
      console.error("API Error:", e.response);
      let msg = e.response.data.error.msg;
      throw Array.isArray(msg) ? msg : [msg];
    }
  }

  static async getMatches(){
    let res = await this.request(`/get-match-data`);
    return res.Matches;
  }

  static async getMatchInfo(match_id){
    let res = await this.request(`/get-match-data/${match_id}`)
    console.log(res)
    return res
  }

//   static async getTeams(){
//     let res = await this.request(`teams/`);
//     return res.data;
//   }

//   static async getPlayers(){
//     let res = await this.request(`players/`);
//     return res.data
//   }

//   static async playerDash(player_id){
//     let res = await this.request(`players/${player_id}`)
//     return res
//   }

  static async getPlayersFromMatch(match_id){
    let res = await this.request(`/get-players-by-match/${match_id}`);
    // console.log(res.players)
    return res.players;
  }

  static async getPlayerMatchInfo(match_id, player_id){
    let res = await this.request(`/get-player-match-data/${match_id}/${player_id}`)
    console.log(res)
    return res
  }

  // static async getPlayersInfoFromMatch(match_id, team_id){
  //   let res = await this.request(`players/team_players/${match_id}/${team_id}`);
  //   return res.data
  // }
}

export default RugbyApi;