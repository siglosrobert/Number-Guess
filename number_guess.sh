#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

# Ask for username
echo Enter your username:
# Get username
read USERNAME

# Check if username exist in database
GET_USERNAME_RESULT=$($PSQL "SELECT * FROM users WHERE username='$USERNAME';")

# if not found
if [[ -z $GET_USERNAME_RESULT ]]
then

# add to database
INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")
# echo corresponding message
echo "Welcome, $USERNAME! It looks like this is your first time here."

# if found
else
# get info from database
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME';")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME';")
# echo corresponding message
echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

# Get random number
SECRET_NUMBER=$((RANDOM % 1000))
NUMBER_OF_GUESSES=0
# Echo message to guess
echo "TEST: $SECRET_NUMBER"
echo "Guess the secret number between 1 and 1000:"
#get initial guess
read USER_GUESS

#while user_guess not equal to correct_number
while [[ $USER_GUESS != $SECRET_NUMBER ]]

do
# if user_guess is not integer or null
if [[ ! $USER_GUESS =~ ^[0-9]+$ ]] || [[ ! $USER_GUESS ]]
then
  # Prompt corresponding message
  echo "That is not an integer, guess again:"
  # Get another input
  read USER_GUESS

# else (if user_guess is integer)
else
  # iterate attempt by 1
  NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))

  # if user_guess lower than correct_number
  if [[ $USER_GUESS -lt $SECRET_NUMBER ]]
  then
    # Prompt corresponding message
    echo "It's higher than that, guess again:"
    # Get another input
    read USER_GUESS
  # else (user_guess greater than correct_number)

  else
    # Prompt corresponding message
    echo "It's lower than that, guess again:"
    # Get another input
    read USER_GUESS
  fi
fi
done

# Exit Loop when user_guess is equal to correct_number
# Iterate current attempt for the correct attempt
NUMBER_OF_GUESSES=$((NUMBER_OF_GUESSES+1))
# echo exit message
echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# Update info to database
  # Iterate games_played by 1
  ITERATE_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE username='$USERNAME';")
  # get best attempt
  BEST_GAME_RESULT=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME';")
  # if best attempt is null
  if [[ -z $BEST_GAME_RESULT ]]
  then
    # set best attempt as current attempt
    SET_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME';")
  # if not null
  else
    # if current attempt less than best attempt 
    if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME_RESULT ]]
    then
      # Update best Attempt
      SET_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE username = '$USERNAME';")
    fi
  fi