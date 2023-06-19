using Microsoft.EntityFrameworkCore;

namespace ReportAFaultAPI.Models
{
    public class RafaDbContext : DbContext {
        public RafaDbContext(DbContextOptions<RafaDbContext> options) : base (options) {}

        public DbSet<RAFAFaultImage> RAFA_FAULTIMAGE { get; set; }

        public DbSet<RAFAFaultReport> RAFA_FAULTREPORT { get; set; }

        public DbSet<RAFAOTP> RAFA_OTP { get; set; }

        public DbSet<RAFASmsLog> FEMS_NOTIFICATION_LOG { get; set; }

        public DbSet<RAFAEnvisionApimToken> RAFA_ENVISIONAPIMTOKEN { get; set; }

        public DbSet<RAFAEnvisionBearerToken> RAFA_ENVISIONBEARERTOKEN { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder) {}

    }
}