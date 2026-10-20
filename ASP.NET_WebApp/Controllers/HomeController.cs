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
    public HomeController(Client Supabase)
    {
        _supabaseClient = Supabase;
    }

    // [Authorize(Roles = "Admin")]
    [Authorize]
    public async Task<IActionResult> Index()
    {

        try
        {
            HomeModel homeObj = new HomeModel();

            var appointmentResponse = await _supabaseClient.From<AppointmentsModel>().Get();
            var studentsResponse = await _supabaseClient.From<StudentsModel>().Get();
            var practitionersResponse = await _supabaseClient.From<PractitionerModel>().Get();


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
