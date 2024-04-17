#!/bin/bash
# Requires the database to be up
FLASK_ENV=${FLASK_ENV:-development}
DATABASE_URI=${DATABASE_URI:-postgresql://myuser:mypassword@database:5432/mydatabase}
# Ejecutar el comando con las variables de entorno
FLASK_ENV=$FLASK_ENV DATABASE_URI=$DATABASE_URI python manage.py

