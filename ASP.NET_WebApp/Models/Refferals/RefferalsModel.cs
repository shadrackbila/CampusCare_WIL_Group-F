using System.ComponentModel.DataAnnotations;
using ASP.NET_WebApp.Models;
using StudentManagement.Models;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

[Table("student_refferals")]
public class RefferalsModel : BaseModel
{

    [Key]
    [PrimaryKey("id")]
    public string id { get; set; } = string.Empty;

    [Column("refferal_date")]
    public DateTime RefferalDate { get; set; }

    [Column("refferals_status")]
    public string RefferalsStaus { get; set; } = string.Empty;

    [Column("support_reason")]
    [Required(ErrorMessage = "Please indicate the reason for reffering studint.")]
    public string SupportReason { get; set; } = string.Empty;

    [Column("peer_educator_id")]
    public string PeerEducatorID { get; set; } = string.Empty;

    [Column("student_id")]
    public string StudentID { get; set; } = string.Empty;

    [Reference(typeof(StudentsModel), ReferenceAttribute.JoinType.Left)]
    public StudentsModel? Student { get; set; }


    [Reference(typeof(PractitionerModel), ReferenceAttribute.JoinType.Left)]
    public PractitionerModel? PeerEducator { get; set; }

}