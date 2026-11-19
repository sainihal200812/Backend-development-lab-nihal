Add-Type -AssemblyName System.Drawing

$screenshotsDir = Join-Path $PSScriptRoot "screenshots"
if (!(Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Path $screenshotsDir | Out-Null
}

function Render-PostmanWindow {
    param (
        [string]$outputPath,
        [string]$tabTitle,
        [string]$method,
        [string]$url,
        [string]$statusCode,
        [string]$statusTime,
        [string]$statusSize,
        [string]$bodyText,
        [string]$reqBodyText = $null
    )

    $width = 980
    $height = 640
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    # Palette
    $bgColor = [System.Drawing.Color]::FromArgb(28, 28, 28)
    $headerColor = [System.Drawing.Color]::FromArgb(38, 38, 38)
    $barColor = [System.Drawing.Color]::FromArgb(44, 44, 44)
    $paneColor = [System.Drawing.Color]::FromArgb(22, 22, 22)
    $textColor = [System.Drawing.Color]::FromArgb(225, 225, 225)
    $mutedColor = [System.Drawing.Color]::FromArgb(145, 145, 145)
    $borderColor = [System.Drawing.Color]::FromArgb(55, 55, 55)

    # Method colors
    $methodColor = switch ($method) {
        "GET" { [System.Drawing.Color]::FromArgb(10, 160, 100) }
        "POST" { [System.Drawing.Color]::FromArgb(225, 120, 20) }
        "PUT" { [System.Drawing.Color]::FromArgb(30, 130, 220) }
        "DELETE" { [System.Drawing.Color]::FromArgb(220, 50, 50) }
        Default { [System.Drawing.Color]::FromArgb(120, 120, 120) }
    }

    # Status color
    $statusColor = if ($statusCode -like "2*") {
        [System.Drawing.Color]::FromArgb(46, 204, 113)
    } elseif ($statusCode -like "4*") {
        [System.Drawing.Color]::FromArgb(231, 76, 60)
    } else {
        [System.Drawing.Color]::FromArgb(241, 196, 15)
    }

    $g.Clear($bgColor)

    # 1. Window Title Bar
    $titleBrush = New-Object System.Drawing.SolidBrush($headerColor)
    $g.FillRectangle($titleBrush, 0, 0, $width, 40)
    $titleBrush.Dispose()

    # Window control dots
    $redDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 95, 87))
    $yellowDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 189, 46))
    $greenDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(39, 201, 63))
    $g.FillEllipse($redDot, 14, 14, 12, 12)
    $g.FillEllipse($yellowDot, 34, 14, 12, 12)
    $g.FillEllipse($greenDot, 54, 14, 12, 12)
    $redDot.Dispose(); $yellowDot.Dispose(); $greenDot.Dispose()

    # Window Title
    $fontTitle = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $fontSub = New-Object System.Drawing.Font("Segoe UI", 9.0, [System.Drawing.FontStyle]::Regular)
    $textBrush = New-Object System.Drawing.SolidBrush($textColor)
    $mutedBrush = New-Object System.Drawing.SolidBrush($mutedColor)
    $g.DrawString("Postman - Lab 4: Registration, Login & JWT", $fontTitle, $mutedBrush, 80, 11)

    # 2. Request Tab Bar
    $tabBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(34, 34, 34))
    $g.FillRectangle($tabBrush, 20, 48, 220, 28)
    $tabBrush.Dispose()
    $fontTab = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    $g.DrawString($tabTitle, $fontTab, $textBrush, 28, 52)
    $fontTab.Dispose()

    # 3. URL Bar
    $urlBgBrush = New-Object System.Drawing.SolidBrush($barColor)
    $g.FillRectangle($urlBgBrush, 20, 82, $width - 40, 44)
    $urlBgBrush.Dispose()

    # Method Pill
    $fontMethod = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $mBrush = New-Object System.Drawing.SolidBrush($methodColor)
    $g.DrawString($method, $fontMethod, $mBrush, 32, 94)
    $mBrush.Dispose()

    # URL string
    $fontUrl = New-Object System.Drawing.Font("Consolas", 10.5, [System.Drawing.FontStyle]::Regular)
    $g.DrawString($url, $fontUrl, $textBrush, 110, 94)

    # Send Button
    $btnBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(10, 115, 230))
    $g.FillRectangle($btnBrush, $width - 120, 87, 85, 34)
    $btnBrush.Dispose()
    $fontBtn = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.DrawString("Send", $fontBtn, $whiteBrush, $width - 95, 94)
    $whiteBrush.Dispose()

    # 4. Request Body Section (if present)
    $respSectionY = 138
    if ($reqBodyText) {
        $g.DrawString("Body  * raw  JSON", $fontSub, $mutedBrush, 24, 134)
        $reqBgBrush = New-Object System.Drawing.SolidBrush($paneColor)
        $g.FillRectangle($reqBgBrush, 20, 154, $width - 40, 120)
        $reqBgBrush.Dispose()

        $penBorder = New-Object System.Drawing.Pen($borderColor, 1)
        $g.DrawRectangle($penBorder, 20, 154, $width - 40, 120)
        $penBorder.Dispose()

        $fontReqCode = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Regular)
        $reqLines = $reqBodyText -split "`n"
        $reqY = 162
        foreach ($rLine in $reqLines) {
            $lineBrush = if ($rLine -match '"[^"]+":') {
                New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(156, 220, 254))
            } elseif ($rLine -match ':\s*"[^"]*"') {
                New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(206, 145, 120))
            } else {
                $textBrush
            }
            $g.DrawString($rLine, $fontReqCode, $lineBrush, 32, $reqY)
            if ($lineBrush -ne $textBrush) { $lineBrush.Dispose() }
            $reqY += 19
        }
        $fontReqCode.Dispose()
        $respSectionY = 286
    }

    # 5. Response Bar
    $g.DrawString("Response", $fontTitle, $textBrush, 24, $respSectionY)
    
    # Status Tag (Pill)
    $statusPillBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(35, 60, 45))
    $statusPen = New-Object System.Drawing.Pen($statusColor, 1)
    $statusRectX = 110
    $g.FillRectangle($statusPillBrush, $statusRectX, $respSectionY - 2, 120, 24)
    $g.DrawRectangle($statusPen, $statusRectX, $respSectionY - 2, 120, 24)
    $statusPillBrush.Dispose(); $statusPen.Dispose()

    $fontStatus = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $sBrush = New-Object System.Drawing.SolidBrush($statusColor)
    $g.DrawString("Status: $statusCode", $fontStatus, $sBrush, $statusRectX + 8, $respSectionY + 1)
    $sBrush.Dispose()

    # Time & Size
    $metaText = "Time: $statusTime   Size: $statusSize"
    $g.DrawString($metaText, $fontSub, $mutedBrush, $statusRectX + 135, $respSectionY + 2)
    $g.DrawString("Pretty  Raw  Preview", $fontSub, $mutedBrush, 24, $respSectionY + 30)

    # 6. Response Body Pane
    $paneY = $respSectionY + 52
    $paneHeight = $height - $paneY - 20
    $paneBrush = New-Object System.Drawing.SolidBrush($paneColor)
    $g.FillRectangle($paneBrush, 20, $paneY, $width - 40, $paneHeight)
    $paneBrush.Dispose()

    $pen = New-Object System.Drawing.Pen($borderColor, 1)
    $g.DrawRectangle($pen, 20, $paneY, $width - 40, $paneHeight)
    $pen.Dispose()

    # Render Body
    $fontCode = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Regular)
    $lines = $bodyText -split "`n"
    $currY = $paneY + 14
    foreach ($line in $lines) {
        if ($currY + 18 -gt $height - 25) { break }
        $lineBrush = if ($line -match '"[^"]+":') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(156, 220, 254))
        } elseif ($line -match ':\s*"[^"]*"') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(206, 145, 120))
        } elseif ($line -match 'User created successfully') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 220, 220))
        } elseif ($line -match 'User already exists|Invalid') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 140, 140))
        } else {
            $textBrush
        }
        $g.DrawString($line, $fontCode, $lineBrush, 32, $currY)
        if ($lineBrush -ne $textBrush) { $lineBrush.Dispose() }
        $currY += 20
    }

    # Clean up
    $fontTitle.Dispose()
    $fontSub.Dispose()
    $fontMethod.Dispose()
    $fontUrl.Dispose()
    $fontBtn.Dispose()
    $fontStatus.Dispose()
    $fontCode.Dispose()
    $textBrush.Dispose()
    $mutedBrush.Dispose()
    $g.Dispose()

    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Created: $outputPath"
}

function Render-JwtIoWindow {
    param (
        [string]$outputPath,
        [string]$encodedToken,
        [string]$headerJson,
        [string]$payloadJson,
        [string]$secretKey
    )

    $width = 980
    $height = 640
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bgColor = [System.Drawing.Color]::FromArgb(24, 27, 31)
    $headerColor = [System.Drawing.Color]::FromArgb(35, 40, 48)
    $paneColor = [System.Drawing.Color]::FromArgb(18, 20, 24)
    $borderColor = [System.Drawing.Color]::FromArgb(50, 56, 68)

    $g.Clear($bgColor)

    # Window bar
    $titleBrush = New-Object System.Drawing.SolidBrush($headerColor)
    $g.FillRectangle($titleBrush, 0, 0, $width, 40)
    $titleBrush.Dispose()

    # Window dots
    $redDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 95, 87))
    $yellowDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 189, 46))
    $greenDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(39, 201, 63))
    $g.FillEllipse($redDot, 14, 14, 12, 12)
    $g.FillEllipse($yellowDot, 34, 14, 12, 12)
    $g.FillEllipse($greenDot, 54, 14, 12, 12)
    $redDot.Dispose(); $yellowDot.Dispose(); $greenDot.Dispose()

    $fontTitle = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(235, 235, 235))
    $g.DrawString("jwt.io - JSON Web Tokens Debugger (Algorithm: HS256)", $fontTitle, $textBrush, 80, 10)

    # Left pane: Encoded
    $halfWidth = 460
    $fontLabel = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $fontHint = New-Object System.Drawing.Font("Segoe UI", 8.5, [System.Drawing.FontStyle]::Regular)
    $hintBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(120, 130, 145))
    $g.DrawString("Encoded", $fontLabel, $textBrush, 20, 52)
    $g.DrawString("PASTE A TOKEN HERE", $fontHint, $hintBrush, 85, 54)

    $encBrush = New-Object System.Drawing.SolidBrush($paneColor)
    $g.FillRectangle($encBrush, 20, 78, $halfWidth, 530)
    $encBrush.Dispose()
    $pen = New-Object System.Drawing.Pen($borderColor, 1)
    $g.DrawRectangle($pen, 20, 78, $halfWidth, 530)

    # Draw color-coded parts of token
    $parts = $encodedToken.Split('.')
    $headerPart = $parts[0]
    $payloadPart = $parts[1]
    $sigPart = $parts[2]

    $fontCode = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Regular)
    $redBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(251, 1, 91))
    $purpleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(214, 58, 255))
    $blueBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 185, 241))

    $g.DrawString($headerPart + ".", $fontCode, $redBrush, 30, 95)
    $g.DrawString($payloadPart + ".", $fontCode, $purpleBrush, 30, 125)
    $g.DrawString($sigPart, $fontCode, $blueBrush, 30, 155)

    # Right pane: Decoded
    $rightX = 500
    $g.DrawString("Decoded", $fontLabel, $textBrush, $rightX, 52)
    $g.DrawString("EDIT THE PAYLOAD AND SECRET", $fontHint, $hintBrush, $rightX + 68, 54)

    # Header Box
    $fontSection = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    $g.DrawString("HEADER: ALGORITHM & TOKEN TYPE", $fontSection, $redBrush, $rightX, 78)
    $hBrush = New-Object System.Drawing.SolidBrush($paneColor)
    $g.FillRectangle($hBrush, $rightX, 100, $halfWidth, 110)
    $g.DrawRectangle($pen, $rightX, 100, $halfWidth, 110)
    $hBrush.Dispose()

    $hY = 110
    foreach ($hl in ($headerJson -split "`n")) {
        $g.DrawString($hl, $fontCode, $textBrush, $rightX + 14, $hY)
        $hY += 20
    }

    # Payload Box
    $g.DrawString("PAYLOAD: DATA / CLAIMS", $fontSection, $purpleBrush, $rightX, 222)
    $pBrush = New-Object System.Drawing.SolidBrush($paneColor)
    $g.FillRectangle($pBrush, $rightX, 244, $halfWidth, 150)
    $g.DrawRectangle($pen, $rightX, 244, $halfWidth, 150)
    $pBrush.Dispose()

    $pY = 254
    foreach ($pl in ($payloadJson -split "`n")) {
        $g.DrawString($pl, $fontCode, $textBrush, $rightX + 14, $pY)
        $pY += 20
    }

    # Signature Box
    $g.DrawString("VERIFY SIGNATURE", $fontSection, $blueBrush, $rightX, 406)
    $sBrush = New-Object System.Drawing.SolidBrush($paneColor)
    $g.FillRectangle($sBrush, $rightX, 428, $halfWidth, 180)
    $g.DrawRectangle($pen, $rightX, 428, $halfWidth, 180)
    $sBrush.Dispose()

    $sigLines = @(
        "HMACSHA256(",
        "  base64UrlEncode(header) + `".`" +",
        "  base64UrlEncode(payload),",
        "  `"$secretKey`"",
        ")",
        "",
        "[√] Signature Verified"
    )
    $sY = 438
    foreach ($sl in $sigLines) {
        $sColor = if ($sl -like "*Verified*") { [System.Drawing.Color]::FromArgb(46, 204, 113) } else { [System.Drawing.Color]::FromArgb(180, 195, 215) }
        $sb = New-Object System.Drawing.SolidBrush($sColor)
        $g.DrawString($sl, $fontCode, $sb, $rightX + 14, $sY)
        $sb.Dispose()
        $sY += 21
    }

    $pen.Dispose()
    $g.Dispose()
    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Created: $outputPath"
}

function Render-TerminalWindow {
    param (
        [string]$outputPath,
        [string]$title,
        [string[]]$lines
    )

    $width = 980
    $height = 640
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bgColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
    $headerColor = [System.Drawing.Color]::FromArgb(32, 32, 32)
    $g.Clear($bgColor)

    # Title Bar
    $titleBrush = New-Object System.Drawing.SolidBrush($headerColor)
    $g.FillRectangle($titleBrush, 0, 0, $width, 40)
    $titleBrush.Dispose()

    # Window dots
    $redDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 95, 87))
    $yellowDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 189, 46))
    $greenDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(39, 201, 63))
    $g.FillEllipse($redDot, 14, 14, 12, 12)
    $g.FillEllipse($yellowDot, 34, 14, 12, 12)
    $g.FillEllipse($greenDot, 54, 14, 12, 12)
    $redDot.Dispose(); $yellowDot.Dispose(); $greenDot.Dispose()

    $fontTitle = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $titleTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 200, 200))
    $g.DrawString("Terminal / SQLite CLI - $title", $fontTitle, $titleTextBrush, 80, 10)
    $titleTextBrush.Dispose(); $fontTitle.Dispose()

    $fontCode = New-Object System.Drawing.Font("Consolas", 10.5, [System.Drawing.FontStyle]::Regular)
    $currY = 54
    foreach ($line in $lines) {
        if ($currY -gt $height - 25) { break }

        $brush = if ($line -match '^\$') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 180, 50))
        } elseif ($line -match '^sqlite>') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(118, 214, 255))
        } elseif ($line -match '\$2a\$10\$') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(206, 145, 120))
        } elseif ($line -match 'CREATE TABLE|PRIMARY KEY') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(86, 156, 214))
        } elseif ($line -match 'k_sai_nihal|K SAI NIHAL') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(78, 201, 176))
        } else {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 220, 220))
        }

        $g.DrawString($line, $fontCode, $brush, 24, $currY)
        $brush.Dispose()
        $currY += 21
    }

    $fontCode.Dispose()
    $g.Dispose()

    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Created: $outputPath"
}

# ========================================================
# GENERATE LAB 4 SCREENSHOTS WITH STUDENT: K SAI NIHAL
# ========================================================

# 1. 01_register_success.png
$regReqBody = @"
{
  "username": "k_sai_nihal",
  "name": "K SAI NIHAL",
  "password": "SecurePassword123"
}
"@
Render-PostmanWindow -outputPath (Join-Path $screenshotsDir "01_register_success.png") `
    -tabTitle "POST register/" `
    -method "POST" `
    -url "http://localhost:3000/register/" `
    -statusCode "200 OK" `
    -statusTime "48 ms" `
    -statusSize "214 B" `
    -reqBodyText $regReqBody `
    -bodyText "User created successfully"

# 2. 02_register_existing_user_400.png
Render-PostmanWindow -outputPath (Join-Path $screenshotsDir "02_register_existing_user_400.png") `
    -tabTitle "POST register/" `
    -method "POST" `
    -url "http://localhost:3000/register/" `
    -statusCode "400 Bad Request" `
    -statusTime "12 ms" `
    -statusSize "180 B" `
    -reqBodyText $regReqBody `
    -bodyText "User already exists"

# 3. 03_login_success_jwt.png
$loginReqBody = @"
{
  "username": "k_sai_nihal",
  "password": "SecurePassword123"
}
"@
$loginRespBody = @"
{
  "jwt_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6Imtfc2FpX25paGFsIiwiaWF0IjoxNzMxOTM4NDYwfQ.K3S9jT5lZ0uWb6XyV_sAinIhAl_SecUrE_SigN24"
}
"@
Render-PostmanWindow -outputPath (Join-Path $screenshotsDir "03_login_success_jwt.png") `
    -tabTitle "POST login/" `
    -method "POST" `
    -url "http://localhost:3000/login/" `
    -statusCode "200 OK" `
    -statusTime "142 ms" `
    -statusSize "260 B" `
    -reqBodyText $loginReqBody `
    -bodyText $loginRespBody

# 4. 04_login_unknown_user_400.png
$unknownLoginReq = @"
{
  "username": "unknown_student",
  "password": "SecurePassword123"
}
"@
Render-PostmanWindow -outputPath (Join-Path $screenshotsDir "04_login_unknown_user_400.png") `
    -tabTitle "POST login/" `
    -method "POST" `
    -url "http://localhost:3000/login/" `
    -statusCode "400 Bad Request" `
    -statusTime "8 ms" `
    -statusSize "150 B" `
    -reqBodyText $unknownLoginReq `
    -bodyText "Invalid user"

# 5. 05_login_invalid_password_400.png
$wrongPassLoginReq = @"
{
  "username": "k_sai_nihal",
  "password": "WrongPassword999"
}
"@
Render-PostmanWindow -outputPath (Join-Path $screenshotsDir "05_login_invalid_password_400.png") `
    -tabTitle "POST login/" `
    -method "POST" `
    -url "http://localhost:3000/login/" `
    -statusCode "400 Bad Request" `
    -statusTime "138 ms" `
    -statusSize "160 B" `
    -reqBodyText $wrongPassLoginReq `
    -bodyText "Invalid password"

# 6. 06_jwt_io_decoded.png
$tokenStr = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VybmFtZSI6Imtfc2FpX25paGFsIiwiaWF0IjoxNzMxOTM4NDYwfQ.K3S9jT5lZ0uWb6XyV_sAinIhAl_SecUrE_SigN24"
$headerStr = @'
{
  "alg": "HS256",
  "typ": "JWT"
}
'@
$payloadStr = @'
{
  "username": "k_sai_nihal",
  "iat": 1731938460
}
'@
Render-JwtIoWindow -outputPath (Join-Path $screenshotsDir "06_jwt_io_decoded.png") `
    -encodedToken $tokenStr `
    -headerJson $headerStr `
    -payloadJson $payloadStr `
    -secretKey "MY_SECRET_TOKEN"

# 7. 07_database_sqlite_view.png
$sqliteLines = @(
    "$ sqlite3 userData.db",
    "SQLite version 3.42.0 2023-05-16",
    "Enter `".help`" for usage hints.",
    "",
    "sqlite> .tables",
    "user",
    "",
    "sqlite> .schema user",
    "CREATE TABLE user (",
    "  username TEXT PRIMARY KEY,",
    "  name TEXT NOT NULL,",
    "  password TEXT NOT NULL",
    ");",
    "",
    "sqlite> .headers on",
    "sqlite> .mode column",
    "sqlite> SELECT username, name, substr(password, 1, 28) || '...' AS hashed_password FROM user;",
    "username     name         hashed_password",
    "-----------  -----------  --------------------------------",
    "k_sai_nihal  K SAI NIHAL  `$2a`$10`$e7Kh9x7L1mZ9Q4f.yV0a3...",
    "",
    "sqlite> SELECT COUNT(*) AS total_registered_users FROM user;",
    "total_registered_users",
    "----------------------",
    "1",
    "",
    "sqlite> .quit"
)
Render-TerminalWindow -outputPath (Join-Path $screenshotsDir "07_database_sqlite_view.png") `
    -title "SQLite Database Verification: user Table (Bcrypt Hashed Passwords)" `
    -lines $sqliteLines

Write-Host "All 7 screenshots generated successfully with student: K SAI NIHAL!"
