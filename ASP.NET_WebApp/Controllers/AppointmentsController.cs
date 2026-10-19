using System.Diagnostics;
using Microsoft.AspNetCore.Mvc;
using ASP.NET_WebApp.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.IdentityModel.Tokens;
using Supabase;
using StudentManagement.Models;

namespace ASP.NET_WebApp.Controllers;

public class AppointmentsController : Controller
{
    private readonly Client _supabaseClient;
    private readonly ILogger<AppointmentsController> _logger;


    public AppointmentsController(ILogger<AppointmentsController> logger, Client Supabase)
    {
        _supabaseClient = Supabase;
        _logger = logger;
    }

    [HttpGet]
    // [Authorize(Roles = "Admin")]
    [Authorize]

    public async Task<IActionResult> Index()
    {
        try
        {

            var response = await _supabaseClient.From<AppointmentsModel>().Get();

            List<AppointmentsModel> appointments = response.Models;
            return View(appointments);
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

        ViewBag.type = "Appointment.";
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

            await _supabaseClient.From<AppointmentsModel>().Where(a => a.ID == id).Delete();

            return RedirectToAction("Index");
        }
        catch (Exception error)
        {
            return View("_NotFound");
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

            await LoadPractitioners();
            AppointmentsModel appointment = await _supabaseClient.From<AppointmentsModel>().Where(a => a.ID == id).Single();

            if (appointment is null)
            {
                return View("_NotFound");
            }

            return View(appointment);
        }
        catch (Exception error)
        {
            return View("_NotFound");
        }
    }


    [HttpPost]
    [Authorize]
    public async Task<IActionResult> Update(AppointmentsModel appointment)
    {
        try
        {

            if (string.IsNullOrEmpty(appointment.Student?.AssignedPractitionerID))
            {
                ModelState.AddModelError("Student.AssignedPractitionerID", "Please assign a practitioner.");
            }

            if (!ModelState.IsValid)
            {
                await LoadPractitioners();
                return View(appointment);
            }

            var existing = await _supabaseClient
                .From<AppointmentsModel>()
                .Where(a => a.ID == appointment.ID)
                .Single();

            if (existing is null)
            {
                return View("_NotFound");
            }

            bool rescheduled =
                (existing.AppointmentDate.Date != appointment.AppointmentDate.Date) ||
                (existing.AppointmentTime != appointment.AppointmentTime);

            var query = _supabaseClient
                .From<AppointmentsModel>()
                .Where(a => a.ID == appointment.ID)
                .Set(a => a.AppointmentDate, appointment.AppointmentDate)
                .Set(a => a.AppointmentTime, appointment.AppointmentTime);

            if (rescheduled)
            {
                query = query.Set(a => a.Status, "rescheduled");
            }


            var studentId = existing?.Student?.id;
            var newPractitionerId = appointment.Student?.AssignedPractitionerID;

            if (!string.IsNullOrWhiteSpace(studentId) &&
                !string.IsNullOrWhiteSpace(newPractitionerId) &&
                existing?.Student?.AssignedPractitionerID != newPractitionerId)
            {
                await _supabaseClient.From<StudentsModel>()
                    .Where(s => s.id == studentId)
                    .Set(s => s.AssignedPractitionerID, newPractitionerId)
                    .Update();
            }

            await query.Update();

            return RedirectToAction("Index");
        }
        catch (Exception ex)
        {
            await LoadPractitioners();
            _logger.LogError(ex, "Failed to Update appointment");
            ModelState.AddModelError(string.Empty, "Something went wrong while saving. Please try again.");
            return View(appointment);
        }
    }

    private async Task LoadPractitioners()
    {
        var response = await _supabaseClient.From<PractitionerModel>().Get();
        ViewBag.Practitioners = response.Models;
    }

    [ResponseCache(Duration = 0, Location = ResponseCacheLocation.None, NoStore = true)]
    public IActionResult Error()
    {
        return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
    }
}
