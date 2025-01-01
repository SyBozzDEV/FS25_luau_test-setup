param (
    # If run with -y flag the zip file gets copied to the FS25 mod folder without asking
    [switch]$y
)

$configFile = Get-Content -Path "build.config"

function SetTargetPath {
    param (
        [hashtable]$config
    )
    $basePath = (Get-Item .).FullName
    $config.zipFilePath = Join-Path -Path $basePath -ChildPath (Join-Path -Path $config.buildFolder -ChildPath $config.targetFileName)
    return $config
}

function ParseConfig {
    $result = @{}
    foreach ($line in $configFile) {
        if ($line -match "^buildFolder=(.*)$") {
            $result.buildFolder = $matches[1]
        } elseif ($line -match "^targetFileName=(.*)$") {
            $result.targetFileName = $matches[1]
        } elseif ($line -match "^include=(.*)$") {
            $result.include = $matches[1] -split ";"
        }
    }
    return SetTargetPath -config $result
}

function CreateBuildFolder {
    param (
        [string]$path
    )
    if (Test-Path -Path $path) {
        Remove-Item -Path $path -Force -Recurse
    }
    New-Item -Path $path -ItemType Directory | Out-Null
}

function CreateBuildFile {
    param (
        [Hashtable]$config
    )
    Push-Location -Path ".\src\"

    & tar.exe -acf "$($config.zipFilePath)" $config.include

    if ($LASTEXITCODE -ne 0) {
        Write-Error "Could not create zip file"
        Pop-Location
        exit $LASTEXITCODE
    }

    Write-Output "Build was successfull"

    Pop-Location
}

function AskYesNoQuestion {
    param (
        [string]$Question
    )

    while ($true) {
        $response = Read-Host "$Question [y/n]"

        switch ($response.ToLower()) {
            'y' { return $true }
            'n' { return $false }
            default { Write-Host "Please answer with 'y' or 'n'." }
        }
    }
}

function CopyResultToModFolder {
    param (
        [Hashtable]$config
    )
    # Define the path to the "Documents" folder, user and language independent
    $documentsPath = [System.Environment]::GetFolderPath('MyDocuments')

    # Combine the "Documents" path with "My Games\FarmingSimulator2025\mods" folder
    $modsFolderPath = Join-Path -Path $documentsPath -ChildPath "My Games\FarmingSimulator2025\mods"

    if (-Not (Test-Path -Path $modsFolderPath)) {
        Write-Warning "The path '$modsFolderPath' does not exist."
        return
    }

    if ($y -or (AskYesNoQuestion -Question "Copy '$($config.targetFileName)' to the FS25 mod folder?")) {
        Copy-Item -Path "$($config.zipFilePath)" -Destination $modsFolderPath -Force
        Write-Output "$($config.targetFileName) copy to FS25 mod successfull"
    }
}

$config = ParseConfig
CreateBuildFolder -Path $config.buildFolder
CreateBuildFile -config $config
CopyResultToModFolder -config $config
