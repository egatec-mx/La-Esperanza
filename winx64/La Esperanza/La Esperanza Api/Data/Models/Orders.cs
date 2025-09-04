using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace LaEsperanza.Api.Data.Models
{
    public partial class Orders
    {
        public Orders()
        {
            OrderDetails = new HashSet<OrderDetails>();
        }

        [Key]
        [Column("order_id")]
        public long OrderId { get; set; }

        [Column("user_id")]
        public int UserId { get; set; }

        [Column("customer_id")]
        public int CustomerId { get; set; }

        [Column("order_date", TypeName = "datetime")]
        public DateTime OrderDate { get; set; }

        [Column("order_notes")]
        public string OrderNotes { get; set; }

        [Column("order_subtotal", TypeName = "money")]
        public decimal OrderSubtotal { get; set; }

        [Column("order_tax", TypeName = "money")]
        public decimal OrderTax { get; set; }

        [Column("order_delivery_tax", TypeName = "money")]
        public decimal? OrderDeliveryTax { get; set; }

        [Column("order_total", TypeName = "money")]
        public decimal OrderTotal { get; set; }

        [Column("order_started_date", TypeName = "datetime")]
        public DateTime? OrderStartedDate { get; set; }

        [Column("order_processed_date", TypeName = "datetime")]
        public DateTime? OrderProcessedDate { get; set; }

        [Column("order_delivered_date", TypeName = "datetime")]
        public DateTime? OrderDeliveredDate { get; set; }

        [Column("order_canceled_date", TypeName = "datetime")]
        public DateTime? OrderCanceledDate { get; set; }

        [Column("order_canceled_reason")]
        public string OrderCanceledReason { get; set; }

        [Column("order_rejected_date", TypeName = "datetime")]
        public DateTime? OrderRejectedDate { get; set; }

        [Column("order_rejected_reason")]
        public string OrderRejectedReason { get; set; }

        [Column("order_qr_code")]
        public string OrderQrCode { get; set; }

        [Column("order_schedule_date", TypeName = "datetime")]
        public DateTime? OrderScheduleDate { get; set; }

        [Column("mop_id")]
        public int? MopId { get; set; }

        [Column("status_id")]
        public int StatusId { get; set; }

        [ForeignKey(nameof(CustomerId))]
        [InverseProperty(nameof(Customers.Orders))]
        public virtual Customers Customer { get; set; }

        [ForeignKey(nameof(MopId))]
        [InverseProperty(nameof(MethodOfPayment.Orders))]
        public virtual MethodOfPayment Mop { get; set; }

        [ForeignKey(nameof(StatusId))]
        [InverseProperty("Orders")]
        public virtual Status Status { get; set; }

        [ForeignKey(nameof(UserId))]
        [InverseProperty(nameof(Users.Orders))]
        public virtual Users User { get; set; }

        [InverseProperty("Order")]
        public virtual ICollection<OrderDetails> OrderDetails { get; set; }
    }
}