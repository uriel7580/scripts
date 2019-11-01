
ALTER TABLE [dbo].[CalificacionesPermitidas] ADD [Descripcion]  VARCHAR (150) NOT NULL  CONSTRAINT [DF_CalificacionesPermitidas_Descripcion]  DEFAULT ('')

PRINT N'Creando [dbo].[SubperiodosNacional].[IX_SubperiodosNacional]...';
GO
CREATE UNIQUE NONCLUSTERED INDEX [IX_SubperiodosNacional]
    ON [dbo].[SubperiodosNacional]([Idperiodo] ASC, [SubperiodoNacionalId] ASC);
GO
PRINT N'Creando [dbo].[FK_SubperiodosNacionalCampusFechaFin_SubperiodosNacionalCampusFechaFin]...';
GO
ALTER TABLE [dbo].[SubperiodosNacionalCampusFechaFin] WITH NOCHECK
    ADD CONSTRAINT [FK_SubperiodosNacionalCampusFechaFin_SubperiodosNacionalCampusFechaFin] FOREIGN KEY ([Idperiodo], [IdperiodoNacional]) REFERENCES [dbo].[SubperiodosNacional] ([Idperiodo], [SubperiodoNacionalId]);
GO
PRINT N'Creando [dbo].[FK_SubperiodosNacionalCampusFechaInicio_SubperiodosNacional]...';
GO
ALTER TABLE [dbo].[SubperiodosNacionalCampusFechaInicio] WITH NOCHECK
    ADD CONSTRAINT [FK_SubperiodosNacionalCampusFechaInicio_SubperiodosNacional] FOREIGN KEY ([Idperiodo], [IdperiodoNacional]) REFERENCES [dbo].[SubperiodosNacional] ([Idperiodo], [SubperiodoNacionalId]);
GO
ALTER TABLE [dbo].[SubperiodosNacionalCampusFechaFin] WITH CHECK CHECK CONSTRAINT [FK_SubperiodosNacionalCampusFechaFin_SubperiodosNacionalCampusFechaFin];
ALTER TABLE [dbo].[SubperiodosNacionalCampusFechaInicio] WITH CHECK CHECK CONSTRAINT [FK_SubperiodosNacionalCampusFechaInicio_SubperiodosNacional];
