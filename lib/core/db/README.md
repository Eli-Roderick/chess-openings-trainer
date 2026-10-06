# core/db

The drift database (`AppDatabase`), table definitions, DAOs and migrations. Opened on a background isolate with WAL. Every schema change bumps `schemaVersion`, adds a migration and a migration test with schemas exported to `drift_schemas/`.
