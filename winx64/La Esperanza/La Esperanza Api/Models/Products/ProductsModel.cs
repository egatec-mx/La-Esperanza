using System.Collections.Generic;

namespace La_Esperanza_Api.Models.Products
{
    public class ProductsModel : Data.Models.Products
    {
        public string Message { get; set; }
        public List<string> Errors { get; set; }

        public ProductsModel()
        {
            Errors = new List<string>();
        }
    }
}