using La_Esperanza.Data;
using La_Esperanza.Services;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.StaticFiles;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using WebEssentials.AspNetCore.Pwa;

namespace La_Esperanza
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {
            services.AddDbContext<LaEsperanzaContext>(options => options.UseSqlServer(Configuration.GetConnectionString("LaEsperanzaConnection")));
            services.AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme).AddCookie();
            services.AddControllersWithViews();
            services.AddProgressiveWebApp(new PwaOptions
            {
                EnableCspNonce = false,
                RegisterServiceWorker = false
            }, "manifest.json");
            services.AddRazorPages();
            services.Configure<PushSettings>(Configuration.GetSection("VapidKeys"));
            services.Configure<ApplePushSettings>(Configuration.GetSection("ApplePush"));
            services.AddTransient<IPushService, PushService>();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                app.UseDatabaseErrorPage();
            }
            else
            {
                app.UseExceptionHandler("/Home/Error");
                // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
                app.UseHsts();
            }

            app.UseHttpsRedirection();

            FileExtensionContentTypeProvider provider = new FileExtensionContentTypeProvider();
            provider.Mappings.Add(".ipa", "application/octect-stream");
            provider.Mappings.Add(".plist", "text/xml");

            app.UseStaticFiles(new StaticFileOptions { ContentTypeProvider = provider });

            app.UseRouting();
            app.UseAuthentication();
            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllerRoute(
                    name: "default",
                    pattern: "{controller=Home}/{action=Index}/{id?}");
                endpoints.MapRazorPages();
            });
        }
    }
}