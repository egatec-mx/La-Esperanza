using LaEsperanza.Api.Data;
using LaEsperanza.Api.Data.Models;
using LaEsperanza.Api.Models;
using LaEsperanza.Api.Services;
using LaEsperanza.Helpers;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;

namespace LaEsperanza.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class OrdersController : Controller
    {
        private readonly ILogger<OrdersController> _logger;
        private readonly LaEsperanzaContext _dbContext;
        private readonly IPushService _pushService;

        public OrdersController(ILogger<OrdersController> logger, LaEsperanzaContext dbContext, IPushService pushService, IConfiguration configuration)
        {
            _logger = logger;
            _dbContext = dbContext;
            _pushService = pushService;
        }

        [HttpGet]
        public async Task<IActionResult> GetOrdersAsync()
        {
            try
            {
                List<OrdersListModel> newOrders = await _dbContext.Orders.
                    Where(o => new int[] { 1, 2, 3 }.Contains(o.StatusId) ||
                    (new int[] { 4, 5, 6 }.Contains(o.StatusId) && o.OrderScheduleDate.Value.Date >= DateTime.Now.Date))
                    .Select(o => new OrdersListModel
                    {
                        OrderId = o.OrderId,
                        OrderDate = o.OrderDate.ToShortDateString(),
                        Customer = $"{o.Customer.CustomerName.Trim()} {o.Customer.CustomerLastname.Trim()}",
                        OrderTotal = o.OrderTotal,
                        StatusId = o.StatusId
                    }).ToListAsync().ConfigureAwait(true);

                return Ok(newOrders);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
            }

            return BadRequest();
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetOrderAsync(int Id)
        {
            OrdersModel order = new OrdersModel();

            try
            {
                Orders o = await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == Id).ConfigureAwait(true);

                if (o != null)
                {
                    order = new OrdersModel
                    {
                        Articles = o.OrderDetails.Select(d => new OrderDetailsModel
                        {
                            OrderDetailId = d.OrderDetailId,
                            OrderDetailQuantity = d.OrderDetailQuantity,
                            OrderDetailTotal = d.OrderDetailTotal,
                            OrderDetailPrice = d.OrderDetailPrice,
                            ProductId = d.ProductId,
                            ProductName = d.Product.ProductName
                        }).ToList(),
                        CountryName = o.Customer.State.Country.CountryName,
                        CustomerId = o.CustomerId,
                        CustomerCity = o.Customer.CustomerCity,
                        CustomerColony = o.Customer.CustomerColony,
                        CustomerLastname = o.Customer.CustomerLastname,
                        CustomerName = o.Customer.CustomerName,
                        CustomerPhone = o.Customer.CustomerPhone,
                        CustomerStreet = o.Customer.CustomerStreet,
                        CustomerZipcode = o.Customer.CustomerZipcode,
                        OrderCanceledDate = o.OrderCanceledDate,
                        OrderCanceledReason = o.OrderCanceledReason,
                        OrderDate = o.OrderDate,
                        OrderDeliveredDate = o.OrderDeliveredDate,
                        OrderDeliveryTax = o.OrderDeliveryTax,
                        OrderId = o.OrderId,
                        OrderNotes = o.OrderNotes,
                        OrderProcessedDate = o.OrderProcessedDate,
                        OrderQrCode = o.OrderQrCode,
                        OrderRejectedDate = o.OrderRejectedDate,
                        OrderRejectedReason = o.OrderRejectedReason,
                        OrderScheduleDate = o.OrderScheduleDate,
                        OrderStartedDate = o.OrderStartedDate,
                        OrderSubtotal = o.OrderSubtotal,
                        OrderTax = o.OrderTax,
                        OrderTotal = o.OrderTotal,
                        PaymentMethod = o.MopId.HasValue ? o.Mop.MopDescription : "N/A",
                        PaymentMethodId = o.MopId,
                        StateName = o.Customer.State.StateName,
                        StatusId = o.StatusId,
                        StatusName = o.Status.StatusName,
                        UserFirstname = o.User.UserFirstname,
                        UserLastname = o.User.UserLastname
                    };
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
                order.Errors.Add(Properties.Resources.ERROR_ORDER_GET);
            }

            return Ok(order);
        }

        [HttpPost("search")]
        public async Task<IActionResult> SearchAsync([FromBody] SearchModel model)
        {
            if (model is null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            model.Errors = new List<string>();

            try
            {
                if (long.TryParse(model.SearchTerm, out long orderId))
                {
                    var results = (await _dbContext.Orders
                                    .Where(o => o.OrderId == orderId)
                                    .ToListAsync().ConfigureAwait(true))
                                    .Select(o =>
                                    {
                                        return new OrdersListModel
                                        {
                                            OrderId = o.OrderId,
                                            OrderDate = o.OrderDate.ToShortDateString(),
                                            Customer = $"{o.Customer.CustomerName.Trim()} {o.Customer.CustomerLastname.Trim()}",
                                            OrderTotal = o.OrderTotal,
                                            StatusId = o.StatusId
                                        };
                                    }).ToList();
                    return Ok(results);
                }
                else
                {
                    var results = (await _dbContext.Orders
                                    .Where(o =>
                                        o.Customer.CustomerName.Contains(model.SearchTerm) ||
                                        o.Customer.CustomerLastname.Contains(model.SearchTerm))
                                    .ToListAsync().ConfigureAwait(true))
                                    .Select(o =>
                                    {
                                        return new OrdersListModel
                                        {
                                            OrderId = o.OrderId,
                                            OrderDate = o.OrderDate.ToShortDateString(),
                                            Customer = $"{o.Customer.CustomerName.Trim()} {o.Customer.CustomerLastname.Trim()}",
                                            OrderTotal = o.OrderTotal,
                                            StatusId = o.StatusId
                                        };
                                    }).ToList();
                    return Ok(results);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
                model.Errors.Add(Properties.Resources.ERROR_ORDER_SEARCH);
            }

            return Ok(model);
        }

        [HttpPost("advance")]
        public async Task<IActionResult> MoveOrderAsync([FromBody] OrdersModel model)
        {
            if (model is null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            model.Errors = new List<string>();

            try
            {
                int userId = int.Parse(User.FindFirst(ClaimTypes.Sid).Value);
                Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == userId).ConfigureAwait(true);

                if (ModelState.IsValid)
                {
                    Orders order = await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == model.OrderId).ConfigureAwait(true);

                    if (order != null)
                    {
                        switch (order.StatusId)
                        {
                            case 1:
                                order.StatusId = 2;
                                order.OrderStartedDate = DateTime.Now;
                                await _pushService.SendToAllDevicesAsync(Properties.Resources.PUSH_ORDER_TITLE_MOVED,
                                string.Format(Properties.Resources.PUSH_ORDER_MESSAGE_MOVED,
                                string.Format("{0} {1}", dbUser.UserFirstname, dbUser.UserLastname),
                                order.OrderId.ToString().PadLeft(6, '0'), Properties.Resources.STATUS_NAME_PROCESSING)).ConfigureAwait(true);
                                break;

                            case 2:
                                order.StatusId = 3;
                                order.OrderProcessedDate = DateTime.Now;
                                await _pushService.SendToAllDevicesAsync(Properties.Resources.PUSH_ORDER_TITLE_MOVED,
                                string.Format(Properties.Resources.PUSH_ORDER_MESSAGE_MOVED,
                                string.Format("{0} {1}", dbUser.UserFirstname, dbUser.UserLastname),
                                order.OrderId.ToString().PadLeft(6, '0'), Properties.Resources.STATUS_NAME_DELIVER)).ConfigureAwait(true);
                                break;

                            case 3:
                                order.StatusId = 4;
                                order.OrderDeliveredDate = DateTime.Now;
                                await _pushService.SendToAllDevicesAsync(Properties.Resources.PUSH_ORDER_TITLE_DELIVER,
                                string.Format(Properties.Resources.PUSH_ORDER_MESSAGE_DELIVER,
                                string.Format("{0} {1}", dbUser.UserFirstname, dbUser.UserLastname),
                                order.OrderId.ToString().PadLeft(6, '0'), order.OrderTotal.ToString("C2"))).ConfigureAwait(true);
                                break;
                        }

                        _ = await _dbContext.SaveChangesAsync().ConfigureAwait(true);

                        model.Message = string.Format(Properties.Resources.SUCCESS_ORDER_MOVED, order.OrderId.ToString().PadLeft(6, '0'));
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
                model.Errors.Add(Properties.Resources.ERROR_ORDER_MOVED);
            }

            return Ok(model);
        }

        [HttpPost("cancel")]
        public async Task<IActionResult> CancelOrderAsync([FromBody] CancelOrderModel model)
        {
            if (model is null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            model.Errors = new List<string>();

            try
            {
                int userId = int.Parse(User.FindFirst(ClaimTypes.Sid).Value);
                Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == userId).ConfigureAwait(true);

                if (ModelState.IsValid)
                {
                    Orders order = await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == model.OrderId).ConfigureAwait(true);

                    if (order != null)
                    {
                        order.StatusId = 5;
                        order.OrderCanceledDate = DateTime.Now;
                        order.OrderCanceledReason = model.CancelReason;

                        _ = await _dbContext.SaveChangesAsync().ConfigureAwait(true);

                        await _pushService.SendToAllDevicesAsync(Properties.Resources.PUSH_ORDER_TITLE_CANCEL,
                        string.Format(Properties.Resources.PUSH_ORDER_MESSAGE_CANCEL,
                        string.Format("{0} {1}", dbUser.UserFirstname, dbUser.UserLastname),
                        order.OrderId.ToString().PadLeft(6, '0'), order.OrderCanceledReason)).ConfigureAwait(true);

                        model.Message = string.Format(Properties.Resources.SUCCESS_ORDER_CANCEL, order.OrderId.ToString().PadLeft(6, '0'));
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
                model.Errors.Add(Properties.Resources.ERROR_ORDER_CANCEL);
            }

            return Ok(model);
        }

        [HttpPost("reject")]
        public async Task<IActionResult> RejectOrderAsync([FromBody] RejectOrderModel model)
        {
            if (model is null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            model.Errors = new List<string>();

            try
            {
                int userId = int.Parse(User.FindFirst(ClaimTypes.Sid).Value);
                Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == userId).ConfigureAwait(true);

                if (ModelState.IsValid)
                {
                    Orders order = await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == model.OrderId).ConfigureAwait(true);

                    if (order != null)
                    {
                        order.StatusId = 6;
                        order.OrderRejectedDate = DateTime.Now;
                        order.OrderRejectedReason = model.RejectReason;

                        _ = await _dbContext.SaveChangesAsync().ConfigureAwait(true);

                        await _pushService.SendToAllDevicesAsync(Properties.Resources.PUSH_ORDER_TITLE_REJECT,
                        string.Format(Properties.Resources.PUSH_ORDER_MESSAGE_REJECT,
                        string.Format("{0} {1}", dbUser.UserFirstname, dbUser.UserLastname),
                        order.OrderId.ToString().PadLeft(6, '0'), order.OrderRejectedReason)).ConfigureAwait(true);

                        model.Message = string.Format(Properties.Resources.SUCCESS_ORDER_REJECT, order.OrderId.ToString().PadLeft(6, '0'));
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
                model.Errors.Add(Properties.Resources.ERROR_ORDER_REJECT);
            }

            return Ok(model);
        }

        [HttpGet("mop-list")]
        public async Task<IActionResult> GetMethodsOfPaymentListAsync()
        {
            try
            {
                return Ok((await _dbContext.MethodOfPayment
                    .Where(s => s.MopActive.Value)
                    .OrderBy(s => s.MopDescription)
                    .Select(s => new { s.MopId, s.MopDescription })
                    .ToListAsync().ConfigureAwait(true))
                    .Prepend(new { MopId = 0, MopDescription = Properties.Resources.SELECT_ITEM_EMPTY }));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
            }

            return BadRequest();
        }

        [HttpGet("products")]
        public async Task<IActionResult> GetProductsListAsync()
        {
            try
            {
                return Ok((await _dbContext.Products
                    .Where(p => p.ProductActive.Value)
                    .OrderBy(p => p.ProductName).
                    Select(p => new ProductsModel
                    {
                        ProductId = p.ProductId,
                        ProductName = p.ProductName,
                        ProductPrice = p.ProductPrice,
                        ProductActive = p.ProductActive,
                        Message = string.Empty
                    }).ToListAsync().ConfigureAwait(true))
                    .Prepend(new ProductsModel
                    {
                        ProductActive = true,
                        Message = string.Empty,
                        ProductId = 0,
                        ProductName = Properties.Resources.SELECT_ITEM_EMPTY,
                        ProductPrice = 0
                    }));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
            }

            return BadRequest();
        }

        [HttpPost("update")]
        public async Task<IActionResult> UpdateOrderAsync([FromBody] OrdersModel model)
        {
            try
            {
                if (model is null)
                {
                    throw new ArgumentNullException(nameof(model));
                }

                model.Errors = new List<string>();

                if (ModelState.IsValid)
                {
                    int userId = int.Parse(User.FindFirst(ClaimTypes.Sid).Value);
                    Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == userId).ConfigureAwait(true);

                    Orders order = await _dbContext.Orders.FirstOrDefaultAsync(o => o.OrderId == model.OrderId).ConfigureAwait(true);

                    order.CustomerId = model.CustomerId;
                    order.OrderNotes = model.OrderNotes;
                    order.OrderScheduleDate = model.OrderScheduleDate;
                    order.OrderSubtotal = model.OrderSubtotal;
                    order.OrderTax = model.OrderTax;
                    order.OrderTotal = model.OrderTotal;
                    order.StatusId = model.StatusId;
                    order.OrderDeliveryTax = model.OrderDeliveryTax;
                    order.MopId = model.PaymentMethodId;

                    foreach (OrderDetailsModel article in model.Articles.Where(a => a.ProductId > 0))
                    {
                        if (article.OrderDetailId > 0)
                        {
                            OrderDetails detail = order.OrderDetails.FirstOrDefault(d => d.OrderDetailId == article.OrderDetailId);

                            if (detail != null)
                            {
                                detail.OrderDetailQuantity = article.OrderDetailQuantity;
                                detail.ProductId = article.ProductId;
                                detail.OrderDetailPrice = article.OrderDetailPrice;
                                detail.OrderDetailTotal = article.OrderDetailTotal;

                                _dbContext.Entry(detail).State = EntityState.Modified;
                            }
                        }
                        else
                        {
                            OrderDetails detail = new OrderDetails
                            {
                                OrderId = order.OrderId,
                                OrderDetailQuantity = article.OrderDetailQuantity,
                                ProductId = article.ProductId,
                                OrderDetailPrice = article.OrderDetailPrice,
                                OrderDetailTotal = article.OrderDetailTotal
                            };

                            _ = _dbContext.OrderDetails.Add(detail);
                        }
                    }

                    foreach (OrderDetails detail in _dbContext.OrderDetails.Where(o => o.OrderId == order.OrderId))
                    {
                        if (!model.Articles.Select(a => a.OrderDetailId).Contains(detail.OrderDetailId))
                        {
                            _dbContext.Entry(detail).State = EntityState.Deleted;
                        }
                    }

                    order.OrderQrCode = await CodeGeneratorHelper.GetCodeAsync(model.OrderId.ToString().PadLeft(6, '0')).ConfigureAwait(true);

                    _dbContext.Entry(order).State = EntityState.Modified;
                    _ = await _dbContext.SaveChangesAsync().ConfigureAwait(true);

                    await _pushService.SendToAllDevicesAsync(Properties.Resources.PUSH_ORDER_TITLE_UPDATE,
                    string.Format(Properties.Resources.PUSH_ORDER_MESSAGE_UPDATE,
                    string.Format("{0} {1}", dbUser.UserFirstname, dbUser.UserLastname),
                    order.OrderId.ToString().PadLeft(6, '0'))).ConfigureAwait(true);

                    model.Message = string.Format(Properties.Resources.SUCCESS_ORDER_UPDATE, order.OrderId.ToString().PadLeft(6, '0'));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
                model.Errors.Add(Properties.Resources.ERROR_ORDER_UPDATE);
            }

            return Ok(model);
        }

        [HttpPost("add")]
        public async Task<IActionResult> AddOrderAsync([FromBody] OrdersModel model)
        {
            try
            {
                if (model is null)
                {
                    throw new ArgumentNullException(nameof(model));
                }

                model.Errors = new List<string>();

                int userId = int.Parse(User.FindFirst(ClaimTypes.Sid).Value);
                Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == userId).ConfigureAwait(true);

                if (ModelState.IsValid)
                {
                    Orders order = new Orders
                    {
                        CustomerId = model.CustomerId,
                        MopId = model.PaymentMethodId,
                        OrderDate = DateTime.Now,
                        OrderDeliveryTax = model.OrderDeliveryTax,
                        OrderNotes = model.OrderNotes,
                        OrderScheduleDate = model.OrderScheduleDate,
                        OrderSubtotal = model.OrderSubtotal,
                        OrderTax = model.OrderTax,
                        OrderTotal = model.OrderTotal,
                        StatusId = 1,
                        UserId = userId,
                        OrderDetails = model.Articles.Where(a => a.ProductId > 0).Select(a => new OrderDetails
                        {
                            OrderDetailPrice = a.OrderDetailPrice,
                            OrderDetailQuantity = a.OrderDetailQuantity,
                            OrderDetailTotal = a.OrderDetailTotal,
                            ProductId = a.ProductId
                        }).ToList()
                    };

                    _dbContext.Orders.Add(order);
                    _ = await _dbContext.SaveChangesAsync().ConfigureAwait(true);

                    order.OrderQrCode = await CodeGeneratorHelper.GetCodeAsync(order.OrderId.ToString().PadLeft(6, '0')).ConfigureAwait(true);
                    _ = await _dbContext.SaveChangesAsync().ConfigureAwait(true);

                    await _pushService.SendToAllDevicesAsync(Properties.Resources.PUSH_ORDER_TITLE_NEW,
                    string.Format(Properties.Resources.PUSH_ORDER_MESSAGE_NEW,
                    string.Format("{0} {1}", dbUser.UserFirstname, dbUser.UserLastname),
                    order.OrderId.ToString().PadLeft(6, '0'))).ConfigureAwait(true);

                    model.Message = string.Format(Properties.Resources.SUCCESS_ORDER_ADD, order.OrderId.ToString().PadLeft(6, '0'));
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
                model.Errors.Add(Properties.Resources.ERROR_ORDER_ADD);
            }

            return Ok(model);
        }

        [HttpGet("todaysales")]
        public async Task<IActionResult> GetTodaySales()
        {
            try
            {
                List<Orders> orders = await _dbContext.Orders
                    .Where(o => o.StatusId == 4 && o.OrderDeliveredDate.Value.Date == DateTime.Today.Date)
                    .ToListAsync()
                    .ConfigureAwait(true);
                return Ok(new
                {
                    orders.Count,
                    DeliveryTaxTotal = orders.Sum(o => o.OrderDeliveryTax),
                    Total = orders.Sum(o => o.OrderTotal)
                });
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
            }
            return Ok();
        }
    }
}