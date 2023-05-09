#!/bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Script to insert data from games.csv into worldcup database

awk -F',' 'NR>1 {
  printf "INSERT INTO teams (name) SELECT '\''%s'\'' WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name = '\''%s'\'');\n", $3, $3
  printf "INSERT INTO teams (name) SELECT '\''%s'\'' WHERE NOT EXISTS (SELECT 1 FROM teams WHERE name = '\''%s'\'');\n", $4, $4
  printf "INSERT INTO games (year, round, winner_goals, opponent_goals, winner_id, opponent_id) SELECT %d, '\''%s'\'', %d, %d, (SELECT team_id FROM teams WHERE name = '\''%s'\''), (SELECT team_id FROM teams WHERE name = '\''%s'\'') WHERE NOT EXISTS (SELECT 1 FROM games WHERE year = %d AND round = '\''%s'\'' AND winner_id = (SELECT team_id FROM teams WHERE name = '\''%s'\'') AND opponent_id = (SELECT team_id FROM teams WHERE name = '\''%s'\''));\n", $1, $2, $5, $6, $3, $4, $1, $2, $3, $4

}' games.csv | $PSQL >/dev/null

: '
EXPLAINATION:
-F',' sets the field separator to a comma
NR>1 skips the first line of the CSV file, which contains the column names
$1, $2, $3, $4, $5, and $6 refer to the columns in the CSV file

The first printf inserts a new row into the "teams" table with the team name in column 3, if it does not already exist in the table.
The second printf inserts a new row into the "teams" table with the team name in column 4, if it does not already exist in the table.
The third printf inserts a new row into the "games" table with the year in column 1, the round in column 2, the winners goals in column 5, the opponents goals in column 6, the ID of the winning team (obtained by looking up the team name in column 3), and the ID of the opposing team (obtained by looking up the team name in column 4).
The output of printf is piped to $PSQL.
$PSQL >/dev/null is redirecting the output of the psql command, which is stored in the $PSQL variable, to /dev/null. This effectively silences any output produced by the psql command, while still allowing the script to execute the necessary SQL queries against the database.
'