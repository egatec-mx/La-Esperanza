using LaEsperanza.Api.Data;
using LaEsperanza.Api.Data.Models;
using LaEsperanza.Api.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace LaEsperanza.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class CustomersController : Controller
    {
        private readonly ILogger<CustomersController> _logger;
        private readonly LaEsperanzaContext _dbContext;

        public CustomersController(ILogger<CustomersController> logger, LaEsperanzaContext dbContext)
        {
            _logger = logger;
            _dbContext = dbContext;
        }

        [HttpGet]
        public async Task<IActionResult> GetCustomersAsync()
        {
            try
            {
                return Ok(await _dbContext.Customers
                    .Where(c => c.CustomerActive.Value)
                    .OrderBy(c => c.CustomerName)
                    .ThenBy(c => c.CustomerLastname)
                    .Select(c => new CustomersModel
                    {
                        CustomerId = c.CustomerId,
                        CustomerName = c.CustomerName.Trim(),
                        CustomerLastname = c.CustomerLastname.Trim(),
                        CustomerStreet = c.CustomerStreet.Trim(),
                        CustomerColony = c.CustomerColony.Trim(),
                        CustomerCity = c.CustomerCity.Trim(),
                        CustomerZipcode = c.CustomerZipcode,
                        CustomerActive = c.CustomerActive,
                        CustomerMail = c.CustomerMail,
                        CustomerPhone = c.CustomerPhone,
                        StateId = c.StateId,
                        Message = string.Empty,
                        StateName = c.State.StateName,
                        CountryName = c.State.Country.CountryName
                    })
                    .ToListAsync().ConfigureAwait(true));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
            }

            return BadRequest();
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetCustomerAsync(int Id)
        {
            CustomersModel customer = new CustomersModel();

            try
            {
                Customers dbcustomer = await _dbContext.Customers.FirstOrDefaultAsync(c => c.CustomerId == Id).ConfigureAwait(true);

                if (dbcustomer != null)
                {
                    customer.CustomerActive = dbcustomer.CustomerActive;
                    customer.CustomerCity = dbcustomer.CustomerCity;
                    customer.CustomerColony = dbcustomer.CustomerColony;
                    customer.CustomerId = dbcustomer.CustomerId;
                    customer.CustomerLastname = dbcustomer.CustomerLastname;
                    customer.CustomerMail = dbcustomer.CustomerMail;
                    customer.CustomerName = dbcustomer.CustomerName;
                    customer.CustomerPhone = dbcustomer.CustomerPhone;
                    customer.CustomerStreet = dbcustomer.CustomerStreet;
                    customer.CustomerZipcode = dbcustomer.CustomerZipcode;
                    customer.StateId = dbcustomer.StateId;
                    customer.StateName = dbcustomer.State.StateName;
                    customer.CountryName = dbcustomer.State.Country.CountryName;
                    customer.Message = string.Empty;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
                customer.Errors.Add(Properties.Resources.ERROR_CUSTOMER_GET);
            }

            return Ok(customer);
        }

        [HttpPost("update")]
        public async Task<IActionResult> UpdateCustomerAsync([FromBody] CustomersModel model)
        {
            if (model is null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            model.Errors = new List<string>();

            try
            {
                if (ModelState.IsValid)
                {
                    Customers c = new Customers
                    {
                        CustomerActive = model.CustomerActive,
                        CustomerCity = model.CustomerCity.Trim(),
                        CustomerColony = model.CustomerColony.Trim(),
                        CustomerId = model.CustomerId,
                        CustomerLastname = model.CustomerLastname.Trim(),
                        CustomerMail = model.CustomerMail.Trim(),
                        CustomerName = model.CustomerName.Trim(),
                        CustomerPhone = model.CustomerPhone.Trim(),
                        CustomerStreet = model.CustomerStreet.Trim(),
                        CustomerZipcode = model.CustomerZipcode.Trim(),
                        StateId = model.StateId
                    };

                    _dbContext.Entry(c).State = EntityState.Modified;
                    _ = await _dbContext.SaveChangesAsync().ConfigureAwait(true);

                    model.Message = Properties.Resources.SUCCESS_CUSTOMER_UPDATE;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
                model.Errors.Add(Properties.Resources.ERROR_CUSTOMER_UPDATE);
            }

            return Ok(model);
        }

        [HttpPost("add")]
        public async Task<IActionResult> AddCustomerAsync([FromBody] CustomersModel model)
        {
            if (model is null)
            {
                throw new ArgumentNullException(nameof(model));
            }


            model.Errors = new List<string>();

            try
            {
                if (ModelState.IsValid)
                {
                    Customers c = new Customers
                    {
                        CustomerActive = model.CustomerActive,
                        CustomerCity = model.CustomerCity.Trim(),
                        CustomerColony = model.CustomerColony.Trim(),
                        CustomerLastname = model.CustomerLastname.Trim(),
                        CustomerMail = model.CustomerMail.Trim(),
                        CustomerName = model.CustomerName.Trim(),
                        CustomerPhone = model.CustomerPhone.Trim(),
                        CustomerStreet = model.CustomerStreet.Trim(),
                        CustomerZipcode = model.CustomerZipcode.Trim(),
                        StateId = model.StateId
                    };

                    _dbContext.Customers.Add(c);
                    _ = await _dbContext.SaveChangesAsync().ConfigureAwait(true);

                    model.Message = Properties.Resources.SUCCESS_CUSTOMER_ADD;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
                model.Errors.Add(Properties.Resources.ERROR_CUSTOMER_ADD);
            }

            return Ok(model);
        }

        [HttpGet("states-list")]
        public async Task<IActionResult> GetStatesListAsync()
        {
            try
            {
                return Ok((await _dbContext.States
                    .Where(s => s.StateActive.Value)
                    .OrderBy(s => s.StateName)
                    .Select(s => new { s.StateId, s.StateName })
                    .ToListAsync().ConfigureAwait(true))
                    .Prepend(new { StateId = 0, StateName = Properties.Resources.SELECT_ITEM_EMPTY }));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
            }

            return BadRequest();
        }
    }
}