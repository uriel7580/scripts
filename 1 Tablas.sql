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
	CONSTRAINT [PK_ArchivosCanvas] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
PRINT N'tabla ArchivosCanvas'

CREATE TABLE [dbo].[ArchivosCanvasFiltrado](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Periodo] [varchar](50) NOT NULL,
	[CRN] [varchar](50) NOT NULL,
	[PIDMProfesor] [varchar](50) NOT NULL,
	[PIDMAlumno] [varchar](50) NOT NULL,
	[GradeNum] [varchar](50) NOT NULL,
	[GradeAlfa] [varchar](50) NOT NULL,
	[Procesado] [bit] NOT NULL,
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
	[UsuarioLogin] [int] NOT NULL,
	[Comentarios] [varchar](8000) NOT NULL,
	CONSTRAINT [PK_Bitacora_CargaCalificiones] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Bitacora_GeneracionReportes](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Accion] [varchar](8000) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioLogin] [int] NOT NULL,
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
	[UsuarioLogin] [int] NOT NULL,
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
	[UsuarioLogin] [int] NOT NULL,
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
	[UsuarioLogin] [int] NOT NULL,
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

CREATE TABLE [dbo].[Bitacora_RolesAdmin](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Accion] [varchar](8000) NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioLogin] [int] NOT NULL,
	[Comentarios] [varchar](8000) NOT NULL,
	CONSTRAINT [PK_Bitacora_RolesAdmin] PRIMARY KEY CLUSTERED 
	(
		[Id] ASC
	)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[Bitacora_SubPeriodoCampus](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[SubperiodoNacionalId] [int] NOT NULL,
	[SubperiodoCampusId] [int] NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioLogin] [int] NOT NULL,
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
	[SubperiodoNacionalId] [int] NOT NULL,
	[FechaRegistro] [datetime] NOT NULL,
	[UsuarioLogin] [int] NOT NULL,
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
	[CalificacionAbreviada] [varchar](10) NOT NULL,
	[ClaveEjerAcadEfectivo] [int] NOT NULL,
	[ClaveEjerAcadFin] [varchar](10) NOT NULL,
	[CANVAS] [bit] NULL,
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
	[Grupo] [int] NOT NULL,
	[CRN] [int] NOT NULL,
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
	[CRN] [int] NOT NULL,
	[NombreNormativa] [varchar](100) NOT NULL,
	[NormativaId] [int] NOT NULL,
	CONSTRAINT [PK_MateriasNormativas] PRIMARY KEY CLUSTERED 
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
	--[CampusId] [varchar](5) NOT NULL,
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
