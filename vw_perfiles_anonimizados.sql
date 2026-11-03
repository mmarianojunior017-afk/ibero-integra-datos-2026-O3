/**
Vista anonimizada para analistas junior
Pregunta de negocio: ¿Cómo damos a los analistas junior el perfil de cada cliente sin exponer PII?
R= La vista no incluye correo, teléfono ni salario. Solo muestra el nombre limpio, la ciudad y la cantidad de ventas del cliente, y es lo único a lo que se le da acceso al analista junior.
**/
create view vw_perfiles_anonimizados as
select
    c.cliente_id,
    ltrim(rtrim(c.nombre)) as nombre_apellido,
    c.ciudad,
    v.total_ventas
from Tabla_Clientes c
left join (select
    cliente_id,
    count(venta_id) as total_ventas
from Tabla_Ventas
group by cliente_id) as v
    on c.cliente_id = v.cliente_id;
