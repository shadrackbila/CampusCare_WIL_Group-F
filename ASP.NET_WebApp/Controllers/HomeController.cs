using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ASP.NET_WebApp.Models;
using Microsoft.AspNetCore.Authorization;
using Supabase;

namespace ASP.NET_WebApp.Controllers;

public class HomeController : Controller
{

    private readonly Client _supabase;
    public HomeController(Client Supabase)
    {
        _supabase = Supabase;
    }

    // [Authorize(Roles = "Admin")]
    [Authorize]
    public IActionResult Index()
    {
        return View();
    }

    public IActionResult Privacy()
    {
        return View();
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
