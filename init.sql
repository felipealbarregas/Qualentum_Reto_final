-- init.sql

CREATE TABLE IF NOT EXISTS data (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL
);