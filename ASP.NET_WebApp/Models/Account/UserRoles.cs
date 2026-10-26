using System.ComponentModel.DataAnnotations;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

[Table("user_roles")]
public class UserRoles : BaseModel
{

    [Key]
    [PrimaryKey("id")]
    public string ID { get; set; } = Guid.NewGuid().ToString();

    [Column("user_id")]
    public string UserID { get; set; } = string.Empty;

    [Column("role")]
    public string UserRole { get; set; } = string.Empty;
}