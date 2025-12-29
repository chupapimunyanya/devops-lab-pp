var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

var logger = app.Logger;

app.MapGet("/", () =>
{
    logger.LogInformation("Main page was asked");
    return "DevOps Lab: Version 1.0 (Stable)";
});

app.MapGet("/health", () =>
{
    return Results.Ok("Healthy");
});

app.MapGet("/db-check", () =>
{
    var dbHost = Environment.GetEnvironmentVariable("DB_HOST") ?? "localhost";

    logger.LogInformation($"Checking DB connection to {dbHost}...");

    return $"Connected to Database at: {dbHost}";
});

app.Run();