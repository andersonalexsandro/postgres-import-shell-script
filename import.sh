#!/bin/bash

if [ ! -f .env ]; then
    echo "Erro: Arquivo .env não encontrado"
    exit 1
fi

USERNAME=$(grep "SQLALCHEMY_DATABASE_URI" .env | cut -d'/' -f3 | cut -d':' -f1)
PASSWORD=$(grep "SQLALCHEMY_DATABASE_URI" .env | cut -d':' -f3 | cut -d'@' -f1)
HOST=$(grep "SQLALCHEMY_DATABASE_URI" .env | cut -d'@' -f2 | cut -d':' -f1)
PORT=$(grep "SQLALCHEMY_DATABASE_URI" .env | cut -d':' -f4 | cut -d'/' -f1)
DBNAME=$(grep "SQLALCHEMY_DATABASE_URI" .env | cut -d'/' -f4)

if [ -z "$USERNAME" ] || [ -z "$PASSWORD" ] || [ -z "$HOST" ] || [ -z "$PORT" ] || [ -z "$DBNAME" ]; then
    echo "Erro: Falha ao extrair variáveis do arquivo .env"
    exit 1
fi

export PGPASSWORD=$PASSWORD

psql -U $USERNAME -d $DBNAME -h $HOST -p $PORT -c "\q"
if [ $? -ne 0 ]; then
    echo "Erro: Falha ao conectar ao banco de dados"
    exit 1
fi

tempfile=$(mktemp)
error_count=0

for sql_file in sql/*.sql; do
    echo "Importando $sql_file..."
    psql -U $USERNAME -d $DBNAME -h $HOST -p $PORT -f $sql_file 2>>$tempfile
    if [ $? -ne 0 ]; then
        echo "Erro ao importar $sql_file"
        ((error_count++))
    fi
done

echo "Número de erros de importação: $error_count"

if [ $error_count -ne 0 ]; then
    echo "Mensagens de erro:"
    cat $tempfile
fi

rm $tempfile

echo "Importação concluída"