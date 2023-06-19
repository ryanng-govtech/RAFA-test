using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ReportAFaultAPI.Models;
using Microsoft.Extensions.Configuration;
using Newtonsoft.Json.Linq;

namespace ReportAFaultAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RAFABuildingsController : ControllerBase
    {
        private readonly IConfiguration configuration;

        private static readonly HttpClient _httpClient = new HttpClient();

        private readonly string jmmApiPrefix;

        private readonly string oneMapApiPrefix;

        public RAFABuildingsController(IConfiguration configuration)
        {
            this.configuration = configuration;
            jmmApiPrefix = Constants.isDev ? Constants.JmmApiPrefix : configuration["JmmApi:Url"];
            oneMapApiPrefix = Constants.isDev ? Constants.OneMapApiPrefix : configuration["OneMapApiConfiguration:Url"];
        }

        [HttpGet("SearchForBuilding")]
        public async Task<ActionResult> GetBuilding(string name, string postalCode)
        {
            try
            {
                using (var request = new HttpRequestMessage(HttpMethod.Get, jmmApiPrefix + $"/building/search?name={name}&postal_code={postalCode}&include_building_space=false&include_asset=false"))
                {
                    request.Headers.Add("subkey-gcc-ext", configuration["JmmApi:Subkey-gcc-ext"]);
                    request.Headers.Add("subkey-gcc-int", configuration["JmmApi:Subkey-gcc-int"]);
                    using (var response = await _httpClient.SendAsync(request))
                    {
                        response.EnsureSuccessStatusCode();

                        return Ok(await response.Content.ReadAsStringAsync());
                    }
                }
                // HttpResponseMessage response = await _httpClient.GetAsync(Constants.JmmApiPrefix + $"/JMM/api/building/search?name={query}&include_building_space=false&include_asset=false");
                // response.EnsureSuccessStatusCode();
                // var responseBody = await response.Content.ReadAsStringAsync();
                // // var json = Newtonsoft.Json.JsonConvert.DeserializeObject(responseBody);
                // // Above three lines can be replaced with new helper method below
                // // string responseBody = await client.GetStringAsync(uri);
                // Console.WriteLine(responseBody);
                // return Ok(responseBody);
            }
            catch (HttpRequestException e)
            {
                Console.WriteLine("\nException Caught!");
                Console.WriteLine("Message :{0} ", e.Message);
            }
            return BadRequest("Query failed");
        }

        [HttpGet("RetrieveBuildingByCode")]
        public async Task<ActionResult> GetBuildingNameByCode(string buildingCode)
        {
            try
            {
                using (var request = new HttpRequestMessage(HttpMethod.Get, jmmApiPrefix + $"/building/{buildingCode}"))
                {
                    request.Headers.Add("subkey-gcc-ext", configuration["JmmApi:Subkey-gcc-ext"]);
                    request.Headers.Add("subkey-gcc-int", configuration["JmmApi:Subkey-gcc-int"]);
                    using (var response = await _httpClient.SendAsync(request))
                    {
                        response.EnsureSuccessStatusCode();
                        return Ok(await response.Content.ReadAsStringAsync());

                    }
                }
            }
            catch (HttpRequestException e)
            {
                Console.WriteLine("\nException Caught!");
                Console.WriteLine("Message :{0} ", e.Message);
            }
            return BadRequest("Query failed");
        }

        [HttpPost("ReverseGeocode")]
        public async Task<ActionResult> OneMapApiReverseGeocode(double latitude, double longitude)
        {
            //authenticate with onemap services
            dynamic authenticationJsonResponseBody = "";
            string authenticationUrl = oneMapApiPrefix + "/privateapi/auth/post/getToken";
            JObject authenticationParameters = JObject.FromObject(new
            {
                email = configuration["OneMapApiConfiguration:Email"],
                password = configuration["OneMapApiConfiguration:Password"]
            });
            var content = new StringContent(authenticationParameters.ToString(), System.Text.Encoding.UTF8, "application/json");
            try
            {
                using (var request = new HttpRequestMessage(HttpMethod.Post, authenticationUrl))
                {
                    request.Headers.Add("subkey-gcc-ext", configuration["OneMapApiConfiguration:Subkey-gcc-ext"]);
                    request.Content = content;
                    using (var response = await _httpClient.SendAsync(request))
                    {
                        response.EnsureSuccessStatusCode();
                        string authenticationResponseBody = await response.Content.ReadAsStringAsync();
                        authenticationJsonResponseBody = JObject.Parse(authenticationResponseBody);
                    }
                }
            }
            catch (HttpRequestException e)
            {
                Console.WriteLine("\nException Caught!");
                Console.WriteLine("Message :{0} ", e.Message);
                return BadRequest("Authentication with OneMap service failed.");
            }

            //reverse geocoding using onemap services
            string reverseGeoCodeUrl = oneMapApiPrefix + "/privateapi/commonsvc/revgeocode";
            string reverseGeocodeParameters = $"?location={latitude},{longitude}&token={authenticationJsonResponseBody.access_token}";
            string reverseGeocodeFullUrl = reverseGeoCodeUrl + reverseGeocodeParameters;
            try
            {
                using (var request = new HttpRequestMessage(HttpMethod.Get, reverseGeocodeFullUrl))
                {
                    request.Headers.Add("subkey-gcc-ext", configuration["OneMapApiConfiguration:Subkey-gcc-ext"]);
                    using (var response = await _httpClient.SendAsync(request))
                    {
                        response.EnsureSuccessStatusCode();
                        string reverseGeocodeResponseBody = await response.Content.ReadAsStringAsync();
                        dynamic reverseGeocodeJsonResponseBody = JObject.Parse(reverseGeocodeResponseBody);
                        if (reverseGeocodeJsonResponseBody.GeocodeInfo.Count != 0)
                        {
                            Console.WriteLine(reverseGeocodeJsonResponseBody.GeocodeInfo[0]);
                            return Ok(reverseGeocodeJsonResponseBody.GeocodeInfo[0].ToString());
                        }
                    }
                }
            }
            catch (HttpRequestException e)
            {
                Console.WriteLine("\nException Caught!");
                Console.WriteLine("Message :{0} ", e.Message);
                return BadRequest("Connection to reverse geocode service failed.");
            }
            return BadRequest("No information available for given coordinates.");
        }

        [HttpGet("OneMapApiSearch")]
        public async Task<ActionResult> OneMapApiSearch(string searchVal)
        {
            string searchUrl = oneMapApiPrefix + $"/commonapi/search?searchVal={searchVal}&returnGeom=Y&getAddrDetails=Y&pageNum=1";
            try
            {
                using (var request = new HttpRequestMessage(HttpMethod.Get, searchUrl))
                {
                    request.Headers.Add("subkey-gcc-ext", configuration["OneMapApiConfiguration:Subkey-gcc-ext"]);
                    using (var response = await _httpClient.SendAsync(request))
                    {
                        response.EnsureSuccessStatusCode();
                        string searchResponseBody = await response.Content.ReadAsStringAsync();
                        dynamic searchJsonResponseBody = JObject.Parse(searchResponseBody);
                        if (searchJsonResponseBody.results.Count != 0)
                        {
                            return Ok(searchJsonResponseBody.results.ToString());
                        }
                    }
                }
            }
            catch (HttpRequestException e)
            {
                Console.WriteLine("\nException Caught!");
                Console.WriteLine("Message :{0} ", e.Message);
                return BadRequest("Unable to use search address service.");
            }
            return BadRequest("No addresses found for given search term.");
        }
    }
}
