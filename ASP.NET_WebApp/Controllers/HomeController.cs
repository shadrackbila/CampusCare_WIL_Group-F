using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ASP.NET_WebApp.Models;
using Microsoft.AspNetCore.Authorization;
using Supabase;
using StudentManagement.Models;

namespace ASP.NET_WebApp.Controllers;

public class HomeController : Controller
{

    private readonly Client _supabaseClient;
    private readonly Client _adminDb;
    public HomeController(Client Supabase, [FromKeyedServices("admin")] Client adminDb)
    {
        _supabaseClient = Supabase;
        _adminDb = adminDb;
    }

    // [Authorize(Roles = "Admin")]
    [Authorize]
    public async Task<IActionResult> Index()
    {

        try
        {
            HomeModel homeObj = new HomeModel();

            var appointmentResponse = await _adminDb.From<AppointmentsModel>().Get();
            var studentsResponse = await _adminDb.From<StudentsModel>().Get();
            var practitionersResponse = await _adminDb.From<PractitionerModel>().Get();


            homeObj.Appointments = appointmentResponse.Models;
            homeObj.Students = studentsResponse.Models;
            homeObj.Practitioners = practitionersResponse.Models;

            return View(homeObj);
        }
        catch (Exception ex)
        {
            return View(new HomeModel());
        }
    }

    [Authorize]
    public async Task<IActionResult> Practitioners()
    {
        return View();
    }

    [Authorize]
    public async Task<IActionResult> PeerEducators()
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
