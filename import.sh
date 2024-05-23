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

TABLES=$(psql -U $USERNAME -d $DBNAME -h $HOST -p $PORT -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public';")

tempfile=$(mktemp)
error_count=0

for sql_file in sql/*.sql; do
    psql -U $USERNAME -d $DBNAME -h $HOST -p $PORT -f $sql_file 2>>$tempfile
    if [ $? -ne 0 ]; then
        ((error_count++))
    fi
done

echo "Number of import errors: $error_count"

if [ $error_count -ne 0 ]; then
    echo "Error messages:"
    cat $tempfile
fi

rm $tempfile

echo "Import completed"