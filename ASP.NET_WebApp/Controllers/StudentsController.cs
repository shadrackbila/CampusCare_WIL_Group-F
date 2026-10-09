using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ASP.NET_WebApp.Models;

namespace ASP.NET_WebApp.Controllers;

public class StudentsController : Controller
{
    [HttpGet]
    public IActionResult Index()
    {
        return View();
    }

    public IActionResult GetStudent(string id)
    {

        return View("StudentInfo");
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
