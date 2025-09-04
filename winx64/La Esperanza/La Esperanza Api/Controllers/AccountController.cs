using LaEsperanza.Api.Data;
using LaEsperanza.Api.Data.Models;
using LaEsperanza.Api.Helpers;
using LaEsperanza.Api.Models;
using LaEsperanza.Api.Settings;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;

namespace LaEsperanza.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class AccountController : Controller
    {
        private readonly JWTSettings _jwtSettings;
        private readonly ILogger<AccountController> _logger;
        private readonly LaEsperanzaContext _dbContext;

        public AccountController(ILogger<AccountController> logger, IOptions<JWTSettings> jwtSettings, LaEsperanzaContext dbContext)
        {
            _logger = logger;
            _jwtSettings = jwtSettings.Value;
            _dbContext = dbContext;
        }

        [AllowAnonymous]
        [HttpGet("/")]
        public IActionResult Welcome()
        {
            return Ok(Properties.Resources.API_WELCOME);
        }

        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> LoginAsync([FromBody] LogInModel model)
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
                    Users _dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserUsername.Equals(model.UserName)).ConfigureAwait(true);

                    if (_dbUser != null)
                    {
                        string hashedPassword = PasswordHelper.HashPassword(model.Password);

                        if (_dbUser.UserPassword.Equals(hashedPassword))
                        {
                            _dbUser.UserAttempts = 0;

                            model.Password = string.Empty;
                            model.Token = GenerateToken(_dbUser);
                        }
                        else
                        {
                            _dbUser.UserAttempts++;

                            model.Errors.Add(Properties.Resources.ERROR_ACCOUNT_PASSWORD_NOT_MATCH);

                            if (_dbUser.UserAttempts >= 5)
                            {
                                _dbUser.UserLocked = true;

                                model.Errors.Add(Properties.Resources.ERROR_ACCOUNT_USER_LOCKED);
                            }
                            else
                            {
                                model.Errors.Add(string.Format(Properties.Resources.ERROR_ACCOUNT_ATTEMPT_COUNTER, _dbUser.UserAttempts, 5));
                            }
                        }
                    }
                    else
                    {
                        model.Errors.Add(Properties.Resources.ERROR_ACCOUNT_USER_NOT_EXISTS);
                    }
                }
                else
                {
                    if (string.IsNullOrEmpty(model.UserName))
                    {
                        model.Errors.Add(Properties.Resources.ERROR_VALIDATION_LOGIN_USERNAME);
                    }

                    if (string.IsNullOrEmpty(model.Password))
                    {
                        model.Errors.Add(Properties.Resources.ERROR_VALIDATION_LOGIN_PASSWORD);
                    }
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);

                model.Errors.Add(ex.Message);
            }

            await _dbContext.SaveChangesAsync().ConfigureAwait(true);

            return Ok(model);
        }

        [HttpGet("profile")]
        public async Task<IActionResult> GetProfileAsync()
        {
            if (int.TryParse(User.FindFirst(ClaimTypes.Sid).Value, out int userId))
            {
                Users _dbUser = await _dbContext.Users.FirstOrDefaultAsync(u => u.UserId == userId).ConfigureAwait(true);
                if (_dbUser != null)
                {
                    return Ok(new
                    {
                        Name = $"{_dbUser.UserFirstname} {_dbUser.UserLastname}",
                        Role = _dbUser.Role.RoleName
                    });
                }
            }
            return BadRequest();
        }

        [HttpPost("register")]
        public async Task<IActionResult> RegisterDeviceAsync(Devices model)
        {
            if (model is null)
            {
                throw new ArgumentNullException(nameof(model));
            }

            if (ModelState.IsValid)
            {
                try
                {
                    if (model.DevicePushAuth.Contains("Apple"))
                    {
                        Devices dbDevice = await _dbContext.Devices.FirstOrDefaultAsync(d => d.DevicePushP256dh == model.DevicePushP256dh).ConfigureAwait(true);
                        
                        if (dbDevice != null)
                        {
                            dbDevice.DeviceNotificationCount = 0;
                            dbDevice.DeviceValid = true;

                            if (dbDevice.DeviceRegistrationDate is null)
                            {
                                dbDevice.DeviceRegistrationDate = DateTime.Now;
                            }
                            
                            _dbContext.Entry(dbDevice).State = EntityState.Modified;

                            _ = await _dbContext.SaveChangesAsync().ConfigureAwait(true);

                            return Ok();
                        }
                    }

                    model.UserId = int.Parse(User.FindFirst(ClaimTypes.Sid).Value);
                    model.DeviceValid = true;
                    model.DeviceNotificationCount = 0;
                    model.DeviceRegistrationDate = DateTime.Now;

                    _dbContext.Devices.Add(model);
                    _ = await _dbContext.SaveChangesAsync().ConfigureAwait(true);

                    return Ok();
                }
                catch (Exception ex)
                {
                    _logger.LogError(ex, Properties.Resources.ERROR_EXCEPTION_TITLE);
                }
            }

            return BadRequest();
        }

        internal string GenerateToken(Users user)
        {
            try
            {
                JwtSecurityTokenHandler tokenHandler = new JwtSecurityTokenHandler();
                List<Claim> claims = new List<Claim>
                {
                    new Claim(ClaimTypes.Sid, user.UserId.ToString()),
                    new Claim(ClaimTypes.Role, user.Role.RoleName)
                };
                SecurityTokenDescriptor tokenDescriptor = new SecurityTokenDescriptor
                {
                    Subject = new ClaimsIdentity(claims),
                    Audience = _jwtSettings.Audience,
                    Issuer = _jwtSettings.Issuer,
                    Expires = DateTime.UtcNow.AddMinutes(_jwtSettings.Expiration),
                    SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(Encoding.ASCII.GetBytes(_jwtSettings.Key)), SecurityAlgorithms.HmacSha512Signature)
                };
                SecurityToken token = tokenHandler.CreateToken(tokenDescriptor);
                return tokenHandler.WriteToken(token);
            }
            catch
            {
                throw;
            }
        }
    }
}