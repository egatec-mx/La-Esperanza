using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Threading.Tasks;

namespace La_Esperanza.Models
{
    public class SalesDates
    {
        [Required(AllowEmptyStrings = false, ErrorMessage = "La fecha de {0} es requerida")]
        [Display(Name = "inicio")]
        [DataType(DataType.Date)]
        public string StartDate { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "La fecha de {0} es requerida")]
        [Display(Name = "fin")]
        [DataType(DataType.Date)]
        public string EndDate { get; set; }
    }
}
