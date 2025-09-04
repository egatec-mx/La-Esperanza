using System.ComponentModel.DataAnnotations;

namespace LaEsperanza.Api.Models
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