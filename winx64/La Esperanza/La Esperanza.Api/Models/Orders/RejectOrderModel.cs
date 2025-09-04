namespace LaEsperanza.Api.Models
{
    public class RejectOrderModel : BaseModel
    {
        public long OrderId { get; set; }
        public string RejectReason { get; set; }
    }
}