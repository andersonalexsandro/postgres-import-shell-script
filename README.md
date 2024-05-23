# PostgreSQL Import Shell Script

Este script foi desenvolvido para ser utilizado em sistemas Unix-like (Linux ou MacOS).

## Requisitos

- PostgreSQL instalado e em execução.
- Arquivo `.env` contendo suas credenciais de banco de dados.
- Tabelas já criadas no banco de dados.
- Arquivos `.sql` no diretório `sql`.

## Uso

1. Clone ou faça o download deste repositório.
2. Crie um arquivo `.env` dentro do diretório do script e adicione suas credenciais de banco de dados conforme o exemplo abaixo:
3. Dê permissões de execução aos scripts de importação e rebase executando:

```bash
chmod +x import.sh rebase.sh

##Execute os scripts:

./import.sh
## ou
./rebase.sh
