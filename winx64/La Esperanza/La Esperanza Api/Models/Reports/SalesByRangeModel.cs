using LaEsperanza.Api.Data.Models;
using System;
using System.Collections.Generic;

namespace LaEsperanza.Api.Models.Reports
{
    public class SalesByRangeModel
    {
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public List<Orders> Orders { get; set; }
    }
}