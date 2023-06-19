using System.Security.Cryptography;
using System.Text;
using Microsoft.AspNetCore.Mvc;
using System.Text.Json;
using Microsoft.Extensions.Logging;
using Microsoft.EntityFrameworkCore;
using System.Net.Http;
using System;
using System.Threading.Tasks;
using ReportAFaultAPI.Models;
using ReportAFaultAPI.Interfaces;
using Microsoft.AspNetCore.Authorization;
using System.IO;
using System.Collections.Generic;
using System.Drawing;
using Microsoft.Extensions.Configuration;

namespace ReportAFaultAPI.Controllers
{
    public class RAFAEnvisionController : IRAFAEnvisionController
    {
        private readonly IConfiguration configuration;

        private readonly ILogger<RAFAEnvisionController> _logger;

        private readonly RafaDbContext _context;

        private static readonly HttpClient _httpClient = new HttpClient();

        public static string CURRENT_TIMESTAMP = null;
        public static string BEARER_PREFIX = "Bearer ";

        public RAFAEnvisionController(IConfiguration iConfig, ILogger<RAFAEnvisionController> logger, RafaDbContext context)
        {
            configuration = iConfig;
            _logger = logger;
            _context = context;
            _httpClient.DefaultRequestHeaders.Clear();
            _httpClient.DefaultRequestHeaders.Add("subkey-gcc-ext", configuration["Envision:Subkey-gcc-ext"]);
        }

        public async Task<string?> RegisterToken()
        {
            RAFAEnvisionBearerToken bearerTokenDetails = await _context.RAFA_ENVISIONBEARERTOKEN.FirstOrDefaultAsync();
            if (bearerTokenDetails != null)
            {
                _logger.LogInformation("Bearer token retrieved.");
                return bearerTokenDetails.BearerToken;
            }
            JsonElement? registrationResult = await TriggerOneTimeRegistration();
            if (registrationResult != null)
            {
                JsonElement notNullRegistrationResult = (JsonElement)registrationResult;
                // _logger.LogInformation(notNullRegistrationResult.ToString());
                string? bearerToken = notNullRegistrationResult.GetProperty("data").GetProperty("accessToken").GetString();
                /*
                 * TODO : You will need to store the registrationResult (bearerToken)
                 * in your repository which will be used in a later stage to trigger the
                 * functional APIs.
                 */
                RAFAEnvisionBearerToken newToken = new RAFAEnvisionBearerToken
                {
                    BearerToken = bearerToken,
                    CreatedDateTime = DateTime.Now
                };
                await _context.RAFA_ENVISIONBEARERTOKEN.AddAsync(newToken);
                await _context.SaveChangesAsync();
                _logger.LogInformation("New bearer token added.");
                return bearerToken;
            }
            return null;
        }

        public async Task<string?> CreateCase(string bearerToken, RAFAFaultReport rfr)
        {
            _logger.LogInformation($"Start Envision CreateCase.");
            string apiEndpoint = configuration["Envision:ApiBaseUrl"] + configuration["Envision:CreateCasePath"];
            CURRENT_TIMESTAMP = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds().ToString();
            string? signatureString = null;
            //Step 1: Get APIM Access Token
            string? accessToken = await GetApimAccessToken();

            if (accessToken != null)
            {
                //Step 2: Construct the request payload
                object requestBody = new
                {
                    jtcCaseId = rfr.JtcCaseId,
                    type = "CM",
                    customerName = rfr.Salutation + " " + rfr.GivenName + " " + rfr.Surname,
                    customerEmail = rfr.EmailAddress,
                    customerContact = rfr.ContactNumber,
                    buildingId = rfr.BuildingCode,
                    spaceId = rfr.SpaceId,
                    problemDescription = rfr.FaultDescription,
                    status = "New",
                    coordinatesLatitude = rfr.Latitude,
                    coordinatesLongitude = rfr.Longitude,
                    others = rfr.IsReceiveUpdate ? "Feedback reporter would like to be updated on the status of their case." : null,
                    additionalSpaceDetails = rfr.LocationDetails,
                    otherLocation = rfr.OtherLocation,
                    relatedJtcAppId = "jtc-rafa-app",
                    reportedDatetime = rfr.CreatedDateTime
                };
                //serialise into json string
                string requestBodyJsonString = JsonSerializer.Serialize(requestBody);

                //Step 3: Construct the APIM signature
                StringBuilder signatureData = new StringBuilder();
                signatureData.Append(accessToken);
                signatureData.Append(requestBodyJsonString);
                signatureData.Append(CURRENT_TIMESTAMP);
                signatureData.Append(configuration["Envision:SecretKey"]);
                //SHA256 hashing
                using (var sha256 = SHA256.Create())
                {
                    var secretBytes = Encoding.UTF8.GetBytes(signatureData.ToString());
                    var secretHash = sha256.ComputeHash(secretBytes);
                    signatureString = Convert.ToHexString(secretHash).ToLower();
                };

                //Step 4: Invoke JMM API
                using (HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, apiEndpoint))
                {
                    request.Content = new StringContent(requestBodyJsonString, Encoding.UTF8, "application/json");
                    request.Headers.Add("apim-accesstoken", accessToken);
                    request.Headers.Add("apim-timestamp", CURRENT_TIMESTAMP);
                    request.Headers.Add("apim-signature", signatureString);
                    request.Headers.Add("Authorization", BEARER_PREFIX + bearerToken);

                    //Step 5: Obtain result from JMM API
                    using (HttpResponseMessage response = await _httpClient.SendAsync(request))
                    {
                        Stream contentStream = await response.Content.ReadAsStreamAsync();
                        try
                        {
                            using (JsonDocument? result = await JsonSerializer.DeserializeAsync<JsonDocument>(contentStream))
                            {
                                if (result != null)
                                {
                                    JsonElement clonedResult = result.RootElement.Clone();
                                    _logger.LogInformation(clonedResult.ToString());
                                    Console.WriteLine(clonedResult);
                                    if (clonedResult.GetProperty("data").TryGetProperty("jtcCaseId", out JsonElement value))
                                    {
                                        _logger.LogInformation($"Envision CreateCase successful.");
                                        return value.GetString();
                                    }
                                }
                            }
                        }
                        catch (Exception e)
                        {
                            _logger.LogError($"{e}, Response content: {response.Content.ReadAsStringAsync().Result}");
                        }


                    }
                }
            }
            _logger.LogInformation("Envision CreateCase unsuccessful.");
            return null;
        }

        public async Task UploadDocument(string bearerToken, string jtcCaseId, RAFAFaultImage rafaFaultImage, int counter)
        {
            string apiEndpoint = configuration["Envision:ApiBaseUrl"] + configuration["Envision:UploadDocumentPath"];
            CURRENT_TIMESTAMP = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds().ToString();
            string? signatureString = null;
            //Step 1: Get APIM Access Token
            string? accessToken = await GetApimAccessToken();

            if (accessToken != null)
            {
                //Step 2: Construct the request payload
                // Not required in UploadDocument

                //Step 3: Construct the APIM signature
                // (removed in subsequent update 14/03/2023) Request payload is "undefined" for upload document due to file upload for APIM signature 
                StringBuilder signatureData = new StringBuilder();
                signatureData.Append(accessToken);
                // signatureData.Append("undefined");
                signatureData.Append(CURRENT_TIMESTAMP);
                signatureData.Append(configuration["Envision:SecretKey"]);
                //SHA256 hashing
                using (var sha256 = SHA256.Create())
                {
                    var secretBytes = Encoding.UTF8.GetBytes(signatureData.ToString());
                    var secretHash = sha256.ComputeHash(secretBytes);
                    signatureString = Convert.ToHexString(secretHash).ToLower();
                };

                //Step 4: Invoke JMM API
                // Check image type
                string? rawFormat = null;
                using (MemoryStream stream = new MemoryStream(rafaFaultImage.ImageData))
                {
                    Image image = Image.FromStream(stream);
                    rawFormat = image.RawFormat.ToString().ToLower();
                }
                using (HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, apiEndpoint))
                {
                    MultipartFormDataContent multipartFormDataContent = new MultipartFormDataContent("----------" + Guid.NewGuid());
                    multipartFormDataContent.Add(new StringContent(jtcCaseId), "jtcCaseId");
                    var imageContent = new StreamContent(new MemoryStream(rafaFaultImage.ImageData));
                    imageContent.Headers.ContentType = new System.Net.Http.Headers.MediaTypeHeaderValue($"image/{rawFormat}");
                    multipartFormDataContent.Add(imageContent, "uploadedContent", $"picture{counter}.{rawFormat}");
                    request.Content = multipartFormDataContent;
                    request.Headers.Add("apim-accesstoken", accessToken);
                    request.Headers.Add("apim-timestamp", CURRENT_TIMESTAMP);
                    request.Headers.Add("apim-signature", signatureString);
                    request.Headers.Add("Authorization", BEARER_PREFIX + bearerToken);

                    //Step 5: Obtain result from JMM API
                    using (HttpResponseMessage response = await _httpClient.SendAsync(request))
                    {
                        Stream contentStream = await response.Content.ReadAsStreamAsync();
                        try
                        {
                            using (JsonDocument? result = await JsonSerializer.DeserializeAsync<JsonDocument>(contentStream))
                            {
                                if (result != null)
                                {
                                    JsonElement clonedResult = result.RootElement.Clone();
                                    Console.WriteLine(clonedResult);
                                    int statusCode = clonedResult.GetProperty("code").GetInt32();
                                    string message = clonedResult.GetProperty("message").GetString();
                                    if (statusCode == 200)
                                    {
                                        _logger.LogInformation($"Submitted image successfully, status code {statusCode}, message {message}");
                                    }
                                    else
                                    {
                                        _logger.LogWarning($"Failed to submit image, status code {statusCode}, message {message}");
                                    }
                                    return;
                                }
                            };
                        }
                        catch (Exception e)
                        {
                            _logger.LogError($"{e}, Response content: {response.Content.ReadAsStringAsync().Result}");
                        }

                    };
                };
            }
            _logger.LogInformation("Failed to submit image, accesstoken is null");
            return;
        }

        #region Private Methods
        private async Task<JsonElement?> TriggerOneTimeRegistration()
        {
            string apiEndPoint = configuration["Envision:ApiBaseUrl"] + configuration["Envision:RegisterPath"];
            string? signatureString = null;
            CURRENT_TIMESTAMP = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds().ToString();
            //Step 1: Get APIM AccessToken
            string? accessToken = await GetApimAccessToken();
            Console.WriteLine($"Step 1: Access Token {accessToken}");

            if (accessToken != null)
            {
                //Step 2: Construct request payload
                object requestBody = new
                {
                    appId = configuration["Envision:AppId"],
                    svcAcctId = configuration["Envision:SvcAcctId"]
                };
                //serialise into json string
                string requestBodyJsonString = JsonSerializer.Serialize(requestBody);

                //Step 3: Construct APIM Signature
                StringBuilder signatureData = new StringBuilder();
                signatureData.Append(accessToken);
                signatureData.Append(requestBodyJsonString);
                signatureData.Append(CURRENT_TIMESTAMP);
                signatureData.Append(configuration["Envision:SecretKey"]);
                //SHA256 hashing
                using (var sha256 = SHA256.Create())
                {
                    var secretBytes = Encoding.UTF8.GetBytes(signatureData.ToString());
                    var secretHash = sha256.ComputeHash(secretBytes);
                    signatureString = Convert.ToHexString(secretHash).ToLower();
                };

                //Step 4: Invoking JMM Registration API
                using (HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, apiEndPoint))
                {
                    request.Content = new StringContent(requestBodyJsonString, Encoding.UTF8, "application/json");
                    request.Headers.Add("apim-accesstoken", accessToken);
                    request.Headers.Add("apim-timestamp", CURRENT_TIMESTAMP);
                    request.Headers.Add("apim-signature", signatureString);

                    //Step 5: Obtain result from Registration API
                    using (HttpResponseMessage response = await _httpClient.SendAsync(request))
                    {
                        // var contentStream = await response.Content.ReadAsStringAsync();
                        // Console.WriteLine((int)response.StatusCode);
                        // Console.WriteLine(contentStream);
                        var contentStream = await response.Content.ReadAsStreamAsync();
                        try
                        {
                            using (JsonDocument? result = await JsonSerializer.DeserializeAsync<JsonDocument>(contentStream))
                            {
                                if (result != null)
                                {
                                    JsonElement clonedResult = result.RootElement.Clone();
                                    Console.WriteLine(clonedResult);
                                    // _logger.LogInformation(clonedResult.ToString());
                                    _logger.LogInformation("TriggerOneTimeRegistration successful.");
                                    return clonedResult;
                                }
                            }
                        }
                        catch (Exception e)
                        {
                            _logger.LogError($"{e}, Response content: {response.Content.ReadAsStringAsync().Result}");
                        }

                    };
                };
            }
            _logger.LogInformation("TriggerOneTimeRegistration unsuccessful.");
            return null;
        }

        private async Task<string?> GetApimAccessToken()
        {
            _logger.LogInformation("Start GetApimAccessToken.");
            string apiEndPoint = configuration["Envision:ApiBaseUrl"] + configuration["Envision:GetTokenPath"];
            CURRENT_TIMESTAMP = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds().ToString();
            /*
             * TODO:
             * Check if token exists in DB
             * - Yes: Check if token expired
             * 		- Yes: Call get token API to re-acquire APIM access token
             * 		- No: Reuse token
             * - No: Call get token API to acquire APIM access token
             */
            RAFAEnvisionApimToken apimToken = await _context.RAFA_ENVISIONAPIMTOKEN.FirstOrDefaultAsync();
            if (apimToken != null)
            {
                if (apimToken.CreatedDateTime.AddSeconds((double)apimToken.Expire).CompareTo(DateTime.Now) > 0)
                {
                    _logger.LogInformation("GetApimAccessToken successful.");
                    return apimToken.AccessToken;
                }
            }
            //Step 1: Call getToken API
            string? accessToken = null;
            string checksumBody = configuration["Envision:AppKey"] + CURRENT_TIMESTAMP + configuration["Envision:SecretKey"];
            string? sha256hexChecksum = null;
            using (var sha256 = SHA256.Create())
            {
                var secretBytes = Encoding.UTF8.GetBytes(checksumBody);
                var secretHash = sha256.ComputeHash(secretBytes);
                sha256hexChecksum = Convert.ToHexString(secretHash).ToLower();
            };
            Console.WriteLine(sha256hexChecksum);
            object obj = new
            {
                appKey = configuration["Envision:AppKey"],
                encryption = sha256hexChecksum,
                timestamp = CURRENT_TIMESTAMP
            };

            using (HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, apiEndPoint))
            {
                request.Content = new StringContent(JsonSerializer.Serialize(obj), Encoding.UTF8, "application/json");
                using (HttpResponseMessage response = await _httpClient.SendAsync(request))
                {
                    var contentStream = await response.Content.ReadAsStreamAsync();
                    try
                    {
                        using (var result = await JsonSerializer.DeserializeAsync<JsonDocument>(contentStream))
                        {
                            if (result != null)
                            {
                                JsonElement root = result.RootElement;
                                JsonElement data = root.GetProperty("data");
                                accessToken = data.GetProperty("accessToken").GetString();
                                int expireTime = data.GetProperty("expire").GetInt32();
                                Console.WriteLine(accessToken);
                                Console.WriteLine(expireTime);
                                Console.WriteLine(DateTime.Now);
                                /*
                                 * TODO : You are required to store the accessToken and expireTime
                                 * in your repository, so that it can be retrieved again without re-triggering
                                 * the get token API.
                                 */
                                if (await _context.RAFA_ENVISIONAPIMTOKEN.AnyAsync())
                                {
                                    RAFAEnvisionApimToken oldToken = await _context.RAFA_ENVISIONAPIMTOKEN.FirstOrDefaultAsync();
                                    oldToken.AccessToken = accessToken;
                                    oldToken.Expire = expireTime;
                                    oldToken.CreatedDateTime = DateTime.Now;
                                }
                                else
                                {
                                    RAFAEnvisionApimToken newToken = new RAFAEnvisionApimToken
                                    {
                                        AccessToken = accessToken,
                                        Expire = expireTime,
                                        CreatedDateTime = DateTime.Now
                                    };
                                    await _context.RAFA_ENVISIONAPIMTOKEN.AddAsync(newToken);
                                }
                                await _context.SaveChangesAsync();
                            }
                        };
                    }
                    catch (Exception e)
                    {
                        _logger.LogError($"{e}, Response content: {response.Content.ReadAsStringAsync().Result}");
                    }
                };
            };
            _logger.LogInformation("GetApimAccessToken successful.");
            return accessToken;
        }
        #endregion
    }
}