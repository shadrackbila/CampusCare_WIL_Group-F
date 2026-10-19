
using System.ComponentModel.DataAnnotations;
using ASP.NET_WebApp.Models;
using Microsoft.AspNetCore.Mvc.ModelBinding.Validation;
using StudentManagement.Models;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

[Table("appointments")]
public class AppointmentsModel : BaseModel
{

    [Key]
    [PrimaryKey("id")]
    public string ID { get; set; } = string.Empty;

    [ValidateNever]
    [Reference(typeof(StudentsModel), ReferenceAttribute.JoinType.Left)]
    public StudentsModel? Student { get; set; }

    [Column("service_id")]
    public string ServiceID { get; set; } = string.Empty;

    [Required(ErrorMessage = "Please select an appointment date.")]
    [DataType(DataType.Date)]
    [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd}", ApplyFormatInEditMode = true)]
    [Column("appointment_date")]
    public DateTime AppointmentDate { get; set; }

    [Required(ErrorMessage = "Please select an appointment time.")]
    [DataType(DataType.Time)]
    [DisplayFormat(DataFormatString = @"{0:hh\:mm}", ApplyFormatInEditMode = true)]
    [Column("appointment_time")]
    public TimeSpan AppointmentTime { get; set; }

    [Column("status")]
    public string Status { get; set; } = string.Empty;

    [Column("booking_reference")]
    public string BookingReference { get; set; } = string.Empty;


}