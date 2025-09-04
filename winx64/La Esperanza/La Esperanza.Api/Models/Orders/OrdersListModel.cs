namespace LaEsperanza.Api.Models
{
    public class OrdersListModel
    {
        public long OrderId { get; set; }
        public string OrderDate { get; set; }
        public string Customer { get; set; }
        public decimal OrderTotal { get; set; }
        public int StatusId { get; set; }
    }
}