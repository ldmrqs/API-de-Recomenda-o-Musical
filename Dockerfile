# Usa imagem oficial do Python
FROM python:3.10-slim

# Define diretório de trabalho dentro do container
WORKDIR /app

# Copia os arquivos da API
COPY requirements.txt requirements.txt
COPY app.py app.py

# Instala as dependências
RUN pip install -r requirements.txt

# Expõe a porta 5000
EXPOSE 5000

# Comando para rodar a app
CMD ["python", "app.py"]
