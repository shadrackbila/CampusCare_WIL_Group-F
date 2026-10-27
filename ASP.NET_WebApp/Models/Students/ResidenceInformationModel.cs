namespace ASP.NET_WebApp.Models;


using System.Text.Json.Serialization;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

[Table("student_residence")]
public class ResidenceInformationModel : BaseModel
{

    [Column("student_id")]
    public string StudentID { get; set; } = string.Empty;

    [Column("residence_type")]
    public string ResidenceType { get; set; } = string.Empty;


    // CUT Specific Accommodation Details
    [Column("residence_name")]
    public string? ResidenceName { get; set; }

    [Column("room_number")]
    public string? RoomNumber { get; set; }

    // Private Accommodation Details
    [Column("address")]
    public string? PrivateAddress { get; set; }

    [Column("city")]
    public string City { get; set; } = string.Empty;

    [Column("postal_code")]
    public string PostalCode { get; set; } = string.Empty;

    [Column("province")]
    public string Province { get; set; } = string.Empty;
}