---
description: How to add a new backend feature end-to-end (entity → controller), with correct file paths for the current project.
---

# Add Backend Feature Workflow

## Prerequisites
- Read `Kemora/.agent/skills/kemora-backend/SKILL.md` for architecture context
- Ensure SQL Server (SQLEXPRESS) is running

## 1. Create/modify the Domain Entity
- File: `d:\FlutterProjects\gitlove\Kemora\Kemora.Domain\Entities\<EntityName>.cs`
- Use `[Key]` for primary keys, configure composite keys in DbContext
- Add navigation properties for relationships

## 2. Update the DbContext
- File: `d:\FlutterProjects\gitlove\Kemora\Kemora.Infrastructure\Data\ApplicationDbContext.cs`
- Add `DbSet<Entity>` property
- Configure relationships in `OnModelCreating` (especially cascade delete prevention)

## 3. Create and run the EF migration
```powershell
cd d:\FlutterProjects\gitlove\Kemora
dotnet ef migrations add <MigrationName> --project Kemora.Infrastructure --startup-project Kemora.Api
```

## 4. Create DTOs
- File: `d:\FlutterProjects\gitlove\Kemora\Kemora.Application\DTOs\<Feature>Dtos.cs`
- Create Request DTOs with `[Required]`, `[StringLength]`, `[Range]` validation attributes
- Create Response DTOs (flat, no navigation properties)

## 5. Add AutoMapper mappings
- File: `d:\FlutterProjects\gitlove\Kemora\Kemora.Application\Mapping\MappingProfile.cs`
- Map Entity → ResponseDto with `.ForMember()` for custom mappings

## 6. Create the repository interface (if needed)
- File: `d:\FlutterProjects\gitlove\Kemora\Kemora.Domain\Interfaces\I<Entity>Repository.cs`
- Extend `IRepository<Entity>` for specialized queries

## 7. Create the repository implementation (if needed)
- File: `d:\FlutterProjects\gitlove\Kemora\Kemora.Infrastructure\Repositories\<Entity>Repository.cs`
- Extend `Repository<Entity>` and implement specialized methods

## 8. Create the service interface
- File: `d:\FlutterProjects\gitlove\Kemora\Kemora.Application\Interfaces\I<Feature>Service.cs`
- Define business methods with DTOs as params/returns

## 9. Create the service implementation
- File: `d:\FlutterProjects\gitlove\Kemora\Kemora.Application\Services\<Feature>Service.cs` (business logic)
- OR: `d:\FlutterProjects\gitlove\Kemora\Kemora.Infrastructure\Services\<Feature>Service.cs` (external integrations)
- Inject IMapper, IUnitOfWork, repositories via constructor

## 10. Register in DI container
- File: `d:\FlutterProjects\gitlove\Kemora\Kemora.Api\Program.cs`
- Add `builder.Services.AddScoped<IInterface, Implementation>()` in the appropriate section

## 11. Create the API Controller
- File: `d:\FlutterProjects\gitlove\Kemora\Kemora.Api\Controllers\<Feature>Controller.cs`
- Use `[ApiController]`, `[Route("api/[controller]")]`
- Use `[Authorize]` or `[Authorize(Roles = "Admin")]`
- Inject the service interface via constructor
- Return `Ok()`, `NotFound()`, `BadRequest()` consistently

## 12. Verify the build
```powershell
cd d:\FlutterProjects\gitlove\Kemora
dotnet build Kemora.sln
```
Must exit with code 0.
