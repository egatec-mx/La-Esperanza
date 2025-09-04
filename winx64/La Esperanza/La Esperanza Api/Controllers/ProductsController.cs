using La_Esperanza_Api.Data;
using La_Esperanza_Api.Data.Models;
using La_Esperanza_Api.Models.Products;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace La_Esperanza_Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class ProductsController : Controller
    {
        private readonly ILogger<ProductsController> _logger;
        private readonly LaEsperanzaContext _dbContext;

        public ProductsController(ILogger<ProductsController> logger, LaEsperanzaContext dbContext)
        {
            _logger = logger;
            _dbContext = dbContext;
        }

        [HttpGet]
        public async Task<IActionResult> GetProductsAsync()
        {
            try
            {
                return Ok(await _dbContext.Products
                    .Where(p => p.ProductActive.Value)
                    .OrderBy(p => p.ProductName)
                    .Select(p => new ProductsModel
                    {
                        ProductId = p.ProductId,
                        ProductName = p.ProductName,
                        ProductPrice = p.ProductPrice,
                        ProductActive = p.ProductActive,
                        Message = string.Empty
                    }).ToListAsync().ConfigureAwait(true));
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
            }

            return BadRequest();
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetProductAsync(int Id)
        {
            ProductsModel product = new ProductsModel();

            try
            {
                Products p = await _dbContext.Products.FirstOrDefaultAsync(p => p.ProductId == Id).ConfigureAwait(true);

                if (p != null)
                {
                    product.ProductActive = p.ProductActive;
                    product.ProductId = p.ProductId;
                    product.ProductName = p.ProductName;
                    product.ProductPrice = p.ProductPrice;
                    product.Message = string.Empty;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
                product.Errors.Add(Properties.Resources.ERROR_PRODUCT_GET);
            }

            return Ok(product);
        }

        [HttpPost("update")]
        public async Task<IActionResult> UpdateProductAsync([FromBody] ProductsModel model)
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
                    Products p = new Products
                    {
                        ProductId = model.ProductId,
                        ProductName = model.ProductName,
                        ProductPrice = model.ProductPrice,
                        ProductActive = model.ProductActive
                    };

                    _dbContext.Entry(p).State = EntityState.Modified;
                    _ = await _dbContext.SaveChangesAsync().ConfigureAwait(true);

                    model.Message = Properties.Resources.SUCCESS_PRODUCT_UPDATE;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
                model.Errors.Add(Properties.Resources.ERROR_PRODUCT_UPDATE);
            }

            return Ok(model);
        }

        [HttpPost("add")]
        public async Task<IActionResult> AddProductAsync([FromBody] ProductsModel model)
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
                    Products p = new Products
                    {
                        ProductName = model.ProductName,
                        ProductPrice = model.ProductPrice,
                        ProductActive = model.ProductActive
                    };

                    _dbContext.Products.Add(p);
                    _ = await _dbContext.SaveChangesAsync().ConfigureAwait(true);

                    model.Message = Properties.Resources.SUCCESS_PRODUCT_ADD;
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
                model.Errors.Add(Properties.Resources.ERROR_PRODUCT_ADD);
            }

            return Ok(model);
        }
    }
}