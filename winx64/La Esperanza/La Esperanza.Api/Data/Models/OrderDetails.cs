using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace LaEsperanza.Api.Data.Models
{
    public partial class OrderDetails
    {
        [Key]
        [Column("order_detail_id")]
        public long OrderDetailId { get; set; }

        [Column("order_id")]
        public long OrderId { get; set; }

        [Column("order_detail_quantity")]
        public double OrderDetailQuantity { get; set; }

        [Column("product_id")]
        public int ProductId { get; set; }

        [Column("order_detail_price", TypeName = "money")]
        public decimal OrderDetailPrice { get; set; }

        [Column("order_detail_total", TypeName = "money")]
        public decimal OrderDetailTotal { get; set; }

        [ForeignKey(nameof(OrderId))]
        [InverseProperty(nameof(Orders.OrderDetails))]
        public virtual Orders Order { get; set; }

        [ForeignKey(nameof(ProductId))]
        [InverseProperty(nameof(Products.OrderDetails))]
        public virtual Products Product { get; set; }
    }
}