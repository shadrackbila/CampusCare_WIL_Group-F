using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ASP.NET_WebApp.Models;
using Supabase;
using Microsoft.AspNetCore.Authorization;


namespace ASP.NET_WebApp.Controllers;

public class NotificationsController : Controller
{

    private readonly Client _supabaseClient;
    private readonly IConfiguration _config;

    private readonly ILogger<NotificationsModel> _logger;
    private readonly Client _adminDb;



    public NotificationsController(ILogger<NotificationsModel> logger, Client SupabaseClient, IConfiguration config, [FromKeyedServices("admin")] Client adminDb)
    {
        _supabaseClient = SupabaseClient;
        _logger = logger;
        _config = config;
        _adminDb = adminDb;
    }

    [HttpGet]
    [Authorize]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> Index()
    {
        try
        {

            var response = await _adminDb.From<RefferalsModel>().Get();


            List<RefferalsModel> refferals = response.Models;
            return View(refferals);
        }
        catch (Exception error)
        {
            _logger.LogError(error.Message);
            return View();
        }
    }






    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}


