/*
BASES DE DATOS APLICADAS

-FECHA DE ENTREGA: 14-06-2024

-GRUPO: 12

-INTEGRANTES:
Massa, Valentin				DNI 44510875
Hamilton, Juan Pablo		DNI 44259410
Cesti, Facundo				DNI 44670178
Rodriguez Salvo, Nicolas	DNI 43443079


Se proveen maestros de Médicos, Pacientes, Prestadores y Sedes en formato CSV. También se dispone
de un archivo JSON que contiene la parametrización del mecanismo de autorización según estudio y
obra social, además de porcentaje cubierto, etc. Ver archivo “Datasets para importar” en Miel.

*/


use FINAL_GRUPO_12
go

---Importar Archivos CSV
if not exists(select 1 from sys.schemas where name = 'ImportacionArchivoCSV')
		exec ('create schema ImportacionArchivoCSV')
else
	print'schema ya creado'
GO

--importar JSON
if not exists(select 1 from sys.schemas where name = 'ImportacionArchivoJSON')
		exec ('create schema ImportacionArchivoJSON')
else
	print'schema ya creado'

go
--GENERAR XML
if not exists(select 1 from sys.schemas where name = 'GenerarXML')
		exec ('create schema GenerarXML')
else
	print'schema ya creado'

go

-----------------------------------
--IMPORTAR MEDICO
----------------------------------

CREATE OR ALTER procedure ImportacionArchivoCSV.ImportarMedico_00
@path varchar(500)
AS BEGIN
	declare @Dinamico nvarchar(max)
	declare @idEstado bit

CREATE TABLE #TempMedico 
	(Nombre VARCHAR(30), Apellido varchar(30), especialidad varchar(100), ID_Matricula int primary key)

	set @Dinamico = 'BULK INSERT #TempMedico 
	FROM'''+ @path +'''WITH
	(
	FIELDTERMINATOR = '';'', 
	ROWTERMINATOR = ''\n'', 
	CODEPAGE = ''65001'', 
	FIRSTROW = 2
	)';
	exec sp_executesql @Dinamico;
	set @idEstado = 1

	insert into Medico_info.Especialidad(Nombre_Especialidad) 
		Select distinct especialidad from #TempMedico as b
		where not exists (select 1 from Medico_info.Especialidad as a where a.Nombre_Especialidad = b.especialidad )

	insert into Medico_info.Medico(Nombre_Medico, Apellido_Medico, idEspecialidad, Nro_Matricula, Estado)
		select 
		upper(rtrim(SUBSTRING(c.Nombre, CHARINDEX('.', c.Nombre) + 1, LEN(c.Nombre) - CHARINDEX('.', c.Nombre)))), 
		upper(c.Apellido), d.id_Especialidad, c.ID_Matricula, @idEstado
			from #TempMedico as c inner join Medico_info.Especialidad as d on Nombre_Especialidad = especialidad
				where not exists (select 1 from Medico_info.Medico as a where a.Nro_Matricula = c.ID_Matricula)
	drop table #TempMedico
	
END;

go
-----------------------------------
--IMPORTAR PRESTADOR
----------------------------------

CREATE OR ALTER procedure ImportacionArchivoCSV.ImportarPrestador_01
@path varchar(500)
AS BEGIN
	declare @Dinamico nvarchar(max)

CREATE TABLE #TempPrestador 
	(prestador VARCHAR(20), planPres varchar(40))

	set @Dinamico = 'BULK INSERT #TempPrestador 
	FROM'''+ @path +'''WITH
	(
	FIELDTERMINATOR = '';'', 
	ROWTERMINATOR = ''\n'', 
	CODEPAGE = ''65001'', 
	FIRSTROW = 2
	)';
	exec sp_executesql @Dinamico;
	
	insert into Prestador_info.Prestador(Nombre)
		Select DISTINCT RTRIM(UPPER(b.prestador))
		from #TempPrestador as b
		where not exists (select 1 from Prestador_info.Prestador as a 
			where a.Nombre = RTRIM(UPPER(b.prestador))
			)
			-- prestador planpres id_prestador nombre estado

	insert into Prestador_info.PrestadorCobertura(Plan_Prestador, idPrestador)
		Select upper(rtrim(LEFT(planPres, LEN(planPres) - 2))), H.id_Prestador
		from #TempPrestador as b inner join Prestador_info.Prestador as H
			on RTRIM(UPPER(b.prestador)) = RTRIM(UPPER(H.Nombre))	
				where NOT EXISTS (SELECT 1 FROM Prestador_info.PrestadorCobertura as N 
				where N.Plan_Prestador=  UPPER(RTRIM(LEFT(planPres, LEN(planPres) - 2)))
					and N.idPrestador = H.id_Prestador)
			
	drop table #TempPrestador
END;

go

-----------------------------------
--IMPORTAR SEDE
----------------------------------
CREATE OR ALTER procedure ImportacionArchivoCSV.ImportarSede_02
@path varchar(500)
AS BEGIN
	declare @Dinamico nvarchar(max)

CREATE TABLE #TempSede 
	(Sede VARCHAR(20), Direcccion varchar(40), Localidad varchar(20), provincia varchar(20))
	
	set @Dinamico = 'BULK INSERT #TempSede 
	FROM'''+ @path +'''WITH
	(
	FIELDTERMINATOR = '';'', 
	ROWTERMINATOR = ''\n'', 
	CODEPAGE = ''65001'', 
	FIRSTROW = 2
	)';
	exec sp_executesql @Dinamico;

	insert into Sede_info.SedeAtencion(Nombre_Sede, Direccion_Sede)
		select RTRIM(UPPER(a.Sede)), (CONCAT(Direcccion,' ',Localidad, ' ', provincia)) 
			from #TempSede as a where not exists(select 1 from Sede_info.SedeAtencion b 
				where RTRIM(UPPER(a.Sede)) = RTRIM(UPPER(b.Nombre_Sede)) )
	drop table #TempSede
END;

go

-----------------------------------
--IMPORTAR Pacientes
----------------------------------
CREATE OR ALTER procedure ImportacionArchivoCSV.ImportarPaciente_03
@path varchar(500)
AS BEGIN
	declare @Dinamico nvarchar(max)

CREATE TABLE #TempPaciente
	(Nombre VARCHAR(30), Apellido varchar(30),FecNac varchar(12), tipDoc varchar(20), NroDoc int, Sexo_Bio char(10), 
		Genero varchar(20), Telefono_Cel varchar(20), Nacionalidad varchar(30), mail varchar(50), 
			calleynro varchar(100), localidad varchar(50), provincia varchar(25))
	
	set @Dinamico = 'BULK INSERT #TempPaciente 
	FROM'''+ @path +'''WITH
	(
	FIELDTERMINATOR = '';'', 
	ROWTERMINATOR = ''\n'', 
	CODEPAGE = ''65001'', 
	FIRSTROW = 2
	)';
	exec sp_executesql @Dinamico;
		insert into Paciente_info.Paciente(Nombre,Apellido,FecNac, Tipo_Documento, DNI,
			Sexo_Biologico, Genero,	Telefono_Celular, Mail, Nacionalidad)
		select RTRIM(UPPER(a.Nombre)),
		RTRIM(UPPER(a.Apellido)),
			FORMAT(CONVERT(DATE, a.FecNac, 103), 'yyyy-M-d'), 
			RTRIM(UPPER(a.tipDoc)), 
			a.NroDoc,
			upper(left(rtrim(a.Sexo_Bio), 1)), 
			a.Genero, 
			a.Telefono_Cel, 
			a.mail, 
			upper(rtrim(a.Nacionalidad)) 
			from #TempPaciente a where 
				not exists(select 1 from Paciente_info.Paciente b where b.DNI = a.NroDoc)
		
		insert into Paciente_info.Domicilio(provincia, localidad, calle, idHistoriaClinica)
			select f.provincia, f.localidad, f.calleynro, c.id_Historia_Clinica from #TempPaciente as f
				inner join Paciente_info.Paciente as c on f.NroDoc =  c.DNI
					where not exists (select 1 from Paciente_info.Domicilio as pa 
						where pa.idHistoriaClinica = c.id_Historia_Clinica )


		insert into Paciente_info.Usuario(IdUsuario,contrasenia, fechaCreacion)
			select fa.NroDoc, fa.NroDoc, cast(getdate() as date) from #TempPaciente as fa
				where not exists(select 1 from Paciente_info.Usuario as ne 
					where ne.IdUsuario = fa.NroDoc)

	drop table #TempPaciente 

END;

GO
----------------------------------
--ESTUDIOS IMPORTAR
----------------------------------

------------------
--FUNCION CORRECION COLLATE
-----------------
CREATE or alter FUNCTION ImportacionArchivoJSON.ConvertirDeANSIaUTF8_MAYUS(@palabra varchar(100))
returns varchar(100)
as begin
	set @palabra = REPLACE(@palabra, 'Ã¡', 'á')
	set @palabra = REPLACE(@palabra, 'Ã©', 'é')
	set @palabra = REPLACE(@palabra, 'Ã­', 'í')
	set @palabra = REPLACE(@palabra, 'Ã³', 'ó')
	set @palabra = REPLACE(@palabra, 'Ãº', 'ú')
	set @palabra = REPLACE(@palabra, 'Ã', 'Á')
	set @palabra = REPLACE(@palabra, 'Ã‰', 'É')
	set @palabra = REPLACE(@palabra, 'Ã', 'Í')
	set @palabra = REPLACE(@palabra, 'Ã“', 'Ó')
	set @palabra = REPLACE(@palabra, 'Ãš', 'Ú')
	set @palabra = REPLACE(@palabra,'Ã±', 'ñ')
	set @palabra = REPLACE(@palabra, 'Ã‘', 'Ñ')
	
	return UPPER(@palabra)
END;


go 

CREATE OR ALTER procedure ImportacionArchivoJSON.ImportarEstudios_04
@path varchar(500)
AS BEGIN
	declare @Dinamico nvarchar(max)	

CREATE TABLE #TempJson 
	(area VARCHAR(40), estudio varchar(100),PRESTADOR VARCHAR(40), plan_Pres varchar(40), porcentaje int, costo int, estado BIT)
CREATE TABLE #TempJsonUTF8
	(area VARCHAR(40), estudio varchar(100), plan_Pres varchar(40), porcentaje int, costo int, estado BIT)
--creamos dos tablas, una donde guardamos la importacion, otra donde guardamos el archivo con collate utf8
	set @Dinamico = 
		'INSERT INTO #TempJson(area, estudio,PRESTADOR, plan_Pres, porcentaje, costo, estado) SELECT 
		B.AREA, B.ESTUDIO, B.PRESTADOR, B.PLAN_PRESTADOR, B.PORCENTAJE, B.COSTO, B.ESTADO 
		FROM OPENROWSET (BULK'''+@path+''',CODEPAGE = 65001,SINGLE_CLOB) AS DATA
		CROSS APPLY OPENJSON(DATA.BulkColumn)
		WITH (
		AREA VARCHAR(40) ''$.Area'',
		ESTUDIO VARCHAR(100) ''$.Estudio'',
		PRESTADOR VARCHAR(40) ''$.Prestador'',
		PLAN_PRESTADOR VARCHAR(40) ''$.Plan'',
		PORCENTAJE INT ''$."Porcentaje Cobertura"'',
		COSTO INT ''$.Costo'',
		ESTADO BIT ''$."Requiere autorizacion"''
		)AS B';
	
	exec sp_executesql @Dinamico
	--verificamos que nada sea null(error de archivo) y corregimos acentos
	INSERT INTO #TempJsonUTF8(area, estudio, plan_Pres, porcentaje, costo, estado) 
		select 
		RTRIM(ImportacionArchivoJSON.ConvertirDeANSIaUTF8_MAYUS(B.area)),
		RTRIM(ImportacionArchivoJSON.ConvertirDeANSIaUTF8_MAYUS(B.estudio)),
		RTRIM(ImportacionArchivoJSON.ConvertirDeANSIaUTF8_MAYUS(B.plan_Pres)),
		B.porcentaje,
		B.costo,
		B.estado
		from #TempJson as B
		where 
			area is not null and
			estudio is not null and 
			plan_Pres is not null and 
			porcentaje is not null and 
			costo is not null and 
			estado is not null 

	drop table #TempJson

	--verificamos que todos los registros del archivo a insertar tengan relacion con un plan prestador existente

	IF EXISTS(SELECT 1 FROM #TempJsonUTF8 as b LEFT JOIN Prestador_info.PrestadorCobertura as a 
			on a.Plan_Prestador = b.plan_Pres WHERE a.Plan_Prestador IS NULL)
	begin
		PRINT 'HAY UN PRESTADOR/SERVICIO DE PRESTADOR NO REGISTRADO'
		RETURN;
	end;

	--cte para ayuda visual, insertamos los datos en la tabla estudio y checkeamos repetidos
	with COBERTURAS as
	(
		select Plan_Prestador, id_PrestadorCobertura from Prestador_info.PrestadorCobertura
	)
	INSERT INTO Estudio_info.Estudio(Fecha, Area, Nombre_Estudio, Autorizado, Porcentaje_Cobertura, costo, idPrestadorCobertura)
	select 
		cast(getdate() as date),
		N.area,
		N.estudio,
		estado,
		porcentaje,
		costo,
		(SELECT H.id_PrestadorCobertura from COBERTURAS as H where H.Plan_Prestador = N.plan_Pres)
		FROM #TempJsonUTF8 as N
		Where not exists(select 1 from Estudio_info.Estudio AS F
			where 
				F.Nombre_Estudio = N.estudio AND
				F.Area = N.area AND
				F.Autorizado = N.estado AND
				F.Porcentaje_Cobertura = N.porcentaje AND
				F.costo = N.costo AND
				F.idPrestadorCobertura = (SELECT a.id_PrestadorCobertura from COBERTURAS as a where a.Plan_Prestador = N.plan_Pres) AND
				F.Fecha = CAST(GETDATE() AS DATE)
			)

	DROP TABLE #TempJsonUTF8 
END;

GO

-----------------
--GENERAR XML
-----------------

CREATE OR ALTER PROCEDURE GenerarXML.TurnosAtendidosEnRangoPorObraSocial_05
	@OBRASOCIAL VARCHAR(20),
	@FECHA_DESDE DATE,
	@FECHA_HASTA DATE
AS BEGIN
	
	with PACIENTESCONDOBRASOC as
	(
		select
			N.id_Historia_Clinica AS PAC_HISTCLINIC, 
			N.Apellido PAC_APELL,
			N.Nombre AS PAC_NOMBRE,
			N.DNI AS PAC_DNI,
			L.id_Prestador AS PAC_ID_PREST,
			L.Nombre AS PAC_NOMBRE_PREST
				from Paciente_info.Paciente AS N 
					INNER JOIN Paciente_info.Cobertura  AS H ON N.id_Historia_Clinica = H.idHistoriaClinica
					INNER JOIN Prestador_info.PrestadorCobertura AS K ON H.idPrestadorCobertura = K.id_PrestadorCobertura
					INNER JOIN Prestador_info.Prestador AS L ON K.idPrestador = L.id_Prestador
	),
	MEDICOS as
		(
			SELECT 
					B.id_Medico AS ID_MEDICO,
					B.Nro_Matricula AS MATRICULA, 
					B.Nombre_Medico AS NOMBRE_MEDICO,
					T.id_Especialidad AS ID_ESP_MEDIC,
					T.Nombre_Especialidad AS NOMBRE_ESP_MEDIC
			FROM Medico_info.Medico AS B
					INNER JOIN Medico_info.Especialidad AS T ON B.idEspecialidad = T.id_Especialidad 
		),
		TURNOSCONESTADO AS
			(
				SELECT 
					J.id_Turno AS TURNO_ID,
					J.IdHistoriaClinica AS TURNO_ID_HISTCLINIC, 
					J.idEstado_Turno AS TURNO_ESTADO_ID, 
					J.Fecha_Turno AS FECHA_TURNO, 
					J.Hora_Turno_Inicio  AS TURNO_HORA_INICIO,
					J.idMedico AS TURNO_ID_MEDICO,
					J.idEspecialidad AS TURNO_ID_ESPECIALIDAD
				FROM Turnos_info.ReservaTurno AS J
					WHERE J.idEstado_Turno = (SELECT N.id_EstadoTurno FROM Turnos_info.EstadoTurno AS N
													WHERE N.nombreEstado = 'ATENDIDO')
			)
			SELECT
				U.PAC_APELL, 
				U.PAC_NOMBRE, 
				U.PAC_DNI, 
				U.PAC_NOMBRE_PREST,
				Y.NOMBRE_MEDICO,
				Y.MATRICULA, 
				Y.NOMBRE_ESP_MEDIC,
				T.FECHA_TURNO,
				T.TURNO_HORA_INICIO
					FROM TURNOSCONESTADO AS T
						INNER JOIN MEDICOS AS Y ON T.TURNO_ID_MEDICO = Y.ID_MEDICO
						INNER JOIN PACIENTESCONDOBRASOC U ON T.TURNO_ID_HISTCLINIC = U.PAC_HISTCLINIC
					WHERE 
						U.PAC_NOMBRE_PREST = @OBRASOCIAL AND
						DATEDIFF(DAY, @FECHA_DESDE, @FECHA_HASTA) >= 0
					FOR XML RAW('REGISTRO'), ROOT ('XML')
END;

GO
RAISERROR(N'ESTA PARTE DEL script no está pensado para que lo ejecutes "de una" con F5. Seleccioná y ejecutá de a poco.', 20, 1) WITH LOG;
GO

--LOTE PRUEBA

exec ImportacionArchivoCSV.ImportarMedico_00 'C:\Users\User\Desktop\Datos TP4\Dataset\Medicos.csv'
GO
exec ImportacionArchivoCSV.ImportarPrestador_01 'C:\Users\User\Desktop\Datos TP4\Dataset\Prestador.csv'
GO
exec ImportacionArchivoCSV.ImportarSede_02 'C:\Users\User\Desktop\Datos TP4\Dataset\Sedes.csv'
GO
exec  ImportacionArchivoCSV.ImportarPaciente_03 'C:\Users\User\Desktop\Datos TP4\Dataset\Pacientes.csv'
GO
exec ImportacionArchivoJSON.ImportarEstudios_04 'C:\Users\User\Desktop\Datos TP4\Dataset\Centro_Autorizaciones.Estudios clinicos.json'

/*
MIRAR RESULTADOS
select * from Medico_info.Medico
select * from Medico_info.Especialidad
SELECT * FROM Prestador_info.Prestador
SELECT * FROM Prestador_info.PrestadorCobertura
select * from Sede_info.SedeAtencion
select* from Paciente_info.Usuario
select* from Paciente_info.Paciente 
*/

/* INSERTAMOS VALORES A COBERTURA*/
INSERT INTO Paciente_info.Cobertura(idHistoriaClinica, idPrestadorCobertura) VALUES
(1,1),
(2,1),
(3,1),
(4,2),
(5,2),
(6,3),
(7,3),
(8,3),
(9,3),
(10,8),
(11,8),
(12,8),
(13,8),
(14,9),
(15,10),
(16,10),
(17,11),
(18,11)

/*
VER RESULTADO
select * from Paciente_info.Cobertura
*/

/* DAMOS DE ALTA TURNOS EN DIAS X SEDE*/
exec Sede_info.InsertarDiasxSede 119918, '10:00', '17:00', '2024-06-22', 1
exec Sede_info.InsertarDiasxSede 119919, '10:00', '14:00', '2024-06-22', 1
exec Sede_info.InsertarDiasxSede 119920, '17:00', '18:00', '2024-06-22', 1
exec Sede_info.InsertarDiasxSede 119921, '13:00', '19:00', '2024-06-22', 1
exec Sede_info.InsertarDiasxSede 119922, '09:00', '13:00', '2024-06-22', 1
exec Sede_info.InsertarDiasxSede 119918, '09:00', '13:00', '2024-07-22', 1
exec Sede_info.InsertarDiasxSede 119919, '09:00', '13:00', '2024-08-22', 1

/* RESERVAMOS ESOS TURNOS DADOS DE ALTA....*/

exec Turnos_info.InsertarReserva '2024-06-22', '10:00', 25111001, 119918, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-06-22', '11:00', 25111001, 119919, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-06-22', '17:00', 25111002, 119920, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-06-22', '13:00', 25111002, 119921, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-06-22', '09:00', 25111003, 119922, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-06-22', '13:00', 25111003, 119918, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-06-22', '13:30', 25111003, 119919, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-06-22', '17:30', 25111004, 119920, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-06-22', '16:00', 25111004, 119921, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-07-22', '09:00', 25111001, 119918, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-08-22', '09:30', 25111002, 119919, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-07-22', '10:30', 25111004, 119918, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-08-22', '10:00', 25111004, 119919, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-07-22', '09:15', 25111010, 119918, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-08-22', '09:45', 25111011, 119919, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-07-22', '10:45', 25111012, 119918, 1, 'PRESENCIAL'
exec Turnos_info.InsertarReserva '2024-08-22', '10:15', 25111010, 119919, 1, 'PRESENCIAL'

/*
VER RESULTADO
select * from Sede_info.DiasxSede
select * from Turnos_info.ReservaTurno
*/


/*
MODIFICAMOS ALGUN TURNO PONIENDOLO EN ATENDIDO, ASI GENERAMOS EL XML
select * from Sede_info.DiasxSede
select * from Turnos_info.ReservaTurno
*/

exec Turnos_info.ModificarReserva 25111010, '2024-08-22', '10:15', 'ATENDIDO'
exec Turnos_info.ModificarReserva 25111012,'2024-07-22', '10:45', 'ATENDIDO'

/*GENERAMOS EL XML*/

EXEC GenerarXML.TurnosAtendidosEnRangoPorObraSocial_05 'OSDE', '2024-07-22', '2024-08-22'