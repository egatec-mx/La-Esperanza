namespace LaEsperanza.Api.Models
{
    public class OrderDetailsModel
    {
        public long OrderDetailId { get; set; }
        public double OrderDetailQuantity { get; set; }
        public int ProductId { get; set; }
        public decimal OrderDetailPrice { get; set; }
        public decimal OrderDetailTotal { get; set; }
        public string ProductName { get; set; }
    }
}