using La_Esperanza_Api.Models.Base;
using System.ComponentModel.DataAnnotations;

namespace La_Esperanza_Api.Models.Account
{
    public class LogInModel : BaseModel
    {
        [Required(ErrorMessageResourceName = "LOGINMODEL_USERNAME_VALIDATION", ErrorMessageResourceType = typeof(Properties.Resources))]
        public string UserName { get; set; }

        [Required(ErrorMessageResourceName = "LOGINMODEL_PASSWORD_VALIDATION", ErrorMessageResourceType = typeof(Properties.Resources))]
        [DataType(DataType.Password)]
        public string Password { get; set; }

        public string Token { get; set; }
    }
}