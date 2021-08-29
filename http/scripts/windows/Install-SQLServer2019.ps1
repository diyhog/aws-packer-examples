# https://community.chocolatey.org/packages/sql-server-2019#install

$ErrorActionPreference = 'Stop'

'Installing SQL Server 2019 Developer Edition via Chocolatey...'
choco install --yes --limitoutput --no-progress sql-server-2019
