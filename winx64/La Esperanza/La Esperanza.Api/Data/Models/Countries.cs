using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace LaEsperanza.Api.Data.Models
{
    public partial class Countries
    {
        public Countries()
        {
            States = new HashSet<States>();
        }

        [Key]
        [Column("country_id")]
        public int CountryId { get; set; }

        [Required]
        [Column("country_name")]
        [StringLength(50)]
        public string CountryName { get; set; }

        [Required]
        [Column("country_active")]
        public bool? CountryActive { get; set; }

        [InverseProperty("Country")]
        public virtual ICollection<States> States { get; set; }
    }
}