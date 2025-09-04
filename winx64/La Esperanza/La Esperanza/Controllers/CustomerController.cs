using La_Esperanza.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace La_Esperanza.Controllers
{
    [Authorize]
    public class CustomerController : Controller
    {
        private readonly LaEsperanzaContext _dbContext;
        private readonly ILogger<CustomerController> _logger;

        public CustomerController(ILogger<CustomerController> logger, LaEsperanzaContext dbContext)
        {
            _logger = logger;
            _dbContext = dbContext;
        }

        public IActionResult AddCustomer()
        {
            try
            {
                ViewBag.States = StatesList();
                return PartialView(new Customers { CustomerId = 0, CustomerActive = true });
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> AddCustomerAsync(Customers model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    _dbContext.Customers.Add(model);
                    await _dbContext.SaveChangesAsync();

                    ViewBag.Message = "El cliente ha sido agregado correctamente.";
                    return PartialView("_Success");
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                    _logger.LogError(ex, "¡Uops!");
                }
            }
            ViewBag.States = StatesList();
            return PartialView(model);
        }

        public IActionResult CustomersList()
        {
            try
            {
                return View(_dbContext.Customers.Where(c => c.CustomerActive.Value));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return View();
        }

        public async Task<IActionResult> DeleteCustomerAsync(int Id)
        {
            try
            {
                return PartialView(await _dbContext.Customers.FirstOrDefaultAsync(c => c.CustomerId == Id));
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
        public async Task<IActionResult> DeleteCustomerAsync(Customers model)
        {
            try
            {
                if (model.CustomerId > 0)
                {
                    Customers dbCustomer = await _dbContext.Customers.FirstOrDefaultAsync(c => c.CustomerId == model.CustomerId);
                    if (dbCustomer != null)
                    {
                        dbCustomer.CustomerActive = false;

                        _dbContext.Entry(dbCustomer).State = EntityState.Modified;
                        await _dbContext.SaveChangesAsync();

                        ViewBag.Message = "El cliente ha sido borrado correctamente";
                        return PartialView("_Success");
                    }
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        public async Task<IActionResult> DetailsCustomerAsync(int Id)
        {
            try
            {
                ViewBag.States = StatesList();
                return PartialView(await _dbContext.Customers.FirstOrDefaultAsync(c => c.CustomerId == Id));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        public async Task<IActionResult> EditCustomerAsync(int Id)
        {
            try
            {
                ViewBag.States = StatesList();
                return PartialView(await _dbContext.Customers.FirstOrDefaultAsync(c => c.CustomerId == Id));
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
        public async Task<IActionResult> EditCustomerAsync(Customers model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    Customers dbCustomer = await _dbContext.Customers.FirstOrDefaultAsync(c => c.CustomerId == model.CustomerId);
                    if (dbCustomer != null)
                    {
                        dbCustomer.CustomerActive = model.CustomerActive;
                        dbCustomer.CustomerCity = model.CustomerCity;
                        dbCustomer.CustomerColony = model.CustomerColony;
                        dbCustomer.CustomerLastname = model.CustomerLastname;
                        dbCustomer.CustomerMail = model.CustomerMail;
                        dbCustomer.CustomerName = model.CustomerName;
                        dbCustomer.CustomerPhone = model.CustomerPhone;
                        dbCustomer.CustomerStreet = model.CustomerStreet;
                        dbCustomer.CustomerZipcode = model.CustomerZipcode;
                        dbCustomer.StateId = model.StateId;

                        _dbContext.Entry(dbCustomer).State = EntityState.Modified;
                        await _dbContext.SaveChangesAsync();

                        ViewBag.Message = "El cliente se modificó correctamente";
                        return PartialView("_Success");
                    }
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                    _logger.LogError(ex, "¡Uops!");
                }
            }
            ViewBag.States = StatesList();
            return PartialView(model);
        }

        [HttpPost]
        public IActionResult SearchCustomer([FromForm] string search, int count)
        {
            try
            {
                return Ok(_dbContext
                    .Customers
                    .ToList()
                    .Where(c => (c.CustomerName.Contains(search, StringComparison.InvariantCultureIgnoreCase) ||
                                 c.CustomerLastname.Contains(search, StringComparison.InvariantCultureIgnoreCase)) &&
                                 c.CustomerActive.Value)
                    .OrderBy(c => c.CustomerName)
                    .Take(count)
                    .Select(c => new KeyValuePair<int, string>(c.CustomerId, $"{c.CustomerName} {c.CustomerLastname}"))
                    .Append(new KeyValuePair<int, string>(0, "--- Agregar nuevo cliente ---")));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "¡Uops!");
            }
            return BadRequest();
        }

        private IEnumerable<SelectListItem> StatesList()
        {
            return new SelectList(_dbContext.States, "StateId", "StateName").Prepend(new SelectListItem("--- Seleccione Estado ---", ""));
        }
    }
}