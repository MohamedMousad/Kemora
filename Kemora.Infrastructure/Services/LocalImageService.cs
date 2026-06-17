using Kemora.Application.Interfaces;
using Microsoft.AspNetCore.Hosting;
using Microsoft.Extensions.Configuration;
using System;
using System.IO;
using System.Threading.Tasks;

namespace Kemora.Infrastructure.Services
{
    /// <summary>
    /// Saves uploaded images to the local wwwroot/uploads/ folder and returns a server-relative URL.
    /// Suitable for development / on-premises deployments that don't need cloud storage.
    /// </summary>
    public class LocalImageService : IImageService
    {
        private readonly string _uploadsFolder;
        private readonly string _baseUrl;

        public LocalImageService(IWebHostEnvironment env, IConfiguration config)
        {
            // Store files under wwwroot/uploads (auto-created if missing)
            _uploadsFolder = Path.Combine(env.WebRootPath ?? env.ContentRootPath, "uploads");
            Directory.CreateDirectory(_uploadsFolder);

            // Use BaseUrl from appsettings.json (e.g. "http://localhost:5299")
            _baseUrl = (config["BaseUrl"] ?? "http://localhost:5299").TrimEnd('/');
        }

        public async Task<string?> UploadImageAsync(Stream fileStream, string fileName)
        {
            if (fileStream == null || fileStream.Length == 0)
                return null;

            // Make the filename unique to avoid collisions
            var ext = Path.GetExtension(fileName);
            var uniqueName = $"{Guid.NewGuid():N}{ext}";
            var filePath = Path.Combine(_uploadsFolder, uniqueName);

            await using var fs = new FileStream(filePath, FileMode.Create, FileAccess.Write);
            await fileStream.CopyToAsync(fs);

            // Return the public URL pointing to the static-file middleware
            return $"{_baseUrl}/uploads/{uniqueName}";
        }
    }
}
