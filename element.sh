#!/bin/bash

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit 0
fi

# Assign the input argument to a variable
input=$1

# Query the PostgreSQL database
result=$(psql -X --username=postgres --dbname=periodic_table -t --no-align -c --command="
  SELECT 
    e.atomic_number, 
    TRIM(e.name) AS name, 
    TRIM(e.symbol) AS symbol, 
    TRIM(t.type) AS type, 
    p.atomic_mass, 
    p.melting_point_celsius, 
    p.boiling_point_celsius
  FROM elements AS e
  JOIN properties AS p ON e.atomic_number = p.atomic_number
  JOIN types AS t ON p.type_id = t.type_id
  WHERE e.atomic_number::text = '$input'
     OR e.symbol = '$input'
     OR e.name ILIKE '$input'
  LIMIT 1;
")

# Check if the query returned a result
if [ -z "$result" ]; then
  echo "I could not find that element in the database."
else
  # Parse the result and remove extra spaces
  IFS='|' read -r atomic_number name symbol type atomic_mass melting_point boiling_point <<< "$result"
  
  # Trim extra spaces
  name=$(echo $name | xargs)
  symbol=$(echo $symbol | xargs)
  type=$(echo $type | xargs)
  
  # Format and display the output
  echo "The element with atomic number $atomic_number is $name ($symbol). It's a $type, with a mass of $atomic_mass amu. $name has a melting point of $melting_point celsius and a boiling point of $boiling_point celsius."
fi
