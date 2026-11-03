use DB_Customer360_Lab;

/**
Paso 1
Pregunta de negocio: ¿Dónde guardamos los métodos de pago y los datos sensibles (PII) de cada cliente?
R= En dos tablas aparte, ligadas a Tabla_Clientes por cliente_id. Así los datos PII quedan separados del resto del modelo y se les puede aplicar enmascaramiento (DDM) y CHECK constraints directamente.
**/
create table Tabla_MetodosPago (
    metodo_pago_id int primary key identity(1,1),
    cliente_id int foreign key references Tabla_Clientes(cliente_id),
    tipo_metodo varchar(30) not null,
    numero_tarjeta varchar(16) masked with (function = 'partial(0,"XXXX-XXXX-XXXX-",4)') not null,
    constraint ck_tarjeta_longitud check (len(numero_tarjeta) = 16)
);

create table Tabla_PerfilesSensibles (
    perfil_id int primary key identity(1,1),
    cliente_id int foreign key references Tabla_Clientes(cliente_id),
    correo_personal varchar(100) masked with (function = 'email()') not null,
    telefono varchar(20) masked with (function = 'partial(0,"XXX-XXX-",4)') null,
    salario_mensual decimal(10,2) masked with (function = 'default()') not null,
    constraint ck_correo_formato check (correo_personal like '%_@_%._%'),
    constraint ck_salario_minimo check (salario_mensual >= 9000)
);

insert into Tabla_MetodosPago (cliente_id, tipo_metodo, numero_tarjeta) values
(1, 'Tarjeta de Crédito', '4111111111111111'),
(2, 'Tarjeta de Débito', '5500000000000004'),
(4, 'Tarjeta de Crédito', '3400000000000009');

insert into Tabla_PerfilesSensibles (cliente_id, correo_personal, telefono, salario_mensual) values
(1, 'carlos.mendoza@email.com', '4771234567', 28000.00),
(2, 'ana.torres@email.com', '3331234567', 35000.00),
(3, 'roberto.gomez@email.com', '4421234567', 15000.00),
(4, 'maria.f@email.com', '4421239876', 22000.00);

/**
Paso 2
Pregunta de negocio: ¿Cómo evitamos que se capturen correos con formato inválido en la tabla de clientes?
R= Con un CHECK constraint sobre email. Los 4 clientes actuales cumplen el patrón, por lo que se puede agregar sin error.
**/
alter table Tabla_Clientes
add constraint ck_clientes_email_formato check (email like '%_@_%._%');

/**
Paso 3
Pregunta de negocio: ¿Qué ve un analista junior cuando consulta los datos sensibles?
R= Solo valores enmascarados: el correo como aXXX@XXXX.com, el teléfono con XXX-XXX- y los últimos 4 dígitos, el salario en 0 y la tarjeta con XXXX-XXXX-XXXX- y los últimos 4 dígitos. Para comprobarlo se crea un usuario sin permiso UNMASK y se consulta como ese usuario.
**/
if user_id('analista_jr') is null
    create user analista_jr without login;

grant select on Tabla_PerfilesSensibles to analista_jr;
grant select on Tabla_MetodosPago to analista_jr;

execute as user = 'analista_jr';

select
    perfil_id,
    cliente_id,
    correo_personal,
    telefono,
    salario_mensual
from Tabla_PerfilesSensibles;

select
    metodo_pago_id,
    cliente_id,
    tipo_metodo,
    numero_tarjeta
from Tabla_MetodosPago;

revert;
