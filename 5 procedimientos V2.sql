/****** Object:  StoredProcedure [dbo].[spAlumnosPorGrupo_ObtieneInformacion]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jonatan Flores
-- Create date: 04-09-2019
-- Description:	Procedimiento que obtiene una lista de alumnos y su calificación mediante el crn.
-- =============================================
CREATE PROCEDURE [dbo].[spAlumnosPorGrupo_ObtieneInformacion] 
	@CRN		INT,
	@TERM		VARCHAR(20)

	AS
	BEGIN
		--DECLARE @CRN INT
		--DECLARE @TERM VARCHAR(20)
		----SET @CRN = 18673
		--SET @CRN = 18088
		--SET @TERM = '201913'

		--SELECT * FROM CalificacionesEnviadasBanner

		DECLARE @GRUPOS_TEMP TABLE  
			( ID					INT IDENTITY(1,1)   NOT NULL ,  
			CRN					int NOT NULL,
			PERIODO				INT NOT NULL, 
			PIDM					INT NOT NULL, 
			MATRICULA				VARCHAR(50)  NULL);

		DECLARE @ALUMNOS_TEMP TABLE  
			( ID					INT IDENTITY(1,1)   NOT NULL ,  
			CRN					int NOT NULL,
			PIDM				INT NOT NULL, 
			MATRICULA					VARCHAR(20) NOT NULL, 
			NOMBRE				VARCHAR(200)  NULL,
			AP_PATERNO				VARCHAR(200)  NULL,
			AP_MATERNO				VARCHAR(200)  NULL);

		DECLARE @ALUMNOS_MOSTRAR TABLE  
			( ID					INT IDENTITY(1,1)   NOT NULL ,  
			CRN					int NOT NULL,
			PIDM				INT NOT NULL, 
			MATRICULA					VARCHAR(20) NOT NULL, 
			NOMBRE				VARCHAR(1000)  NULL,
			NOMINA				VARCHAR(20)		NULL,
			NOMBRE_PROFESOR		VARCHAR(1000)	NULL,	  
			CALIFICACION				VARCHAR(20)  NULL);

		DECLARE @ALUMNOS_CALIF TABLE  
			( ID					INT IDENTITY(1,1)   NOT NULL ,  
			CRN					int NOT NULL,
			PIDM				INT NOT NULL, 
			MATRICULA					VARCHAR(20) NOT NULL, 
			NOMBRE				VARCHAR(1000)  NULL,
			NOMINA				VARCHAR(20)		NULL,
			NOMBRE_PROFESOR		VARCHAR(1000)	NULL,  
			CALIFICACION				VARCHAR(20)  NULL);

		DECLARE @NOMBRE_PROFE TABLE  
			( ID					INT IDENTITY(1,1)   NOT NULL ,
				NOMINA				VARCHAR(20) NULL,  
			NOMBRE				VARCHAR(1000)  NULL);

		INSERT INTO @GRUPOS_TEMP
			SELECT CRN, PERIODO, PIDM, MATRICULA FROM Replicas.DBO.GRUPO_ALUMNOS WITH (NOLOCK) WHERE CRN = @CRN

			--select * from @GRUPOS_TEMP

		INSERT INTO @ALUMNOS_TEMP
			SELECT GT.CRN, A.PIDM, A.MATRICULA, A.NOMBRE, A.AP_PATERNO, A.AP_MATERNO
			FROM @GRUPOS_TEMP GT
			INNER JOIN Replicas.dbo.ALUMNOS A ON GT.PIDM=A.PIDM 

			--select * from @ALUMNOS_TEMP

		INSERT INTO @ALUMNOS_CALIF
			SELECT CRN, PIDM, MATRICULA, CONCAT(NOMBRE, + ' ' + AP_PATERNO,+ ' ' + AP_MATERNO)AS 'NOMBRE', '', '', '' FROM @ALUMNOS_TEMP

		--SELECT * FROM @ALUMNOS_CALIF

		INSERT INTO @ALUMNOS_MOSTRAR
			SELECT AT.CRN, AT.PIDM, AT.MATRICULA, CONCAT(AT.NOMBRE, + ' ' + AT.AP_PATERNO,+ ' ' + AT.AP_MATERNO)AS 'NOMBRE',
				CB.UsuarioCalifico, '',  CB.Calificacion
				FROM CalificacionesEnviadasBanner CB
				RIGHT JOIN @ALUMNOS_TEMP AT ON CB.CRN=AT.CRN AND CB.MatriculaAlumno=AT.MATRICULA
				WHERE CB.CRN=@CRN AND CB.TERM=@TERM	

		--select * from @ALUMNOS_MOSTRAR

		IF EXISTS(SELECT ID, CRN, PIDM, MATRICULA, NOMBRE, NOMINA, NOMBRE_PROFESOR, CALIFICACION FROM @ALUMNOS_MOSTRAR)
			BEGIN
				UPDATE 
					@ALUMNOS_CALIF
				SET
					CALIFICACION= B.CALIFICACION,
					NOMINA = B.NOMINA
				FROM
					@ALUMNOS_CALIF A
					INNER JOIN @ALUMNOS_MOSTRAR B ON A.PIDM=B.PIDM

		INSERT INTO @NOMBRE_PROFE
			SELECT NOMINA, '' FROM @ALUMNOS_CALIF WHERE NOMINA IS NOT NULL OR NOMINA != ''

			--select * from @NOMBRE_PROFE

				UPDATE 
					@ALUMNOS_CALIF
				SET
					NOMINA = B.NOMINA
				FROM
					@ALUMNOS_CALIF A
					INNER JOIN @NOMBRE_PROFE B ON A.NOMINA=B.NOMINA

				UPDATE 
					@NOMBRE_PROFE
				SET
					NOMBRE= CONCAT(B.NOMBRE, + ' '+ B.AP_PATERNO, +' '+ B.AP_MATERNO)
				FROM
					@ALUMNOS_CALIF A
					INNER JOIN Replicas.dbo.PROFESORES B ON A.NOMINA=B.NOMINA
				
				UPDATE 
						@ALUMNOS_CALIF
					SET
						NOMBRE_PROFESOR = B.NOMBRE
					FROM
						@ALUMNOS_CALIF A
						INNER JOIN @NOMBRE_PROFE B ON A.NOMINA=B.NOMINA		

					DELETE FROM @ALUMNOS_MOSTRAR
					INSERT INTO @ALUMNOS_MOSTRAR
						SELECT CRN, PIDM, MATRICULA, NOMBRE, NOMINA, NOMBRE_PROFESOR, CALIFICACION FROM @ALUMNOS_CALIF
				END	
		ELSE
			BEGIN 
				INSERT INTO @ALUMNOS_MOSTRAR
					SELECT CRN, PIDM, MATRICULA, NOMBRE, NOMINA, NOMBRE_PROFESOR, CALIFICACION FROM @ALUMNOS_CALIF
			END

		SELECT ID, CRN, PIDM, MATRICULA, NOMBRE, NOMINA, NOMBRE_PROFESOR, CALIFICACION FROM @ALUMNOS_MOSTRAR
	END
GO
/****** Object:  StoredProcedure [dbo].[spArchivoCanvas_InsertaValores]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spArchivoCanvas_InsertaValores]
	-- Add the parameters for the stored procedure here
	@PERIODO VARCHAR(50),
	@CRN VARCHAR(50),
	@PIDM_PROFESOR VARCHAR(50),
	@PIDM_ALUMNO VARCHAR(50),
	@GRADE_NUM VARCHAR(50)=NULL,
	@GRADE_ALFA VARCHAR(50)=NULL,
	@PROCESADO BIT
		
	AS
	BEGIN
		BEGIN TRY
			SET NOCOUNT ON;

			-- Insert statements for procedure here
			INSERT INTO dbo.ArchivosCanvas(Periodo, CRN, PIDMProfesor, PIDMAlumno, GradeNum, GradeAlfa, Procesado)
			VALUES(@PERIODO, @CRN, @PIDM_PROFESOR, @PIDM_ALUMNO, @GRADE_NUM, @GRADE_ALFA, @PROCESADO)
		END TRY
		BEGIN CATCH
			SELECT
				ERROR_NUMBER() AS ErrorNumber  
				,ERROR_SEVERITY() AS ErrorSeverity  
				,ERROR_STATE() AS ErrorState  
				,ERROR_PROCEDURE() AS ErrorProcedure  
				,ERROR_LINE() AS ErrorLine  
				,ERROR_MESSAGE() AS ErrorMessage; 
		END CATCH
	END
GO
/****** Object:  StoredProcedure [dbo].[spArchivosCanvas_CargarValores]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spArchivosCanvas_CargarValores]
	-- Add the parameters for the stored procedure here
	@PERIODO				VARCHAR(50),
	@CRN					VARCHAR(50),
	@PIDM_PROFESOR			VARCHAR(50),
	@PIDM_ALUMNO			VARCHAR(50),
	@GRADE_NUM				VARCHAR(50)=NULL,
	@GRADE_ALFA				VARCHAR(50)=NULL,
	@PROCESADO				BIT,
	@HORAS					INT,
	@DESTACADO				BIT,
	@COMENTARIODESTACADO	VARCHAR(6000),
	@ACCION INT
	
	AS
	BEGIN
		BEGIN TRY
			-- SET NOCOUNT ON added to prevent extra result sets from
			-- interfering with SELECT statements.
			SET NOCOUNT ON;
			DECLARE @RES_EXISTE		INT
			-- INSERTA LOS DATOS EN ArchivosCanvas
			IF @ACCION = 1
				BEGIN	
					SET @RES_EXISTE  = (SELECT Id FROM dbo.ArchivosCanvas 
										WHERE Periodo=@PERIODO AND CRN=@CRN AND PIDMAlumno=@PIDM_ALUMNO)
					IF @RES_EXISTE is null
						BEGIN
							INSERT INTO dbo.ArchivosCanvas
							(Periodo, CRN, PIDMProfesor, PIDMAlumno, GradeNum, GradeAlfa, Procesado, Horas, Destacado, ComentarioDestacado)
							VALUES(@PERIODO, @CRN, @PIDM_PROFESOR, @PIDM_ALUMNO, @GRADE_NUM, @GRADE_ALFA, @PROCESADO, @HORAS, @DESTACADO, @COMENTARIODESTACADO)
						END
					ELSE
						BEGIN
							DELETE FROM dbo.ArchivosCanvas WHERE Id = @RES_EXISTE
							INSERT INTO dbo.ArchivosCanvas
							(Periodo, CRN, PIDMProfesor, PIDMAlumno, GradeNum, GradeAlfa, Procesado, Horas, Destacado, ComentarioDestacado)
							VALUES(@PERIODO, @CRN, @PIDM_PROFESOR, @PIDM_ALUMNO, @GRADE_NUM, @GRADE_ALFA, @PROCESADO, @HORAS, @DESTACADO, @COMENTARIODESTACADO) 
						END
					
				END

			EXEC DBO.spBitacoras_RegistraBitacora 9, @PERIODO, @CRN, @PIDM_PROFESOR, NULL, NULL, NULL,@PIDM_ALUMNO,'FLUJO','PROCESO AUTOMATICO', NULL, NULL, NULL,'Proceso Automatico agregando a tabla Archivo canvas cada alumno' 
		END TRY
		BEGIN CATCH
			SELECT
				ERROR_NUMBER() AS ErrorNumber  
				,ERROR_SEVERITY() AS ErrorSeverity  
				,ERROR_STATE() AS ErrorState  
				,ERROR_PROCEDURE() AS ErrorProcedure  
				,ERROR_LINE() AS ErrorLine  
				,ERROR_MESSAGE() AS ErrorMessage; 
			EXEC DBO.spBitacoras_RegistraBitacora 9, @PERIODO, @CRN, @PIDM_PROFESOR, NULL, NULL, NULL,@PIDM_ALUMNO,'FLUJO','PROCESO AUTOMATICO', NULL, NULL, NULL,'Error en proceso Automatico al agregar a tabla Archivo canvas cada alumno' 
		END CATCH
	END
GO
/****** Object:  StoredProcedure [dbo].[spArchivosCanvasFiltrado_CargarValores]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alejandro Cervantes
-- Create date: 06-07-2019
-- Description:	GENERA EL LLENADO DE LA TABLA VALORES_ArchivosCanvasFiltrado CON LOS VALORES FILTRADOS DE CANVAS PARA ENVIAR A BANNER
-- =============================================
CREATE PROCEDURE [dbo].[spArchivosCanvasFiltrado_CargarValores]
	@TERM		VARCHAR(20)=NULL,
	@CRN		INT	= NULL,
	@ACCION		INT	
	AS
	BEGIN
		DECLARE @RES_EX		VARCHAR(20)	
		SET NOCOUNT ON;

		IF @ACCION=1
			BEGIN
				SET @RES_EX = (SELECT COUNT(GA.CRN)	 
						FROM [Replicas].[dbo].[GRUPO_ALUMNOS] GA
						INNER JOIN dbo.ArchivosCanvas AC 
							ON GA.PERIODO=AC.Periodo AND GA.CRN = AC.CRN AND GA.PIDM = AC.PIDMAlumno 
						WHERE AC.Procesado = 0)

				IF @RES_EX > 0
					BEGIN
						INSERT INTO DBO.ArchivosCanvasFiltrado
							SELECT GA.PERIODO, GA.CRN, AC.PIDMProfesor, AC.PIDMAlumno, AC.GradeNum, AC.GradeAlfa, AC.Procesado,
							AC.Horas, AC.Destacado, AC.ComentarioDestacado	 
								FROM [Replicas].[dbo].[GRUPO_ALUMNOS] GA
								INNER JOIN dbo.ArchivosCanvas AC 
									ON GA.PERIODO=AC.Periodo AND GA.CRN = AC.CRN AND GA.PIDM = AC.PIDMAlumno 
								WHERE AC.Procesado = 0

						
						EXEC DBO.spBitacoras_RegistraBitacora 9, @TERM, @CRN, 0, NULL,NULL,NULL,0,'FLUJO','PROCESO AUTOMATICO', NULL,NULL,NULL,'Archivo filtrados y agregados a tabla de archivos filtrados'				
					END
				ELSE
					BEGIN
						
						EXEC DBO.spBitacoras_RegistraBitacora 9, @TERM, @CRN, 0, NULL,NULL,NULL,0,'ERROR','PROCESO AUTOMATICO', NULL,NULL,NULL,'No existen los alumnos en los grupos de banner' 	 	
					END
				
			
			END	
		IF @ACCION = 2
			BEGIN
				SET @RES_EX = (SELECT COUNT(GA.CRN)	 
								FROM [Replicas].[dbo].[GRUPO_ALUMNOS] GA
								INNER JOIN dbo.ArchivosCanvas AC 
									ON GA.PERIODO=AC.Periodo AND GA.CRN = AC.CRN AND GA.PIDM = AC.PIDMAlumno 
								WHERE AC.Periodo=@TERM AND AC.CRN=@CRN AND AC.Procesado = 0)

				IF @RES_EX > 0
					BEGIN
						INSERT INTO DBO.ArchivosCanvasFiltrado
							SELECT GA.PERIODO, GA.CRN, AC.PIDMProfesor, AC.PIDMAlumno, AC.GradeNum, AC.GradeAlfa, AC.Procesado,
							AC.Horas, AC.Destacado, AC.ComentarioDestacado	 
								FROM [Replicas].[dbo].[GRUPO_ALUMNOS] GA
								INNER JOIN dbo.ArchivosCanvas AC 
									ON GA.PERIODO=AC.Periodo AND GA.CRN = AC.CRN AND GA.PIDM = AC.PIDMAlumno 
								WHERE AC.Periodo=@TERM AND AC.CRN=@CRN AND AC.Procesado = 0

						
						EXEC DBO.spBitacoras_RegistraBitacora 9, @TERM, @CRN, 0, NULL,NULL,NULL,0,'FLUJO','PROCESO AUTOMATICO', NULL,NULL,NULL,'Alumnos filtrados y agregados a tabla de ArchivosCanvasFiltrado' 	
						
					END
				ELSE
					BEGIN
						EXEC DBO.spBitacoras_RegistraBitacora 9, @TERM, @CRN, 0, NULL,NULL,NULL,0,'ERROR','PROCESO AUTOMATICO', NULL,NULL,NULL,'No existen los alumnos en los grupos de banner' 	
					END
			END

		DELETE DBO.ArchivosCanvas WHERE (Periodo = @TERM AND CRN = @CRN)
	END
GO
/****** Object:  StoredProcedure [dbo].[spBD_ProbarConexion]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ALEJANDRO CERVANTES
-- Create date: 06-07-2019
-- Description:	PROBAR CONEXION CON BASE DE DATOS
-- =============================================
CREATE PROCEDURE [dbo].[spBD_ProbarConexion]
	-- Add the parameters for the stored procedure here
	AS
	BEGIN
		SET NOCOUNT ON;
		SELECT 'SI HAY CONEXION CON LA BASE DE DATOS' AS MENSAJE
	END
GO
/****** Object:  StoredProcedure [dbo].[spBitacoras_RegistraBitacora]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ALEJANDRO CERVANTES
-- Create date: 06-07-2019
-- Description:	DA DE ALTA TODAS LAS ACTIVIDADES DE LAS TABLAS DE  BITACORAS PARA CADA PROCESO
-- =============================================
CREATE PROCEDURE [dbo].[spBitacoras_RegistraBitacora]
	@BANDERA			INT,
	@TERM				VARCHAR(20)=NULL,
	@CRN				INT=NULL,
	@NOMINA_PROFESOR	VARCHAR(50)=NULL,
	@ID_SUBPERIODO_NACIONAL		VARCHAR(100)=NULL,
	@ID_SUBPERIODO_CAMPUS		VARCHAR(100)=NULL,
	@ID_UsuarioLogin	VARCHAR(100)=NULL,--
	@MATRICULA_ALUMNO	VARCHAR(200)=NULL,
	@ACCION				VARCHAR(4000),--
	@COMENTARIOS		VARCHAR(8000)=NULL,--
	@ID_NORMATIVA		INT=NULL,
	@SUBJECT			VARCHAR(20)=NULL,
	@COURSE				VARCHAR(20)=NULL,
	@MensajeError		VARCHAR(8000)=NULL

	AS
	BEGIN
		SET NOCOUNT ON;

		IF @BANDERA = 1
			BEGIN
				INSERT INTO DBO.Bitacora_SubperiodoNacional
					(SubperiodoNacionalId, UsuarioLogin, Accion, Comentarios)
				VALUES(@ID_SUBPERIODO_NACIONAL,@ID_UsuarioLogin, @ACCION, @COMENTARIOS)
			END
		IF @BANDERA = 2
			BEGIN
				INSERT INTO DBO.Bitacora_SubPeriodoCampus
					(SubperiodoNacionalId, SubperiodoCampusId, UsuarioLogin, Accion, Comentarios)
				VALUES(@ID_SUBPERIODO_NACIONAL,@ID_SUBPERIODO_CAMPUS, @ID_UsuarioLogin, @ACCION, @COMENTARIOS)
			END
		IF @BANDERA = 3
			BEGIN
				INSERT INTO DBO.Bitacora_Normativas
					(NormativaId, Accion, UsuarioLogin,  Comentarios)
				VALUES(@ID_NORMATIVA,@ACCION, @ID_UsuarioLogin, @COMENTARIOS)
				
			END

		IF @BANDERA = 4
			BEGIN
				INSERT INTO DBO.Bitacora_RolesAdmin
					(Accion, UsuarioLogin, Comentarios)
				VALUES(@ACCION, @ID_UsuarioLogin,  @COMENTARIOS)
			END

		IF @BANDERA = 5
			BEGIN
				INSERT INTO DBO.Bitacora_MateriasNormativa
					([Subject], Course, NormativaId, Accion,UsuarioLogin, Comentarios)
				VALUES(@SUBJECT, @COURSE, @ID_NORMATIVA, @ACCION, @ID_UsuarioLogin, @COMENTARIOS)
			END

		IF @BANDERA = 6
			BEGIN
				INSERT INTO DBO.Bitacora_MateriasExcepcion
					([Subject], Course, Accion,UsuarioLogin, Comentarios)
				VALUES(@SUBJECT, @COURSE, @ACCION, @ID_UsuarioLogin, @COMENTARIOS)
				--VALUES('WKAB', '1002S', 'ELIMINAR Materia CON EXCEPCION', 1, 'Se ha eliminado materia con excepciones.')
			END

		IF @BANDERA = 7
			BEGIN
				INSERT INTO DBO.Bitacora_GeneracionReportes
					(Accion, UsuarioLogin, Comentarios)
				VALUES(@ACCION, @ID_UsuarioLogin,  @COMENTARIOS)
			END

		IF @BANDERA = 8
			BEGIN
				INSERT INTO DBO.Bitacora_CargaCalificiones
					(CRN, Accion, UsuarioLogin, Comentarios)
				VALUES(@CRN, @ACCION, @ID_UsuarioLogin,  @COMENTARIOS)
			END

		IF @BANDERA = 9
			BEGIN
				INSERT INTO DBO.Bitacora_ProcesoAutomatico
					(TERM, CRN, MatriculaProfesor, MatriculaAlumno, Accion, MensajeError, Comentarios)
				VALUES(@TERM, @CRN, @NOMINA_PROFESOR, @MATRICULA_ALUMNO, @ACCION, @MensajeError,  @COMENTARIOS)
			END
		IF @BANDERA = 10
			BEGIN
				INSERT INTO DBO.Bitacora_ProcesoSC
					(TERM,CRN,SubPeriodoId,ClaveCampus,Accion,MensajeError,Comentarios)
				VALUES(@TERM, @CRN, @ID_SUBPERIODO_CAMPUS, @COURSE, @ACCION, @MensajeError,  @COMENTARIOS)
			END

	END


GO
/****** Object:  StoredProcedure [dbo].[spCalificacionesEnExcepcion_Revisar]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spCalificacionesEnExcepcion_Revisar]
	-- Add the parameters for the stored procedure here
	@TERM		VARCHAR(20),
	@CRN		INT
	AS
	BEGIN
		BEGIN TRY
			SET NOCOUNT ON;
			
			DECLARE @ARCHIVO_C_FIL TABLE  
				( Id					INT IDENTITY(1,1)   NOT NULL ,	
				ID_AC					INT NOT NULL,		 
				TERM					VARCHAR(20) NOT NULL,
				CRN					VARCHAR(20) NOT NULL,
				PIDMProfesor			INT NOT NULL,
				PIDMAlumno			INT NOT NULL,
				GradeNum				VARCHAR(20) NOT NULL,
				GradeAlfa			VARCHAR(20) NULL,
				Procesado				BIT NOT NULL);

			DECLARE @ARCHIVO_C_FIL_A_BAN TABLE  
				( Id					INT IDENTITY(1,1)   NOT NULL ,	
				ID_ACB				INT NOT NULL,		 
				TERM					VARCHAR(20) NOT NULL,
				CRN					VARCHAR(20) NOT NULL,
				PIDMProfesor			INT NOT NULL,
				PIDMAlumno			INT NOT NULL,
				GradeNum				VARCHAR(20) NOT NULL,
				GradeAlfa			VARCHAR(20) NULL,
				Procesado				BIT NOT NULL);

			DECLARE @ARCHIVO_C_FIL_A_BAN2 TABLE  
				( Id					INT IDENTITY(1,1)   NOT NULL ,	
				ID_ACB				INT NOT NULL,		 
				TERM					VARCHAR(20) NOT NULL,
				CRN					VARCHAR(20) NOT NULL,
				PIDMProfesor			INT NOT NULL,
				PIDMAlumno			INT NOT NULL,
				GradeNum				VARCHAR(20) NOT NULL,
				GradeAlfa			VARCHAR(20) NULL,
				ISNUMERICO			INT NULL,
				Procesado				BIT NOT NULL);

			DECLARE @ARCHIVO_C_FIL_A_BAN3 TABLE  
				( Id					INT IDENTITY(1,1)   NOT NULL ,	
				ID_ACB				INT NOT NULL,		 
				TERM					VARCHAR(20) NOT NULL,
				CRN					VARCHAR(20) NOT NULL,
				PIDMProfesor			INT NOT NULL,
				PIDMAlumno			INT NOT NULL,
				GradeNum				VARCHAR(20) NOT NULL,
				GradeAlfa			VARCHAR(20) NULL,
				Procesado				BIT NOT NULL);

			DECLARE @ARCHIVO_C_FIL_A_BAN4 TABLE  
				( Id					INT IDENTITY(1,1)   NOT NULL ,	
				ID_ACB				INT NOT NULL,	
				ID_CP					INT NULL,	 
				GradeAlfa			VARCHAR(20) NULL);

		
			INSERT INTO @ARCHIVO_C_FIL
				SELECT Id,Periodo,CRN,PIDMProfesor,PIDMAlumno, 
				IIF (GradeNum IS NULL OR GradeNum= '', '0', GradeNum) AS GradeNum, 
				IIF (GradeAlfa IS NULL OR GradeAlfa = '', GradeNum, GradeAlfa) AS GradeAlfa, 
				Procesado
				FROM DBO.ArchivosCanvasFiltrado
				WHERE (Periodo=@TERM AND CRN=@CRN)

			INSERT INTO @ARCHIVO_C_FIL_A_BAN
				SELECT ID_AC,TERM,CRN,PIDMProfesor,PIDMAlumno, 
				GradeNum, 
				IIF (GradeAlfa IS NULL OR GradeAlfa = '', 'SC', GradeAlfa) AS GradeAlfa, 
				Procesado
				FROM @ARCHIVO_C_FIL

			INSERT INTO @ARCHIVO_C_FIL_A_BAN2
				SELECT ID_ACB,TERM,CRN,PIDMProfesor,PIDMAlumno, 
				GradeNum, 
				GradeAlfa,
				ISNUMERIC(GradeAlfa), 
				Procesado
				FROM @ARCHIVO_C_FIL_A_BAN

			INSERT INTO @ARCHIVO_C_FIL_A_BAN3
				SELECT ID_ACB,TERM,CRN,PIDMProfesor,PIDMAlumno, 
				GradeNum, 
				GradeAlfa,
				Procesado
				FROM @ARCHIVO_C_FIL_A_BAN2
				WHERE ISNUMERICO=0

			INSERT INTO @ARCHIVO_C_FIL_A_BAN4
				SELECT ACF3.ID_ACB, CP.Id, ACF3.GradeAlfa 
					FROM @ARCHIVO_C_FIL_A_BAN3 ACF3
					LEFT JOIN DBO.CalificacionesPermitidas CP ON ACF3.GradeAlfa=CP.ClaveCalificacion
				WHERE CP.Id IS NULL

			UPDATE @ARCHIVO_C_FIL_A_BAN
				SET
					GradeNum='SC',
					GradeAlfa='SC'
				FROM
				@ARCHIVO_C_FIL_A_BAN B
				INNER JOIN @ARCHIVO_C_FIL_A_BAN4 B4 ON B.ID_ACB=B4.ID_ACB
			WHERE B.TERM=@TERM AND B.CRN=@CRN

			UPDATE DBO.ArchivosCanvasFiltrado 
				SET
					GradeNum=ACFB.GradeNum,
					GradeAlfa=ACFB.GradeAlfa
				FROM
					DBO.ArchivosCanvasFiltrado ACF
					INNER JOIN @ARCHIVO_C_FIL_A_BAN ACFB
						ON ACF.Id=ACFB.ID_ACB
				WHERE ACF.Periodo=@TERM AND ACF.CRN=@CRN
		END TRY
		BEGIN CATCH
			SELECT
				ERROR_NUMBER() AS ErrorNumber  
				,ERROR_SEVERITY() AS ErrorSeverity  
				,ERROR_STATE() AS ErrorState  
				,ERROR_PROCEDURE() AS ErrorProcedure  
				,ERROR_LINE() AS ErrorLine  
				,ERROR_MESSAGE() AS ErrorMessage; 
		END CATCH
		
	END--END FINAL
GO
/****** Object:  StoredProcedure [dbo].[spCalificacionesEnviadasBanner_ActualizaEstatus]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spCalificacionesEnviadasBanner_ActualizaEstatus] 
	@TERM		VARCHAR(20),
	@CRN		INT
	
	AS
	
	BEGIN
		BEGIN TRY
			SET NOCOUNT ON;
			UPDATE DBO.CalificacionesEnviadasBanner
			SET SeEnvio = 1
			WHERE (TERM = @TERM AND CRN = @CRN)
		END TRY
		BEGIN CATCH
			SELECT
				ERROR_NUMBER() AS ErrorNumber  
				,ERROR_SEVERITY() AS ErrorSeverity  
				,ERROR_STATE() AS ErrorState  
				,ERROR_PROCEDURE() AS ErrorProcedure  
				,ERROR_LINE() AS ErrorLine  
				,ERROR_MESSAGE() AS ErrorMessage; 
		END CATCH
	END
GO
/****** Object:  StoredProcedure [dbo].[spCanvas_ValidarGrupos]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		ALEJANDRO CERVANTES
-- Create date: 01/06/2019
-- Description:	TRAE LA INFORMACION DEL SISTEMA DE CALIFICACIONES Y TABLAS DE INTEGRACIONES PARA CANVAS. 
-- =============================================
CREATE PROCEDURE [dbo].[spCanvas_ValidarGrupos] 
	-- Add the parameters for the stored procedure here
	@TERM	VARCHAR(10),
	@CRN	VARCHAR(10)
	AS
	BEGIN --begin first
		BEGIN TRY --try
			-- SET NOCOUNT ON added to prevent extra result sets from
			-- interfering with SELECT statements.
			SET NOCOUNT ON;
			DECLARE @CONTADOR_GRUPOS_ENVIADOS INT
			DECLARE @MENSAJE_SALIDA VARCHAR(255)
			DECLARE	@RES_LISTA_EXC		INT
			DECLARE @RES_SEM_6Y12		INT
			DECLARE @RES_COURSE			VARCHAR(10)
			DECLARE @RES_SUBJECT		VARCHAR(10)
			DECLARE @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC VARCHAR(10) 
			DECLARE @REGISTRO_CalificacionesPermitidas VARCHAR(3000)
			DECLARE @REGISTRO_CalificacionesSemanaTec VARCHAR(3000)
			DECLARE @Periodo_de_grupo			VARCHAR(20)
			DECLARE @RES_SUBPeriodo_ACTIVO		INT
			DECLARE @FechaInicio		DATETIME
			DECLARE @FechaFin			DATETIME
			DECLARE @IdCampus			VARCHAR(10)
			DECLARE @PeriodoLargo		VARCHAR(20)
			DECLARE @IS_VALID_PMT6		INT

			--Traemos datos de fecha de inicio y fin del subperiodo por el campus
			SET @IdCampus = (SELECT CAMPUS FROM Replicas.dbo.GRUPOS WHERE TERM = @TERM AND CRN = @CRN);
			SET @PeriodoLargo = dbo.vCReturnSubPeriodo(@TERM, @CRN, 1)
			SET @FechaInicio = (SELECT FechaDesde FROM SubperiodosCampus WHERE IdSubperiodo = @PeriodoLargo AND IdCampus = @IdCampus)
			SET @FechaFin = (SELECT FechaHasta FROM SubperiodosCampus WHERE IdSubperiodo = @PeriodoLargo AND IdCampus = @IdCampus)
			--IF 1
			IF EXISTS (SELECT TOP(1) TERM,CRN, FechaAgregado FROM CalificacionesEnviadasBanner
				WHERE TERM=@TERM AND CRN=@CRN ORDER BY FechaAgregado ASC)
				BEGIN--1
				--Grupo Enviado devolvemos 1
					SET @MENSAJE_SALIDA = '1'
					SELECT @MENSAJE_SALIDA AS 'MENSAJE'
					RETURN
				END--1
			--ELSE 1
			ELSE
				BEGIN--1
					SET @Periodo_de_grupo = dbo.vCReturnSubPeriodo(@TERM, @CRN, 2)
					--IF 2
					IF @Periodo_de_grupo = '' OR @Periodo_de_grupo is null
						BEGIN--2
						--Si no existe subperiodo campus dado de alta para ese grupo devolvemos 4
							SET @MENSAJE_SALIDA = '4'
							SELECT @MENSAJE_SALIDA AS 'MENSAJE'
							RETURN
						END--2
					--ELSE 2
					ELSE
						BEGIN--2
							--COMPARAMOS EL PERIODO PARA SABER SI NOS ENCONTRAMOS DENTRO DEL SUBPERIODO CAMPUS
							--EJECUTO STORED PARA SABER SI SE ENCUENTRA EL SUBPeriodo Activo O NO
							EXEC @RES_SUBPeriodo_ACTIVO=dbo.spPeriodo_TraerPeriodoActivo @TERM, @CRN
							SET @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC = dbo.vCReturnSubPeriodo(@TERM, @CRN, 2);
							--IF 3
							IF @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC = 'PMT7' OR @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC = 'PMT8' OR @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC = 'PMT9'
								BEGIN
									SET @REGISTRO_CalificacionesSemanaTec = (SELECT STUFF(
									(SELECT ',' + (ISNULL([ClaveCal]+'-'+CONVERT(VARCHAR(10), [IntervaloDesde])+'-'+CONVERT(VARCHAR(10), [IntervaloHasta]), 'NULL') )		
									FROM [dbo].[Normativas]
									WHERE IndActivo = 1 FOR XML PATH('')),1,1, '') AS CalificacionesPermitidas)
								END
							--IF 5
							IF @RES_SUBPeriodo_ACTIVO = 1
								BEGIN--5
								--Periodo se encuentra activo
								--IF 6
									IF (@ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC = 'PMT1')
										OR (@ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC = 'PMT2')
										OR (@ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC = 'PMT3')
										OR (@ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC = 'PMT4')
										OR (@ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC = 'PMT5')
										OR (@ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC = 'PMT7')
										OR (@ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC = 'PMT8')
										BEGIN--6
											--VOY A REVISAR QUE NO SE ENCUENTREN LAS MATERIAS DENTRO DE LA TABLA EXCEPCION
											IF EXISTS(SELECT G.CAMPUS, G.TERM, G.CRN, G.[Subject], G.Course FROM --6.1
													REPLICAS.DBO.GRUPOS G
													RIGHT JOIN dbo.MateriasExclusiones EM 
													ON G.TERM=EM.TERM AND G.[Subject]=EM.Materia AND G.Course=EM.Curso
													WHERE G.TERM=@TERM and G.CRN=@CRN and EM.Activo=1)
												BEGIN--6.1
													--SI EXISTE EN LA TABLA DE EXCEPCION DE MATERIAS DEVUELVO UN MENSAJE DE NO DISPONIBLE 2
													SET @MENSAJE_SALIDA = '2'
													SELECT @MENSAJE_SALIDA AS 'MENSAJE'
													RETURN
												END--6.1
											ELSE --6.1
												BEGIN --6.1
													SET @REGISTRO_CalificacionesPermitidas = (SELECT STUFF(
													(SELECT ',' + (ISNULL([ClaveCalificacion]+'-'+[CalificacionAbreviada], 'NULL') )		
													FROM [dbo].[CalificacionesPermitidas]
													WHERE CANVAS = 1 FOR XML PATH('')),1,1, '') AS CalificacionesPermitidas)

													IF EXISTS(SELECT '3' AS MENSAJE, CL, A, AI, CA, @REGISTRO_CalificacionesPermitidas AS 'CALIFICACIONES PERMITIDAS', --6.1.1
															@FechaInicio AS 'FechaInicio', @FechaFin AS 'FechaFin',
															@REGISTRO_CalificacionesSemanaTec AS 'NormativaSemanaTEC'
															FROM REPLICAS.DBO.MATERIAS_ATRIBUTOS MA
															INNER JOIN REPLICAS.DBO.GRUPOS G ON MA.Subject=G.Subject AND MA.Course = G.Course
															WHERE G.TERM = @TERM AND G.CRN=@CRN)
														BEGIN--6.1.1
															SELECT '3' AS MENSAJE, CL, A, AI, CA, @REGISTRO_CalificacionesPermitidas AS 'CALIFICACIONES PERMITIDAS',
															@FechaInicio AS 'FechaInicio', @FechaFin AS 'FechaFin',
															@REGISTRO_CalificacionesSemanaTec AS 'NormativaSemanaTEC'
																FROM REPLICAS.DBO.MATERIAS_ATRIBUTOS MA
																INNER JOIN REPLICAS.DBO.GRUPOS G ON MA.Subject=G.Subject AND MA.Course = G.Course
															WHERE G.TERM = @TERM AND G.CRN=@CRN
															RETURN
														END--6.1.1
													ELSE--6.1.1
														BEGIN--6.1.1
															SET @MENSAJE_SALIDA = '4'
															SELECT @MENSAJE_SALIDA AS 'MENSAJE'
															RETURN
														END--6.1.1

												END --6.1										
										END--6
									--A los periodos restantes se les muestran las calificaciones en directo.
									ELSE --6
										BEGIN--6
											SET @REGISTRO_CalificacionesPermitidas = (SELECT STUFF(
												(SELECT ',' + (ISNULL([ClaveCalificacion]+'-'+[CalificacionAbreviada], 'NULL') )		
												FROM [dbo].[CalificacionesPermitidas]
												WHERE CANVAS = 1 FOR XML PATH('')),1,1, '') AS CalificacionesPermitidas)

											IF EXISTS(SELECT '3' AS MENSAJE, CL, A, AI, CA, @REGISTRO_CalificacionesPermitidas AS 'CALIFICACIONES PERMITIDAS', --6.2
													@FechaInicio AS 'FechaInicio', @FechaFin AS 'FechaFin',
													@REGISTRO_CalificacionesSemanaTec AS 'NormativaSemanaTEC'
													FROM REPLICAS.DBO.MATERIAS_ATRIBUTOS MA
													INNER JOIN REPLICAS.DBO.GRUPOS G ON MA.Subject=G.Subject AND MA.Course = G.Course
													WHERE G.TERM = @TERM AND G.CRN=@CRN)
												BEGIN--6.2
													SELECT '3' AS MENSAJE, CL, A, AI, CA, @REGISTRO_CalificacionesPermitidas AS 'CALIFICACIONES PERMITIDAS',
													@FechaInicio AS 'FechaInicio', @FechaFin AS 'FechaFin',
													@REGISTRO_CalificacionesSemanaTec AS 'NormativaSemanaTEC'
														FROM REPLICAS.DBO.MATERIAS_ATRIBUTOS MA
														INNER JOIN REPLICAS.DBO.GRUPOS G ON MA.Subject=G.Subject AND MA.Course = G.Course
													WHERE G.TERM = @TERM AND G.CRN=@CRN
													RETURN
												END--6.2
											ELSE--6.2
												BEGIN--6.2
													SET @MENSAJE_SALIDA = '4'
													SELECT @MENSAJE_SALIDA AS 'MENSAJE'
													RETURN
												END--6.2	
										END--6
								END--5
							--ELSE 5 Caso que no se encuentre en el periodo pero se analiza si es PMT6
							ELSE
								BEGIN--5
									SET @IS_VALID_PMT6 = dbo.intReturnPMT6yMateriaExcepcionValida(@TERM, @CRN);
									IF @IS_VALID_PMT6 = 1 --5.1
										BEGIN--5.1
											SET @REGISTRO_CalificacionesPermitidas = (SELECT STUFF(
												(SELECT ',' + (ISNULL([ClaveCalificacion]+'-'+[CalificacionAbreviada], 'NULL') )		
												FROM [dbo].[CalificacionesPermitidas]
												WHERE CANVAS = 1 FOR XML PATH('')),1,1, '') AS CalificacionesPermitidas)

											IF EXISTS(SELECT '3' AS MENSAJE, CL, A, AI, CA, @REGISTRO_CalificacionesPermitidas AS 'CALIFICACIONES PERMITIDAS',--5.1.1
													@FechaInicio AS 'FechaInicio', @FechaFin AS 'FechaFin',
													@REGISTRO_CalificacionesSemanaTec AS 'NormativaSemanaTEC'
													FROM REPLICAS.DBO.MATERIAS_ATRIBUTOS MA
													INNER JOIN REPLICAS.DBO.GRUPOS G ON MA.Subject=G.Subject AND MA.Course = G.Course
													WHERE G.TERM = @TERM AND G.CRN=@CRN)
												BEGIN--5.1.1
													SELECT '3' AS MENSAJE, CL, A, AI, CA, @REGISTRO_CalificacionesPermitidas AS 'CALIFICACIONES PERMITIDAS',
													@FechaInicio AS 'FechaInicio', @FechaFin AS 'FechaFin',
													@REGISTRO_CalificacionesSemanaTec AS 'NormativaSemanaTEC'
														FROM REPLICAS.DBO.MATERIAS_ATRIBUTOS MA
														INNER JOIN REPLICAS.DBO.GRUPOS G ON MA.Subject=G.Subject AND MA.Course = G.Course
													WHERE G.TERM = @TERM AND G.CRN=@CRN
													RETURN
												END--5.1.1
											ELSE --5.1.1
												BEGIN --5.1.1
													SET @MENSAJE_SALIDA = '4'
													SELECT @MENSAJE_SALIDA AS 'MENSAJE'
													RETURN
												END --5.1.1
										END--5.1
									
									ELSE --DE NO ENCONTRARSE DENTRO DE LOS PERIODOS DEBE HABER RESPUESTA DE 2, ELSE 5.1
										BEGIN --5.1
											SET @MENSAJE_SALIDA = '2'
											SELECT @MENSAJE_SALIDA AS 'MENSAJE'
											RETURN	
										END--5.1
								END--5
						END--2
				END--1
	END TRY --try
		BEGIN CATCH
			SELECT
				ERROR_NUMBER() AS ErrorNumber  
				,ERROR_SEVERITY() AS ErrorSeverity  
				,ERROR_STATE() AS ErrorState  
				,ERROR_PROCEDURE() AS ErrorProcedure  
				,ERROR_LINE() AS ErrorLine  
				,ERROR_MESSAGE() AS ErrorMessage; 
		END CATCH
END	--begin first	
GO
/****** Object:  StoredProcedure [dbo].[spConsulta_ConsultarMateriasPorAlumno]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Jonatán Flores
-- Create date: 18-09-2019
-- Description:	Procedimiento que obtiene por matricula de alumno los grupos materias y todo información relacionada con ello.
-- =============================================
CREATE PROCEDURE [dbo].[spConsulta_ConsultarMateriasPorAlumno] 
	-- Add the parameters for the stored procedure here
	@MATRICULA		VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SELECT 
	g.CRN, 
	g.MATERIA, 
	m.NOMBRE, 
	p.NOMINA,
		CONCAT(p.NOMBRE, + ' ' + p.AP_PATERNO,+ ' ' + p.AP_MATERNO) AS 'PROFESOR',
		CONCAT(Q.NOMBRE, + ' ' + Q.AP_PATERNO,+ ' ' + Q.AP_MATERNO) AS 'PROFESOR_CALIFICO',
	ceb.Calificacion, 
	ceb.USUARIOCALIFICO, ceb.FECHAAGREGADO, g.TERM 
	,(select [dbo].[vCReturnSubPeriodo](g.TERM,g.CRN,1)) as 'SUBPERIODO'
	FROM [Replicas].[dbo].[ALUMNOS] a
	INNER JOIN [Replicas].[dbo].[GRUPO_ALUMNOS] ga ON a.MATRICULA = ga.MATRICULA
	INNER JOIN [Replicas].[dbo].[GRUPOS] g ON ga.CRN = g.CRN
	INNER JOIN [Replicas].[dbo].[MATERIAS] m ON g.COURSE = m.COURSE AND g.SUBJECT = m.SUBJECT
	LEFT JOIN [Replicas].[dbo].[NOMINA_GRUPO] ng ON ng.CRN = g.CRN
	LEFT JOIN [Replicas].[dbo].[PROFESORES] p ON p.NOMINA = ng.NOMINA
	LEFT JOIN CalificacionesEnviadasBanner ceb ON ceb.MatriculaAlumno = a.MATRICULA AND ceb.CRN = g.CRN
	LEFT JOIN [Replicas].[dbo].[PROFESORES] Q ON Q.NOMINA = ceb.UsuarioCalifico
	WHERE a.MATRICULA = @MATRICULA
    -- Insert statements for procedure here
	-- SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
END
GO
/****** Object:  StoredProcedure [dbo].[spCorreo_EnviaCorreos]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ALEJANDRO CERVANTES
-- Create date: 06-07-2019		
-- Description:	ENVIA CorreoS
-- =============================================
CREATE PROCEDURE [dbo].[spCorreo_EnviaCorreos]
	@CORREO		VARCHAR(50),
	@MENSAJE	VARCHAR(8000),
	@PERIODO	VARCHAR(50),
	@CRN		VARCHAR(50),
	@NOMINA		VARCHAR(20),
	@LOGIN		varchar(50)

	AS
	BEGIN
		DECLARE @salida INT;
		DECLARE @mailId INT;
		DECLARE @mensajeError VARCHAR(1500);
		SET NOCOUNT ON;
		EXEC @salida = msdb.dbo.sp_send_dbmail  
		@profile_name = 'CorreosCalificaciones',  
		@recipients = @CORREO,  
		@body = @MENSAJE,  
		@SUBJECT = 'Sistema de Calificaciones TEC',
		@mailitem_id = @mailId OUTPUT;

		SET @mensajeError = @@ERROR;

		INSERT INTO Bitacora_Correos(IdPeriodo, Crn, Nomina, Correo, ResultadoStatus, ResultadoMensaje, MailId, UsuarioLogin)
		VALUES (@PERIODO, @CRN, @NOMINA, @CORREO, @salida, @mensajeError, @mailId, @LOGIN);
	END
GO
/****** Object:  StoredProcedure [dbo].[spCrud_ArchivosProcesados_InsertaArchivos]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[spCrud_ArchivosProcesados_InsertaArchivos]
	@NOMBRE			VARCHAR(300),
	@ACCION			INT
	AS
	BEGIN
		BEGIN TRY
			SET NOCOUNT ON;
			IF @ACCION = 1
			BEGIN
				INSERT INTO DBO.ArchivosProcesados
					(Nombre)
				VALUES
					(@NOMBRE)
			END
		END TRY
		BEGIN CATCH
			SELECT
				ERROR_NUMBER() AS ErrorNumber  
				,ERROR_SEVERITY() AS ErrorSeverity  
				,ERROR_STATE() AS ErrorState  
				,ERROR_PROCEDURE() AS ErrorProcedure  
				,ERROR_LINE() AS ErrorLine  
				,ERROR_MESSAGE() AS ErrorMessage; 
		END CATCH
	END
GO
/****** Object:  StoredProcedure [dbo].[spDirectivo_ObtenerMaterias]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		URIEL HERNANDEZ
-- Create date: 24-10-2019
-- Description:	Procedimiento que obtiene una lista de las materias de un departamento.
-- =============================================
CREATE PROCEDURE [dbo].[spDirectivo_ObtenerMaterias] 
	@Campus		VARCHAR(10),
	@Periodo	VARCHAR(10),
	@ClaveBanner VARCHAR(10)
	AS
	BEGIN
	SELECT * FROM REPLICAS.DBO.MATERIAS WHERE [SUBJECT]+COURSE IN(
		SELECT CLAVE_MATERIA
		FROM Replicas.dbo.DIM_R_ESCO_UNIDAD_ORG_MATERIA C
		WHERE C.CLAVE_DEPARTAMENTO_MATERIA = @ClaveBanner--siglas de calve original banner org
		AND C.CLAVE_EJERCICIO_ACADEMICO = (SELECT MAX(D.CLAVE_EJERCICIO_ACADEMICO)
								FROM Replicas.dbo.DIM_R_ESCO_UNIDAD_ORG_MATERIA D
								WHERE C.CLAVE_AREA_MATERIA = D.CLAVE_AREA_MATERIA
								AND C.NUMERO_CURSO = D.NUMERO_CURSO
								AND C.CLAVE_CAMPUS = D.CLAVE_CAMPUS
								AND C.CLAVE_DIVISION_MATERIA = D.CLAVE_DIVISION_MATERIA
								AND C.CLAVE_DEPARTAMENTO_MATERIA = D.CLAVE_DEPARTAMENTO_MATERIA
								AND D.CLAVE_EJERCICIO_ACADEMICO <= @Periodo)--periodo actual
		AND C.CLAVE_CAMPUS = @Campus)--campus al que pertence

	END
GO
/****** Object:  StoredProcedure [dbo].[spDirectivo_ObtieneCampus]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		URIEL HERNANDEZ
-- Create date: 23-10-2019
-- Description:	Procedimiento que obtiene una lista de Los campus ya sea de un departamento o de un directivo.
-- =============================================
CREATE PROCEDURE [dbo].[spDirectivo_ObtieneCampus] 
	@PIDM		NUMERIC(8,0)=NULL,
	@Vigencia	VARCHAR(20)=NULL,
	@Depto		VARCHAR(20)=NULL,
	@Opcion		int
	AS
	BEGIN
		IF (@Opcion=1)--OBTENCION DE LOS Campus de un directivo
				--REQUIRE DE PIDM
				BEGIN
					WITH deptos as (
						SELECT uo.CLAVE_ESTRUCTURA_ORG clave, uo.FECHA_FIN_VIGENCIA fecha, uo.CLAVE_ESTRUCTURA_PREDECESORA prede, uo.TABLA_ORIGINAL_BANNER tipo, uo.CLAVE_IDENTIDAD_RESPONSABLE pidm, uo.CLAVE_ORIGINAL_BANNER banner
						FROM [Replicas].[dbo].DIM_R_ESCO_ESTRUCTURA_ORG uo
						WHERE uo.FECHA_FIN_VIGENCIA = (SELECT MAX(eff.fecha_fin_vigencia)
													FROM [Replicas].[dbo].DIM_R_ESCO_ESTRUCTURA_ORG eff
													WHERE eff.CLAVE_ESTRUCTURA_ORG = uo.CLAVE_ESTRUCTURA_ORG
													AND eff.FECHA_FIN_VIGENCIA <= dbo.dReturnDate(getdate()))
						AND uo.IND_ESTATUS_ESTRUCTURA_ORG = 'A'
						AND uo.TABLA_ORIGINAL_BANNER = 'STVDEPT'
						AND uo.CLAVE_IDENTIDAD_RESPONSABLE = @PIDM),
					unidades as (
						SELECT uo.CLAVE_ESTRUCTURA_ORG clave, uo.FECHA_FIN_VIGENCIA fecha, uo.CLAVE_ESTRUCTURA_PREDECESORA prede, uo.TABLA_ORIGINAL_BANNER tipo, IND_ESTATUS_ESTRUCTURA_ORG estatus, uo.CLAVE_IDENTIDAD_RESPONSABLE pidm, uo.CLAVE_ORIGINAL_BANNER banner
						FROM [Replicas].[dbo].DIM_R_ESCO_ESTRUCTURA_ORG uo
						WHERE uo.FECHA_FIN_VIGENCIA = (SELECT MAX(eff.fecha_fin_vigencia)
													FROM [Replicas].[dbo].DIM_R_ESCO_ESTRUCTURA_ORG eff
													WHERE eff.CLAVE_ESTRUCTURA_ORG = uo.CLAVE_ESTRUCTURA_ORG
													AND eff.FECHA_FIN_VIGENCIA <= dbo.dReturnDate(getdate()))
						AND uo.IND_ESTATUS_ESTRUCTURA_ORG = 'A'
					),
					campus AS (
						SELECT deptos.clave, deptos.fecha, deptos.prede, deptos.tipo, deptos.pidm, deptos.banner FROM deptos
						UNION ALL
						SELECT uo.clave, uo.fecha, uo.prede, uo.tipo, uo.pidm, uo.banner
						FROM unidades uo, campus
						WHERE uo.estatus = 'A'
						AND campus.prede = uo.clave)
					SELECT DISTINCT campus.banner clave_campus
					FROM campus
					WHERE tipo = 'STVCAMP';

				END
			IF (@Opcion=2)--OBTENCION DE LOS Campus de un DEPARTAMENTO
				BEGIN
					WITH deptos as (
							SELECT uo.CLAVE_ESTRUCTURA_ORG clave, uo.FECHA_FIN_VIGENCIA fecha, uo.CLAVE_ESTRUCTURA_PREDECESORA prede, uo.TABLA_ORIGINAL_BANNER tipo, uo.CLAVE_IDENTIDAD_RESPONSABLE pidm, uo.CLAVE_ORIGINAL_BANNER banner
							FROM [Replicas].[dbo].DIM_R_ESCO_ESTRUCTURA_ORG uo
							WHERE uo.FECHA_FIN_VIGENCIA = (SELECT MAX(eff.fecha_fin_vigencia)
														FROM [Replicas].[dbo].DIM_R_ESCO_ESTRUCTURA_ORG eff
														WHERE eff.CLAVE_ESTRUCTURA_ORG = uo.CLAVE_ESTRUCTURA_ORG
														AND eff.FECHA_FIN_VIGENCIA <= dbo.dReturnDate(getdate()))
							AND uo.IND_ESTATUS_ESTRUCTURA_ORG = 'A'
							AND uo.CLAVE_ESTRUCTURA_ORG = @Depto
							AND uo.FECHA_FIN_VIGENCIA = @Vigencia),
						unidades as (
							SELECT uo.CLAVE_ESTRUCTURA_ORG clave, uo.FECHA_FIN_VIGENCIA fecha, uo.CLAVE_ESTRUCTURA_PREDECESORA prede, uo.TABLA_ORIGINAL_BANNER tipo, IND_ESTATUS_ESTRUCTURA_ORG estatus, uo.CLAVE_IDENTIDAD_RESPONSABLE pidm, uo.CLAVE_ORIGINAL_BANNER banner
							FROM [Replicas].[dbo].DIM_R_ESCO_ESTRUCTURA_ORG uo
							WHERE uo.FECHA_FIN_VIGENCIA = (SELECT MAX(eff.fecha_fin_vigencia)
														FROM [Replicas].[dbo].DIM_R_ESCO_ESTRUCTURA_ORG eff
														WHERE eff.CLAVE_ESTRUCTURA_ORG = uo.CLAVE_ESTRUCTURA_ORG
														AND eff.FECHA_FIN_VIGENCIA <= dbo.dReturnDate(getdate()))
							AND uo.IND_ESTATUS_ESTRUCTURA_ORG = 'A'
						),
						campus AS (
							SELECT deptos.clave, deptos.fecha, deptos.prede, deptos.tipo, deptos.pidm, deptos.banner FROM deptos
							UNION ALL
							SELECT uo.clave, uo.fecha, uo.prede, uo.tipo, uo.pidm, uo.banner
							FROM unidades uo, campus
							WHERE uo.estatus = 'A'
							AND campus.prede = uo.clave)
						SELECT DISTINCT campus.banner clave_campus
						FROM campus
						WHERE tipo = 'STVCAMP';
				END
	END
GO
/****** Object:  StoredProcedure [dbo].[spDirectivo_ObtieneDepartamento]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		URIEL HERNANDEZ
-- Create date: 23-10-2019
-- Description:	Procedimiento que obtiene una lista de departamentos de un directivo.
-- =============================================
CREATE PROCEDURE [dbo].[spDirectivo_ObtieneDepartamento] 
	@PIDM		NUMERIC(8,0)=NULL
	AS
	BEGIN
		--se busca la existencia del pidm como directivo y se cargan los datos correspondientes
		SELECT uo.CLAVE_ESTRUCTURA_ORG clave, uo.FECHA_FIN_VIGENCIA fecha, uo.CLAVE_ESTRUCTURA_PREDECESORA prede, uo.TABLA_ORIGINAL_BANNER tipo, uo.CLAVE_IDENTIDAD_RESPONSABLE pidm, uo.CLAVE_ORIGINAL_BANNER banner, uo.DESC_ESTRUCTURA_ORG Descripcion, uo.SIGLAS_ESTRUCTURA_ORG Identificador
		FROM [Replicas].[dbo].DIM_R_ESCO_ESTRUCTURA_ORG uo
		WHERE uo.FECHA_FIN_VIGENCIA = (SELECT MAX(eff.fecha_fin_vigencia)
									FROM [Replicas].[dbo].DIM_R_ESCO_ESTRUCTURA_ORG eff
									WHERE eff.CLAVE_ESTRUCTURA_ORG = uo.CLAVE_ESTRUCTURA_ORG
									AND eff.FECHA_FIN_VIGENCIA <= dbo.dReturnDate(getdate()))
		AND uo.IND_ESTATUS_ESTRUCTURA_ORG = 'A'
		AND uo.TABLA_ORIGINAL_BANNER = 'STVDEPT'
		AND uo.CLAVE_IDENTIDAD_RESPONSABLE = @PIDM;
	END
GO
/****** Object:  StoredProcedure [dbo].[spEjemplo]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[spEjemplo]
	-- Add the parameters for the stored procedure here
	@salida nvarchar(20) out
	AS
	BEGIN
	-- SET NO 0OUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
		SET NOCOUNT ON;
		select @salida = 'pturna'
	END
GO
/****** Object:  StoredProcedure [dbo].[spFiltro_ConsultarAlumnos]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Jonatán Flores
-- Create date: 12-09-2019
-- Description: Procedimiento que obtiene los alumnos mediante los siguientes filtros: matrícula, campus, periodo y subperiodo.
-- =============================================
CREATE PROCEDURE [dbo].[spFiltro_ConsultarAlumnos]
	-- Add the parameters for the stored procedure here
	@MATRICULA		VARCHAR(20),
	@CAMPUS			VARCHAR(100),
	@SUBPERIODO		VARCHAR(100),
	@PERIODO		VARCHAR(20)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	IF @MATRICULA != '' AND @CAMPUS != '' AND @SUBPERIODO != '' AND @PERIODO != ''
	BEGIN
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		INNER JOIN Replicas.dbo.GRUPOS g on ga.CRN = g.CRN
		INNER JOIN SubperiodosNacional sn on ga.PERIODO = sn.Idperiodo
		WHERE
		a.MATRICULA LIKE @MATRICULA
		AND c.desc_campus LIKE @CAMPUS
		AND sn.SubperiodoNacionalId LIKE @SUBPERIODO
		AND g.TERM LIKE @PERIODO

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus, g.TERM, sn.SubperiodoNacionalId
		ORDER BY c.desc_campus DESC
	END
	IF @MATRICULA != '' AND @CAMPUS = '' AND @SUBPERIODO = '' AND @PERIODO = ''
	BEGIN
	/*-- MATRICULA --*/
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		WHERE
		a.MATRICULA LIKE @MATRICULA

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus
		ORDER BY c.desc_campus DESC
	END 
	IF @MATRICULA = '' AND @CAMPUS != '' AND @SUBPERIODO = '' AND @PERIODO = ''
	/*-- CAMPUS --*/
	BEGIN
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		WHERE
		c.desc_campus LIKE @CAMPUS

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus
		ORDER BY c.desc_campus DESC
	END
	/*-- SUBPERIODO --*/
	IF @MATRICULA = '' AND @CAMPUS = '' AND @SUBPERIODO != '' AND @PERIODO = ''
	BEGIN
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		INNER JOIN Replicas.dbo.GRUPOS g on ga.CRN = g.CRN
		INNER JOIN SubperiodosNacional sn on ga.PERIODO = sn.Idperiodo
		WHERE
		sn.SubperiodoNacionalId LIKE @SUBPERIODO

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus
		ORDER BY c.desc_campus DESC
	END 
	/*-- PERIODO --*/
	IF @MATRICULA = '' AND @CAMPUS = '' AND @SUBPERIODO = '' AND @PERIODO != ''
	BEGIN
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		INNER JOIN Replicas.dbo.GRUPOS g on ga.CRN = g.CRN
		--INNER JOIN SubperiodosNacional sn on ga.PERIODO = sn.Idperiodo
		WHERE
		g.TERM = '201913'

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus
		ORDER BY c.desc_campus DESC
	END
	/*-- MATRICULA - CAMPUS --*/
	IF @MATRICULA != '' AND @CAMPUS != '' AND @SUBPERIODO = '' AND @PERIODO = ''
	BEGIN
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		--INNER JOIN Replicas.dbo.GRUPOS g on ga.CRN = g.CRN
		--INNER JOIN SubperiodosNacional sn on ga.PERIODO = sn.Idperiodo
		WHERE
		a.MATRICULA LIKE @MATRICULA
		AND c.desc_campus LIKE @CAMPUS
		--AND sn.SubperiodoNacionalId LIKE @SUBPERIODO
		--AND g.TERM LIKE @PERIODO

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus
		--, g.TERM, sn.SubperiodoNacionalId
		ORDER BY c.desc_campus DESC
	END
	/*-- MATRICULA - SUBPERIODO --*/
	IF @MATRICULA != '' AND @CAMPUS = '' AND @SUBPERIODO != '' AND @PERIODO = ''
	BEGIN
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		INNER JOIN Replicas.dbo.GRUPOS g on ga.CRN = g.CRN
		INNER JOIN SubperiodosNacional sn on ga.PERIODO = sn.Idperiodo
		WHERE
		a.MATRICULA LIKE @MATRICULA
		--AND c.desc_campus LIKE @CAMPUS
		AND sn.SubperiodoNacionalId LIKE @SUBPERIODO
		--AND g.TERM LIKE @PERIODO

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus
		--, g.TERM, sn.SubperiodoNacionalId
		ORDER BY c.desc_campus DESC
	END
	/*-- MATRICULA - PERIODO --*/
	IF @MATRICULA != '' AND @CAMPUS = '' AND @SUBPERIODO = '' AND @PERIODO != ''
	BEGIN
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		INNER JOIN Replicas.dbo.GRUPOS g on ga.CRN = g.CRN
		INNER JOIN SubperiodosNacional sn on ga.PERIODO = sn.Idperiodo
		WHERE
		a.MATRICULA LIKE @MATRICULA
		--AND c.desc_campus LIKE @CAMPUS
		--AND sn.SubperiodoNacionalId LIKE @SUBPERIODO
		AND g.TERM LIKE @PERIODO

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus
		--, g.TERM, sn.SubperiodoNacionalId
		ORDER BY c.desc_campus DESC
	END
	/*-- SUBPERIODO - PERIODO --*/
	IF @MATRICULA = '' AND @CAMPUS = '' AND @SUBPERIODO != '' AND @PERIODO != ''
	BEGIN
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		INNER JOIN Replicas.dbo.GRUPOS g on ga.CRN = g.CRN
		INNER JOIN SubperiodosNacional sn on ga.PERIODO = sn.Idperiodo
		WHERE
		--a.MATRICULA LIKE @MATRICULA
		--AND c.desc_campus LIKE @CAMPUS
		sn.SubperiodoNacionalId LIKE @SUBPERIODO
		AND g.TERM LIKE @PERIODO

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus
		--, g.TERM, sn.SubperiodoNacionalId
		ORDER BY c.desc_campus DESC
	END
	/*-- SUBPERIODO - CAMPUS --*/
	IF @MATRICULA = '' AND @CAMPUS != '' AND @SUBPERIODO != '' AND @PERIODO = ''
	BEGIN
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		INNER JOIN Replicas.dbo.GRUPOS g on ga.CRN = g.CRN
		INNER JOIN SubperiodosNacional sn on ga.PERIODO = sn.Idperiodo
		WHERE
		--a.MATRICULA LIKE @MATRICULA
		c.desc_campus LIKE @CAMPUS
		AND sn.SubperiodoNacionalId LIKE @SUBPERIODO
		--AND g.TERM LIKE @PERIODO

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus
		--, g.TERM, sn.SubperiodoNacionalId
		ORDER BY c.desc_campus DESC
	END
	/*-- PERIODO - CAMPUS --*/
	IF @MATRICULA = '' AND @CAMPUS != '' AND @SUBPERIODO = '' AND @PERIODO != ''
	BEGIN
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		INNER JOIN Replicas.dbo.GRUPOS g on ga.CRN = g.CRN
		INNER JOIN SubperiodosNacional sn on ga.PERIODO = sn.Idperiodo
		WHERE
		--a.MATRICULA LIKE @MATRICULA
		c.desc_campus LIKE @CAMPUS
		--AND sn.SubperiodoNacionalId LIKE @SUBPERIODO
		AND g.TERM LIKE @PERIODO

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus
		--, g.TERM, sn.SubperiodoNacionalId
		ORDER BY c.desc_campus DESC
	END
	/*-- MATRICULA - PERIODO - SUBPERIODO --*/
	IF @MATRICULA != '' AND @CAMPUS = '' AND @SUBPERIODO != '' AND @PERIODO != ''
	BEGIN
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		INNER JOIN Replicas.dbo.GRUPOS g on ga.CRN = g.CRN
		INNER JOIN SubperiodosNacional sn on ga.PERIODO = sn.Idperiodo
		WHERE
		a.MATRICULA LIKE @MATRICULA
		--c.desc_campus LIKE @CAMPUS
		AND sn.SubperiodoNacionalId LIKE @SUBPERIODO
		AND g.TERM LIKE @PERIODO

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus
		--, g.TERM, sn.SubperiodoNacionalId
		ORDER BY c.desc_campus DESC
	END
	/*-- MATRICULA - PERIODO - CAMPUS --*/
	IF @MATRICULA != '' AND @CAMPUS != '' AND @SUBPERIODO = '' AND @PERIODO != ''
	BEGIN
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		INNER JOIN Replicas.dbo.GRUPOS g on ga.CRN = g.CRN
		INNER JOIN SubperiodosNacional sn on ga.PERIODO = sn.Idperiodo
		WHERE
		a.MATRICULA LIKE @MATRICULA
		AND c.desc_campus LIKE @CAMPUS
		--AND sn.SubperiodoNacionalId LIKE @SUBPERIODO
		AND g.TERM LIKE @PERIODO

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus
		--, g.TERM, sn.SubperiodoNacionalId
		ORDER BY c.desc_campus DESC
	END
	/*-- MATRICULA - SUBPERIODO - CAMPUS --*/
	IF @MATRICULA != '' AND @CAMPUS != '' AND @SUBPERIODO != '' AND @PERIODO = ''
	BEGIN
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		INNER JOIN Replicas.dbo.GRUPOS g on ga.CRN = g.CRN
		INNER JOIN SubperiodosNacional sn on ga.PERIODO = sn.Idperiodo
		WHERE
		a.MATRICULA LIKE @MATRICULA
		AND c.desc_campus LIKE @CAMPUS
		AND sn.SubperiodoNacionalId LIKE @SUBPERIODO
		--AND g.TERM LIKE @PERIODO

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus
		--, g.TERM, sn.SubperiodoNacionalId
		ORDER BY c.desc_campus DESC
	END
	/*-- PERIODO - SUBPERIODO - CAMPUS --*/
	IF @MATRICULA = '' AND @CAMPUS != '' AND @SUBPERIODO != '' AND @PERIODO != ''
	BEGIN
		SELECT a.PIDM, a.MATRICULA, CONCAT(a.NOMBRE, + ' ' + a.AP_PATERNO + ' ' + a.AP_MATERNO) AS 'NOMBRE', a.CORREO_ELECTRONICO, c.DESC_CAMPUS
		FROM Replicas.dbo.ALUMNOS a
		INNER JOIN Replicas.dbo.CAMPUS c on a.CAMPUS = c.clave_campus
		INNER JOIN Replicas.dbo.GRUPO_ALUMNOS ga on a.MATRICULA = ga.MATRICULA
		INNER JOIN Replicas.dbo.GRUPOS g on ga.CRN = g.CRN
		INNER JOIN SubperiodosNacional sn on ga.PERIODO = sn.Idperiodo
		WHERE
		--a.MATRICULA LIKE @MATRICULA
		c.desc_campus LIKE @CAMPUS
		AND sn.SubperiodoNacionalId LIKE @SUBPERIODO
		AND g.TERM LIKE @PERIODO

		GROUP BY a.PIDM, a.MATRICULA, a.NOMBRE, a.AP_PATERNO, a.AP_MATERNO, a.CORREO_ELECTRONICO, c.desc_campus
		--, g.TERM, sn.SubperiodoNacionalId
		ORDER BY c.desc_campus DESC
	END
    -- Insert statements for procedure here
	--SELECT <@Param1, sysname, @p1>, <@Param2, sysname, @p2>
END
GO
/****** Object:  StoredProcedure [dbo].[spGrupos_TraerDatos]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ALEJANDRO CERVANTES
-- Create date: 06-07-2019
-- Description:	TRAE LOS DATOS DE GRUPOS POR TERM Y CRN
-- =============================================
CREATE PROCEDURE [dbo].[spGrupos_TraerDatos]
	-- Add the parameters for the stored procedure here
	@TERM		VARCHAR(20),
	@CRN		INT,
	@ACCION		INT,
	@RES_DATOS	VARCHAR(100) OUTPUT
	AS
	BEGIN --EMPIEZA
		
		SET NOCOUNT ON;
		IF @ACCION = 1
			BEGIN	
				SET @RES_DATOS=(SELECT CAMPUS FROM REPLICAS.DBO.GRUPOS WHERE TERM = @TERM AND CRN=@CRN)
			END

		IF @ACCION = 2
			BEGIN	
				SET @RES_DATOS=(SELECT [Subject] FROM REPLICAS.DBO.GRUPOS WHERE TERM = @TERM AND CRN=@CRN)
			END
		IF @ACCION = 3
			BEGIN	
				SET @RES_DATOS=(SELECT Course FROM REPLICAS.DBO.GRUPOS WHERE TERM = @TERM AND CRN=@CRN)
			END

		IF @ACCION = 4
		BEGIN	
			SET @RES_DATOS=(SELECT NOMINA FROM REPLICAS.DBO.GRUPOS WHERE TERM = @TERM AND CRN=@CRN)
		END
	END--TERMINA
GO
/****** Object:  StoredProcedure [dbo].[spMateriasExcepcion_VerificaMaterias]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ALEJANDRO CERVANTES
-- Create date: 08-07-2019
-- Description:	REVISA SI SE ENCUENTRAN DENTRO LAS MATERIAS EN EXCEPCION
-- =============================================
CREATE PROCEDURE [dbo].[spMateriasExcepcion_VerificaMaterias]
	@SUBJECT		VARCHAR(20),
	@COURSE			VARCHAR(20),
	@TERM			VARCHAR(20)
	AS
	BEGIN
		SET NOCOUNT ON;
		IF EXISTS(SELECT Id FROM [dbo].[MateriasExclusiones] 
			WHERE Materia=@SUBJECT AND Curso=@COURSE AND TERM=@TERM AND Activo = 1)
			BEGIN
				--SELECT 1 AS 'MENSAJE'
				IF EXISTS(SELECT CLAVE_EJERCICIO_ACADEMICO FROM Replicas.dbo.DIM_R_ESCO_EJERCICIO_ACADEMICO 
						  WHERE CLAVE_EJERCICIO_ACADEMICO = @TERM AND IND_ESTATUS_EJER_ACAD IN ('A', 'H'))
					BEGIN
						RETURN 1
					END
				ELSE
					BEGIN
						RETURN 0
					END	
			END
		ELSE
			BEGIN
				--SELECT 0 AS 'MENSAJE'
				RETURN 0
			END
	END
GO
/****** Object:  StoredProcedure [dbo].[spMateriasNormativas_RevisarMaterias]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ALEJANDRO CERVANTES
-- Create date: 08-07-2019
-- Description:	REVISAR SI SE ENCUENTRAN LAS MateriaS EN LA TABLA DE MateriaS_NORMATIVA
-- =============================================
CREATE PROCEDURE [dbo].[spMateriasNormativas_RevisarMaterias]
	@Materia	VARCHAR(20),
	@Curso		VARCHAR(20),
	@TERM		VARCHAR(20)

	AS
	BEGIN
		SET NOCOUNT ON;

		IF EXISTS(SELECT Id 
				FROM [dbo].[MateriasNormativas]
				WHERE Curso=@Curso AND Materia=@Materia AND Activo = 1)
			BEGIN
				--SELECT 1
				IF EXISTS(SELECT CLAVE_EJERCICIO_ACADEMICO FROM Replicas.dbo.DIM_R_ESCO_EJERCICIO_ACADEMICO 
						  WHERE CLAVE_EJERCICIO_ACADEMICO = @TERM AND IND_ESTATUS_EJER_ACAD IN ('A', 'H'))
					BEGIN
						RETURN 1
					END
				ELSE
					BEGIN
						RETURN 0
					END			
			END
		ELSE
			BEGIN
				--SELECT 0
				RETURN 0
			END

	END
GO
/****** Object:  StoredProcedure [dbo].[spNormativa_AplicarNormativa]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Alejandro Cervantes
-- Create date: 06-07-2019
-- Description:	APLICA LA NORMATIVA A ALUMNOS DE UN MISMO Grupo Y PERIODO
-- =============================================
CREATE PROCEDURE [dbo].[spNormativa_AplicarNormativa]
    @TERM				VARCHAR(20)=NULL,
    @CRN				INT=NULL,
    @ID_NORMATIVA		INT
   
    AS

    BEGIN
        BEGIN TRY	
            SET NOCOUNT ON;
            DECLARE @CONT_NORM_APL			INT
            DECLARE @REN_NOR_APL			INT
            DECLARE @NOR_INTERVALO_DESDE	INT
            DECLARE @NOR_INTERVALO_HASTA	INT
            DECLARE @CONT_ARCH_FIL			INT
            DECLARE @REN_ARCH_FIL			INT
            DECLARE @VAR_CLAVE				VARCHAR(20)

            DECLARE @Normativas_APLICAR TABLE  
                ( Id   INT IDENTITY(1,1)   NOT NULL ,  
                ID_NORM			INT	   NOT NULL,
                VigenciaDesde   DATETIME NOT NULL, 
                VigenciaHasta	DATETIME NOT NULL,
                IntervaloDesde	INT NOT NULL,
                IntervaloHasta	INT NOT NULL,
                ClaveCal			VARCHAR(50) NOT NULL);

            DECLARE @ARCH_FIL TABLE  
                ( Id			INT IDENTITY(1,1)   NOT NULL ,  
                ID_ARCH		INT NOT NULL,
                Periodo		VARCHAR(20) NOT NULL, 
                CRN			INT NOT NULL,
                PIDMProfesor	INT NOT NULL,
                PIDMAlumno	INT NOT NULL,
                GradeNum		VARCHAR (10) NOT NULL,
                GradeAlfa	VARCHAR (10) NULL,
                Procesado		BIT NOT NULL);



            INSERT INTO @Normativas_APLICAR
            SELECT Id, VigenciaDesde,VigenciaHasta,IntervaloDesde,IntervaloHasta,ClaveCal FROM Normativas WHERE NormativaId=@ID_NORMATIVA;

            INSERT INTO @ARCH_FIL
            SELECT Id, Periodo, CRN, PIDMProfesor, PIDMAlumno, GradeNum, GradeAlfa, Procesado FROM ArchivosCanvasFiltrado;

            SET @CONT_NORM_APL = (SELECT 1 FROM @Normativas_APLICAR)
            SET @REN_NOR_APL = 1
            SET @CONT_ARCH_FIL =(SELECT 1 FROM @ARCH_FIL WHERE (Periodo=@TERM AND CRN=@CRN))
            --ESTE CICLO RECORRE LAS VECES QUE HAYA QUE AGREGAR NORMATIVA
            WHILE @REN_NOR_APL <= @CONT_NORM_APL
                BEGIN
                    --SELECT  * FROM @Normativas_APLICAR
                    SET @NOR_INTERVALO_DESDE = (SELECT  IntervaloDesde FROM @Normativas_APLICAR WHERE Id=@REN_NOR_APL)
                    SET @NOR_INTERVALO_HASTA = (SELECT  IntervaloHasta FROM @Normativas_APLICAR WHERE Id=@REN_NOR_APL)
                    SET @VAR_CLAVE = (SELECT  ClaveCal FROM @Normativas_APLICAR WHERE Id=@REN_NOR_APL)
                    SET @REN_ARCH_FIL = 1

                    WHILE @REN_ARCH_FIL <= @CONT_ARCH_FIL
                        BEGIN
                            DECLARE @GRADE_A VARCHAR(20)=(SELECT GradeAlfa FROM @ARCH_FIL WHERE Id= @REN_ARCH_FIL)
                            DECLARE @GRADE_N	INT=(SELECT GradeNum FROM @ARCH_FIL WHERE Id= @REN_ARCH_FIL)
                            IF @GRADE_A = NULL OR @GRADE_A = '' OR @GRADE_A = 'FI'
                                BEGIN
                                    IF @GRADE_N BETWEEN @NOR_INTERVALO_DESDE AND @NOR_INTERVALO_HASTA
                                        BEGIN
                                            IF @GRADE_A = 'FI'
                                            BEGIN
                                                UPDATE @ARCH_FIL SET GradeNum=@VAR_CLAVE WHERE Id=@REN_ARCH_FIL;
                                            END
                                            ELSE
                                            BEGIN
                                                UPDATE @ARCH_FIL SET GradeAlfa=@VAR_CLAVE WHERE Id=@REN_ARCH_FIL;
                                            END;
                                        END;
                                END;
                            SET @REN_ARCH_FIL=@REN_ARCH_FIL+1
                        END
                    --SELECT * FROM dbo.ArchivosCanvasFiltrado
                    SET @REN_NOR_APL=@REN_NOR_APL+1
                END

            --UNA VEZ TERMINADO DE APLICAR LAS Normativas AFECTAMOS LA TABLA
            UPDATE dbo.ArchivosCanvasFiltrado 
                SET
                    GradeAlfa=AF.GradeAlfa,
                    GradeNum = AF.GradeNum
                FROM
                    ArchivosCanvasFiltrado AS ACF
                    INNER JOIN @ARCH_FIL AS AF
                        ON ACF.Id=AF.ID_ARCH
            WHERE (ACF.Periodo=@TERM AND ACF.CRN=@CRN)

            EXEC dbo.spBitacoras_RegistraBitacora 9, @TERM, @CRN, 0, NULL,NULL,NULL,0,'FLUJO','PROCESO AUTOMATICO', NULL,NULL,NULL,'Se aplica normativas'
            
        END TRY
        BEGIN CATCH
            SELECT
                ERROR_NUMBER() AS ErrorNumber  
                ,ERROR_SEVERITY() AS ErrorSeverity  
                ,ERROR_STATE() AS ErrorState  
                ,ERROR_PROCEDURE() AS ErrorProcedure  
                ,ERROR_LINE() AS ErrorLine  
                ,ERROR_MESSAGE() AS ErrorMessage; 
                EXEC dbo.spBitacoras_RegistraBitacora 9, @TERM, @CRN, 0, NULL,NULL,NULL,0,'FLUJO','PROCESO AUTOMATICO', NULL,NULL,NULL,'Error al aplicar normativa'
        END CATCH	
    END
GO
/****** Object:  StoredProcedure [dbo].[spNormativa_ObtenerInformacion]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ALEJANDRO CERVANTES
-- Create date: 08-07-2019
-- Description:	TRAER INFORMACION RELACIONADA CON LA NORMATIVA
-- =============================================
CREATE PROCEDURE [dbo].[spNormativa_ObtenerInformacion]
	@Materia		VARCHAR(20),
	@Curso			VARCHAR(20),
	@ACCION			INT,
	@RES			INT OUTPUT

	AS
	BEGIN
		SET NOCOUNT ON;
		IF @ACCION=1
			BEGIN
				SET @RES=(SELECT TOP(1) NormativaId 
				FROM [dbo].[MateriasNormativas]
				WHERE Materia=@Materia AND Curso=@Curso)
				SELECT @RES
			END
	END
GO
/****** Object:  StoredProcedure [dbo].[spPeriodo_ObtenerAtributo]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ALEJANDRO CERVANTES
-- Create date: 06-07-2019
-- Description: HACE LAS COMPARACIONES PARA DECIRNOS EL TIPO DE PERIODO QUE ES PARA SU ATRIBUTO
-- =============================================
CREATE PROCEDURE [dbo].[spPeriodo_ObtenerAtributo]
	@TERM							VARCHAR(20),
	@ID_SUB_PERIODO_CAMPUS			VARCHAR(20),
	@R								varchar(20) out
	AS
	BEGIN
		SET NOCOUNT ON;
		DECLARE @TIPO_PERIODO		VARCHAR(20)
		DECLARE	@CONV_SUBPERIODO	VARCHAR(20)
		
		SET @CONV_SUBPERIODO = SUBSTRING(@ID_SUB_PERIODO_CAMPUS,8,1)

		SELECT @TIPO_PERIODO =
				CASE --DETECTAMOS QUE TIPO DE PERIODO ES
					WHEN @CONV_SUBPERIODO = '1' THEN 'PMT1'
					WHEN @CONV_SUBPERIODO = '2' THEN 'PMT2'
					WHEN @CONV_SUBPERIODO = '3' THEN 'PMT3'
					WHEN @CONV_SUBPERIODO = '4' THEN 'PMT4'
					WHEN @CONV_SUBPERIODO = '5' THEN 'PMT5'
					WHEN @CONV_SUBPERIODO = '6' THEN 'PMT6'
					WHEN @CONV_SUBPERIODO = '7' THEN 'PMT1'
					WHEN @CONV_SUBPERIODO = '8' THEN 'PMT2'
					WHEN @CONV_SUBPERIODO = '9' THEN 'PMT3'
				END
		SET @R=(SELECT @TIPO_PERIODO AS TIPO_PERIODO)
		
		SELECT @R AS 'TIPO PERIODO'
	END
GO
/****** Object:  StoredProcedure [dbo].[spPeriodo_TraerPeriodoActivo]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ALEJANDRO CERVANTES
-- Create date: 08-JULIO-2019
-- Description:	TE TRAE DE VUELTA SI EL PERIODO SE ENCUENTRA Activo, QUE TIPO DE PERIODO ES Y SUS FECHAS
-- =============================================
CREATE PROCEDURE [dbo].[spPeriodo_TraerPeriodoActivo]
	@TERM	VARCHAR(20),
	@CRN	INT

	AS
	BEGIN
		SET NOCOUNT ON;
		DECLARE @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC VARCHAR(10);
		DECLARE @IS_VALID_PMT6			INT;

		DECLARE @ID_CAMPUS VARCHAR(20)=(SELECT CAMPUS FROM Replicas.dbo.GRUPOS WHERE TERM = @TERM AND CRN=@CRN)
		DECLARE @IS_SEMANA_TEC VARCHAR(10)
		SET @IS_SEMANA_TEC = (SELECT CLAVE_ATRIBUTO FROM REPLICAS.DBO.GRUPO_ATRIBUTOS WHERE TERM =@TERM AND CRN = @CRN AND CLAVE_ATRIBUTO = 'STEC')
		DECLARE @CLAVE_ATRIBUTO_PERIODO_TEMP VARCHAR(10) = (SELECT CLAVE_ATRIBUTO FROM Replicas.DBO.GRUPO_ATRIBUTOS WHERE TERM =@TERM AND CRN = @CRN AND CLAVE_ATRIBUTO IN ('PMT1','PMT2','PMT3','PMT4','PMT5','PMT6'))

		IF ISNULL(@IS_SEMANA_TEC,'') <>''
			BEGIN
				--SI EL CONTADOR ES MAYOR A DOS SIGNIFICA QUE SON SEMANAS TEC
				SELECT @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC =
				CASE --DETECTAMOS QUE NUMERO DE PERIODO DE SEMANA TEC ES
					WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT1' THEN '7'
					WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT2' THEN '8'
					WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT3' THEN '9'
				END
			END
		ELSE
			BEGIN
				SELECT @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC=
					CASE --EN EL ELSE SON LOS SUBPERIODOS DEL 1 AL 6
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT1' THEN '1'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT2' THEN '2'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT3' THEN '3'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT4' THEN '4'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT5' THEN '5'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT6' THEN '6'
					END
			END	

		--REALIZAMOS QUERY PARA TRAERNOS EL SUBPERIODO INDICADO		
		DECLARE @NUMERO_SUBPERIODO VARCHAR(20)
		SET @NUMERO_SUBPERIODO = @TERM + '-' + @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC
					
		SELECT ID, IdSubperiodo,Nombre,FechaDesde,FechaHasta
			INTO #SUBPERIODO_CAMPUS_TEMP
			FROM DBO.SubperiodosCampus
		WHERE (IdSubperiodo = @NUMERO_SUBPERIODO AND IdCampus = @ID_CAMPUS AND Activo = 1)

		--OBTENEMOS LOS RANGOS DE FECHAS DEL SUBPERIODO CAMPUS
		DECLARE @FECHA_DESDE_SUBPERIODO_CAMPUS DATETIME = (SELECT FechaDesde FROM #SUBPERIODO_CAMPUS_TEMP)
		DECLARE @FECHA_HASTA_SUBPERIODO_CAMPUS DATETIME = (SELECT FechaHasta FROM #SUBPERIODO_CAMPUS_TEMP)
		DECLARE @HOY_MISMO DATETIME
		SET @HOY_MISMO = DBO.dReturnDate(GETDATE());

		--COMPARAMOS EL PERIODO PARA SABER SI NOS ENCONTRAMOS DENTRO DEL SUBPERIODO CAMPUS
		IF @HOY_MISMO BETWEEN @FECHA_DESDE_SUBPERIODO_CAMPUS AND @FECHA_HASTA_SUBPERIODO_CAMPUS
			BEGIN
				--SI SE ENCUENTRA DENTRO DE PERIODO DEVUELVO 1 Y EL COMPLEMENTO
				--SELECT 1
				RETURN 1
			END
		ELSE
			BEGIN
				--SI NO SE ENCUENTRA DENTRO DE PERIODO DEVUELVO 0 Y EL COMPLEMENTO
				--SELECT  0

				RETURN 0
			END  
	END
GO
/****** Object:  StoredProcedure [dbo].[spProcesoAutomatico_Ejecutar]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ALEJANDRO CERVANTES
-- Create date: 06-08-2019
-- Description:	EJECUTA PROCESO AUTOMATICO POR TERM Y CRN
-- =============================================
CREATE PROCEDURE [dbo].[spProcesoAutomatico_Ejecutar]
@TERM					VARCHAR(20),
@CRN					INT,
@FECHA					DATETIME,
@ACCION					INT
AS
BEGIN -- Begin first
	SET NOCOUNT ON;
	DECLARE @RES_SUBPeriodo_ACTIVO	VARCHAR(4000)
	DECLARE @RES_LISTA_EXC			INT
	DECLARE @RES_SEM_6Y12			INT
	DECLARE @RES_EX_NORMATIVA		INT
	DECLARE @RES_NormativaId		INT
	DECLARE @MENSAJE_SALIDA			VARCHAR(8000)
	DECLARE	@RES_Subject			VARCHAR(20)
	DECLARE @RES_Course				VARCHAR(20)
	DECLARE @RES_ENV_BAN			VARCHAR(20)
	DECLARE @IS_VALID_PMT6			INT

	--REVISAMOS SI EXISTE EL QUERY DE QUE YA FUE ENVIADO ESE Grupo
	IF EXISTS(SELECT TOP 1 CRN FROM dbo.CalificacionesEnviadasBanner WHERE (TERM=@TERM AND CRN=@CRN)) --IF 1
		BEGIN--1
			--SE ENVIA MENSAJE QUE YA SE ENCUENTRA EN LA TABLA DE ProcesadoS
			EXEC dbo.spBitacoras_RegistraBitacora 9, @TERM, @CRN, 0, NULL,NULL,NULL,0,'ERROR','PROCESO AUTOMATICO', NULL,NULL,NULL,'CRN ya fue enviado a Banner'
			SET @MENSAJE_SALIDA = 'CRN ya fue enviado a Banner'
			SELECT @MENSAJE_SALIDA AS 'MENSAJE'
			DELETE FROM dbo.ArchivosCanvasFiltrado WHERE (Periodo=@TERM AND CRN = @CRN)
			RETURN
		END--1
	ELSE --ELSE 1
		BEGIN--1
			--EJECUTO STORED PARA SABER SI SE ENCUENTRA EL SUBPeriodo Activo O NO
			EXEC @RES_SUBPeriodo_ACTIVO=dbo.spPeriodo_TraerPeriodoActivo @TERM, @CRN
			--ME TRAIGO LOS DATOS DE MateriaS DENTRO DE LA TABLA GRUPOS
			EXEC  dbo.spGrupos_TraerDatos @TERM, @CRN, 2, @RES_Subject OUTPUT
			EXEC  dbo.spGrupos_TraerDatos @TERM, @CRN, 3, @RES_Course OUTPUT
			--SI SE ENCUENTRA Activo REVISAR SI ESTA EN LISTA DE EXCEPCION
			EXEC @RES_LISTA_EXC=dbo.spMateriasExcepcion_VerificaMaterias @RES_Subject, @RES_Course, @TERM
			EXEC @RES_SEM_6Y12 = dbo.spSemana6Y12_RevisarSemana @TERM, @CRN
						
			IF @RES_SUBPeriodo_ACTIVO = 1 -- 1.1
				BEGIN --1.1					
					IF @RES_LISTA_EXC=0 AND @RES_SEM_6Y12=0 --1.1.2
						BEGIN--1.1.2
							EXEC @RES_EX_NORMATIVA=dbo.spMateriasNormativas_RevisarMaterias @RES_Subject, @RES_Course, @TERM 
							select '@RES_EX_NORMATIVA'
							IF @RES_EX_NORMATIVA=1--1.1.3
								BEGIN--1.1.3
									EXEC dbo.spNormativa_ObtenerInformacion @RES_Subject, @RES_Course, 1, @RES_NormativaId OUTPUT
									EXEC dbo.spNormativa_AplicarNormativa @TERM, @CRN, @RES_NormativaId
									EXEC dbo.spBitacoras_RegistraBitacora 9, @TERM, @CRN, NULL, NULL,NULL,NULL,NULL,'FLUJO','PROCESO AUTOMATICO', NULL,NULL,NULL,'Aplica normativa'
								END --1.1.3
											
							--CALIFICACIONES EN EXCEPCION
							EXEC spCalificacionesEnExcepcion_Revisar @TERM, @CRN

							--PREPARAR ENVIAR A BANNER
							SET @RES_ENV_BAN = (SELECT COUNT('x')
												FROM dbo.ArchivosCanvasFiltrado ACF
													INNER JOIN REPLICAS.DBO.GRUPO_ALUMNOS GA ON ACF.PIDMAlumno=GA.PIDM AND ACF.Periodo=GA.Periodo AND ACF.CRN=GA.CRN
													INNER JOIN [Replicas].[dbo].[PROFESORES] P ON ACF.PIDMProfesor=P.PIDM
												WHERE (ACF.Periodo=@TERM AND ACF.CRN=@CRN))

							IF @RES_ENV_BAN > 0 --1.1.4
								BEGIN--1.1.4
									INSERT INTO CalificacionesEnviadasBanner
										SELECT DISTINCT ACF.Periodo, ACF.CRN, GA.MATRICULA, ACF.PIDMAlumno, 
											IIF (ACF.GradeAlfa='FI', GradeNum, GradeAlfa) AS GradeAlfa, 
											@FECHA AS FechaAgregado, P.NOMINA, 
											IIF (ACF.GradeAlfa='FI', 'FI', '') AS Comentarios,0,
											ACF.Horas, ACF.Destacado, ACF.ComentarioDestacado
										FROM dbo.ArchivosCanvasFiltrado ACF
											INNER JOIN REPLICAS.DBO.GRUPO_ALUMNOS GA ON ACF.PIDMAlumno=GA.PIDM AND ACF.Periodo=GA.Periodo AND ACF.CRN=GA.CRN
											INNER JOIN [Replicas].[dbo].[PROFESORES] P ON ACF.PIDMProfesor=P.PIDM
										WHERE (ACF.Periodo=@TERM AND ACF.CRN=@CRN)

									EXEC dbo.spBitacoras_RegistraBitacora 9, @TERM, @CRN, NULL, NULL,NULL,NULL,NULL,'FLUJO','PROCESO AUTOMATICO', NULL,NULL,NULL,'Agregar alumnos a tabla para enviar a banner'
														
								END--1.1.4
							ELSE--1.1.4
								BEGIN--1.1.4
									EXEC dbo.spBitacoras_RegistraBitacora 9, @TERM, @CRN, NULL, NULL,NULL,NULL,0,'ERROR','PROCESO AUTOMATICO', NULL,NULL,NULL,'No existen alumnos en la tabla grupo_alumnos de replicas'
								END--1.1.4
						END--1.1.2
					ELSE --1.1.2
						BEGIN--1.1.2
							SET @IS_VALID_PMT6 = dbo.intReturnPMT6yMateriaExcepcionValida(@TERM, @CRN);
							IF @IS_VALID_PMT6 = 1--1.1.2.1
								BEGIN--1.1.2.1
									EXEC @RES_EX_NORMATIVA=dbo.spMateriasNormativas_RevisarMaterias @RES_Subject, @RES_Course, @TERM 
									IF @RES_EX_NORMATIVA=1--1.1.2.2
										BEGIN--1.1.2.2
											EXEC dbo.spNormativa_ObtenerInformacion @RES_Subject, @RES_Course, 1, @RES_NormativaId OUTPUT
											EXEC dbo.spNormativa_AplicarNormativa @TERM, @CRN, @RES_NormativaId
											EXEC dbo.spBitacoras_RegistraBitacora 9, @TERM, @CRN, NULL, NULL,NULL,NULL,NULL,'FLUJO','PROCESO AUTOMATICO', NULL,NULL,NULL,'Aplica normativa'
										END --1.1.2.2
											
									--CALIFICACIONES EN EXCEPCION
									EXEC spCalificacionesEnExcepcion_Revisar @TERM, @CRN

									--PREPARAR ENVIAR A BANNER
									SET @RES_ENV_BAN = (SELECT COUNT('x')
														FROM dbo.ArchivosCanvasFiltrado ACF
															INNER JOIN REPLICAS.DBO.GRUPO_ALUMNOS GA ON ACF.PIDMAlumno=GA.PIDM AND ACF.Periodo=GA.Periodo AND ACF.CRN=GA.CRN
															INNER JOIN [Replicas].[dbo].[PROFESORES] P ON ACF.PIDMProfesor=P.PIDM
														WHERE (ACF.Periodo=@TERM AND ACF.CRN=@CRN))

									IF @RES_ENV_BAN > 0 --1.1.2.2
										BEGIN--1.1.4
											INSERT INTO CalificacionesEnviadasBanner
												SELECT DISTINCT ACF.Periodo, ACF.CRN, GA.MATRICULA, ACF.PIDMAlumno, 
													IIF (ACF.GradeAlfa='FI', GradeNum, GradeAlfa) AS GradeAlfa, 
													@FECHA AS FechaAgregado, P.NOMINA, 
													IIF (ACF.GradeAlfa='FI', 'FI', '') AS Comentarios,0,
													ACF.Horas, ACF.Destacado, ACF.ComentarioDestacado
												FROM dbo.ArchivosCanvasFiltrado ACF
													INNER JOIN REPLICAS.DBO.GRUPO_ALUMNOS GA ON ACF.PIDMAlumno=GA.PIDM AND ACF.Periodo=GA.Periodo AND ACF.CRN=GA.CRN
													INNER JOIN [Replicas].[dbo].[PROFESORES] P ON ACF.PIDMProfesor=P.PIDM
												WHERE (ACF.Periodo=@TERM AND ACF.CRN=@CRN)

											EXEC dbo.spBitacoras_RegistraBitacora 9, @TERM, @CRN, NULL, NULL,NULL,NULL,NULL,'FLUJO','PROCESO AUTOMATICO', NULL,NULL,NULL,'Agregar alumnos a tabla para enviar a banner'
														
										END--1.1.2.2
								END--1.1.2.1
							ELSE--1.1.2.1
								BEGIN--1.1.2.1
									--SE ENCUENTRA EN LA TABLA DE EXCEPCION DE MateriaS O ES SEMANA 6 Y 12
									EXEC dbo.spBitacoras_RegistraBitacora 9, @TERM, @CRN, NULL, NULL,NULL,NULL,0,'ERROR','PROCESO AUTOMATICO', NULL,NULL,NULL,'Se encuentra en excepción de materias y es semana 6 ó 12'
									SET @MENSAJE_SALIDA = 'Se encuentra en excepción de materias y es semana 6 ó 12'
									SELECT @MENSAJE_SALIDA AS 'MENSAJE'
									DELETE FROM dbo.ArchivosCanvasFiltrado WHERE (Periodo=@TERM AND CRN = @CRN)
									RETURN
								END--1.1.2.1
							
						END--1.1.2
				END--1.1
			ELSE--1.1
				BEGIN --1.1
					SET @IS_VALID_PMT6 = dbo.intReturnPMT6yMateriaExcepcionValida(@TERM, @CRN);
					IF @IS_VALID_PMT6 = 1 --1.1.1
						BEGIN--1.1.1
							--ME TRAIGO LOS DATOS DE MateriaS DENTRO DE LA TABLA GRUPOS
							EXEC  dbo.spGrupos_TraerDatos @TERM, @CRN, 2, @RES_Subject OUTPUT
							EXEC  dbo.spGrupos_TraerDatos @TERM, @CRN, 3, @RES_Course OUTPUT

							EXEC @RES_EX_NORMATIVA=dbo.spMateriasNormativas_RevisarMaterias @RES_Subject, @RES_Course, @TERM 
							IF @RES_EX_NORMATIVA=1--1.1.3
								BEGIN--1.1.3
									EXEC dbo.spNormativa_ObtenerInformacion @RES_Subject, @RES_Course, 1, @RES_NormativaId OUTPUT
									EXEC dbo.spNormativa_AplicarNormativa @TERM, @CRN, @RES_NormativaId
									EXEC dbo.spBitacoras_RegistraBitacora 9, @TERM, @CRN, NULL, NULL,NULL,NULL,NULL,'FLUJO','PROCESO AUTOMATICO', NULL,NULL,NULL,'Aplica normativa'
								END --1.1.3
											
							--CALIFICACIONES EN EXCEPCION
							EXEC spCalificacionesEnExcepcion_Revisar @TERM, @CRN

							--PREPARAR ENVIAR A BANNER
							SET @RES_ENV_BAN = (SELECT COUNT('x')
												FROM dbo.ArchivosCanvasFiltrado ACF
													INNER JOIN REPLICAS.DBO.GRUPO_ALUMNOS GA ON ACF.PIDMAlumno=GA.PIDM AND ACF.Periodo=GA.Periodo AND ACF.CRN=GA.CRN
													INNER JOIN [Replicas].[dbo].[PROFESORES] P ON ACF.PIDMProfesor=P.PIDM
												WHERE (ACF.Periodo=@TERM AND ACF.CRN=@CRN))

							IF @RES_ENV_BAN > 0 --1.1.4
								BEGIN--1.1.4
									INSERT INTO CalificacionesEnviadasBanner
										SELECT DISTINCT ACF.Periodo, ACF.CRN, GA.MATRICULA, ACF.PIDMAlumno, 
											IIF (ACF.GradeAlfa='FI', GradeNum, GradeAlfa) AS GradeAlfa, 
											@FECHA AS FechaAgregado, P.NOMINA, 
											IIF (ACF.GradeAlfa='FI', 'FI', '') AS Comentarios,0,
											ACF.Horas, ACF.Destacado, ACF.ComentarioDestacado
										FROM dbo.ArchivosCanvasFiltrado ACF
											INNER JOIN REPLICAS.DBO.GRUPO_ALUMNOS GA ON ACF.PIDMAlumno=GA.PIDM AND ACF.Periodo=GA.Periodo AND ACF.CRN=GA.CRN
											INNER JOIN [Replicas].[dbo].[PROFESORES] P ON ACF.PIDMProfesor=P.PIDM
										WHERE (ACF.Periodo=@TERM AND ACF.CRN=@CRN)

									EXEC dbo.spBitacoras_RegistraBitacora 9, @TERM, @CRN, NULL, NULL,NULL,NULL,NULL,'FLUJO','PROCESO AUTOMATICO', NULL,NULL,NULL,'Agregar alumnos a tabla para enviar a banner'
														
								END--1.1.4
						ELSE--1.1.4
							BEGIN--1.1.4
								EXEC dbo.spBitacoras_RegistraBitacora 9, @TERM, @CRN, NULL, NULL,NULL,NULL,0,'ERROR','PROCESO AUTOMATICO', NULL,NULL,NULL,'No existen alumnos en la tabla grupo_alumnos de replicas'
							END--1.1.4
						END--1.1.1
					ELSE--1.1.1
						BEGIN--1.1.1
							--SE ENVIA MENSAJE DE ERROR DE SUBPeriodo NO Activo
							EXEC dbo.spBitacoras_RegistraBitacora 9, @TERM, @CRN, NULL, NULL,NULL,NULL,0,'ERROR','PROCESO AUTOMATICO', NULL,NULL,NULL,'No se encuentra dentro de los rangos de fechas del subperiodo campus'
							SET @MENSAJE_SALIDA = 'No se encuentra dentro de los rangos de fechas del subperiodo campus'
							SELECT @MENSAJE_SALIDA AS 'MENSAJE'
							DELETE FROM dbo.ArchivosCanvasFiltrado WHERE (Periodo=@TERM AND CRN = @CRN)
							RETURN
						END--1.1.1
				END --1.1
		END--1

	DELETE FROM dbo.ArchivosCanvasFiltrado WHERE (Periodo=@TERM AND CRN = @CRN)

END --End first
GO
/****** Object:  StoredProcedure [dbo].[spProcesoSC_GeneraSC]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ALEJANDRO CERVANTES
-- Create date: 06-07-2019
-- Description:	GENERA SC A TODOS LOS ALUMNOS QUE FALTARON POR AGREGARSELES Calificacion MEDIA HORA DESPUES DE QUE SE CERRO EL SUBPERIODO CAMPUS
-- =============================================
CREATE PROCEDURE [dbo].[spProcesoSC_GeneraSC]
	@TERM						VARCHAR(50),
	@ID_SUBPERIODO_CAMPUS			VARCHAR(50),
	@ID_CAMPUS						VARCHAR(10)
	AS
	BEGIN--EMPIEZA

		SET NOCOUNT ON;
		DECLARE @CONT_GRUPOS		INT
		DECLARE @REN_GRUPOS			INT
		DECLARE @CRN				INT
		DECLARE	@RES_LISTA_EXC		INT
		DECLARE @RES_SEM_6Y12		INT
		DECLARE @RES_SUBJECT		VARCHAR(10)
		DECLARE @RES_COURSE			VARCHAR(10)
		DECLARE @RES_SUBPERIODO		VARCHAR(20)
		DECLARE @IS_VALID_PMT6		INT

		DECLARE @GRUPOS_TEMP TABLE  
			( ID					INT IDENTITY(1,1)   NOT NULL ,			 
			TERM					VARCHAR(20) NOT NULL,
			ID_SP_CAMPUS			VARCHAR(20) NOT NULL,
			CRN					VARCHAR(20) NOT NULL,
			[Subject]				VARCHAR(20) NOT NULL,
			Course				VARCHAR(20) NOT NULL,
			NOMINA				VARCHAR(50)  NULL);

		DECLARE @GRUPOS_TEMP1 TABLE  
			( ID					INT IDENTITY(1,1)   NOT NULL ,			 
			  TERM					VARCHAR(20) NOT NULL,
			  ID_SP_CAMPUS			VARCHAR(20) NOT NULL,
			  CRN					VARCHAR(20) NOT NULL,
			  [SUBJECT]				VARCHAR(20) NOT NULL,
			  COURSE				VARCHAR(20) NOT NULL,
			  NOMINA				VARCHAR(50)  NULL);

		DECLARE @GRUPO_CON_ALUMNOS TABLE  
			( ID					INT IDENTITY(1,1)   NOT NULL ,  
			CAMPUS				VARCHAR(20)  NULL, 
			CRN					VARCHAR(20)  NULL, 
			TERM					VARCHAR(100)  NULL,
			[Subject]				VARCHAR(20)  NULL, 
			Course				VARCHAR(20)  NULL, 
			NOMINA				VARCHAR(20)  NULL, 
			PIDM					VARCHAR(20)  NULL, 
			MATRICULA				VARCHAR(20) NULL);

		DECLARE @PREPARA_ENVIAR_BANNER TABLE  
			( ID					INT IDENTITY(1,1)   NOT NULL ,  
			CAMPUS				VARCHAR(20)  NULL, 
			CRN					VARCHAR(20)  NULL, 
			TERM					VARCHAR(100)  NULL,
			[Subject]				VARCHAR(20)  NULL, 
			Course				VARCHAR(20)  NULL, 
			NOMINA				VARCHAR(20)  NULL, 
			PIDM					VARCHAR(20)  NULL, 
			MATRICULA				VARCHAR(20) NULL);

		--OBTENEMOS EL TIPO DE PERIODO PARA DELIMITAR EL Grupo
		EXEC DBO.spPeriodo_ObtenerAtributo @TERM, @ID_SUBPERIODO_CAMPUS, @RES_SUBPERIODO OUTPUT;

		DECLARE @TIPO_PERIODO		VARCHAR(20)
		DECLARE	@CONV_SUBPERIODO	VARCHAR(20)

		SET @CONV_SUBPERIODO = SUBSTRING(@ID_SUBPERIODO_CAMPUS,8,1)

		SELECT @TIPO_PERIODO =
			CASE --DETECTAMOS QUE TIPO DE PERIODO ES
				WHEN @CONV_SUBPERIODO = '1' THEN 'PMT1'
				WHEN @CONV_SUBPERIODO = '2' THEN 'PMT2'
				WHEN @CONV_SUBPERIODO = '3' THEN 'PMT3'
				WHEN @CONV_SUBPERIODO = '4' THEN 'PMT4'
				WHEN @CONV_SUBPERIODO = '5' THEN 'PMT5'
				WHEN @CONV_SUBPERIODO = '6' THEN 'PMT6'
				WHEN @CONV_SUBPERIODO = '7' THEN 'PMT7'
				WHEN @CONV_SUBPERIODO = '8' THEN 'PMT8'
				WHEN @CONV_SUBPERIODO = '9' THEN 'PMT9'
			END;



		--DELIMITAMOS LOS GRUPOS QUE TIENEN TIENEN PERIODO Y SON MT21
		WITH
		LIFE AS (SELECT CRN FROM REPLICAS.DBO.GRUPO_ATRIBUTOS c WHERE CLAVE_ATRIBUTO = 'LIFE'),
		PMT6 AS (SELECT CRN FROM REPLICAS.DBO.GRUPO_ATRIBUTOS c WHERE CLAVE_ATRIBUTO = 'PMT6'),
		MT21 AS (SELECT CRN FROM REPLICAS.DBO.GRUPO_ATRIBUTOS c WHERE CLAVE_ATRIBUTO = 'MT21'),
		PMT AS (SELECT CRN FROM REPLICAS.DBO.GRUPO_ATRIBUTOS c WHERE CLAVE_ATRIBUTO IN ('PMT1','PMT2','PMT3','PMT4','PMT5','PMT6')),
		LIFE_PMT6 AS (SELECT x.CRN FROM LIFE x, PMT6 y WHERE x.CRN = y.CRN),
		MT21_PMT AS (SELECT x.CRN FROM MT21 x, PMT y WHERE x.CRN = y.CRN)
		INSERT INTO @GRUPOS_TEMP1(TERM, ID_SP_CAMPUS, CRN, [Subject], Course, NOMINA) 
		SELECT G.TERM, G.CAMPUS,G.CRN, G.[Subject], G.Course, G.NOMINA  
		FROM Replicas.DBO.GRUPOS G 
		WHERE CRN IN (SELECT * FROM LIFE_PMT6
		union all
		SELECT * FROM MT21_PMT) AND CAMPUS = @ID_CAMPUS;

		IF @TIPO_PERIODO = 'PMT1' OR @TIPO_PERIODO = 'PMT2' OR @TIPO_PERIODO = 'PMT3'
			BEGIN
				INSERT INTO @GRUPOS_TEMP
					SELECT  gt.TERM,gt.ID_SP_CAMPUS, gt.CRN, gt.[SUBJECT],gt.COURSE, gt.NOMINA FROM @GRUPOS_TEMP1 gt 
					INNER JOIN GRUPO_atributos g on gt.crn=g.crn and g.term=gt.term 
					where g.CLAVE_ATRIBUTO=@RES_SUBPERIODO 
					EXCEPT
					SELECT  gt.TERM,gt.ID_SP_CAMPUS, gt.CRN, gt.[SUBJECT],gt.COURSE, gt.NOMINA FROM @GRUPOS_TEMP1 gt 
					INNER JOIN GRUPO_atributos g on gt.crn=g.crn and g.term=gt.term 
					WHERE g.CLAVE_ATRIBUTO='STEC' 

			END 

		IF @TIPO_PERIODO = 'PMT7' OR @TIPO_PERIODO = 'PMT8' OR @TIPO_PERIODO = 'PMT9'
			BEGIN
				INSERT INTO @GRUPOS_TEMP
					SELECT  gt.TERM,gt.ID_SP_CAMPUS, gt.CRN, gt.[SUBJECT],gt.COURSE, gt.NOMINA FROM @GRUPOS_TEMP1 gt 
					INNER JOIN Replicas.dbo.GRUPO_atributos g on gt.crn=g.crn and g.term=gt.term 
					where g.CLAVE_ATRIBUTO=@RES_SUBPERIODO
					INTERSECT
					SELECT  gt.TERM,gt.ID_SP_CAMPUS, gt.CRN, gt.[SUBJECT],gt.COURSE, gt.NOMINA FROM @GRUPOS_TEMP1 gt 
					INNER JOIN Replicas.dbo.GRUPO_atributos g on gt.crn=g.crn and g.term=gt.term 
				WHERE g.CLAVE_ATRIBUTO='STEC' 
	
			END
		IF @TIPO_PERIODO = 'PMT4' OR @TIPO_PERIODO = 'PMT5' OR @TIPO_PERIODO = 'PMT6'
			BEGIN
				INSERT INTO @GRUPOS_TEMP
					SELECT gt.TERM,gt.ID_SP_CAMPUS, gt.CRN, gt.[SUBJECT],gt.COURSE, gt.NOMINA FROM @GRUPOS_TEMP1 gt 
					INNER JOIN Replicas.dbo.GRUPO_atributos g on gt.crn=g.crn and g.term=gt.term 
					where g.CLAVE_ATRIBUTO=@RES_SUBPERIODO
			END


		SET @REN_GRUPOS=1
		SET @CONT_GRUPOS=(SELECT COUNT(*) FROM @GRUPOS_TEMP)

--RECORREMOS TODOS LOS GRUPOS CON SUS ALUMNOS
	WHILE @CONT_GRUPOS >= @REN_GRUPOS
		BEGIN
		--SELECT @REN_GRUPOS
			--BUSCAR CRN PARA AVERIGUAR LA MATERIA
			SET @CRN = (SELECT CRN FROM @GRUPOS_TEMP WHERE ID=@REN_GRUPOS)
		

			--ME TRAIGO LOS DATOS DE MATERIAS DENTRO DE LA TABLA GRUPOS
			EXEC DBO.SP_TRAER_DATOS_GRUPOS @TERM, @CRN, 2, @RES_SUBJECT OUTPUT
			EXEC DBO.SP_TRAER_DATOS_GRUPOS @TERM, @CRN, 3, @RES_COURSE OUTPUT

			--SI SE ENCUENTRA ACTIVO  REVISO SI ESTA EN LISTA DE EXCEPCION	
			EXEC @RES_LISTA_EXC= spMateriasExcepcion_VerificaMaterias @RES_SUBJECT, @RES_COURSE, @TERM
			EXEC @RES_SEM_6Y12 = spSemana6Y12_RevisarSemana @TERM, @CRN

			SET @IS_VALID_PMT6 = dbo.intReturnPMT6yMateriaExcepcionValida(@TERM, @CRN);
			IF @IS_VALID_PMT6 = 1--1.1
				BEGIN--1.1
					--TE TRAES EL GRUPO CON SUS ALUMNOS
					INSERT INTO @GRUPO_CON_ALUMNOS
						SELECT G.CAMPUS, G.CRN, G.TERM, G.[SUBJECT], G.COURSE, G.NOMINA, GA.PIDM, GA.MATRICULA 
						FROM Replicas.dbo.GRUPOS G	
						INNER JOIN Replicas.dbo.GRUPO_ALUMNOS GA ON G.TERM=GA.PERIODO AND G.CRN=GA.CRN
						WHERE GA.PERIODO=@TERM AND GA.CRN=@CRN

					
					--PREPARAS INFORMACIÓN CON CALIFICACION SC Y LLENAS LA TABLA ENVIAR A BANNER	
					INSERT INTO @PREPARA_ENVIAR_BANNER
						SELECT GCA.CAMPUS, GCA.CRN, GCA.TERM, GCA.[SUBJECT], GCA.COURSE,
							   GCA.NOMINA, GCA.PIDM, GCA.MATRICULA
						FROM @GRUPO_CON_ALUMNOS GCA
						LEFT JOIN CalificacionesEnviadasBanner CEB 
								   ON GCA.PIDM=CEB.PIDM
						WHERE CEB.ID IS NULL

					 --INSERTAR CALIFICACIONES EN TABLA DE ENVIAR A BANNER
					 INSERT INTO CalificacionesEnviadasBanner
						SELECT TERM, CRN, MATRICULA, PIDM, 'SC', DBO.dReturnDate(GETDATE()), NOMINA, 'PROCESO SC', 0, 0,0,''
						FROM @PREPARA_ENVIAR_BANNER
				END--1.1
			ELSE--1.1
				BEGIN--1.1
					IF @RES_LISTA_EXC=0 AND @RES_SEM_6Y12= 0
						BEGIN

							--TE TRAES EL GRUPO CON SUS ALUMNOS
							INSERT INTO @GRUPO_CON_ALUMNOS
								SELECT G.CAMPUS, G.CRN, G.TERM, G.[SUBJECT], G.COURSE, G.NOMINA, GA.PIDM, GA.MATRICULA 
								FROM Replicas.dbo.GRUPOS G	
								INNER JOIN Replicas.dbo.GRUPO_ALUMNOS GA ON G.TERM=GA.PERIODO AND G.CRN=GA.CRN
								WHERE GA.PERIODO=@TERM AND GA.CRN=@CRN

					
							--PREPARAS INFORMACIÓN CON CALIFICACION SC Y LLENAS LA TABLA ENVIAR A BANNER	
							INSERT INTO @PREPARA_ENVIAR_BANNER
								SELECT GCA.CAMPUS, GCA.CRN, GCA.TERM, GCA.[SUBJECT], GCA.COURSE,
									   GCA.NOMINA, GCA.PIDM, GCA.MATRICULA
								FROM @GRUPO_CON_ALUMNOS GCA
								LEFT JOIN CalificacionesEnviadasBanner CEB 
										   ON GCA.PIDM=CEB.PIDM
								WHERE CEB.ID IS NULL

							 --INSERTAR CALIFICACIONES EN TABLA DE ENVIAR A BANNER
							 INSERT INTO CalificacionesEnviadasBanner
								SELECT TERM, CRN, MATRICULA, PIDM, 'SC', DBO.dReturnDate(GETDATE()), NOMINA, 'PROCESO SC', 0, 0,0,''
								FROM @PREPARA_ENVIAR_BANNER
								
						END
				END--1.1
			
				EXEC dbo.spBitacoras_RegistraBitacora 10, @TERM, @CRN, NULL,NULL,@ID_SUBPERIODO_CAMPUS,NULL,NULL, 'FLUJO', 'GENERACION DE SC', NULL,NULL,@ID_CAMPUS, 'Generacion de sc sin errores'	;
				DELETE FROM @GRUPO_CON_ALUMNOS
				DELETE FROM @PREPARA_ENVIAR_BANNER

			SET @REN_GRUPOS=@REN_GRUPOS+1

		END--TERMINA WHILE
	
	END--TERMINA
GO
/****** Object:  StoredProcedure [dbo].[spReporteAvanceCapturado_ObtenerReporte]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		EctoTec
-- Create date: 
-- Description:	Procedimiento que permite obener un reporte de avance de caputras de campus.
-- =============================================
CREATE PROCEDURE [dbo].[spReporteAvanceCapturado_ObtenerReporte] 
	-- Add the parameters for the stored procedure here
	@campus nvarchar(4), 
	@periodo nvarchar(6), 
	@subperiodo int,
	@capturado bit,
	@profesor nvarchar(50) = null,
	@nomina nvarchar(50) = null,
	@materia nvarchar(50) = null,
	@fechaCaptura date = null

    AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;

        IF @capturado = 0
            BEGIN
                SELECT DISTINCT camp.desc_campus CAMPUS, gpo.CRN, gpo.TERM, CAST(@subperiodo as nvarchar(1)) SUBPERIODO, gpo.Materia, gpo.Subject, gpo.Course, gpo.INSCRITOS, prof.NOMINA + ' ' + prof.Nombre + ' ' + prof.AP_PATERNO + ' ' + prof.AP_MATERNO NOMINA, null FechaAgregado, null UsuarioCalifico
                FROM            Replicas.dbo.GRUPOS AS gpo WITH (NOLOCK)
                LEFT JOIN Replicas.dbo.PROFESORES prof WITH (NOLOCK) ON gpo.NOMINA = prof.NOMINA
                LEFT JOIN Replicas.dbo.CAMPUS camp WITH (NOLOCK) ON gpo.CAMPUS = camp.clave_campus
                WHERE ((@campus = '%' OR gpo.CAMPUS = @campus)
                AND gpo.TERM = @periodo
                --AND gpo.SUBPERIODO = @subperiodo
                AND NOT EXISTS (SELECT 'x' FROM  dbo.CalificacionesEnviadasBanner AS env WITH (NOLOCK) WHERE gpo.TERM = env.TERM AND gpo.CRN = env.CRN)
                AND EXISTS (SELECT 'x' FROM Replicas.dbo.GRUPO_ATRIBUTOS attr WITH (NOLOCK) WHERE attr.TERM = gpo.TERM AND attr.CRN = gpo.CRN 
                                AND (
                                    (@subperiodo <= 6 AND attr.CLAVE_ATRIBUTO = 'PMT'+ CAST(@subperiodo as nvarchar)) 
                                    OR (@subperiodo = 7 AND attr.CLAVE_ATRIBUTO = 'PMT1')
                                    OR (@subperiodo = 8 AND attr.CLAVE_ATRIBUTO = 'PMT2')
                                    OR (@subperiodo = 9 AND attr.CLAVE_ATRIBUTO = 'PMT3')
                                    ) )
                AND EXISTS (SELECT 'x' FROM Replicas.dbo.GRUPO_ATRIBUTOS attr WITH (NOLOCK) WHERE attr.TERM = gpo.TERM AND attr.CRN = gpo.CRN 
                                AND (
                                    (@subperiodo <= 6 AND attr.CLAVE_ATRIBUTO = 'MT21') 
                                    OR (@subperiodo > 6 AND attr.CLAVE_ATRIBUTO = 'STEC')) )
                AND (@profesor IS NULL OR gpo.NOMINA = @profesor)
                AND (@materia IS NULL OR gpo.Materia = @materia));
            END
        ELSE
            BEGIN
                SELECT DISTINCT camp.desc_campus CAMPUS, gpo.CRN, gpo.TERM, CAST(@subperiodo as nvarchar(1)) SUBPERIODO, gpo.Materia, gpo.Subject, gpo.Course, gpo.INSCRITOS, prof.NOMINA + ' ' + prof.Nombre + ' ' + prof.AP_PATERNO + ' ' + prof.AP_MATERNO NOMINA, env.FechaAgregado, env.UsuarioCalifico
                FROM            Replicas.dbo.GRUPOS AS gpo WITH (NOLOCK) INNER JOIN
                                        dbo.CalificacionesEnviadasBanner AS env WITH (NOLOCK) ON gpo.TERM = env.TERM AND gpo.CRN = env.CRN
                LEFT JOIN Replicas.dbo.PROFESORES prof WITH (NOLOCK) ON gpo.NOMINA = prof.NOMINA
                LEFT JOIN Replicas.dbo.CAMPUS camp WITH (NOLOCK) ON gpo.CAMPUS = camp.clave_campus
                WHERE (@campus = '%' OR gpo.CAMPUS = @campus)
                AND gpo.TERM = @periodo
                --AND gpo.SUBPERIODO = @subperiodo
                AND EXISTS (SELECT 'x' FROM Replicas.dbo.GRUPO_ATRIBUTOS attr WITH (NOLOCK) WHERE (attr.TERM = gpo.TERM AND attr.CRN = gpo.CRN 
                                AND (
                                    (@subperiodo <= 6 AND attr.CLAVE_ATRIBUTO = 'PMT'+ CAST(@subperiodo as nvarchar)) 
                                    OR (@subperiodo = 7 AND attr.CLAVE_ATRIBUTO = 'PMT1')
                                    OR (@subperiodo = 8 AND attr.CLAVE_ATRIBUTO = 'PMT2')
                                    OR (@subperiodo = 9 AND attr.CLAVE_ATRIBUTO = 'PMT3')
                                    ) ))
                AND EXISTS (SELECT 'x' FROM Replicas.dbo.GRUPO_ATRIBUTOS attr WITH (NOLOCK) WHERE (attr.TERM = gpo.TERM AND attr.CRN = gpo.CRN 
                                AND (
                                    (@subperiodo <= 6 AND attr.CLAVE_ATRIBUTO = 'MT21') 
                                    OR (@subperiodo > 6 AND attr.CLAVE_ATRIBUTO = 'STEC')) ))
                AND (@profesor IS NULL OR gpo.NOMINA = @profesor)
                AND (@nomina IS NULL OR env.UsuarioCalifico = @nomina)
                AND (@materia IS NULL OR gpo.Materia = @materia)
                AND (@fechaCaptura IS NULL OR CAST(env.FechaAgregado as date) = @fechaCaptura);		
            END;
    END
GO
/****** Object:  StoredProcedure [dbo].[spSemana6Y12_RevisarSemana]    Script Date: 28/10/2019 10:59:06 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		ALEJANDRO CERVANTES
-- Create date: 08-07-2019
-- Description:	SE REVISA SI SE ENCUENTRAN LAS MATERIAS EN SEMANA 6 Y 12
-- =============================================
CREATE PROCEDURE [dbo].[spSemana6Y12_RevisarSemana]
	@TERM			VARCHAR(20),
	@CRN			INT
	AS
	BEGIN

		SET NOCOUNT ON;
		DECLARE @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC VARCHAR(10);
		DECLARE @ID_CAMPUS VARCHAR(20)=(SELECT CAMPUS FROM Replicas.dbo.GRUPOS WHERE TERM = @TERM AND CRN=@CRN)
		DECLARE @IS_SEMANA_TEC VARCHAR(10)
		SET @IS_SEMANA_TEC = (SELECT CLAVE_ATRIBUTO FROM REPLICAS.DBO.GRUPO_ATRIBUTOS WHERE TERM =@TERM AND CRN = @CRN AND CLAVE_ATRIBUTO = 'STEC')
		DECLARE @CLAVE_ATRIBUTO_PERIODO_TEMP VARCHAR(10) = (SELECT CLAVE_ATRIBUTO FROM Replicas.DBO.GRUPO_ATRIBUTOS WHERE TERM =@TERM AND CRN = @CRN AND CLAVE_ATRIBUTO IN ('PMT1','PMT2','PMT3','PMT4','PMT5','PMT6'))

		IF ISNULL(@IS_SEMANA_TEC,'') <>''
			BEGIN
				--SI EL CONTADOR ES MAYOR A DOS SIGNIFICA QUE SON SEMANAS TEC
				SELECT @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC =
				CASE --DETECTAMOS QUE NUMERO DE PERIODO DE SEMANA TEC ES
					WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT1' THEN '7'
					WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT2' THEN '8'
					WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT3' THEN '9'
				END
			END
		ELSE
			BEGIN
				SELECT @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC=
					CASE --EN EL ELSE SON LOS SUBPERIODOS DEL 1 AL 6
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT1' THEN '1'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT2' THEN '2'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT3' THEN '3'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT4' THEN '4'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT5' THEN '5'
						WHEN @CLAVE_ATRIBUTO_PERIODO_TEMP = 'PMT6' THEN '6'
					END
			END		

		--REVISO SI SON SEMANAS 6 Y 12
		IF (@CLAVE_ATRIBUTO_PERIODO_TEMP='1')
		OR (@CLAVE_ATRIBUTO_PERIODO_TEMP='2')
		OR (@CLAVE_ATRIBUTO_PERIODO_TEMP='4')
			BEGIN
				--SELECT 1 AS 'MENSAJE'

				RETURN 1
			END
		ELSE
			BEGIN
				--SELECT 0 AS 'MENSAJE'
				RETURN 0
				
			END

	END
GO