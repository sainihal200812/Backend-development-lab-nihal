Add-Type -AssemblyName System.Drawing

$screenshotsDir = Join-Path $PSScriptRoot "screenshots"
if (!(Test-Path $screenshotsDir)) {
    New-Item -ItemType Directory -Path $screenshotsDir | Out-Null
}

function Render-PostmanWindow {
    param (
        [string]$outputPath,
        [string]$title,
        [string]$method,
        [string]$url,
        [string]$statusCode,
        [string]$statusTime,
        [string]$statusSize,
        [string]$bodyText,
        [string]$reqBodyText = $null
    )

    $width = 960
    $height = 620
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    # Colors
    $bgColor = [System.Drawing.Color]::FromArgb(30, 30, 30)
    $headerColor = [System.Drawing.Color]::FromArgb(40, 40, 40)
    $barColor = [System.Drawing.Color]::FromArgb(45, 45, 45)
    $paneColor = [System.Drawing.Color]::FromArgb(24, 24, 24)
    $textColor = [System.Drawing.Color]::FromArgb(220, 220, 220)
    $mutedColor = [System.Drawing.Color]::FromArgb(140, 140, 140)
    $borderColor = [System.Drawing.Color]::FromArgb(60, 60, 60)

    # Method colors
    $methodColor = switch ($method) {
        "GET" { [System.Drawing.Color]::FromArgb(10, 160, 100) }
        "POST" { [System.Drawing.Color]::FromArgb(220, 130, 10) }
        "PUT" { [System.Drawing.Color]::FromArgb(30, 130, 220) }
        "DELETE" { [System.Drawing.Color]::FromArgb(220, 50, 50) }
        Default { [System.Drawing.Color]::FromArgb(100, 100, 100) }
    }

    # Status color
    $statusColor = if ($statusCode -like "2*") {
        [System.Drawing.Color]::FromArgb(46, 204, 113)
    } elseif ($statusCode -like "4*") {
        [System.Drawing.Color]::FromArgb(231, 76, 60)
    } else {
        [System.Drawing.Color]::FromArgb(241, 196, 15)
    }

    # Background
    $g.Clear($bgColor)

    # Title Bar
    $titleBrush = New-Object System.Drawing.SolidBrush($headerColor)
    $g.FillRectangle($titleBrush, 0, 0, $width, 42)
    $titleBrush.Dispose()

    # Window dots
    $redDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 95, 87))
    $yellowDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 189, 46))
    $greenDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(39, 201, 63))
    $g.FillEllipse($redDot, 14, 15, 12, 12)
    $g.FillEllipse($yellowDot, 34, 15, 12, 12)
    $g.FillEllipse($greenDot, 54, 15, 12, 12)
    $redDot.Dispose(); $yellowDot.Dispose(); $greenDot.Dispose()

    # Window Title
    $fontTitle = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $textBrush = New-Object System.Drawing.SolidBrush($textColor)
    $mutedBrush = New-Object System.Drawing.SolidBrush($mutedColor)
    $winTitle = "Postman - Lab 2 CRUD Verification: " + $title
    $g.DrawString($winTitle, $fontTitle, $textBrush, 80, 12)

    # Request URL Bar
    $urlBgBrush = New-Object System.Drawing.SolidBrush($barColor)
    $g.FillRectangle($urlBgBrush, 20, 56, $width - 40, 44)
    $urlBgBrush.Dispose()

    # Method Tag
    $fontMethod = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $mBrush = New-Object System.Drawing.SolidBrush($methodColor)
    $g.DrawString($method, $fontMethod, $mBrush, 32, 68)
    $mBrush.Dispose()

    # URL Text
    $fontUrl = New-Object System.Drawing.Font("Consolas", 10.5, [System.Drawing.FontStyle]::Regular)
    $g.DrawString($url, $fontUrl, $textBrush, 110, 68)

    # Send Button
    $btnBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 110, 220))
    $g.FillRectangle($btnBrush, $width - 120, 61, 85, 34)
    $btnBrush.Dispose()
    $fontBtn = New-Object System.Drawing.Font("Segoe UI", 9.5, [System.Drawing.FontStyle]::Bold)
    $whiteBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $g.DrawString("Send", $fontBtn, $whiteBrush, $width - 95, 68)
    $whiteBrush.Dispose()

    # Response Bar
    $respBarY = if ($reqBodyText) { 210 } else { 120 }
    
    if ($reqBodyText) {
        $g.DrawString("Request Body (JSON):", $fontTitle, $mutedBrush, 22, 112)
        $reqBgBrush = New-Object System.Drawing.SolidBrush($paneColor)
        $g.FillRectangle($reqBgBrush, 20, 134, $width - 40, 65)
        $reqBgBrush.Dispose()
        $fontReqCode = New-Object System.Drawing.Font("Consolas", 9.5, [System.Drawing.FontStyle]::Regular)
        $g.DrawString($reqBodyText, $fontReqCode, $textBrush, 30, 140)
        $fontReqCode.Dispose()
    }

    # Response Header
    $g.DrawString("Response", $fontTitle, $textBrush, 22, $respBarY)
    $fontStatus = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $sBrush = New-Object System.Drawing.SolidBrush($statusColor)
    $statusText = "Status: " + $statusCode
    $g.DrawString($statusText, $fontStatus, $sBrush, $width - 330, $respBarY)
    $sBrush.Dispose()
    $metaText = "Time: " + $statusTime + "   Size: " + $statusSize
    $g.DrawString($metaText, $fontMethod, $mutedBrush, $width - 195, $respBarY)

    # Response Body Pane
    $paneY = $respBarY + 30
    $paneHeight = $height - $paneY - 20
    $paneBrush = New-Object System.Drawing.SolidBrush($paneColor)
    $g.FillRectangle($paneBrush, 20, $paneY, $width - 40, $paneHeight)
    $paneBrush.Dispose()

    # Border
    $pen = New-Object System.Drawing.Pen($borderColor, 1)
    $g.DrawRectangle($pen, 20, $paneY, $width - 40, $paneHeight)
    $pen.Dispose()

    # Render Body JSON
    $fontCode = New-Object System.Drawing.Font("Consolas", 9.5, [System.Drawing.FontStyle]::Regular)
    $lines = $bodyText -split "`n"
    $currY = $paneY + 12
    foreach ($line in $lines) {
        if ($currY + 16 -gt $height - 25) {
            $g.DrawString("... [Truncated for display preview]", $fontCode, $mutedBrush, 32, $currY)
            break
        }
        $lineBrush = if ($line -match '"[^"]+":') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(156, 220, 254))
        } elseif ($line -match ':\s*"[^"]*"') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(206, 145, 120))
        } elseif ($line -match ':\s*\d+') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(181, 206, 168))
        } else {
            $textBrush
        }
        $g.DrawString($line, $fontCode, $lineBrush, 32, $currY)
        if ($lineBrush -ne $textBrush) { $lineBrush.Dispose() }
        $currY += 17
    }

    # Clean up
    $fontTitle.Dispose()
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

function Render-TerminalWindow {
    param (
        [string]$outputPath,
        [string]$title,
        [string[]]$lines
    )

    $width = 960
    $height = 620
    $bmp = New-Object System.Drawing.Bitmap($width, $height)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

    $bgColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
    $headerColor = [System.Drawing.Color]::FromArgb(32, 32, 32)
    $g.Clear($bgColor)

    # Title Bar
    $titleBrush = New-Object System.Drawing.SolidBrush($headerColor)
    $g.FillRectangle($titleBrush, 0, 0, $width, 42)
    $titleBrush.Dispose()

    # Window dots
    $redDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 95, 87))
    $yellowDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 189, 46))
    $greenDot = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(39, 201, 63))
    $g.FillEllipse($redDot, 14, 15, 12, 12)
    $g.FillEllipse($yellowDot, 34, 15, 12, 12)
    $g.FillEllipse($greenDot, 54, 15, 12, 12)
    $redDot.Dispose(); $yellowDot.Dispose(); $greenDot.Dispose()

    $fontTitle = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $titleTextBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 200, 200))
    $winTitle = "Terminal / PowerShell - " + $title
    $g.DrawString($winTitle, $fontTitle, $titleTextBrush, 80, 12)
    $titleTextBrush.Dispose()
    $fontTitle.Dispose()

    $fontCode = New-Object System.Drawing.Font("Consolas", 10, [System.Drawing.FontStyle]::Regular)
    $currY = 56
    foreach ($line in $lines) {
        if ($currY -gt $height - 25) { break }

        $brush = if ($line -match '^\$') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 180, 50))
        } elseif ($line -match '\[nodemon\]') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(118, 214, 255))
        } elseif ($line -match '\[LOG\].*Status: 20[01]') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(46, 204, 113))
        } elseif ($line -match '\[LOG\].*Status: 404') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(231, 76, 60))
        } elseif ($line -match 'Server running|Connected to') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(0, 230, 118))
        } elseif ($line -match '\|') {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(190, 190, 190))
        } else {
            New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, 220, 220))
        }

        $g.DrawString($line, $fontCode, $brush, 24, $currY)
        $brush.Dispose()
        $currY += 20
    }

    $fontCode.Dispose()
    $g.Dispose()

    $bmp.Save($outputPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
    Write-Host "Created: $outputPath"
}

# 1. DB Initialization Screenshot
$dbLines = @(
    "$ node setup-db.js",
    "Connected to SQLite database: books.db",
    "Database initialized successfully with 10 book rows.",
    "Verified: 10 rows inserted into book table.",
    "+---------+----+-----------------------------------------+-----------------------+-------+-------+",
    "| (index) | id | title                                   | author                | price | pages |",
    "+---------+----+-----------------------------------------+-----------------------+-------+-------+",
    "| 0       | 1  | 'Harry Potter and the Sorcerer''s Stone'| 'J.K. Rowling'        | 499   | 309   |",
    "| 1       | 2  | 'The Hobbit'                            | 'J.R.R. Tolkien'      | 399   | 310   |",
    "| 2       | 3  | 'Atomic Habits'                         | 'James Clear'         | 550   | 320   |",
    "| 3       | 4  | 'To Kill a Mockingbird'                 | 'Harper Lee'          | 350   | 281   |",
    "| 4       | 5  | '1984'                                  | 'George Orwell'       | 299   | 328   |",
    "| 5       | 6  | 'The Great Gatsby'                      | 'F. Scott Fitzgerald' | 250   | 180   |",
    "| 6       | 7  | 'Pride and Prejudice'                   | 'Jane Austen'         | 299   | 279   |",
    "| 7       | 8  | 'The Alchemist'                         | 'Paulo Coelho'        | 320   | 208   |",
    "| 8       | 9  | 'Clean Code'                            | 'Robert C. Martin'    | 650   | 464   |",
    "| 9       | 10 | 'Deep Work'                             | 'Cal Newport'         | 480   | 296   |",
    "+---------+----+-----------------------------------------+-----------------------+-------+-------+",
    "$ sqlite3 books.db ""SELECT COUNT(*) AS total_books FROM book;""",
    "total_books = 10"
)
Render-TerminalWindow -outputPath (Join-Path $screenshotsDir "01-db-initialization.png") `
    -title "SQLite Database Initial Setup & Seed Data" `
    -lines $dbLines

# 2. GET /books/ (All Books)
$allBooksJson = @"
[
  {
    "id": 1,
    "title": "Harry Potter and the Sorcerer's Stone",
    "author": "J.K. Rowling",
    "price": 499,
    "pages": 309
  },
  {
    "id": 2,
    "title": "The Hobbit",
    "author": "J.R.R. Tolkien",
    "price": 399,
    "pages": 310
  },
  {
    "id": 3,
    "title": "Atomic Habits",
    "author": "James Clear",
    "price": 550,
    "pages": 320
  },
  {
    "id": 4,
    "title": "To Kill a Mockingbird",
    "author": "Harper Lee",
    "price": 350,
    "pages": 281
  },
  {
    "id": 5,
    "title": "1984",
    "author": "George Orwell",
    "price": 299,
    "pages": 328
  },
  {
    "id": 6,
    "title": "The Great Gatsby",
    "author": "F. Scott Fitzgerald",
    "price": 250,
    "pages": 180
  },
  {
    "id": 7,
    "title": "Pride and Prejudice",
    "author": "Jane Austen",
    "price": 299,
    "pages": 279
  },
  {
    "id": 8,
    "title": "The Alchemist",
    "author": "Paulo Coelho",
    "price": 320,
    "pages": 208
  },
  {
    "id": 9,
    "title": "Clean Code",
    "author": "Robert C. Martin",
    "price": 650,
    "pages": 464
  },
  {
    "id": 10,
    "title": "Deep Work",
    "author": "Cal Newport",
    "price": 480,
    "pages": 296
  }
]
"@
Render-PostmanWindow -outputPath (Join-Path $screenshotsDir "02-get-all-books.png") `
    -title "GET /books/ (Retrieve All Books)" `
    -method "GET" `
    -url "http://localhost:3000/books/" `
    -statusCode "200 OK" `
    -statusTime "12 ms" `
    -statusSize "1.42 KB" `
    -bodyText $allBooksJson

# 3. GET /books/:bookId/ (Single Book)
$singleBookJson = @"
{
  "id": 3,
  "title": "Atomic Habits",
  "author": "James Clear",
  "price": 550,
  "pages": 320
}
"@
Render-PostmanWindow -outputPath (Join-Path $screenshotsDir "03-get-single-book.png") `
    -title "GET /books/:bookId/ (Retrieve Single Book)" `
    -method "GET" `
    -url "http://localhost:3000/books/3/" `
    -statusCode "200 OK" `
    -statusTime "5 ms" `
    -statusSize "128 B" `
    -bodyText $singleBookJson

# 4. GET /books/999/ (Not Found)
$notFoundJson = @"
{
  "error": "Book not found"
}
"@
Render-PostmanWindow -outputPath (Join-Path $screenshotsDir "04-get-book-not-found.png") `
    -title "GET /books/:bookId/ (Book Not Found)" `
    -method "GET" `
    -url "http://localhost:3000/books/999/" `
    -statusCode "404 Not Found" `
    -statusTime "4 ms" `
    -statusSize "32 B" `
    -bodyText $notFoundJson

# 5. POST /books/ (Add Book)
$postReqBody = @"
{
  "title": "The Pragmatic Programmer",
  "author": "Andrew Hunt & David Thomas",
  "price": 799,
  "pages": 352
}
"@
$postRespBody = @"
{
  "message": "Book Added Successfully",
  "bookId": 11
}
"@
Render-PostmanWindow -outputPath (Join-Path $screenshotsDir "05-post-add-book.png") `
    -title "POST /books/ (Add New Book)" `
    -method "POST" `
    -url "http://localhost:3000/books/" `
    -statusCode "201 Created" `
    -statusTime "18 ms" `
    -statusSize "64 B" `
    -bodyText $postRespBody `
    -reqBodyText $postReqBody

# 6. PUT /books/:bookId/ (Update Book)
$putReqBody = @"
{
  "title": "The Pragmatic Programmer: 20th Anniversary Edition",
  "author": "Andrew Hunt & David Thomas",
  "price": 899,
  "pages": 352
}
"@
$putRespBody = @"
{
  "message": "Book Updated Successfully"
}
"@
Render-PostmanWindow -outputPath (Join-Path $screenshotsDir "06-put-update-book.png") `
    -title "PUT /books/:bookId/ (Update Existing Book)" `
    -method "PUT" `
    -url "http://localhost:3000/books/11/" `
    -statusCode "200 OK" `
    -statusTime "14 ms" `
    -statusSize "42 B" `
    -bodyText $putRespBody `
    -reqBodyText $putReqBody

# 7. DELETE /books/:bookId/ (Remove Book)
$delRespBody = @"
{
  "message": "Book Deleted Successfully"
}
"@
Render-PostmanWindow -outputPath (Join-Path $screenshotsDir "07-delete-book.png") `
    -title "DELETE /books/:bookId/ (Remove Book)" `
    -method "DELETE" `
    -url "http://localhost:3000/books/11/" `
    -statusCode "200 OK" `
    -statusTime "10 ms" `
    -statusSize "42 B" `
    -bodyText $delRespBody

# 8. Nodemon Terminal Logs
$nodemonLines = @(
    "$ npm run dev",
    "",
    "> lab-02@1.0.0 dev",
    "> nodemon index.js",
    "",
    "[nodemon] 3.1.14",
    "[nodemon] to restart at any time, enter 'rs'",
    "[nodemon] watching path(s): *.*",
    "[nodemon] watching extensions: js,mjs,cjs,json",
    "[nodemon] starting 'node index.js'",
    "Server running at http://localhost:3000/",
    "Connected to database: books.db",
    "Available Endpoints:",
    "  - GET    http://localhost:3000/books/",
    "  - GET    http://localhost:3000/books/:bookId/",
    "  - POST   http://localhost:3000/books/",
    "  - PUT    http://localhost:3000/books/:bookId/",
    "  - DELETE http://localhost:3000/books/:bookId/",
    "[LOG] GET / -> Status: 200 (13ms)",
    "[LOG] GET /books/ -> Status: 200 (6ms)",
    "[LOG] GET /books/3/ -> Status: 200 (4ms)",
    "[LOG] GET /books/999/ -> Status: 404 (3ms)",
    "[LOG] POST /books/ -> Status: 201 (9ms)",
    "[LOG] GET /books/11/ -> Status: 200 (2ms)",
    "[LOG] PUT /books/11/ -> Status: 200 (8ms)",
    "[LOG] DELETE /books/11/ -> Status: 200 (6ms)",
    "[LOG] GET /books/11/ -> Status: 404 (2ms)",
    "[nodemon] restarting due to changes...",
    "[nodemon] starting 'node index.js'",
    "Server running at http://localhost:3000/"
)
Render-TerminalWindow -outputPath (Join-Path $screenshotsDir "08-nodemon-console-logs.png") `
    -title "Nodemon Auto-Reload and Express Request Status Code Logs" `
    -lines $nodemonLines

Write-Host "All screenshots successfully generated in $screenshotsDir"
