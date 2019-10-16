--CREACION DE LOS DEFAULTS
ALTER TABLE [dbo].[Bitacora_CargaCalificiones] ADD  CONSTRAINT [DF_Bitacora_CargaCalificiones_FechaRegistro]  DEFAULT (DBO.dReturnDate(getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_GeneracionReportes] ADD  CONSTRAINT [DF_Bitacora_GeneracionReportes_FechaRegistro]  DEFAULT (DBO.dReturnDate(getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_MateriasExcepcion] ADD  CONSTRAINT [DF_Bitacora_MateriasExcepcion_FechaRegistro]  DEFAULT (DBO.dReturnDate(getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_MateriasNormativa] ADD  CONSTRAINT [DF_Bitacora_MateriasNormativa_FechaRegistro]  DEFAULT (DBO.dReturnDate(getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_Normativas] ADD  CONSTRAINT [DF_Bitacora_Normativas_FechaRegistro]  DEFAULT (DBO.dReturnDate(getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_ProcesoAutomatico] ADD  CONSTRAINT [DF_Bitacora_ProcesoAutomatico_FechaRegistro]  DEFAULT (DBO.dReturnDate(getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_RolesAdmin] ADD  CONSTRAINT [DF_Bitacora_RolesAdmin_FechaRegistro]  DEFAULT (DBO.dReturnDate(getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_SubPeriodoCampus] ADD  CONSTRAINT [DF_Bitacora_SubPeriodoCampus_FechaRegistro]  DEFAULT (DBO.dReturnDate(getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[Bitacora_SubperiodoNacional] ADD  CONSTRAINT [DF_Bitacora_SubperiodoNacional_FechaRegistro]  DEFAULT (DBO.dReturnDate(getdate())) FOR [FechaRegistro]
ALTER TABLE [dbo].[CalificacionesEnviadasBanner] ADD  CONSTRAINT [DF_CalificacionesEnviadasBanner_FechaAgregado]  DEFAULT (DBO.dReturnDate(getdate())) FOR [FechaAgregado]
ALTER TABLE [dbo].[CatalogoBitacoras] ADD CONSTRAINT [DF_CatalogoBitacoras_Nivel] DEFAULT (DBO.dReturnDate(getdate())) FOR [FechaAgregado]
ALTER TABLE [dbo].[SubperiodosCampus] ADD  CONSTRAINT [DF_SubperiodosCampus_Nivel]  DEFAULT ('05-Profesional') FOR [Nivel]
ALTER TABLE [dbo].[SubperiodosCampus] ADD  CONSTRAINT [DF_SubperiodosCampus_FechaAgregado]  DEFAULT (DBO.dReturnDate(getdate())) FOR [FechaAgregado]
GO
ALTER TABLE ArchivosCanvas add CONSTRAINT DF_ArchivosCanvas_GradeNum default '' for GradeNum
ALTER TABLE ArchivosCanvas add CONSTRAINT DF_ArchivosCanvas_GradeAlfa default '' for GradeAlfa
ALTER TABLE ArchivosCanvasFiltrado add CONSTRAINT DF_ArchivosCanvasFiltrado_GradeNum default '' for GradeNum
ALTER TABLE ArchivosCanvasFiltrado add CONSTRAINT DF_ArchivosCanvasFiltrado_GradeAlfa default '' for GradeAlfa
ALTER TABLE Bitacora_CargaCalificiones add CONSTRAINT DF_Bitacora_CargaCalificiones_Comentarios default '' for Comentarios
ALTER TABLE Bitacora_GeneracionReportes add CONSTRAINT DF_Bitacora_GeneracionReportes_Comentarios default '' for Comentarios
ALTER TABLE Bitacora_MateriasExcepcion add CONSTRAINT DF_Bitacora_MateriasExcepcion_Comentarios default '' for Comentarios
ALTER TABLE Bitacora_MateriasNormativa add CONSTRAINT DF_Bitacora_MateriasNormativa_Comentarios default '' for Comentarios
ALTER TABLE Bitacora_Normativas add CONSTRAINT DF_Bitacora_Normativas_Comentarios default '' for Comentarios
ALTER TABLE Bitacora_ProcesoAutomatico add CONSTRAINT DF_Bitacora_ProcesoAutomatico_Comentarios default '' for Comentarios
ALTER TABLE Bitacora_RolesAdmin add CONSTRAINT DF_Bitacora_RolesAdmin_Comentarios default '' for Comentarios
ALTER TABLE Bitacora_SubPeriodoCampus add CONSTRAINT DF_Bitacora_SubPeriodoCampus_Comentarios default '' for Comentarios
ALTER TABLE Bitacora_SubperiodoNacional add CONSTRAINT DF_Bitacora_SubperiodoNacional_Comentarios default '' for Comentarios
ALTER TABLE CalificacionesEnviadasBanner add CONSTRAINT DF_CalificacionesEnviadasBanner_Comentarios default '' for Comentarios
ALTER TABLE CalificacionesPermitidas add CONSTRAINT DF_CalificacionesPermitidas_ClaveEjerAcadFin default '' for ClaveEjerAcadFin
ALTER TABLE CatalogoBitacoras add CONSTRAINT DF_CatalogoBitacoras_Comentarios default '' for Comentarios
ALTER TABLE Normativas add CONSTRAINT DF_Normativas_Descripcion default '' for Descripcion
ALTER TABLE Normativas add CONSTRAINT DF_Normativas_Nota default '' for Nota
ALTER TABLE Normativas add CONSTRAINT DF_Normativas_FechaAgregado default (DBO.dReturnDate(getdate())) for FechaAgregado
GO