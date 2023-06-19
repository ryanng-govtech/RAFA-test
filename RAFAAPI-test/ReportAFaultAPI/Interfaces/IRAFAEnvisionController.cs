using System.Threading.Tasks;
using ReportAFaultAPI.Models;

namespace ReportAFaultAPI.Interfaces;

public interface IRAFAEnvisionController {
    public Task<string?> RegisterToken();

    public Task<string?> CreateCase(string bearerToken, RAFAFaultReport rfr);
    
    public Task UploadDocument(string bearerToken, string jtcCaseId, RAFAFaultImage rafaFaultImage, int counter);
}