#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE TABLE games, teams;")

cat games.csv | while IFS="," read YEAR ROUND WNAME ONAME WGOALS OGOALS
do

if [[ $WNAME != 'winner' ]]
then
  WTEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE '$WNAME' = name")
  if [[ -z $WTEAM_ID ]]
  then
  INSERT_WTEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WNAME')")
  WTEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE '$WNAME' = name")
  fi
fi

if [[ $ONAME != 'opponent' ]]
then
  OTEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE '$ONAME' = name")
  if [[ -z $OTEAM_ID ]]
  then
  INSERT_OTEAM_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$ONAME')")
  OTEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE '$ONAME' = name")
  fi
fi

if [[ $YEAR != 'year' ]]
then
  GAME_ID=$($PSQL "SELECT game_id FROM games FULL JOIN teams ON games.winner_id = teams.team_id WHERE games.year = $YEAR AND games.round = '$ROUND' AND teams.name = '$WNAME'")
  if [[ -z $GAME_ID ]]
  then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE '$WNAME' = name")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE '$ONAME' = name")
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WGOALS, $OGOALS)")
    GAME_ID=$($PSQL "SELECT game_id FROM games WHERE year = $YEAR AND round = '$ROUND' AND winner_id = $WINNER_ID")
  fi
fi
done


