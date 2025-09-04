using System;
using System.Collections.Generic;

namespace LaEsperanza.Api.Models
{
    public class OrdersModel : BaseModel
    {
        public long OrderId { get; set; }
        public int CustomerId { get; set; }
        public string CustomerName { get; set; }
        public string CustomerLastname { get; set; }
        public string CustomerPhone { get; set; }
        public string CustomerStreet { get; set; }
        public string CustomerColony { get; set; }
        public string CustomerCity { get; set; }
        public string CustomerZipcode { get; set; }
        public string StateName { get; set; }
        public string CountryName { get; set; }
        public DateTime OrderDate { get; set; }
        public string PaymentMethod { get; set; }
        public int? PaymentMethodId { get; set; }
        public DateTime? OrderScheduleDate { get; set; }
        public DateTime? OrderCanceledDate { get; set; }
        public string OrderCanceledReason { get; set; }
        public DateTime? OrderDeliveredDate { get; set; }
        public decimal? OrderDeliveryTax { get; set; }
        public string OrderNotes { get; set; }
        public DateTime? OrderProcessedDate { get; set; }
        public string OrderQrCode { get; set; }
        public DateTime? OrderRejectedDate { get; set; }
        public string OrderRejectedReason { get; set; }
        public DateTime? OrderStartedDate { get; set; }
        public decimal OrderSubtotal { get; set; }
        public decimal OrderTax { get; set; }
        public decimal OrderTotal { get; set; }
        public int StatusId { get; set; }
        public string StatusName { get; set; }
        public string UserFirstname { get; set; }
        public string UserLastname { get; set; }
        public List<OrderDetailsModel> Articles { get; set; }
    }
}