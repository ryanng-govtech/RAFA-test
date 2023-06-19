using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpsPolicy;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using ReportAFaultAPI.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.IdentityModel.Tokens;
using System.Text;
using ReportAFaultAPI.Interfaces;
using ReportAFaultAPI.Controllers;
using Microsoft.IdentityModel.Logging;

namespace ReportAFaultAPI
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
            services.AddApplicationInsightsTelemetry();
            IdentityModelEventSource.ShowPII = true;

            services.AddControllers();
            services.AddCors(o => o.AddPolicy("AllowAll", builder =>
            {
                builder.AllowAnyOrigin()
                    .AllowAnyMethod()
                    .AllowAnyHeader();
            }));
            services.AddCors(o => o.AddPolicy("TestPolicy", builder =>
            {
                builder.WithOrigins("http://localhost:1024")
                    .AllowAnyMethod()
                    .AllowAnyHeader();
            }));
            services.AddCors(o => o.AddPolicy("QaPolicy", builder =>
            {
                builder.WithOrigins("https://fem.jtcqas.gov.sg")
                    .AllowAnyMethod()
                    .AllowAnyHeader();
            }));
            services.AddCors(o => o.AddPolicy("ProdPolicy", builder =>
            {
                builder.WithOrigins("https://fem.jtc.gov.sg")
                    .AllowAnyMethod()
                    .AllowAnyHeader();
            }));
            services.AddAuthentication(options =>
            {
                options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
                options.DefaultSignInScheme = JwtBearerDefaults.AuthenticationScheme;
            }).AddJwtBearer(options =>
            {
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(Encoding.ASCII.GetBytes(Configuration.GetValue<string>("SecretKey"))),
                    ValidateLifetime = true,
                    ValidateAudience = false,
                    ValidateIssuer = false,
                    ClockSkew = TimeSpan.Zero
                };
            });
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo { Title = "ReportAFaultAPI", Version = "v1" });
            });

            services.AddDbContext<RafaDbContext>(options => options.UseSqlServer(Configuration.GetConnectionString("RAFAConnectionString")));
            services.AddTransient<IRAFAEnvisionController, RAFAEnvisionController>();
        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
                app.UseSwagger();
                app.UseSwaggerUI(c => c.SwaggerEndpoint("/swagger/v1/swagger.json", "ReportAFaultAPI v1"));
            }
            else
            {
                app.Use(async (context, next) =>
                {
                    context.Response.Headers.Add("Content-Security-Policy", "default-src 'none'");
                    await next();
                });
            }

            app.UseHttpsRedirection();

            app.UseAuthentication();

            app.UseRouting();

            if (env.IsDevelopment())
            {
                app.UseCors("AllowAll");
            }
            else if (env.IsStaging())
            {
                app.UseCors("QaPolicy");
            }
            else if (env.IsProduction())
            {
                app.UseCors("ProdPolicy");
            }

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints
                    .MapControllers()
                    .RequireAuthorization();
            });
        }
    }
}
