--clonacion de informacion
SET IDENTITY_INSERT [dbo].[ArchivosCanvas] ON 
    INSERT INTO [dbo].[ArchivosCanvas]
           ([Id]
           ,[Periodo]
           ,[CRN]
           ,[PIDMProfesor]
           ,[PIDMAlumno]
           ,[GradeNum]
           ,[GradeAlfa]
           ,[Procesado]
           ,[Horas]
	         ,[Destacado]
           ,[ComentarioDestacado])
		   select [ID],[PERIODO]
           ,[CRN]
           ,[PIDM_PROFESOR]
           ,[PIDM_ALUMNO]
           ,[GRADE_NUM]
           ,[GRADE_ALFA]
           ,[PROCESADO]
           ,0
           ,0
           ,''
           from ARCHIVO_CANVAS;
SET IDENTITY_INSERT [dbo].[ArchivosCanvas] OFF
GO
SET IDENTITY_INSERT [dbo].[ArchivosCanvasFiltrado] ON 
    INSERT INTO [dbo].[ArchivosCanvasFiltrado]
           ([Id],[Periodo]
           ,[CRN]
           ,[PIDMProfesor]
           ,[PIDMAlumno]
           ,[GradeNum]
           ,[GradeAlfa]
           ,[Procesado]
           ,[Horas]
	         ,[Destacado]
           ,[ComentarioDestacado])
		   select [ID],[PERIODO]
           ,[CRN]
           ,[PIDM_PROFESOR]
           ,[PIDM_ALUMNO]
           ,[GRADE_NUM]
           ,[GRADE_ALFA]
           ,[PROCESADO]
           ,0
           ,0
           ,''
           from ARCHIVO_CANVAS_FILTRADO;
SET IDENTITY_INSERT [dbo].[ArchivosCanvasFiltrado] OFF
GO
SET IDENTITY_INSERT [dbo].[ArchivosCargaCalificaciones] ON 
    INSERT INTO [dbo].[ArchivosCargaCalificaciones]
            ([Id]
            ,[Campus]
            ,[Periodo]
            ,[NombreProfesor]
            ,[NominaCaptura]
            ,[Materia]
            ,[CRN]
            ,[NumeroAlumnos]
            ,[Capturado]
            ,[FechaCaptura])
            SELECT [ID]
            ,[CAMPUS]
            ,[PERIODO]
            ,[NOMBRE_PROFESOR]
            ,[NOMINA_CAPTURA]
            ,[MATERIA]
            ,[CRN]
            ,[NUMERO_ALUMNOS]
            ,[CAPTURADO]
            ,[FECHA_CAPTURA]
            FROM [dbo].[ARCHIVO_CARGA_CALIFICACIONES]
SET IDENTITY_INSERT [dbo].[ArchivosCargaCalificaciones] OFF
GO
SET IDENTITY_INSERT [dbo].[ArchivosProcesados] ON 
    INSERT INTO [dbo].[ArchivosProcesados]
           ([Id]
           ,[Nombre])
            SELECT [ID]
            ,[NOMBRE]
            FROM [dbo].[ARCHIVOS_PROCESADOS]
SET IDENTITY_INSERT [dbo].[ArchivosProcesados] OFF
GO
/*SET IDENTITY_INSERT [dbo].[Bitacora_tmp] ON 
    INSERT INTO [dbo].[Bitacora_tmp]
           ([Id],
            [TERM],
            [CRN],
            [IdSubperiodo],
            [IdUsuarioLogin],
            [MatriculaNomina],
            [FechaRegistro],
            [Accion],
            [Comentarios])
            SELECT [ID]
            ,[TERM]
            ,[CRN]
            ,[ID_SUBPERIODO]
            ,[ID_USUARIO_LOGIN]
            ,[MATRICULA_NOMINA]
            ,[FECHA_REGISTRO]
            ,[ACCION]
            ,[COMENTARIOS]
            FROM [dbo].[BITACORA]
SET IDENTITY_INSERT [dbo].[Bitacora_tmp] OFF
GO*/
SET IDENTITY_INSERT [dbo].[Bitacora_CargaCalificiones] ON 
    INSERT INTO [dbo].[Bitacora_CargaCalificiones]
           ([Id]
            ,[CRN]
            ,[MatriculaProfesor]
            ,[Accion]
            ,[FechaRegistro]
            ,[UsuarioLogin]
            ,[Comentarios])
            SELECT [ID]
            ,[CRN]
            ,[MATRICULA_PROFESOR]
            ,[ACCION]
            ,[FECHA_REGISTRO]
            ,[USUARIO_LOGIN]
            ,[COMENTARIOS]
            FROM [dbo].[BITACORA_CARGA_CALIFICACIONES]
SET IDENTITY_INSERT [dbo].[Bitacora_CargaCalificiones] OFF
GO
SET IDENTITY_INSERT [dbo].[Bitacora_GeneracionReportes] ON 
    INSERT INTO [dbo].[Bitacora_GeneracionReportes]
           ([Id]
            ,[Accion]
            ,[FechaRegistro]
            ,[UsuarioLogin]
            ,[Comentarios])
            SELECT [ID]
            ,[ACCION]
            ,[FECHA_REGISTRO]
            ,[USUARIO_LOGIN]
            ,[COMENTARIOS]
            FROM [dbo].[BITACORA_GENERACION_REPORTE]
SET IDENTITY_INSERT [dbo].[Bitacora_GeneracionReportes] OFF
GO
SET IDENTITY_INSERT [dbo].[Bitacora_MateriasExcepcion] ON 
    INSERT INTO [dbo].[Bitacora_MateriasExcepcion]
           ([Id]
      ,[Subject]
      ,[Course]
      ,[Accion]
      ,[FechaRegistro]
      ,[UsuarioLogin]
      ,[Comentarios])
            SELECT [ID]
      ,[SUBJECT]
      ,[COURSE]
      ,[ACCION]
      ,[FECHA_REGISTRO]
      ,[USUARIO_LOGIN]
      ,[COMENTARIOS]
  FROM [dbo].[BITACORA_MATERIAS_EXCEPCION]
SET IDENTITY_INSERT [dbo].[Bitacora_MateriasExcepcion] OFF
GO
SET IDENTITY_INSERT [dbo].[Bitacora_MateriasNormativa] ON 
    INSERT INTO [dbo].[Bitacora_MateriasNormativa]
           ([Id]
      ,[Subject]
      ,[Course]
      ,[NormativaId]
      ,[Accion]
      ,[FechaRegistro]
      ,[UsuarioLogin]
      ,[Comentarios])
            SELECT [ID]
      ,[SUBJECT]
      ,[COURSE]
      ,[ID_NORMATIVA]
      ,[ACCION]
      ,[FECHA_REGISTRO]
      ,[USUARIO_LOGIN]
      ,[COMENTARIOS]
  FROM [dbo].[BITACORA_MATERIAS_NORMATIVA]
SET IDENTITY_INSERT [dbo].[Bitacora_MateriasNormativa] OFF
GO
SET IDENTITY_INSERT [dbo].[Bitacora_Normativas] ON 
    INSERT INTO [dbo].[Bitacora_Normativas]
           ([Id]
      ,[NormativaId]
      ,[Accion]
      ,[FechaRegistro]
      ,[UsuarioLogin]
      ,[Comentarios])
            SELECT [ID]
      ,[ID_NORMATIVA]
      ,[ACCION]
      ,[FECHA_REGISTRO]
      ,[USUARIO_LOGIN]
      ,[COMENTARIOS]
  FROM [dbo].[BITACORA_NORMATIVA]
SET IDENTITY_INSERT [dbo].[Bitacora_Normativas] OFF
GO
SET IDENTITY_INSERT [dbo].[Bitacora_ProcesoAutomatico] ON 
    INSERT INTO [dbo].[Bitacora_ProcesoAutomatico]
           ([Id]
      ,[TERM]
      ,[CRN]
      ,[MatriculaProfesor]
      ,[MatriculaAlumno]
      ,[Accion]
      ,[FechaRegistro]
      ,[MensajeError]
      ,[Comentarios])
            SELECT [ID],
      [TERM],
      [CRN],
      case when [MATRICULA_PROFESOR] is NULL then ''  else [MATRICULA_PROFESOR] end as [MATRICULA_PROFESOR],
      case when [MATRICULA_ALUMNO] is NULL then ''  else [MATRICULA_ALUMNO] end as [MATRICULA_ALUMNO],
      [ACCION],
      [FECHA_REGISTRO],
      [MENSAJE_ERROR],
      [COMENTARIOS]
      FROM [dbo].[BITACORA_PROCESO_AUTOMATICO]
SET IDENTITY_INSERT [dbo].[Bitacora_ProcesoAutomatico] OFF
GO
-- SET IDENTITY_INSERT [dbo].[Bitacora_RolesAdmin] ON 
--     INSERT INTO [dbo].[Bitacora_RolesAdmin]
--            ([Id]
--       ,[Accion]
--       ,[FechaRegistro]
--       ,[UsuarioLogin]
--       ,[Comentarios])
--     SELECT [ID]
--       ,[ACCION]
--       ,[FECHA_REGISTRO]
--       ,[USUARIO_LOGIN]
--       ,[COMENTARIOS]
--   FROM [dbo].[BITACORA_ROLES_ADMIN]
-- SET IDENTITY_INSERT [dbo].[Bitacora_RolesAdmin] OFF
GO
--validarlo
SET IDENTITY_INSERT [dbo].[Bitacora_SubPeriodoCampus] ON 
    INSERT INTO [dbo].[Bitacora_SubPeriodoCampus]
           ([Id]
      ,[SubperiodoNacionalId]
      ,[SubperiodoCampusId]
      ,[FechaRegistro]
      ,[UsuarioLogin]
      ,[Accion]
      ,[Comentarios])
          SELECT [ID]
      ,[ID_SUBPERIODO_NACIONAL]
      ,[ID_SUBPERIODO_CAMPUS]
      ,[FECHA_REGISTRO]
      ,[USUARIO_LOGIN]
      ,[ACCION]
      ,[COMENTARIOS]
  FROM [dbo].[BITACORA_SUBPERIODO_CAMPUS]
SET IDENTITY_INSERT [dbo].[Bitacora_SubPeriodoCampus] OFF
GO
SET IDENTITY_INSERT [dbo].[Bitacora_SubperiodoNacional] ON 
    INSERT INTO [dbo].[Bitacora_SubperiodoNacional]
            ([Id]
            ,[SubperiodoNacionalId]
            ,[FechaRegistro]
            ,[UsuarioLogin]
            ,[Accion]
            ,[Comentarios])
            SELECT [ID]
            ,[ID_SUBPERIODO_NACIONAL]
            ,[FECHA_REGISTRO]
            ,[USUARIO_LOGIN]
            ,[ACCION]
            ,[COMENTARIOS]
            FROM [dbo].[BITACORA_SUBPERIODO_NACIONAL]
SET IDENTITY_INSERT [dbo].[Bitacora_SubperiodoNacional] OFF
GO
SET IDENTITY_INSERT [dbo].[CalificacionesEnviadasBanner] ON 
    INSERT INTO [dbo].[CalificacionesEnviadasBanner]
           ([Id]
      ,[TERM]
      ,[CRN]
      ,[MatriculaAlumno]
      ,[PIDM]
      ,[Calificacion]
      ,[FechaAgregado]
      ,[UsuarioCalifico]
      ,[Comentarios]
      ,[SeEnvio]
      ,[Horas]
      ,[Destacado]
      ,[ComentarioDestacado])
            SELECT [ID]
      ,[TERM]
      ,[CRN]
      ,[MATRICULA_ALUMNO]
      ,[PIDEM]
      ,[CALIFICACION]
      ,[FECHA_AGREGADO]
      ,[USUARIO_CALIFICO]
      ,[COMENTARIOS]
      ,[SE_ENVIO]
      ,0
      ,0
      ,''
  FROM [dbo].[CALIFICACIONES_ENVIADAS_BANNER]
SET IDENTITY_INSERT [dbo].[CalificacionesEnviadasBanner] OFF
GO
SET IDENTITY_INSERT [dbo].[CalificacionesEnviadasConsolidado] ON 
    INSERT INTO [dbo].[CalificacionesEnviadasConsolidado]
           ([Id]
      ,[TERM]
      ,[CRN]
      ,[FechaAgregado]
      ,[UsuarioCalifico])
        SELECT [ID]
      ,[TERM]
      ,[CRN]
      ,[FECHA_AGREGADO]
      ,[USUARIO_CALIFICO]
        FROM [dbo].[CALIFICACIONES_ENVIADAS_CONSOLIDADO]
SET IDENTITY_INSERT [dbo].[CalificacionesEnviadasConsolidado] OFF
GO
SET IDENTITY_INSERT [dbo].[CalificacionesPermitidas] ON 
    INSERT INTO [dbo].[CalificacionesPermitidas]
           ([Id]
      ,[ClaveCalificacion]
      ,[Descripcion]
      ,[CalificacionAbreviada]
      ,[ClaveEjerAcadEfectivo]
      ,[ClaveEjerAcadFin]
      ,[CANVAS]
      ,[PROCESO])
           SELECT [ID]
      ,[CLAVE_CALIFICACION]
      ,''
      ,[CALIFICACION_ABREVIADA]
      ,[CLAVE_EJER_ACAD_EFECTIVO]
      ,case when [CLAVE_EJER_ACAD_FIN] is NULL then ''  else [CLAVE_EJER_ACAD_FIN] end as [CLAVE_EJER_ACAD_FIN]
      ,[CANVAS]
      ,0
  FROM [dbo].[CALIFICACIONES_PERMITIDAS]
SET IDENTITY_INSERT [dbo].[CalificacionesPermitidas] OFF
GO
SET IDENTITY_INSERT [dbo].[CatalogoBitacoras] ON 
    INSERT INTO [dbo].[CatalogoBitacoras]
           ([Id]
      ,[Nombre]
      ,[Activo]
      ,[FechaAgregado]
      ,[Comentarios])
            SELECT [ID]
      ,[NOMBRE]
      ,[ACTIVO]
      ,[FECHA_AGREGADO]
      ,[COMENTARIOS]
  FROM [dbo].[CAT_BITACORAS]
SET IDENTITY_INSERT [dbo].[CatalogoBitacoras] OFF
GO
SET IDENTITY_INSERT [dbo].[CatalogoNormativas] ON 
    INSERT INTO [dbo].[CatalogoNormativas]
           ([Id]
      ,[Nombre]
      ,[Activo]
      ,[FechaIngreso])
           SELECT [ID]
      ,[NOMBRE]
      ,[ACTIVO]
      ,[FECHA_INGRESO]
  FROM [dbo].[CATALOGO_NORMATIVAS]
SET IDENTITY_INSERT [dbo].[CatalogoNormativas] OFF
GO
SET IDENTITY_INSERT [dbo].[ExcepciondeMaterias] ON 
    INSERT INTO [dbo].[ExcepciondeMaterias]
           ([Id]
      ,[Subject]
      ,[Course]
      ,[TERM])
           SELECT [ID]
      ,[SUBJECT]
      ,[COURSE]
      ,[TERM]
  FROM [dbo].[EXCEPCION_DE_MATERIAS]
SET IDENTITY_INSERT [dbo].[ExcepciondeMaterias] OFF
GO
SET IDENTITY_INSERT [dbo].[MateriasExclusiones] ON 
    INSERT INTO [dbo].[MateriasExclusiones]
           ([Id]
      ,[Materia]
      ,[Curso]
      ,[ClaveMateria]
      ,[NombreMateria]
      ,[TERM]
      ,[Vigencia]
      ,[Activo]
	    ,[FechaAgregado])
            SELECT [ID]
      ,[MATERIA]
      ,[CURSO]
      ,[CLAVE_MATERIA]
      ,[NOMBRE_MATERIA]
      ,[GRUPO]
      ,DBO.dReturnDate(getdate())
      ,0
      ,DBO.dReturnDate(getdate())
  FROM [dbo].[MATERIAS_EXCLUSIONES]
SET IDENTITY_INSERT [dbo].[MateriasExclusiones] OFF
GO
SET IDENTITY_INSERT [dbo].[MateriasNormativas] ON 
    INSERT INTO [dbo].[MateriasNormativas]
           ([Id]
      ,[Materia]
      ,[Curso]
      ,[ClaveMateria]
      ,[NombreMateria]
      ,[TERM]
      ,[NombreNormativa]
      ,[NormativaId]
      ,[Vigencia]
	    ,[FechaAgregado]
	    ,[Activo]
      )
        SELECT [ID]
      ,[MATERIA]
      ,[CURSO]
      ,[CLAVE_MATERIA]
      ,[NOMBRE_MATERIA]
      ,[TERM]
      ,[NOMBRE_NORMATIVA]
      ,[ID_NORMATIVA]
      ,DBO.dReturnDate(getdate())
      ,DBO.dReturnDate(getdate())
      ,0
    FROM [dbo].[MATERIAS_NORMATIVAS]
SET IDENTITY_INSERT [dbo].[MateriasNormativas] OFF
GO
SET IDENTITY_INSERT [dbo].[Normativas] ON 
    INSERT INTO [dbo].[Normativas]
           ([Id]
      ,[NormativaId]
      ,[Nombre]
      ,[ClaveCal]
      ,[VigenciaDesde]
      ,[VigenciaHasta]
      ,[IntervaloDesde]
      ,[IntervaloHasta]
      ,[Descripcion]
      ,[Nota]
      ,[IndActivo],
      [FechaAgregado])
           SELECT [ID]
      ,[ID_NORMATIVA]
      ,[NOMBRE]
      ,[CLAVE_CAL]
      ,[VIGENCIA_DESDE]
      ,[VIGENCIA_HASTA]
      ,[INTERVALO_DESDE]
      ,[INTERVALO_HASTA]
      ,[DESCRIPCION]
      ,[NOTA]
      ,[IND_ACTIVO]
      ,DBO.dReturnDate(getdate())
  FROM [dbo].[NORMATIVAS_tmp]
SET IDENTITY_INSERT [dbo].[Normativas] OFF
GO
SET IDENTITY_INSERT [dbo].[SubperiodosCampus] ON 
    INSERT INTO [dbo].[SubperiodosCampus]
           ([Id]
      ,[IdSubperiodo]
      ,[Nombre]
      ,[FechaDesde]
      ,[FechaHasta]
      ,[IdCampus]
      ,[Nivel]
      ,[Idperiodo]
      ,[IdperiodoNacional]
      ,[FechaAgregado]
      ,[Activo])
            SELECT [ID]
      ,[ID_SUBPERIODO]
      ,[NOMBRE]
      ,[FECHA_DESDE]
      ,[FECHA_HASTA]
      ,[ID_CAMPUS]
      ,[NIVEL]
      ,[ID_PERIODO]
      ,[ID_PERIODO_NACIONAL]
      ,[FECHA_AGREGADO]
      ,[ACTIVO]
  FROM [dbo].[SUBPERIODOS_CAMPUS]
SET IDENTITY_INSERT [dbo].[SubperiodosCampus] OFF
GO
SET IDENTITY_INSERT [dbo].[SubperiodosNacional] ON 
    INSERT INTO [dbo].[SubperiodosNacional]
           ([Id]
      ,[SubperiodoNacionalId]
      ,[Nombre]
      ,[FechaDesde]
      ,[FechaHasta]
      ,[Nivel]
      ,[Idperiodo]
      ,[FechaAgregado]
      ,[Activo])
            SELECT [ID]
      ,[ID_SUBPERIODO_NACIONAL]
      ,[NOMBRE]
      ,[FECHA_DESDE]
      ,[FECHA_HASTA]
      ,[NIVEL]
      ,[ID_PERIODO]
      ,[FECHA_AGREGADO]
      ,[ACTIVO]
  FROM [dbo].[SUBPERIODOS_NACIONAL]
SET IDENTITY_INSERT [dbo].[SubperiodosNacional] OFF
GO
SET IDENTITY_INSERT [dbo].[Usuarios] ON 
    INSERT INTO [dbo].[Usuarios]
           ([Id]
      ,[Nomina]
      ,[Nombre]
      ,[Apellidos]
      ,[Correo]
      ,[Activo]
      ,[DTAgregado])
            SELECT [ID]
        ,[NOMINA]
        ,[NOMBRE]
        ,[APELLIDOS]
        ,[CORREO]
        ,1
        ,[DT-AGREGARO]
    FROM [dbo].[USUARIOS_tmp]
SET IDENTITY_INSERT [dbo].[Usuarios] OFF
GO
SET IDENTITY_INSERT [dbo].[Roles] ON 
    INSERT INTO [dbo].[Roles]
           ([Id]
      ,[Nombre]
      ,[Activo])
            SELECT [ID]
      ,[NOMBRE]
      ,[ACTIVO]
  FROM [dbo].[ROLES_tmp]
SET IDENTITY_INSERT [dbo].[Roles] OFF
GO

update [dbo].[ROLES-USUARIO] set [NOMINA-USUARIO]='L00285767' WHERE LEN([NOMINA-USUARIO])>9
--verificar los valores de las  tablas con foraneas porque puede generar errores en caso de incosistencia d edeatos en especial roles
If ((SELECT COUNT(Id) FROM [dbo].[ROLES-USUARIO] WHERE LEN([NOMINA-USUARIO])>9)>0)
	 PRINT N'EXISTEN NOMINAS INCORRECTAS, ESTAS NO SE COPIARAN AL NUEVO MODELO';

update [dbo].[ROLES-USUARIO] set [NOMINA-USUARIO]='L00285767' WHERE LEN([NOMINA-USUARIO])>9
SET IDENTITY_INSERT [dbo].[RolesUsuario] ON 
    INSERT INTO [dbo].[RolesUsuario]
           ([Id]
      ,[UsuariosNomina]
      ,[RolesId]
      ,[CampusId]
      ,[Activo])
        SELECT [ID]
      ,[NOMINA-USUARIO]
      ,[ROL-ID]
      ,[CAMPUS-ID]
      ,[ACTIVO]
  FROM [dbo].[ROLES-USUARIO] where LEN([NOMINA-USUARIO])=9
SET IDENTITY_INSERT [dbo].[RolesUsuario] OFF