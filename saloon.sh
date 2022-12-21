#! /bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"
echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU(){

  TOTAL_SERVICES=$($PSQL "SELECT COUNT(*) FROM services")
  SERVICE_COUNT=1
  while [[ $SERVICE_COUNT -le $TOTAL_SERVICES ]]
    do
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_COUNT")
      echo "$SERVICE_COUNT)$SERVICE_NAME"
      SERVICE_COUNT=$((SERVICE_COUNT+1))
    done

  read SERVICE_ID_SELECTED
  if [ $SERVICE_ID_SELECTED -gt $TOTAL_SERVICES ] || [ $SERVICE_ID_SELECTED -le 0 ]
    then
      echo -e "\nI could not find that service. What would you like today?"
      MAIN_MENU
    fi
}

#Main menu loop
MAIN_MENU

# Phone check
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")
if [[ -z $CUSTOMER_ID ]]
  then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    NEW_CUSTOMER=$($PSQL "INSERT INTO customers (phone,name) VALUES ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
    if [[ $NEW_CUSTOMER == "INSERT 0 1" ]]
      then
        CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE name='$CUSTOMER_NAME'")
    fi
  else
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id='$CUSTOMER_ID'")
fi

# Appointment
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
echo -e "What time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
read SERVICE_TIME
APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id,service_id,time) VALUES ($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
if [[ $APPOINTMENT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a$SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
fi
