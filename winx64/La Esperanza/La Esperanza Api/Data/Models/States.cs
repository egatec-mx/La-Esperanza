using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace La_Esperanza_Api.Data.Models
{
    public partial class States
    {
        public States()
        {
            Customers = new HashSet<Customers>();
        }

        [Key]
        [Column("state_id")]
        public int StateId { get; set; }

        [Column("country_id")]
        public int CountryId { get; set; }

        [Required]
        [Column("state_name")]
        [StringLength(50)]
        public string StateName { get; set; }

        [Required]
        [Column("state_active")]
        public bool? StateActive { get; set; }

        [ForeignKey(nameof(CountryId))]
        [InverseProperty(nameof(Countries.States))]
        public virtual Countries Country { get; set; }

        [InverseProperty("State")]
        public virtual ICollection<Customers> Customers { get; set; }
    }
}