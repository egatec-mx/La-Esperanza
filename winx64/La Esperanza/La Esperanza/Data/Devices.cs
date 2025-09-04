using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace La_Esperanza.Data
{
    public partial class Devices
    {
        [Key]
        [Column("device_id")]
        public int DeviceId { get; set; }

        [Required]
        [Column("device_push_auth")]
        public string DevicePushAuth { get; set; }

        [Required]
        [Column("device_push_endpoint")]
        public string DevicePushEndpoint { get; set; }

        [Required]
        [Column("device_push_p256dh")]
        public string DevicePushP256dh { get; set; }

        [Column("user_id")]
        public int UserId { get; set; }

        [Column("device_valid")]
        public bool? DeviceValid { get; set; }

        [Column("device_notification_count")]
        public int DeviceNotificationCount { get; set; }

        [ForeignKey(nameof(UserId))]
        [InverseProperty(nameof(Users.Devices))]
        public virtual Users User { get; set; }
    }
}