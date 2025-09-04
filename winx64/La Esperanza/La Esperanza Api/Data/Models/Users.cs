using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace La_Esperanza_Api.Data.Models
{
    public partial class Users
    {
        public Users()
        {
            Devices = new HashSet<Devices>();
            Orders = new HashSet<Orders>();
        }

        [Key]
        [Column("user_id")]
        public int UserId { get; set; }

        [Required]
        [Column("user_username")]
        [StringLength(50)]
        public string UserUsername { get; set; }

        [Required]
        [Column("user_password")]
        [StringLength(100)]
        public string UserPassword { get; set; }

        [Required]
        [Column("user_firstname")]
        [StringLength(50)]
        public string UserFirstname { get; set; }

        [Required]
        [Column("user_lastname")]
        [StringLength(50)]
        public string UserLastname { get; set; }

        [Column("user_created_date", TypeName = "datetime")]
        public DateTime UserCreatedDate { get; set; }

        [Column("user_attempts")]
        public int? UserAttempts { get; set; }

        [Column("user_locked")]
        public bool UserLocked { get; set; }

        [Column("user_locked_date", TypeName = "datetime")]
        public DateTime? UserLockedDate { get; set; }

        [Column("role_id")]
        public int RoleId { get; set; }

        [Required]
        [Column("user_active")]
        public bool? UserActive { get; set; }

        [ForeignKey(nameof(RoleId))]
        [InverseProperty(nameof(Roles.Users))]
        public virtual Roles Role { get; set; }

        [InverseProperty("User")]
        public virtual ICollection<Devices> Devices { get; set; }

        [InverseProperty("User")]
        public virtual ICollection<Orders> Orders { get; set; }
    }
}