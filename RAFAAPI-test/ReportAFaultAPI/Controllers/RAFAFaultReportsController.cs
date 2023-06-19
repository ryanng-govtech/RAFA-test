using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ReportAFaultAPI.Models;
using System.IO;
using MimeDetective;
using Microsoft.Extensions.Logging;
using ReportAFaultAPI.Interfaces;
using System.Diagnostics;

namespace ReportAFaultAPI.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class RAFAFaultReportsController : ControllerBase
    {
        private readonly ILogger _logger;
        private readonly RafaDbContext _context;
        private IRAFAEnvisionController _RAFAEnvisionController;

        public RAFAFaultReportsController(ILogger<RAFAFaultReportsController> logger, RafaDbContext context, IRAFAEnvisionController RAFAEnvisionController)
        {
            _logger = logger;
            _context = context;
            _RAFAEnvisionController = RAFAEnvisionController;
        }

        // [HttpGet("RetrieveReportById")]
        // public async Task<ActionResult<RAFAFaultReport>> GetReportById(int reportId)
        // {
        //     if (reportId != 0)
        //     {
        //         var report = await _context.RAFA_FAULTREPORT.Where(a => a.Id == reportId).FirstOrDefaultAsync();
        //         if (report != null)
        //         {
        //             return Ok(report);
        //         }
        //         else
        //         {
        //             return NotFound("No report with ID is found");
        //         }
        //     }
        //     else
        //     {
        //         return BadRequest("Missing required parameters");
        //     }
        // }
        [Authorize(Roles = "User")]
        [HttpPost("CreateNewFault")]
        public async Task<ActionResult<RAFAFaultReport>> CreateNewFault([FromForm] RAFAFaultReport rfr)
        {
            var images = Request.Form.Files;
            rfr.RAFAFaultImages = new List<RAFAFaultImage>();
            if (images.Count <= 10)
            {
                var Inspector = new ContentInspectorBuilder()
                {
                    Definitions = MimeDetective.Definitions.Default.FileTypes.Images.All()
                }.Build();
                if (images.Count > 0)
                {
                    Debug.WriteLine(images.Count);
                    foreach (IFormFile image in images)
                    {
                        using (var fs1 = image.OpenReadStream())
                        {
                            var content = ContentReader.Default.ReadFromStream(fs1);
                            var results = Inspector.Inspect(content);
                            var resultsByFileExtension = results.ByFileExtension();
                            if (!resultsByFileExtension.IsDefaultOrEmpty)
                            {
                                Debug.WriteLine("File check passed!");
                                byte[] imageByteArr = null;
                                Debug.WriteLine(image.Length);
                                if (image.Length > 0 && image.Length < 5 * 1024 * 1024)
                                {
                                    using (var ms1 = new MemoryStream())
                                    {
                                        fs1.CopyTo(ms1);
                                        imageByteArr = ms1.ToArray();
                                    }
                                    RAFAFaultImage rfi = new RAFAFaultImage();
                                    rfi.ImageData = imageByteArr;
                                    rfr.RAFAFaultImages.Add(rfi);
                                }
                            }
                            else
                            {   
                                _logger.LogWarning("File check failed.");
                                Debug.WriteLine("File check failed!");
                            }
                        }
                    }
                }
                //add case id RAFA_yy0001 e.g. RAFA_220001 to model
                string? jtcCaseIdVar = null;
                var rafaFaultReportLatestId = (from r in _context.RAFA_FAULTREPORT
                                               orderby r.Id descending
                                               select r.JtcCaseId).FirstOrDefault();
                //year in yy format e.g. 22
                DateTimeOffset dtoUtc = new DateTimeOffset(DateTime.UtcNow);
                TimeSpan offset = new TimeSpan(+8, 00, 00);
                var dtToSpecificTimezone = dtoUtc.ToOffset(offset);
                if (null == rafaFaultReportLatestId)
                {
                    jtcCaseIdVar = "RAFA_";
                    jtcCaseIdVar += dtToSpecificTimezone.ToString("yy");
                    jtcCaseIdVar += "0001";
                }
                else
                {
                    string rafaFaultReportIdLatestYear = rafaFaultReportLatestId.Substring(5, 2);
                    if (rafaFaultReportIdLatestYear == dtToSpecificTimezone.ToString("yy"))
                    {
                        Int32.TryParse(rafaFaultReportLatestId.Substring(7), out int runningNumber);
                        runningNumber += 1;
                        jtcCaseIdVar = "RAFA_";
                        jtcCaseIdVar += dtToSpecificTimezone.ToString("yy");
                        for (int i = 0; i < 4 - runningNumber.ToString().Length; i++)
                        {
                            jtcCaseIdVar += "0";
                        }
                        jtcCaseIdVar += runningNumber;
                    }
                    else
                    {
                        jtcCaseIdVar = "RAFA_";
                        jtcCaseIdVar += dtToSpecificTimezone.ToString("yy");
                        jtcCaseIdVar += "0001";
                    }
                }
                rfr.JtcCaseId = jtcCaseIdVar;

                //add current datetime to report
                rfr.CreatedDateTime = dtToSpecificTimezone.ToString("yyyy-MM-ddTHH:mm:ss");

                //Register Envision JMM API
                string bearerToken = await _RAFAEnvisionController.RegisterToken();
                _logger.LogInformation($"Done with registering Envision token.");

                //Invoke Envision JMM API Create Case
                Debug.WriteLine("JTC Case Id:" + rfr.JtcCaseId);
                string envisionJtcCaseId = await _RAFAEnvisionController.CreateCase(bearerToken, rfr);
                Debug.WriteLine("Returned Case Id: " + envisionJtcCaseId);
                
                //Save changes to own db if no exceptions thrown for JMM API Create Case
                _context.Add(rfr);
                await _context.SaveChangesAsync();

                //Invoke Envision JMM API Upload Document (images)
                int counter = 0;
                foreach (RAFAFaultImage rafaFaultImage in rfr.RAFAFaultImages)
                {
                    counter++;
                    await _RAFAEnvisionController.UploadDocument(bearerToken, envisionJtcCaseId, rafaFaultImage, counter);
                }

                _logger.LogInformation($"{jtcCaseIdVar} successfully submitted.");
                return Ok(new { jtcCaseId = jtcCaseIdVar });
            }
            _logger.LogWarning("Blocked attempt to upload more than 10 images.");
            return BadRequest("Cannot upload more than 10 images");
        }
        // DateTimeOffset dtoUtc = new DateTimeOffset(DateTime.UtcNow);
        // TimeSpan offset = new TimeSpan(+8, 00, 00);  // Specify timezone
        // var dtToSpecificTimezone = dtoUtc.ToOffset(offset);
        // Debug.WriteLine (dtToSpecificTimezone.ToString("yyyy-MM-ddTHH:mm:ss"));

        // [Authorize(Roles = "User")]
        // [HttpPost("CreateNewFault")]
        // public async Task<ActionResult<RAFAFaultReport>> CreateNewFault([FromForm] RAFAFaultReport rfr)
        // {
        //     var images = Request.Form.Files;
        //     if (images.Count <= 10)
        //     {
        //         var Inspector = new ContentInspectorBuilder()
        //         {
        //             Definitions = MimeDetective.Definitions.Default.FileTypes.Images.All()
        //         }.Build();
        //         if (images.Count > 0)
        //         {
        //             rfr.RAFAFaultImages = new List<RAFAFaultImage>();
        //             Debug.WriteLine(images.Count);
        //             foreach (IFormFile image in images)
        //             {
        //                 using (var fs1 = image.OpenReadStream())
        //                 {
        //                     var content = ContentReader.Default.ReadFromStream(fs1);
        //                     var results = Inspector.Inspect(content);
        //                     var resultsByFileExtension = results.ByFileExtension();
        //                     if (!resultsByFileExtension.IsDefaultOrEmpty)
        //                     {
        //                         Debug.WriteLine("File check passed!");
        //                         byte[] imageByteArr = null;
        //                         Debug.WriteLine(image.Length);
        //                         if (image.Length > 0 && image.Length < 5 * 1024 * 1024)
        //                         {
        //                             using (var ms1 = new MemoryStream())
        //                             {
        //                                 fs1.CopyTo(ms1);
        //                                 imageByteArr = ms1.ToArray();
        //                             }
        //                             RAFAFaultImage rfi = new RAFAFaultImage();
        //                             rfi.ImageData = imageByteArr;
        //                             rfr.RAFAFaultImages.Add(rfi);
        //                         }
        //                     }
        //                     else
        //                     {
        //                         Debug.WriteLine("File check failed!");
        //                     }
        //                 }
        //             }
        //         }
        //         //add case id e.g. RAFA-0002 to model
        //         var rafaFaultReportLatestId = (from r in _context.RAFA_FAULTREPORT
        //             orderby r.Id descending
        //             select r.Id).FirstOrDefault();
        //         rafaFaultReportLatestId += 1;
        //         string jtcCaseIdVar = "RAFA-";
        //         for (int i = 0; i < 4 - rafaFaultReportLatestId.ToString().Length; i++) {
        //             jtcCaseIdVar += "0";
        //         }
        //         jtcCaseIdVar += rafaFaultReportLatestId;
        //         rfr.JtcCaseId = jtcCaseIdVar;

        //         //add current datetime to report
        //         rfr.CreatedDateTime = DateTime.Now;

        //         _context.Add(rfr);
        //         await _context.SaveChangesAsync();

        //         _logger.LogInformation($"{jtcCaseIdVar} successfully submitted.");
        //         return Ok(new {jtcCaseId = jtcCaseIdVar});
        //     }
        //     _logger.LogWarning("Blocked attempt to upload more than 10 images.");
        //     return BadRequest("Cannot upload more than 10 images");
        // }

        // GET: api/RAFAFaultReports
        /*[HttpGet]
        public async Task<ActionResult<IEnumerable<RAFAFaultReport>>> GetRAFAFaultReport()
        {
            return await _context.RAFAFaultReport.ToListAsync();
        }

        // GET: api/RAFAFaultReports/5
        [HttpGet("{id}")]
        public async Task<ActionResult<RAFAFaultReport>> GetRAFAFaultReport(int id)
        {
            var rAFAFaultReport = await _context.RAFAFaultReport.FindAsync(id);

            if (rAFAFaultReport == null)
            {
                return NotFound();
            }

            return rAFAFaultReport;
        }

        // PUT: api/RAFAFaultReports/5
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPut("{id}")]
        public async Task<IActionResult> PutRAFAFaultReport(int id, RAFAFaultReport rAFAFaultReport)
        {
            if (id != rAFAFaultReport.Id)
            {
                return BadRequest();
            }

            _context.Entry(rAFAFaultReport).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!RAFAFaultReportExists(id))
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

        // POST: api/RAFAFaultReports
        // To protect from overposting attacks, see https://go.microsoft.com/fwlink/?linkid=2123754
        [HttpPost]
        public async Task<ActionResult<RAFAFaultReport>> PostRAFAFaultReport(RAFAFaultReport rAFAFaultReport)
        {
            _context.RAFAFaultReport.Add(rAFAFaultReport);
            await _context.SaveChangesAsync();

            return CreatedAtAction("GetRAFAFaultReport", new { id = rAFAFaultReport.Id }, rAFAFaultReport);
        }

        // DELETE: api/RAFAFaultReports/5
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteRAFAFaultReport(int id)
        {
            var rAFAFaultReport = await _context.RAFAFaultReport.FindAsync(id);
            if (rAFAFaultReport == null)
            {
                return NotFound();
            }

            _context.RAFAFaultReport.Remove(rAFAFaultReport);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        private bool RAFAFaultReportExists(int id)
        {
            return _context.RAFAFaultReport.Any(e => e.Id == id);
        }*/
    }
}
