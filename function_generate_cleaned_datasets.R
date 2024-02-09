library("dplyr")
saracens_vs_bath_original_df <- read.csv("/Users/matthewng/Desktop/projects/portfolio/portfolio-rugby-dashboard/CSVs/271663_batvsar_csv_match_events_plus.csv")
bristol_vs_gloucester_original_df <- read.csv("/Users/matthewng/Desktop/projects/portfolio/portfolio-rugby-dashboard/CSVs/271736_brivglo_csv_match_events_plus.csv")
london_vs_exeter_original_df <- read.csv("/Users/matthewng/Desktop/projects/portfolio/portfolio-rugby-dashboard/CSVs/271725_lonvexe_csv_match_events_plus.csv")
leicester_vs_harlequins_original_df <- read.csv("/Users/matthewng/Desktop/projects/portfolio/portfolio-rugby-dashboard/CSVs/271683_leivhar_csv_match_events_plus.csv")
sale_vs_newcastle_original_df <- read.csv("/Users/matthewng/Desktop/projects/portfolio/portfolio-rugby-dashboard/CSVs/271739_salvnew_csv_match_events_plus.csv")

# function to clean the OvalInsights CSV file
generate_cleaned_datasets <- function(match_csv){
  original_df = match_csv # takes in a loaded csv file and assigns it to original_df
  df = original_df[-c(1:4, 7:18,24:27,30:40,45:48,50, 52:56, 58:60)]
  df[df == ""] = NA
  
  homeTeamId = df[1,3]
  awayTeamId = df[1,5]
  
  homeTeamName = df[1,4]
  awayTeamName = df[1,6]
  
  matchWinnerTeamId = df[1,7]
  matchWinnerTeamName = ""
  matchLosingTeamId = numeric(0)
  matchLosingTeamName = ""
  
  if(homeTeamId == matchWinnerTeamId){
    matchWinnerTeamName = homeTeamName
    matchLosingTeamId = awayTeamId
    matchLosingTeamName = awayTeamName
  } else if (awayTeamId == matchWinnerTeamId){
    matchWinnerTeamName = awayTeamName
    matchingLosingTeamId = homeTeamId
    matchLosingTeamName = homeTeamName
  }
  
  
  original_column_names = colnames(df[17:55]) # slightly clean up column names
  new_column_names = character(length(original_column_names))
  pattern <- "^properties_(propertyGroupName|name|value)_([0-9]+)$"
  for (i in 1:length(original_column_names)) {
    if (grepl(pattern, original_column_names[i])) {
      parts <- unlist(strsplit(original_column_names[i], "_"))
      new_name <- paste(parts[2], parts[3], sep = "_")
      new_column_names[i] <- new_name
    } else {
      new_column_names[i] <- original_column_names[i]
    }
  }
  
  colnames(df)[17:55] = new_column_names[1:39]
  
  shift_values_left <- function(row_data) { # function to shift values to the left
    for (group_num in 1:12) {
      prop_group_col <- paste0("propertyGroupName_", group_num)
      name_col <- paste0("name_", group_num)
      value_col <- paste0("value_", group_num)
      
      if (is.na(row_data[prop_group_col]) || row_data[prop_group_col] == "") {
        next_group_num <- group_num + 1
        while (next_group_num <= 13 && (is.na(row_data[paste0("propertyGroupName_", next_group_num)]) ||
                                        row_data[paste0("propertyGroupName_", next_group_num)] == "")) {
          next_group_num <- next_group_num + 1
        }
        
        if (next_group_num <= 13) {
          row_data[prop_group_col] <- row_data[paste0("propertyGroupName_", next_group_num)]
          row_data[name_col] <- row_data[paste0("name_", next_group_num)]
          row_data[value_col] <- row_data[paste0("value_", next_group_num)]
          
          row_data[paste0("propertyGroupName_", next_group_num)] <- NA
          row_data[paste0("name_", next_group_num)] <- NA
          row_data[paste0("value_", next_group_num)] <- NA
        }
      }
    }
    
    return(row_data)
  }
  
  
  for (row_index in 1:nrow(df)) {
    df[row_index, ] <- shift_values_left(df[row_index, ])
  }
  
  cleaned_df <- df %>%
    select_if(~!all(is.na(.)))
  
  return(cleaned_df)
}

cleaned_df <- generate_cleaned_datasets(csv_file)

# function to generate two separate team lists, each containing $match_events, $efficacy_scores and $player_stats, using the cleaned_df
generate_team_lists <- function(cleaned_df){
  unique_teams <- unique(na.omit(cleaned_df$team_name))
  team_lists <- lapply(unique_teams, function(team) character(0))
  
  for (i in 1:nrow(cleaned_df)) {
    team_name <- cleaned_df$team_name[i]
    player_name <- cleaned_df$player_name[i]
    
    if (!is.na(team_name) && !is.na(player_name)) {
      team_index <- match(team_name, unique_teams)
      
      if (!is.na(team_index) && !(player_name %in% team_lists[[team_index]])) {
        team_lists[[team_index]] <- c(team_lists[[team_index]], player_name)
      }
    }
  }
  team_lists <- setNames(team_lists, unique_teams)
  
  for(team_name in unique_teams){
    player_list <- list()
    for (player in team_lists[[team_name]]) {
      for(i in 1:nrow(cleaned_df)){
        match_events <- subset(cleaned_df, player_name == player)
      }
      efficacy_scores <- data.frame(
        position = match_events$position_name[1],
        minutes.played = match_events$player_minutesPlayed[1],
        total.game.actions = 0,
        scoring = 0,
        ball.carrying = 0,
        tackling = 0,
        passing = 0,
        kicking = 0,
        ball.support = 0,
        ball.reception = 0,
        lineout.throw = 0,
        lineout.contest = 0
      )
      
      player_stats <- data.frame(
        player_name = match_events$player_name[1],
        player_id = match_events$player_id[1],
        position = match_events$position_name[1],
        minutes.played = match_events$player_minutesPlayed[1],
        tackles = 0,
        "tackle errors" = 0,
        carries = 0,
        "carry errors" = 0,
        "metres carried" = 0,
        passes = 0,
        "pass error" = 0,
        "tries scored" = 0,
        "ruck entries" = 0,
        "ruck errors" = 0,
        "lineout throws" = 0,
        "lineout throw errors" = 0,
        "lineout contests won" = 0,
        "lineout contest errors" = 0,
        "goal kicks made" = 0,
        "goal kicks error" = 0,
        kicks = 0,
        "kick errors" = 0,
        "reception success" = 0,
        "reception failure" = 0
      )
      
      player_list[[player]] <- list(
        match_events = match_events,
        efficacy_scores = efficacy_scores,
        player_stats = player_stats
      )
    }
    team_lists[[team_name]] <- player_list
  }
  
  return(list(team_1 = team_lists[[1]], team_2 = team_lists[[2]]))
}

team_lists <- generate_team_lists(salvsnew_cleaned)
sale <- team_lists$team_1
newcastle <- team_lists$team_2

# Function to iterate through the $match_events and process players stats (frequency) and efficacy scores (qualitative)
process_raw_efficacy_scores <- function(team_df){
  match_data = team_df$match_events
  efficacy_scores = team_df$efficacy_scores
  player_stats = team_df$player_stats
  
  keywords <- list(
    "try scored", "error", "pen conceded", "carry metres", "dominant contact", "neutral contact", "ineffective contact",
    "carried over", "carried in touch", "dropped ball unforced", "lost ball forced", "lost in ruck or maul", "tackled",
    "other", "kick", "pass", "penalty won", "conversion", "drop goal", "penalty goal", "goal kicked", "goal missed",
    "dominant tackle contact", "neutral tackle contact", "ineffective tackle contact", "complete", "forced in touch",
    "offload allowed", "turnover won", "missed", "ineffective", "try saver", "offload", "ruck pass", "miss pass",
    "complete pass", "off target pass", "receiver error", "incomplete pass", "pass error", "forward pass", "intercepted pass", "pressured kick",
    "no pressure kick", "error - out on the full", "error - terratorial loss", "error - dead ball", "error - failure to find touch",
    "kick in touch", "caught full", "collected bounce", "in goal", "own player - collected", "own player - failed",
    "pressure carried over", "pressure in touch", "pressure error", "50/22", "cleaned out", "secured", "nuisance",
    "failed clearout", "pen won", "attacking catch", "attacking loose ball", "defensive catch", "defensive loose ball",
    "restart catch", "interception", "tap back", "in goal touchdown", "mark", "success", "fail", "pressure", "no pressure",
    "won catch", "won tap", "won penalty", "won free kick", "won other", "lost not straight", "lost outright",
    "lost not 5m", "lost overthrown", "lost free kick", "lost penalty", "lost other", "lost handling error", "clean catch", "clean tap",
    "off target tap", "cleaned up", "tap error", "handling error forced", "handling error unforced", "penalty conceded",
    "penalty won", "forced error", "steal"
  )
  
  for(i in 1:nrow(match_data)){
    type_name = match_data$type_name[i]
    position = match_data$position_name[i]
    
    cell_contains_keywords <- logical(length(keywords))
    names(cell_contains_keywords) <- keywords
    
    for(keyword_idx in seq_along(keywords)){
      keyword <- keywords[keyword_idx]
      cell_contains_keywords[keyword_idx] <- any(apply(match_data[i, ], 1, function(cell) grepl(keyword, cell, ignore.case = TRUE)))
    }
    
    if(type_name == "goal kick" && position == "fly half"){
      if(cell_contains_keywords["conversion"] && cell_contains_keywords["goal kicked"]){
        efficacy_scores$scoring = efficacy_scores$scoring + 2
        player_stats$goal.kicks.made = player_stats$goal.kicks.made +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["drop goal"] && cell_contains_keywords["goal kicked"]){
        efficacy_scores$scoring = efficacy_scores$scoring + 3
        player_stats$goal.kicks.made = player_stats$goal.kicks.made +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["penalty goal"] && cell_contains_keywords["goal kicked"]){
        efficacy_scores$scoring = efficacy_scores$scoring + 1
        player_stats$goal.kicks.made = player_stats$goal.kicks.made +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["goal missed"]){
        efficacy_scores$scoring = efficacy_scores$scoring -3
        player_stats$goal.kicks.error = player_stats$goal.kicks.error +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
    } 
    
    if(type_name == "carry"){
      if(cell_contains_keywords["try scored"]){
        efficacy_scores$scoring = efficacy_scores$scoring + 5
        player_stats$tries.scored = player_stats$tries.scored +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["pen conceded"]){
        efficacy_scores$ball.carrying = efficacy_scores$ball.carrying - 3
        player_stats$carry.errors = player_stats$carry.errors + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["dominant contact"] && (cell_contains_keywords["tackled"] || 
                                                             cell_contains_keywords["other"] || 
                                                             cell_contains_keywords["kick"] || 
                                                             cell_contains_keywords["pass"] || 
                                                             cell_contains_keywords["penalty won"])){
        efficacy_scores$ball.carrying = efficacy_scores$ball.carrying + 2
        player_stats$carries = player_stats$carries + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["neutral contact"] && (cell_contains_keywords["tackled"] || 
                                                            cell_contains_keywords["other"] || 
                                                            cell_contains_keywords["kick"] || 
                                                            cell_contains_keywords["pass"] || 
                                                            cell_contains_keywords["penalty won"])){
        efficacy_scores$ball.carrying = efficacy_scores$ball.carrying + 1
        player_stats$carries = player_stats$carries + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["ineffective contact"] && (cell_contains_keywords["tackled"] || 
                                                                cell_contains_keywords["other"] || 
                                                                cell_contains_keywords["kick"] || 
                                                                cell_contains_keywords["pass"] || 
                                                                cell_contains_keywords["penalty won"])){
        efficacy_scores$ball.carrying = efficacy_scores$ball.carrying - 2
        player_stats$carries = player_stats$carries + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
    }
    
    if(type_name == "turnover"){
      if(cell_contains_keywords["carried over"] ||
         cell_contains_keywords["carried in touch"] ||
         cell_contains_keywords["dropped ball unforced"] ||
         cell_contains_keywords["lost in ruck or maul"] ||
         cell_contains_keywords["lost ball forced"]){
        efficacy_scores$ball.carrying = efficacy_scores$ball.carrying - 3
        player_stats$carry.errors = player_stats$carry.errors + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
    }
    
    if(type_name == "tackle"){
      if(cell_contains_keywords["dominant tackle contact"] && (cell_contains_keywords["complete"] || 
                                                               cell_contains_keywords["forced in touch"] || 
                                                               cell_contains_keywords["offload allowed"])){
        efficacy_scores$tackling = efficacy_scores$tackling + 2
        player_stats$tackles = player_stats$tackles +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["dominant tackle contact"] && cell_contains_keywords["turnover won"]){
        efficacy_scores$tackling = efficacy_scores$tackling + 3
        player_stats$tackles = player_stats$tackles +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if((cell_contains_keywords["neutral tackle contact"] || 
               cell_contains_keywords["ineffective tackle contact"]) && (cell_contains_keywords["complete"] || 
                                                                         cell_contains_keywords["forced in touch"] || 
                                                                         cell_contains_keywords["offload allowed"])){
        efficacy_scores$tackling = efficacy_scores$tackling + 1
        player_stats$tackles = player_stats$tackles +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["pen conceded"] || 
              cell_contains_keywords["missed"] || 
              cell_contains_keywords["ineffective"]){
        efficacy_scores$tackling = efficacy_scores$tackling -3
        player_stats$tackle.errors = player_stats$tackle.errors +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["try saver"]){
        efficacy_scores$tackling = efficacy_scores$tackling + 3
        player_stats$tackles = player_stats$tackles +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
    }
    
    if(type_name == "pass"){
      if(cell_contains_keywords["offload"] && cell_contains_keywords["complete pass"]){
        efficacy_scores$passing = efficacy_scores$passing + 3
        player_stats$passes = player_stats$passes +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["offload"] && (cell_contains_keywords["off target pass"] || 
                                                    cell_contains_keywords["receiver error"])){
        efficacy_scores$passing = efficacy_scores$passing + 2
        player_stats$passes = player_stats$passes +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["ruck pass"] && (cell_contains_keywords["complete pass"] || 
                                                      cell_contains_keywords["off target pass"] || 
                                                      cell_contains_keywords["receiver error"])){
        efficacy_scores$passing = efficacy_scores$passing + 1
        player_stats$passes = player_stats$passes +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["miss pass"] && cell_contains_keywords["complete pass"]){
        efficacy_scores$passing = efficacy_scores$passing + 2
        player_stats$passes = player_stats$passes +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["miss pass"] && (cell_contains_keywords["off target pass"] || 
                                                      cell_contains_keywords["receiver error"])){
        efficacy_scores$passing = efficacy_scores$passing + 1
        player_stats$passes = player_stats$passes +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(!(cell_contains_keywords["offload"] || 
                cell_contains_keywords["ruck pass"] || 
                cell_contains_keywords["miss pass"]) && (cell_contains_keywords["complete pass"] || 
                                                         cell_contains_keywords["off target pass"] || 
                                                         cell_contains_keywords["receiver error"])){
        efficacy_scores$passing = efficacy_scores$passing + 1
        player_stats$passes = player_stats$passes +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["incomplete pass"]){
        efficacy_scores$passing = efficacy_scores$passing -2
        player_stats$pass.error = player_stats$pass.error +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["pass error"] || 
              cell_contains_keywords["forward pass"] || 
              cell_contains_keywords["intercepted pass"]){
        efficacy_scores$passing = efficacy_scores$passing -3
        player_stats$pass.error = player_stats$pass.error +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
    }
    
    if(type_name == "kick" && (position == "scrum half" || 
                               position == "fly half" || 
                               position == "left wing" || 
                               position == "right wing" || 
                               position == "inside centre" || 
                               position == "outside centre" || 
                               position == "full back")){
      if ((cell_contains_keywords["error - out on the full"] ||
           cell_contains_keywords["error - terratorial loss"] ||
           cell_contains_keywords["error - dead ball"] ||
           cell_contains_keywords["error - failure to find touch"]) && cell_contains_keywords["no pressure kick"]){
        efficacy_scores$kicking = efficacy_scores$kicking - 3
        player_stats$kick.errors = player_stats$kick.errors + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if((cell_contains_keywords["kick in touch"] ||
               cell_contains_keywords["caught full"] ||
               cell_contains_keywords["collected bounce"] ||
               cell_contains_keywords["in goal"] ||
               cell_contains_keywords["own player - collected"] ||
               cell_contains_keywords["own player - failed"] ||
               cell_contains_keywords["pressure carried over"] ||
               cell_contains_keywords["pressure in touch"] ||
               cell_contains_keywords["pressure error"] ||
               cell_contains_keywords["50/22"]) && cell_contains_keywords["no pressure kick"]){
        efficacy_scores$kicking = efficacy_scores$kicking + 1
        player_stats$kicks = player_stats$kicks + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if((cell_contains_keywords["kick in touch"] ||
               cell_contains_keywords["caught full"] ||
               cell_contains_keywords["collected bounce"] ||
               cell_contains_keywords["in goal"] ||
               cell_contains_keywords["own player - collected"] ||
               cell_contains_keywords["own player - failed"] ||
               cell_contains_keywords["pressure carried over"] ||
               cell_contains_keywords["pressure in touch"] ||
               cell_contains_keywords["pressure error"] ||
               cell_contains_keywords["50/22"]) && cell_contains_keywords["pressured kick"]){
        efficacy_scores$kicking = efficacy_scores$kicking + 3
        player_stats$kicks = player_stats$kicks + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if((cell_contains_keywords["error - out on the full"] ||
               cell_contains_keywords["error - terratorial loss"] ||
               cell_contains_keywords["error - dead ball"] ||
               cell_contains_keywords["error - failure to find touch"]) && cell_contains_keywords["pressured kick"]){
        efficacy_scores$kicking = efficacy_scores$kicking -2
        player_stats$kick.errors = player_stats$kick.errors + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
    }
    if(type_name == "ruck entry"){
      if(cell_contains_keywords["cleaned out"] || 
         cell_contains_keywords["secured"] || 
         cell_contains_keywords["nuisance"]){
        efficacy_scores$ball.support = efficacy_scores$ball.support + 1
        player_stats$ruck.entries = player_stats$ruck.entries + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["pen won"]){
        efficacy_scores$ball.support = efficacy_scores$ball.support + 2
        player_stats$ruck.entries = player_stats$ruck.entries + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["turnover won"]){
        efficacy_scores$ball.support = efficacy_scores$ball.support + 3
        player_stats$ruck.entries = player_stats$ruck.entries + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["failed clearout"]){
        efficacy_scores$ball.support = efficacy_scores$ball.support - 2
        player_stats$ruck.errors = player_stats$ruck.errors + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["error"]){
        efficacy_scores$ball.support = efficacy_scores$ball.support -3 
        player_stats$ruck.errors = player_stats$ruck.errors + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
    }
    
    if(type_name == "ball reception"){
      if(cell_contains_keywords["mark"] && cell_contains_keywords["success"]){
        efficacy_scores$ball.reception = efficacy_scores$ball.reception +1
        player_stats$reception.success = player_stats$reception.success +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if((cell_contains_keywords["attacking catch"] ||
               cell_contains_keywords["defensive catch"] ||
               cell_contains_keywords["attacking loose ball"] ||
               cell_contains_keywords["defensive loose ball"]||
               cell_contains_keywords["restart catch"]) && cell_contains_keywords["success"] && cell_contains_keywords["no pressure"]){
        efficacy_scores$ball.reception = efficacy_scores$ball.reception + 1
        player_stats$reception.success = player_stats$reception.success +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if((cell_contains_keywords["attacking catch"] ||
               cell_contains_keywords["defensive catch"] ||
               cell_contains_keywords["attacking loose ball"] ||
               cell_contains_keywords["defensive loose ball"] ||
               cell_contains_keywords["restart catch"]) && cell_contains_keywords["success"] && cell_contains_keywords["pressure"]){
        efficacy_scores$ball.reception = efficacy_scores$ball.reception + 3
        player_stats$reception.success = player_stats$reception.success +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if((cell_contains_keywords["attacking catch"] ||
               cell_contains_keywords["defensive catch"] ||
               cell_contains_keywords["attacking loose ball"] ||
               cell_contains_keywords["defensive loose ball"]||
               cell_contains_keywords["restart catch"]) && cell_contains_keywords["fail"] && cell_contains_keywords["no pressure"]){
        efficacy_scores$ball.reception = efficacy_scores$ball.reception - 3
        player_stats$reception.failure = player_stats$reception.failure +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if((cell_contains_keywords["attacking catch"] ||
               cell_contains_keywords["defensive catch"] ||
               cell_contains_keywords["attacking loose ball"] ||
               cell_contains_keywords["defensive loose ball"]||
               cell_contains_keywords["restart catch"]) && cell_contains_keywords["fail"] && cell_contains_keywords["pressure"]){
        efficacy_scores$ball.reception = efficacy_scores$ball.reception - 1
        player_stats$reception.failure = player_stats$reception.failure +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if((cell_contains_keywords["interception"] || 
               cell_contains_keywords["in goal touchdown"]) && cell_contains_keywords["success"]){
        efficacy_scores$ball.reception = efficacy_scores$ball.reception + 2
        player_stats$reception.success = player_stats$reception.success +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["tap back"] && cell_contains_keywords["success"]){
        efficacy_scores$ball.reception = efficacy_scores$ball.reception + 1
        player_stats$reception.success = player_stats$reception.success +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
    }
    
    if(type_name == "lineout throw" && position == "hooker"){
      if(cell_contains_keywords["won catch"] ||
         cell_contains_keywords["won tap"] || 
         cell_contains_keywords["won penalty"] || 
         cell_contains_keywords["won free kick"] || 
         cell_contains_keywords["won other"]){
        efficacy_scores$lineout = efficacy_scores$lineout.throw + 2
        player_stats$lineout.throws = player_stats$lineout.throws +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["lost not straight"] ||
              cell_contains_keywords["lost outright"] || 
              cell_contains_keywords["lost not 5m"] || 
              cell_contains_keywords["lost overthrown"]){
        efficacy_scores$lineout = efficacy_scores$lineout.throw -2
        player_stats$lineout.throw.errors = player_stats$lineout.throw.errors +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["lost free kick"] ||
              cell_contains_keywords["lost penalty"] ||
              cell_contains_keywords["lost other"] ||
              cell_contains_keywords["lost handling error"]){
        efficacy_scores$lineout = efficacy_scores$lineout.throw -1
        player_stats$lineout.throws = player_stats$lineout.throws +1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
    }
    
    if(type_name == "lineout contest" && (position == "second row"|| position == "flanker")){
      if(cell_contains_keywords["clean catch"] ||
         cell_contains_keywords["clean tap"] ||
         cell_contains_keywords["penalty won"] ||
         cell_contains_keywords["nuisance"] ||
         cell_contains_keywords["forced error"]){
        efficacy_scores$lineout = efficacy_scores$lineout.contest + 2
        player_stats$lineout.contests.won = player_stats$lineout.contests.won + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["off target tap"] || 
              cell_contains_keywords["cleaned up"]) {
        efficacy_scores$lineout = efficacy_scores$lineout.contest +1
        player_stats$lineout.contests.won = player_stats$lineout.contests.won + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["tap error"] ||
              cell_contains_keywords["handling error forced"]){
        efficacy_scores$lineout = efficacy_scores$lineout.contest -2
        player_stats$lineout.contest.errors = player_stats$lineout.contest.errors + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["handling error unforced"] ||
              cell_contains_keywords["penalty conceded"]){
        efficacy_scores$lineout = efficacy_scores$lineout.contest -3
        player_stats$lineout.contest.errors = player_stats$lineout.contest.errors + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
      else if(cell_contains_keywords["steal"]){
        efficacy_scores$lineout = efficacy_scores$lineout.contest + 3
        player_stats$lineout.contests.won = player_stats$lineout.contests.won + 1
        efficacy_scores$total.game.actions = efficacy_scores$total.game.actions + 1
      }
    }
  }
  # print(efficacy_scores)
  # print(player_stats)
  
  player_scores <- list(efficacy_scores = efficacy_scores, player_stats = player_stats)
  return(player_scores)
}

# function applying the process_raw_efficacy_scores function to both team data lists
update_all_player_scores <- function(team_df){
  for(player_name in names(team_df)){
    player_data <- team_df[[player_name]]
    updated_player_scores <- process_raw_efficacy_scores(player_data)
    team_df[[player_name]] <- updated_player_scores
  }
  return(team_df)
}

team_1_player_scores <- update_all_player_scores(team_1)
team_2_player_scores <- update_all_player_scores(team_2)

saracen_player_scores <- update_all_player_scores(saracens)
bathrugby_player_scores <- update_all_player_scores(bathrugby)
bristol_player_scores <- update_all_player_scores(bristol)
gloucester_player_scores <- update_all_player_scores(gloucester)
london_player_scores <- update_all_player_scores(london)
exeter_player_scores <- update_all_player_scores(exeter)
leicester_player_scores <- update_all_player_scores(leicester)
harlequins_player_scores <- update_all_player_scores(harlquins)
sale_player_scores <- update_all_player_scores(sale)
newcastle_player_scores <- update_all_player_scores(newcastle)



# Function to separate the efficacies and stats from the match events
generate_team_efficacies_and_stats_lists <- function(updated_team_df){
  player_efficacies_list <- list()
  player_stats_list <- list()
  for(player_name in names(updated_team_df)){
    player_efficacy_score <- updated_team_df[[player_name]]$efficacy_scores
    player_stats_score <- updated_team_df[[player_name]]$player_stats
    
    player_efficacies_list[[player_name]] <- player_efficacy_score
    player_stats_list[[player_name]] <- player_stats_score
  }
  return(list(player_efficacies = player_efficacies_list, player_stats = player_stats_list))
}
  
 
update_team_1 <- generate_team_efficacies_and_stats_lists(team_1_player_scores)
update_team_2 <- generate_team_efficacies_and_stats_lists(team_2_player_scores)

sarvsbat_efficacies <- c(saracen_efficacies, bathrugby_efficacies)
sar_team_eff_stat <- generate_team_efficacies_and_stats_lists(saracen_player_scores)
saracen_efficacies <- sar_team_eff_stat$player_efficacies
saracen_stats = sar_team_eff_stat$player_stats

bat_team_eff_stat <- generate_team_efficacies_and_stats_lists(bathrugby_player_scores)
bathrugby_efficacies = bat_team_eff_stat$player_efficacies
bathrugby_stats = bat_team_eff_stat$player_stats

brivsglo_efficacies <- c(bristol_efficacies, gloucester_efficacies)

bri_team_eff_stat <- generate_team_efficacies_and_stats_lists(bristol_player_scores)
bristol_efficacies = bri_team_eff_stat$player_efficacies
bristol_stats = bri_team_eff_stat$player_stats

glo_team_eff_stat <- generate_team_efficacies_and_stats_lists(gloucester_player_scores)
gloucester_efficacies = glo_team_eff_stat$player_efficacies
gloucester_stats = glo_team_eff_stat$player_stats

lonvsexe_efficacies <- c(london_efficacies, exeter_efficacies)
lon_team_eff_stat <- generate_team_efficacies_and_stats_lists(london_player_scores)
london_efficacies = lon_team_eff_stat$player_efficacies
london_stats = lon_team_eff_stat$player_stats

exe_team_eff_stat <- generate_team_efficacies_and_stats_lists(exeter_player_scores)
exeter_efficacies = exe_team_eff_stat$player_efficacies
exeter_stats = exe_team_eff_stat$player_stats

leivshar_efficacies <- c(leicester_efficacies, harlequins_efficacies)
lei_team_eff_stat <- generate_team_efficacies_and_stats_lists(leicester_player_scores)
leicester_efficacies = lei_team_eff_stat$player_efficacies
leicester_stats = lei_team_eff_stat$player_stats

har_team_eff_stat <- generate_team_efficacies_and_stats_lists(harlequins_player_scores)
harlequins_efficacies = har_team_eff_stat$player_efficacies
harlequins_stats = har_team_eff_stat$player_stats

salvsnew_efficacies <- c(sale_efficacies, newcastle_efficacies)
sal_team_eff_stat <- generate_team_efficacies_and_stats_lists(sale_player_scores)
sale_efficacies = sal_team_eff_stat$player_efficacies
sale_stats = sal_team_eff_stat$player_stats

new_team_eff_stat <- generate_team_efficacies_and_stats_lists(newcastle_player_scores)
newcastle_efficacies = new_team_eff_stat$player_efficacies
newcastle_stats = new_team_eff_stat$player_stats

team_1_efficacies <- update_team_1$player_efficacies
team_2_efficacies <- update_team_2$player_efficacies
match_player_efficacies <- c(team_1_efficacies, team_2_efficacies)

team_1_stats <- update_team_1$player_stats
team_2_stats <- update_team_2$player_stats

# I want to create a function here that will take in the team stats, so in this case team_1_stat
# It will accept the name of a player, and then look at the player_stats
# using $position, it will delete specific columns of information

update_team_stats_by_position <- function(team_stats){
  player_names = names(team_stats)
  for(name in player_names){
    position = team_stats[[name]]$position
    if(position == "loosehead prop" || position == "tighthead prop" || position == "number eight"){
      team_stats[[name]]$lineout.throws <- 0
      team_stats[[name]]$lineout.throw.errors <- 0
      team_stats[[name]]$lineout.contests.won <- 0
      team_stats[[name]]$lineout.contest.errors <- 0
      team_stats[[name]]$goal.kicks.made <- 0
      team_stats[[name]]$goal.kicks.error <- 0
      team_stats[[name]]$kicks <- 0
      team_stats[[name]]$kick.errors <- 0
    }
    if(position == "hooker" || position == "Hooker"){
      team_stats[[name]]$lineout.contests.won <- 0
      team_stats[[name]]$lineout.contest.errors <- 0
      team_stats[[name]]$goal.kicks.made <- 0
      team_stats[[name]]$goal.kicks.error <- 0
      team_stats[[name]]$kicks <- 0
      team_stats[[name]]$kick.errors <- 0
    }
    if(position == "second row" || position == "flanker"){
      team_stats[[name]]$lineout.throws <- 0
      team_stats[[name]]$lineout.throw.errors <- 0
      team_stats[[name]]$goal.kicks.made <- 0
      team_stats[[name]]$goal.kicks.error <- 0
      team_stats[[name]]$kicks <- 0
      team_stats[[name]]$kick.errors <- 0
    }
    if(position == "scrum half" || position == "right wing" || position == "left wing" || position == "inside centre" || position == "outside centre"){
      team_stats[[name]]$lineout.throws <- 0
      team_stats[[name]]$lineout.throw.errors <- 0
      team_stats[[name]]$lineout.contests.won <- 0
      team_stats[[name]]$lineout.contest.errors <- 0
      team_stats[[name]]$goal.kicks.made <- 0
      team_stats[[name]]$goal.kicks.error <- 0
    }
    if(position == "fly half"){
      team_stats[[name]]$lineout.throws <- 0
      team_stats[[name]]$lineout.throw.errors <- 0
      team_stats[[name]]$lineout.contests.won <- 0
      team_stats[[name]]$lineout.contest.errors <- 0
    }
  }
  return(team_stats)
}

saracen_stats <- update_team_stats_by_position(saracen_stats)
bathrugby_stats <- update_team_stats_by_position(bathrugby_stats)
bristol_stats <- update_team_stats_by_position(bristol_stats)
gloucester_stats <- update_team_stats_by_position(gloucester_stats)
london_stats <- update_team_stats_by_position(london_stats)
exeter_stats <- update_team_stats_by_position(exeter_stats)
leicester_stats <- update_team_stats_by_position(leicester_stats)
harlequins_stats <- update_team_stats_by_position(harlequins_stats)
sale_stats <- update_team_stats_by_position(sale_stats)
newcastle_stats = update_team_stats_by_position(newcastle_stats)


# function to calculate and normalize each players efficacy score based on minutes played and total game actions 
find_positional_scores <- function(match_efficacies_df){
  positions = c("prop", "hooker", "second row", "flanker", "scrum half", "number eight", "fly half", "wing", "centre", "full back")
  position_efficacies <- list(
    prop = list(),
    hooker = list(),
    "second row" = list(),
    flanker = list(),
    "scrum half" = list(),
    "number eight" = list(),
    "fly half" = list(),
    wing = list(),
    centre = list(),
    "full back" = list()
  )
  
  for(player_name in names(match_efficacies_df)){
    position <- match_efficacies_df[[player_name]]$position
    minutes_played <- match_efficacies_df[[player_name]]$minutes.played
    total_score = sum(match_efficacies_df[[player_name]]$scoring, 
                      match_efficacies_df[[player_name]]$ball.carrying,
                      match_efficacies_df[[player_name]]$tackling,
                      match_efficacies_df[[player_name]]$passing,
                      match_efficacies_df[[player_name]]$kicking,
                      match_efficacies_df[[player_name]]$ball.support,
                      match_efficacies_df[[player_name]]$lineout.throw,
                      match_efficacies_df[[player_name]]$lineout.contest,
                      match_efficacies_df[[player_name]]$ball.reception)
    game_actions = match_efficacies_df[[player_name]]$total.game.actions
    game_actions_score = (total_score / minutes_played)*(total_score / game_actions)
    
    for (list_name in names(position_efficacies)) {
      if (grepl(list_name, position, ignore.case = TRUE)) {
        player_stats <- list(game_actions_score = game_actions_score)
        player_stats <- setNames(player_stats, player_name)
        position_efficacies[[list_name]] <- c(position_efficacies[[list_name]], player_stats)
        break 
      }
    }
  }
  return(position_efficacies)
}

data_bp <- find_positional_scores(salvsnew_efficacies)

saracen_efficacies_final$prop
bathrugby_efficacies_final

data <- unname(saracen_efficacies_final$prop)
team1_avg <- sapply(data, mean)

team1_avg <- sapply(saracen_efficacies_final, function(prop) mean(unlist(saracen_efficacies_final$prop)))
average_scores <- sapply(saracen_efficacies_final, function(position) mean(unlist(position)))
sapply(bathrugby_efficacies_final, function(position) mean(unlist(position)))
bathrugby_stats$`Niall Annett`

propnums1 <- unlist(unname(saracen_efficacies_final$prop))
propnums2 <- unlist(unname(bathrugby_efficacies_final$prop))

propnums1_avg = mean(propnums1)
propnums2_avg = mean(propnums2)

barplot(
  t(as.matrix(average_scores[, c("Saracen", "Bath Rugby")])),
  beside = TRUE,
  col = c("blue", "red"),
  names.arg = average_scores$Position,
  legend.text = c("Saracen", "Bath Rugby"),
  main = "Average Prop Scores by Team",
  xlab = "Position",
  ylab = "Average Score"
)

data_bp_list <- list(
  prop_bp <- unlist(unname(data_bp$prop)),
  hooker_bp <- unlist(unname(data_bp$hooker)),
  second_row_bp <- unlist(unname(data_bp$`second row`)),
  flanker_bp <- unlist(unname(data_bp$flanker)),
  number_eight_bp <- unlist(unname(data_bp$`number eight`)),
  scrum_half_bp <- unlist(unname(data_bp$`scrum half`)),
  fly_half_bp <- unlist(unname(data_bp$`fly half`)),
  wing_bp <- unlist(unname(data_bp$wing)),
  centre_bp <- unlist(unname(data_bp$centre)),
  full_back_bp <- unlist(unname(data_bp$`full back`))
)

boxplot(data_bp_list, main = "Sale vs Newcastle",
        names = rep("", length(data_bp)), ylab = "Position Scores")
text(x = seq_along(data_bp_list), y=par("usr")[3] - 0.15, 
      labels = names(data_bp), srt = 45, adj = c(1,1), xpd=TRUE)

# function to find the mean, standard deviation, max and min scores for each position in match. 

find_positional_scores_info <- function(match_efficacies_df){
  match_performance_scores = find_positional_scores(match_efficacies_df)
  positions = c("prop", "hooker", "second row", "flanker", "scrum half", "number eight", "fly half", "wing", "centre", "full back")
  adjusted_position_scores <- list()
  
  for(position in positions){
    performance_scores = match_performance_scores[[position]]
    scores = unlist(performance_scores)
    total = round(sum(scores), digits = 4)
    average = round(mean(scores), digits = 4)
    standard_deviation = round(sd(scores), digits = 4)
    max_score = round(max(scores), digits = 4)
    min_score = round(min(scores), digits = 4)
    # print(paste("Adjusted efficacies for", position, ":"))
    # print(paste("Average:", average))
    # print(paste("Standard Deviation:", standard_deviation))
    # print(paste("Max Score:", max_score))
    # print(paste("Min Score:", min_score))
    adjusted_position_scores[[position]] <- c(adjusted_position_scores[[position]], list(average = average, 
                                                                        standard_deviation = standard_deviation,
                                                                        max_score = max_score,
                                                                        min_score = min_score))
  }
  return(adjusted_position_scores)
}

match_player_scores <- find_positional_scores(match_player_efficacies)

sarvsbat_match_info <- find_positional_scores_info(sarvsbat_efficacies)

names(sarvsbat_match_info)
data = sarvsbat_match_info


# I want to display boxplots of the different positional scores from each match
# Each match will have a graph, each graph will have 10 box plots, each box plot will show the mean, and min and max scores
match_positional_scores_info <- find_positional_scores_info(match_player_efficacies)

team_1_efficacies_final <- find_positional_scores(team_1_efficacies)
team_2_efficacies_final <- find_positional_scores(team_2_efficacies)

# function to generate the final performance index score using the previously transformed efficacy scores. 
generate_player_performance_index_scores <- function(match_efficacies_df, team_efficacies_df){
  positions = c("prop", "hooker", "second row", "flanker", "scrum half", "number eight", "fly half", "wing", "centre", "full back")
  player_performance_index_scores <- list()
  desired_center = 75
  desired_range = 24.99
  curve_factor = 2
  
  for(position in positions){
    player_names = names(team_efficacies_df[[position]])
    average = match_efficacies_df[[position]]$average
    std_dev = match_efficacies_df[[position]]$standard_deviation
    print(player_names)
    
    for(player_name in player_names){
      player_score = team_efficacies_df[[position]][[player_name]]
      adj_player_score = desired_center + desired_range * (2 / (1 + exp(-2 * curve_factor * (player_score - average))) - 1)
      
      player_performance_index_scores[[player_name]] = adj_player_score
      # print(paste("Position:", position, 
      #             "Player name:", player_name,
      #             "Player Efficacy Score:", round(player_score, digits = 2),
      #             "Player Match Performance Score:", round(adj_player_score, digits=2))
      #       )
    }
  }
  return(player_performance_index_scores)
}

team_1_match_performance_scores <- generate_player_performance_index_scores(match_positional_scores_info, team_1_efficacies_final)
team_2_match_performance_scores <- generate_player_performance_index_scores(match_positional_scores_info, team_2_efficacies_final)
# # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # 
# Run all functions above
cleaned_df <- generate_cleaned_datasets(saracens_vs_bath_original_df)

team_lists <- generate_team_lists(cleaned_df)
team_1 <- team_lists$team_1
team_2 <- team_lists$team_2


team_1_player_scores <- update_all_player_scores(team_1)
team_2_player_scores <- update_all_player_scores(team_2)

update_team_1 <- generate_team_efficacies_and_stats_lists(team_1_player_scores)
update_team_2 <- generate_team_efficacies_and_stats_lists(team_2_player_scores)

team_1_efficacies <- update_team_1$player_efficacies
team_2_efficacies <- update_team_2$player_efficacies
match_player_efficacies <- c(team_1_efficacies, team_2_efficacies)

team_1_stats <- update_team_1$player_stats
team_2_stats <- update_team_2$player_stats

match_player_scores <- find_positional_scores(match_player_efficacies)
match_positional_scores_info <- find_positional_scores_info(match_player_efficacies)

team_1_efficacies_final <- find_positional_scores(team_1_efficacies)
team_2_efficacies_final <- find_positional_scores(team_2_efficacies)

sarvsbat_efficacies_final <- find_positional_scores_info(sarvsbat_efficacies)
brivsglo_efficacies_final <- find_positional_scores_info(brivsglo_efficacies)
lonvsexe_efficacies_final <- find_positional_scores_info(lonvsexe_efficacies)
leivshar_efficacies_final <- find_positional_scores_info(leivshar_efficacies)
salvsnew_efficacies_final <- find_positional_scores_info(salvsnew_efficacies)


saracen_efficacies_final <- find_positional_scores(saracen_efficacies)
bathrugby_efficacies_final <- find_positional_scores(bathrugby_efficacies)
bristol_efficacies_final <- find_positional_scores(bristol_efficacies)
gloucester_efficacies_final <- find_positional_scores(gloucester_efficacies)
london_efficacies_final <- find_positional_scores(london_efficacies)
exeter_efficacies_final <- find_positional_scores(exeter_efficacies)
leicester_efficacies_final <- find_positional_scores(leicester_efficacies)
harlequins_efficacies_final <- find_positional_scores(harlequins_efficacies)
sale_efficacies_final <- find_positional_scores(sale_efficacies)
newcastle_efficacies_final = find_positional_scores(newcastle_efficacies)

team_1_match_performance_scores <- generate_player_performance_index_scores(match_positional_scores_info, team_1_efficacies_final)
team_2_match_performance_scores <- generate_player_performance_index_scores(match_positional_scores_info, team_2_efficacies_final)

saracens_match_performance_scores <- generate_player_performance_index_scores(sarvsbat_efficacies_final, saracen_efficacies_final)
bathrugby_match_performance_scores <- generate_player_performance_index_scores(sarvsbat_efficacies_final, bathrugby_efficacies_final)

bristol_match_performance_scores <- generate_player_performance_index_scores(brivsglo_efficacies_final, bristol_efficacies_final)
gloucester_match_performance_scores <- generate_player_performance_index_scores(brivsglo_efficacies_final, gloucester_efficacies_final)

london_match_performance_scores <- generate_player_performance_index_scores(lonvsexe_efficacies_final, london_efficacies_final)
exeter_match_performance_scores <- generate_player_performance_index_scores(lonvsexe_efficacies_final, exeter_efficacies_final)

leicester_match_performance_scores <- generate_player_performance_index_scores(leivshar_efficacies_final, leicester_efficacies_final)
harlequins_match_performance_scores <- generate_player_performance_index_scores(leivshar_efficacies_final, harlequins_efficacies_final)

sale_match_performance_scores <- generate_player_performance_index_scores(salvsnew_efficacies_final, sale_efficacies_final)
newcastle_match_performance_scores <- generate_player_performance_index_scores(salvsnew_efficacies_final, newcastle_efficacies_final)

# a series of data.frames to be exported as CSVs 
match_data <- data.frame(
  "match_id" = numeric(0),
  "match_date" = as.Date(character(0)),
  "team_1_id" = numeric(0),
  "team_2_id" = numeric(0),
  "team_1_score" = numeric(0),
  "team_2_score" = numeric(0),
  "team_1_name" = character(0),
  "team_2_name" = character(0)
)

team_1_data <- data.frame(
  "team_1_id" = numeric(0),
  "team_1_name" = character(0),
  "team_1_score" = numeric(0)
)

team_2_data <- data.frame(
  "team_2_id" = numeric(0),
  "team_2_name" = character(0),
  "team_2_score" = numeric(0)
)

match_data <- rbind(match_data, data.frame(
  "match_id" = cleaned_df$matchID[1],
  "match_date" = as.Date(cleaned_df$date[1]),
  "team_1_id" = cleaned_df$homeTeamID[1],
  "team_2_id" = cleaned_df$awayTeamID[1],
  "team_1_name" = cleaned_df$homeTeamName[1],
  "team_2_name" = cleaned_df$awayTeamName[1],
  "team_1_score" = cleaned_df$homeScore[nrow(cleaned_df)],
  "team_2_score" = cleaned_df$awayScore[nrow(cleaned_df)]
))

team_1_data <- rbind(team_1_data, data.frame(
  "match_id" = cleaned_df$matchID[1],
  "team_1_id" = cleaned_df$homeTeamID[1],
  "team_1_name" = cleaned_df$homeTeamName[1],
  "team_1_score" = cleaned_df$homeScore[nrow(cleaned_df)]
))

team_2_data <- rbind(team_2_data, data.frame(
  "match_id" = cleaned_df$matchID[1],
  "team_2_id" = cleaned_df$awayTeamID[1],
  "team_2_name" = cleaned_df$awayTeamName[1],
  "team_2_score" = cleaned_df$awayScore[nrow(cleaned_df)]
))

team_1_player_data <- data.frame(
  "match_id" = numeric(0),
  "team_id" = numeric(0),
  "team_name" = character(0),
  "player_id" = numeric(0),
  "player_name" = character(0),
  "player_position" = character(0),
  "player_index_score" = numeric(0),
  "player_minutesPlayed" = numeric(0),
  "tackles" = numeric(0),
  "tackle_errors" = numeric(0),
  "carries" = numeric(0),
  "carry_errors" = numeric(0),
  "metres_carried" = numeric(0),
  "passes" = numeric(0),
  "pass_errors" = numeric(0),
  "tries_scored" = numeric(0),
  "ruck_entries" = numeric(0),
  "ruck_errors" = numeric(0),
  "lineout_throws" = numeric(0),
  "lineout_throw_errors" = numeric(0),
  "lineout_contests_won" = numeric(0),
  "lineout_contest_errors" = numeric(0),
  "goal_kicks_made" = numeric(0),
  "goal_kicks_errors" = numeric(0),
  "kicks" = numeric(0),
  "kick_errors" = numeric(0),
  "reception_success" = numeric(0),
  "reception_failure" = numeric(0)
)

team_2_player_data <- data.frame(
  "match_id" = numeric(0),
  "team_id" = numeric(0),
  "team_name" = character(0),
  "player_id" = numeric(0),
  "player_name" = character(0),
  "player_position" = character(0),
  "player_minutesPlayed" = numeric(0),
  "player_index_score" = numeric(0),
  "tackles" = numeric(0),
  "tackle_errors" = numeric(0),
  "carries" = numeric(0),
  "carry_errors" = numeric(0),
  "metres_carried" = numeric(0),
  "passes" = numeric(0),
  "pass_errors" = numeric(0),
  "tries_scored" = numeric(0),
  "ruck_entries" = numeric(0),
  "ruck_errors" = numeric(0),
  "lineout_throws" = numeric(0),
  "lineout_throw_errors" = numeric(0),
  "lineout_contests_won" = numeric(0),
  "lineout_contest_errors" = numeric(0),
  "goal_kicks_made" = numeric(0),
  "goal_kicks_errors" = numeric(0),
  "kicks" = numeric(0),
  "kick_errors" = numeric(0),
  "reception_success" = numeric(0),
  "reception_failure" = numeric(0)
)

# Function to populate each teams player data.frame to export as csvs
populate_team_player_data <- function(team_player_data, team_stats_df, team_match_performance_df, match_id, team_id, team_name){
  team_stats <- team_stats_df
  team_match_performance <- team_match_performance_df
  for(player_name in names(team_stats)){
    team_player_data <- rbind(team_player_data, data.frame(
      "match_id" = match_id,
      "team_id" = team_id ,
      "team_name" = team_name,
      "player_id" = team_stats[[player_name]]$player_id,
      "player_name" = team_stats[[player_name]]$player_name,
      "player_position" = team_stats[[player_name]]$position,
      "player_minutesPlayed" = team_stats[[player_name]]$minutes.played,
      "player_index_score" = round(team_match_performance[[player_name]], digits = 2),
      "tackles" = team_stats[[player_name]]$tackles,
      "tackle_errors" = team_stats[[player_name]]$tackle.errors,
      "carries" = team_stats[[player_name]]$carries,
      "carry_errors" = team_stats[[player_name]]$carry.errors,
      "metres_carried" = team_stats[[player_name]]$metres.carried,
      "passes" = team_stats[[player_name]]$passes,
      "pass_errors" = team_stats[[player_name]]$pass.error,
      "tries_scored" = team_stats[[player_name]]$tries.scored,
      "ruck_entries" = team_stats[[player_name]]$ruck.entries,
      "ruck_errors" = team_stats[[player_name]]$ruck.errors,
      "lineout_throws" = team_stats[[player_name]]$lineout.throws,
      "lineout_throw_errors" = team_stats[[player_name]]$lineout.throw.errors,
      "lineout_contests_won" = team_stats[[player_name]]$lineout.contests.won,
      "lineout_contest_errors" = team_stats[[player_name]]$lineout.contest.errors,
      "goal_kicks_made" = team_stats[[player_name]]$goal.kicks.made,
      "goal_kicks_errors" = team_stats[[player_name]]$goal.kicks.error,
      "kicks" = team_stats[[player_name]]$kicks,
      "kick_errors" = team_stats[[player_name]]$kick.errors,
      "reception_success" = team_stats[[player_name]]$reception.success,
      "reception_failure" = team_stats[[player_name]]$reception.failure
    ))
  }
  return(team_player_data)
}

team_1_player_data = populate_team_player_data(team_1_player_data, team_1_stats, team_1_match_performance_scores, cleaned_df$matchID[1], cleaned_df$homeTeamID[1], cleaned_df$homeTeamName[1])

saracens_player_data = populate_team_player_data(team_1_player_data, saracen_stats, saracens_match_performance_scores, sarvsbat_cleaned$matchID[1], sarvsbat_cleaned$homeTeamID[1], sarvsbat_cleaned$homeTeamName[1])
bathrugby_player_data = populate_team_player_data(team_2_player_data, bathrugby_stats, bathrugby_match_performance_scores, sarvsbat_cleaned$matchID[1], sarvsbat_cleaned$awayTeamID[1], sarvsbat_cleaned$awayTeamName[1])

bristol_player_data = populate_team_player_data(team_1_player_data, bristol_stats, bristol_match_performance_scores, brivsglo_cleaned$matchID[1], brivsglo_cleaned$homeTeamID[1], brivsglo_cleaned$homeTeamName[1])
gloucester_player_data = populate_team_player_data(team_2_player_data, gloucester_stats, gloucester_match_performance_scores, brivsglo_cleaned$matchID[1], brivsglo_cleaned$awayTeamID[1], brivsglo_cleaned$awayTeamName[1])

london_player_data = populate_team_player_data(team_1_player_data, london_stats, london_match_performance_scores, lonvsexe_cleaned$matchID[1], lonvsexe_cleaned$homeTeamID[1], lonvsexe_cleaned$homeTeamName[1])
exeter_player_data = populate_team_player_data(team_2_player_data, exeter_stats, exeter_match_performance_scores, lonvsexe_cleaned$matchID[1], lonvsexe_cleaned$awayTeamID[1], lonvsexe_cleaned$awayTeamName[1])

leicester_player_data = populate_team_player_data(team_1_player_data, leicester_stats, leicester_match_performance_scores, leivshar_cleaned$matchID[1], leivshar_cleaned$homeTeamID[1], leivshar_cleaned$homeTeamName[1])
harlequins_player_data = populate_team_player_data(team_2_player_data, harlequins_stats, harlequins_match_performance_scores, leivshar_cleaned$matchID[1], leivshar_cleaned$awayTeamID[1], leivshar_cleaned$awayTeamName[1])

sale_player_data = populate_team_player_data(team_1_player_data, sale_stats, sale_match_performance_scores, salvsnew_cleaned$matchID[1], salvsnew_cleaned$homeTeamID[1], salvsnew_cleaned$homeTeamName[1])
newcastle_player_data = populate_team_player_data(team_2_player_data, newcastle_stats, newcastle_match_performance_scores, salvsnew_cleaned$matchID[1], salvsnew_cleaned$awayTeamID[1], salvsnew_cleaned$awayTeamName[1])







team_2_player_data = populate_team_player_data(team_2_player_data, team_2_stats, team_2_match_performance_scores, cleaned_df$matchID[1], cleaned_df$awayTeamID[1], cleaned_df$awayTeamName[1])

salvsnew_match_data <- rbind(match_data, data.frame(
  "match_id" = salvsnew_cleaned$matchID[1],
  "match_date" = as.Date(salvsnew_cleaned$date[1]),
  "team_1_id" = salvsnew_cleaned$homeTeamID[1],
  "team_2_id" = salvsnew_cleaned$awayTeamID[1],
  "team_1_name" = salvsnew_cleaned$homeTeamName[1],
  "team_2_name" = salvsnew_cleaned$awayTeamName[1],
  "team_1_score" = salvsnew_cleaned$homeScore[nrow(salvsnew_cleaned)],
  "team_2_score" = salvsnew_cleaned$awayScore[nrow(salvsnew_cleaned)]
))

sale_team_data <- rbind(team_1_data, data.frame(
  "match_id" = salvsnew_cleaned$matchID[1],
  "team_1_id" = salvsnew_cleaned$homeTeamID[1],
  "team_1_name" = salvsnew_cleaned$homeTeamName[1],
  "team_1_score" = salvsnew_cleaned$homeScore[nrow(salvsnew_cleaned)]
))

newcastle_team_data <- rbind(team_2_data, data.frame(
  "match_id" = salvsnew_cleaned$matchID[1],
  "team_2_id" = salvsnew_cleaned$awayTeamID[1],
  "team_2_name" = salvsnew_cleaned$awayTeamName[1],
  "team_2_score" = salvsnew_cleaned$awayScore[nrow(salvsnew_cleaned)]
))

sarvsbat_files <- list(match_data = sarvsbat_match_data, team_1_data = saracen_team_data, team_2_data = bath_team_data, team_1_player_data = saracens_player_data, team_2_player_data = bathrugby_player_data)
brivsglo_files <- list(match_data = brivsglo_match_data, team_1_data = bristol_team_data, team_2_data = gloucester_team_data, team_1_player_data = bristol_player_data, team_2_player_data = gloucester_player_data)
lonvsexe_files <- list(match_data = lonvsexe_match_data, team_1_data = london_team_data, team_2_data = exeter_team_data, team_1_player_data = london_player_data, team_2_player_data = exeter_player_data)
leivshar_files <- list(match_data = leivshar_match_data, team_1_data = leicester_team_data, team_2_data = harlequins_team_data, team_1_player_data = leicester_player_data, team_2_player_data = harlequins_player_data)
salvsnew_files <- list(match_data = salvsnew_match_data, team_1_data = sale_team_data, team_2_data = newcastle_team_data, team_1_player_data = sale_player_data, team_2_player_data = newcastle_player_data)



# # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # 



  
match_data_list <- list(sarvsbat_files$match_data, 
                        brivsglo_files$match_data, 
                        lonvsexe_files$match_data, 
                        leivshar_files$match_data, 
                        salvsnew_files$match_data)
combine_match_data <- do.call(rbind, match_data_list)

team_1_data_list <- list(sarvsbat_files$team_1_data,
                         brivsglo_files$team_1_data,
                         lonvsexe_files$team_1_data,
                         leivshar_files$team_1_data,
                         salvsnew_files$team_1_data)


team_2_data_list <- list(sarvsbat_files$team_2_data,
                         brivsglo_files$team_2_data,
                         lonvsexe_files$team_2_data,
                         leivshar_files$team_2_data,
                         salvsnew_files$team_2_data)

# List of lists with original column names
list_of_lists <- list(list1, list2, list3, list4, list5, list6, list7, list8, list9, list10)

# Define the new column names
new_column_names <- c("match_id", "team_id", "team_name", "team_score")

# Loop through each list and rename columns
for (i in seq_along(team_data_list)) {
  if ("team_1_id" %in% colnames(team_data_list[[i]])) {
    colnames(team_data_list[[i]]) <- new_column_names
  } else if ("team_2_id" %in% colnames(team_data_list[[i]])) {
    colnames(team_data_list[[i]]) <- new_column_names
  }
}

team_data_list <- list(team_1_data_list[[1]], 
                       team_1_data_list[[2]],
                       team_1_data_list[[3]],
                       team_1_data_list[[4]],
                       team_1_data_list[[5]],
                       team_2_data_list[[1]],
                       team_2_data_list[[2]],
                       team_2_data_list[[3]],
                       team_2_data_list[[4]],
                       team_2_data_list[[5]])
combine_team_data <- do.call(rbind, team_data_list)

player_data_list <- list(sarvsbat_files$team_1_player_data,
                         sarvsbat_files$team_2_player_data,
                         brivsglo_files$team_1_player_data, 
                         brivsglo_files$team_2_player_data,
                         lonvsexe_files$team_1_player_data, 
                         lonvsexe_files$team_2_player_data, 
                         leivshar_files$team_1_player_data, 
                         leivshar_files$team_2_player_data, 
                         salvsnew_files$team_1_player_data,
                         salvsnew_files$team_2_player_data)

combine_player_data <- do.call(rbind, player_data_list)
combine_player_data[is.na(combine_player_data)] <- 0

nrow(combine_player_data)
save_dataframes_to_csv <- function(match_data, team_data, player_data) {
  write.csv(combine_match_data, "/Users/matthewng/Desktop/researchproject/backend/CSV/match_data.csv", row.names = FALSE)
  write.csv(combine_team_data, "/Users/matthewng/Desktop/researchproject/backend/CSV/team_data.csv", row.names = FALSE)
  write.csv(combine_player_data, "/Users/matthewng/Desktop/researchproject/backend/CSV/player_data.csv", row.names = FALSE)
}
csv_files <- save_dataframes_to_csv(combine_match_data, combine_team_data, combine_player_data)
