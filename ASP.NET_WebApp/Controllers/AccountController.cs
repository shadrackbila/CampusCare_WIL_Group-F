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

public class AccountController : Controller
{

    private readonly Client _supabaseClient;
    private readonly IConfiguration _config;

    private readonly ILogger<SetPasswordModel> _logger;
    private readonly Client _adminDb;



    public AccountController(ILogger<SetPasswordModel> logger, Client SupabaseClient, IConfiguration config, [FromKeyedServices("admin")] Client adminDb)
    {
        _supabaseClient = SupabaseClient;
        _logger = logger;
        _config = config;
        _adminDb = adminDb;
    }

    [HttpGet]
    public IActionResult Login()
    {
        return View();
    }

    [HttpGet]
    public IActionResult InvitedUser(string token_hash)
    {
        if (string.IsNullOrEmpty(token_hash))
        {
            ViewBag.Error = "Invalid token.";
            return View("_NotFound");
        }


        return View(new SetPasswordModel { TokenHash = token_hash });
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> InvitedUser(SetPasswordModel model)
    {
        if (!ModelState.IsValid)
        {
            return View(model);
        }

        var userId = string.Empty;

        try
        {
            var session = await _supabaseClient.Auth.VerifyTokenHash(
                model.TokenHash, Supabase.Gotrue.Constants.EmailOtpType.Invite);

            userId = session?.User?.Id;

            if (string.IsNullOrEmpty(userId))
            {
                // await _adminDb.From<PractitionerModel>().Where(p => p.UserID == userId).Set(p => p.VerificationStatus, "expired").Update();

                ModelState.AddModelError("", "This invite link is invalid or has expired.");
                return View(model);
            }


            var admin = _supabaseClient.AdminAuth(_config["Supabase:ServiceRoleKey"] ?? "");
            await admin.UpdateUserById(userId, new Supabase.Gotrue.AdminUserAttributes
            {
                Password = model.Password
            });

            await _adminDb.From<PractitionerModel>().Where(p => p.UserID == userId).Set(p => p.VerificationStatus, "verified").Update();


            TempData["Success"] = "Password set. You can now sign in.";
            return RedirectToAction("Login");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to complete invite");
            ModelState.AddModelError("", "Something went wrong. Please request a new invite.");
            return View(model);
        }
    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Login(LoginViewModel model)
    {

        if (!ModelState.IsValid)
        {
            return View(model);
        }


        try
        {
            Supabase.Gotrue.Session? session = null;

            try
            {
                session = await _supabaseClient.Auth.SignIn(model.UserName, model.Password);
            }
            catch (Exception ex)
            {
                ModelState.AddModelError("", "Invalid username or password.");

            }

            if (session?.User != null)
            {
                var userId = session.User.Id;
                UserRoles? userRoles = await _supabaseClient.From<UserRoles>().Where(u => u.UserID == userId).Single();

                var practitioner = (await _supabaseClient.From<PractitionerModel>()
                                    .Where(p => p.UserID == userId)
                                    .Get()).Models.FirstOrDefault();

                var displayName = practitioner?.FullName ?? session.User.Email ?? model.UserName;

                var claims = new List<Claim> {
                    new Claim(ClaimTypes.NameIdentifier, userId),
                    new Claim(ClaimTypes.Name, displayName),
                    new Claim(ClaimTypes.Email, session.User.Email ?? model.UserName)
                    };

                if (userRoles != null)
                {
                    _logger.LogError($"User is : -------> {userRoles.UserRole}");
                    claims.Add(new Claim(ClaimTypes.Role, userRoles.UserRole));
                }
                else
                {
                    ModelState.AddModelError("", "User role unknown.");
                }

                var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
                await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(claimsIdentity));


                if (userRoles.UserRole == "admin")
                {
                    return RedirectToAction("Index", "Home");
                }
                else if (userRoles.UserRole == "practitioner")
                {
                    return RedirectToAction("Practitioners", "Home");
                }
                else if (userRoles.UserRole == "peer_educator")
                {
                    return RedirectToAction("PeerEducators", "Home");
                }

                ModelState.AddModelError("", "Access Denied.");

            }

        }
        catch (Exception ex)
        {
            ModelState.AddModelError("", ex.Message);
        }

        return View();


    }

    [HttpPost]
    [ValidateAntiForgeryToken]
    public async Task<IActionResult> Logout()
    {
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        return RedirectToAction("Login");
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}


