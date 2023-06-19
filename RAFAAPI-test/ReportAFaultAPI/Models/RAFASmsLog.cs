using System;

using System.ComponentModel.DataAnnotations;

namespace ReportAFaultAPI.Models
{
    public class RAFASmsLog
    {   
        // RAFA's SMS Notification Log 
        // [Key]
        // public int Id { get; set; }
        // public String MobileNumber { get; set; }
        // public bool IsSuccessful { get; set; }
        // public DateTime CreatedDateTime { get; set; }
        // public String Remarks { get; set; }
        [Key]
        public long Id { get; set; }

        [StringLength(50)]
        public string? AppCode { get; set; }

        [StringLength(50)]
        public string NotificationType { get; set; }

        [StringLength(256)]
        public string Recipient { get; set; }

        [StringLength(256)]
        public string? MessageId { get; set; }

        [StringLength(500)]
        public string Subject { get; set; }

        public bool IsSuccess { get; set; }

        public string? ErrorMessages { get; set; }

        public DateTime LogDateTime { get; set; }
    }
}