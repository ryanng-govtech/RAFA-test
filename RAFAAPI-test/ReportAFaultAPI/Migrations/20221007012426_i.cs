using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace ReportAFaultAPI.Migrations
{
    public partial class i : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "FEMS_NOTIFICATION_LOG",
                columns: table => new
                {
                    Id = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AppCode = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    NotificationType = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    Recipient = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    MessageId = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: true),
                    Subject = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    IsSuccess = table.Column<bool>(type: "bit", nullable: false),
                    ErrorMessages = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    LogDateTime = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_FEMS_NOTIFICATION_LOG", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "RAFA_ENVISIONAPIMTOKEN",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AccessToken = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    Expire = table.Column<int>(type: "int", nullable: true),
                    CreatedDateTime = table.Column<DateTime>(type: "datetime2", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RAFA_ENVISIONAPIMTOKEN", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "RAFA_FAULTREPORT",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    JtcCaseId = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    BuildingCode = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    OtherLocation = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    Latitude = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    Longitude = table.Column<string>(type: "nvarchar(10)", maxLength: 10, nullable: false),
                    SpaceId = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    LocationDetails = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    FaultDescription = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    Salutation = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    GivenName = table.Column<string>(type: "nvarchar(66)", maxLength: 66, nullable: false),
                    Surname = table.Column<string>(type: "nvarchar(66)", maxLength: 66, nullable: false),
                    ContactNumber = table.Column<string>(type: "nvarchar(8)", maxLength: 8, nullable: false),
                    EmailAddress = table.Column<string>(type: "nvarchar(320)", maxLength: 320, nullable: false),
                    IsReceiveUpdate = table.Column<bool>(type: "bit", nullable: false),
                    CreatedDateTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ReportStatus = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RAFA_FAULTREPORT", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "RAFA_OTP",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MobileNumber = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    OTPCode = table.Column<int>(type: "int", nullable: false),
                    CreatedDateTime = table.Column<DateTime>(type: "datetime2", nullable: false),
                    ExpiredDateTime = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Verified = table.Column<bool>(type: "bit", nullable: false),
                    IsActive = table.Column<bool>(type: "bit", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RAFA_OTP", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "RAFA_FAULTIMAGE",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    ImageData = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    RAFAFaultReportId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RAFA_FAULTIMAGE", x => x.Id);
                    table.ForeignKey(
                        name: "FK_RAFA_FAULTIMAGE_RAFA_FAULTREPORT_RAFAFaultReportId",
                        column: x => x.RAFAFaultReportId,
                        principalTable: "RAFA_FAULTREPORT",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_RAFA_FAULTIMAGE_RAFAFaultReportId",
                table: "RAFA_FAULTIMAGE",
                column: "RAFAFaultReportId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "FEMS_NOTIFICATION_LOG");

            migrationBuilder.DropTable(
                name: "RAFA_ENVISIONAPIMTOKEN");

            migrationBuilder.DropTable(
                name: "RAFA_FAULTIMAGE");

            migrationBuilder.DropTable(
                name: "RAFA_OTP");

            migrationBuilder.DropTable(
                name: "RAFA_FAULTREPORT");
        }
    }
}
