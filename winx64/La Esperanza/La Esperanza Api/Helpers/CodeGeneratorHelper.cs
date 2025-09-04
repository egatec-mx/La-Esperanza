using Barcode.Express.Core;
using System;
using System.Drawing;
using System.Drawing.Imaging;
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
                    using (QRCode qrCode = new QRCode
                    {
                        BackgroundColor = Color.White,
                        ForeColor = Color.Black,
                        Size = 5,
                        Value = OrderId
                    })
                    {
                        qrCode.Draw().Save(memoryStream, ImageFormat.Png);
                    }
                    string base64Img = Convert.ToBase64String(memoryStream.GetBuffer());
                    return base64Img;
                }
            }).ConfigureAwait(true);
        }
    }
}