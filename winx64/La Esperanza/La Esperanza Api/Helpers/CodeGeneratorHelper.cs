using System;
using System.IO;
using System.Threading.Tasks;

namespace La_Esperanza_Api.Helpers
{
    public static class CodeGeneratorHelper
    {
        public static async Task<string> GetCodeAsync(string OrderId)
        {
            return await Task.Factory.StartNew(() =>
            {
                using (MemoryStream memoryStream = new MemoryStream())
                {
                    // Removed EGATEC™ Barcode Express Propietary Code
                    // Because it is not free.
                    // You can use any other library to generate the barcode image.
                    string base64Img = Convert.ToBase64String(memoryStream.GetBuffer());
                    return base64Img;
                }
            }).ConfigureAwait(true);
        }
    }
}