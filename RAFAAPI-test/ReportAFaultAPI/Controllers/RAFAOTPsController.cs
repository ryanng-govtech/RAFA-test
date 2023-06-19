using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ReportAFaultAPI.Models;
using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using Microsoft.Extensions.Configuration;
using System.Net.Http;
using Microsoft.AspNetCore.Authorization;
using Microsoft.Extensions.Logging;
using System.Diagnostics;

namespace ReportAFaultAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RAFAOTPsController : ControllerBase
    {
        private readonly ILogger _logger;
        private readonly RafaDbContext _context;
        private static Random hashCode;
        private readonly IConfiguration configuration;
        private static readonly HttpClient _httpClient = new HttpClient();

        public RAFAOTPsController(ILogger<RAFAOTPsController> logger, RafaDbContext context, IConfiguration iConfig)
        {
            _logger = logger;
            configuration = iConfig;
            _context = context;
            _httpClient.DefaultRequestHeaders.Clear();
            _httpClient.DefaultRequestHeaders.Add("subkey-gcc-ext", configuration["SmsConfiguration:Sms_subkey-gcc-ext"]);
            _httpClient.DefaultRequestHeaders.Add("subkey-gcc-int", configuration["SmsConfiguration:Sms_subkey-gcc-int"]);
        }

        private string CreateToken(IEnumerable<Claim> claims, DateTime expiresAt)
        {
            Debug.WriteLine(claims);
            var secretKey = Encoding.ASCII.GetBytes(configuration.GetValue<string>("SecretKey"));
            Debug.WriteLine("Test Key:" + secretKey);
            var jwt = new JwtSecurityToken(
                claims: claims,
                notBefore: DateTime.UtcNow,
                expires: expiresAt,
                signingCredentials: new SigningCredentials(
                    new SymmetricSecurityKey(secretKey),
                    SecurityAlgorithms.HmacSha256Signature
                )
            );
            return new JwtSecurityTokenHandler().WriteToken(jwt);
        }

        [HttpPost("CheckTokenAboutToExpire")]
        [AllowAnonymous]
        public async Task<ActionResult> CheckTokenAboutToExpire([FromForm] string accessToken) {
            var secretKey = Encoding.ASCII.GetBytes(configuration.GetValue<string>("SecretKey"));
            JwtSecurityTokenHandler tokenHandler = new JwtSecurityTokenHandler();
            TokenValidationParameters validationParameters = new TokenValidationParameters() 
            {
                IssuerSigningKey = new SymmetricSecurityKey(secretKey),
                ValidateAudience = false,
                ValidateIssuer = false,
            };
            tokenHandler.ValidateToken(accessToken, validationParameters, out SecurityToken validatedToken);
            DateTime tokenCreatedAt = validatedToken.ValidFrom;
            Debug.WriteLine(tokenCreatedAt);
            if (tokenCreatedAt.AddMinutes(10) < DateTime.UtcNow) 
            {
                _logger.LogInformation("Token has expired.");
                return BadRequest();
            }
            _logger.LogInformation("Token has not expired.");
            return Ok();
        }

        [HttpPost("VerifyOTPCode")]
        [AllowAnonymous]
        public async Task<ActionResult<RAFAOTP>> VerifyOTPCode(string phoneNum, int otp)
        {
            Debug.WriteLine("phoneNum" + phoneNum);
            Debug.WriteLine("OTP" + otp);
            var getOTP = await _context.RAFA_OTP.Where(a => a.MobileNumber.Equals(phoneNum) && DateTime.UtcNow >= a.CreatedDateTime && DateTime.UtcNow <= a.ExpiredDateTime && a.Verified == false && a.IsActive == true).FirstOrDefaultAsync();
            if (getOTP != null)
            {
                Debug.WriteLine(getOTP.OTPCode);
                if (getOTP.OTPCode == otp)
                {
                    var claims = new List<Claim> 
                    {
                        new Claim(ClaimTypes.Name,"reportUser"),
                        new Claim(ClaimTypes.Role,"User"),
                    };
                    var expiresAt = DateTime.UtcNow.AddMinutes(20);
                    getOTP.Verified = true;
                    getOTP.IsActive = false;
                    getOTP.ExpiredDateTime = DateTime.UtcNow;
                    _context.Update(getOTP);
                    await _context.SaveChangesAsync();
                    _logger.LogInformation($"Verified OTP for mobile number {phoneNum}.");
                    return Ok(new
                    {
                        accessToken = CreateToken(claims, expiresAt)
                    });
                }
                else
                {
                    _logger.LogInformation($"Invalid OTP for mobile number {phoneNum}.");
                    return BadRequest("Error verifying OTP code, please try again");
                }
            }
            else
            {
                _logger.LogInformation($"Invalid OTP for mobile number {phoneNum}.");
                return BadRequest("No OTP code found or OTP Expired.");
            }
        }

        [HttpPost("GenerateOTPByMobileNumber")]
        [AllowAnonymous]
        public async Task<ActionResult<RAFAOTP>> GenerateOTPByMobileNumber(String mobileNumber)
        {
            Debug.WriteLine("Entered Post");
            Debug.WriteLine("My Number: " + mobileNumber);
            if (mobileNumber.Length == 8)
            {
                var getExistingOTP = await _context.RAFA_OTP.Where(a => a.MobileNumber.Equals(mobileNumber) && a.ExpiredDateTime.HasValue && a.ExpiredDateTime.Value.CompareTo(DateTime.UtcNow) > 0 && a.Verified == false && a.IsActive == true).FirstOrDefaultAsync();

                if (getExistingOTP == null)
                {
                    if (hashCode == null)
                    {
                        hashCode = new(Guid.NewGuid().GetHashCode());
                    }
                    int otpCode = hashCode.Next(100000, 999999);
                    RAFAOTP otp = new();
                    otp.MobileNumber = mobileNumber;
                    otp.CreatedDateTime = DateTime.UtcNow;
                    otp.ExpiredDateTime = DateTime.UtcNow.AddMinutes(3);
                    otp.Verified = false;
                    otp.IsActive = true;
                    Debug.WriteLine("this is the otp: " + otpCode);
                    otp.OTPCode = otpCode;
                    _context.Add(otp);
                    await _context.SaveChangesAsync();
                    
                    _logger.LogInformation(bool.Parse(configuration["SmsConfiguration:IsSendSMS"]).ToString());
                    //send sms if config is true
                    if (bool.Parse(configuration["SmsConfiguration:IsSendSMS"]))
                    {
                        var response = await SendSmsAsync(mobileNumber, otpCode);

                        _logger.LogInformation($"Status Code = {response.StatusCode}. Request for SMS OTP to {mobileNumber}.");
                        
                        RAFASmsLog smsLog = new();

                        if (response.StatusCode.ToString().Trim().ToUpper() != "OK")
                        {
                            Debug.WriteLine("SMS OTP failed");
                            
                            // //save unsuccessful sms log to db
                            // smsLog.MobileNumber = mobileNumber;
                            // smsLog.IsSuccessful = false;
                            // smsLog.CreatedDateTime = DateTime.UtcNow;
                            // _context.Add(smsLog);
                            // await _context.SaveChangesAsync();

                            //save unsuccessful sms log to shared notifications table
                            smsLog.AppCode = "RAFA";
                            smsLog.NotificationType = "Sms";
                            smsLog.Recipient = mobileNumber;
                            smsLog.MessageId = null;
                            smsLog.Subject = "One Time Password (OTP)";
                            smsLog.IsSuccess = false;
                            smsLog.ErrorMessages = null;
                            smsLog.LogDateTime = DateTime.UtcNow;
                            _context.Add(smsLog);
                            await _context.SaveChangesAsync();
                            _logger.LogWarning("Send SMS failed.");
                            return BadRequest(" Sending SMS failed" + response.StatusCode + " - " + response.ReasonPhrase.ToString());
                        }
                        // //save successful sms log to db
                        // smsLog.MobileNumber = mobileNumber;
                        // smsLog.IsSuccessful = true;
                        // smsLog.CreatedDateTime = DateTime.UtcNow;
                        // _context.Add(smsLog);
                        // await _context.SaveChangesAsync();

                        //save successful sms log to shared notifications table
                        smsLog.AppCode = "RAFA";
                        smsLog.NotificationType = "Sms";
                        smsLog.Recipient = mobileNumber;
                        smsLog.MessageId = null;
                        smsLog.Subject = "One Time Password (OTP)";
                        smsLog.IsSuccess = true;
                        smsLog.ErrorMessages = null;
                        smsLog.LogDateTime = DateTime.UtcNow;
                        _context.Add(smsLog);
                        await _context.SaveChangesAsync();
                    }
                    // return Ok(new { otp = otpCode });
                    _logger.LogInformation("Send SMS successful. testing");
                    return Ok();
                }
                else if (getExistingOTP != null && getExistingOTP.CreatedDateTime.AddMinutes(1).CompareTo(DateTime.UtcNow) < 0)
                {
                    getExistingOTP.IsActive = false;
                    if (hashCode == null)
                    {
                        hashCode = new(Guid.NewGuid().GetHashCode());
                    }
                    int otpCode = hashCode.Next(100000, 999999);
                    RAFAOTP otp = new();
                    otp.MobileNumber = mobileNumber;
                    otp.CreatedDateTime = DateTime.UtcNow;
                    otp.ExpiredDateTime = DateTime.UtcNow.AddMinutes(3);
                    otp.Verified = false;
                    otp.IsActive = true;
                    Debug.WriteLine("this is the otp: " + otpCode);
                    otp.OTPCode = otpCode;
                    _context.Add(otp);
                    await _context.SaveChangesAsync();

                    //send sms if config is true
                    if (bool.Parse(configuration["SmsConfiguration:IsSendSMS"]))
                    {
                        var response = await SendSmsAsync(mobileNumber, otpCode);

                        _logger.LogInformation($"Status Code = {response.StatusCode}. Request for SMS OTP to {mobileNumber}.");
                        
                        RAFASmsLog smsLog = new();

                        if (response.StatusCode.ToString().Trim().ToUpper() != "OK")
                        {
                            Debug.WriteLine("SMS OTP failed");
                            
                            // //save unsuccessful sms log to db
                            // smsLog.MobileNumber = mobileNumber;
                            // smsLog.IsSuccessful = false;
                            // smsLog.CreatedDateTime = DateTime.UtcNow;
                            // _context.Add(smsLog);
                            // await _context.SaveChangesAsync();
                            
                            //save unsuccessful sms log to shared notifications table
                            smsLog.AppCode = "RAFA";
                            smsLog.NotificationType = "Sms";
                            smsLog.Recipient = mobileNumber;
                            smsLog.MessageId = null;
                            smsLog.Subject = "One Time Password (OTP)";
                            smsLog.IsSuccess = false;
                            smsLog.ErrorMessages = null;
                            smsLog.LogDateTime = DateTime.UtcNow;
                            _context.Add(smsLog);
                            await _context.SaveChangesAsync();
                            _logger.LogWarning("Send SMS failed.");
                            return BadRequest(" Sending SMS failed" + response.StatusCode + " - " + response.ReasonPhrase.ToString());
                        }
                        // //save successful sms log to db
                        // smsLog.MobileNumber = mobileNumber;
                        // smsLog.IsSuccessful = true;
                        // smsLog.CreatedDateTime = DateTime.UtcNow;
                        // _context.Add(smsLog);
                        // await _context.SaveChangesAsync();

                        //save successful sms log to shared notifications table
                        smsLog.AppCode = "RAFA";
                        smsLog.NotificationType = "Sms";
                        smsLog.Recipient = mobileNumber;
                        smsLog.MessageId = null;
                        smsLog.Subject = "One Time Password (OTP)";
                        smsLog.IsSuccess = true;
                        smsLog.ErrorMessages = null;
                        smsLog.LogDateTime = DateTime.UtcNow;
                        _context.Add(smsLog);
                        await _context.SaveChangesAsync();
                    }
                    // return Ok(new { otp = otpCode });
                    _logger.LogInformation("Send SMS successful.");
                    return Ok();
                }
                else
                {
                    _logger.LogInformation("There is a existing OTP code.");
                    return BadRequest("There's a existing OTP code.");
                }
            }
            _logger.LogWarning("Length of mobile number is not equal to 8.");
            return BadRequest("Invalid mobile number.");
        }

        [HttpPost("ResendOTPByMobileNumber")]
        [AllowAnonymous]
        public async Task<ActionResult<RAFAOTP>> ResendOTPByMobileNumber(String mobileNumber)
        {
            Debug.WriteLine("Entered Post");
            Debug.WriteLine("My Number: " + mobileNumber);
            if (mobileNumber.Length == 8)
            {
                var getExistingOTP = await _context.RAFA_OTP.Where(a => a.MobileNumber.Equals(mobileNumber) && a.ExpiredDateTime.HasValue && a.ExpiredDateTime.Value.CompareTo(DateTime.UtcNow) > 0 && a.Verified == false && a.IsActive == true).FirstOrDefaultAsync();

                if (getExistingOTP == null)
                {
                    if (hashCode == null)
                    {
                        hashCode = new(Guid.NewGuid().GetHashCode());
                    }
                    int otpCode = hashCode.Next(100000, 999999);
                    RAFAOTP otp = new();
                    otp.MobileNumber = mobileNumber;
                    otp.CreatedDateTime = DateTime.UtcNow;
                    otp.ExpiredDateTime = DateTime.UtcNow.AddMinutes(3);
                    otp.Verified = false;
                    otp.IsActive = true;
                    Debug.WriteLine("this is the otp: " + otpCode);
                    otp.OTPCode = otpCode;
                    _context.Add(otp);
                    await _context.SaveChangesAsync();

                    //send sms if config is true
                    if (bool.Parse(configuration["SmsConfiguration:IsSendSMS"]))
                    {
                        var response = await SendSmsAsync(mobileNumber, otpCode);

                        _logger.LogInformation($"Status Code = {response.StatusCode}. Request for SMS OTP to {mobileNumber}.");
                        
                        RAFASmsLog smsLog = new();

                        if (response.StatusCode.ToString().Trim().ToUpper() != "OK")
                        {
                            Debug.WriteLine("SMS OTP failed");
                            
                            // //save unsuccessful sms log to db
                            // smsLog.MobileNumber = mobileNumber;
                            // smsLog.IsSuccessful = false;
                            // smsLog.CreatedDateTime = DateTime.UtcNow;
                            // _context.Add(smsLog);
                            // await _context.SaveChangesAsync();

                            //save unsuccessful sms log to shared notifications table
                            smsLog.AppCode = "RAFA";
                            smsLog.NotificationType = "Sms";
                            smsLog.Recipient = mobileNumber;
                            smsLog.MessageId = null;
                            smsLog.Subject = "One Time Password (OTP)";
                            smsLog.IsSuccess = false;
                            smsLog.ErrorMessages = null;
                            smsLog.LogDateTime = DateTime.UtcNow;
                            _context.Add(smsLog);
                            await _context.SaveChangesAsync();

                            _logger.LogWarning("Send SMS failed.");
                            return BadRequest(" Sending SMS failed" + response.StatusCode + " - " + response.ReasonPhrase.ToString());
                        }
                        // //save successful sms log to db
                        // smsLog.MobileNumber = mobileNumber;
                        // smsLog.IsSuccessful = true;
                        // smsLog.CreatedDateTime = DateTime.UtcNow;
                        // _context.Add(smsLog);
                        // await _context.SaveChangesAsync();

                        //save successful sms log to shared notifications table
                        smsLog.AppCode = "RAFA";
                        smsLog.NotificationType = "Sms";
                        smsLog.Recipient = mobileNumber;
                        smsLog.MessageId = null;
                        smsLog.Subject = "One Time Password (OTP)";
                        smsLog.IsSuccess = true;
                        smsLog.ErrorMessages = null;
                        smsLog.LogDateTime = DateTime.UtcNow;
                        _context.Add(smsLog);
                        await _context.SaveChangesAsync();
                    }
                    // return Ok(new { otp = otpCode });
                    _logger.LogInformation("Send SMS successful.");
                    return Ok();
                }
                else if (getExistingOTP != null && getExistingOTP.CreatedDateTime.AddMinutes(1).CompareTo(DateTime.UtcNow) < 0)
                {
                    getExistingOTP.IsActive = false;
                    if (hashCode == null)
                    {
                        hashCode = new(Guid.NewGuid().GetHashCode());
                    }
                    int otpCode = hashCode.Next(100000, 999999);
                    RAFAOTP otp = new();
                    otp.MobileNumber = mobileNumber;
                    otp.CreatedDateTime = DateTime.UtcNow;
                    otp.ExpiredDateTime = DateTime.UtcNow.AddMinutes(3);
                    otp.Verified = false;
                    otp.IsActive = true;
                    Debug.WriteLine("this is the otp: " + otpCode);
                    otp.OTPCode = otpCode;
                    _context.Add(otp);
                    await _context.SaveChangesAsync();

                    //send sms if config is true
                    if (bool.Parse(configuration["SmsConfiguration:IsSendSMS"]))
                    {
                        var response = await SendSmsAsync(mobileNumber, otpCode);

                        _logger.LogInformation($"Status Code = {response.StatusCode}. Request for SMS OTP to {mobileNumber}.");
                        
                        RAFASmsLog smsLog = new();

                        if (response.StatusCode.ToString().Trim().ToUpper() != "OK")
                        {
                            Debug.WriteLine("SMS OTP failed");
                            
                            // //save unsuccessful sms log to db
                            // smsLog.MobileNumber = mobileNumber;
                            // smsLog.IsSuccessful = false;
                            // smsLog.CreatedDateTime = DateTime.UtcNow;
                            // _context.Add(smsLog);
                            // await _context.SaveChangesAsync();

                            //save unsuccessful sms log to shared notifications table
                            smsLog.AppCode = "RAFA";
                            smsLog.NotificationType = "Sms";
                            smsLog.Recipient = mobileNumber;
                            smsLog.MessageId = null;
                            smsLog.Subject = "One Time Password (OTP)";
                            smsLog.IsSuccess = false;
                            smsLog.ErrorMessages = null;
                            smsLog.LogDateTime = DateTime.UtcNow;
                            _context.Add(smsLog);
                            await _context.SaveChangesAsync();

                            _logger.LogWarning("Send SMS failed.");
                            return BadRequest(" Sending SMS failed" + response.StatusCode + " - " + response.ReasonPhrase.ToString());
                        }
                        // //save successful sms log to db
                        // smsLog.MobileNumber = mobileNumber;
                        // smsLog.IsSuccessful = true;
                        // smsLog.CreatedDateTime = DateTime.UtcNow;
                        // _context.Add(smsLog);
                        // await _context.SaveChangesAsync();

                        //save successful sms log to shared notifications table
                        smsLog.AppCode = "RAFA";
                        smsLog.NotificationType = "Sms";
                        smsLog.Recipient = mobileNumber;
                        smsLog.MessageId = null;
                        smsLog.Subject = "One Time Password (OTP)";
                        smsLog.IsSuccess = true;
                        smsLog.ErrorMessages = null;
                        smsLog.LogDateTime = DateTime.UtcNow;
                        _context.Add(smsLog);
                        await _context.SaveChangesAsync();    
                    }
                    // return Ok(new { otp "= otpCode });
                    _logger.LogInformation("Send SMS successful.");
                    return Ok();
                }
                else
                {
                    _logger.LogInformation("There is a existing OTP code.");
                    return BadRequest("There's a existing OTP code.");
                }
            }
            _logger.LogInformation("Length of mobile number is not equal to 8.");
            return BadRequest("Invalid mobile number.");
        }

        private async Task<HttpResponseMessage> SendSmsAsync(string mobileNumber, int otpCode)
        {
            string requestUrl = configuration["SmsConfiguration:Url"];
            requestUrl += "?";
            requestUrl += "authid=" + configuration["SmsConfiguration:AuthId"];
            requestUrl += "&authcode=" + configuration["SmsConfiguration:AuthCode"];
            requestUrl += "&source=" + configuration["SmsConfiguration:Source"];
            requestUrl += "&destination=" + mobileNumber;
            requestUrl += "&message=" + 
            $"Thank you for using JTC Facilities Estate Management System. Your One Time Password (OTP) for Report-A-Fault is {otpCode}. This OTP will expire in 3 mins.";
            

            return await _httpClient.PostAsync(requestUrl, null);
        }
        // GET: api/RAFAOTPs
        /*[HttpGet]
        public async Task<ActionResult<IEnumerable<RAFAOTP>>> GetRAFAOTP()
        {
            return await _context.RAFAOTP.ToListAsync();
        }

        // GET: api/RAFAOTPs/5
        [HttpGet("{id}")]
        public async Task<ActionResult<RAFAOTP>> GetRAFAOTP(int id)
        {
            var rAFAOTP = await _context.RAFAOTP.FindAsync(id);

            if (rAFAOTP == null)
            {
                return NotFound();
            }

            return rAFAOTP;
        }

        // PUT: api/RAFAOTPs/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutRAFAOTP(int id, RAFAOTP rAFAOTP)
        {
            if (id != rAFAOTP.Id)
            {
                return BadRequest();
            }

            _context.Entry(rAFAOTP).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!RAFAOTPExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/RAFAOTPs
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<RAFAOTP>> PostRAFAOTP(RAFAOTP rAFAOTP)
        {
            _context.RAFAOTP.Add(rAFAOTP);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetRAFAOTP", new { id = rAFAOTP.Id }, rAFAOTP);
        }

        // DELETE: api/RAFAOTPs/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteRAFAOTP(int id)
        {
            var rAFAOTP = await _context.RAFAOTP.FindAsync(id);
            if (rAFAOTP == null)
            {
                return NotFound();
            }

            _context.RAFAOTP.Remove(rAFAOTP);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool RAFAOTPExists(int id)
        {
            return _context.RAFAOTP.Any(e => e.Id == id);
        }*/
    }
}
