/*
BASES DE DATOS APLICADAS

-FECHA DE ENTREGA: 14-06-2024

-GRUPO: 12

-INTEGRANTES:
Massa, Valentin				DNI 44510875
Hamilton, Juan Pablo		DNI 44259410
Cesti, Facundo				DNI 44670178
Rodriguez Salvo, Nicolas	DNI 43443079


Deberá instalar el DMBS y documentar el proceso. No incluya capturas de pantalla. Detalle las
configuraciones aplicadas (ubicación de archivos, memoria asignada, seguridad, puertos, etc.) en un
documento como el que le entregaría al DBA.

Cree la base de datos, entidades y relaciones. Incluya restricciones y claves. Deberá entregar un
archivo .sql con el script completo de creación (debe funcionar si se lo ejecuta “tal cual” es entregado).
Incluya comentarios para indicar qué hace cada módulo de código.

Genere store procedures para manejar la inserción, modificado, borrado (si corresponde, también
debe decidir si determinadas entidades solo admitirán borrado lógico) de cada tabla.

Genere esquemas para organizar de forma lógica los componentes del sistema y aplique esto en la
creación de objetos. NO use el esquema “dbo”.
*/


create database FINAL_GRUPO_12
go
use FINAL_GRUPO_12
go
--creamos la base de datos

--Vamos a crear 7 esquemas para ordenar de manera logica la base de datos:

--Paciente_info : Paciente, Cobertura, Usuario, Domicilio.
--Medico_info : Medico, Especialidad, 
--Sede_Info: Dias_Sede, Sede_Atencion
--LOG_INFO : registro de log
--Turnos_info : Reserva_Turnos , Estado, Tipo_turno
--Estudio_Info: Estudio
--Prestador_Info: Prestador


/*
REFERENCIA:
Key de tabla propia id_"Name" (primera letra mayuscula)
key de otra tabla Id"Name"(I y la primera letra en Mayus)
*/

set nocount on

go
--creamos los esquemas


---Paciente_info
if not exists(select 1 from sys.schemas where name = 'Paciente_info')
		exec ('create schema Paciente_info')
else
	print'schema ya creado'

go
--Medico_Info
if not exists(select * from sys.schemas where name = 'Medico_info')
		exec ('create schema Medico_info')
else
	print'schema ya creado'

go
--Sede_Info
if not exists(select 1 from sys.schemas where name = 'Sede_info')
		exec ('create schema Sede_info')
else
	print'schema ya creado'


go
--Log_Info
if not exists(select * from sys.schemas where name = 'Log_Info')
		exec ('create schema Log_Info')
else
	print'schema ya creado'

go
--Turnos_Info
if not exists(select * from sys.schemas where name = 'Turnos_info')
		exec ('create schema Turnos_info')
else
	print'schema ya creado'

go

--Estudio_Info
if not exists(select * from sys.schemas where name = 'Estudio_info')
		exec ('create schema Estudio_info')
else
	print'schema ya creado'

go

--Prestador_Info
if not exists(select * from sys.schemas where name = 'Prestador_info')
		exec ('create schema Prestador_info')
else
	print'schema ya creado'

go

--select * from sys.schemas 
--schemas creados!


--Empezamos a crear las tablas
--------------------------------------------
--(Schema Prestador_Info)
--------------------------------------------
--tabla prestador
if OBJECT_ID(N'[Prestador_info].[Prestador]', N'U') is null
	create table Prestador_info.Prestador
	(
	id_Prestador smallint identity(1,1) primary key,
	Nombre varchar (20),
	estado bit default 1
	)
else
		print 'ya existe'
go

---tabla cobertura que presta el prestador

if OBJECT_ID(N'[Prestador_info].[PrestadorCobertura]', N'U') is null
	create table Prestador_info.PrestadorCobertura
	(
	id_PrestadorCobertura int identity(1,1) primary key,
	Plan_Prestador varchar (40) not null,
	idPrestador smallint not null,
	estado bit default 1,
		constraint Fk_PrestadorCobertura foreign key(idPrestador) 
			references Prestador_info.Prestador(id_Prestador)
	)
else
		print 'ya existe'
go

--------------------------------------------
--schema Estudio_Info
-------------------------------------------

--tabla estudio
if OBJECT_ID(N'[Estudio_info].[Estudio]', N'U') is null
    create table Estudio_info.Estudio
	(
		id_Estudio_Guardado int identity(1,1) primary key, 
		Fecha date not null,
		Area varchar(40) not null,
		Nombre_Estudio varchar(100) not null,
		Autorizado bit not null,
		Ruta_Doc varchar(100),
		Ruta_Imagen_Resultado varchar(100),
		Porcentaje_Cobertura tinyint not null ,
		costo int not null,
		idPrestadorCobertura int,
			constraint CK_Estudio_PorcCob check (Porcentaje_Cobertura >= 0 and Porcentaje_Cobertura <= 100),
			constraint CK_Estudio_Costo check (costo >= 0),
		constraint Fk_PrestadorCobertura foreign key(idPrestadorCobertura) 
			references Prestador_info.PrestadorCobertura(id_PrestadorCobertura)
	)
else
	print 'ya existe'
go
-----------------------------------------
--(schema Paciente_Info)
-----------------------------------------
--tabla paciente 
if OBJECT_ID(N'[Paciente_info].[Paciente]', N'U') is null
	create table Paciente_info.Paciente
	(
		id_Historia_Clinica int identity(1,1) primary key,
		Nombre varchar(30) not null,
		Apellido varchar(30) not null,
		Apellido_Materno varchar(30),
		FecNac date not null,
		Tipo_Documento varchar(20) not null,
		DNI int UNIQUE not null,
		Sexo_Biologico char(1) not null,
		Genero varchar(20),
		Nacionalidad varchar (30) not null,
		Ruta_Imagen varchar(100),
		Mail varchar(50) not null,
		Telefono_Celular varchar(20) not null,
		Telefono_Contacto_Alternativo varchar(20),
		Telefono_Laboral varchar(20),
		Fecha_Registro smalldatetime default getdate(),
		Fecha_Actualizacion smalldatetime null,
		Usuario_Actualizacion smalldatetime null,
		estado bit default 1,

		CONSTRAINT CK_DNI check (DNI>0),
		CONSTRAINT CK_SEXO_BIOLOGICO check (Sexo_Biologico like 'F' or Sexo_Biologico like 'M')
	)
else
	print 'ya existe'

go

--tabla usuario

if OBJECT_ID(N'[Paciente_info].[Usuario]', N'U') is null
	create table Paciente_info.Usuario 
	(
		id_Usuario int IDENTITY(1,1) primary key,
		IdUsuario int not null unique,
		contrasenia varchar(20) not null,
		fechaCreacion smalldatetime default getdate() not null
	)
else
	print 'ya existe'
go

--tabla cobertura de paciente

if OBJECT_ID(N'[Paciente_info].[Cobertura]', N'U') is null
		create table Paciente_info.Cobertura
		(
			id_Cobertura int identity(1,1) primary key,
			imagenCredencial varchar(255), 
			nroSocio int, 
			fechaRegistro date, 
			idHistoriaClinica int unique,
			idPrestadorCobertura int,
				constraint Fk_CoberturaIdClinica foreign key(idHistoriaClinica) 
					references Paciente_info.Paciente(id_Historia_Clinica),
				constraint Fk_Prestador foreign key(idPrestadorCobertura) 
					references Prestador_info.PrestadorCobertura(id_PrestadorCobertura),
				constraint Check_NroSocio check (NroSocio>0)
		)
else
	print 'ya existe'

go

--tabla Estudios de paciente

if OBJECT_ID(N'[Paciente_info].[EstudiosPaciente]', N'U') is null
    create table Paciente_info.EstudiosPaciente
	(
		id int identity(1,1) primary key,
		idEstudio int,
		idHistoriaClinica int,
		constraint Fk_HistoriaClinicaPAcienteEstudio foreign key(idHistoriaClinica) 
				references Paciente_info.Paciente(id_Historia_Clinica),
		constraint Fk_IdEstudioRelacionado foreign key(idEstudio) 
				references Estudio_info.Estudio(id_Estudio_Guardado)		 
	)
else
	print 'ya existe'
go

--tabla domicilio

if OBJECT_ID(N'[Paciente_info].[Domicilio]', N'U') is null
    create table Paciente_info.Domicilio(
    id_Domicilio int identity(1,1) primary key, 
    calle varchar(50), 
    numero int, 
    piso tinyint, 
    departamento char(3), 
    codigoPostal char(4), 
    pais varchar(20), 
    provincia varchar(25), 
    localidad varchar(50),
    idHistoriaClinica int unique,
	constraint Fk_HistoriaClinicaDomicilio foreign key(idHistoriaClinica) 
		references Paciente_info.Paciente(id_Historia_Clinica),
	constraint check_numero check(numero >0),
	constraint check_piso check(piso>0)
	)
else
	print 'ya existe'

---------------------------------
--tablas medico_Info
---------------------------------
--tabla Especialidad
if OBJECT_ID(N'[Medico_info].[Especialidad]', N'U') is null
    create table Medico_info.Especialidad
	(
		id_Especialidad smallint identity(1,1) primary key,
		Nombre_Especialidad varchar(100) not null,
	)
else
	print 'ya existe'
go

--tabla Medico
if OBJECT_ID(N'[Medico_info].[Medico]', N'U') is null
    create table Medico_info.Medico
	(
		id_Medico smallint identity(1,1) primary key,
		Nombre_Medico varchar(30) not null,
		Apellido_Medico varchar(30) not null,
		Estado bit default 1,
		Nro_Matricula int unique not null,
		idEspecialidad smallint,
			constraint FK_Medico_Especialidad foreign key(idEspecialidad) 
				references Medico_info.Especialidad(id_Especialidad),
			constraint Medico_Check_Nro_Matricula check (Nro_Matricula>0)
	)
else
	print 'ya existe'
go
----------------------------------
--Tablas Sede_Info
----------------------------------

--tabla Sede de atencion

if OBJECT_ID(N'[Sede_info].[SedeAtencion]', N'U') is null
    create table Sede_info.SedeAtencion
	(
		id_Sede smallint identity(1,1) primary key,
		Nombre_Sede varchar(100) not null,
		Direccion_Sede varchar(100) not null
	)
else
	print 'ya existe'
go


--tabla DiasxSede

if OBJECT_ID(N'[Sede_info].[DiasxSede]', N'U') is null
    create table Sede_info.DiasxSede
	(
		id_DiasxSede smallint identity(1,1),
		idSede smallint,
		idMedico smallint, 
		horaInicio time(0),
		Fecha date,
		constraint FK_Sede_Medico foreign key (idMedico)
			references Medico_info.Medico(id_Medico),
		constraint FK_Sede_Sede foreign key (idSede)
			references Sede_info.SedeAtencion(id_Sede)
	)
else
	print 'ya existe'

go

---------------------------------
--Tablas Turno_Info
---------------------------------

--Tipo_Turno

if OBJECT_ID(N'[Turnos_Info].[TipoTurno]', N'U') is null
    create table Turnos_Info.TipoTurno
    (
		id_TipoTurno bit primary key, 
		nombreTipoTurno char(10),
		constraint CK_nombreTipoTurno 
			check (nombreTipoTurno in ('PRESENCIAL', 'VIRTUAL'))
    )
else
    print 'ya existe'
go

--Estado Turno: Corroborar nombre de estado todo mayus

if OBJECT_ID(N'[Turnos_Info].[EstadoTurno]', N'U') is null
    create table Turnos_Info.EstadoTurno
    (
		id_EstadoTurno tinyint IDENTITY(1,1) primary key, 
		nombreEstado char(10),
		constraint CK_nombreEstado 
			check (nombreEstado in ('ATENDIDO', 'AUSENTE', 'CANCELADO', 'RESERVADO')),
		Constraint CK_CantTurnos check(id_EstadoTurno < 5)
    )
else
    print 'ya existe'
go

--RESERVA TURNO

if OBJECT_ID(N'[Turnos_info].[ReservaTurno]', N'U') is null
    create table Turnos_info.ReservaTurno
	(
		id_Turno bigint identity(1,1) primary key,
		Fecha_Turno date not null,
		Hora_Turno_Inicio time(0) not null,
		Hora_Turno_Fin time(0) not null,
		IdHistoriaClinica int not null,
		idMedico smallint not null,
		idEspecialidad smallint not null,
		idSede smallint not null,
		idEstado_Turno tinyint, 
		idTipo_Turno bit not null
		constraint FK_Turno_Medico foreign key (IdMedico)
			references Medico_info.Medico(id_Medico),
		constraint FK_Turno_Especialidad foreign key (IdEspecialidad)
			references Medico_info.Especialidad(id_Especialidad),
		constraint FK_Turno_Sede foreign key (IdSede)
			references Sede_info.SedeAtencion(id_Sede),
		constraint FK_Turno_Estado foreign key (IdEstado_Turno)
			references Turnos_Info.EstadoTurno(id_EstadoTurno),
		constraint FK_Turno_Tipo foreign key (IdTipo_Turno)
			references Turnos_Info.TipoTurno(id_TipoTurno),
		constraint FK_Turno_Paciente foreign key (IdHistoriaClinica)
			references Paciente_info.Paciente(id_Historia_Clinica)
	)
else
	print 'ya existe'
go

--TipoTurno: Checkear los estados al insertar en el sp

---------------------------
--Schema Log
---------------------------
--tabla Log
if OBJECT_ID(N'[Log_Info].[LogReg]', N'U') is null
	create table Log_Info.LogReg(
		id_Log int identity(1,1) primary key,
		FyH smalldatetime DEFAULT CURRENT_TIMESTAMP,
		texto varchar(50),
		modulo varchar(10),
		usuario varchar(30)
    )
else
    print 'ya existe'
go

-----------------------------------------------
--Insercion de datos basicos
----------------------------------------------

insert into Turnos_info.EstadoTurno(nombreEstado)
values
('ATENDIDO'), 
('AUSENTE'), 
('CANCELADO'),
('RESERVADO')


go

insert into Turnos_info.TipoTurno(id_TipoTurno, nombreTipoTurno) values
(0, 'PRESENCIAL'),
(1, 'VIRTUAL')

go
-------------------
/*
Tenemos los siguientes roles

• Paciente
• Medico
• Personal Administrativo
• Personal Técnico clínico
• Administrador General

*/

/*
Vamos a crear un SP para el log, el cual sera invocado en todos los sp usados.
Este contiene:
		id_Log int identity(1,1) primary key,
		FyH smalldatetime DEFAULT CURRENT_TIMESTAMP,
		texto varchar(50),
		modulo varchar(10),
		usuario varchar(30)
texto: alguna aclaracion, sino va null.
modulo(en la tabla que se realizo la insercion)
usuario, si en algun momento generamos un servidor y creamos logins, con  SUSER_SNAME podemos obtener el nombre de usuario 
que esta realizando esa modificacion. tiendo un log que indica que usuario hizo la accion
*/

create OR ALTER procedure Log_Info.InsertarAlLog
	@modulo varchar(10) , 
	@texto varchar(50),
	@usuario varchar(30)
as
BEGIN
	if @modulo = ''
		begin
			set @modulo = 'N/A'
	end
	if @modulo = ''
		begin
			set @texto = 'N/A'
	end
	if @modulo = ''
		begin
			set @usuario = 'N/A'
	end
	insert into Log_Info.LogReg(texto, modulo, usuario)
		values(
			rtrim(upper(@texto)), 
			rtrim(upper(@modulo)), 
			@usuario)
END;
go


/* Creamos los Store Procedures correspondientes al esquema Paciente_info
------------------------------------------------------
					Paciente_info
------------------------------------------------------
*/

------------------------------------------------------
--STORED  PROCEDURE DAR DE ALTA PACIENTE
------------------------------------------------------
create or alter procedure Paciente_info.DarAltaPAciente
		@Nombre varchar(30),
		@Apellido varchar(30),
		@Apellido_Materno varchar(30),
		@FecNac date,
		@Tipo_Documento varchar(20),
		@DNI int,
		@Sexo_Biologico char(9),
		@Genero varchar(20),
		@Nacionalidad varchar (30),
		@Ruta_Imagen varchar(100),
		@Mail varchar(50),
		@Telefono_Celular varchar(20),
		@Telefono_Contacto_Alternativo varchar(20),
		@Telefono_Laboral varchar(20)
as begin
	declare @AltaPaciente bit
	declare @sexoBio_new char(1)
	declare @contra varchar(20)
	
	--comprobamos sexo
	if UPPER(RTRIM(@Sexo_Biologico)) = 'MASCULINO'
		begin
			SET @sexoBio_new = 'M'
		end
	else if UPPER(RTRIM(@Sexo_Biologico)) = 'FEMENINO'
		begin
			set @sexoBio_new = 'F'
		end
	else
		begin
			print 'NO EXISTE EL SEXO BIOLOGICO INDICADO'
			RETURN;
		end
	--creamos contrasenia 
	set @contra = @DNI

	insert into Paciente_info.Paciente(Nombre,Apellido, Apellido_Materno, FecNac, DNI, Tipo_Documento, 
		Sexo_Biologico,Genero, Nacionalidad,Ruta_Imagen,
			Mail,Telefono_Celular,Telefono_Contacto_Alternativo, Telefono_Laboral) 
			values(
				upper(rtrim(@Nombre)),
				upper(rtrim(@Apellido)), 
				rtrim(@Apellido_Materno),
				@FecNac,
				@DNI,
				upper(rtrim(@Tipo_Documento)), 
				@sexoBio_new, 
				upper(rtrim(@Genero)), 
				UPPER(rtrim(@Nacionalidad)), 
				RTRIM(@Ruta_Imagen), 
				RTRIM(@Mail), 
				rtrim(@Telefono_Celular),
				rtrim(@Telefono_Contacto_Alternativo), 
				rtrim(@Telefono_Laboral)
			)
	insert into Paciente_info.Usuario (IdUsuario, contrasenia)
	values(
		@DNI, 
		@contra
		)
	exec Log_Info.InsertarAlLog '', 'SE AGREGO UN USUARIO',''

end;

go
------------------------------------------------------
--STORED  PROCEDURE DAR DE BAJA AL PACIENTE 
------------------------------------------------------
create or alter procedure Paciente_info.DarBajaPaciente

@dni int

as begin

declare @idHistClinica  int
declare @idestadoturno tinyint

set @idHistClinica = (select id_Historia_Clinica from Paciente_info.Paciente where DNI = @dni)
set @idestadoturno =  (select id_EstadoTurno from Turnos_info.EstadoTurno where nombreEstado = 'RESERVADO')

if @idHistClinica is null
	begin
		print'no existe este paciente'
		return;
	end;
if not exists (select 1 from Turnos_info.ReservaTurno where IdHistoriaClinica = @idHistClinica and idEstado_Turno = @idestadoturno)
	begin
		update Paciente_info.Paciente
		set estado = 0
		where id_Historia_Clinica = @idHistClinica
		exec Log_Info.InsertarAlLog '', 'SE DIO DE BAJA UN PACIENTE',''
	end;
else
	begin
		print 'EL USUARIO TIENE TURNOS PENDIENTES, BAJA CANCELADA'
		RETURN;
	end;
end;

go



------------------------------------------------------
--STORED  PROCEDURE actualizar AL PACIENTE 
------------------------------------------------------
create or alter procedure Paciente_info.ActualizarPaciente
		@DNI int,
		@Genero varchar(20),
		@Mail varchar(50),
		@Telefono_Celular varchar(10),
		@Telefono_Contacto_Alternativo varchar(10),
		@Telefono_Laboral varchar(10)
as begin
	declare @fecha smalldatetime
	set @fecha = convert(smalldatetime, GETDATE())

    IF EXISTS(SELECT 1 FROM Paciente_info.Paciente WHERE DNI = @DNI)
	BEGIN
		update  Paciente_info.Paciente
		set 
			Genero = upper(rtrim(@Genero)),
			Mail = RTRIM(@Mail),
			Telefono_Celular = rtrim(@Telefono_Celular) ,
			Telefono_Contacto_Alternativo = rtrim(@Telefono_Contacto_Alternativo), 
			Telefono_Laboral = rtrim(@Telefono_Laboral), 
			Fecha_Actualizacion = @fecha
		where DNI = @DNI
		exec Log_Info.InsertarAlLog '', 'SE ACTUALIZO INFORMACION DE PACIENTE',''
	END;
end;

go

------------------------------------------------------
--STORED  PROCEDURE  actualizar AL USUARIO
------------------------------------------------------

create or alter procedure Paciente_info.ActualizarUsuario
@DNI int,
@contrasenia varchar(20)
AS BEGIN

IF EXISTS(SELECT 1 FROM Paciente_info.Usuario as b where @DNI = b.IdUsuario)
	update Paciente_info.Usuario 
		set contrasenia = RTRIM(@contrasenia)
		where @DNI = contrasenia
ELSE
	BEGIN
		PRINT'NO EXISTE ESTE USUARIO'
		RETURN;
	END;
	update Paciente_info.Paciente
		set Usuario_Actualizacion = cast(GETDATE() as smalldatetime)
	where DNI = @DNI
	exec Log_Info.InsertarAlLog '', 'SE ACTUALIZO INFORMACION DE UN USUARIO',''
END;

GO

------------------------------------------------------
--STORED  PROCEDURE AGREGAR DOMICILIO
------------------------------------------------------
CREATE OR ALTER PROCEDURE Paciente_Info.InsertarDomicilio
    @calle VARCHAR(50),
    @numero INT,
    @piso INT,
    @departamento CHAR(3),
    @codigoPostal CHAR(4),
    @pais VARCHAR(20),
    @provincia VARCHAR(25),
    @localidad VARCHAR(50),
    @DNI INT
AS
BEGIN
	DECLARE @idHistoriaClinica int
	set @idHistoriaClinica = (SELECT id_Historia_Clinica FROM Paciente_info.Paciente WHERE DNI = @DNI)

	IF EXISTS(SELECT 1 FROM Paciente_info.Paciente WHERE @idHistoriaClinica = id_Historia_Clinica)
	BEGIN
		INSERT INTO Paciente_info.Domicilio(calle, numero, piso, departamento, 
			codigoPostal, pais, provincia, localidad, idHistoriaClinica)
		VALUES(
			lower(rtrim(@calle)), 
			@numero, 
			@piso, 
			rtrim(upper(@departamento)), 
			rtrim(upper(@codigoPostal)), 
			rtrim(upper(@pais)), 
			rtrim(upper(@provincia)),
			rtrim(upper(@localidad)), 
			@idHistoriaClinica
		)
		exec Log_Info.InsertarAlLog '', 'SE AGREGO EL DOMICILIO DE UN PACIENTE',''
		END;
	else
		BEGIN
			print 'NO EXISTE PACIENTE CON ESE DNI'
			RETURN;
		END;
END;

GO
------------------------------------------------------
--STORED  PROCEDURE MODIFICAR DOMICILIO
------------------------------------------------------
CREATE OR ALTER PROCEDURE Paciente_info.ModificarDomicilio
    @nuevaCalle VARCHAR(50),
    @nuevoNumero INT,
    @nuevoPiso INT,
    @nuevoDepartamento CHAR(3),
    @nuevoCodigoPostal CHAR(4),
    @nuevoPais VARCHAR(20),
    @nuevaProvincia VARCHAR(25),
    @nuevaLocalidad VARCHAR(50),
	@DNIBUSQUEDA INT
AS
BEGIN
	DECLARE @HISTCLINICID INT
	SET @HISTCLINICID = (SELECT id_Historia_Clinica FROM Paciente_info.Paciente WHERE DNI = @DNIBUSQUEDA)

	IF @HISTCLINICID IS NOT NULL
		BEGIN
			UPDATE Paciente_info.Domicilio
			SET calle = lower(RTRIM(@nuevaCalle)),
				numero = @nuevoNumero,
				piso = @nuevoPiso,
				departamento =RTRIM(@nuevoDepartamento),
				codigoPostal = RTRIM(@nuevoCodigoPostal),
				pais = UPPER(RTRIM(@nuevoPais)),
				provincia =  UPPER(RTRIM(@nuevaProvincia)),
				localidad = UPPER(RTRIM(@nuevaLocalidad))
			WHERE idHistoriaClinica = @HISTCLINICID;
			exec Log_Info.InsertarAlLog '', 'SE MODIFICO EL DOMICILIO DE UN PACIENTE',''
		END;
	ELSE
		BEGIN
			PRINT 'NO EXISTE PACIENTE CON ESE DNI'
			RETURN;
		END;
END;

GO
------------------------------------------------------
--STORED  PROCEDURE AGREGAR COBERTURA A PACIENTE
------------------------------------------------------
CREATE or alter PROCEDURE Paciente_info.InsertarCobertura
    @imagenCredencial varchar(255),
    @nroSocio INT,
    @fechaRegistro DATE,
    @DNI_PACIENTE INT,
	@idCoberturaPrestador INT
AS
BEGIN
	DECLARE @HISTCLINICID INT
	SET @HISTCLINICID = (SELECT id_Historia_Clinica FROM Paciente_info.Paciente WHERE DNI = @DNI_PACIENTE)
	
	IF @HISTCLINICID IS NULL
		BEGIN
			print'PACIENTE NO REGISTRADO'
			RETURN;
		END;

	IF NOT EXISTS (SELECT 1 FROM Prestador_info.PrestadorCobertura where id_PrestadorCobertura = @idCoberturaPrestador and estado <> 0)
		BEGIN
			print 'COBERTURA NO REGISTRADA'
			RETURN;
		END;

	IF	NOT EXISTS (SELECT 1 FROM Paciente_info.Cobertura 
			WHERE nroSocio = @nroSocio and @idCoberturaPrestador = @idCoberturaPrestador)

	BEGIN
			INSERT INTO Paciente_info.Cobertura (imagenCredencial, nroSocio, fechaRegistro, 
				idHistoriaClinica, idPrestadorCobertura)
			VALUES ( RTRIM(@imagenCredencial), @nroSocio, CAST(GETDATE() AS date), @HISTCLINICID, @idCoberturaPrestador);
			exec Log_Info.InsertarAlLog '', 'SE AGREGO UNA COBERTURA A UN PACIENTE',''
		END;
	ELSE
		BEGIN
			PRINT 'ERROR, USUARIO YA DADO DE ALTA CON ESA COBERTURA'
			RETURN;
		END;
END;

GO
------------------------------------------------------
--STORED  PROCEDURE ELIMINAR COBERTURA
------------------------------------------------------
CREATE OR ALTER PROCEDURE Paciente_Info.EliminarCobertura
    @DNI INT
AS
BEGIN
	DECLARE @HISTCLINICID INT
	SET @HISTCLINICID = (SELECT id_Historia_Clinica FROM Paciente_info.Paciente WHERE DNI = @DNI)

	IF @HISTCLINICID IS NOT NULL AND EXISTS (SELECT 1 FROM Paciente_info.Cobertura where idHistoriaClinica = @HISTCLINICID)
		begin
			delete Paciente_Info.Cobertura
			WHERE idHistoriaClinica = @HISTCLINICID
			exec Log_Info.InsertarAlLog '', 'SE ELIMINO UNA COBERTURA DE UN PACIENTE',''
		end;
	ELSE
		BEGIN
			PRINT 'NO EXISTE PACIENTE CON ESE DNI o NO SE DIO DE ALTA UNA COBERTURA PARA ESE PACIENTE'
			RETURN;
		END;
END;
GO

/* Creamos los Store Procedures correspondientes al esquema Turnos_info
------------------------------------------------------
					Turnos_info
------------------------------------------------------
*/
------------------------------------------------------
--STORED  PROCEDURE AGREGAR RESERVA
------------------------------------------------------
CREATE OR ALTER PROCEDURE Turnos_info.InsertarReserva
@FechaTurno date,
@Hora_Inicio time(0),
@dnipaciente int, 
@matriculaMedico int,
@idSede smallint,
@Tipo_Turno varchar(10)
AS BEGIN

	declare @idEspecialidad smallint
	declare @idHistClinica int
	declare @idMedico smallint
	declare @idTipoTurno bit
	declare @tiempoTurno tinyint
	declare @idestadoturno tinyint
	set @tiempoTurno = 15

	set @idMedico = (select id_Medico from Medico_info.Medico where Nro_Matricula = @matriculaMedico)
	set @idEspecialidad = (select idEspecialidad from Medico_info.Medico where Nro_Matricula = @matriculaMedico)
	set @idHistClinica = (select id_Historia_Clinica from Paciente_info.Paciente where DNI = @dnipaciente)
	set @idTipoTurno = (select id_TipoTurno from Turnos_info.TipoTurno where nombreTipoTurno = rtrim(upper(@Tipo_Turno)))
	set @idestadoturno = (select id_EstadoTurno from Turnos_info.EstadoTurno where nombreEstado = 'RESERVADO')

	if @idHistClinica Is null or @idMedico is null  or @Tipo_Turno is null OR @idEspecialidad is null
		BEGIN
			print 'ERROR , DATOS INVALIDOS'
			return;
		END;
	IF EXISTS(SELECT 1 FROM Turnos_info.ReservaTurno A WHERE 
			A.Fecha_Turno = @FechaTurno AND
			A.Hora_Turno_Inicio = @Hora_Inicio AND
			A.idEspecialidad = @idEspecialidad AND
			A.IdHistoriaClinica = @idHistClinica AND
			A.idMedico = @idMedico AND
			A.idSede = @idSede and
			A.idEstado_Turno = @idestadoturno
			)
		BEGIN
			PRINT 'ESTE TURNO YA ESTA RESERVADO, POR FAVOR SELECCIONE OTRO'
			RETURN;
		END;
	IF EXISTS(SELECT 1 FROM Sede_info.DiasxSede A WHERE
		A.Fecha = @FechaTurno AND
		A.horaInicio = @Hora_Inicio and
		A.idMedico = @idMedico AND
		A.idSede = @idSede
		)
		BEGIN
			INSERT INTO Turnos_info.ReservaTurno(Fecha_Turno,Hora_Turno_Inicio,
				Hora_Turno_Fin,IdHistoriaClinica,idMedico,idEspecialidad,idSede,idTipo_Turno, idEstado_Turno)
			values(
			@FechaTurno,
			@Hora_Inicio,
			cast(DATEADD(minute,@tiempoTurno, cast(@Hora_Inicio as smalldatetime)) as time(0)),
			@idHistClinica,
			@idMedico,
			@idEspecialidad,
			@idSede,
			@idTipoTurno,
			@idestadoturno
			)
			exec Log_Info.InsertarAlLog '', 'SE AGREGO UN NUEVO TURNO',''
		END;
	ELSE
		BEGIN
			PRINT'NO ESTA DADO DE ALTA EL TURNO A RESERVAR'
			RETURN;
		END;
END;
GO
------------------------------------------------------
--STORED  PROCEDURE MODIFICAR RESERVA
------------------------------------------------------

CREATE OR ALTER PROCEDURE Turnos_info.ModificarReserva
@DNI INT,
@FECHA_TURNO DATE,
@HORA_TURNO TIME(0),
@ESTADO CHAR(10)
AS BEGIN
	declare @idHistClinica int
	declare @idEstado tinyint

	set @idHistClinica = (select id_Historia_Clinica from Paciente_info.Paciente where DNI = @DNI)
	set @idEstado = (select id_EstadoTurno from Turnos_info.EstadoTurno where nombreEstado = UPPER(rtrim(@ESTADO)))

	if @idHistClinica is null
		begin
			print 'PACIENTE NO ENCONTRADO'
			RETURN;
		end;

	IF @idEstado IS NULL
		begin
			print 'estado NO ENCONTRADO'
			RETURN;
		end;

	if exists (select 1 from Turnos_info.ReservaTurno as a where 
		a.IdHistoriaClinica = @idHistClinica and
		a.Fecha_Turno = @FECHA_TURNO and
		a.Hora_Turno_Inicio = @HORA_TURNO
	)
	BEGIN
		update Turnos_info.ReservaTurno
		set 
		idEstado_Turno = @idEstado
		WHERE 
			IdHistoriaClinica = @idHistClinica and
			Fecha_Turno = @FECHA_TURNO and
			Hora_Turno_Inicio = @HORA_TURNO
		exec Log_Info.InsertarAlLog '', 'SE MODIFICO EL ESTADO DEL TURNO',''
	END;
	ELSE
		BEGIN
			PRINT 'TURNO NO ENCONTRADO'
			RETURN;
		END;
END;

go

/* Creamos los Store Procedures correspondientes al esquema Sede_info
------------------------------------------------------
					Sede_info
------------------------------------------------------
*/

---------------------------------------------------------
--Store Procedure Insertar Sede			
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Sede_info.InsertarSede
    @nombreSede varchar(100),
    @direccionSede varchar(100)
AS
BEGIN
    INSERT INTO Sede_info.SedeAtencion (Nombre_Sede, Direccion_Sede)
    VALUES (
		upper(rtrim(@nombreSede)), 
		lower(rtrim(@direccionSede))
		);
	exec Log_Info.InsertarAlLog '', 'insertar sede insercion',''
END;

go

---------------------------------------------------------
--VERIFICACION DE FECHA, SP UTILIZADO EN INSERTARDIASXSEDE
---------------------------------------------------------
create or alter procedure Sede_info.VerificarFechaDelDia
@fecha date,
@tiempoTurno tinyint,
@hora_Inicio time(0),
@hora_fin time(0),
@resultado bit output

as
begin
	declare @ERR bit
	declare @TODO_OK bit
	declare @fechafull datetime
	set @TODO_OK =1
	set @ERR = 0
	
	if DATEPART(MINUTE, @hora_Inicio) % @tiempoTurno <> 0
		begin
			print 'ERROR EN FECHA, LOS TURNOS TIENEN QUE EMPEZAR POR MINUTO 00, 15....'
			set @resultado = @ERR
			return;
		end
	if DATEPART(MINUTE, @hora_fin) % @tiempoTurno <> 0
		begin
			print 'ERROR EN FECHA, LOS TURNOS TIENEN QUE TERMINAR POR MINUTO 00, 15....'
			set @resultado = @ERR
			return;
		end
	--verificamos que no se quiera registrar una fecha anterior a la indicada

	set @fechafull = DATETIMEFROMPARTS(
										year(@fecha),
										month(@fecha),
										day(@fecha),
										datepart(hour,(@hora_Inicio)), 
										datepart(minute,(@hora_Inicio)),
										datepart(SECOND,(@hora_Inicio)),
										datepart(MILLISECOND,(@hora_Inicio))
										)
	if @fechafull < cast(GETDATE() as datetime)
		begin
			print 'NO SE PUEDE DAR DE ALTA TURNOS DE FECHAS/HORAS QUE YA PASARON'
			set @resultado = @ERR
			RETURN;
		END
	set @resultado = @TODO_OK

	---Verificamos que el horario es correcto.
end;

go
----------------------------------------------------------
--STORED PROCEDURE INSERTAR DIAS X SEDE
-- exec Sede_info.InsertarDiasxSede matricula, hora_inicio, hora_fin, fecha, idSede
----------------------------------------------------------
create or alter procedure Sede_info.InsertarDiasxSede
@matricula int,
@hora_Inicio time(0),
@hora_fin time(0),
@fecha date,
@idSede smallint
as begin
	declare @tiempoTurno tinyint
	declare @idmedico smallint
	declare @resultadoFinal as bit
	declare @ERR bit
	declare @TODO_OK bit
	set @ERR = 0
	set @tiempoTurno = 15

	--sp para verificar las fechas
	exec Sede_info.VerificarFechaDelDia @fecha, @tiempoTurno, @hora_Inicio, @hora_fin, @resultado = @resultadoFinal output
	if  @resultadoFinal = @ERR	
		return;
	set @idmedico = (select a.id_Medico from Medico_info.Medico as a where @matricula = a.Nro_Matricula and a.Estado <>0)
	if @idmedico is NULL 
		begin
			print 'NO SE ENCONTRO MEDICO CON ESA MATRICULA'
			return;
		end
	-- se asigna a idmedico su respectivo valor

	while @hora_Inicio < @hora_fin
	begin
		if not exists(select 1 from Sede_info.DiasxSede as b 
			where 
			@idSede = b.idSede and 
			@idmedico = b.idMedico and 
			@fecha = b.Fecha and 
			@hora_Inicio = b.horaInicio
			)
				begin
					insert into Sede_info.DiasxSede(idSede, idMedico, horaInicio, Fecha) 
					values(
						@idSede, 
						@idmedico, 
						@hora_Inicio, 
						@fecha
					)
					set @hora_Inicio = DATEADD(minute, @tiempoTurno, @hora_Inicio)
					exec Log_Info.InsertarAlLog '', 'TURNO DE MEDICO AGREGADO A UNA SEDE',''
				end
			else 
				BEGIN
					print 'ERROR, YA SE HA REGISTRADO ESTE RANGO DE TURNOS EN ESOS HORARIOS'
					return;
				END
	end
end;

go

/* Creamos los Store Procedures correspondientes al esquema Medico_info
------------------------------------------------------
					Medico_info
------------------------------------------------------
*/

---------------------------------------------------------
--Store Procedure Insertar Medico	
---------------------------------------------------------

CREATE or alter PROCEDURE Medico_info.InsertarMedico
    @nombre varchar(30),
    @apellido varchar(30),
    @nroMatricula int,
    @idEspecialidad smallint
AS
BEGIN
	declare @activo bit
	set @activo = 1
    IF NOT EXISTS (SELECT 1 FROM Medico_info.Medico WHERE Nro_Matricula = @nroMatricula)
    BEGIN
        INSERT INTO Medico_info.Medico (Nombre_Medico, Apellido_Medico, Estado, Nro_Matricula, idEspecialidad)
        VALUES(
				upper(rtrim(@nombre)), 
				upper(rtrim(@apellido)), 
				@activo, 
				@nroMatricula, 
				@idEspecialidad);
		exec Log_Info.InsertarAlLog '', 'MEDICO INSERCION',''
    END
    ELSE
    BEGIN
        PRINT 'Ya existe un médico con el número de matrícula especificado.'
    END
END;

go

---------------------------------------------------------
/*			Store Procedure Eliminar Medico			*/
---------------------------------------------------------

CREATE or alter PROCEDURE Medico_info.EliminarMedico
    @nroMatricula int
AS
BEGIN
	declare @idmedico smallint
	declare @idEstado tinyint
	set @idmedico = (select id_Medico from Medico_info.Medico where Nro_Matricula = @nroMatricula )
	set @idEstado = (select id_EstadoTurno from Turnos_info.EstadoTurno where nombreEstado ='RESERVADO' )
	if @idmedico is null
	BEGIN
		Print 'no existe el medico seleccionado'
		return;
	END;

    IF not EXISTS(SELECT 1 FROM Turnos_info.ReservaTurno WHERE idMedico = @idmedico and idEstado_Turno = @idEstado)
		BEGIN
			update Medico_info.Medico
			set Estado = 0
			where Nro_Matricula = @nroMatricula
			exec Log_Info.InsertarAlLog '', ' MEDICO se elimino logicamente',''
		END
	else
	begin
		print 'EL MEDICO TIENE TURNOS ASIGNADOS'
		return;
	end;
END;

go

---------------------------------------------------------
/*			Store Procedure Actualizar Medico			*/
---------------------------------------------------------

CREATE or alter PROCEDURE Medico_info.ActualizarMedico
    @nroMatricula int,
	@nuevoNombre varchar(30),
    @nuevoApellido varchar(30),
	@nuevoIdEspecialidad smallint,
	@nuevoestado bit
AS
BEGIN
	IF EXISTS(SELECT 1 FROM Medico_info.Medico WHERE Nro_Matricula = @nroMatricula)
	BEGIN
		UPDATE Medico_info.Medico
		SET Nombre_Medico = upper(rtrim(@nuevoNombre)),
			Apellido_Medico =upper(rtrim(@nuevoApellido)),
			idEspecialidad = @nuevoIdEspecialidad,
			Estado = @nuevoestado
		WHERE Nro_Matricula = @nroMatricula;
		exec Log_Info.InsertarAlLog '', ' MEDICO se actualizo',''
	END
END;

go

---------------------------------------------------------
/*		Store Procedure Insertar Especialidad			*/
---------------------------------------------------------

CREATE OR ALTER PROCEDURE Medico_info.InsertarEspecialidad
    @nombreEspecialidad varchar(100)
AS
BEGIN

	INSERT INTO Medico_info.Especialidad (Nombre_Especialidad)
	VALUES (
		upper(rtrim(@nombreEspecialidad))
		);
	exec Log_Info.InsertarAlLog '', 'ESPECIALIDAD MEDICO INSERCION',''
END;

go

/* Creamos los Store Procedures correspondientes al esquema Prestador_info
------------------------------------------------------
					Prestador_info
------------------------------------------------------
*/

------------------------------------------------------
--STORED  PROCEDURE AGREGAR PRESTADOR
------------------------------------------------------

CREATE OR ALTER PROCEDURE Prestador_info.AltaPrestador
@nombre varchar(20)
AS BEGIN	
	IF NOT EXISTS(SELECT 1 FROM Prestador_info.Prestador AS B 
			WHERE B.Nombre = UPPER(RTRIM(@nombre))
		)
		INSERT INTO Prestador_info.Prestador(Nombre) 
		VALUES(
			UPPER(RTRIM(@nombre))
			)
		exec Log_Info.InsertarAlLog '', 'SE AGREGO INFORMACION DE UN PRESTADOR',''
END;
go

------------------------------------------------------
--STORED  PROCEDURE AGREGAR COBERTURA DE PRESTADOR
------------------------------------------------------

CREATE OR ALTER PROCEDURE Prestador_info.AltaCoberturaPrestador
@idPrestador smallint,
@PlanCobertura varchar(50)
AS BEGIN	

	IF NOT EXISTS(SELECT 1 FROM Prestador_info.Prestador AS B where B.id_Prestador = @idPrestador)
	BEGIN
		print 'PRESTADOR NO REGISTRADO'
		RETURN;
	END;

	IF not EXISTS (SELECT 1 FROM Prestador_info.PrestadorCobertura where Plan_Prestador = UPPER(RTRIM(@PlanCobertura)))
		BEGIN
			INSERT INTO Prestador_info.PrestadorCobertura(idPrestador, Plan_Prestador) 
			VALUES(
				@idPrestador,
				UPPER(RTRIM(@PlanCobertura))
				)
			exec Log_Info.InsertarAlLog '', 'SE AGREGO INFORMACION DE UN PRESTADOR',''
		END;
	ELSE	
		BEGIN
			PRINT'COBERTURA DE PRESTADOR YA AGREGADA'
			RETURN;
		END;
END;
go

------------------------------------------------------
--ELIMINAR PRESTADOR
------------------------------------------------------
CREATE OR ALTER PROCEDURE Prestador_Info.EliminarPrestador
@idprestador smallint

AS BEGIN
	declare @idEstado tinyint
	set @idEstado = (select id_EstadoTurno from Turnos_info.EstadoTurno where nombreEstado = 'RESERVADO')
	

	if exists (select 1 from Prestador_info.Prestador where id_Prestador = @idprestador and estado <> 0)
		begin
			update Prestador_info.Prestador
				set estado = 0
				where id_Prestador = @idprestador;

		with CoberturaPacientes as
				(
					select idHistoriaClinica from Paciente_info.Cobertura as A inner join Prestador_info.PrestadorCobertura as B
						on A.idPrestadorCobertura = B.id_PrestadorCobertura where B.idPrestador = @idprestador
				)
		update Turnos_info.ReservaTurno
		set idEstado_Turno = (select id_EstadoTurno from Turnos_info.EstadoTurno where nombreEstado = 'CANCELADO')
		where id_Turno in  
			(
				select N.id_Turno from CoberturaPacientes as H inner join Turnos_info.ReservaTurno as N
					on H.idHistoriaClinica = N.IdHistoriaClinica
			)


		exec Log_Info.InsertarAlLog '', 'SE ELIMINO UN PRESTADOR Y TODOS SUS TURNOS RELACIONADOS',''
	END;
	else
		BEGIN
			print 'NO EXISTE ESTE PRESTADOR'
			RETURN;
		END;
END;
go


/* Creamos los Store Procedures correspondientes al esquema Estudio_info
------------------------------------------------------
					Estudio_info
------------------------------------------------------
*/

------------------------------------------------------
--STORED  PROCEDURE AGREGAR ESTUDIO GENERAL
------------------------------------------------------

CREATE OR ALTER PROCEDURE Estudio_info.AgregarEstudio
@DNIPACIENTE int,

@ID_ESTUDIO CHAR(25),
@fechaEstudio date,
@Area varchar(40),
@NombreEstudio varchar(100),
@AUTORIZADO BIT,
@RutaDoc varchar(100),
@RutaImagen varchar(100),
@PorcentajeCobertura tinyint,
@costo int

AS BEGIN
	DECLARE @HISTCLINICID INT
	SET @HISTCLINICID = (SELECT id_Historia_Clinica FROM Paciente_info.Paciente WHERE DNI = @DNIPACIENTE)

	IF @HISTCLINICID IS NOT NULL 
		BEGIN
			INSERT INTO Estudio_info.Estudio(Fecha, Area, Nombre_Estudio, Autorizado, 
					Ruta_Doc, Ruta_Imagen_Resultado, Porcentaje_Cobertura, costo)
			VALUES( 
				@fechaEstudio,
				upper(rtrim(@Area)),
				UPPER(RTRIM(@NombreEstudio)),
				@AUTORIZADO,
				RTRIM(@RutaDoc),
				RTRIM(@RutaImagen),
				@PorcentajeCobertura,
				@costo
			)
			exec Log_Info.InsertarAlLog '', 'SE AGREGO UN ESTUDIO',''
	insert into Paciente_info.EstudiosPaciente (idEstudio, idHistoriaClinica)
	values(
		(select id_Estudio_Guardado from Estudio_info.Estudio where id_Estudio_Guardado = rtrim(@ID_ESTUDIO) ),
		@HISTCLINICID
		)
		END;
	ELSE
		PRINT 'SE ESTA QUERIENDO AGREGAR UN ESTUDIO A UN PACIENTE NO DADO DE ALTA'
		RETURN;
END;
go


-----------------------------------
--SETEAMOS ROLES
-----------------------------------
/*
• Paciente
	exec Paciente_info.ActualizarUsuario

• Medico
	exec Sede_info.InsertarDiasxSede
	exec Sede_info.VerificarFechaDelDia

• Personal Administrativo
	exec Paciente_info.ActualizarPaciente
	exec Paciente_info.DarAltaPAciente
	exec Paciente_info.DarBajaPaciente
	exec Paciente_info.EliminarCobertura
	exec Paciente_info.InsertarCobertura
	exec Paciente_info.InsertarDomicilio
	exec Paciente_info.ModificarDomicilio
	exec Turnos_info.InsertarReserva
	exec Turnos_info.ModificarReserva

• Personal Técnico clínico
	exec Estudio_info.AgregarEstudio

• Administrador General
	exec Prestador_info.AltaCoberturaPrestador
	exec Prestador_info.AltaPrestador
	exec Prestador_info.EliminarPrestador
	exec Medico_info.ActualizarMedico
	exec Medico_info.EliminarMedico
	exec Medico_info.InsertarEspecialidad
	exec Medico_info.InsertarMedico
	exec Sede_info.InsertarSede
*/

--Rol y permisos a Paciente
create role Paciente
go
grant execute on object ::Paciente_info.ActualizarUsuario to Paciente
go

--Rol y permisos a Medico
create role Medico
go
grant execute on object ::Sede_info.InsertarDiasxSede to Medico
go
grant execute on object ::Sede_info.VerificarFechaDelDia to Medico
go

--Rol y permisos a Personal Administrativo
create role Personal_Administrativo
go
grant execute on object ::Paciente_info.ActualizarPaciente to Personal_Administrativo
go
grant execute on object ::Paciente_info.DarAltaPAciente to Personal_Administrativo
go
grant execute on object ::Paciente_info.DarBajaPaciente to Personal_Administrativo
go
grant execute on object ::Paciente_info.EliminarCobertura to Personal_Administrativo
go
grant execute on object ::Paciente_info.InsertarCobertura to Personal_Administrativo
go
grant execute on object ::Paciente_info.InsertarDomicilio to Personal_Administrativo
go
grant execute on object ::Paciente_info.ModificarDomicilio to Personal_Administrativo
go
grant execute on object ::Turnos_info.InsertarReserva to Personal_Administrativo
go
grant execute on object ::Turnos_info.ModificarReserva to Personal_Administrativo
go

--Rol y permisos a Personal Tecnico Clinico
create role Personal_Tecnico_clínico
go
grant execute on object ::Estudio_info.AgregarEstudio to Personal_Tecnico_clínico
go

--Rol y permisos a Administrador General
create role Administrador_General
go
grant execute on object ::Prestador_info.AltaPrestador to Administrador_General
go
grant execute on object ::Prestador_info.AltaCoberturaPrestador to Administrador_General
go
grant execute on object ::Prestador_info.EliminarPrestador to Administrador_General
go
grant execute on object ::Medico_info.ActualizarMedico to Administrador_General
go
grant execute on object ::Medico_info.EliminarMedico to Administrador_General
go
grant execute on object ::Medico_info.InsertarEspecialidad to Administrador_General
go
grant execute on object ::Medico_info.InsertarMedico to Administrador_General
go
grant execute on object ::Sede_info.InsertarSede to Administrador_General
go

