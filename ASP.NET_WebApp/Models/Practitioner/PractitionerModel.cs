using System;
using System.Text.Json.Serialization;
using Supabase.Postgrest.Models;

namespace StudentManagement.Models
{
    public class PractitionerModel : BaseModel
    {
        [JsonPropertyName("personnel_number")]
        public string PersonnelNumber { get; set; } = string.Empty;

        [JsonPropertyName("assigned_practitioner")]
        public string AssignedPractitioner { get; set; } = string.Empty;

        [JsonPropertyName("role")]
        public string Role { get; set; } = string.Empty;

        [JsonPropertyName("gender")]
        public string Gender { get; set; } = string.Empty;

        [JsonPropertyName("email_address")]
        public string EmailAddress { get; set; } = string.Empty;
    }
}
