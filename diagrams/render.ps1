param()
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
& (Join-Path $PSScriptRoot 'render-pages.ps1')

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
