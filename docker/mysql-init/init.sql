CREATE DATABASE IF NOT EXISTS aiquery_manager CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Ajuste o usuário/credenciais conforme o que seu application-prod.properties usa.
-- Atualmente seu app usa root como padrão, mas se você quiser outro usuário, ajuste aqui e no Compose.
GRANT ALL PRIVILEGES ON aiquery_manager.* TO 'root'@'%' IDENTIFIED BY 'true';
FLUSH PRIVILEGES;
