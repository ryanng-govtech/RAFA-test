# FEM-RAFA
## RAFAAPP
- contants.dart, set kIsRecaptchaEnabled = false;
- edit appsettings.json connection string for Database connection to SSMS

## RAFAAPI
- Constants.cs, set isDev = true;

## Database (Microsoft SQL Server Management Studio)
- create Database named FEMUsers in Microsoft SQL Server Management Studio
- execute db script .sql provided

## How to run in VSCode
- execute the following command in CLI in RAFAAPP
flutter run -d chrome --web-renderer html

- for RAFAAPI, run in CLI
dotnet restore
- go to run>run without debugging

1) When RAFA opens in browser, enter any 8 digit number (e.g. 12341234)
2) go to Database dbo.RAFA_OTP and copy the latest OTPCode into the OTP field in browser
3) on the next page, click enter 3 characters and click Others, 
	to use the map, sign up with OneMap, enter Email and Password into OneMapApiConfiguration in appsettings.json 
	in RAFAAPI for reverse geocoding, click anywhere on the map for location to be displayed in above box
	enter email address in format test@gmail.com

4) the final page is a Thank You page that will give error 500 as it is linked to Vendor company in QA and Prod
	and it is not connected in localhost