# Proyecto Análisis de cartera de créditos en SQL

## 📌 Descripción del proyecto

Proyecto en SQL desarrollado sobre una base de datos financiera ficticia de **FinCore S.A.**, orientada a la gestión de clientes, productos crediticios, préstamos, pagos, morosidad y riesgo de cartera.

El proyecto busca aplicar SQL no solo para realizar consultas, sino también para construir soluciones orientadas a la **gestión financiera, control de cartera, auditoría, automatización de procesos y análisis ejecutivo**.

Se trabajó con **MySQL 8.0+**, utilizando funciones, vistas, triggers, procedimientos almacenados, transacciones, CTEs, consultas analíticas e índices para optimización.

---

# 🎯 Objetivos del proyecto

Los principales objetivos fueron:

- Analizar el estado de la cartera de créditos.
- Clasificar los préstamos según sus días de mora.
- Construir vistas para facilitar el análisis de cartera y clientes.
- Implementar auditoría automática mediante triggers.
- Automatizar el registro de pagos.
- Generar resúmenes mensuales de gestión.
- Automatizar procesos de refinanciación.
- Analizar el aging de la cartera.
- Identificar los clientes con mayor exposición crediticia.
- Analizar el historial de pagos.
- Construir un reporte ejecutivo por segmento y categoría de riesgo.
- Optimizar consultas mediante índices.
- Validar el funcionamiento de las soluciones mediante pruebas.

 # Tecnologías y herramientas utilizadas

- MySQL 8.0+
- SQL
- Funciones
- Vistas
- Triggers
- Procedimientos almacenados
- Transacciones
- Índices
- EXPLAIN
- `information_schema`

---

---

# Base de datos

La base de datos utilizada se denomina:

`fincore_sa`

El proyecto trabaja principalmente con las siguientes tablas:

- `clientes`
- `productos_credito`
- `prestamos`
- `pagos`
- `auditoria_prestamos`
- `resumen_mensual`

---

# Modelo de información

La estructura representa una operación básica de una institución financiera:

~~~text
CLIENTES
   │
   ├───────────────┐
   │               │
   ▼               ▼
PRÉSTAMOS     INFORMACIÓN
   │           DEL CLIENTE
   │
   ├──────────────► PRODUCTOS_CREDITO
   │
   └──────────────► PAGOS
                     │
                     ▼
              HISTORIAL DE PAGOS

PRÉSTAMOS
   │
   └──────────────► AUDITORIA_PRESTAMOS

PRÉSTAMOS + PAGOS
   │
   └──────────────► RESUMEN_MENSUAL
~~~

---

# Principales entidades

## Clientes

Contiene información de los clientes, incluyendo:

- Identificación.
- Nombre.
- Email.
- Teléfono.
- Ciudad.
- Segmento.
- Categoría de riesgo.
- Fecha de alta.

Las categorías de riesgo consideradas son:

- A — Excelente
- B — Bueno
- C — Regular
- D — Alto riesgo

---

## Productos de crédito

Contiene la información de los productos ofrecidos por FinCore.

Entre ellos:

- Crédito Personal Flex
- Crédito Personal Plus
- Crédito Empresarial Básico
- Crédito Empresarial Pro
- Crédito Hipotecario
- Crédito Automotriz

Cada producto contiene información como:

- Tipo de crédito.
- Tasa anual.
- Plazo mínimo.
- Plazo máximo.
- Monto mínimo.
- Monto máximo.

---

## Préstamos

La tabla `prestamos` contiene la información de cada operación crediticia.

Entre sus principales atributos:

- Cliente.
- Producto.
- Monto otorgado.
- Tasa aplicada.
- Plazo.
- Fecha de otorgamiento.
- Fecha de vencimiento.
- Cuota mensual.
- Saldo pendiente.
- Estado.
- Días de mora.

Los estados utilizados incluyen:

- Activo
- Vencido
- Cancelado
- Refinanciado

---

## Pagos

La tabla `pagos` registra los pagos realizados sobre los préstamos.

Incluye:

- Préstamo asociado.
- Fecha de pago.
- Monto pagado.
- Tipo de pago.
- Canal utilizado.

---

# Archivos del proyecto

El proyecto está compuesto principalmente por:

~~~text
FinCore/
│
├── datos_fincore.sql
├── Solucion_FinCore_Kellys_3..sql
~~~

### `datos_fincore.sql`

Contiene la estructura y los datos iniciales de la base de datos.

### `Solucion_FinCore_Kellys_3..sql`

Contiene la solución desarrollada para el proyecto:

- Función de clasificación de mora.
- Vistas.
- Trigger de auditoría.
- Procedimientos almacenados.
- Consultas analíticas.
- Optimización mediante índices.
- Pruebas de ejecución.

---

## Desarrollo del proyecto

# Función de clasificación de mora

Se creó la función:

`fn_clasificar_mora`

Su objetivo es clasificar los préstamos según la cantidad de días de mora.

La clasificación utilizada es:

| Días de mora | Categoría |
|---:|---|
| 0 o menos | Al día |
| 1–30 | Mora Temprana |
| 31–60 | Mora Media |
| 61–90 | Mora Grave |
| +90 | Mora Crítica |

La función implementada fue:

~~~sql
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
END
~~~

### Ejemplo

Un préstamo con:

`180 días de mora`

es clasificado como:

`Mora Crítica (+90d)`

---

# Vista de estado de cartera

Se creó la vista:

`vw_estado_cartera`

Su objetivo es consolidar información relevante de cada préstamo.

La vista integra información proveniente de:

- Clientes.
- Préstamos.
- Productos de crédito.

Además, calcula:

- Porcentaje de saldo restante.
- Días de mora.
- Categoría de mora.

La consulta utiliza la función creada anteriormente:

~~~sql
fn_clasificar_mora(pt.dias_mora) AS categoria_mora
~~~

Esto permite disponer de una visión más completa del estado de la cartera.

---

# Vista de resumen por cliente

Se creó la vista:

`vw_resumen_clientes`

Esta vista consolida la información crediticia de cada cliente.

Los principales indicadores son:

- Total de préstamos.
- Monto total otorgado.
- Saldo pendiente consolidado.
- Máximo de días de mora.
- Existencia de mora activa.

Ejemplo de cálculo:

~~~sql
COUNT(pt.id_prestamo) AS total_prestamos,
COALESCE(SUM(pt.monto_otorgado), 0) AS total_monto_otorgado,
COALESCE(SUM(pt.saldo_pendiente), 0) AS total_saldo_pendiente_consolidado,
COALESCE(MAX(pt.dias_mora), 0) AS max_dias_mora
~~~

Esta vista permite analizar la exposición crediticia desde la perspectiva del cliente.

---

# Trigger de auditoría

Se creó el trigger:

`trg_auditoria_estado`

Este trigger permite registrar automáticamente modificaciones realizadas sobre los préstamos.

Se auditan específicamente cambios en:

- Estado del préstamo.
- Días de mora.

Cuando uno de estos campos cambia, se registra:

- ID del préstamo.
- Campo modificado.
- Valor anterior.
- Valor nuevo.
- Fecha del cambio.

Ejemplo:

~~~sql
IF NOT (OLD.estado <=> NEW.estado) THEN

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
~~~

Esto permite mantener una trazabilidad de modificaciones relevantes sobre la cartera.

---

# Procedimiento para registrar pagos

Se creó el procedimiento:

`sp_registrar_pago`

Su objetivo es automatizar el registro de pagos y actualizar el saldo pendiente del préstamo.

El procedimiento incorpora distintas validaciones.

## Validaciones implementadas

### Existencia del préstamo

Se verifica que el préstamo exista.

~~~sql
IF v_existe = 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'El préstamo no existe.';
END IF;
~~~

### Estado del préstamo

Solo se permiten pagos para préstamos:

- Activos.
- Vencidos.

No se permiten pagos sobre préstamos:

- Cancelados.
- Refinanciados.

### Validación del monto

El pago debe ser mayor que cero.

Además, no puede superar el saldo pendiente.

~~~sql
IF p_monto <= 0 THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'El monto del pago debe ser mayor que cero.';
END IF;
~~~

~~~sql
IF p_monto > v_saldo THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'El monto del pago supera el saldo pendiente.';
END IF;
~~~

---

# Uso de transacciones

El procedimiento de registro de pagos utiliza una transacción:

~~~sql
START TRANSACTION;
~~~

Luego:

1. Valida el préstamo.
2. Bloquea el registro.
3. Valida el monto.
4. Actualiza el saldo.
5. Registra el pago.
6. Cancela el préstamo si el saldo llega a cero.
7. Confirma la operación.

Finalmente:

~~~sql
COMMIT;
~~~

En caso de error se utiliza:

~~~sql
ROLLBACK;
~~~

Esto permite mantener la consistencia de la información.

---

# Procedimiento para generar resumen mensual

Se creó:

`sp_generar_resumen_mensual`

Este procedimiento genera indicadores mensuales relacionados con la actividad crediticia.

Los indicadores calculados son:

- Total de préstamos.
- Monto total otorgado.
- Total de pagos recibidos.
- Préstamos vencidos.
- Tasa de morosidad.

---

## Tasa de morosidad

La tasa se calcula mediante:

~~~sql
(v_prestamos_vencidos / v_total_prestamos) * 100
~~~

El resultado se redondea a dos decimales.

La información se almacena en:

`resumen_mensual`

Además, se utilizó:

~~~sql
ON DUPLICATE KEY UPDATE
~~~

para actualizar el resumen si el período ya existe.

Esto evita duplicar información para un mismo año y mes.

---

# Procedimiento de refinanciación

Se creó:

`sp_refinanciar_prestamo`

Este procedimiento automatiza el proceso de refinanciación de un préstamo.

El flujo es:

1. Verificar que el préstamo exista.
2. Obtener y bloquear la información.
3. Validar el estado actual.
4. Validar el nuevo plazo.
5. Validar la nueva tasa.
6. Calcular la nueva cuota.
7. Cambiar el préstamo original a `Refinanciado`.
8. Crear un nuevo préstamo utilizando el saldo pendiente.
9. Confirmar la transacción.

---

#  Aging de cartera

Se desarrolló una consulta para construir un **aging de cartera**.

El análisis agrupa los préstamos activos y vencidos según el tramo de mora.

Los indicadores obtenidos son:

- Tramo de mora.
- Cantidad de préstamos.
- Saldo en riesgo.
- Porcentaje sobre el total de la cartera.

La consulta utiliza:

~~~sql
fn_clasificar_mora(dias_mora)
~~~

Esto permite identificar rápidamente dónde se concentra el riesgo de mora.

---

# Top 5 de exposición crediticia

Se desarrolló una consulta para identificar los cinco clientes con mayor saldo pendiente.

Para ello se utilizaron:

- CTE `exposicion`.
- CTE `promedio`.
- `CROSS JOIN`.
- Agregaciones.
- `ORDER BY`.
- `LIMIT`.

La consulta permite comparar:

- Saldo total del cliente.
- Promedio de exposición de la cartera.
- Diferencia respecto al promedio.

Ejemplo:

~~~sql
WITH exposicion AS (
    SELECT
        c.id_cliente,
        c.nombre AS cliente,
        SUM(p.saldo_pendiente) AS saldo_total
    FROM clientes c
    JOIN prestamos p
        ON c.id_cliente = p.id_cliente
    GROUP BY
        c.id_cliente,
        c.nombre
)
~~~

Este análisis permite identificar clientes con una exposición crediticia significativamente superior al promedio.

---

# Historial de pagos

Se creó una consulta para obtener los últimos 20 pagos registrados.

La consulta relaciona:

- Pagos.
- Préstamos.
- Clientes.
- Productos de crédito.

Se muestran:

- ID del pago.
- Fecha.
- Monto.
- Tipo de pago.
- Canal.
- ID del préstamo.
- Cliente.
- Producto.

El resultado se ordena desde el pago más reciente.

~~~sql
ORDER BY
    pg.fecha_pago DESC,
    pg.id_pago DESC
LIMIT 20;
~~~

---

# Reporte ejecutivo

Se desarrolló un reporte orientado a gestión agrupando la cartera por:

- Segmento.
- Categoría de riesgo.

Los principales indicadores son:

- Tasa promedio.
- Cantidad de créditos vencidos.
- Porcentaje de cartera en riesgo.

La cartera en riesgo se calcula considerando el saldo pendiente asociado a préstamos con días de mora superiores a cero.

~~~sql
SUM(
    CASE
        WHEN dias_mora > 0 THEN saldo_pendiente
        ELSE 0
    END
)
~~~

Esto permite obtener una visión ejecutiva de la cartera según el perfil de cliente.

---

# Optimización de consultas

Como parte del proyecto también se trabajó en optimización mediante índices.

Se utilizó:

~~~sql
EXPLAIN FORMAT=TRADITIONAL
~~~

para analizar el plan de ejecución de la consulta del historial de pagos.

---

# Índices creados

Se incorporaron índices adicionales sobre columnas utilizadas en:

- Filtros.
- JOIN.
- Ordenamiento.

Los índices creados fueron:

~~~sql
CREATE INDEX idx_pagos_fecha_id
ON pagos (fecha_pago DESC, id_pago DESC);
~~~

~~~sql
CREATE INDEX idx_pagos_prestamo_fecha
ON pagos (id_prestamo, fecha_pago);
~~~

~~~sql
CREATE INDEX idx_prestamos_cliente_producto
ON prestamos (id_cliente, id_producto);
~~~

Estos índices buscan mejorar el acceso a la información utilizada frecuentemente por las consultas.

---

# Procedimiento auxiliar para crear índices

MySQL no soporta directamente:

`CREATE INDEX IF NOT EXISTS`

Por este motivo se creó un procedimiento auxiliar:

`sp_crear_indice`

Este procedimiento consulta `information_schema.statistics` para verificar si el índice ya existe antes de crearlo.

La lógica principal es:

~~~sql
IF NOT EXISTS (
    SELECT 1
    FROM information_schema.statistics
    WHERE table_schema = DATABASE()
      AND table_name = p_tabla
      AND index_name = p_indice
)
~~~

Esto permite ejecutar nuevamente el script sin generar errores por índices duplicados.

---

# Comparación mediante EXPLAIN

Se ejecutó `EXPLAIN` antes y después de la creación de índices para evaluar el plan de ejecución.

Consulta analizada:

~~~sql
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
~~~

El objetivo fue evaluar el comportamiento de la consulta y aplicar índices sobre las columnas relevantes.

---

# Pruebas de funcionamiento

El proyecto incluye pruebas para validar las principales funcionalidades desarrolladas.

---

## Prueba del trigger

Se modificó temporalmente el estado y los días de mora de un préstamo.

~~~sql
UPDATE prestamos
SET estado = 'Vencido',
    dias_mora = 45
WHERE id_prestamo = 2;
~~~

Luego se restauraron los valores originales.

Esto permitió comprobar que el trigger registrara los cambios realizados en:

`auditoria_prestamos`

---

# Prueba del resumen mensual

Se ejecutó el procedimiento para distintos períodos:

~~~sql
CALL sp_generar_resumen_mensual(2023, 1);

CALL sp_generar_resumen_mensual(2023, 2);

CALL sp_generar_resumen_mensual(2023, 3);
~~~

Posteriormente se verificó la información:

~~~sql
SELECT *
FROM resumen_mensual
ORDER BY anio, mes;
~~~

Esto permite comprobar la generación de múltiples períodos de información.

---

# Verificación de resultados

También se incorporó una consulta para verificar la cantidad de registros generados en las tablas de auditoría y resumen:

~~~sql
SELECT
    'auditoria_prestamos' AS tabla,
    COUNT(*) AS registros
FROM auditoria_prestamos

UNION ALL

SELECT
    'resumen_mensual',
    COUNT(*)
FROM resumen_mensual;
~~~

---

# Pruebas manuales opcionales

El proyecto también incluye ejemplos de ejecución manual para probar los procedimientos.

### Registrar un pago

~~~sql
CALL sp_registrar_pago(
    2,
    500.00,
    'Cuota',
    'App'
);
~~~

### Refinanciar un préstamo

~~~sql
CALL sp_refinanciar_prestamo(
    14,
    24,
    20.00
);
~~~

Estas pruebas permiten validar el comportamiento de los procedimientos sobre datos reales de la base.


---

# Enfoque de negocio

Además del desarrollo técnico, el proyecto busca resolver problemas habituales dentro de una operación financiera.

### Gestión de cartera

Permite conocer:

- Cuánto dinero se encuentra pendiente.
- Qué préstamos presentan mora.
- Qué clientes tienen mayor exposición.
- Cómo se distribuye la cartera por riesgo.

### Gestión de riesgo

La clasificación de mora permite identificar rápidamente:

- Clientes al día.
- Mora temprana.
- Mora media.
- Mora grave.
- Mora crítica.

### Control y auditoría

El trigger permite mantener trazabilidad sobre modificaciones importantes realizadas en los préstamos.

### Gestión financiera

El resumen mensual permite consolidar:

- Créditos otorgados.
- Monto otorgado.
- Pagos recibidos.
- Créditos vencidos.
- Tasa de morosidad.

### Automatización

Los procedimientos almacenados permiten convertir procesos manuales en operaciones controladas y reutilizables.

---

# Principales aprendizajes

Este proyecto permitió profundizar en el uso de SQL para resolver problemas que van más allá de consultas simples.

Las principales habilidades desarrolladas fueron:

- Diseño de consultas complejas.
- Manejo de múltiples tablas relacionadas.
- Uso de CTEs.
- Creación de funciones.
- Creación de vistas.
- Automatización mediante procedimientos almacenados.
- Implementación de triggers.
- Manejo de transacciones.
- Control de errores mediante `SIGNAL`.
- Bloqueo de registros mediante `FOR UPDATE`.
- Análisis de cartera.
- Análisis de morosidad.
- Análisis de exposición crediticia.
- Construcción de reportes ejecutivos.
- Optimización mediante índices.
- Interpretación de planes de ejecución con `EXPLAIN`.

---

# Recomendaciones

Como siguientes etapas del proyecto se podrían incorporar:

- Dashboard de cartera en Power BI.
- Indicadores de cartera en tiempo real.
- Evolución mensual de la morosidad.
- Score de riesgo.
- Análisis de concentración de cartera.
- Alertas automáticas para préstamos en mora.
- Análisis de rentabilidad por producto.
- Integración con Python para análisis predictivo.
- Modelo de predicción de incumplimiento.
- Automatización del reporte ejecutivo.
- Conexión SQL + Power BI.

---

# Conclusión

El proyecto **FinCore S.A.** permitió desarrollar una solución integral utilizando MySQL para la gestión y análisis de una cartera de créditos.

La solución combina:

**SQL + automatización + auditoría + análisis financiero + optimización**

A través de funciones, vistas, triggers, procedimientos almacenados, consultas analíticas y optimización mediante índices, se construyó una solución capaz de apoyar distintos procesos de gestión financiera y análisis de cartera.
