namespace ASP.NET_WebApp.Models;

using System.Text.Json.Serialization;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

[Table("student_academic_info")]
public class AcademicInformationModel : BaseModel
{

    [Column("student_id")]
    public string StudentID { get; set; } = string.Empty;

    [Column("faculty")]
    public string Faculty { get; set; } = string.Empty;

    [Column("department")]
    public string Department { get; set; } = string.Empty;

    [Column("qualification")]
    public string Qualification { get; set; } = string.Empty;

    [Column("year_of_study")]
    public string YearOfStudy { get; set; } = string.Empty;

    [Column("study_mode")]
    public string ModeOfStudy { get; set; } = string.Empty;

    [Column("campus")]
    public string Campus { get; set; } = string.Empty;
}
