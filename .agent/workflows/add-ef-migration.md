---
description: How to create and apply EF Core database migrations, with correct file paths for the current project.
---

# EF Core Migration Workflow

## 1. Create a new migration
```powershell
cd d:\FlutterProjects\gitlove\Kemora
dotnet ef migrations add <MigrationName> --project Kemora.Infrastructure --startup-project Kemora.Api
```
Replace `<MigrationName>` with a descriptive PascalCase name like `AddUserFollowsTable`.

## 2. Review the generated migration
Check the file created in `d:\FlutterProjects\gitlove\Kemora\Kemora.Infrastructure\Migrations\` to ensure it matches your expectations.

## 3. Apply migrations to the database
```powershell
cd d:\FlutterProjects\gitlove\Kemora
dotnet ef database update --project Kemora.Infrastructure --startup-project Kemora.Api
```

## 4. Rollback a migration (if needed)
```powershell
cd d:\FlutterProjects\gitlove\Kemora
dotnet ef database update <PreviousMigrationName> --project Kemora.Infrastructure --startup-project Kemora.Api
```

## 5. Remove last migration (if not applied)
```powershell
cd d:\FlutterProjects\gitlove\Kemora
dotnet ef migrations remove --project Kemora.Infrastructure --startup-project Kemora.Api
```
