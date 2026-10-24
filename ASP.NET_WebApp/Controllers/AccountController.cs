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


    public AccountController(ILogger<SetPasswordModel> logger, Client SupabaseClient, IConfiguration config)
    {
        _supabaseClient = SupabaseClient;
        _logger = logger;
        _config = config;

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


        try
        {
            var session = await _supabaseClient.Auth.VerifyTokenHash(
                model.TokenHash, Supabase.Gotrue.Constants.EmailOtpType.Invite);

            var userId = session?.User?.Id;
            if (userId == null)
            {
                ModelState.AddModelError("", "This invite link is invalid or has expired.");
                return View(model);
            }

            var admin = _supabaseClient.AdminAuth(_config["Supabase:ServiceRoleKey"] ?? "");
            await admin.UpdateUserById(userId, new Supabase.Gotrue.AdminUserAttributes
            {
                Password = model.Password
            });


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
            var session = await _supabaseClient.Auth.SignIn(model.UserName, model.Password);

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

            ModelState.AddModelError("", "Invalid username or password.");
        }
        catch (Exception ex)
        {
            ModelState.AddModelError("", ex.Message);
        }

        return View();


    }



    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}


