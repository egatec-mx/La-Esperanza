using System.ComponentModel.DataAnnotations;

namespace La_Esperanza.Models
{
    public class PasswordChangeModel
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "El {0} es requerido")]
        [Display(Name = "nombre de usuario")]
        public string Username { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "La {0} es requerida")]
        [Display(Name = "nueva contraseña")]
        [DataType(DataType.Password)]
        public string Password { get; set; }
    }
}