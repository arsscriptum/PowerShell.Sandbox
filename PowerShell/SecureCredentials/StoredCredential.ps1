


# simple password vault access class 
class StoredCredential{
    [System.Management.Automation.PSCredential] $PSCredential
    [string] $account;
    [string] $password;

    # loads credential from vault
    StoredCredential( [string] $name ){
        [void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime] 
        $vault = New-Object Windows.Security.Credentials.PasswordVault 
        $cred = $vault.FindAllByResource($name) | select -First 1
        $cred.retrievePassword()
        $this.account = $cred.userName
        $this.password = $cred.password 
        $pwd_ss = ConvertTo-SecureString $cred.password -AsPlainText -Force
        $this.PSCredential = New-Object System.Management.Automation.PSCredential ($this.account, $pwd_ss )
    }

    static [bool] Exists( [string] $name ){
        [void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime] 
        $vault = New-Object Windows.Security.Credentials.PasswordVault 
        try{
            $vault.FindAllByResource($name) 
        }
        catch{
            if ( $_.Exception.message -match "element not found" ){
                return $false
            }
            throw $_.exception
        }
        return $true
    }


    static [StoredCredential] Store( [string] $name, [string] $login, [string] $pwd ){
        [void][Windows.Security.Credentials.PasswordVault,Windows.Security.Credentials,ContentType=WindowsRuntime]
        $vault=New-Object Windows.Security.Credentials.PasswordVault
        $cred=New-Object Windows.Security.Credentials.PasswordCredential($name, $login, $pwd)
        $vault.Add($cred)
        return [StoredCredential]::new($name)
    }
    
    static [StoredCredential] Store( [string] $name, [PSCredential] $pscred ){
        return [StoredCredential]::Store( $name, $pscred.UserName, ($pscred.GetNetworkCredential()).Password )
    }

}  # class StoredCredential