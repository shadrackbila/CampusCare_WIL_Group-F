using System.ComponentModel.DataAnnotations;
using ASP.NET_WebApp.Models;
using StudentManagement.Models;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

[Table("notifications")]
public class NotificationModel : BaseModel
{

    [Key]
    [PrimaryKey("id")]
    public string id { get; set; } = string.Empty;

    [Column("user_id")]
    public string UserID { get; set; } = string.Empty;

    [Column("title")]
    public string Title { get; set; } = string.Empty;

    [Column("body")]
    public string Body { get; set; } = string.Empty;

    [Column("read")]
    public bool IsRead { get; set; } = false;

    [Column("type")]
    public string Type { get; set; } = "appointment_cancelled";


}