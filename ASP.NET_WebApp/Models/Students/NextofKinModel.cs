namespace ASP.NET_WebApp.Models;

using System.Text.Json.Serialization;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

[Table("next_of_kin")]
public class NextOfKinModel : BaseModel
{
    [Column("student_id")]
    public string StudentID { get; set; } = string.Empty;

    [Column("full_name")]
    public string FullName { get; set; } = string.Empty;


    [Column("relationship")]
    public string Relationship { get; set; } = string.Empty;

    [Column("cell_number")]
    public string CellphoneNumber { get; set; } = string.Empty;

    [Column("alternative_number")]
    public string AlternateNumber { get; set; } = string.Empty;

    [Column("email")]
    public string EmailAddress { get; set; } = string.Empty;

    [Column("residential_address")]
    public string ResidentialAddress { get; set; } = string.Empty;
}