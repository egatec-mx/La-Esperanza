using La_Esperanza.Data;
using La_Esperanza.Helpers;
using La_Esperanza.Models;
using La_Esperanza.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Rendering;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Security.Claims;
using System.Threading.Tasks;

namespace La_Esperanza.Controllers
{
    [Authorize]
    public class AccountController : Controller
    {
        private readonly LaEsperanzaContext _dbContext;
        private readonly ILogger<AccountController> _logger;
        private readonly PushSettings _settings;

        public AccountController(ILogger<AccountController> logger, LaEsperanzaContext dbContext, IOptions<PushSettings> settings)
        {
            _logger = logger;
            _dbContext = dbContext;
            _settings = settings.Value;
        }

        public IActionResult AddUser()
        {
            try
            {
                ViewBag.Roles = RolesList();
                return PartialView(new Users { UserActive = true });
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
        public async Task<IActionResult> AddUserAsync(Users model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    model.UserAttempts = 0;
                    model.UserCreatedDate = DateTime.Now;
                    model.UserLocked = false;
                    model.UserPassword = PasswordHelper.HashPassword(model.UserPassword);

                    _dbContext.Users.Add(model);
                    _ = await _dbContext.SaveChangesAsync();

                    ViewBag.Message = "El usuario se ha creado correctamente.";
                    return PartialView("_Success");
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                    _logger.LogError(ex, "¡Uops!");
                }
            }

            ViewBag.Roles = RolesList();
            return PartialView(model);
        }

        public IActionResult CheckSession()
        {
            if (User.Identity.IsAuthenticated)
                return Ok();
            else
                return Unauthorized();
        }

        public async Task<IActionResult> DeleteUserAsync(int Id)
        {
            try
            {
                return PartialView(await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == Id));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return null;
        }

        [HttpDelete]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> DeleteUserAsync(Users model)
        {
            try
            {
                Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == model.UserId);
                if (dbUser != null)
                {
                    dbUser.UserActive = false;

                    _dbContext.Entry(dbUser).State = EntityState.Modified;
                    await _dbContext.SaveChangesAsync();

                    ViewBag.Message = "El usuario ha sido borrado correctamente.";
                    return PartialView("_Success");
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return PartialView(model);
        }

        public async Task<IActionResult> EditUserAsync(int Id)
        {
            try
            {
                ViewBag.Roles = RolesList();
                return PartialView(await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == Id));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return null;
        }

        [HttpPut]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> EditUserAsync(Users model)
        {
            try
            {
                Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == model.UserId);
                if (dbUser != null)
                {
                    dbUser.RoleId = model.RoleId;
                    dbUser.UserFirstname = model.UserFirstname;
                    dbUser.UserLastname = model.UserLastname;

                    if (!string.IsNullOrEmpty(model.UserPassword))
                    {
                        dbUser.UserPassword = PasswordHelper.HashPassword(model.UserPassword);
                    }

                    _dbContext.Entry(dbUser).State = EntityState.Modified;
                    await _dbContext.SaveChangesAsync();

                    ViewBag.Message = "El usuario se modificó correctamente";
                    return PartialView("_Success");
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            ViewBag.Roles = RolesList();
            return PartialView(model);
        }

        [AllowAnonymous]
        public IActionResult ForgotPassword()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        [AllowAnonymous]
        public async Task<IActionResult> ForgotPasswordAsync(PasswordChangeModel model)
        {
            if (!ModelState.IsValid)
            {
                if (!string.IsNullOrEmpty(model.Username))
                {
                    Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserUsername == model.Username);
                    if (dbUser != null)
                    {
                        ViewBag.ShowPassword = true;
                    }
                }
                else
                {
                    ModelState.AddModelError(string.Empty, "Se require del usuario para poder restablecer su contraseña");
                }
            }
            else
            {
                Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserUsername == model.Username);
                if (dbUser != null)
                {
                    dbUser.UserPassword = PasswordHelper.HashPassword(model.Password);

                    _dbContext.Entry(dbUser).State = EntityState.Modified;
                    await _dbContext.SaveChangesAsync();

                    return RedirectToAction("Login", "Account", new { Success = true });
                }
            }
            return View(model);
        }

        [AllowAnonymous]
        public IActionResult Login(string ReturnUrl, string Success = null)
        {
            if (Success != null)
                ViewBag.Message = "La contraseña fue cambiada correctamente";

            return View(new LoginModel { ReturnUrl = ReturnUrl });
        }

        [HttpPost]
        [AllowAnonymous]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> LoginAsync(LoginModel model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserUsername == model.Username && u.UserActive.Value);
                    if (dbUser != null)
                    {
                        if (dbUser.UserLocked)
                        {
                            ModelState.AddModelError(string.Empty, "Usuario bloqueado, consulte con su administrador para desbloquear su cuenta.");
                            _logger.LogInformation($"Usuario bloqueado - {model.Username}");
                        }
                        else
                        {
                            if (dbUser.UserPassword == PasswordHelper.HashPassword(model.Password))
                            {
                                dbUser.UserAttempts = 0;
                                dbUser.UserLocked = false;
                                dbUser.UserLockedDate = null;

                                _dbContext.Entry(dbUser).State = EntityState.Modified;
                                await _dbContext.SaveChangesAsync();

                                ClaimsIdentity identity = new ClaimsIdentity(new List<Claim> {
                                new Claim(ClaimTypes.Name,dbUser.UserUsername),
                                new Claim(ClaimTypes.Role, dbUser.Role.RoleName),
                                new Claim("FullName", $"{dbUser.UserFirstname} {dbUser.UserLastname}"),
                                new Claim("UserId",dbUser.UserId.ToString())
                            }, CookieAuthenticationDefaults.AuthenticationScheme);

                                AuthenticationProperties authenticationProperties = new AuthenticationProperties
                                {
                                    AllowRefresh = false,
                                    ExpiresUtc = DateTime.Now.AddMinutes(60),
                                    IsPersistent = false,
                                    IssuedUtc = DateTime.Now
                                };

                                await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(identity), authenticationProperties);

                                return RedirectToUrl(model.ReturnUrl);
                            }
                            else
                            {
                                dbUser.UserAttempts++;

                                if (dbUser.UserAttempts >= 3)
                                {
                                    dbUser.UserLocked = true;
                                    dbUser.UserLockedDate = DateTime.Now;

                                    _dbContext.Entry(dbUser).State = EntityState.Modified;
                                    await _dbContext.SaveChangesAsync();

                                    ModelState.AddModelError(string.Empty, "Usuario bloqueado por exceso de intentos fallidos. <br/>Consulte con su administrador para desbloquear su cuenta.");
                                    _logger.LogInformation($"Bloqueo de usuario - {model.Username}");
                                }
                                else
                                {
                                    ModelState.AddModelError(string.Empty, $"La contraseña es incorrecta, intento {dbUser.UserAttempts} de 3");
                                    _logger.LogInformation($"La contraseña es incorrecta, intento {dbUser.UserAttempts} de 3 para {model.Username}");
                                }
                            }
                        }
                    }
                    else
                    {
                        ModelState.AddModelError(string.Empty, "El usuario no existe.");
                        _logger.LogInformation($"El usuario {model.Username} no existe");
                    }
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                    _logger.LogError(ex, "¡Uops!");
                }
            }
            return View(model);
        }

        public async Task<IActionResult> LogOutAsync()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
            return RedirectToUrl();
        }

        [HttpPost]
        public async Task<IActionResult> RegisterDeviceAsync(Devices model)
        {
            if (ModelState.IsValid)
            {
                try
                {
                    if (model.DevicePushAuth.Contains("Apple"))
                    {
                        Devices dbDevice = await _dbContext.Devices.FirstOrDefaultAsync(d => d.DevicePushP256dh == model.DevicePushP256dh);
                        if (dbDevice != null)
                        {
                            dbDevice.DeviceNotificationCount = 0;
                            _dbContext.Entry(dbDevice).State = EntityState.Modified;

                            await _dbContext.SaveChangesAsync();

                            return Ok();
                        }
                    }

                    model.UserId = int.Parse(User.Claims.FirstOrDefault(c => c.Type == "UserId").Value);
                    model.DeviceValid = true;
                    model.DeviceNotificationCount = 0;

                    _dbContext.Devices.Add(model);
                    await _dbContext.SaveChangesAsync();

                    return Ok();
                }
                catch (Exception ex)
                {
                    ModelState.AddModelError(string.Empty, ex.Message);
                    _logger.LogError(ex, "Uops!");
                }
            }
            return BadRequest();
        }

        public IActionResult ServerKey()
        {
            return Ok(_settings.PublicKey);
        }

        public async Task<IActionResult> UnlockUserAsync(int Id)
        {
            try
            {
                return PartialView(await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == Id));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return null;
        }

        [HttpPut]
        [ValidateAntiForgeryToken]
        public async Task<IActionResult> UnlockUserAsync(Users model)
        {
            try
            {
                Users dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == model.UserId);
                if (dbUser != null)
                {
                    dbUser.UserLocked = false;
                    dbUser.UserLockedDate = null;
                    dbUser.UserAttempts = 0;

                    _dbContext.Entry(dbUser).State = EntityState.Modified;
                    await _dbContext.SaveChangesAsync();

                    ViewBag.Message = $"El usuario {model.UserUsername} ha sido desbloqueado correctamente";
                    return PartialView("_Success");
                }
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return PartialView(model);
        }

        public IActionResult UsersList()
        {
            try
            {
                return View(_dbContext.Users.Where(u => u.UserActive.Value));
            }
            catch (Exception ex)
            {
                ModelState.AddModelError(string.Empty, "¡Uops! Algo me salío mal, intente de nuevo.");
                _logger.LogError(ex, "¡Uops!");
            }
            return null;
        }

        private IActionResult RedirectToUrl(string Url = null)
        {
            return string.IsNullOrEmpty(Url) ? RedirectToAction("Index", "Home") : (IActionResult)Redirect(Url);
        }

        private IEnumerable<SelectListItem> RolesList()
        {
            return new SelectList(_dbContext.Roles, "RoleId", "RoleName").Prepend(new SelectListItem("----Seleccione un rol----", ""));
        }
    }
}