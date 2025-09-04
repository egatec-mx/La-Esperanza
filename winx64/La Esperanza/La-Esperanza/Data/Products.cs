using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace La_Esperanza.Data
{
    public partial class Products
    {
        public Products()
        {
            OrderDetails = new HashSet<OrderDetails>();
        }

        [Key]
        [Column("product_id")]
        public int ProductId { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "El {0} es requerido")]
        [Column("product_name")]
        [Display(Name = "producto")]
        public string ProductName { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "El {0} es requerido")]
        [Column("product_price", TypeName = "money")]
        [Display(Name = "precio")]
        [DataType(DataType.Currency)]
        public decimal ProductPrice { get; set; }

        [Required]
        [Column("product_active")]
        public bool? ProductActive { get; set; }

        [InverseProperty("Product")]
        public virtual ICollection<OrderDetails> OrderDetails { get; set; }
    }
}