#!/bin/bash
# Requires the database to be up
FLASK_ENV=development DATABASE_URI=postgresql://myuser:mypassword@database:5432/mydatabase python manage.py
