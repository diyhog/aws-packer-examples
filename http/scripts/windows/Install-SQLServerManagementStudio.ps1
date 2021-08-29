# https://community.chocolatey.org/packages/sql-server-management-studio#install

$ErrorActionPreference = 'Stop'

'Installing SQL Server Management Studio (SSMS) via Chocolatey...'
choco install --yes --limitoutput --no-progress sql-server-management-studio
