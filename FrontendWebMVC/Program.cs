using FrontendWebMVC;
using System.Text.Json;

var options = new JsonSerializerOptions()
{
    PropertyNameCaseInsensitive = true,
    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
};

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSignalR();
builder.Services.AddDaprClient(client =>
{
    client.UseJsonSerializationOptions(options);
});
builder.Services.AddControllersWithViews().AddDapr();

// Add services to the container.
var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
}
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();
app.UseCloudEvents();
app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");
app.MapSubscribeHandler();
app.MapHub<SignalRHub>("/signalrhub");
app.Run();
