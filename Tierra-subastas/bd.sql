-- =============================================
-- AGROBID – Base de datos
-- Importar en phpMyAdmin o con:
--   mysql -u root -p < bd.sql
-- =============================================

CREATE DATABASE IF NOT EXISTS agrobid CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE agrobid;

-- ---- Tabla: usuarios ----
CREATE TABLE IF NOT EXISTS usuarios (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(120)  NOT NULL,
    correo          VARCHAR(180)  NOT NULL UNIQUE,
    telefono        VARCHAR(20)   DEFAULT NULL,
    contrasena      VARCHAR(255)  NOT NULL,
    rol             ENUM('usuario','admin') NOT NULL DEFAULT 'usuario',
    fecha_registro  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ---- Tabla: productos ----
CREATE TABLE IF NOT EXISTS productos (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    usuario_id      INT           NOT NULL,
    nombre          VARCHAR(200)  NOT NULL,
    descripcion     TEXT          NOT NULL,
    categoria       VARCHAR(80)   NOT NULL,
    precio_inicial  DECIMAL(14,2) NOT NULL,
    imagen          VARCHAR(200)  DEFAULT NULL,
    fecha_creacion  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---- Tabla: subastas ----
CREATE TABLE IF NOT EXISTS subastas (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    producto_id     INT           NOT NULL UNIQUE,
    fecha_fin       DATETIME      NOT NULL,
    estado          ENUM('activa','cerrada','cancelada') NOT NULL DEFAULT 'activa',
    fecha_creacion  DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---- Tabla: pujas ----
CREATE TABLE IF NOT EXISTS pujas (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    subasta_id      INT           NOT NULL,
    usuario_id      INT           NOT NULL,
    monto           DECIMAL(14,2) NOT NULL,
    fecha_puja      DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subasta_id) REFERENCES subastas(id) ON DELETE CASCADE,
    FOREIGN KEY (usuario_id) REFERENCES usuarios(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---- Tabla: transacciones ----
CREATE TABLE IF NOT EXISTS transacciones (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    subasta_id      INT           NOT NULL,
    comprador_id    INT           NOT NULL,
    vendedor_id     INT           NOT NULL,
    monto_final     DECIMAL(14,2) NOT NULL,
    estado          ENUM('pendiente','confirmada','cancelada') NOT NULL DEFAULT 'pendiente',
    fecha           DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (subasta_id)   REFERENCES subastas(id),
    FOREIGN KEY (comprador_id) REFERENCES usuarios(id),
    FOREIGN KEY (vendedor_id)  REFERENCES usuarios(id)
) ENGINE=InnoDB;

-- ---- Tabla: imagenes (adicionales por producto) ----
CREATE TABLE IF NOT EXISTS imagenes (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    producto_id     INT           NOT NULL,
    ruta            VARCHAR(200)  NOT NULL,
    fecha_subida    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (producto_id) REFERENCES productos(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- =============================================
-- DATOS DE PRUEBA
-- Contraseñas: admin123 / user123
-- =============================================

INSERT INTO usuarios (nombre, correo, telefono, contrasena, rol) VALUES
('Administrador', 'admin@agrobid.co', '3001234567',
 '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin'),
('Carlos Rodríguez', 'carlos@ejemplo.co', '3107654321',
 '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'usuario'),
('María Gómez', 'maria@ejemplo.co', '3209988776',
 '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'usuario'),
('Luis Peña', 'luis@ejemplo.co', NULL,
 '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'usuario');

-- Nota: el hash anterior corresponde a la contraseña "password"
-- Para usar contraseñas distintas, genera hashes con PHP:
--   echo password_hash('admin123', PASSWORD_DEFAULT);

INSERT INTO productos (usuario_id, nombre, descripcion, categoria, precio_inicial) VALUES
(2, '50 bultos café pergamino – Huila',
 'Café de altura, cosecha reciente. Humedad 11%. Finca ubicada en La Plata, Huila. Calidad especial, puntaje Q 85+.',
 'Café', 2500000.00),

(2, '10 novillos angus cruzado',
 'Novillo engorde, promedio 380 kg. Bien alimentados, desparasitados, con certificado sanitario ICA. Finca en Córdoba.',
 'Ganado', 18000000.00),

(3, 'Lote cosecha maíz amarillo – 8 toneladas',
 'Maíz tecnificado, secado al 14%. Disponible en Montería. Negociable en volumen.',
 'Cosecha', 9600000.00),

(3, 'Microlote café especial – Nariño 20 kg',
 'Variedad Caturra. Proceso lavado. Notas a frutas rojas y caramelo. Ideal exportación.',
 'Café', 800000.00);

INSERT INTO subastas (producto_id, fecha_fin, estado) VALUES
(1, DATE_ADD(NOW(), INTERVAL 3 DAY),  'activa'),
(2, DATE_ADD(NOW(), INTERVAL 12 HOUR),'activa'),
(3, DATE_ADD(NOW(), INTERVAL 5 DAY),  'activa'),
(4, DATE_ADD(NOW(), INTERVAL 2 DAY),  'activa');

INSERT INTO pujas (subasta_id, usuario_id, monto) VALUES
(1, 4, 2600000),
(1, 3, 2750000),
(1, 4, 2900000),
(2, 3, 18500000),
(2, 4, 19000000),
(3, 4, 9800000);
