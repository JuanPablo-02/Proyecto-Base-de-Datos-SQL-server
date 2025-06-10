# TP Integrador – Bases de Datos Aplicada

Este repositorio contiene el Trabajo Práctico Integrador realizado para la materia **Bases de Datos Aplicada** (Ingeniería en Informática – UNLaM), correspondiente al Grupo 12.

## 📌 Descripción general

El proyecto implementa un sistema de gestión para turnos médicos, pacientes, estudios clínicos y prestadores de salud para el Hospital **Cure S.A.** La solución fue desarrollada en SQL Server y se estructura de manera modular.

Incluye:

- 🗂️ Diseño de base de datos relacional con más de 10 entidades normalizadas
- 🧱 Organización por **esquemas lógicos** (`Paciente_info`, `Medico_info`, `Turnos_info`, etc.)
- ⚙️ Implementación de **Stored Procedures** para alta, baja, modificación, validación e importación
- ✅ Definición de **restricciones**, claves primarias y foráneas, y validaciones (`CHECK`)
- 📋 Registro de acciones mediante un sistema de **logging** centralizado
- 🛡️ **Asignación de roles** con permisos específicos por actor del sistema (Paciente, Médico, Administrativo, etc.)
- 📂 **Importación de datos** desde archivos **CSV y JSON**, con lógica para manejar novedades mensuales, correcciones y validaciones automáticas
- 🧾 **Generación de archivos XML** para rendiciones de turnos atendidos a prestadoras, incluyendo datos del paciente, profesional y cita médica

## 📂 Estructura del proyecto

```
├── /scripts
│   ├── ENTREGA_3_GRUPO_12.sql  # Creación completa de la base y lógica del sistema
│   ├── ENTREGA_4_GRUPO_12.sql  # Importaciones de CSV/JSON, generación de XML (no incluido en este repo)
├── /documentacion
│   ├── Informes técnicos por entrega (on-premise y cloud)
├── /datasets
│   ├── CSV / JSON para importación de maestros
├── /testing
│   ├── Juegos de prueba y archivos con comentarios de verificación
├── README.md
```

## 🛠️ Tecnologías utilizadas

- **Microsoft SQL Server**
- T-SQL
- CSV, JSON, XML
- AWS / Azure / GCP (análisis de costos de hosting)

---

> 📧 Proyecto presentado y defendido mediante entregas sucesivas y coloquios.
