using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ASP.NET_WebApp.Models;
using Supabase;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication;
using StudentManagement.Models;

namespace ASP.NET_WebApp.Controllers;

public class RefferalsController : Controller
{

    private readonly Client _supabaseClient;
    private readonly IConfiguration _config;

    private readonly ILogger<RefferalsModel> _logger;
    private readonly Client _adminDb;



    public RefferalsController(ILogger<RefferalsModel> logger, Client SupabaseClient, IConfiguration config, [FromKeyedServices("admin")] Client adminDb)
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

    [HttpGet]
    [Authorize]
    [Authorize(Roles = "admin")]
    public async Task<IActionResult> Search(string? searchTerm)
    {
        ViewData["SearchTerm"] = searchTerm;

        var response = await _adminDb.From<RefferalsModel>().Get();
        var results = response.Models.AsEnumerable();

        if (!string.IsNullOrWhiteSpace(searchTerm))
        {
            results = results.Where(r =>
                (r.Student?.StudentNumber?.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) ?? false) ||
                (r.PeerEducator?.Email?.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) ?? false) ||
                  (r.PeerEducator?.PersonnelNumber?.Contains(searchTerm, StringComparison.OrdinalIgnoreCase) ?? false)
                );
        }

        return View("Index", results.ToList());
    }

    [HttpGet]
    [Authorize]

    public async Task<IActionResult> Create(string studentId)
    {
        try
        {
            if (string.IsNullOrWhiteSpace(studentId))
                return View("_NotFound");

            var model = new RefferalsModel();
            model.StudentID = studentId;


            return View(model);
        }
        catch (Exception error)
        {
            _logger.LogError(error.Message);
            return View();
        }
    }

    [HttpPost]
    [Authorize]
    public async Task<IActionResult> Create(RefferalsModel model)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);

            if (string.IsNullOrEmpty(userId))
            {
                return RedirectToAction("Login", "Account");
            }


            model.RefferalDate = DateTime.UtcNow;
            model.id = Guid.NewGuid().ToString();
            model.RefferalsStaus = "in_progress";
            model.PeerEducatorID = userId;
            await _adminDb.From<RefferalsModel>().Insert(model);

            return RedirectToAction("PeerEducators", "Home");
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


