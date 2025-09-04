using La_Esperanza_Api.Models.Base;

namespace La_Esperanza_Api.Models.Orders
{
    public class RejectOrderModel : BaseModel
    {
        public long OrderId { get; set; }
        public string RejectReason { get; set; }
    }
}