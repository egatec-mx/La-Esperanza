using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace La_Esperanza.Data
{
    public partial class Users
    {
        public Users()
        {
            Orders = new HashSet<Orders>();
        }

        [Required]
        [Key]
        [Column("user_id")]
        public int UserId { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "El {0} es requerido")]
        [Column("user_username")]
        [StringLength(50)]
        [Display(Name = "usuario")]
        public string UserUsername { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "La {0} es requerida")]
        [Column("user_password")]
        [StringLength(100)]
        [DataType(DataType.Password)]
        [Display(Name = "contraseña")]
        public string UserPassword { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "El {0} es requerido")]
        [Column("user_firstname")]
        [StringLength(50)]
        [Display(Name = "nombre")]
        public string UserFirstname { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "El/los {0} es/son requerido(s)")]
        [Column("user_lastname")]
        [StringLength(50)]
        [Display(Name = "apellido(s)")]
        public string UserLastname { get; set; }

        [Column("user_created_date", TypeName = "datetime")]
        public DateTime UserCreatedDate { get; set; }

        [Column("user_attempts")]
        public int? UserAttempts { get; set; }

        [Column("user_locked")]
        public bool UserLocked { get; set; }

        [Column("user_locked_date", TypeName = "datetime")]
        public DateTime? UserLockedDate { get; set; }

        [Required(AllowEmptyStrings = false, ErrorMessage = "El {0} es requerido")]
        [Column("role_id")]
        [Display(Name = "rol")]
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

