/**
Vista: ventas por cliente con nombre y apellido unificados
Pregunta de negocio: ¿Cuáles son las ventas de cada cliente, mostrando su nombre completo en una sola columna?
R= Tabla_Clientes guarda nombre y apellido en una sola columna y con espacios sobrantes (ej. ' Carlos Mendoza '). La vista los limpia con ltrim y rtrim y se parte de clientes con left join para no perder a los que no tienen ventas.
**/
create view vw_consulta_ventas_cliente_nombre_apellido as
select
    c.cliente_id,
    ltrim(rtrim(c.nombre)) as nombre_apellido,
    v.venta_id,
    v.monto_venta,
    v.fecha_venta
from Tabla_Clientes c
left join Tabla_Ventas v
    on c.cliente_id = v.cliente_id;
