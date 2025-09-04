using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace La_Esperanza.Models
{
    public class LoginModel
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "El {0} es requerido.")]
        [Display(Name = "usuario")]
        public string Username { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "La {0} es requerida.")]
        [DataType(DataType.Password)]
        [Display(Name = "contraseña")]
        public string Password { get; set; }

        public string ReturnUrl { get; set; }
    }
}
