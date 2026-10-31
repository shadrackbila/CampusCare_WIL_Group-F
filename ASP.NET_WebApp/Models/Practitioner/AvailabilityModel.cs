using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;
using Supabase.Postgrest.Attributes;
using Supabase.Postgrest.Models;

namespace StudentManagement.Models
{

    [Table("practitioner_availability")]
    public class AvailabilityModel : BaseModel
    {
        [PrimaryKey("id")]
        [Column("id")]
        public string ID { get; set; } = Guid.NewGuid().ToString();

        [Column("practitioner_id")]
        public string PractitionerID { get; set; } = string.Empty;

        [Column("day_of_week")]
        public int DayOfWeek { get; set; } = 1;

        [Column("start_time")]
        public TimeOnly StartTime { get; set; }

        [Column("end_time")]
        public TimeOnly EndTime { get; set; }

        [Column("is_recurring")]
        public bool IsReccuring { get; set; } = true;

        [Column("avalibility")]
        public bool Availability { get; set; } = true;
    }
}
