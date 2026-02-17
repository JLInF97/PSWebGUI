function Set-Title {
    
    param (
    [Parameter(Mandatory=$true)][string]$Title
    )

    # Write javascript to inmdiately change page title. Only in web browser
    "<script>document.title='$Title'</script>"

}