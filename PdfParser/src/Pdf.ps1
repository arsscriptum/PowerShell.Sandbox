



function ScriptException{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [System.Management.Automation.ErrorRecord]$Record,
        [Parameter(Mandatory=$false)]
        [switch]$ShowStack
    )       
    $Cmd = $Global:MyInvocation.MyCommand
    $CmdPath = $Global:MyInvocation.MyCommand.Path
    $CmdName = $Global:MyInvocation.MyCommand.Name
    Write-Host "[EXCEPTION RAISED ON COMMAND] " -nonewline -ForegroundColor DarkBlue; 
    Write-Host "$Cmd" -ForegroundColor DarkCyan
    $Url = "www.google.com/search?q=$Cmd"
    Start-Process $Url
    #Write-Host "[CmdPath] -> " -NoNewLine -ForegroundColor Red; 
    #Write-Host "$CmdPath" -ForegroundColor Yellow
    #Write-Host "[CmdName] -> " -NoNewLine -ForegroundColor Red; 
    #Write-Host "$CmdName" -ForegroundColor Yellow  
    $formatstring = "{0}`n{1}"
    $fields = $Record.FullyQualifiedErrorId,$Record.Exception.ToString()
    $ExceptMsg=($formatstring -f $fields)
    $Stack=$Record.ScriptStackTrace
    Write-Host "[ERROR] -> " -NoNewLine -ForegroundColor Red; 
    Write-Host "$ExceptMsg" -ForegroundColor Yellow
    if($ShowStack){
        Write-Host "--stack begin--" -ForegroundColor Green
        Write-Host "$Stack" -ForegroundColor Gray  
        Write-Host "--stack end--`n" -ForegroundColor Green       
    }
}   

function ProcessPath{
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true)]
        [String]$Path,
        [Parameter(Mandatory=$true)]
        [String]$Year
    ) 
        $pdfs = (gci $Path -Filter '*.pdf' -File).Fullname
        $export = (New-TemporaryFile).Fullname
        $results = @()
        $Month = ''
        $keywords = @('JuliaJeon')
        #$keywords += $Pattern
        [int]$TotalAmmount = 0
        [int]$TotalVirements = 0


        foreach($pdf in $pdfs) {
            $pdf = "$pdf"
            $pdfname = $pdf
            # prepare the pdf
            $reader = New-Object iTextSharp.text.pdf.pdfreader -ArgumentList "$pdfname"
            $Basename = (Get-Item $pdfname).Basename
            $Month = $Basename
            $pageNum = $reader.NumberOfPages
            Write-Host "[$Basename] " -f White -NoNewLine 
            Write-Host "$pageNum pages..." -f DarkGray

            [int]$NumVirement = 0
            [int]$SubTotal = 0
            # for each page
            for($page = 1; $page -le $reader.NumberOfPages; $page++) {

                # set the page text
                $pageText = [iTextSharp.text.pdf.parser.PdfTextExtractor]::GetTextFromPage($reader,$page).Split([char]0x000A)
                $show = $false
                
                ForEach($val in $pageText){
                    if(($val -match 'X*Virementenvoyé') -And ($val -match 'X*JuliaJeon')) {
                        $NumVirement++
                        $TotalVirements++
                        #Write-Host "[$NumVirement] Virement: " -f DarkRed -NoNewLine
                        #Write-Host "$val" -f DarkYellow
                        $Array = $val.Split(' ')
                        $index = $Array.IndexOf('JuliaJeon')
                        $index++
                        [string]$StrValue = $Array[$index]
                        [int]$Ammount = [decimal]$StrValue.Replace(",", ".")
                        [int]$SubTotal += $Ammount
                        [int]$TotalAmmount += $Ammount
                    }
                }             
            }
            Write-Host "For the month $Month " -f DarkRed -NoNewLine
            Write-Host "$NumVirement $SubTotal `$" -f DarkYellow
            Write-Host "Total: " -f DarkRed -NoNewLine
            Write-Host "$TotalVirements, $TotalAmmount `$" -f DarkYellow
        
        }


}


function Search-PdfFolder {
    <#
    .SYNOPSIS
            Create a download job
    .DESCRIPTION
            Create a download job
#>

    [CmdletBinding(SupportsShouldProcess)]
    param()
    <#    [Parameter(Mandatory=$true,Position=0)]
        [string]$Path,
        [Parameter(Mandatory=$false,Position=1)]
        [string]$Pattern=""
    )#>
    try{
         Add-Type -Path 'C:\Scripts\Modules\CodeCastor.PowerShell.PdfParser\libs\BouncyCastle.Crypto.dll'
         Add-Type -Path 'C:\Scripts\Modules\CodeCastor.PowerShell.PdfParser\libs\itextsharp.dll'
        $PdfPath2020='C:\Scripts\Modules\CodeCastor.PowerShell.PdfParser\Data\2020'
        $PdfPath2021='C:\Scripts\Modules\CodeCastor.PowerShell.PdfParser\Data\2021'

        ProcessPath $PdfPath2020
        
        ProcessPath $PdfPath2021



  }
  catch{
        Write-Error $_
        ScriptException $_  -ShowStack
        return $null
    }
}
