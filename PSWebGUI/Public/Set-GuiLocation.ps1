function Set-GuiLocation{

    param(
        [Parameter(Mandatory=$true,Position=0,ValueFromPipeline=$true)]
        [ValidatePattern("^\/(([A-z0-9\-\%]+\/)*[A-z0-9\-\%]+$)?")]
        [Alias("Location","Path")]
        [string]$URL
    )

    '<script>window.location.href="'+$URL+'"</script>'
}