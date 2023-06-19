using System;

namespace ReportAFaultAPI.Models;

public class RAFAEnvisionApimToken {
    public int Id { get; set; }

    public string? AccessToken { get; set; }

    public int? Expire { get; set; }

    public DateTime CreatedDateTime { get; set; }
}