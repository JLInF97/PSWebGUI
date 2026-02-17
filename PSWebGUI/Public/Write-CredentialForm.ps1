function Write-CredentialForm {
    
    param(
        [Parameter(Mandatory=$false)][string]$Title="Credential input",
        [Parameter(Mandatory=$false)][string]$Description="Enter your credential",
        [Parameter(Mandatory=$false)][ValidatePattern("^\/(([A-z0-9\-\%]+\/)*[A-z0-9\-\%]+$)?")][string]$Action,
        [Parameter(Mandatory=$false)][string]$UsernameLabel="Enter your username",
        [Parameter(Mandatory=$false)][string]$PasswordLabel="Enter your pasword",
        [Parameter(Mandatory=$false)][string]$SubmitLabel="Submit"
    )

    Set-Title -Title $Title

    "
    <div class='container'>
        <h2 class='mt-3'>$Title</h2>
        <p>$Description</p>

        <form method='post' action=$action>
            <div class='form-group'>
                <label for='usernameInput'>$UsernameLabel</label>
                <input type='text' class='form-control' id='usernameInput' name='userName' autofocus>
            </div>

            <div class='form-group'>
                <label for='passwordInput'>$PasswordLabel</label>
                <input type='password' class='form-control' id='passwordInput' name='Password'>
            </div>

            <button type='submit' class='btn btn-primary'>$SubmitLabel</button>
        </form>
    </div>
    "
}