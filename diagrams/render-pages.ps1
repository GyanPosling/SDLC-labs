param()
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

foreach ($pageFile in @('rates-page', 'converter-page', 'history-page', 'notifications-page')) {
    $source = [IO.File]::ReadAllText((Join-Path $PSScriptRoot ($pageFile + '.sysml')), [Text.Encoding]::UTF8)
    $definitions = [regex]::Matches($source, 'part def (\w+)\s*\{([^}]+)\}')
    $page = $definitions[0]
    $parts = [regex]::Matches($page.Groups[2].Value, 'part (\w+) : (\w+);')
    if ($parts.Count -ne 6) { throw "Expected six components in $pageFile" }
    $title = [regex]::Match($page.Groups[2].Value, 'attribute title : String = "([^"]+)"').Groups[1].Value
    $bitmap = New-Object Drawing.Bitmap 2400,1000
    $g = [Drawing.Graphics]::FromImage($bitmap)
    $g.SmoothingMode = [Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $pen = New-Object Drawing.Pen ([Drawing.Color]::Black),2
    $font = New-Object Drawing.Font 'Arial',17
    $small = New-Object Drawing.Font 'Arial',15
    $bold = New-Object Drawing.Font 'Arial',20,([Drawing.FontStyle]::Bold)
    $format = New-Object Drawing.StringFormat
    $format.Alignment = [Drawing.StringAlignment]::Center
    $format.LineAlignment = [Drawing.StringAlignment]::Center

    try {
        $g.Clear([Drawing.Color]::White)
        $g.DrawRectangle($pen, 20, 58, 2360, 910)
        $g.DrawRectangle($pen, 20, 18, 610, 40)
        $g.DrawString(('RateFlow_' + $page.Groups[1].Value), $bold, [Drawing.Brushes]::Black, 35, 22)

        # Page definition and its title attribute.
        $g.DrawRectangle($pen, 850, 105, 700, 155)
        $g.DrawString('«part def»', $font, [Drawing.Brushes]::Black, (New-Object Drawing.RectangleF 850,112,700,32), $format)
        $g.DrawString($page.Groups[1].Value, $bold, [Drawing.Brushes]::Black, (New-Object Drawing.RectangleF 850,145,700,39), $format)
        $g.DrawLine($pen, 850, 188, 1550, 188)
        $g.DrawString('attributes', $small, [Drawing.Brushes]::Black, (New-Object Drawing.RectangleF 850,194,700,25), $format)
        $g.DrawString(('title = "' + $title + '"'), $font, [Drawing.Brushes]::Black, (New-Object Drawing.RectangleF 860,222,680,32), $format)

        for ($index = 0; $index -lt $parts.Count; $index++) {
            $partName = $parts[$index].Groups[1].Value
            $typeName = $parts[$index].Groups[2].Value
            $definition = @($definitions | Where-Object { $_.Groups[1].Value -eq $typeName })[0]
            if (-not $definition) { throw "Missing definition $typeName" }
            $attrs = [regex]::Matches($definition.Groups[2].Value, 'attribute (\w+) : String = "([^"]+)";')
            $x = 40 + $index * 390
            $center = $x + 185
            $diamondX = 935 + $index * 105
            $diamond = [Drawing.PointF[]]@(
                (New-Object Drawing.PointF $diamondX,252),
                (New-Object Drawing.PointF ($diamondX + 10),264),
                (New-Object Drawing.PointF $diamondX,276),
                (New-Object Drawing.PointF ($diamondX - 10),264)
            )
            $g.FillPolygon([Drawing.Brushes]::Black, $diamond)
            $g.DrawLine($pen, $diamondX, 276, $diamondX, 320)
            $g.DrawLine($pen, $diamondX, 320, $center, 320)
            $g.DrawLine($pen, $center, 320, $center, 407)
            $arrow = [Drawing.PointF[]]@((New-Object Drawing.PointF $center,415),(New-Object Drawing.PointF ($center - 6),403),(New-Object Drawing.PointF ($center + 6),403))
            $g.FillPolygon([Drawing.Brushes]::Black, $arrow)

            # Part usage and the definition to which it is typed.
            $g.DrawRectangle($pen, $x, 415, 370, 85)
            $g.DrawString('«part»', $font, [Drawing.Brushes]::Black, (New-Object Drawing.RectangleF $x,421,370,30), $format)
            $g.DrawString(($partName + ': ' + $typeName), $font, [Drawing.Brushes]::Black, (New-Object Drawing.RectangleF ($x + 5),452,360,43), $format)
            $g.DrawLine($pen, $center, 500, $center, 600)
            $arrow = [Drawing.PointF[]]@((New-Object Drawing.PointF $center,609),(New-Object Drawing.PointF ($center - 6),597),(New-Object Drawing.PointF ($center + 6),597))
            $g.FillPolygon([Drawing.Brushes]::Black, $arrow)

            $g.DrawRectangle($pen, $x, 610, 370, 290)
            $g.DrawString('«part def»', $font, [Drawing.Brushes]::Black, (New-Object Drawing.RectangleF $x,617,370,30), $format)
            $g.DrawString($typeName, $bold, [Drawing.Brushes]::Black, (New-Object Drawing.RectangleF ($x + 3),649,364,36), $format)
            $g.DrawLine($pen, $x, 693, ($x + 370), 693)
            $g.DrawString('attributes', $small, [Drawing.Brushes]::Black, (New-Object Drawing.RectangleF $x,700,370,28), $format)
            for ($row = 0; $row -lt $attrs.Count; $row++) {
                $label = $attrs[$row].Groups[1].Value + ' = "' + $attrs[$row].Groups[2].Value + '"'
                $g.DrawString($label, $small, [Drawing.Brushes]::Black, (New-Object Drawing.RectangleF ($x + 10),(735 + $row * 53),350,53), $format)
            }
        }
        $outputPath = Join-Path $PSScriptRoot ($pageFile + '.png')
        $bitmap.Save($outputPath, [Drawing.Imaging.ImageFormat]::Png)
        Write-Output $outputPath
    }
    finally {
        $g.Dispose(); $bitmap.Dispose(); $pen.Dispose()
        $font.Dispose(); $small.Dispose(); $bold.Dispose(); $format.Dispose()
    }
}
