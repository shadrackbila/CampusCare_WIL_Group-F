using System.ComponentModel.DataAnnotations;
using ASP.NET_WebApp.Models;
using StudentManagement.Models;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

[Table("notifications")]
public class NotificationsModel : BaseModel
{

    [Key]
    [PrimaryKey("id")]
    public string id { get; set; } = string.Empty;

    [Column("title")]
    public string Title { get; set; } = string.Empty;

    [Column("body")]
    public string MessageBody { get; set; } = string.Empty;

    [Column("read")]
    public bool SupportReason { get; set; } = false;


    [Reference(typeof(StudentsModel), ReferenceAttribute.JoinType.Left)]
    public StudentsModel? Student { get; set; }


    [Reference(typeof(PractitionerModel), ReferenceAttribute.JoinType.Left)]
    public PractitionerModel? PeerEducator { get; set; }

}