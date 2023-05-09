#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Script to insert data from games.csv into worldcup database

echo $($PSQL "TRUNCATE games, teams RESTART IDENTITY")
awk '(NR>1)' games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
    
  # TEAMS TABLE

  # get winning team
  WIN_TEAM=$($PSQL "SELECT name FROM teams WHERE name='$WINNER'")
  # if not found
  if [[ -z $WIN_TEAM ]]
  then
    # insert winning team
    INSERT_WIN_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
  if [[ $INSERT_WIN_TEAM_RESULT == 'INSERT 0 1' ]]
  then
    echo Inserted into teams: $WINNER
  fi
  fi

  # get opponent team
  OPP_TEAM=$($PSQL "SELECT name FROM teams WHERE name='$OPPONENT'")
  # if not found
  if [[ -z $OPP_TEAM ]]
  then
    # insert opponent team
    INSERT_OPP_TEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
  if [[ $INSERT_OPP_TEAM_RESULT == 'INSERT 0 1' ]]
  then
    echo Inserted into teams: $OPPONENT
  fi
  fi

  # GAMES TABLE

  # get winner_id
  WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'") 

  # get opponent_id
  OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

  # insert game info
  GAME_INFO=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID)")
  if [[ $GAME_INFO == 'INSERT 0 1' ]]
  then
    echo Inserted into games: $YEAR, $ROUND, $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_ID, $OPPONENT_ID
  fi

done