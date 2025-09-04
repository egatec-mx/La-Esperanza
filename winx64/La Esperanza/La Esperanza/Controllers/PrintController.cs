using La_Esperanza.Data;
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

namespace La_Esperanza.Controllers
{
    [Authorize]
    public class PrintController : Controller
    {
        private readonly LaEsperanzaContext _dbContext;
        private readonly ILogger<OrderController> _logger;

        public PrintController(ILogger<OrderController> logger, LaEsperanzaContext dbContext)
        {
            _logger = logger;
            _dbContext = dbContext;
        }

        public async Task<IActionResult> PrintOrderAsync(int Id)
        {
            try
            {
                Orders order = await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == Id);
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
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        [AllowAnonymous]
        public async Task<IActionResult> PrintAppleOrderAsync(int Id)
        {
            try
            {
                if (!string.IsNullOrEmpty(Request.Headers["Device"].ToString()))
                {
                    string deviceId = Request.Headers["Device"].ToString();
                    Devices device = await _dbContext.Devices.FirstOrDefaultAsync(d => d.DevicePushP256dh.Equals(deviceId) && d.DeviceValid.Value);
                    if (device != null)
                    {
                        Orders order = await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == Id);
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
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return Unauthorized();
        }

        public async Task<IActionResult> PrintSalesReportAsync(string Id)
        {
            try
            {
                DateTime date = DateTime.Parse(Id);
                List<Orders> orders = await _dbContext.Orders
                    .Where(o => o.StatusId == 4 &&
                                o.OrderDeliveredDate.Value.Date.Equals(date.Date))
                    .OrderBy(o => o.OrderDeliveredDate)
                    .ToListAsync();
                ViewAsPdf pdf = new ViewAsPdf
                {
                    FileName = $"{Id.Replace("-", "_")}.pdf",
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
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        [AllowAnonymous]
        public async Task<IActionResult> PrintAppleSalesReportAsync(string Id)
        {
            try
            {
                if (!string.IsNullOrEmpty(Request.Headers["Device"].ToString()))
                {
                    string deviceId = Request.Headers["Device"].ToString();
                    Devices device = await _dbContext.Devices.FirstOrDefaultAsync(d => d.DevicePushP256dh.Equals(deviceId) && d.DeviceValid.Value);
                    if (device != null)
                    {
                        DateTime date = DateTime.Parse(Id);
                        List<Orders> orders = await _dbContext.Orders
                            .Where(o => o.StatusId == 4 &&
                                        o.OrderDeliveredDate.Value.Date.Equals(date.Date))
                            .OrderBy(o => o.OrderDeliveredDate)
                            .ToListAsync();
                        ViewAsPdf pdf = new ViewAsPdf
                        {
                            FileName = $"{Id.ToString().PadLeft(6, '0')}.pdf",
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
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return Unauthorized();
        }
    }
}