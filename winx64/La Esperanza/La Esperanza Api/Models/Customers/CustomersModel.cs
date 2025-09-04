using System.Collections.Generic;

namespace La_Esperanza_Api.Models.Customers
{
    public class CustomersModel : Data.Models.Customers
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