using La_Esperanza_Api.Data;
using La_Esperanza_Api.Data.Models;
using La_Esperanza_Api.Models.Reports;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Rotativa.NetCore;
using Rotativa.NetCore.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace La_Esperanza_Api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PrintController : Controller
    {
        private readonly LaEsperanzaContext _dbContext;
        private readonly ILogger<PrintController> _logger;

        public PrintController(ILogger<PrintController> logger, LaEsperanzaContext dbContext)
        {
            _logger = logger;
            _dbContext = dbContext;
        }

        [HttpGet("order/{id}")]
        public async Task<IActionResult> OrderAsync(int Id)
        {
            try
            {
                Orders order = await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == Id).ConfigureAwait(true);
                ViewAsPdf pdf = new ViewAsPdf
                {
                    FileName = $"{Id.ToString().PadLeft(6, '0')}.pdf",
                    Model = order,
                    ViewName = "PrintOrder",
                    IsLowQuality = false,
                    PageSize = Size.Letter,
                    PageMargins = new Margins(5, 5, 5, 5),
                    PageOrientation = Orientation.Portrait,
                    MinimumFontSize = 6,
                    CustomSwitches = $"--print-media-type --footer-center \"© EGATEC {DateTime.Now.Year}. Todos los derechos reservados.\n\rwww.egatec.com.mx\" --footer-font-size \"6\" --footer-font-name \"Verdana\""
                };
                return File(pdf.BuildFile(ControllerContext), "application/pdf", $"{Id.ToString().PadLeft(6, '0')}.pdf");
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
            }
            return Unauthorized();
        }

        [HttpGet("sales/{id}")]
        public async Task<IActionResult> SalesByDayReportAsync(string Id)
        {
            try
            {
                if (DateTime.TryParse(Id, out DateTime date))
                {
                    List<Orders> orders = await _dbContext.Orders
                        .Where(o => o.StatusId == 4 &&
                                    o.OrderDeliveredDate.Value.Date.Equals(date.Date))
                        .OrderBy(o => o.OrderDeliveredDate)
                        .ToListAsync().ConfigureAwait(true);

                    if (orders.Count > 0)
                    {
                        ViewAsPdf pdf = new ViewAsPdf
                        {
                            Model = orders,
                            ViewName = "SalesByDayReport",
                            IsLowQuality = false,
                            PageSize = Size.Letter,
                            PageMargins = new Margins(5, 5, 5, 5),
                            PageOrientation = Orientation.Portrait,
                            MinimumFontSize = 6,
                            CustomSwitches = $"--print-media-type --footer-center \"© EGATEC {DateTime.Now.Year}. Todos los derechos reservados.\n\rwww.egatec.com.mx\" --footer-font-size \"6\" --footer-font-name \"Verdana\""
                        };
                        return File(pdf.BuildFile(ControllerContext), "application/pdf", $"{Id.Replace("-", "_")}.pdf");
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
            }
            return NotFound();
        }

        [HttpGet("report/{startDate}")]
        public async Task<IActionResult> SalesReportAsync([FromRoute] string startDate, [FromQuery] string endDate)
        {
            try
            {
                if (DateTime.TryParse(startDate, out DateTime start) && DateTime.TryParse(endDate, out DateTime end))
                {
                    List<Orders> orders = null;

                    if (start.Date.Equals(end.Date))
                    {
                        orders = await _dbContext.Orders
                                .Where(o => o.StatusId == 4 && o.OrderDeliveredDate.Value.Date == start.Date)
                                .OrderBy(o => o.OrderDeliveredDate)
                                .ToListAsync().ConfigureAwait(true);
                    }
                    else
                    {
                        orders = await _dbContext.Orders
                                .Where(o => o.StatusId == 4 && o.OrderDeliveredDate.Value.Date >= start.Date && o.OrderDeliveredDate.Value.Date <= end.Date)
                                .OrderBy(o => o.OrderDeliveredDate)
                                .ToListAsync().ConfigureAwait(true);
                    }

                    if (orders.Count > 0)
                    {
                        SalesByRangeModel model = new SalesByRangeModel
                        {
                            StartDate = start,
                            EndDate = end,
                            Orders = orders
                        };

                        ViewAsPdf pdf = new ViewAsPdf
                        {
                            Model = model,
                            ViewName = "SalesByRangeReport",
                            IsLowQuality = false,
                            PageSize = Size.Letter,
                            PageMargins = new Margins(5, 5, 5, 5),
                            PageOrientation = Orientation.Portrait,
                            MinimumFontSize = 6,
                            CustomSwitches = $"--print-media-type --footer-center \"© EGATEC {DateTime.Now.Year}. Todos los derechos reservados.\n\rwww.egatec.com.mx\" --footer-font-size \"6\" --footer-font-name \"Verdana\""
                        };
                        return File(pdf.BuildFile(ControllerContext), "application/pdf", $"{startDate.Replace("-", "_")}_{endDate.Replace("-", "_")}.pdf");
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
            }
            return NotFound();
        }
    }
}