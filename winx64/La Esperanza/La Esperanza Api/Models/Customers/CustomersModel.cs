using LaEsperanza.Api.Data.Models;
using System.Collections.Generic;

namespace LaEsperanza.Api.Models
{
    public class CustomersModel : Customers
    {
        public string Message { get; set; }
        public List<string> Errors { get; set; }

        public string StateName { get; set; }
        public string CountryName { get; set; }

        public CustomersModel()
        {
            Errors = new List<string>();
        }
    }
}