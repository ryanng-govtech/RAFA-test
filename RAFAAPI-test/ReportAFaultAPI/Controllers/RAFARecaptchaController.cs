using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Net.Http.Json;
using System.Text;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json.Linq;

namespace ReportAFaultAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RAFARecaptchaController : ControllerBase
    {
        private readonly ILogger _logger;

        private readonly IConfiguration configuration;

        private static readonly HttpClient _httpClient = new HttpClient();

        public RAFARecaptchaController(ILogger<RAFARecaptchaController> logger, IConfiguration iConfig)
        {
            _logger = logger;
            configuration = iConfig;
            _httpClient.DefaultRequestHeaders.Clear();
            _httpClient.DefaultRequestHeaders.Add("subkey-gcc-ext", configuration["GRecaptcha:Subkey-gcc-ext"]);
        }

        [HttpGet("GetRecaptchaVerification")]
        [AllowAnonymous]
        public async Task<ActionResult> GetRecaptchaVerification(string gRecaptchaToken)
        {
            if (!bool.Parse(configuration["GRecaptcha:IsActive"]))
            {
                return Ok(new {success = true, score = 1.0, action = "GRecaptcha disabled", challenge_ts = DateTime.UtcNow.ToString("s"), hostname = "RAFA GRecaptcha"});
            }
            try
            {   
                // decode encoded values that were used to bypass Azure WAF Policy Ruleset
                gRecaptchaToken = gRecaptchaToken.Replace(",", "0x").Replace(".", "0X");
                gRecaptchaToken = Encoding.UTF8.GetString(Convert.FromBase64String(gRecaptchaToken));

                var data = new KeyValuePair<string, string>[] {
                    new KeyValuePair<string, string>("secret", configuration["GRecaptcha:SecretKey"]),
                    new KeyValuePair<string, string>("response", gRecaptchaToken)
                };
                using (var request = new HttpRequestMessage(HttpMethod.Post, configuration["GRecaptcha:Url"]))
                {
                    request.Content = new FormUrlEncodedContent(data);
                    using (var response = await _httpClient.SendAsync(request))
                    {
                        var result = await response.Content.ReadFromJsonAsync<object>();

                        _logger.LogInformation($"GRecaptcha results: {result}");
                        return Ok(result);
                    }
                }
            }
            catch (Exception e)
            {
                _logger.LogError("GetRecaptchaVerification error: " + e.ToString());
            }
            return BadRequest();
        }

    }
}