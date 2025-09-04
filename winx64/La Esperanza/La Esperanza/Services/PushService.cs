using La_Esperanza.Data;
using La_Esperanza.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.IO;
using System.Linq;
using System.Linq.Dynamic.Core;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Security.Authentication;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;
using WebPush;

namespace La_Esperanza.Services
{
    public class PushService : IPushService
    {
        private readonly LaEsperanzaContext _dbContext;
        private readonly PushSettings _settings;
        private readonly ApplePushSettings _appleSettings;
        private readonly ILogger<PushService> _logger;

        public PushService(LaEsperanzaContext dbContext, IOptions<PushSettings> settings, IOptions<ApplePushSettings> appleSettings, ILogger<PushService> logger)
        {
            _dbContext = dbContext;
            _settings = settings.Value;
            _appleSettings = appleSettings.Value;
            _logger = logger;
        }

        public async Task SendToAllDevicesAsync(string title, string message)
        {
            try
            {
                await SendToAppleAsync(title, message);
                await SendToAndroidAsync(title, message);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Uops! - Push Service - Send To All Devices");
            }
        }

        public async Task SendToAndroidAsync(string title, string message)
        {
            try
            {
                foreach (Devices device in _dbContext.Devices.Where(d => d.DeviceValid.Value && d.DevicePushAuth != "Apple"))
                {
                    PushSubscription Subscription = new PushSubscription(device.DevicePushEndpoint, device.DevicePushP256dh, device.DevicePushAuth);
                    VapidDetails Details = new VapidDetails("mailto:soporte@egatec.com.mx", _settings.PublicKey, _settings.PrivateKey);
                    WebPushClient PushClient = new WebPushClient();

                    string PushMessage = JsonConvert.SerializeObject(new PushMessage { Title = title, Message = message });

                    try
                    {
                        PushClient.SendNotification(Subscription, PushMessage, Details);
                    }
                    catch (Exception ex)
                    {
                        _logger.LogError(ex, "Uops! - Push to Android failed!");

                        device.DeviceValid = false;
                        _dbContext.Entry(device).State = EntityState.Modified;
                    }
                }

                await _dbContext.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Uops! - Send To Android");
            }
        }

        public async Task SendToAppleAsync(string pushTitle, string pushMessage)
        {
            try
            {
                string data = await File.ReadAllTextAsync(_appleSettings.P8);

                List<string> list = data.Split('\n').ToList();

                string prk = list.Where((s, i) => i != 0 && i != list.Count - 1).Aggregate((agg, s) => agg + s);

                byte[] bytes = Convert.FromBase64String(prk);

                CngKey cngKey = CngKey.Import(bytes, CngKeyBlobFormat.Pkcs8PrivateBlob);

                foreach (Devices d in _dbContext.Devices.Where(d => d.DeviceValid.Value && d.DevicePushAuth.Equals("Apple")))
                {
                    ECDsaCng key = new ECDsaCng(cngKey);

                    string token = CreateToken(key, _appleSettings.Key, _appleSettings.Team);
                    string url = $"{_appleSettings.Server}/3/device/{d.DevicePushP256dh}";

                    HttpRequestMessage request = new HttpRequestMessage(HttpMethod.Post, url);
                    request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
                    request.Headers.TryAddWithoutValidation("apns-push-type", "alert");
                    request.Headers.TryAddWithoutValidation("apns-id", Guid.NewGuid().ToString("D"));
                    request.Headers.TryAddWithoutValidation("apns-expiration", Convert.ToString(0));
                    request.Headers.TryAddWithoutValidation("apns-priority", Convert.ToString(10));
                    request.Headers.TryAddWithoutValidation("apns-topic", _appleSettings.Bundle);
                    request.Version = HttpVersion.Version20;

                    string body = JsonConvert.SerializeObject(new
                    {
                        aps = new
                        {
                            alert = new
                            {
                                title = pushTitle,
                                body = pushMessage,
                                time = DateTime.Now.ToString()
                            },
                            badge = ++d.DeviceNotificationCount,
                            sound = "default"
                        },
                        acme2 = new string[] { "bang", "whiz" }
                    });

                    using (StringContent stringContent = new StringContent(body, Encoding.UTF8, "application/json"))
                    {
                        request.Content = stringContent;
                        HttpClientHandler handler = new HttpClientHandler
                        {
                            SslProtocols = SslProtocols.Tls12 | SslProtocols.Tls11 | SslProtocols.Tls,
                            ServerCertificateCustomValidationCallback = (message, cert, chain, errors) => true
                        };
                        using (HttpClient client = new HttpClient(handler))
                        {
                            HttpResponseMessage resp = await client.SendAsync(request).ContinueWith(responseTask => { return responseTask.Result; });

                            if (resp != null)
                            {
                                string apnsResponseString = await resp.Content.ReadAsStringAsync();
                                if (!string.IsNullOrEmpty(apnsResponseString.Trim()))
                                {
                                    _logger.LogError($"Appple Push APN Response: {apnsResponseString} - Device Id: {d.DevicePushP256dh}");
                                    var jsonResponse = JsonConvert.DeserializeAnonymousType(apnsResponseString, new { Reason = "" });
                                    if (!string.IsNullOrEmpty(jsonResponse.Reason) && jsonResponse.Reason == "BadDeviceToken")
                                    {
                                        d.DeviceValid = false;
                                    }
                                }
                            }
                        }
                    }
                }

                await _dbContext.SaveChangesAsync();
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Uops! - Push to Apple failed");
            }
        }

        public static string CreateToken(ECDsa key, string keyID, string teamID)
        {
            ECDsaSecurityKey securityKey = new ECDsaSecurityKey(key) { KeyId = keyID };
            SigningCredentials credentials = new SigningCredentials(securityKey, "ES256");
            SecurityTokenDescriptor descriptor = new SecurityTokenDescriptor
            {
                IssuedAt = DateTime.Now,
                Issuer = teamID,
                SigningCredentials = credentials
            };
            JwtSecurityTokenHandler handler = new JwtSecurityTokenHandler();
            string encodedToken = handler.CreateEncodedJwt(descriptor);
            return encodedToken;
        }
    }
}