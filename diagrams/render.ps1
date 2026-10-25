param()

$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$modelPath = Join-Path $PSScriptRoot 'ui-structure.sysml'
$outputPath = Join-Path $PSScriptRoot 'ui-structure.png'
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
    $graphics.DrawString('RateFlow — структурный прототип GUI', $headingFont, $dark, 45, 25)
    $graphics.DrawString('SysML v2 | part application : RateFlow | вложенные части и их атрибуты', $font, $muted, 45, 75)
    $graphics.DrawRectangle($borderPen, 30, 120, 1540, 1020)
    $graphics.DrawString('«part» application : RateFlow', $font, $dark, 55, 135)
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
    $graphics.DrawString('Источник: ui-structure.sysml • Структура экранов; функциональность приложения не реализована.', $smallFont, $muted, 45, 1160)
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

$casePath = Join-Path $PSScriptRoot 'use-cases.sysml'
$caseSource = [IO.File]::ReadAllText($casePath, [Text.Encoding]::UTF8)
$cases = [regex]::Matches($caseSource, 'use case def (\w+)\s*\{\s*subject system : RateFlowSystem;\s*actor user : User;\s*objective\s*\{\s*doc /\*\s*(.*?)\s*\*/')
if ($cases.Count -ne 6) { throw 'Expected six use case definitions.' }

$caseBitmap = New-Object Drawing.Bitmap 1400,1200
$caseGraphics = [Drawing.Graphics]::FromImage($caseBitmap)
$caseGraphics.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
$caseGraphics.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
$caseFont = New-Object Drawing.Font 'Segoe UI',18
$caseSmallFont = New-Object Drawing.Font 'Segoe UI',13
$caseTitleFont = New-Object Drawing.Font 'Segoe UI',25,([Drawing.FontStyle]::Bold)
$casePen = New-Object Drawing.Pen ([Drawing.Color]::FromArgb(65,92,120)),2
$caseFill = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(230,240,250))
$caseInk = New-Object Drawing.SolidBrush ([Drawing.Color]::FromArgb(25,43,65))
$centered = New-Object Drawing.StringFormat
$centered.Alignment = [Drawing.StringAlignment]::Center
$centered.LineAlignment = [Drawing.StringAlignment]::Center

try {
    $caseGraphics.Clear([Drawing.Color]::FromArgb(247,249,252))
    $caseGraphics.DrawString('RateFlow — варианты использования', $caseTitleFont, $caseInk, 40, 25)
    $caseGraphics.DrawString('SysML v2 | субъект system : RateFlowSystem | актор user : User', $caseSmallFont, $caseInk, 42, 80)
    $caseGraphics.FillRectangle([Drawing.Brushes]::White, 390, 125, 950, 990)
    $caseGraphics.DrawRectangle($casePen, 390, 125, 950, 990)
    $caseGraphics.DrawString('«subject» system : RateFlowSystem', $caseFont, $caseInk, 420, 143)

    # Actor shared by each of the six definitions in the source model.
    $caseGraphics.DrawEllipse($casePen, 145, 520, 56, 56)
    $caseGraphics.DrawLine($casePen, 173, 576, 173, 665)
    $caseGraphics.DrawLine($casePen, 115, 610, 231, 610)
    $caseGraphics.DrawLine($casePen, 173, 665, 125, 735)
    $caseGraphics.DrawLine($casePen, 173, 665, 221, 735)
    $caseGraphics.DrawString('«actor»', $caseSmallFont, $caseInk, 137, 760)
    $caseGraphics.DrawString('user : User', $caseFont, $caseInk, 105, 787)
    $caseGraphics.DrawString('Пользователь', $caseFont, $caseInk, 91, 823)

    for ($index = 0; $index -lt $cases.Count; $index++) {
        $y = 200 + $index * 145
        $caseGraphics.DrawLine($casePen, 231, 610, 505, ($y + 57))
        $caseGraphics.FillEllipse($caseFill, 505, $y, 770, 114)
        $caseGraphics.DrawEllipse($casePen, 505, $y, 770, 114)
        $notation = '«use case def» ' + $cases[$index].Groups[1].Value
        $caseGraphics.DrawString($notation, $caseSmallFont, $caseInk, (New-Object Drawing.RectangleF 520,($y + 10),740,30), $centered)
        $caseGraphics.DrawString($cases[$index].Groups[2].Value, $caseFont, $caseInk, (New-Object Drawing.RectangleF 520,($y + 42),740,52), $centered)
    }
    $caseGraphics.DrawString('Источник: use-cases.sysml • Линии показывают участие актора в вариантах использования.', $caseSmallFont, $caseInk, 40, 1153)
    $caseOutput = Join-Path $PSScriptRoot 'use-cases.png'
    $caseBitmap.Save($caseOutput, [Drawing.Imaging.ImageFormat]::Png)
    Write-Output $caseOutput
}
finally {
    $caseGraphics.Dispose()
    $caseBitmap.Dispose()
    $caseFont.Dispose()
    $caseSmallFont.Dispose()
    $caseTitleFont.Dispose()
    $casePen.Dispose()
    $caseFill.Dispose()
    $caseInk.Dispose()
    $centered.Dispose()
}
