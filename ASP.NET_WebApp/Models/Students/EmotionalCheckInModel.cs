namespace ASP.NET_WebApp.Models;

using System.Text.Json.Serialization;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

[Table("emotional_checkins")]
public class EmotionalCheckInModel : BaseModel
{
    [PrimaryKey("id")]
    public string Id { get; set; } = string.Empty;

    [Column("student_id")]
    public string StudentID { get; set; } = string.Empty;

    [Column("emotions")]
    public string[]? Emotions { get; set; } = Array.Empty<string>();

    [Column("intensity")]
    public int? Intensity { get; set; } = 0;

    [Column("created_at")]
    public DateTime? CreatedAt { get; set; }


    [Column("notes")]
    public string? Notes { get; set; } = string.Empty;

    [Column("stress_level")]
    public int? StressLevel { get; set; } = 0;

    [Column("coping_level")]
    public int? CopingLevel { get; set; } = 0;

    [Column("support_level")]
    public int? SupportLevel { get; set; } = 0;

}
