param()

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$modelPath = Join-Path $PSScriptRoot 'currency-ui.sysml'
$outputPath = Join-Path $PSScriptRoot 'currency-ui.png'
$source = [IO.File]::ReadAllText($modelPath, [Text.Encoding]::UTF8)
$screens = [regex]::Matches($source, 'part def (\w+Screen)\s*\{([^}]+)\}')
if ($screens.Count -ne 4) { throw 'Expected four screen definitions in the SysML model.' }

$bitmap = New-Object Drawing.Bitmap 1600,1200
$graphics = [Drawing.Graphics]::FromImage($bitmap)
$graphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$font = New-Object Drawing.Font 'Segoe UI',15
$headingFont = New-Object Drawing.Font 'Segoe UI',22,([Drawing.FontStyle]::Bold)
$smallFont = New-Object Drawing.Font 'Segoe UI',12
$dark = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(25,43,65))
$muted = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(70,85,103))
$headerBrush = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(225,236,247))
$borderPen = New-Object Drawing.Pen ([Drawing.Color]::FromArgb(76,110,145)),2

try {
    $graphics.Clear([Drawing.Color]::FromArgb(247,249,252))
    $graphics.DrawString('КурсПульс — структурный прототип GUI', $headingFont, $dark, 45, 25)
    $graphics.DrawString('SysML v2 | part application : Application | вложенные части и их атрибуты', $font, $muted, 45, 75)
    $graphics.DrawRectangle($borderPen, 30, 120, 1540, 1020)
    $graphics.DrawString('«part» application : Application', $font, $dark, 55, 135)
    $navigation = [regex]::Match($source, 'attribute navigation : String = "([^"]+)"').Groups[1].Value
    $graphics.DrawString('navigation = ' + $navigation, $font, $muted, 55, 175)

    $usageNames = @('rates', 'converter', 'history', 'alerts')
    for ($index = 0; $index -lt $screens.Count; $index++) {
        $screen = $screens[$index]
        $x = 55 + ($index % 2) * 760
        $y = 235 + [Math]::Floor($index / 2) * 440
        $graphics.FillRectangle([Drawing.Brushes]::White, $x, $y, 730, 410)
        $graphics.FillRectangle($headerBrush, $x, $y, 730, 78)
        $graphics.DrawRectangle($borderPen, $x, $y, 730, 410)
        $graphics.DrawString(('«part» {0} : {1}' -f $usageNames[$index], $screen.Groups[1].Value), $font, $dark, ($x + 18), ($y + 10))
        $attributes = [regex]::Matches($screen.Groups[2].Value, 'attribute (\w+) : String = "([^"]+)";')
        $title = $attributes[0].Groups[2].Value
        $graphics.DrawString($title, $headingFont, $dark, ($x + 18), ($y + 37))
        $graphics.DrawString('attributes : String', $smallFont, $muted, ($x + 18), ($y + 90))
        for ($row = 1; $row -lt $attributes.Count; $row++) {
            $attribute = $attributes[$row]
            $lineY = $y + 120 + ($row - 1) * 43
            $graphics.DrawString($attribute.Groups[1].Value + ' =', $smallFont, $muted, ($x + 18), $lineY)
            $graphics.DrawString($attribute.Groups[2].Value, $font, $dark, ($x + 18), ($lineY + 17))
        }
    }
    $graphics.DrawString('Источник: currency-ui.sysml • Структура экранов; функциональность приложения не реализована.', $smallFont, $muted, 45, 1160)
    $bitmap.Save($outputPath, [Drawing.Imaging.ImageFormat]::Png)
    Write-Output $outputPath
}
finally {
    $graphics.Dispose()
    $bitmap.Dispose()
    $font.Dispose()
    $headingFont.Dispose()
    $smallFont.Dispose()
    $dark.Dispose()
    $muted.Dispose()
    $headerBrush.Dispose()
    $borderPen.Dispose()
}
