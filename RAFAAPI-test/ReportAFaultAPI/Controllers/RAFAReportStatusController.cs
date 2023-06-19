// using Microsoft.AspNetCore.Http;
// using Microsoft.AspNetCore.Mvc;
// using System;
// using System.Collections.Generic;
// using System.Linq;
// using System.Threading.Tasks;
// using ReportAFaultAPI.Models;
// using Microsoft.EntityFrameworkCore;
// using Microsoft.AspNetCore.Authorization;

// namespace ReportAFaultAPI.Controllers
// {
//     [Route("api/[controller]")]
//     [ApiController]
//     public class RAFAReportStatusController : Controller
//     {
//         private readonly RafaDbContext _context;

//         public RAFAReportStatusController(RafaDbContext context)
//         {
//             _context = context;
//         }

//         [HttpGet]
//         [AllowAnonymous]
//         public async Task<ActionResult<IEnumerable<RAFAFaultReport>>> GetRAFAReportStatus()
//         {
//             return await _context.RAFA_FAULTREPORT.ToListAsync();
//         }

//         [HttpGet("RetreiveStatusByMobile")]
//         public async Task<ActionResult<IEnumerable<RAFAFaultReport>>> GetEstate(string mobile)
//         {
//             IEnumerable<RAFAFaultReport> RAFAFaultReport;
//             if (string.IsNullOrEmpty(mobile))
//             {
//                 RAFAFaultReport = await _context.RAFA_FAULTREPORT.ToListAsync();
//             }
//             else
//             {
//                 RAFAFaultReport = await _context.RAFA_FAULTREPORT.Where(tr => tr.ContactNumber == mobile).ToListAsync();

//             }
//             return Ok(RAFAFaultReport);
//         }

//     }
// }
