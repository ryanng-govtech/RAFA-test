namespace ReportAFaultAPI.Models
{
    public class RAFAFaultImage
    {
        public int Id { get; set; }
        public byte[] ImageData { get; set; }
        public int RAFAFaultReportId { get; set; }
        public RAFAFaultReport RAFAFaultReport { get; set; }
    }
}