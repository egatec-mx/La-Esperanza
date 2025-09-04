using La_Esperanza_Api.Models.Base;

namespace La_Esperanza_Api.Models.Orders
{
    public class CancelOrderModel : BaseModel
    {
        public long OrderId { get; set; }
        public string CancelReason { get; set; }
    }
}