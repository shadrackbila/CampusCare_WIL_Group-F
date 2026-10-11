namespace ASP.NET_WebApp.Models;

using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using StudentManagement.Models;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

[Table("students")]
public class StudentsModel : BaseModel
{

    [Key]
    [PrimaryKey("id")]
    public string id { get; set; } = string.Empty;

    // 1. Personal Information
    [Column("student_number")]
    public string StudentNumber { get; set; } = string.Empty;

    [Column("surname")]
    public string Surname { get; set; } = string.Empty;

    [Column("first_names")]
    public string FirstName { get; set; } = string.Empty;

    [Column("preferred_name")]
    public string PreferredName { get; set; } = string.Empty;

    [Column("date_of_birth")]
    public DateTime DateOfBirth { get; set; }


    [JsonIgnore]
    public int Age
    {
        get
        {
            var today = DateTime.Today;
            var age = today.Year - DateOfBirth.Year;

            if (DateOfBirth.Date > today.AddYears(-age))
                age--;

            return age;
        }
    }

    [Column("gender")]
    public string Gender { get; set; } = string.Empty;

    // not in db
    [JsonIgnore]
    public string IdOrPassportNumber { get; set; } = string.Empty;

    [Column("nationality")]
    public string Nationality { get; set; } = string.Empty;

    [Column("home_language")]
    public string HomeLanguage { get; set; } = string.Empty;

    [Column("other_languages")]
    public string[] OtherLanguages { get; set; } = Array.Empty<string>();

    // 2. Next of Kin / Emergency Contact
    [Reference(typeof(NextOfKinModel), ReferenceAttribute.JoinType.Left)]
    public NextOfKinModel? ContactPerson { get; set; }

    // 3. Academic Information
    [Reference(typeof(AcademicInformationModel), ReferenceAttribute.JoinType.Left)]
    public AcademicInformationModel? AcademicInfo { get; set; }

    // 4. Residence Information
    [Reference(typeof(ResidenceInformationModel), ReferenceAttribute.JoinType.Left)]
    public ResidenceInformationModel? ResidenceInfo { get; set; }

    // [Reference(typeof(PractitionerModel))]
    // public PractitionerModel? AssignedPractitionerInfo { get; set; }


}