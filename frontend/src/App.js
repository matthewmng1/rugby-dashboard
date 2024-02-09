import { BrowserRouter } from "react-router-dom";
import Routes from "./routes/Routes"
import './App.css';

function App() {
  return (
    <BrowserRouter>
      <div className="App">
        <Routes/>
      </div>
    </BrowserRouter>
  );
}

export default App;
