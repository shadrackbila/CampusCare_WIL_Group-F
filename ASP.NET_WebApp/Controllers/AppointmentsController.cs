using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ASP.NET_WebApp.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.IdentityModel.Tokens;
using Supabase;

namespace ASP.NET_WebApp.Controllers;

public class AppointmentsController : Controller
{
    private readonly Client _supabaseClient;
    private readonly ILogger<AppointmentsController> _logger;


    public AppointmentsController(ILogger<AppointmentsController> logger, Client Supabase)
    {
        _supabaseClient = Supabase;
        _logger = logger;
    }

    [HttpGet]
    // [Authorize(Roles = "Admin")]
    [Authorize]

    public async Task<IActionResult> Index()
    {
        try
        {

            var response = await _supabaseClient.From<AppointmentsModel>().Get();

            List<AppointmentsModel> appointments = response.Models;
            return View(appointments);
        }
        catch (Exception error)
        {
            _logger.LogError(error.Message);
            return View();
        }
    }

    [HttpGet]
    // [Authorize(Roles = "Admin")]
    [Authorize]

    public IActionResult ConfirmDelete(string id)
    {

        ViewBag.type = "Appointment.";
        return View("_ConfirmDelete");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    // [Authorize(Roles = "Admin")]
    [Authorize]

    public async Task<IActionResult> Delete(string id)
    {
        if (id.IsNullOrEmpty())
        {
            return View("_NotFound");
        }

        try
        {

            await _supabaseClient.From<AppointmentsModel>().Where(a => a.ID == id).Delete();

            return RedirectToAction("Index");
        }
        catch (Exception error)
        {
            return View("_NotFound");
        }

    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
