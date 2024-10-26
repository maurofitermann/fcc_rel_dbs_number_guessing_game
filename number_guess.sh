#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
read -p "Enter your username: " USERNAME

# CHECK IF THERE IS A SAVED USER WITH THAT NAME
KNOWN_PLAYER=$($PSQL "SELECT EXISTS(SELECT player_id FROM players WHERE username='$USERNAME');")

# IF THERE IS:
if [ "$KNOWN_PLAYER" == t ]
then
CURR_PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT COUNT(game_id) FROM games WHERE player_id='$CURR_PLAYER_ID'")
BEST_GAME=$($PSQL "SELECT MIN(attempts) FROM games where player_id='$CURR_PLAYER_ID'")
echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
else
# IF THERE ISN'T:
echo "Welcome, $USERNAME! It looks like this is your first time here."
fi

# Generate pseudo-random INT between 1 and 1000
NUM=$((1 + $RANDOM % 1000))
# echo $NUM

ATTEMPTS=1

# prompt and read input for a first guess
read -p "Guess the secret number between 1 and 1000:" GUESS

while [ "$GUESS" -ne "$NUM" ];
do
if [[ "$GUESS" -gt "$NUM" ]]; then
((ATTEMPTS++))
read -p "It's lower than that, guess again:" GUESS
elif [[ $GUESS -lt $NUM ]]; then
((ATTEMPTS++))
read -p "It's higher than that, guess again:" GUESS
else
read -p "That is not an integer, guess again:" GUESS
fi
done
  
echo "You guessed it in $ATTEMPTS tries. The secret number was $NUM. Nice job!"
  
if [ "$KNOWN_PLAYER" == "f" ]
then
$PSQL "INSERT INTO players(username) VALUES ('$USERNAME')"
CURR_PLAYER_ID=$($PSQL "SELECT player_id FROM players WHERE username='$USERNAME'")
fi

$PSQL "INSERT INTO games(player_id, attempts, answer) VALUES ($CURR_PLAYER_ID, $ATTEMPTS, $NUM)"