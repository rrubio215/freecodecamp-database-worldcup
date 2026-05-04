#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
echo $($PSQL "TRUNCATE teams, games")
cat games.csv | while IFS=',' read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do 

  if [[ $YEAR != year ]]
  then
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    #if not found
    if [[ -z $WINNER_TEAM_ID ]]
    then
      # insert winner
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $WINNER
      fi
      WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      #insert opponent
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES ('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into teams, $OPPONENT
      fi
      OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi
  fi
done

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != year ]]
  then 
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    if [[ -z $WINNER_TEAM_ID || -z $OPPONENT_TEAM_ID ]] 
    then
      echo Team not found
    fi
    # insert game info
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_goals, opponent_goals, winner_id, opponent_id) VALUES ($YEAR, '$ROUND', $WINNER_GOALS, $OPPONENT_GOALS, $WINNER_TEAM_ID, $OPPONENT_TEAM_ID)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo Inserted into games, $YEAR $WINNER $OPPONENT
    fi
  fi
done