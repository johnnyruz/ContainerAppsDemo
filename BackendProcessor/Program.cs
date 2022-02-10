using System.Text.Json;

var options = new JsonSerializerOptions()
{
    PropertyNameCaseInsensitive = true,
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
};

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddDaprClient(client =>
{
    client.UseJsonSerializationOptions(options);
});
builder.Services.AddControllers().AddDapr();
var appInsightsInstrumentationKey = Environment.GetEnvironmentVariable("AppInsightsInstrumentationKey");
if (!string.IsNullOrEmpty(appInsightsInstrumentationKey))
    builder.Services.AddApplicationInsightsTelemetry(appInsightsInstrumentationKey);

var app = builder.Build();

// Configure the HTTP request pipeline.

app.UseAuthorization();
app.UseCloudEvents();
app.MapControllers();
app.MapSubscribeHandler();
app.Run();
