using System;
using System.Security.Cryptography;
using System.Text;

namespace LaEsperanza.Api.Helpers
{
    public static class PasswordHelper
    {
        public static string HashPassword(string passsword)
        {
            using (SHA512 service = new SHA512CryptoServiceProvider())
            {
                byte[] input = Encoding.ASCII.GetBytes(passsword);
                byte[] output = service.ComputeHash(input, 0, input.Length);
                return Convert.ToBase64String(output);
            }
        }
    }
}