using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace La_Esperanza.Data
{
    public partial class Customers
    {
        public Customers()
        {
            Orders = new HashSet<Orders>();
        }

        [Key]
        [Column("customer_id")]
        public int CustomerId { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "El/Los {0} es/son requerido(s)")]
        [Column("customer_name")]
        [StringLength(50)]
        [Display(Name = "nombre(s)")]
        public string CustomerName { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "El/Los {0} es/son requerido(s)")]
        [Column("customer_lastname")]
        [StringLength(50)]
        [Display(Name = "apellido(s)")]
        public string CustomerLastname { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "La {0} es requerida")]
        [Column("customer_street")]
        [StringLength(50)]
        [Display(Name = "calle")]
        public string CustomerStreet { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "La {0} es requerida")]
        [Column("customer_colony")]
        [StringLength(50)]
        [Display(Name = "colonia / barrio")]
        public string CustomerColony { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "La {0} es requerida")]
        [Column("customer_city")]
        [StringLength(50)]
        [Display(Name = "ciudad / municipio / alcaldía / delegación")]
        public string CustomerCity { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "El {0} es requerido")]
        [Column("state_id")]
        [Display(Name = "estado")]
        public int StateId { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "El {0} es requerido")]
        [Column("customer_zipcode")]
        [Display(Name = "código postal")]
        public string CustomerZipcode { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "El {0} es requerido")]
        [Column("customer_phone")]
        [StringLength(50)]
        [Display(Name = "teléfono")]
        public string CustomerPhone { get; set; }

        [Column("customer_mail")]
        [StringLength(50)]
        [Display(Name = "e-mail (opcional)")]
        public string CustomerMail { get; set; }

        [Required]
        [Column("customer_active")]
        public bool? CustomerActive { get; set; }

        [ForeignKey(nameof(StateId))]
        [InverseProperty(nameof(States.Customers))]
        public virtual States State { get; set; }

        [InverseProperty("Customer")]
        public virtual ICollection<Orders> Orders { get; set; }
    }
}