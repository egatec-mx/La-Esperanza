namespace LaEsperanza.Api.Models
{
    public class CancelOrderModel : BaseModel
    {
        public long OrderId { get; set; }
        public string CancelReason { get; set; }
    }
}