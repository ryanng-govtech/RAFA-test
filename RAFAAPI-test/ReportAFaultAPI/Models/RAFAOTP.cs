using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using System.ComponentModel.DataAnnotations;

namespace ReportAFaultAPI.Models
{
    public class RAFAOTP
    {
        [Key]
        public int Id { get; set; }
        public String MobileNumber { get; set; }
        public int OTPCode { get; set; }
        public DateTime CreatedDateTime { get; set; }
        public DateTime? ExpiredDateTime { get; set; }
        public bool Verified { get; set; }
        public bool IsActive { get; set; }
        
    }
}
