using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace La_Esperanza_Api.Data.Models
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

        [Required]
        [Column("customer_name")]
        [StringLength(50)]
        public string CustomerName { get; set; }

        [Required]
        [Column("customer_lastname")]
        [StringLength(50)]
        public string CustomerLastname { get; set; }

        [Required]
        [Column("customer_street")]
        [StringLength(50)]
        public string CustomerStreet { get; set; }

        [Required]
        [Column("customer_colony")]
        [StringLength(50)]
        public string CustomerColony { get; set; }

        [Required]
        [Column("customer_city")]
        [StringLength(50)]
        public string CustomerCity { get; set; }

        [Column("state_id")]
        public int StateId { get; set; }

        [Column("customer_zipcode")]
        [StringLength(5)]
        public string CustomerZipcode { get; set; }

        [Required]
        [Column("customer_phone")]
        [StringLength(50)]
        public string CustomerPhone { get; set; }

        [Column("customer_mail")]
        [StringLength(50)]
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