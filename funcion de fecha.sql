alter table [dbo].[NORMATIVAS] add FECHA_AGREGADO datetime not null CONSTRAINT DF_NORMATIVAS_FECHA_AGREGADO default (getdate())


SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[dReturnDate]( @dFecha as datetime)

returns DATETIME

as
begin
    DECLARE @D AS datetimeoffset
    SET @D = CONVERT(datetimeoffset, @Dfecha) AT TIME ZONE 'Central Standard Time (Mexico)'
    RETURN CONVERT(datetime, @D);
end

/****** Object:  UserDefinedFunction [dbo].[vCReturnSubPeriodo]    Script Date: 19/09/2019 12:30:12 p. m. ******/
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

--declare @TERM varchar(20);
--declare @CRN int;
--declare @TIPO int;
DECLARE @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC VARCHAR(10);
--SET @TERM = '201913'
--SET @CRN = 10272
--SET @TIPO = 1

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

----select @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC
--set @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC = '201913-1'
--	-- Return the result of the function
	RETURN @ATRIBUTO_PERIODO_NORMAL_O_SEMANATEC

END
GO