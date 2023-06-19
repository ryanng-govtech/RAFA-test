using System;

namespace ReportAFaultAPI.Models;

public class RAFAEnvisionBearerToken {
    public int Id { get; set; }

    public string? BearerToken { get; set; }

    public DateTime CreatedDateTime { get; set; }
}