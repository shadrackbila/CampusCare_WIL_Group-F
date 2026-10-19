using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ASP.NET_WebApp.Models;
using Microsoft.AspNetCore.Authorization;
using Supabase;
using StudentManagement.Models;
using Microsoft.IdentityModel.Tokens;

namespace ASP.NET_WebApp.Controllers;

public class PractitionersController : Controller
{

    private readonly Client _supabaseClient;
    private readonly ILogger<PractitionersController> _logger;

    public PractitionersController(ILogger<PractitionersController> logger, Client SupabaseClient)
    {
        _supabaseClient = SupabaseClient;
        _logger = logger;
    }

    [HttpGet]
    // [Authorize(Roles = "Admin")]
    [Authorize]
    public async Task<IActionResult> Index()
    {
        try
        {
            var response = await _supabaseClient.From<PractitionerModel>().Get();
            List<PractitionerModel> practitioners = response.Models;
            return View(practitioners);
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
        ViewBag.type = "Practitioner.";
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
            await _supabaseClient.From<PractitionerModel>().Where(a => a.ID == id).Delete();
            return RedirectToAction("Index");
        }
        catch (Exception error)
        {
            return View("_NotFound");
        }
    }

    [HttpGet]
    // [Authorize(Roles = "Admin")]
    [Authorize]
    public IActionResult Create()
    {
        return View();
    }

    [HttpPost]
    // [Authorize(Roles = "Admin")]
    [Authorize]
    public async Task<IActionResult> Create(PractitionerModel practitioner)
    {
        if (!ModelState.IsValid)
        {
            return View(practitioner);
        }

        try
        {
            await _supabaseClient.From<PractitionerModel>().Insert(practitioner);
            return RedirectToAction("Index");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to create practitioner");
            ModelState.AddModelError(string.Empty, "Something went wrong while saving. Please try again.");
            return View(practitioner);
        }
    }

    [HttpGet]
    [Authorize]
    public async Task<IActionResult> Update(string id)
    {
        if (id.IsNullOrEmpty())
        {
            return View("_NotFound");
        }

        try
        {
            PractitionerModel practitioner = await _supabaseClient.From<PractitionerModel>().Where(a => a.ID == id).Single();

            if (practitioner is null)
            {
                return View("_NotFound");
            }

            return View(practitioner);
        }
        catch (Exception error)
        {
            return View("_NotFound");
        }
    }


    [HttpPost]
    // [Authorize(Roles = "Admin")]
    [Authorize]
    public async Task<IActionResult> Update(PractitionerModel practitioner)
    {
        if (!ModelState.IsValid)
        {
            return View(practitioner);
        }

        try
        {
            await _supabaseClient
       .From<PractitionerModel>()
       .Where(p => p.ID == practitioner.ID)
       .Set(p => p.FullName, practitioner.FullName)
       .Set(p => p.Title, practitioner.Title)
       .Set(p => p.Role, practitioner.Role)
       .Set(p => p.Gender, practitioner.Gender)
       .Set(p => p.PersonnelNumber, practitioner.PersonnelNumber)
       .Update();

            return RedirectToAction("Index");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to Update practitioner");
            ModelState.AddModelError(string.Empty, "Something went wrong while saving. Please try again.");
            return View(practitioner);
        }
    }



    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
