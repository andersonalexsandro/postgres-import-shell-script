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

echo "Você está no usuário $USERNAME, banco de dados $DBNAME, host $HOST, porta $PORT"
read -p "Tem certeza de que deseja excluir todos os dados? (y/n) " -n 1 -r 
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Operação abortada"
    exit 1
fi

TABLES=$(psql -U $USERNAME -d $DBNAME -h $HOST -p $PORT -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public';")

if [ $? -ne 0 ]; then
    echo "Erro: Falha ao obter nomes das tabelas"
    exit 1
fi

error_count=0
tempfile=$(mktemp)

for table in $TABLES; do
    psql -U $USERNAME -d $DBNAME -h $HOST -p $PORT -c "TRUNCATE TABLE \"$table\" CASCADE;" 2>>$tempfile
    if [ $? -ne 0 ]; then
        echo "Erro ao truncar a tabela $table"
        ((error_count++))
    fi
done

echo "Número de erros ao truncar tabelas: $error_count"

if [ $error_count -ne 0 ]; then
    echo "Mensagens de erro:"
    cat $tempfile
fi

rm $tempfile

echo "Todos os dados foram excluídos"