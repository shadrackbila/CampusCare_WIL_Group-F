
using System.ComponentModel.DataAnnotations;
using ASP.NET_WebApp.Models;
using StudentManagement.Models;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

[Table("appointments")]
public class AppointmentsModel : BaseModel
{

    [Key]
    [Column("id")]
    public string ID { get; set; } = string.Empty;

    [Reference(typeof(StudentsModel), ReferenceAttribute.JoinType.Left)]
    public StudentsModel? Student { get; set; }

    [Column("service_id")]
    public string ServiceID { get; set; } = string.Empty;

    [Column("appointment_date")]
    public DateTime AppointmentDate { get; set; }

    [Column("appointment_time")]
    public DateTime AppointmentTime { get; set; }

    [Column("status")]
    public string Status { get; set; } = string.Empty;

    [Column("booking_reference")]
    public string BookingReference { get; set; } = string.Empty;


}