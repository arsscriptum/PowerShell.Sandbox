[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing") 
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
[void] [System.Windows.Forms.Application]::EnableVisualStyles()

function Service
{
Get-Service | select DisplayName, Status | Out-GridView
}


$Form = New-Object system.Windows.Forms.Form
$Form.Size = New-Object System.Drawing.Size(400,200)
#You can use the below method as well
#$Form.Width = 400
#$Form.Height = 200
$form.MaximizeBox = $false
$Form.StartPosition = "CenterScreen"
$Form.FormBorderStyle = 'Fixed3D'
$Form.Text = "My Application"

$Label = New-Object System.Windows.Forms.Label
$Label.Text = "This is My First Form"
$Label.AutoSize = $true
$Label.Location = New-Object System.Drawing.Size(75,50)
$Font = New-Object System.Drawing.Font("Arial",15,[System.Drawing.FontStyle]::Bold)
$form.Font = $Font
$Form.Controls.Add($Label)

#$formIcon = New-Object system.drawing.icon ("$env:USERPROFILE\desktop\Blog\v.ico")
#$form.Icon = $formicon

$Okbutton = New-Object System.Windows.Forms.Button
$Okbutton.Location = New-Object System.Drawing.Size(140,80)
$Okbutton.Size = New-Object System.Drawing.Size(120,30)
$Okbutton.Text = "SERVICES"
$Okbutton.Add_Click({service})
$Form.Controls.Add($Okbutton)

$Form.ShowDialog()
