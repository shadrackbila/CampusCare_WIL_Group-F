using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ASP.NET_WebApp.Models;
using Microsoft.AspNetCore.Authorization;
using Supabase;

namespace ASP.NET_WebApp.Controllers;

public class StudentsController : Controller
{

    private readonly ILogger<StudentsController> _logger;

    private readonly Client _supabase;

    public StudentsController(ILogger<StudentsController> logger, Client Supabase)
    {
        _logger = logger;
        _supabase = Supabase;
    }

    [HttpGet]
    [Authorize]
    public async Task<IActionResult> Index()
    {
        try
        {

            var response = await _supabase.From<StudentsModel>().Get();

            _logger.LogInformation("Loaded {Count} students", response.Models.Count);

            List<StudentsModel> students = response.Models;
            return View(students);
        }
        catch (Exception error)
        {
            _logger.LogError(error.Message);
            return View();
        }
    }

    [Authorize]
    public async Task<IActionResult> GetStudent(string id)
    {
        try
        {
            var student = await _supabase.From<StudentsModel>()
                .Where(s => s.id == id)
                .Single();

            if (student == null)
                return NotFound();


            return View("StudentInfo", student);
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to load student {Id}", id);
            return NotFound();
        }
    }



    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
