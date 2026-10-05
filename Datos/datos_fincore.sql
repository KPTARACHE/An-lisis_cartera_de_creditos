-- ============================================================
-- DATOS DE PRÁCTICA — Proyecto FinCore S.A.
-- Proyecto Avanzado SQL — IPS Datax
-- Motor: MySQL 8.0+
-- ============================================================

DROP DATABASE IF EXISTS fincore_sa;
CREATE DATABASE fincore_sa CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE fincore_sa;

-- ------------------------------------------------------------
-- TABLA: clientes
-- ------------------------------------------------------------
CREATE TABLE clientes (
    id_cliente      INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    documento       VARCHAR(20)  NOT NULL UNIQUE,
    email           VARCHAR(100),
    telefono        VARCHAR(20),
    ciudad          VARCHAR(50),
    segmento        ENUM('Personal','Empresarial') NOT NULL,
    categoria_riesgo CHAR(1)     NOT NULL COMMENT 'A=Excelente, B=Bueno, C=Regular, D=Alto riesgo',
    fecha_alta      DATE         NOT NULL,
    activo          TINYINT(1)   NOT NULL DEFAULT 1
);

-- ------------------------------------------------------------
-- TABLA: productos_credito
-- ------------------------------------------------------------
CREATE TABLE productos_credito (
    id_producto     INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(80)  NOT NULL,
    tipo            ENUM('Personal','Empresarial','Hipotecario','Automotriz') NOT NULL,
    tasa_anual      DECIMAL(5,2) NOT NULL COMMENT 'Tasa nominal anual en %',
    plazo_min_meses INT          NOT NULL,
    plazo_max_meses INT          NOT NULL,
    monto_min       DECIMAL(12,2) NOT NULL,
    monto_max       DECIMAL(12,2) NOT NULL
);

-- ------------------------------------------------------------
-- TABLA: prestamos
-- ------------------------------------------------------------
CREATE TABLE prestamos (
    id_prestamo     INT AUTO_INCREMENT PRIMARY KEY,
    id_cliente      INT           NOT NULL,
    id_producto     INT           NOT NULL,
    monto_otorgado  DECIMAL(12,2) NOT NULL,
    tasa_aplicada   DECIMAL(5,2)  NOT NULL,
    plazo_meses     INT           NOT NULL,
    fecha_otorgamiento DATE       NOT NULL,
    fecha_vencimiento  DATE       NOT NULL,
    cuota_mensual   DECIMAL(10,2) NOT NULL,
    saldo_pendiente DECIMAL(12,2) NOT NULL,
    estado          ENUM('Activo','Cancelado','Vencido','Refinanciado') NOT NULL DEFAULT 'Activo',
    dias_mora       INT           NOT NULL DEFAULT 0,
    FOREIGN KEY (id_cliente)  REFERENCES clientes(id_cliente),
    FOREIGN KEY (id_producto) REFERENCES productos_credito(id_producto)
);

-- ------------------------------------------------------------
-- TABLA: pagos
-- ------------------------------------------------------------
CREATE TABLE pagos (
    id_pago         INT AUTO_INCREMENT PRIMARY KEY,
    id_prestamo     INT           NOT NULL,
    fecha_pago      DATE          NOT NULL,
    monto_pagado    DECIMAL(10,2) NOT NULL,
    tipo_pago       ENUM('Cuota','Prepago','Mora') NOT NULL,
    canal           ENUM('App','Sucursal','Transferencia','Débito Automático') NOT NULL,
    registrado_por  VARCHAR(50)   NOT NULL DEFAULT 'sistema',
    FOREIGN KEY (id_prestamo) REFERENCES prestamos(id_prestamo)
);

-- ------------------------------------------------------------
-- TABLA: auditoria_prestamos (el alumno la llena con trigger)
-- ------------------------------------------------------------
CREATE TABLE auditoria_prestamos (
    id_auditoria    INT AUTO_INCREMENT PRIMARY KEY,
    id_prestamo     INT           NOT NULL,
    campo_modificado VARCHAR(50)  NOT NULL,
    valor_anterior  VARCHAR(100),
    valor_nuevo     VARCHAR(100),
    fecha_cambio    DATETIME      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    usuario         VARCHAR(50)   NOT NULL DEFAULT (USER())
);

-- ------------------------------------------------------------
-- TABLA: resumen_mensual (el alumno la llena con procedimiento)
-- ------------------------------------------------------------
CREATE TABLE resumen_mensual (
    id_resumen      INT AUTO_INCREMENT PRIMARY KEY,
    anio            INT           NOT NULL,
    mes             INT           NOT NULL,
    total_prestamos INT           NOT NULL DEFAULT 0,
    monto_total_otorgado DECIMAL(14,2) NOT NULL DEFAULT 0,
    total_pagos_recibidos DECIMAL(14,2) NOT NULL DEFAULT 0,
    prestamos_vencidos   INT       NOT NULL DEFAULT 0,
    tasa_morosidad  DECIMAL(5,2)  NOT NULL DEFAULT 0,
    fecha_generacion DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_anio_mes (anio, mes)
);

-- ============================================================
-- INSERTS
-- ============================================================

INSERT INTO productos_credito (nombre, tipo, tasa_anual, plazo_min_meses, plazo_max_meses, monto_min, monto_max) VALUES
('Crédito Personal Flex',    'Personal',     28.00,  6,  48,   1000.00,  50000.00),
('Crédito Personal Plus',    'Personal',     22.00, 12,  60,   5000.00,  80000.00),
('Crédito Empresarial Básico','Empresarial', 18.00, 12,  36,  10000.00, 200000.00),
('Crédito Empresarial Pro',  'Empresarial',  15.50, 24,  72,  50000.00, 500000.00),
('Crédito Hipotecario',      'Hipotecario',  12.00, 60, 240, 100000.00,1000000.00),
('Crédito Automotriz',       'Automotriz',   19.50, 24,  72,   8000.00, 120000.00);

INSERT INTO clientes (nombre, documento, email, telefono, ciudad, segmento, categoria_riesgo, fecha_alta) VALUES
-- Categoría A (excelente) — 6 clientes
('Carlos Méndez Torres',     'DNI-10234567', 'cmendez@email.com',    '555-1001', 'Ciudad de México', 'Personal',    'A', '2021-03-15'),
('Laura Ramírez Vega',       'DNI-10234568', 'lramirez@email.com',   '555-1002', 'Guadalajara',      'Personal',    'A', '2021-05-20'),
('Inversiones GHL S.A.',     'RUC-20512345', 'contacto@ghl.com',     '555-2001', 'Monterrey',        'Empresarial', 'A', '2020-11-10'),
('Distribuidora Pacífico',   'RUC-20512346', 'dpacif@empresa.com',   '555-2002', 'Ciudad de México', 'Empresarial', 'A', '2021-01-08'),
('Miguel Ángel Fuentes',     'DNI-10234571', 'mfuentes@email.com',   '555-1005', 'Puebla',           'Personal',    'A', '2022-02-14'),
('Sofía Castillo Herrera',   'DNI-10234572', 'scastillo@email.com',  '555-1006', 'Guadalajara',      'Personal',    'A', '2022-07-30'),
-- Categoría B (bueno) — 6 clientes
('Roberto Silva Pardo',      'DNI-10234569', 'rsilva@email.com',     '555-1003', 'Monterrey',        'Personal',    'B', '2021-08-12'),
('Ana Patricia Ochoa',       'DNI-10234570', 'apochoa@email.com',    '555-1004', 'Puebla',           'Personal',    'B', '2022-01-25'),
('Tech Solutions MX S.A.',   'RUC-20512347', 'info@techsol.com',     '555-2003', 'Ciudad de México', 'Empresarial', 'B', '2021-06-18'),
('Constructora Norteña',     'RUC-20512348', 'cnortena@empresa.com', '555-2004', 'Monterrey',        'Empresarial', 'B', '2021-09-05'),
('Diego Hernández Cruz',     'DNI-10234575', 'dhernandez@email.com', '555-1009', 'Ciudad de México', 'Personal',    'B', '2022-04-10'),
('Valentina Torres Ruiz',    'DNI-10234576', 'vtorres@email.com',    '555-1010', 'Guadalajara',      'Personal',    'B', '2022-09-22'),
-- Categoría C (regular) — 5 clientes
('Jorge Luis Paredes',       'DNI-10234573', 'jparedes@email.com',   '555-1007', 'Ciudad de México', 'Personal',    'C', '2022-03-18'),
('Importadora del Centro',   'RUC-20512349', 'imp.centro@emp.com',   '555-2005', 'Puebla',           'Empresarial', 'C', '2022-05-30'),
('Patricia Morales Díaz',    'DNI-10234577', 'pmorales@email.com',   '555-1011', 'Monterrey',        'Personal',    'C', '2022-11-05'),
('Comercial Rápida S.R.L.',  'RUC-20512351', 'crapida@empresa.com',  '555-2007', 'Ciudad de México', 'Empresarial', 'C', '2023-01-20'),
('Fernando López Salinas',   'DNI-10234579', 'flopez@email.com',     '555-1013', 'Puebla',           'Personal',    'C', '2023-03-08'),
-- Categoría D (alto riesgo) — 3 clientes
('Elena Gutiérrez Blanco',   'DNI-10234574', 'egutierrez@email.com', '555-1008', 'Guadalajara',      'Personal',    'D', '2022-06-05'),
('Servicios Omega Ltda.',     'RUC-20512350', 'omega@empresa.com',    '555-2006', 'Ciudad de México', 'Empresarial', 'D', '2022-08-15'),
('Andrés Ramírez Soto',      'DNI-10234578', 'aramirez@email.com',   '555-1012', 'Monterrey',        'Personal',    'D', '2022-12-12');

INSERT INTO prestamos (id_cliente, id_producto, monto_otorgado, tasa_aplicada, plazo_meses, fecha_otorgamiento, fecha_vencimiento, cuota_mensual, saldo_pendiente, estado, dias_mora) VALUES
-- Préstamos ACTIVOS
(1,  2, 45000.00, 22.00, 36, '2023-01-10', '2026-01-10', 1672.00, 28000.00, 'Activo', 0),
(2,  1, 15000.00, 28.00, 24, '2023-03-15', '2025-03-15',  820.00,  6500.00, 'Activo', 0),
(3,  4,180000.00, 15.50, 60, '2022-06-01', '2027-06-01', 4320.00,130000.00, 'Activo', 0),
(4,  3, 90000.00, 18.00, 36, '2023-02-20', '2026-02-20', 3250.00, 62000.00, 'Activo', 0),
(5,  6, 35000.00, 19.50, 48, '2023-05-10', '2027-05-10', 1050.00, 28000.00, 'Activo', 0),
(6,  2, 25000.00, 22.00, 24, '2023-07-01', '2025-07-01', 1285.00, 15000.00, 'Activo', 0),
(7,  1, 20000.00, 28.00, 36, '2022-11-15', '2025-11-15',  855.00, 12000.00, 'Activo', 0),
(8,  2, 30000.00, 22.00, 36, '2023-04-20', '2026-04-20', 1115.00, 22500.00, 'Activo', 0),
(9,  3, 75000.00, 18.00, 24, '2023-06-01', '2025-06-01', 3740.00, 45000.00, 'Activo', 0),
(10, 4,250000.00, 15.50, 72, '2022-09-10', '2028-09-10', 5100.00,200000.00, 'Activo', 0),
(11, 1, 12000.00, 28.00, 18, '2023-08-05', '2025-02-05',  820.00,  7000.00, 'Activo', 0),
(12, 2, 18000.00, 22.00, 24, '2023-09-12', '2025-09-12',  925.00, 12000.00, 'Activo', 0),
(5,  5,200000.00, 12.00,120, '2022-04-01', '2032-04-01', 2860.00,175000.00, 'Activo', 0),
-- Préstamos VENCIDOS (para ejercicios de mora y aging)
(13, 1, 10000.00, 28.00, 12, '2022-08-01', '2023-08-01',  960.00,  8500.00, 'Vencido', 95),
(18, 1,  8000.00, 28.00, 12, '2022-10-15', '2023-10-15',  768.00,  7200.00, 'Vencido',180),
(19, 3, 55000.00, 18.00, 24, '2021-12-01', '2023-12-01', 2740.00, 40000.00, 'Vencido', 62),
-- Préstamos CANCELADOS
(1,  1, 10000.00, 28.00, 12, '2022-01-01', '2023-01-01',  955.00,     0.00, 'Cancelado', 0),
(2,  6, 20000.00, 19.50, 24, '2021-06-01', '2023-06-01', 1015.00,     0.00, 'Cancelado', 0),
(3,  3, 50000.00, 18.00, 18, '2021-03-01', '2022-09-01', 3180.00,     0.00, 'Cancelado', 0),
-- Préstamos REFINANCIADOS
(14, 3, 40000.00, 18.00, 24, '2022-07-01', '2024-07-01', 1990.00, 18000.00, 'Refinanciado', 0),
(20, 2, 22000.00, 22.00, 24, '2022-09-01', '2024-09-01', 1130.00, 10000.00, 'Refinanciado', 0);

INSERT INTO pagos (id_prestamo, fecha_pago, monto_pagado, tipo_pago, canal) VALUES
-- Pagos del préstamo 1 (Carlos Méndez)
(1, '2023-02-10', 1672.00, 'Cuota', 'Débito Automático'),
(1, '2023-03-10', 1672.00, 'Cuota', 'Débito Automático'),
(1, '2023-04-10', 1672.00, 'Cuota', 'Débito Automático'),
(1, '2023-05-10', 1672.00, 'Cuota', 'Débito Automático'),
(1, '2023-06-10', 1672.00, 'Cuota', 'Débito Automático'),
(1, '2023-07-10', 1672.00, 'Cuota', 'Débito Automático'),
-- Pagos del préstamo 2 (Laura Ramírez)
(2, '2023-04-15',  820.00, 'Cuota', 'App'),
(2, '2023-05-15',  820.00, 'Cuota', 'App'),
(2, '2023-06-15',  820.00, 'Cuota', 'App'),
(2, '2023-07-15',  820.00, 'Cuota', 'App'),
(2, '2023-08-15',  820.00, 'Cuota', 'App'),
-- Pagos del préstamo 3 (Inversiones GHL)
(3, '2022-07-01', 4320.00, 'Cuota', 'Transferencia'),
(3, '2022-08-01', 4320.00, 'Cuota', 'Transferencia'),
(3, '2022-09-01', 4320.00, 'Cuota', 'Transferencia'),
(3, '2022-10-01', 4320.00, 'Cuota', 'Transferencia'),
(3, '2022-11-01', 4320.00, 'Cuota', 'Transferencia'),
(3, '2022-12-01', 4320.00, 'Cuota', 'Transferencia'),
(3, '2023-01-01', 4320.00, 'Cuota', 'Transferencia'),
(3, '2023-02-01', 4320.00, 'Cuota', 'Transferencia'),
(3, '2023-03-01', 4320.00, 'Cuota', 'Transferencia'),
-- Pagos del préstamo 7 (Roberto Silva)
(7, '2022-12-15',  855.00, 'Cuota', 'Sucursal'),
(7, '2023-01-15',  855.00, 'Cuota', 'Sucursal'),
(7, '2023-02-15',  855.00, 'Cuota', 'Sucursal'),
(7, '2023-03-15',  855.00, 'Cuota', 'Sucursal'),
-- Prepago del préstamo 5
(5, '2023-10-15', 5000.00, 'Prepago', 'Transferencia'),
-- Pagos con mora (préstamos vencidos)
(14, '2023-09-20',  960.00, 'Cuota', 'Sucursal'),
(14, '2023-09-20',  150.00, 'Mora',  'Sucursal'),
(15, '2024-04-10',  768.00, 'Cuota', 'App'),
(15, '2024-04-10',  220.00, 'Mora',  'App'),
-- Pagos del préstamo 17 (Cancelado — Laura)
(17, '2021-07-01', 1015.00, 'Cuota', 'Débito Automático'),
(17, '2021-08-01', 1015.00, 'Cuota', 'Débito Automático'),
(17, '2021-09-01', 1015.00, 'Cuota', 'Débito Automático'),
(17, '2021-10-01', 1015.00, 'Cuota', 'Débito Automático'),
(17, '2021-11-01', 1015.00, 'Cuota', 'Débito Automático'),
(17, '2021-12-01', 1015.00, 'Cuota', 'Débito Automático'),
(17, '2022-01-01', 1015.00, 'Cuota', 'Débito Automático'),
(17, '2022-02-01', 1015.00, 'Cuota', 'Débito Automático'),
(17, '2022-03-01', 1015.00, 'Cuota', 'Débito Automático'),
(17, '2022-04-01', 1015.00, 'Cuota', 'Débito Automático'),
(17, '2022-05-01', 1015.00, 'Cuota', 'Débito Automático'),
(17, '2022-06-01', 1015.00, 'Cuota', 'Débito Automático'),
-- Pagos del préstamo 9 (Tech Solutions)
(9, '2023-07-01', 3740.00, 'Cuota', 'Transferencia'),
(9, '2023-08-01', 3740.00, 'Cuota', 'Transferencia'),
(9, '2023-09-01', 3740.00, 'Cuota', 'Transferencia'),
(9, '2023-10-01', 3740.00, 'Cuota', 'Transferencia'),
(9, '2023-11-01', 3740.00, 'Cuota', 'Transferencia'),
(9, '2023-12-01', 3740.00, 'Cuota', 'Transferencia');

-- ============================================================
--- Exploración y función personalizada
-- Crea una función llamada fn_clasificar_mora que reciba los días de mora de un préstamo y devuelva su categoría de aging según la política interna: Al día, Mora Temprana (1-30d), Mora Media (31-60d), Mora Grave (61-90d), Mora Crítica (+90d).
-- VERIFICACIÓN FUNCIÓN: CLASIFICACIÓN DE MORA
-- ============================================================
DROP FUNCTION IF EXISTS fn_clasificar_mora;

DELIMITER //

CREATE FUNCTION fn_clasificar_mora(dias_mora INT)
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
    IF dias_mora <= 0 THEN
        RETURN 'Al día';
    ELSEIF dias_mora BETWEEN 1 AND 30 THEN
        RETURN 'Mora Temprana (1-30d)';
    ELSEIF dias_mora BETWEEN 31 AND 60 THEN
        RETURN 'Mora Media (31-60d)';
    ELSEIF dias_mora BETWEEN 61 AND 90 THEN
        RETURN 'Mora Grave (61-90d)';
    ELSE
        RETURN 'Mora Crítica (+90d)';
    END IF;
END //

DELIMITER ;

-- ============================================================
-- VERIFICACIÓN FUNCIÓN: CLASIFICACIÓN DE MORA
-- ============================================================

SELECT fn_clasificar_mora(180) AS clasificacion;

SELECT fn_clasificar_mora(5);

SELECT 
    id_prestamo,
    dias_mora,
    fn_clasificar_mora(dias_mora) AS categoria_aging
FROM prestamos;

-- ============================================================
--- Vistas de análisis
-- Crea dos vistas que serán la base de los reportes ejecutivos:
-- vw_estado_cartera: debe mostrar cada préstamo con los datos del cliente, el producto, el porcentaje de saldo restante y la clasificación de mora (usando la función del Paso 1). Página 2 de 3
-- vw_resumen_clientes: debe mostrar, por cliente, el total de préstamos, el monto total otorgado, el saldo pendiente consolidado, los días de mora máximos y si tiene mora activa.
-- Consulta ambas vistas para verificar que los datos son correctos.
-- ============================================================

-- ============================================================
-- vw_estado_cartera: debe mostrar cada préstamo con los datos del cliente, el producto, el porcentaje de saldo restante y la clasificación de mora (usando la función del Paso 1).
-- ============================================================

CREATE OR REPLACE VIEW vw_estado_cartera AS
SELECT 
    pt.id_prestamo,
    c.nombre AS cliente,
    c.segmento,
    c.categoria_riesgo,
    pd.nombre AS producto,
    pt.monto_otorgado,
    pt.saldo_pendiente,
    pt.tasa_aplicada,
    ROUND((pt.saldo_pendiente / pt.monto_otorgado) * 100, 2) AS porcentaje_saldo_restante,
    pt.dias_mora,
    fn_clasificar_mora(pt.dias_mora) AS categoria_mora
FROM clientes c
JOIN prestamos pt 
    ON c.id_cliente = pt.id_cliente
JOIN productos_credito pd 
    ON pd.id_producto = pt.id_producto;

-- ============================================================
-- Validación 
-- ============================================================

SELECT COUNT(*) AS total_prestamos
FROM vw_estado_cartera;

SELECT *
FROM vw_estado_cartera;

SELECT *
FROM vw_estado_cartera
WHERE categoria_mora COLLATE utf8mb4_unicode_ci 
      <> 'Al día' COLLATE utf8mb4_unicode_ci;
      
-- ============================================================
-- vw_resumen_clientes: debe mostrar, por cliente, el total de préstamos, el monto total otorgado, el saldo pendiente consolidado, los días de mora máximos y si tiene mora activa.
-- ============================================================

CREATE VIEW vw_resumen_clientes AS
SELECT
c.nombre as cliente,
count(pt.id_prestamo) as total_prestamos, 
sum(pt.monto_otorgado) as total_monto_otorgado,
sum(pt.saldo_pendiente) as total_saldo_pendiente_consolidado, 
max(dias_mora) as max_dias_mora ,
CASE
        WHEN MAX(pt.dias_mora) > 0 THEN 'Sí'
        ELSE 'No'
    END AS mora_activa
FROM clientes c
JOIN prestamos pt ON c.id_cliente = pt.id_cliente
GROUP BY
    c.id_cliente,
    c.nombre;
    
SELECT *
FROM vw_resumen_clientes;

-- ============================================================
-- Parte 3 — Trigger de auditoría
-- Implementa un mecanismo de auditoría automática:
-- Crea el trigger trg_auditoria_estado que se dispare después de actualizar la tabla prestamos.
-- El trigger debe registrar en auditoria_prestamos cualquier cambio en los campos estado y dias_mora, guardando el valor anterior y el nuevo valor.
-- Prueba el trigger actualizando manualmente un préstamo y verificando que la tabla auditoria_prestamos generó los registros correspondientes.
-- ============================================================

DELIMITER //

CREATE TRIGGER trg_auditoria_estado
AFTER UPDATE ON prestamos
FOR EACH ROW
BEGIN

    -- Auditar cambio en estado
    IF OLD.estado <> NEW.estado THEN
        INSERT INTO auditoria_prestamos (
            id_prestamo,
            campo_modificado,
            valor_anterior,
            valor_nuevo,
            fecha_cambio
        )
        VALUES (
            NEW.id_prestamo,
            'estado',
            OLD.estado,
            NEW.estado,
            NOW()
        );
    END IF;

    -- Auditar cambio en dias_mora
    IF OLD.dias_mora <> NEW.dias_mora THEN
        INSERT INTO auditoria_prestamos (
            id_prestamo,
            campo_modificado,
            valor_anterior,
            valor_nuevo,
            fecha_cambio
        )
        VALUES (
            NEW.id_prestamo,
            'dias_mora',
            OLD.dias_mora,
            NEW.dias_mora,
            NOW()
        );
    END IF;

END //

DELIMITER ;

-- ============================================================
-- Validación
-- ============================================================
UPDATE prestamos
SET dias_mora = 70
WHERE id_prestamo = 15;

SELECT *
FROM prestamos
WHERE id_prestamo = 15;

SELECT *
FROM auditoria_prestamos;

UPDATE prestamos
SET estado = 'Refinanciado'
WHERE id_prestamo = 15;

SELECT *
FROM auditoria_prestamos
WHERE id_prestamo = 15;

SELECT 
    id_auditoria,
    id_prestamo,
    campo_modificado,
    valor_anterior,
    valor_nuevo
FROM auditoria_prestamos
ORDER BY id_auditoria;
-- ============================================================
-- Parte 4 — Procedimientos almacenados
-- Crea tres procedimientos que automatizan las operaciones principales del negocio:
-- sp_registrar_pago: recibe el ID del préstamo, el monto, el tipo de pago y el canal. Debe validar que el préstamo exista y esté activo (o vencido), actualizar el saldo pendiente y registrar el pago. Si el saldo llega a cero, debe cambiar el estado a Cancelado. Todo dentro de una transacción con manejo de errores.
-- sp_generar_resumen_mensual: recibe año y mes, calcula los indicadores del período (préstamos otorgados, monto total, pagos recibidos, tasa de morosidad) y los inserta o actualiza en la tabla resumen_mensual.
-- sp_refinanciar_prestamo: recibe el ID del préstamo a refinanciar, el nuevo plazo en meses y la nueva tasa. Debe marcar el préstamo original como Refinanciado y crear uno nuevo con el saldo pendiente como monto, dentro de una transacción que garantice que ambas operaciones se realicen juntas o ninguna.
-- ============================================================

DELIMITER //

CREATE PROCEDURE sp_registrar_pago(
    IN p_id_prestamo INT,
    IN p_monto DECIMAL(10,2),
    IN p_tipo_pago VARCHAR(20),
    IN p_canal VARCHAR(30)
)
BEGIN

    DECLARE v_saldo DECIMAL(12,2);
    DECLARE v_estado VARCHAR(20);

    -- Manejo de errores
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al registrar el pago. La transacción fue revertida.';
    END;

    START TRANSACTION;

    -- Verificar que el préstamo exista y obtener sus datos
    SELECT saldo_pendiente, estado
    INTO v_saldo, v_estado
    FROM prestamos
    WHERE id_prestamo = p_id_prestamo
    FOR UPDATE;

    -- Validar que el préstamo esté Activo o Vencido
    IF v_estado NOT IN ('Activo', 'Vencido') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El préstamo no está Activo ni Vencido.';
    END IF;

    -- Validar que el monto sea positivo
    IF p_monto <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El monto del pago debe ser mayor que cero.';
    END IF;

    -- Validar que el pago no supere el saldo pendiente
    IF p_monto > v_saldo THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El monto del pago supera el saldo pendiente.';
    END IF;

    -- Actualizar saldo pendiente
    UPDATE prestamos
    SET saldo_pendiente = saldo_pendiente - p_monto
    WHERE id_prestamo = p_id_prestamo;

    -- Registrar el pago
    INSERT INTO pagos (
        id_prestamo,
        fecha_pago,
        monto_pagado,
        tipo_pago,
        canal
    )
    VALUES (
        p_id_prestamo,
        CURDATE(),
        p_monto,
        p_tipo_pago,
        p_canal
    );

    -- Si el saldo llega a cero, cambiar estado a Cancelado
    IF v_saldo - p_monto = 0 THEN
        UPDATE prestamos
        SET estado = 'Cancelado'
        WHERE id_prestamo = p_id_prestamo;
    END IF;

    COMMIT;

END //

DELIMITER ;

-- ============================================================
-- Validación
-- ============================================================

SELECT 
    id_prestamo,
    saldo_pendiente,
    estado,
    dias_mora
FROM prestamos
WHERE estado IN ('Activo', 'Vencido');

-- abonamos 500.00 al id 2 y revisamos que se descontaron de la deuda
CALL sp_registrar_pago(2, 500.00, 'Cuota', 'App');

SELECT *
FROM pagos
WHERE id_prestamo = 2;

-- abonamos el total de la deuda y confirmamos que estado paso a cancelado
CALL sp_registrar_pago(11, 7000.00, 'Cuota', 'App');

SELECT 
    id_prestamo,
    saldo_pendiente,
    estado
FROM prestamos
WHERE id_prestamo = 11;

-- Genera error pago cancelado 
CALL sp_registrar_pago(
    11,
    100.00,
    'Cuota',
    'App'
);

-- Genera error pago refinanciado

CALL sp_registrar_pago(
    15,
    100.00,
    'Cuota',
    'App'
);
-- ============================================================
-- sp_generar_resumen_mensual: recibe año y mes, calcula los indicadores del período (préstamos otorgados, monto total, pagos recibidos, tasa de morosidad) y los inserta o actualiza en la tabla resumen_mensual.
-- ============================================================

DESCRIBE resumen_mensual;

DROP PROCEDURE IF EXISTS sp_generar_resumen_mensual;

DELIMITER //

CREATE PROCEDURE sp_generar_resumen_mensual(
    IN p_anio INT,
    IN p_mes INT
)
BEGIN
    DECLARE v_total_prestamos INT DEFAULT 0;
    DECLARE v_monto_total DECIMAL(14,2) DEFAULT 0;
    DECLARE v_total_pagos DECIMAL(14,2) DEFAULT 0;
    DECLARE v_prestamos_vencidos INT DEFAULT 0;
    DECLARE v_tasa_morosidad DECIMAL(5,2) DEFAULT 0;

    -- Préstamos otorgados en el período
    SELECT
        COUNT(*),
        COALESCE(SUM(monto_otorgado), 0)
    INTO
        v_total_prestamos,
        v_monto_total
    FROM prestamos
    WHERE YEAR(fecha_otorgamiento) = p_anio
      AND MONTH(fecha_otorgamiento) = p_mes;

    -- Pagos recibidos en el período
    SELECT
        COALESCE(SUM(monto_pagado), 0)
    INTO v_total_pagos
    FROM pagos
    WHERE YEAR(fecha_pago) = p_anio
      AND MONTH(fecha_pago) = p_mes;

    -- Préstamos vencidos
    SELECT
        COUNT(*)
    INTO v_prestamos_vencidos
    FROM prestamos
    WHERE YEAR(fecha_otorgamiento) = p_anio
      AND MONTH(fecha_otorgamiento) = p_mes
      AND dias_mora > 0;

    -- Tasa de morosidad
    IF v_total_prestamos > 0 THEN
        SET v_tasa_morosidad =
            (v_prestamos_vencidos / v_total_prestamos) * 100;
    END IF;

    -- Insertar o actualizar el resumen
    INSERT INTO resumen_mensual (
        anio,
        mes,
        total_prestamos,
        monto_total_otorgado,
        total_pagos_recibidos,
        prestamos_vencidos,
        tasa_morosidad
    )
    VALUES (
        p_anio,
        p_mes,
        v_total_prestamos,
        v_monto_total,
        v_total_pagos,
        v_prestamos_vencidos,
        v_tasa_morosidad
    )
    ON DUPLICATE KEY UPDATE
        total_prestamos = VALUES(total_prestamos),
        monto_total_otorgado = VALUES(monto_total_otorgado),
        total_pagos_recibidos = VALUES(total_pagos_recibidos),
        prestamos_vencidos = VALUES(prestamos_vencidos),
        tasa_morosidad = VALUES(tasa_morosidad),
        fecha_generacion = CURRENT_TIMESTAMP;

END //

DELIMITER ;
-- ============================================================
-- Validación
-- ============================================================
CALL sp_generar_resumen_mensual(2023, 4);
CALL sp_generar_resumen_mensual(2023, 1);
CALL sp_generar_resumen_mensual(2023, 5);

SELECT *
FROM resumen_mensual
ORDER BY anio, mes;

-- ============================================================
--- sp_refinanciar_prestamo: recibe el ID del préstamo a refinanciar, el nuevo plazo en meses y la nueva tasa. Debe marcar el préstamo original como Refinanciado y crear uno nuevo con el saldo pendiente como monto, dentro de una transacción que garantice que ambas operaciones se realicen juntas o ninguna.
 -- ============================================================ 
	
DROP PROCEDURE IF EXISTS sp_refinanciar_prestamo;

DELIMITER //

CREATE PROCEDURE sp_refinanciar_prestamo(
    IN p_id_prestamo INT,
    IN p_nuevo_plazo INT,
    IN p_nueva_tasa DECIMAL(5,2)
)
BEGIN
    DECLARE v_id_cliente INT;
    DECLARE v_id_producto INT;
    DECLARE v_saldo DECIMAL(12,2);
    DECLARE v_estado VARCHAR(20);
    DECLARE v_cuota DECIMAL(10,2);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error al refinanciar el préstamo. La transacción fue revertida.';
    END;

    START TRANSACTION;

    -- Obtener información del préstamo
    SELECT
        id_cliente,
        id_producto,
        saldo_pendiente,
        estado
    INTO
        v_id_cliente,
        v_id_producto,
        v_saldo,
        v_estado
    FROM prestamos
    WHERE id_prestamo = p_id_prestamo
    FOR UPDATE;

    -- Validar estado
    IF v_estado NOT IN ('Activo', 'Vencido') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El préstamo no puede ser refinanciado.';
    END IF;

    -- Validar plazo y tasa
    IF p_nuevo_plazo <= 0 OR p_nueva_tasa < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El plazo o la tasa no son válidos.';
    END IF;

    -- Calcular cuota mensual aproximada
    SET v_cuota =
        v_saldo * (1 + (p_nueva_tasa / 100) / 12 * p_nuevo_plazo)
        / p_nuevo_plazo;

    -- Marcar préstamo original como Refinanciado
    UPDATE prestamos
    SET estado = 'Refinanciado'
    WHERE id_prestamo = p_id_prestamo;

    -- Crear nuevo préstamo
    INSERT INTO prestamos (
        id_cliente,
        id_producto,
        plazo_meses,
        dias_mora,
        estado,
        tasa_aplicada,
        monto_otorgado,
        saldo_pendiente,
        cuota_mensual,
        fecha_otorgamiento,
        fecha_vencimiento
    )
    VALUES (
        v_id_cliente,
        v_id_producto,
        p_nuevo_plazo,
        0,
        'Activo',
        p_nueva_tasa,
        v_saldo,
        v_saldo,
        ROUND(v_cuota, 2),
        CURDATE(),
        DATE_ADD(CURDATE(), INTERVAL p_nuevo_plazo MONTH)
    );

    COMMIT;

END //

DELIMITER ;

-- ============================================================
-- Validación
-- ============================================================

-- comprobamos que se creo el procedimiento
SHOW PROCEDURE STATUS
WHERE Db = 'fincore_sa'
  AND Name = 'sp_refinanciar_prestamo';
  
  -- visualizamos prestamos disponibles para el ejercicio (activos o vencidos)
  SELECT
    id_prestamo,
    id_cliente,
    id_producto,
    saldo_pendiente,
    plazo_meses,
    tasa_aplicada,
    estado
FROM prestamos
WHERE estado IN ('Activo', 'Vencido')
ORDER BY id_prestamo;
-- guardamos datos del prestamo seleccionado
SELECT
    id_prestamo,
    id_cliente,
    id_producto,
    saldo_pendiente,
    plazo_meses,
    tasa_aplicada,
    estado
FROM prestamos
WHERE id_prestamo = 14;

-- realizamos cambio
CALL sp_refinanciar_prestamo(14, 24, 20.00);

-- confirmamos que se refinancio
select *
from prestamos
where id_prestamo = 14;

-- comprobamos que se agrego el nuevo prestamo
SELECT
    id_prestamo,
    id_cliente,
    id_producto,
    plazo_meses,
    tasa_aplicada,
    monto_otorgado,
    saldo_pendiente,
    cuota_mensual,
    fecha_otorgamiento,
    fecha_vencimiento,
    estado
FROM prestamos
WHERE id_cliente = 13
ORDER BY id_prestamo;

-- ============================================================
-- Parte 5 — Análisis avanzado de cartera
-- ============================================================

-- Aging de cartera: agrupa todos los préstamos activos y vencidos por su tramo de mora, mostrando cantidad, saldo en riesgo y porcentaje del total.

SELECT
    fn_clasificar_mora(dias_mora) AS tramo_mora,
    COUNT(*) AS cantidad_prestamos,
    SUM(saldo_pendiente) AS saldo_en_riesgo,
    ROUND(
        SUM(saldo_pendiente) /
        (SELECT SUM(saldo_pendiente)
         FROM prestamos
         WHERE estado IN ('Activo', 'Vencido')) * 100,
        2
    ) AS porcentaje_total
FROM prestamos
WHERE estado IN ('Activo', 'Vencido')
GROUP BY fn_clasificar_mora(dias_mora)
ORDER BY MIN(dias_mora);

-- ============================================================
-- Top 5 de exposición crediticia: identifica los 5 clientes con mayor saldo pendiente total y compara cada uno contra el promedio de la cartera.
-- ============================================================

SELECT
    c.id_cliente,
    c.nombre AS cliente,
    SUM(p.saldo_pendiente) AS saldo_total,
    ROUND(
        SUM(p.saldo_pendiente) -
        (
            SELECT AVG(saldo_cliente)
            FROM (
                SELECT SUM(saldo_pendiente) AS saldo_cliente
                FROM prestamos
                WHERE estado IN ('Activo', 'Vencido')
                GROUP BY id_cliente
            ) AS promedio
        ), 2
    ) AS diferencia_promedio
FROM clientes c
JOIN prestamos p
    ON c.id_cliente = p.id_cliente
WHERE p.estado IN ('Activo', 'Vencido')
GROUP BY c.id_cliente, c.nombre
ORDER BY saldo_total DESC
LIMIT 5;

-- ============================================================
-- Historial de pagos completo: cruza las tablas pagos, prestamos, clientes y productos_credito para mostrar el detalle de los últimos 20 pagos registrados.
-- ============================================================

SELECT
    pg.id_pago,
    pg.fecha_pago,
    pg.monto_pagado,
    pg.tipo_pago,
    pg.canal,
    p.id_prestamo,
    c.nombre AS cliente,
    pc.nombre AS producto
FROM pagos pg
JOIN prestamos p
    ON pg.id_prestamo = p.id_prestamo
JOIN clientes c
    ON p.id_cliente = c.id_cliente
JOIN productos_credito pc
    ON p.id_producto = pc.id_producto
ORDER BY
    pg.fecha_pago DESC,
    pg.id_pago DESC
LIMIT 20;

-- ============================================================
-- Reporte ejecutivo: usando la vista vw_estado_cartera, agrupa la cartera por segmento y categoría de riesgo, mostrando tasa promedio, créditos vencidos y porcentaje de cartera en riesgo.
-- ============================================================

SELECT
    segmento,
    categoria_riesgo,
    ROUND(AVG(tasa_aplicada), 2) AS tasa_promedio,
    SUM(CASE 
            WHEN dias_mora > 0 THEN 1 
            ELSE 0 
        END) AS creditos_vencidos,
    ROUND(
        SUM(CASE 
                WHEN dias_mora > 0 THEN saldo_pendiente 
                ELSE 0 
            END)
        / SUM(saldo_pendiente) * 100,
        2
    ) AS porcentaje_cartera_en_riesgo
FROM vw_estado_cartera
GROUP BY
    segmento,
    categoria_riesgo
ORDER BY
    segmento,
    categoria_riesgo;

-- ============================================================
--    Parte 6 — Optimización
-- ============================================================

-- Analiza y mejora el rendimiento de tus consultas:
-- Usa EXPLAIN sobre la consulta de historial de pagos antes de crear ningún índice. Anota qué tabla aparece como conductora, cuántas filas estima (rows) y qué tablas tienen key=NULL.
-- ============================================================

EXPLAIN FORMAT=TRADITIONAL
SELECT
    pg.id_pago,
    pg.fecha_pago,
    pg.monto_pagado,
    pg.tipo_pago,
    pg.canal,
    p.id_prestamo,
    c.nombre AS cliente,
    pc.nombre AS producto
FROM pagos pg
JOIN prestamos p
    ON pg.id_prestamo = p.id_prestamo
JOIN clientes c
    ON p.id_cliente = c.id_cliente
JOIN productos_credito pc
    ON p.id_producto = pc.id_producto
ORDER BY
    pg.fecha_pago DESC,
    pg.id_pago DESC
LIMIT 20;

-- ============================================================
-- Crea los índices que consideres necesarios sobre las columnas con mayor uso en filtros y JOIN.
-- ============================================================

CREATE INDEX idx_pagos_fecha_id
ON pagos (fecha_pago DESC, id_pago DESC);

CREATE INDEX idx_pagos_prestamo_fecha
ON pagos (id_prestamo, fecha_pago);

CREATE INDEX idx_prestamos_cliente_producto
ON prestamos (id_cliente, id_producto);

EXPLAIN FORMAT=TRADITIONAL
SELECT
    pg.id_pago,
    pg.fecha_pago,
    pg.monto_pagado,
    pg.tipo_pago,
    pg.canal,
    p.id_prestamo,
    c.nombre AS cliente,
    pc.nombre AS producto
FROM pagos pg
JOIN prestamos p
    ON pg.id_prestamo = p.id_prestamo
JOIN clientes c
    ON p.id_cliente = c.id_cliente
JOIN productos_credito pc
    ON p.id_producto = pc.id_producto
ORDER BY
    pg.fecha_pago DESC,
    pg.id_pago DESC
LIMIT 20;

-- Después de crear los índices, la tabla conductora continúa siendo pagos, con una estimación de 49 filas. La columna key continúa en NULL para pagos y se mantiene Using filesort. Las tablas prestamos, productos_credito y clientes continúan utilizando sus claves primarias mediante eq_ref, estimando 1 fila por búsqueda.

-- ============================================================
