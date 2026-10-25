using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ASP.NET_WebApp.Models;
using Microsoft.AspNetCore.Authorization;
using Supabase;
using Microsoft.IdentityModel.Tokens;
using StudentManagement.Models;

namespace ASP.NET_WebApp.Controllers;

public class StudentsController : Controller
{

    private readonly ILogger<StudentsController> _logger;

    private readonly Client _supabase;
    private readonly Client _adminDb;

    public StudentsController(ILogger<StudentsController> logger, Client Supabase, [FromKeyedServices("admin")] Client adminDb)
    {
        _logger = logger;
        _supabase = Supabase;
        _adminDb = adminDb;

    }



    [HttpGet]
    // [Authorize(Roles = "admin")]
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

    // [Authorize(Roles = "admin")]
    [Authorize]
    public async Task<IActionResult> GetStudent(string id)
    {
        try
        {
            var student = await _adminDb.From<StudentsModel>()
                .Where(s => s.id == id)
                .Single();

            if (student == null)
                return View("_NotFound");


            return View("StudentInfo", student);
        }
        catch (Exception ex)
        {
            ViewBag.Error = $"Failed to load student";
            _logger.LogError(ex, "Failed to load student {Id}", id);
            return View("_NotFound");

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
            await LoadPractitioners();
            StudentsModel student = await _supabase.From<StudentsModel>().Where(a => a.id == id).Single();

            if (student is null)
            {
                return View("_NotFound");
            }

            return View(student);
        }
        catch (Exception error)
        {
            return View("_NotFound");
        }
    }

    [HttpPost]
    [Authorize(Roles = "admin")]
    [Authorize]
    public async Task<IActionResult> Update(StudentsModel student)
    {
        try
        {
            if (!ModelState.IsValid)
            {
                await LoadPractitioners();
                return View(student);
            }

            await _supabase
       .From<StudentsModel>()
       .Where(s => s.id == student.id)
       .Set(s => s.StudentNumber, student.StudentNumber)
       .Set(s => s.FirstName, student.FirstName)
       .Set(s => s.Surname, student.Surname)
       .Set(s => s.PreferredName, student.PreferredName)
       .Set(s => s.DateOfBirth, student.DateOfBirth)
       .Set(s => s.Gender, student.Gender)
     .Set(s => s.AssignedPractitionerID, student.AssignedPractitionerID)

       .Update();

            return RedirectToAction("Index");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Failed to Update student");
            await LoadPractitioners();
            ModelState.AddModelError(string.Empty, "Something went wrong while saving. Please try again.");
            return View(student);
        }
    }

    private async Task LoadPractitioners()
    {
        var response = await _supabase.From<PractitionerModel>().Get();
        ViewBag.Practitioners = response.Models;
    }


    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
