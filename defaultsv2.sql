ALTER TABLE [dbo].[ArchivosCanvas] ADD  CONSTRAINT [DF_ArchivosCanvas_GradeNum]  DEFAULT ('') FOR [GradeNum]
ALTER TABLE [dbo].[ArchivosCanvas] ADD  CONSTRAINT [DF_ArchivosCanvas_GradeAlfa]  DEFAULT ('') FOR [GradeAlfa]
ALTER TABLE [dbo].[ArchivosCanvas] ADD  DEFAULT ((0)) FOR [Horas]
ALTER TABLE [dbo].[ArchivosCanvas] ADD  DEFAULT ((0)) FOR [Destacado]
ALTER TABLE [dbo].[ArchivosCanvas] ADD  DEFAULT ('') FOR [ComentarioDestacado]
ALTER TABLE [dbo].[ArchivosCanvasFiltrado] ADD  CONSTRAINT [DF_ArchivosCanvasFiltrado_GradeNum]  DEFAULT ('') FOR [GradeNum]
ALTER TABLE [dbo].[ArchivosCanvasFiltrado] ADD  CONSTRAINT [DF_ArchivosCanvasFiltrado_GradeAlfa]  DEFAULT ('') FOR [GradeAlfa]
ALTER TABLE [dbo].[ArchivosCanvasFiltrado] ADD  DEFAULT ((0)) FOR [Horas]
ALTER TABLE [dbo].[ArchivosCanvasFiltrado] ADD  DEFAULT ((0)) FOR [Destacado]
ALTER TABLE [dbo].[ArchivosCanvasFiltrado] ADD  DEFAULT ('') FOR [ComentarioDestacado]
ALTER TABLE [dbo].[Bitacora_CargaCalificiones] ADD  CONSTRAINT [DF_Bitacora_CargaCalificiones_FechaRegistro]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_CargaCalificiones] ADD  CONSTRAINT [DF_Bitacora_CargaCalificiones_Comentarios]  DEFAULT ('') FOR [Comentarios]
ALTER TABLE [dbo].[Bitacora_Correos] ADD  CONSTRAINT [DF_Bitacora_Correos_FechaRegistro]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_GeneracionReportes] ADD  CONSTRAINT [DF_Bitacora_GeneracionReportes_FechaRegistro]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_GeneracionReportes] ADD  CONSTRAINT [DF_Bitacora_GeneracionReportes_Comentarios]  DEFAULT ('') FOR [Comentarios]
ALTER TABLE [dbo].[Bitacora_MateriasExcepcion] ADD  CONSTRAINT [DF_Bitacora_MateriasExcepcion_FechaRegistro]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_MateriasExcepcion] ADD  CONSTRAINT [DF_Bitacora_MateriasExcepcion_Comentarios]  DEFAULT ('') FOR [Comentarios]
ALTER TABLE [dbo].[Bitacora_MateriasNormativa] ADD  CONSTRAINT [DF_Bitacora_MateriasNormativa_FechaRegistro]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_MateriasNormativa] ADD  CONSTRAINT [DF_Bitacora_MateriasNormativa_Comentarios]  DEFAULT ('') FOR [Comentarios]
ALTER TABLE [dbo].[Bitacora_Normativas] ADD  CONSTRAINT [DF_Bitacora_Normativas_FechaRegistro]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_Normativas] ADD  CONSTRAINT [DF_Bitacora_Normativas_Comentarios]  DEFAULT ('') FOR [Comentarios]
ALTER TABLE [dbo].[Bitacora_ProcesoAutomatico] ADD  CONSTRAINT [DF_Bitacora_ProcesoAutomatico]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_ProcesoAutomatico] ADD  CONSTRAINT [DF_Bitacora_ProcesoAutomatico_Comentarios]  DEFAULT ('') FOR [Comentarios]
ALTER TABLE [dbo].[Bitacora_ProcesoSC] ADD  CONSTRAINT [DF_Bitacora_ProcesoSC_FechaRegistro]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_ProcesoSC] ADD  CONSTRAINT [DF_Bitacora_ProcesoSC_Comentarios]  DEFAULT ('') FOR [Comentarios]
ALTER TABLE [dbo].[Bitacora_RolesAdmin] ADD  CONSTRAINT [DF_Bitacora_RolesAdmin_FechaRegistro]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_RolesAdmin] ADD  CONSTRAINT [DF_Bitacora_RolesAdmin_Comentarios]  DEFAULT ('') FOR [Comentarios]
ALTER TABLE [dbo].[Bitacora_SubPeriodoCampus] ADD  CONSTRAINT [DF_Bitacora_SubPeriodoCampus_FechaRegistro]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_SubPeriodoCampus] ADD  CONSTRAINT [DF_Bitacora_SubPeriodoCampus_Comentarios]  DEFAULT ('') FOR [Comentarios]
ALTER TABLE [dbo].[Bitacora_SubperiodoNacional] ADD  CONSTRAINT [DF_Bitacora_SubperiodoNacional_FechaRegistro]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_SubperiodoNacional] ADD  CONSTRAINT [DF_Bitacora_SubperiodoNacional_Comentarios]  DEFAULT ('') FOR [Comentarios]
ALTER TABLE [dbo].[CalificacionesEnviadasBanner] ADD  CONSTRAINT [DF_CalificacionesEnviadasBanner_FechaAgregado]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaAgregado]
ALTER TABLE [dbo].[CalificacionesEnviadasBanner] ADD  CONSTRAINT [DF_CalificacionesEnviadasBanner_Comentarios]  DEFAULT ('') FOR [Comentarios]
ALTER TABLE [dbo].[CalificacionesEnviadasBanner] ADD CONSTRAINT [DF_CalificacionesEnviadasBanner_Horas] DEFAULT ((0)) FOR [Horas]
ALTER TABLE [dbo].[CalificacionesEnviadasBanner] ADD CONSTRAINT [DF_CalificacionesEnviadasBanner_Destacado] DEFAULT ((0)) FOR [Destacado]
ALTER TABLE [dbo].[CalificacionesEnviadasBanner] ADD CONSTRAINT [DF_CalificacionesEnviadasBanner_ComentarioDestacado] DEFAULT ('') FOR [ComentarioDestacado]
ALTER TABLE [dbo].[CalificacionesPermitidas] ADD  CONSTRAINT [DF_CalificacionesPermitidas_ClaveEjerAcadFin]  DEFAULT ('') FOR [ClaveEjerAcadFin]
ALTER TABLE [dbo].[CatalogoBitacoras] ADD  CONSTRAINT [DF_CatalogoBitacoras_Nivel]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaAgregado]
ALTER TABLE [dbo].[CatalogoBitacoras] ADD  CONSTRAINT [DF_CatalogoBitacoras_Comentarios]  DEFAULT ('') FOR [Comentarios]
ALTER TABLE [dbo].[MateriasNormativas] ADD  CONSTRAINT [DF_MateriasNormativas_FechaAgregado]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaAgregado]
ALTER TABLE [dbo].[Normativas] ADD  CONSTRAINT [DF_Normativas_Descripcion]  DEFAULT ('') FOR [Descripcion]
ALTER TABLE [dbo].[Normativas] ADD  CONSTRAINT [DF_Normativas_Nota]  DEFAULT ('') FOR [Nota]
ALTER TABLE [dbo].[Normativas] ADD  CONSTRAINT [DF_Normativas_FechaAgregado]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaAgregado]
ALTER TABLE [dbo].[SubperiodosCampus] ADD  CONSTRAINT [DF_SubperiodosCampus_Nivel]  DEFAULT ('05-Profesional') FOR [Nivel]
ALTER TABLE [dbo].[SubperiodosCampus] ADD  CONSTRAINT [DF_SubperiodosCampus_FechaAgregado]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaAgregado]
ALTER TABLE [dbo].[SubperiodosNacionalCampusFechaFin] ADD  CONSTRAINT [DF_SuperiodosNacionalCampusFechaFin_FechaAgregado]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaAgregado]
ALTER TABLE [dbo].[SubperiodosNacionalCampusFechaInicio] ADD  CONSTRAINT [DF_SuperiodosNacionalCampusFechaInicio_FechaAgregado]  DEFAULT ([DBO].[dReturnDate](getdate())) FOR [FechaAgregado]
-- ALTER TABLE [dbo].[MateriasNormativas]  WITH CHECK ADD  CONSTRAINT [FK_MateriasNormativas_CatalogoNormativas] FOREIGN KEY([NormativaId])
-- REFERENCES [dbo].[CatalogoNormativas] ([Id])
--ALTER TABLE [dbo].[MateriasNormativas] CHECK CONSTRAINT [FK_MateriasNormativas_CatalogoNormativas]
-- ALTER TABLE [dbo].[Normativas]  WITH CHECK ADD  CONSTRAINT [FK_Normativas_CatalogoNormativas] FOREIGN KEY([NormativaId])
-- REFERENCES [dbo].[CatalogoNormativas] ([Id])
-- ALTER TABLE [dbo].[Normativas] CHECK CONSTRAINT [FK_Normativas_CatalogoNormativas]
-- ALTER TABLE [dbo].[RolesUsuario]  WITH CHECK ADD  CONSTRAINT [FK_RolesUsuario_Roles] FOREIGN KEY([RolesId])
-- REFERENCES [dbo].[Roles] ([Id])
-- ALTER TABLE [dbo].[RolesUsuario] CHECK CONSTRAINT [FK_RolesUsuario_Roles]
-- ALTER TABLE [dbo].[RolesUsuario]  WITH CHECK ADD  CONSTRAINT [FK_RolesUsuario_Usuarios] FOREIGN KEY([UsuariosNomina])
-- REFERENCES [dbo].[Usuarios] ([Nomina])
-- ALTER TABLE [dbo].[RolesUsuario] CHECK CONSTRAINT [FK_RolesUsuario_Usuarios]
--NO funcionan
-- ALTER TABLE [dbo].[SubperiodosNacionalCampusFechaFin]  WITH CHECK ADD  CONSTRAINT [FK_SubperiodosNacionalCampusFechaFin_SubperiodosNacionalCampusFechaFin] FOREIGN KEY([Idperiodo], [IdperiodoNacional])
-- REFERENCES [dbo].[SubperiodosNacional] ([Idperiodo], [SubperiodoNacionalId])
-- ALTER TABLE [dbo].[SubperiodosNacionalCampusFechaFin] CHECK CONSTRAINT [FK_SubperiodosNacionalCampusFechaFin_SubperiodosNacionalCampusFechaFin]
-- ALTER TABLE [dbo].[SubperiodosNacionalCampusFechaInicio]  WITH CHECK ADD  CONSTRAINT [FK_SubperiodosNacionalCampusFechaInicio_SubperiodosNacional] FOREIGN KEY([Idperiodo], [IdperiodoNacional])
-- REFERENCES [dbo].[SubperiodosNacional] ([Idperiodo], [SubperiodoNacionalId])
-- ALTER TABLE [dbo].[SubperiodosNacionalCampusFechaInicio] CHECK CONSTRAINT [FK_SubperiodosNacionalCampusFechaInicio_SubperiodosNacional]
-- /****** Object:  StoredProcedure [dbo].[SP_BORRAR_LISTAS_CORREOS]    Script Date: 28/10/2019 10:40:42 a. m. ******/
-- SET ANSI_NULLS ON
-- GO
-- SET QUOTED_IDENTIFIER ON
-- GO
-- -- =============================================
-- -- Author:      Alejandro Cervantes
-- -- Create Date: 03-09-2019
-- -- Description: Borra la tabla de notificaciones cuando ya fueron enviados.
-- -- =============================================
-- CREATE PROCEDURE [dbo].[SP_BORRAR_LISTAS_CORREOS]
-- AS
-- BEGIN

-- DELETE FROM EmailNotifications

-- END
-- GO