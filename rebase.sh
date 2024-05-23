#!/bin/bash

if [ ! -f .env ]; then
    echo "File .env not found"
    exit 1
fi

USERNAME=$(grep "SQLALCHEMY_DATABASE_URI" .env | cut -d'/' -f3 | cut -d':' -f1)
PASSWORD=$(grep "SQLALCHEMY_DATABASE_URI" .env | cut -d':' -f3 | cut -d'@' -f1)
HOST=$(grep "SQLALCHEMY_DATABASE_URI" .env | cut -d'@' -f2 | cut -d':' -f1)
PORT=$(grep "SQLALCHEMY_DATABASE_URI" .env | cut -d':' -f4 | cut -d'/' -f1)
DBNAME=$(grep "SQLALCHEMY_DATABASE_URI" .env | cut -d'/' -f4)

export PGPASSWORD=$PASSWORD

echo "you are in User $USERNAME, Database $DBNAME, Host $HOST, Port $PORT"
read -p "Are you sure you want to delete all data? (y/n) " -n 1 -r 

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Aborted"
    exit 1
fi

# Get all table names
TABLES=$(psql -U $USERNAME -d $DBNAME -h $HOST -p $PORT -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public';")

# Truncate all tables
for table in $TABLES; do
    psql -U $USERNAME -d $DBNAME -h $HOST -p $PORT -c "TRUNCATE TABLE $table CASCADE;"
done

echo "All data deleted"