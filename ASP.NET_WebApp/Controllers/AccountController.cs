using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ASP.NET_WebApp.Models;
using Supabase;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authentication;

namespace ASP.NET_WebApp.Controllers;

public class AccountController : Controller
{

    private readonly Client _supabaseClient;

    public AccountController(Client supabaseClient)
    {
        _supabaseClient = supabaseClient;
    }

    [HttpGet]
    public IActionResult Login()
    {
        return View();
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

            if (session != null)
            {
                var claims = new List<Claim> { new Claim(ClaimTypes.Name, session.User.Email) };
                var claimsIdentity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);


                await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(claimsIdentity));

                return RedirectToAction("Index", "Home");
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


