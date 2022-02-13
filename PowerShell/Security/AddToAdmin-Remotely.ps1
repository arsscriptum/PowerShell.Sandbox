###################################################################################### 
#             Author: Vikas Sukhija 
#             Date:- 08/30/2014 
#              Description:- This script will add user to local admin 
#                       on remote server.  
###################################################################################### 
 

 https://gallery.technet.microsoft.com/scriptcenter/Add-User-to-Local-964db4d0

 
 https://techwizard.cloud/add-user-to-local-administrator-on-remote-machine/

 
#############ADD GUI Component###################################### 
 
function button ($title,$domain, $user, $Server) { 
 
[void][System.Reflection.Assembly]::LoadWithPartialName( "System.Windows.Forms")  
[void][System.Reflection.Assembly]::LoadWithPartialName( "Microsoft.VisualBasic")  
 
    $form = New-Object "System.Windows.Forms.Form"; 
    $form.Width = 500; 
    $form.Height = 150; 
    $form.Text = $title; 
    $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen; 
     
    $textLabel1 = New-Object "System.Windows.Forms.Label"; 
    $textLabel1.Left = 25; 
    $textLabel1.Top = 15; 
 
    $textLabel1.Text = $domain; 
 
    $textLabel2 = New-Object "System.Windows.Forms.Label"; 
    $textLabel2.Left = 25; 
    $textLabel2.Top = 50; 
     
    $textLabel2.Text = $user; 
 
    $textLabel3 = New-Object "System.Windows.Forms.Label"; 
    $textLabel3.Left = 25; 
    $textLabel3.Top = 85; 
  
    $textLabel3.Text = $Server; 
     
    $textBox1 = New-Object "System.Windows.Forms.TextBox"; 
    $textBox1.Left = 150; 
    $textBox1.Top = 10; 
    $textBox1.width = 200; 
 
    $textBox2 = New-Object "System.Windows.Forms.TextBox"; 
    $textBox2.Left = 150; 
    $textBox2.Top = 50; 
    $textBox2.width = 200; 
     
 
    $textBox3 = New-Object "System.Windows.Forms.TextBox"; 
    $textBox3.Left = 150; 
    $textBox3.Top = 90; 
    $textBox3.width = 200; 
     
    $defaultValue = "" 
    $textBox1.Text = $defaultValue; 
    $textBox2.Text = $defaultValue; 
    $textBox3.Text = $defaultValue; 
     
    $button = New-Object "System.Windows.Forms.Button"; 
    $button.Left = 360; 
    $button.Top = 85; 
    $button.Width = 100; 
    $button.Text = "Ok"; 
     
    $eventHandler = [System.EventHandler]{ 
    $textBox1.Text; 
    $textBox2.Text; 
    $textBox23.Text; 
    $form.Close();}; 
 
    $button.Add_Click($eventHandler) ; 
     
    $form.Controls.Add($button); 
    $form.Controls.Add($textLabel1); 
    $form.Controls.Add($textLabel2); 
    $form.Controls.Add($textLabel3); 
    $form.Controls.Add($textBox1); 
    $form.Controls.Add($textBox2); 
    $form.Controls.Add($textBox3); 
    $ret = $form.ShowDialog(); 
    return  $textBox1.Text, $textBox2.Text, $textBox3.Text 
} 
 
$return= button "Enter Parameters" "Enter Domain" "Enter User" "Enter Server" 
 
 
 
### Add Prameters returned from button  
$Domain = $return[0] 
$UserName = $return[1] 
$Computer = $return[2]  
 
## USe ADSI to connect to Remote Administrators group 
 
$Group = [ADSI]"WinNT://$Computer/Administrators,group" 
 
$User = [ADSI]"WinNT://$Domain/$UserName,user" 
 
$Group.Add($User.Path) 
 
if($error -ne $null) 
 { 
  (new-object -ComObject wscript.shell).Popup("$error",0,"Done",0x1) 
 } 
else 
 { 
 (new-object -ComObject wscript.shell).Popup("Operation Completed",0,"Done",0x1) 
  } 
 
##########################################################################################################