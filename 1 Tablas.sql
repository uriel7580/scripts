--CREAR FUNCIONES
/****** Object:  UserDefinedFunction [dbo].[dReturnDate]    Script Date: 28/10/2019 10:58:59 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
create FUNCTION [dbo].[dReturnDate]( @dFecha as datetime)
	returns DATETIME
	as
	begin
		DECLARE @D AS datetimeoffset
		SET @D = CONVERT(datetimeoffset, @Dfecha) AT TIME ZONE 'Central Standard Time (Mexico)'
		RETURN CONVERT(datetime, @D);
	end
GO
/****** Object:  UserDefinedFunction [dbo].[intReturnPMT6yMateriaExcepcionValida]    Script Date: 28/10/2019 10:58:59 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alejandro Cervantes	
-- Create date: 07-10-2019
-- Description:	Nos ayuda a validar si nos encontramos en PMT6 valido y nuestro grupo tiene una materia de excepción valida.
-- =============================================
CREATE FUNCTION [dbo].[intReturnPMT6yMateriaExcepcionValida]
	(
		@TERM as VARCHAR(20),
		@CRN as INT
	)
	RETURNS INT
	AS
	BEGIN

		DECLARE @PMT6 VARCHAR(20)= @TERM + '-6'
		DECLARE @ID_CAMPUS VARCHAR(20)=(SELECT CAMPUS FROM Replicas.dbo.GRUPOS WHERE TERM = @TERM AND CRN=@CRN)
		DECLARE @FECHA_INICIO	DATETIME = (SELECT FechaDesde FROM SubperiodosCampus WHERE IdCampus = @ID_CAMPUS AND IdSubperiodo=@PMT6)
		DECLARE @FECHA_FIN		DATETIME = (SELECT FechaHasta FROM SubperiodosCampus WHERE IdCampus = @ID_CAMPUS AND IdSubperiodo=@PMT6)
		DECLARE @SUBJECT VARCHAR(20) = (SELECT [Subject] FROM REPLICAS.DBO.GRUPOS WHERE TERM = @TERM AND CRN=@CRN)
		DECLARE @COURSE VARCHAR(20) = (SELECT Course FROM REPLICAS.DBO.GRUPOS WHERE TERM = @TERM AND CRN=@CRN)
		DECLARE @RES INT;
		DECLARE @HOY_MISMO DATETIME
		SET @HOY_MISMO = DBO.dReturnDate(GETDATE());

		IF EXISTS(SELECT Id FROM MateriasExclusiones WHERE Materia = @SUBJECT AND Curso = @COURSE AND TERM = @TERM AND Activo = 1)
			BEGIN
				IF @HOY_MISMO BETWEEN @FECHA_INICIO AND @FECHA_FIN
					BEGIN
						SET @RES = 1 
					END
				ELSE
					BEGIN
						SET @RES = 0 
					END
			END
		ELSE
			BEGIN
				SET @RES = 0 
			END

			-- Return the result of the function
			RETURN @RES
	END
GO
/****** Object:  UserDefinedFunction [dbo].[vCReturnSubPeriodo]    Script Date: 28/10/2019 10:58:59 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alejandro Cervantes
-- Create date: 18-09-2019
-- Description:	funcion que trae el subperiodo
-- =============================================
CREATE FUNCTION [dbo].[vCReturnSubPeriodo]
	(
		-- Add the parameters for the function here
		@TERM as varchar(20),
		@CRN as int,
		@TIPO as int
	)
	RETURNS VARCHAR(100)
	AS
	BEGIN
		DECLARE @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC VARCHAR(10);

		DECLARE @ID_CAMPUS VARCHAR(20)=(SELECT CAMPUS FROM Replicas.dbo.GRUPOS WHERE TERM = @TERM AND CRN=@CRN)
		DECLARE @IS_SEMANA_TEC VARCHAR(10)
		SELECT @IS_SEMANA_TEC = (SELECT TOP 1 CLAVE_ATRIBUTO FROM REPLICAS.DBO.GRUPO_ATRIBUTOS WHERE TERM =@TERM AND CRN = @CRN AND CLAVE_ATRIBUTO = 'STEC')
		DECLARE @CLAVE_ATRIBUTO_PERIODO_TEMP VARCHAR(20) = (SELECT TOP 1 CLAVE_ATRIBUTO FROM Replicas.DBO.GRUPO_ATRIBUTOS WHERE TERM =@TERM AND CRN = @CRN AND CLAVE_ATRIBUTO IN ('PMT1','PMT2','PMT3','PMT4','PMT5','PMT6'))
		--set @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT1'
		IF @TIPO = 1
		BEGIN
		IF ISNULL(@IS_SEMANA_TEC,'') <>''
			BEGIN
				
				SELECT @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC =
				CASE --DETECTAMOS QUE NUMERO DE PERIODO DE SEMANA TEC ES
					WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT1' THEN @TERM+'-7'
					WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT2' THEN @TERM+'-8'
					WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT3' THEN @TERM+'-9'
				END
		END

		ELSE
			BEGIN
				SELECT @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC=
					CASE --EN EL ELSE SON LOS SUBPERIODOS DEL 1 AL 6
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT1' THEN @TERM+'-1'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT2' THEN @TERM+'-2'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT3' THEN @TERM+'-3'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT4' THEN @TERM+'-4'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT5' THEN @TERM+'-5'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT6' THEN @TERM+'-6'
					END
			END	
		END
		IF @TIPO = 2
		BEGIN
		IF ISNULL(@IS_SEMANA_TEC,'') <>''
			BEGIN
				--SI EL CONTADOR ES MAYOR A DOS SIGNIFICA QUE SON SEMANAS TEC
				SELECT @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC =
				CASE --DETECTAMOS QUE NUMERO DE PERIODO DE SEMANA TEC ES
					WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT1' THEN 'PMT7'
					WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT2' THEN 'PMT8'
					WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT3' THEN 'PMT9'
				END
			END
		ELSE
			BEGIN
				SELECT @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC=
					CASE --EN EL ELSE SON LOS SUBPERIODOS DEL 1 AL 6
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT1' THEN 'PMT1'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT2' THEN 'PMT2'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT3' THEN 'PMT3'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT4' THEN 'PMT4'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT5' THEN 'PMT5'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT6' THEN 'PMT6'
					END
			END	
		END
		RETURN @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC
	END
GO

--CREACION DE LAS TABLAS PARA RECEPCION DE ANTIGUA INFORMACION
CREATE TABLE [dbo].[ArchivosCanvas](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Periodo] [varchar](50) NOT NULL,
	[CRN] [varchar](50) NOT NULL,
	[PIDMProfesor] [varchar](50) NOT NULL,
	[PIDMAlumno] [varchar](50) NOT NULL,
	[GradeNum] [varchar](50) NOT NULL,
	[GradeAlfa] [varchar](50) NOT NULL,
	[Procesado] [bit] NOT NULL,
	[Horas] [int] NOT NULL,
	[Destacado] [bit] NOT NULL,
	[ComentarioDestacado] [varchar](6000) NOT NULL,
	CONSTRAINT [PK_ArchivosCanvas] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
PRINT N'tabla ArchivosCanvas CREADA'

CREATE TABLE [dbo].[ArchivosCanvasFiltrado](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Periodo] [varchar](50) NOT NULL,
	[CRN] [varchar](50) NOT NULL,
	[PIDMProfesor] [varchar](50) NOT NULL,
	[PIDMAlumno] [varchar](50) NOT NULL,
	[GradeNum] [varchar](50) NOT NULL,
	[GradeAlfa] [varchar](50) NOT NULL,
	[Procesado] [bit] NOT NULL,
	[Horas] [int] NOT NULL,
	[Destacado] [bit] NOT NULL,
	[ComentarioDestacado] [varchar](6000) NOT NULL,
	CONSTRAINT [PK_ArchivosCanvasFiltrado] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[ArchivosCargaCalificaciones](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Campus] [varchar](255) NOT NULL,
	[Periodo] [varchar](255) NOT NULL,
	[NombreProfesor] [varchar](255) NOT NULL,
	[NominaCaptura] [varchar](255) NOT NULL,
	[Materia] [varchar](255) NOT NULL,
	[CRN] [int] NOT NULL,
	[NumeroAlumnos] [int] NOT NULL,
	[Capturado] [int] NOT NULL,
	[FechaCaptura] [datetime] NOT NULL,
	CONSTRAINT [PK_ArchivosCargaCalificaciones] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[ArchivosProcesados](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](200) NOT NULL,
	CONSTRAINT [PK_ArchivosProcesados] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Bitacora_CargaCalificiones](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[CRN] [int] NOT NULL,
	[MatriculaProfesor] [varchar](50) NOT NULL,
	[Accion] [varchar](8000) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioLogin] [varchar](100) NOT NULL,
	[Comentarios] [varchar](8000) NOT NULL,
	CONSTRAINT [PK_Bitacora_CargaCalificiones] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Bitacora_Correos](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Idperiodo] [varchar](50) NOT NULL,
	[Crn] [varchar](50) NOT NULL,
	[Nomina] [varchar](20) NOT NULL,
	[Correo] [varchar](250) NOT NULL,
	[ResultadoStatus] [int] NOT NULL,
	[ResultadoMensaje] [varchar](1500) NULL,
	[MailId] [int] NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioLogin] [varchar](50) NOT NULL,
 CONSTRAINT [PK_Bitacora_Correos] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Bitacora_GeneracionReportes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Accion] [varchar](8000) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioLogin] [varchar](100) NOT NULL,
	[Comentarios] [varchar](8000) NOT NULL,
	CONSTRAINT [PK_Bitacora_GeneracionReportes] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Bitacora_MateriasExcepcion](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Subject] [varchar](100) NOT NULL,
	[Course] [varchar](100) NOT NULL,
	[Accion] [varchar](8000) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioLogin] [varchar](100) NOT NULL,
	[Comentarios] [varchar](8000) NOT NULL,
	CONSTRAINT [PK_Bitacora_MateriasExcepcion] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Bitacora_MateriasNormativa](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Subject] [varchar](100) NOT NULL,
	[Course] [varchar](100) NOT NULL,
	[NormativaId] [int] NOT NULL,
	[Accion] [varchar](8000) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioLogin] [varchar](100) NOT NULL,
	[Comentarios] [varchar](8000) NOT NULL,
 CONSTRAINT [PK_Bitacora_MateriasNormativa] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Bitacora_Normativas](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[NormativaId] [int] NOT NULL,
	[Accion] [varchar](8000) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioLogin] [varchar](100) NOT NULL,
	[Comentarios] [varchar](8000) NOT NULL,
	CONSTRAINT [PK_Bitacora_Normativas] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Bitacora_ProcesoAutomatico](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TERM] [varchar](20) NOT NULL,
	[CRN] [int] NOT NULL,
	[MatriculaProfesor] [varchar](50) NOT NULL,
	[MatriculaAlumno] [varchar](50) NOT NULL,
	[Accion] [varchar](8000) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[MensajeError] [varchar](8000) NOT NULL,
	[Comentarios] [varchar](8000) NOT NULL,
	CONSTRAINT [PK_Bitacora_ProcesoAutomatico] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Bitacora_ProcesoSC](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TERM] [varchar](20) NOT NULL,
	[CRN] [int] NOT NULL,
	[SubPeriodoId] [varchar](50) NOT NULL,
	[ClaveCampus] [varchar](20) NOT NULL,
	[Accion] [varchar](8000) NOT NULL,
	[FechaRegistro] [datetime] NULL,
	[MensajeError] [varchar](8000) NOT NULL,
	[Comentarios] [varchar](8000) NOT NULL,
 CONSTRAINT [PK_Bitacora_ProcesoSC] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Bitacora_RolesAdmin](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Accion] [varchar](8000) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioLogin] [varchar](100) NOT NULL,
	[Comentarios] [varchar](8000) NOT NULL,
	CONSTRAINT [PK_Bitacora_RolesAdmin] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Bitacora_SubPeriodoCampus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SubperiodoNacionalId] [varchar](100) NOT NULL,
	[SubperiodoCampusId] [varchar](100) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioLogin] [varchar](100) NOT NULL,
	[Accion] [varchar](8000) NOT NULL,
	[Comentarios] [varchar](8000) NOT NULL,
	CONSTRAINT [PK_Bitacora_SubPeriodoCampus] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Bitacora_SubperiodoNacional](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SubperiodoNacionalId] [varchar](100) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioLogin] [varchar](100) NOT NULL,
	[Accion] [varchar](8000) NOT NULL,
	[Comentarios] [varchar](8000) NOT NULL,
	CONSTRAINT [PK_Bitacora_SubperiodoNacional] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[CalificacionesEnviadasBanner](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TERM] [varchar](50) NOT NULL,
	[CRN] [varchar](50) NOT NULL,
	[MatriculaAlumno] [varchar](50) NOT NULL,
	[PIDM] [varchar](50) NOT NULL,
	[Calificacion] [varchar](10) NOT NULL,
	[FechaAgregado] [datetime] NOT NULL,
	[UsuarioCalifico] [varchar](50) NOT NULL,
	[Comentarios] [varchar](4000) NOT NULL,
	[SeEnvio] [bit] NOT NULL,
	[Horas] [int] NOT NULL,
	[Destacado] [bit] NOT NULL,
	[ComentarioDestacado] [varchar](6000) NOT NULL,
	CONSTRAINT [PK_CalificacionesEnviadasBanner] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[CalificacionesEnviadasConsolidado](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[TERM] [varchar](50) NOT NULL,
	[CRN] [varchar](50) NOT NULL,
	[FechaAgregado] [datetime] NOT NULL,
	[UsuarioCalifico] [varchar](50) NOT NULL,
	CONSTRAINT [PK_CalificacionesEnviadasConsolidado] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[CalificacionesPermitidas](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[ClaveCalificacion] [varchar](10) NOT NULL,
	[Descripcion] [varchar](150) NOT NULL,
	[CalificacionAbreviada] [varchar](10) NOT NULL,
	[ClaveEjerAcadEfectivo] [int] NOT NULL,
	[ClaveEjerAcadFin] [varchar](10) NOT NULL,
	[CANVAS] [bit] NULL,
	[PROCESO] [bit] NULL,
	CONSTRAINT [PK_CalificacionesPermitidas] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[CatalogoBitacoras](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](500) NOT NULL,
	[Activo] [int] NOT NULL,
	[FechaAgregado] [datetime] NOT NULL,
	[Comentarios] [varchar](1000) NOT NULL,
	CONSTRAINT [PK_CatalogoBitacoras] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[CatalogoNormativas](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaIngreso] [datetime] NOT NULL,
	CONSTRAINT [PK_CatalogoNormativas] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[ExcepciondeMaterias](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Subject] [varchar](50) NOT NULL,
	[Course] [varchar](50) NOT NULL,
	[TERM] [varchar](10) NOT NULL,
	CONSTRAINT [PK_ExcepciondeMaterias] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC,
		[Subject] ASC,
		[Course] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[MateriasExclusiones](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Materia] [varchar](20) NOT NULL,
	[Curso] [varchar](20) NOT NULL,
	[ClaveMateria] [varchar](50) NOT NULL,
	[NombreMateria] [varchar](50) NOT NULL,
	[TERM] [varchar](10) NOT NULL,
	[Vigencia] [datetime] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaAgregado] [datetime] NOT NULL,
	CONSTRAINT [PK_MateriasExclusiones] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[MateriasNormativas](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Materia] [varchar](10) NOT NULL,
	[Curso] [varchar](10) NOT NULL,
	[ClaveMateria] [varchar](20) NOT NULL,
	[NombreMateria] [varchar](100) NOT NULL,
	[TERM] [varchar](20) NOT NULL,
	[NombreNormativa] [varchar](100) NOT NULL,
	[NormativaId] [int] NOT NULL,
	[Vigencia] [datetime] NOT NULL,
	[FechaAgregado] [datetime] NOT NULL,
	[Activo] [bit] NOT NULL,
	CONSTRAINT [PK_MateriasNormativas] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[MateriasServicioSocial](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Materia] [varchar](20) NOT NULL,
	[Curso] [varchar](20) NOT NULL,
	[ClaveMateria] [varchar](50) NOT NULL,
	[NombreMateria] [varchar](50) NOT NULL,
	[HorasReprobado] [int] NOT NULL,
	[HorasMinimas] [int] NOT NULL,
	[HorasMaximas] [int] NOT NULL,
	[TERM] [varchar](10) NOT NULL,
	[Vigencia] [datetime] NOT NULL,
	[Activo] [bit] NOT NULL,
	[FechaAgregado] [datetime] NOT NULL,
 CONSTRAINT [PK_MateriasServicioSocial] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE NORMATIVAS DROP CONSTRAINT PK_NORMATIVAS
ALTER TABLE ROLES DROP CONSTRAINT PK_ROLES
ALTER TABLE Usuarios DROP CONSTRAINT PK_USUARIOS
EXEC sp_rename 'NORMATIVAS','NORMATIVAS_tmp'
GO
CREATE TABLE [dbo].[Normativas](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[NormativaId] [int] NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[ClaveCal] [varchar](5) NOT NULL,
	[VigenciaDesde] [date] NOT NULL,
	[VigenciaHasta] [date] NOT NULL,
	[IntervaloDesde] [int] NULL,
	[IntervaloHasta] [int] NULL,
	[Descripcion] [varchar](300) NOT NULL,
	[Nota] [varchar](300) NOT NULL,
	[IndActivo] [bit] NOT NULL,
	[FechaAgregado] [datetime] NOT NULL,
	CONSTRAINT [PK_Normativas] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Periodos](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Numero] [int] NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Descripcion] [varchar](max) NOT NULL,
 CONSTRAINT [PK_Periodos] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[ProcesarSC](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Periodo] [varchar](50) NOT NULL,
	[SubperiodoCampus] [varchar](50) NOT NULL,
	[CampusId] [varchar](10) NOT NULL,
	[FechaCierre] [datetime] NOT NULL,
	[EnProceso] [bit] NOT NULL,
	[Procesado] [bit] NOT NULL,
 CONSTRAINT [PK_ProcesarSC] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
GO


CREATE TABLE [dbo].[SubperiodosCampus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[IdSubperiodo] [varchar](50) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[FechaDesde] [datetime] NOT NULL,
	[FechaHasta] [datetime] NOT NULL,
	[IdCampus] [varchar](20) NOT NULL,
	[Nivel] [varchar](100) NOT NULL,
	[Idperiodo] [varchar](50) NOT NULL,
	[IdperiodoNacional] [varchar](100) NOT NULL,
	[FechaAgregado] [datetime] NOT NULL,
	[Activo] [bit] NOT NULL,
	CONSTRAINT [PK_SubperiodosCampus] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[SubperiodosNacional](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SubperiodoNacionalId] [varchar](50) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[FechaDesde] [datetime] NOT NULL,
	[FechaHasta] [datetime] NOT NULL,
	[Nivel] [varchar](100) NOT NULL,
	[Idperiodo] [varchar](50) NOT NULL,
	[FechaAgregado] [datetime] NOT NULL,
	[Activo] [bit] NOT NULL,
	CONSTRAINT [PK_SubperiodosNacional] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[SubperiodosNacionalCampusFechaFin](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Idperiodo] [varchar](50) NOT NULL,
	[IdperiodoNacional] [varchar](50) NOT NULL,
	[IdCampus] [nchar](20) NOT NULL,
	[FechaAgregado] [datetime] NOT NULL,
 CONSTRAINT [PK_SuperiodosNacionalCampusFechaFin] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
GO

CREATE TABLE [dbo].[SubperiodosNacionalCampusFechaInicio](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Idperiodo] [varchar](50) NOT NULL,
	[IdperiodoNacional] [varchar](50) NOT NULL,
	[IdCampus] [nchar](20) NOT NULL,
	[FechaAgregado] [datetime] NOT NULL,
 CONSTRAINT [PK_SuperiodosNacionalCampusFechaInicio] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
	) ON [PRIMARY]
GO

ALTER TABLE [Normativas] ADD CONSTRAINT FK_Normativas_CatalogoNormativas FOREIGN KEY ([NormativaId])
REFERENCES CatalogoNormativas (Id)
ALTER TABLE [MateriasNormativas] ADD CONSTRAINT FK_MateriasNormativas_CatalogoNormativas FOREIGN KEY ([NormativaId])
REFERENCES CatalogoNormativas (Id)

EXEC sp_rename 'USUARIOS','USUARIOS_tmp'
CREATE TABLE [dbo].[Usuarios](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Nomina] [varchar](20) NOT NULL,
	[Nombre] [varchar](50) NOT NULL,
	[Apellidos] [varchar](100) NOT NULL,
	[Correo] [varchar](100) NOT NULL,
	[Activo] [bit] NOT NULL,
	[DTAgregado] [datetime] NOT NULL,
	CONSTRAINT [PK_Usuarios] PRIMARY KEY CLUSTERED 
	(
		[Nomina] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
EXEC sp_rename 'ROLES','ROLES_tmp'

CREATE TABLE [dbo].[Roles](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Nombre] [varchar](100) NOT NULL,
	[Activo] [bit] NOT NULL,
	CONSTRAINT [PK_Roles] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[RolesUsuario](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[UsuariosNomina] [varchar](20) NOT NULL,
	[RolesId] [int] NOT NULL,
	[CampusId] [varchar](5) NOT NULL,
	[Activo] [bit] NOT NULL,
	CONSTRAINT [PK_RolesUsuario] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

ALTER TABLE [RolesUsuario] ADD CONSTRAINT FK_RolesUsuario_Usuarios FOREIGN KEY ([UsuariosNomina])
REFERENCES Usuarios (Nomina)
ALTER TABLE [RolesUsuario] ADD CONSTRAINT FK_RolesUsuario_Roles FOREIGN KEY ([RolesId])
REFERENCES Roles (Id)
