#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "TRUNCATE teams, games")

# Loop through each unique team in the CSV file and add it to the teams table
# Skip the header line
cat games.csv | tail -n +2 | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  # Insert winner team into the 'name' column if not exists
  if [[ -n $winner ]]; then
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
    if [[ -z $TEAM_ID ]]; then
      $PSQL "INSERT INTO teams(name) VALUES('$winner')"
    fi
  fi

  # Insert opponent team into the 'name' column if not exists
  if [[ -n $opponent ]]; then
    TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
    if [[ -z $TEAM_ID ]]; then
      $PSQL "INSERT INTO teams(name) VALUES('$opponent')"
    fi
  fi
done

# Insert game data into the games table
cat games.csv | tail -n +2 | while IFS="," read year round winner opponent winner_goals opponent_goals
do
  # Get winner and opponent IDs from the teams table
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$winner'")
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$opponent'")
  
  # Insert the game record into the games table
  $PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($year, '$round', $WINNER_ID, $OPPONENT_ID, $winner_goals, $opponent_goals)"
done