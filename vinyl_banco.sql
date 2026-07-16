DROP SCHEMA IF EXISTS PUBLIC CASCADE;
CREATE SCHEMA PUBLIC;

CREATE TYPE payment_method AS ENUM ('DEBIT_CARD','CREDIT_CARD','PIX','BOLETO','DIGITAL_WALLET','BANK_TRANSFER');

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL CHECK (length(name) > 0),
    document VARCHAR(11) NOT NULL CHECK (document ~ '^[0-9]{11}$'),
    cellphone VARCHAR(20) NOT NULL UNIQUE CHECK (length(cellphone) > 0),
    email VARCHAR(150) NOT NULL UNIQUE CHECK (length(email) > 0),
    password VARCHAR(120) NOT NULL CHECK (length(password) > 0)
);

CREATE TABLE vinyls (
    id SERIAL PRIMARY KEY,
    title VARCHAR(60) NOT NULL CHECK (length(title) > 0),
    price NUMERIC(10,2) NOT NULL CHECK (price > 0),
    description TEXT,
    released_at VARCHAR(4) NOT NULL, -- Alterado para VARCHAR para bater com o "1969" do front
    image_url TEXT NOT NULL
);

-- Tabela de Pedidos adicionada para suportar o endpoint /order/list
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    id_users INTEGER NOT NULL REFERENCES users(id),
    total_price NUMERIC(10,2) NOT NULL CHECK (total_price >= 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Itens do pedido (N para N entre orders e vinyls)
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    id_orders INTEGER NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    id_vinyl INTEGER NOT NULL REFERENCES vinyls(id),
    price_at_purchase NUMERIC(10,2) NOT NULL -- Garante o histórico se o preço do vinil mudar
);

CREATE TABLE payments (
    id SERIAL PRIMARY KEY,
    value NUMERIC(10,2) NOT NULL CHECK (value > 0),
    payment_method payment_method NOT NULL,
    status VARCHAR(60) NOT NULL CHECK (length(status) > 0),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_users INTEGER NOT NULL REFERENCES users(id),
    id_orders INTEGER REFERENCES orders(id) -- Vincula o pagamento ao pedido
);

CREATE TABLE artists (
    id SERIAL PRIMARY KEY,
    name VARCHAR(60) NOT NULL CHECK (length(name) > 0),
    description TEXT
);

CREATE TABLE accessibility (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL CHECK (length(name) > 0),
    description TEXT
);

CREATE TABLE genres (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE CHECK (length(name) > 0)
);

CREATE TABLE vinyl_genres (
    id SERIAL PRIMARY KEY,
    id_vinyl INTEGER NOT NULL REFERENCES vinyls(id) ON DELETE CASCADE,
    id_genre INTEGER NOT NULL REFERENCES genres(id) ON DELETE CASCADE
);

CREATE TABLE genre_favorites (
    id SERIAL PRIMARY KEY,
    id_users INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    id_genre INTEGER NOT NULL REFERENCES genres(id) ON DELETE CASCADE
);

CREATE TABLE carts (
    id SERIAL PRIMARY KEY,
    id_users INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    id_vinyl INTEGER NOT NULL REFERENCES vinyls(id) ON DELETE CASCADE
);

CREATE TABLE vinyl_artists (
    id SERIAL PRIMARY KEY,
    id_vinyl INTEGER NOT NULL REFERENCES vinyls(id) ON DELETE CASCADE,
    id_artista INTEGER NOT NULL REFERENCES artists(id) ON DELETE CASCADE
);

CREATE TABLE user_accessibility (
    id SERIAL PRIMARY KEY,
    id_users INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    id_accessibility INTEGER NOT NULL REFERENCES accessibility(id) ON DELETE CASCADE
);

CREATE TABLE addresses (
    id SERIAL PRIMARY KEY,
    number VARCHAR(12) NOT NULL CHECK (length(number) > 0),
    complement TEXT,
    zip_code VARCHAR(8) NOT NULL CHECK (zip_code ~ '^[0-9]{8}$'),
    id_users INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE
);