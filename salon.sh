#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --no-align --tuples-only -c"


MAIN_MENU() {
  local MESSAGE="Welcome to My Salon, how can I help you?"

  while true
  do
    SERVICES=$($PSQL "SELECT service_id || ') ' || name FROM services ORDER BY service_id")

    printf "\n%s\n\n%s\n" "$MESSAGE" "$SERVICES"

    read SERVICE_ID_SELECTED || return 0

    if [[ $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]; then
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")

      if [[ -n $SERVICE_NAME ]]; then
        BOOK_APPOINTMENT
        return 0
      fi
    fi

    MESSAGE="I could not find that service. What would you like today?"
  done
}

BOOK_APPOINTMENT() {
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE

  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  if [[ -z $CUSTOMER_NAME ]]; then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME

    INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
  fi

  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
  read SERVICE_TIME

  INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU
