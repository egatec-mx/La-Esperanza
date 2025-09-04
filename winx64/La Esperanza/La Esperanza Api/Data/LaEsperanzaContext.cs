using LaEsperanza.Api.Data.Models;
using Microsoft.EntityFrameworkCore;

namespace LaEsperanza.Api.Data
{
    public partial class LaEsperanzaContext : DbContext
    {
        public LaEsperanzaContext()
        {
        }

        public LaEsperanzaContext(DbContextOptions<LaEsperanzaContext> options)
            : base(options)
        {
        }

        public virtual DbSet<Countries> Countries { get; set; }
        public virtual DbSet<Customers> Customers { get; set; }
        public virtual DbSet<Devices> Devices { get; set; }
        public virtual DbSet<MethodOfPayment> MethodOfPayment { get; set; }
        public virtual DbSet<OrderDetails> OrderDetails { get; set; }
        public virtual DbSet<Orders> Orders { get; set; }
        public virtual DbSet<Products> Products { get; set; }
        public virtual DbSet<Roles> Roles { get; set; }
        public virtual DbSet<States> States { get; set; }
        public virtual DbSet<Status> Status { get; set; }
        public virtual DbSet<Users> Users { get; set; }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            optionsBuilder.UseLazyLoadingProxies(true);
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            modelBuilder.Entity<Countries>(entity =>
            {
                entity.Property(e => e.CountryActive).HasDefaultValueSql("((1))");

                entity.Property(e => e.CountryName).IsUnicode(false);
            });

            modelBuilder.Entity<Customers>(entity =>
            {
                entity.Property(e => e.CustomerActive).HasDefaultValueSql("((1))");

                entity.Property(e => e.CustomerCity).IsUnicode(false);

                entity.Property(e => e.CustomerColony).IsUnicode(false);

                entity.Property(e => e.CustomerLastname).IsUnicode(false);

                entity.Property(e => e.CustomerMail).IsUnicode(false);

                entity.Property(e => e.CustomerName).IsUnicode(false);

                entity.Property(e => e.CustomerPhone).IsUnicode(false);

                entity.Property(e => e.CustomerStreet).IsUnicode(false);

                entity.HasOne(d => d.State)
                    .WithMany(p => p.Customers)
                    .HasForeignKey(d => d.StateId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Customers_States");
            });

            modelBuilder.Entity<Devices>(entity =>
            {
                entity.Property(e => e.DeviceRegistrationDate).HasDefaultValueSql("(getdate())");

                entity.Property(e => e.DeviceValid).HasDefaultValueSql("((1))");

                entity.HasOne(d => d.User)
                    .WithMany(p => p.Devices)
                    .HasForeignKey(d => d.UserId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Devices_Users");
            });

            modelBuilder.Entity<MethodOfPayment>(entity =>
            {
                entity.Property(e => e.MopActive).HasDefaultValueSql("((1))");

                entity.Property(e => e.MopDescription).IsUnicode(false);
            });

            modelBuilder.Entity<OrderDetails>(entity =>
            {
                entity.HasOne(d => d.Order)
                    .WithMany(p => p.OrderDetails)
                    .HasForeignKey(d => d.OrderId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_OrderDetails_Orders");

                entity.HasOne(d => d.Product)
                    .WithMany(p => p.OrderDetails)
                    .HasForeignKey(d => d.ProductId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_OrderDetails_Products");
            });

            modelBuilder.Entity<Orders>(entity =>
            {
                entity.Property(e => e.OrderCanceledReason).IsUnicode(false);

                entity.Property(e => e.OrderNotes).IsUnicode(false);

                entity.Property(e => e.OrderQrCode).IsUnicode(false);

                entity.Property(e => e.OrderRejectedReason).IsUnicode(false);

                entity.Property(e => e.OrderSubtotal).HasDefaultValueSql("((0.00))");

                entity.Property(e => e.OrderTax).HasDefaultValueSql("((0.00))");

                entity.Property(e => e.OrderTotal).HasDefaultValueSql("((0.00))");

                entity.HasOne(d => d.Customer)
                    .WithMany(p => p.Orders)
                    .HasForeignKey(d => d.CustomerId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Orders_Customers");

                entity.HasOne(d => d.Mop)
                    .WithMany(p => p.Orders)
                    .HasForeignKey(d => d.MopId)
                    .HasConstraintName("FK_Orders_MethodOfPayment");

                entity.HasOne(d => d.Status)
                    .WithMany(p => p.Orders)
                    .HasForeignKey(d => d.StatusId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Orders_Status");

                entity.HasOne(d => d.User)
                    .WithMany(p => p.Orders)
                    .HasForeignKey(d => d.UserId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Orders_Users");
            });

            modelBuilder.Entity<Products>(entity =>
            {
                entity.Property(e => e.ProductActive).HasDefaultValueSql("((1))");

                entity.Property(e => e.ProductName).IsUnicode(false);
            });

            modelBuilder.Entity<Roles>(entity =>
            {
                entity.Property(e => e.RoleName).IsUnicode(false);
            });

            modelBuilder.Entity<States>(entity =>
            {
                entity.Property(e => e.StateActive).HasDefaultValueSql("((1))");

                entity.Property(e => e.StateName).IsUnicode(false);

                entity.HasOne(d => d.Country)
                    .WithMany(p => p.States)
                    .HasForeignKey(d => d.CountryId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_States_Countries");
            });

            modelBuilder.Entity<Status>(entity =>
            {
                entity.Property(e => e.StatusName).IsUnicode(false);
            });

            modelBuilder.Entity<Users>(entity =>
            {
                entity.HasIndex(e => e.UserUsername)
                    .HasName("UX_Users")
                    .IsUnique();

                entity.Property(e => e.UserActive).HasDefaultValueSql("((1))");

                entity.Property(e => e.UserFirstname).IsUnicode(false);

                entity.Property(e => e.UserLastname).IsUnicode(false);

                entity.Property(e => e.UserPassword).IsUnicode(false);

                entity.Property(e => e.UserUsername).IsUnicode(false);

                entity.HasOne(d => d.Role)
                    .WithMany(p => p.Users)
                    .HasForeignKey(d => d.RoleId)
                    .OnDelete(DeleteBehavior.ClientSetNull)
                    .HasConstraintName("FK_Users_Roles");
            });

            OnModelCreatingPartial(modelBuilder);
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
    }
}