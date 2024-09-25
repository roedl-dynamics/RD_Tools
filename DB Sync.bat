Title SyncDB
K:\AosService\WebRoot\bin\Microsoft.Dynamics.AX.Deployment.Setup.exe -bindir "K:\AosService\PackagesLocalDirectory" -metadatadir "K:\AosService\PackagesLocalDirectory" -sqluser axdbadmin -sqlserver localhost -sqldatabase AxDB -setupmode sync -syncmode fullall -isazuresql false -sqlpwd $Password
pause

