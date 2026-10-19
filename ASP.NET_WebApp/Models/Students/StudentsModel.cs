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

    [Required(ErrorMessage = "The Student Number is required.")]
    [Column("student_number")]
    public string StudentNumber { get; set; } = string.Empty;

    [Required(ErrorMessage = "The Surname is required.")]
    [Column("surname")]
    public string Surname { get; set; } = string.Empty;

    [Required(ErrorMessage = "The Name is required.")]
    [Column("first_names")]
    public string FirstName { get; set; } = string.Empty;

    [Column("preferred_name")]
    public string PreferredName { get; set; } = string.Empty;

    [Required(ErrorMessage = "The date of birth is required.")]
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

    [Required(ErrorMessage = "The gender is required.")]
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

    [Required(ErrorMessage = "Please assign a practitioner .")]
    [Column("practitioners")]
    public string AssignedPractitionerID { get; set; } = string.Empty;

    [Reference(typeof(PractitionerModel), ReferenceAttribute.JoinType.Left)]
    public PractitionerModel? AssignedPractitionerInfo { get; set; }
    public bool ShouldSerializeAssignedPractitionerInfo() => false;


}