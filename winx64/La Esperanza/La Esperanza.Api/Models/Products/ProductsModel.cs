using LaEsperanza.Api.Data.Models;
using System.Collections.Generic;

namespace LaEsperanza.Api.Models
{
    public class ProductsModel : Products
    {
        public string Message { get; set; }
        public List<string> Errors { get; set; }

        public ProductsModel()
        {
            Errors = new List<string>();
        }
    }
}