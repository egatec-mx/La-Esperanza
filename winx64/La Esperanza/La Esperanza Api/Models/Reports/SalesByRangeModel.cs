using System;
using System.Collections.Generic;

namespace La_Esperanza_Api.Models.Reports
{
    public class SalesByRangeModel
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public List<Data.Models.Orders> Orders { get; set; }
    }
}