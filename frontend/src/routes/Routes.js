import React from 'react'
import { Route, Routes } from 'react-router-dom'
import Home from '../features/Home'
import Match from '../features/Match'
import Player from '../features/Player'

const AppRoutes = () => {
  return (
    <div>
        <Routes>
            <Route path="/" element={<Home/>}/>
            <Route path="/match/:match_id" element={<Match/>}/>
            <Route path="/match/:match_id/player/:player_id" element={<Player/>}/>
        </Routes>
    </div>
  )
}

export default AppRoutes