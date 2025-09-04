using La_Esperanza.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace La_Esperanza.Controllers
{
    [Authorize]
    public class ProductController : Controller
    {
        private readonly LaEsperanzaContext _dbContext;
        private readonly ILogger<ProductController> _logger;

        public ProductController(ILogger<ProductController> logger, LaEsperanzaContext dbContext)
        {
            _logger = logger;
            _dbContext = dbContext;
        }

        public IActionResult AddProduct()
        {
            try
            {
                return PartialView(new Products { ProductId = 0, ProductActive = true });
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
        public async Task<IActionResult> AddProductAsync(Products model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    _dbContext.Products.Add(model);
                    _ = await _dbContext.SaveChangesAsync();

                    ViewBag.Message = "El producto se ha agregado correctamente";
                    return PartialView("_Success");
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                    _logger.LogError(ex, "¡Uops!");
                }
            }
            return PartialView(model);
        }

        public async Task<IActionResult> DeleteProductAsync(int Id)
        {
            try
            {
                return PartialView(await _dbContext.Products.FirstOrDefaultAsync(p => p.ProductId == Id));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return PartialView();
        }

        [HttpDelete]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteProductAsync(Products model)
        {
            if (model.ProductId > 0)
            {
                Products dbProduct = await _dbContext.Products.FirstOrDefaultAsync(p => p.ProductId == model.ProductId);
                if (dbProduct != null)
                {
                    dbProduct.ProductActive = false;

                    _dbContext.Entry(dbProduct).State = EntityState.Modified;
                    await _dbContext.SaveChangesAsync();

                    ViewBag.Message = "El producto ha sido borrado correctamente";
                    return PartialView("_Success");
                }
            }
            return PartialView(model);
        }

        public async Task<IActionResult> EditProductAsync(int Id)
        {
            try
            {
                return PartialView(await _dbContext.Products.FirstOrDefaultAsync(p => p.ProductId == Id));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return PartialView();
        }

        [HttpPut]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditProductAsync(Products model)
        {
            if (ModelState.IsValid)
            {
                Products dbProduct = await _dbContext.Products.FirstOrDefaultAsync(p => p.ProductId == model.ProductId);
                if (dbProduct != null)
                {
                    dbProduct.ProductName = model.ProductName;
                    dbProduct.ProductPrice = model.ProductPrice;

                    _dbContext.Entry(dbProduct).State = EntityState.Modified;
                    await _dbContext.SaveChangesAsync();

                    ViewBag.Message = "El producto ha sido modificado correctamente";
                    return PartialView("_Success");
                }
            }
            return PartialView(model);
        }

        public IActionResult ProductsList()
        {
            try
            {
                return View(_dbContext.Products.Where(p => p.ProductActive.Value).OrderBy(p => p.ProductName));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return View();
        }

        public async Task<IActionResult> ProductsAsync()
        {
            return Ok(await _dbContext.Products
                .Where(p => p.ProductActive.Value)
                .OrderBy(p => p.ProductName)
                .Select(p => new KeyValuePair<int, string>(p.ProductId, p.ProductName))
                .ToListAsync());
        }

        public async Task<IActionResult> PriceAsync(int Id)
        {
            return Ok((await _dbContext.Products.FirstOrDefaultAsync(p => p.ProductId == Id)).ProductPrice);
        }
    }
}