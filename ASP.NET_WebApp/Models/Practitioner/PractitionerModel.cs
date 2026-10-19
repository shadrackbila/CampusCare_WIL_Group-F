using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace StudentManagement.Models
{

    [Table("practitioners")]
    public class PractitionerModel : BaseModel
    {
        [PrimaryKey("id", true)]
        [Column("id")]
        public string ID { get; set; } = Guid.NewGuid().ToString();

        [Required(ErrorMessage = "The Full Name is required.")]
        [Column("full_name")]
        public string FullName { get; set; } = string.Empty;

        [Required(ErrorMessage = "The Title is required.")]
        [Column("title")]
        public string Title { get; set; } = string.Empty;

        [Required(ErrorMessage = "The Role is required.")]
        [Column("role")]
        public string Role { get; set; } = string.Empty;

        [Required(ErrorMessage = "The Gender is required.")]
        [Column("gender")]
        public string Gender { get; set; } = string.Empty;

        [Column("verification_status")]
        public string VerificationStatus { get; set; } = VerificationStatuses.Pending;

        [Required(ErrorMessage = "The Personnel Number is required.")]
        [Column("personnel_number")]
        public string PersonnelNumber { get; set; } = string.Empty;

        [Required(ErrorMessage = "The Email is required.")]
        [EmailAddress(ErrorMessage = "Please enter a valid email address")]
        [Column("email")]
        public string Email { get; set; } = string.Empty;
    }
}
