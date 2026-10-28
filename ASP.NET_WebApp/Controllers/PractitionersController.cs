
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

    private readonly IConfiguration _config;
    public PractitionersController(ILogger<PractitionersController> logger, Client SupabaseClient, IConfiguration config)
    {
        _supabaseClient = SupabaseClient;
        _logger = logger;
        _config = config;
    }


    [HttpGet]
    [Authorize(Roles = "admin")]
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
            ModelState.AddModelError(string.Empty, error.Message);
            _logger.LogError(error.Message);
            return View();
        }
    }


    [HttpGet]
    [Authorize(Roles = "admin")]
    [Authorize]
    public IActionResult ConfirmDelete(string id)
    {
        ViewBag.type = "Practitioner.";
        return View("_ConfirmDelete");
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    [Authorize(Roles = "admin")]
    [Authorize]
    public async Task<IActionResult> Delete(string id)
    {
        if (id.IsNullOrEmpty())
        {
            return View("_NotFound");
        }

        try
        {

            var practitioner = await _supabaseClient.From<PractitionerModel>()
          .Where(a => a.ID == id)
          .Single();

            if (practitioner == null)
                return View("_NotFound");

            var admin = _supabaseClient.AdminAuth(_config["Supabase:ServiceRoleKey"] ?? "");

            string? authEmail = practitioner.Email;
            await _supabaseClient.From<PractitionerModel>().Where(a => a.ID == id).Delete();

            if (!string.IsNullOrEmpty(authEmail))
            {
                var result = await admin.ListUsers(filter: authEmail);
                var user = result?.Users?.FirstOrDefault(u =>
                    string.Equals(u.Email, authEmail, StringComparison.OrdinalIgnoreCase));

                if (user == null)
                    return View("_NotFound");


                await _supabaseClient.From<UserRoles>().Where(u => u.UserID == user.Id).Delete();

                await admin.DeleteUser(user.Id);

            }

            return RedirectToAction("Index");
        }
        catch (Exception error)
        {
            ViewBag.Error = "Practioner still has student appointmnts.";
            return View("_NotFound");
        }
    }

    [HttpGet]
    [Authorize(Roles = "admin")]
    [Authorize]
    public IActionResult Create()
    {
        return View();
    }

    [HttpPost]
    [Authorize(Roles = "admin")]
    [Authorize]
    public async Task<IActionResult> Create(PractitionerModel practitioner)
    {
        if (!ModelState.IsValid)
        {
            return View(practitioner);
        }

        try
        {
            string serviceKey = _config["Supabase:ServiceRoleKey"] ?? "";
            string baseUrl = _config["Supabase:BaseUrl"] ?? "";
            string supabaseUrl = _config["Supabase:Url"] ?? "";

            var admin = _supabaseClient.AdminAuth(serviceKey);

            var invited = await admin.InviteUserByEmail(practitioner.Email, new Supabase.Gotrue.InviteUserByEmailOptions
            {
                RedirectTo = $"{baseUrl}/Account/InvitedUser"
            });

            if (!invited)
            {
                TempData["Failed"] = "Invitation failed.";
                return View(practitioner);
            }

            var result = await admin.ListUsers(filter: practitioner.Email);
            var user = result?.Users?.FirstOrDefault(u =>
                string.Equals(u.Email, practitioner.Email, StringComparison.OrdinalIgnoreCase));

            if (user == null)
            {
                TempData["Failed"] = "Invitation sent, but user not found.";
                return View(practitioner);
            }


            UserRoles userRole = new UserRoles();
            userRole.UserID = user.Id ?? "";

            if (practitioner.Role == "peer_educator")
            {
                userRole.UserRole = "peer_educator";
            }
            else
            {
                userRole.UserRole = "practitioner";
            }

            var adminDb = new Supabase.Client(supabaseUrl, serviceKey, new Supabase.SupabaseOptions
            {
                AutoRefreshToken = false,
                AutoConnectRealtime = false
            });
            await adminDb.InitializeAsync();

            await adminDb.From<UserRoles>().Insert(userRole);

            practitioner.UserID = user.Id;
            await adminDb.From<PractitionerModel>().Insert(practitioner);


            return RedirectToAction("Index");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to create practitioner");
            ModelState.AddModelError(string.Empty, ex.Message);
            return View(practitioner);
        }
    }

    [HttpGet]
    [Authorize]
    [Authorize(Roles = "admin")]
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
    [Authorize(Roles = "admin")]
    [Authorize]
    public async Task<IActionResult> Update(PractitionerModel practitioner)
    {
        if (!ModelState.IsValid)
        {
            return View(practitioner);
        }

        try
        {

            string serviceKey = _config["Supabase:ServiceRoleKey"] ?? "";
            string baseUrl = _config["Supabase:BaseUrl"] ?? "";
            string supabaseUrl = _config["Supabase:Url"] ?? "";

            var adminDb = new Supabase.Client(supabaseUrl, serviceKey, new Supabase.SupabaseOptions
            {
                AutoRefreshToken = false,
                AutoConnectRealtime = false
            });
            await adminDb.InitializeAsync();

            await adminDb
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
