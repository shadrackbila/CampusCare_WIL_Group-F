using StudentManagement.Models;

namespace ASP.NET_WebApp.Models;

public class HomeModel
{

    public List<StudentsModel> Students { get; set; } = new();
    public List<PractitionerModel> Practitioners { get; set; } = new();

    public int TotalPeerEducators { get; set; }

    public List<AppointmentsModel> Appointments { get; set; } = new();

}