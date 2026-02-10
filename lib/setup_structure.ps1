# Root files
New-Item -Path . -Name "main.dart" -ItemType "File" -Force

# App folder
$AppFolders = @("app")
$AppFiles = @(
    "app\app.dart",
    "app\app_router.dart"
)

# Core folder and subfolders
$CoreFolders = @(
    "core",
    "core\constants",
    "core\exceptions",
    "core\utils",
    "core\widgets"
)
$CoreFiles = @(
    "core\constants\app_colors.dart",
    "core\constants\app_strings.dart",
    "core\constants\app_routes.dart",
    "core\exceptions\app_exception.dart",
    "core\utils\date_time_helper.dart",
    "core\utils\adherence_calculator.dart",
    "core\widgets\primary_button.dart",
    "core\widgets\med_dose_card.dart",
    "core\widgets\adherence_chart_placeholder.dart"
)

# Features folder and subfolders
$FeaturesFolders = @(
    "features",
    "features\medication",
    "features\medication\models",
    "features\medication\repositories",
    "features\medication\providers",
    "features\medication\screens",
    "features\insights",
    "features\insights\screens",
    "features\profile",
    "features\profile\screens"
)
$FeaturesFiles = @(
    "features\medication\models\medication.dart",
    "features\medication\models\dose_log.dart",
    "features\medication\repositories\med_repository.dart",
    "features\medication\providers\med_providers.dart",
    "features\medication\screens\home_screen.dart",
    "features\medication\screens\add_med_screen.dart",
    "features\insights\screens\insights_screen.dart",
    "features\profile\screens\profile_screen.dart"
)

# Services folder
$ServicesFolders = @("services")
$ServicesFiles = @(
    "services\notification_service.dart",
    "services\hive_service.dart"
)

# Combine all folders and create them
$AllFolders = $AppFolders + $CoreFolders + $FeaturesFolders + $ServicesFolders
foreach ($folder in $AllFolders) {
    if (!(Test-Path $folder)) {
        New-Item -Path $folder -ItemType "Directory" | Out-Null
        Write-Host "Created folder: $folder"
    }
}

# Combine all files and create them
$AllFiles = $AppFiles + $CoreFiles + $FeaturesFiles + $ServicesFiles
foreach ($file in $AllFiles) {
    if (!(Test-Path $file)) {
        New-Item -Path $file -ItemType "File" -Force | Out-Null
        Write-Host "Created file: $file"
    }
}

Write-Host "`n✅ Project structure created successfully!" -ForegroundColor Green