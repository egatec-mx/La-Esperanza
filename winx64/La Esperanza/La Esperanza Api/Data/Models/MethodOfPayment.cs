using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace La_Esperanza_Api.Data.Models
{
    public partial class MethodOfPayment
    {
        public MethodOfPayment()
        {
            Orders = new HashSet<Orders>();
        }

        [Key]
        [Column("mop_id")]
        public int MopId { get; set; }

        [Required]
        [Column("mop_description")]
        [StringLength(50)]
        public string MopDescription { get; set; }

        [Column("mop_tax", TypeName = "money")]
        public decimal MopTax { get; set; }

        [Required]
        [Column("mop_active")]
        public bool? MopActive { get; set; }

        [InverseProperty("Mop")]
        public virtual ICollection<Orders> Orders { get; set; }
    }
}