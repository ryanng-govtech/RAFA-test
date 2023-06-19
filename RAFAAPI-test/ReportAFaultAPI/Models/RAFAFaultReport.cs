using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Threading.Tasks;

namespace ReportAFaultAPI.Models
{
    public class RAFAFaultReport
    {
        [Key]
        public int Id { get; set; }

        public string JtcCaseId { get; set; }

        [Required]
        [StringLength(50)]
        public string BuildingCode { get; set; }
        
        [StringLength(200)]
        public string OtherLocation { get; set; }

        [Required]
        [StringLength(10)]
        public string Latitude { get; set; }

        [Required]
        [StringLength(10)]
        public string Longitude { get; set; }

        [StringLength(50)]
        public string SpaceId { get; set; }

        [Required]
        [StringLength(50)]
        public string LocationDetails { get; set; }

        [StringLength(200)]
        public string FaultDescription { get; set; }
        
        [Required]
        [StringLength(50)]
        public string Salutation { get; set; }

        [Required]
        [StringLength(66)]
        public string GivenName { get; set; }

        [Required]
        [StringLength(66)]
        public string Surname { get; set; }

        [Required]
        [StringLength(8, MinimumLength = 8)]
        public string ContactNumber { get; set; }

        [Required]
        [StringLength(320)]
        [RegularExpression(@"[\S ]+@[\S ]+\.[\S ]*[A-Za-z0-9]$")]
        public string EmailAddress { get; set; }
        public bool IsReceiveUpdate { get; set; }
        public string? CreatedDateTime { get; set; }
        public string ReportStatus { get; set; }
        public ICollection<RAFAFaultImage> RAFAFaultImages { get; set; }
    }
}
