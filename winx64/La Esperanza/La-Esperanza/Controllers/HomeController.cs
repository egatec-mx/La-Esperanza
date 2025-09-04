using La_Esperanza.Data;
using La_Esperanza.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Primitives;
using System;
using System.Diagnostics;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace La_Esperanza.Controllers
{
    [Authorize]
    public class HomeController : Controller
    {
        private readonly ILogger<HomeController> _logger;
        private readonly LaEsperanzaContext _dbContext;

        public HomeController(ILogger<HomeController> logger, LaEsperanzaContext dbContext)
        {
            _logger = logger;
            _dbContext = dbContext;
        }

        public IActionResult Index()
        {
            return View();
        }

        public IActionResult NewOrders()
        {
            try
            {
                return Ok(new
                {
                    orders = _dbContext.Orders.Where(o => o.StatusId == 1).Select(o => new { o.OrderId, o.OrderTotal, o.Customer.CustomerName }).AsEnumerable().TakeLast(5),
                    total = _dbContext.Orders.Where(o => o.StatusId == 1).Count()
                });
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return Error();
        }

        public IActionResult ProcessingOrders()
        {
            try
            {
                return Ok(new
                {
                    orders = _dbContext.Orders.Where(o => o.StatusId == 2).Select(o => new { o.OrderId, o.OrderTotal, o.Customer.CustomerName }).AsEnumerable().TakeLast(5),
                    total = _dbContext.Orders.Where(o => o.StatusId == 2).Count()
                });
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return Error();
        }

        public IActionResult DeliveryOrders()
        {
            try
            {
                return Ok(new
                {
                    orders = _dbContext.Orders.Where(o => o.StatusId == 3).Select(o => new { o.OrderId, o.OrderTotal, o.Customer.CustomerName }).AsEnumerable().TakeLast(5),
                    total = _dbContext.Orders.Where(o => o.StatusId == 3).Count()
                });
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return Error();
        }

        public IActionResult CompletedOrders()
        {
            try
            {
                return Ok(new
                {
                    orders = _dbContext.Orders.Where(o => o.StatusId == 4).Select(o => new { o.OrderId, o.OrderTotal, o.Customer.CustomerName }).AsEnumerable().TakeLast(5),
                    total = _dbContext.Orders.Where(o => o.StatusId == 4).Count()
                });
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return Error();
        }

        public IActionResult CanceledOrders()
        {
            try
            {
                return Ok(new
                {
                    orders = _dbContext.Orders.Where(o => o.StatusId == 5).Select(o => new { o.OrderId, o.OrderTotal, o.Customer.CustomerName }).AsEnumerable().TakeLast(5),
                    total = _dbContext.Orders.Where(o => o.StatusId == 5).Count()
                });
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return Error();
        }

        public IActionResult RejectedOrders()
        {
            try
            {
                return Ok(new
                {
                    orders = _dbContext.Orders.Where(o => o.StatusId == 6).Select(o => new { o.OrderId, o.OrderTotal, o.Customer.CustomerName }).AsEnumerable().TakeLast(5),
                    total = _dbContext.Orders.Where(o => o.StatusId == 6).Count()
                });
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return Error();
        }

        public IActionResult SalesByDay()
        {
            try
            {
                return Ok(_dbContext.Orders
                    .Where(o => o.StatusId == 4)
                    .GroupBy(o => o.OrderDeliveredDate.Value.Date)
                    .Select(o => new
                    {
                        orders = o.Count(),
                        total = o.Sum(p => p.OrderTotal),
                        date = o.Key.ToShortDateString()
                    })
                    .AsEnumerable()
                    .TakeLast(5));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return Error();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public IActionResult SalesByDay(SalesDates model)
        {
            try
            {
                if (ModelState.IsValid)
                {
                    DateTime start = DateTime.Parse(model.StartDate);
                    DateTime end = DateTime.Parse(model.EndDate);
                    return Ok(_dbContext.Orders
                    .Where(o => o.StatusId == 4 && o.OrderDeliveredDate.Value.Date >= start && o.OrderDeliveredDate.Value.Date <= end)
                    .GroupBy(o => o.OrderDeliveredDate.Value.Date)
                    .Select(o => new
                    {
                        orders = o.Count(),
                        total = o.Sum(p => p.OrderTotal),
                        date = o.Key.ToShortDateString()
                    }));
                }
                return BadRequest();
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return Error();
        }

        public async Task<IActionResult> SalesByDayDetailsAsync([FromRoute] string Id)
        {
            try
            {
                StringValues agent = Request.Headers["user-agent"];
                ViewBag.IsApple = Regex.Match(agent.First(), @"iphone|ipad|ios|ipados|pad", RegexOptions.IgnoreCase).Success;
                ViewBag.ReportDate = Id;
                DateTime date = DateTime.Parse(Id);
                return PartialView(await _dbContext.Orders
                    .Where(o => o.StatusId == 4 &&
                                o.OrderDeliveredDate.Value.Date.Equals(date.Date))
                    .OrderBy(o => o.OrderDeliveredDate)
                    .ToListAsync());
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return Error();
        }

        public IActionResult Error()
        {
            return View(new ErrorViewModel { RequestId = Activity.Current?.Id ?? HttpContext.TraceIdentifier });
        }
    }
}