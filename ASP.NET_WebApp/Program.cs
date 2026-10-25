using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc.Authorization;
using Supabase;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllersWithViews();

builder.Services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Account/Login";
        options.AccessDeniedPath = "/Account/Login";

        options.ExpireTimeSpan = TimeSpan.FromHours(2);
        options.SlidingExpiration = true;
    });

var supabaseUrl = builder.Configuration["Supabase:Url"];
var supabaseKey = builder.Configuration["Supabase:AnonKey"];

var options = new SupabaseOptions
{
    AutoRefreshToken = true,
    AutoConnectRealtime = false
};

builder.Services.AddSingleton(provider =>
{
    var client = new Client(supabaseUrl, supabaseKey, options);
    return client;
});

var serviceKey = builder.Configuration["Supabase:ServiceRoleKey"];
var adminOptions = new SupabaseOptions
{
    AutoRefreshToken = false,
    AutoConnectRealtime = false
};

builder.Services.AddKeyedSingleton<Client>("admin", (provider, key) =>
{
    var client = new Client(supabaseUrl, serviceKey, adminOptions);
    client.InitializeAsync().GetAwaiter().GetResult();
    return client;
});

// builder.Services.AddControllersWithViews(options =>
// {
//     var policy = new AuthorizationPolicyBuilder()
//         .RequireAuthenticatedUser()
//         .Build();
//     options.Filters.Add(new AuthorizeFilter(policy));
// });

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapStaticAssets();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}")
    .WithStaticAssets();


app.Run();
