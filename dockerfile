# Usa una imagen base de Python
FROM python:3.9

# Establece el directorio de trabajo dentro del contenedor
WORKDIR /app

# Copia los archivos de la aplicación al contenedor
COPY . /app

# Instala las dependencias de la aplicación
RUN pip install --no-cache-dir -r requirements.txt

# Expone el puerto en el que la aplicación Flask se ejecutará
EXPOSE 5000

# Define la variable de entorno FLASK_APP
ENV FLASK_APP=run.py
# Configurar las variables de entorno
ENV SQLALCHEMY_DATABASE_URI postgresql://myuser:mypassword@database/mydatabase

# Ejecuta la aplicación Flask cuando se inicie el contenedor
CMD ["flask", "run", "--host=0.0.0.0"]
