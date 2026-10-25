using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ASP.NET_WebApp.Models;
using Microsoft.AspNetCore.Authorization;
using Supabase;
using StudentManagement.Models;
using System.Security.Claims;
using Microsoft.IdentityModel.Tokens;

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

            ViewBag.PeerEducators = homeObj.Practitioners.Count(p => p.Role == "peer_educator");


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
        try
        {
            HomeModel homeObj = new HomeModel();

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrEmpty(userId))
            {
                return RedirectToAction("Login", "Account");
            }

            var appointmentResponse = await _adminDb.From<AppointmentsModel>().Get();
            var studentsResponse = await _adminDb.From<StudentsModel>().Get();
            var practitioner = await _adminDb.From<PractitionerModel>().Where(p => p.UserID == userId).Single();


            homeObj.Appointments = appointmentResponse.Models.Where(a => a.Student?.AssignedPractitionerInfo?.UserID == userId).ToList();
            homeObj.Students = studentsResponse.Models.Where(s => s.AssignedPractitionerInfo?.UserID == userId).ToList();

            ViewBag.PractitionerDetails = $"{practitioner?.Title} {practitioner?.FullName}";

            return View(homeObj);
        }
        catch (Exception ex)
        {
            return View(new HomeModel());
        }
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
