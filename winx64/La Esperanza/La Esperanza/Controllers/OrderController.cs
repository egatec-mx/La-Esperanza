using La_Esperanza.Data;
using La_Esperanza.Helpers;
using La_Esperanza.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace La_Esperanza.Controllers
{
    [Authorize]
    public class OrderController : Controller
    {
        private readonly IConfiguration _configuration;
        private readonly LaEsperanzaContext _dbContext;
        private readonly ILogger<OrderController> _logger;
        private readonly IPushService _pushService;

        public OrderController(ILogger<OrderController> logger, LaEsperanzaContext dbContext, IConfiguration configuration, IPushService pushService)
        {
            _logger = logger;
            _dbContext = dbContext;
            _configuration = configuration;
            _pushService = pushService;
        }

        public IActionResult AddOrder()
        {
            try
            {
                ViewBag.States = StatesList();
                ViewBag.Mop = MopList();
                return PartialView(new Orders { OrderId = 0, StatusId = 1, CustomerId = -1 });
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return PartialView();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AddOrderAsync(Orders model)
        {
            try
            {
                if (model.CustomerId > 0)
                {
                    model.Customer = null;
                }

                model.OrderDate = DateTime.Now;
                model.UserId = int.Parse(User.Claims.FirstOrDefault(c => c.Type == "UserId").Value);

                _ = _dbContext.Orders.Add(model);
                _ = await _dbContext.SaveChangesAsync();

                model.OrderQRCode = await new CodeGeneratorHelper().GetCodeAsync(model.OrderId.ToString().PadLeft(6, '0'));
                _ = await _dbContext.SaveChangesAsync();

                model.User = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == model.UserId);
                await _pushService.SendToAllDevicesAsync("¡Nuevo pedido!", $"{model.User.UserFirstname} {model.User.UserLastname} ha creado un nuevo pedido con el No.{model.OrderId.ToString().PadLeft(6, '0')}");

                ViewBag.Message = $"El pedido No.{model.OrderId.ToString().PadLeft(6, '0')} se ha creado correctamente";
                return PartialView("_Success");
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }

            ViewBag.States = StatesList();
            return PartialView(model);
        }

        public IActionResult CanceledOrdersList()
        {
            try
            {
                return View(_dbContext.Orders.Where(o => o.StatusId == 5));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        public IActionResult CompletedOrdersList()
        {
            try
            {
                return View(_dbContext.Orders.Where(o => o.StatusId == 4));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        public async Task<IActionResult> DeleteOrderAsync(int Id)
        {
            try
            {
                return PartialView(await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == Id));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        [HttpDelete]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteOrderAsync(Orders model)
        {
            try
            {
                int UserId = int.Parse(User.Claims.FirstOrDefault(c => c.Type == "UserId").Value);
                Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == UserId);

                if (model.OrderId > 0)
                {
                    Orders dbOrder = await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == model.OrderId);

                    if (dbOrder != null)
                    {
                        dbOrder.StatusId = 5;
                        dbOrder.OrderCanceledDate = DateTime.Now;
                        dbOrder.OrderCanceledReason = model.OrderCanceledReason;

                        _dbContext.Entry(dbOrder).State = EntityState.Modified;
                        _ = await _dbContext.SaveChangesAsync();

                        await _pushService.SendToAllDevicesAsync("¡Pedido cancelado!", $"{dbUser.UserFirstname} {dbUser.UserLastname} ha cancelado el pedido con el No.{dbOrder.OrderId.ToString().PadLeft(6, '0')} debido a \"{dbOrder.OrderCanceledReason}\".");

                        ViewBag.Message = $"El pedido No.{model.OrderId.ToString().PadLeft(6, '0')} ha sido cancelado correctamente.";
                        return PartialView("_Success");
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return PartialView(model);
        }

        public IActionResult DeliveryOrdersList()
        {
            try
            {
                return View(_dbContext.Orders
                    .Where(o => o.StatusId == 3 && o.OrderScheduleDate.HasValue)
                    .ToList()
                    .OrderBy(o => o.OrderScheduleDate.Value.TimeOfDay)
                    .GroupBy(o => o.OrderScheduleDate.Value.Date)
                    .OrderBy(o => o.Key));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        public async Task<IActionResult> DetailsOrderAsync(int Id)
        {
            try
            {
                return PartialView(await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == Id));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        public async Task<IActionResult> EditOrderAsync(int Id)
        {
            try
            {
                ViewBag.States = StatesList();
                ViewBag.Products = ProductsList();
                ViewBag.Mop = MopList();
                return PartialView(await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == Id));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        [HttpPut]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditOrderAsync(Orders model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    int UserId = int.Parse(User.Claims.FirstOrDefault(c => c.Type == "UserId").Value);
                    Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == UserId);

                    if (model.CustomerId == 0)
                    {
                        model.Customer.CustomerId = 0;
                        _ = _dbContext.Customers.Add(model.Customer);
                    }

                    model.OrderDetails = await _dbContext.OrderDetails.Where(o => o.OrderId == model.OrderId).ToListAsync();

                    for (int i = 0; i < Request.Form.Keys.Count; i++)
                    {
                        if (!string.IsNullOrEmpty(Request.Form[$"OrderDetails[{i}].OrderDetailId"]))
                        {
                            OrderDetails detail = model.OrderDetails.FirstOrDefault(d => d.OrderDetailId == long.Parse(Request.Form[$"OrderDetails[{i}].OrderDetailId"]));
                            if (detail != null)
                            {
                                detail.OrderDetailQuantity = double.Parse(Request.Form[$"OrderDetails[{i}].OrderDetailQuantity"]);
                                detail.ProductId = int.Parse(Request.Form[$"OrderDetails[{i}].ProductId"]);
                                detail.OrderDetailPrice = decimal.Parse(Request.Form[$"OrderDetails[{i}].OrderDetailPrice"]);
                                detail.OrderDetailTotal = decimal.Parse(Request.Form[$"OrderDetails[{i}].OrderDetailTotal"]);
                                _dbContext.Entry(detail).State = EntityState.Modified;
                            }
                            else
                            {
                                detail = new OrderDetails
                                {
                                    OrderId = model.OrderId,
                                    OrderDetailQuantity = double.Parse(Request.Form[$"OrderDetails[{i}].OrderDetailQuantity"]),
                                    ProductId = int.Parse(Request.Form[$"OrderDetails[{i}].ProductId"]),
                                    OrderDetailPrice = decimal.Parse(Request.Form[$"OrderDetails[{i}].OrderDetailPrice"]),
                                    OrderDetailTotal = decimal.Parse(Request.Form[$"OrderDetails[{i}].OrderDetailTotal"])
                                };
                                _ = _dbContext.OrderDetails.Add(detail);
                            }
                        }
                    }

                    foreach (OrderDetails detail in model.OrderDetails)
                    {
                        if (_dbContext.Entry(detail).State != EntityState.Modified)
                        {
                            _dbContext.Entry(detail).State = EntityState.Deleted;
                        }
                    }

                    model.OrderQRCode = await new CodeGeneratorHelper().GetCodeAsync(model.OrderId.ToString().PadLeft(6, '0'));

                    _dbContext.Entry(model).State = EntityState.Modified;
                    _ = await _dbContext.SaveChangesAsync();

                    await _pushService.SendToAllDevicesAsync("¡Pedido modificado!", $"{dbUser.UserFirstname} {dbUser.UserLastname} ha modificado el pedido con el No.{model.OrderId.ToString().PadLeft(6, '0')}");

                    ViewBag.Message = $"El pedido No. {model.OrderId.ToString().PadLeft(6, '0')} se actualizó correctamente";
                    return PartialView("_Success");
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                    _logger.LogError(ex, "¡Uops!");
                }
            }

            ViewBag.States = StatesList();
            ViewBag.Products = ProductsList();
            return PartialView(model);
        }

        public async Task<IActionResult> MoveOrderAsync(int Id)
        {
            try
            {
                return PartialView(await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == Id));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        [HttpPut]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> MoveOrderAsync(Orders model)
        {
            try
            {
                if (model.OrderId > 0)
                {
                    int UserId = int.Parse(User.Claims.FirstOrDefault(c => c.Type == "UserId").Value);
                    Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == UserId);

                    Orders dbOrder = await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == model.OrderId);

                    if (dbOrder != null)
                    {
                        switch (dbOrder.StatusId)
                        {
                            case 1:
                                dbOrder.StatusId = 2;
                                dbOrder.OrderStartedDate = DateTime.Now;

                                await _pushService.SendToAllDevicesAsync("¡Pedido en preparación!", $"{dbUser.UserFirstname} {dbUser.UserLastname} ha movido el pedido con el No.{dbOrder.OrderId.ToString().PadLeft(6, '0')} a \"En preparación\".");
                                ViewBag.Message = $"El pedido No.{model.OrderId.ToString().PadLeft(6, '0')} se ha pasado a \"En preparación\" correctamente.";
                                break;

                            case 2:
                                dbOrder.StatusId = 3;
                                dbOrder.OrderProcessedDate = DateTime.Now;

                                await _pushService.SendToAllDevicesAsync("¡Pedido listo para entregar!", $"{dbUser.UserFirstname} {dbUser.UserLastname} ha movido el pedido con el No.{dbOrder.OrderId.ToString().PadLeft(6, '0')} a \"Listo para entregar\".");
                                ViewBag.Message = $"El pedido No.{model.OrderId.ToString().PadLeft(6, '0')} se ha pasado a \"Listo para entregar\" correctamente.";
                                break;

                            case 3:
                                dbOrder.StatusId = 4;
                                dbOrder.OrderDeliveredDate = DateTime.Now;

                                await _pushService.SendToAllDevicesAsync("¡Pedido entregado!", $"{dbUser.UserFirstname} {dbUser.UserLastname} ha entregado el pedido con el No.{dbOrder.OrderId.ToString().PadLeft(6, '0')} y cobró {dbOrder.OrderTotal:C2}.");
                                ViewBag.Message = $"El pedido No.{model.OrderId.ToString().PadLeft(6, '0')} ha sido entregado y cerrado correctamente.";
                                break;
                        }

                        _dbContext.Entry(dbOrder).State = EntityState.Modified;
                        _ = await _dbContext.SaveChangesAsync();

                        return PartialView("_Success");
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return PartialView(model);
        }

        public IActionResult OrdersList()
        {
            try
            {
                return View(_dbContext.Orders
                    .Where(o => o.StatusId == 1 && o.OrderScheduleDate.HasValue)
                    .ToList()
                    .GroupBy(o => o.OrderScheduleDate.Value.Date)
                    .OrderBy(o => o.Key.Date));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        public IActionResult ProcessingOrdersList()
        {
            try
            {
                return View(_dbContext.Orders
                    .Where(o => o.StatusId == 2 && o.OrderScheduleDate.HasValue)
                    .ToList()
                    .OrderBy(o => o.OrderScheduleDate.Value.TimeOfDay)
                    .GroupBy(o => o.OrderScheduleDate.Value.Date)
                    .OrderBy(o => o.Key));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        public IActionResult RejectedOrdersList()
        {
            try
            {
                return View(_dbContext.Orders.Where(o => o.StatusId == 6));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        public async Task<IActionResult> RejectOrderAsync(int Id)
        {
            try
            {
                return PartialView(await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == Id));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        [HttpDelete]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> RejectOrderAsync(Orders model)
        {
            try
            {
                int UserId = int.Parse(User.Claims.FirstOrDefault(c => c.Type == "UserId").Value);
                Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == UserId);

                if (model.OrderId > 0)
                {
                    Orders dbOrder = await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == model.OrderId);

                    if (dbOrder != null)
                    {
                        dbOrder.StatusId = 6;
                        dbOrder.OrderRejectedDate = DateTime.Now;
                        dbOrder.OrderRejectedReason = model.OrderRejectedReason;

                        _dbContext.Entry(dbOrder).State = EntityState.Modified;
                        _ = await _dbContext.SaveChangesAsync();

                        await _pushService.SendToAllDevicesAsync("¡Pedido rechazado!", $"{dbUser.UserFirstname} {dbUser.UserLastname} indica que el pedido con el No.{dbOrder.OrderId.ToString().PadLeft(6, '0')} ha sido rechazado debido a \"{dbOrder.OrderRejectedReason}\".");

                        ViewBag.Message = $"El pedido No.{model.OrderId.ToString().PadLeft(6, '0')} ha sido rechazado correctamente.";
                        return PartialView("_Success");
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return PartialView(model);
        }

        private IEnumerable<SelectListItem> MopList()
        {
            return new SelectList(_dbContext.MethodOfPayment
                .Where(m => m.MopActive.Value)
                .OrderBy(m => m.MopDescription), "MopId", "MopDescription")
                .Prepend(new SelectListItem("--- Seleccione un metodo ---", ""));
        }

        private IEnumerable<SelectListItem> ProductsList()
        {
            return new SelectList(_dbContext.Products
                .Where(s => s.ProductActive.Value)
                .OrderBy(o => o.ProductName), "ProductId", "ProductName")
                .Prepend(new SelectListItem("--- Seleccione un producto ---", ""));
        }

        private IEnumerable<SelectListItem> StatesList()
        {
            return new SelectList(_dbContext.States
                .Where(s => s.StateActive.Value)
                .OrderBy(s => s.StateName), "StateId", "StateName")
                .Prepend(new SelectListItem("--- Seleccione un estado ---", ""));
        }
    }
}