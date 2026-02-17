function Get-CredentialForm {
    
    # Get username and password from form
    $username=$_POST["userName"]
    $password=ConvertTo-SecureString $_POST["Password"] -AsPlainText -Force

    # Create the credential psobject
    $credential= New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $username,$password

    return $credential

}