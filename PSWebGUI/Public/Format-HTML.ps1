function Format-Html {

    [CmdletBinding(DefaultParameterSetName="Table")]
    param (
        [Parameter(Mandatory=$true,ValueFromPipeline,Position=0)][psobject]$InputObject,
        
        [Parameter(ParameterSetName="Table",Mandatory=$false)][Alias("Tabledark","Table-dark")][switch]$Darktable,
        [Parameter(ParameterSetName="Table",Mandatory=$false)][Alias("Theaddark","Thead-dark")][switch]$Darkheader,
        [Parameter(ParameterSetName="Table",Mandatory=$false)][switch]$Striped,
        [Parameter(ParameterSetName="Table",Mandatory=$false)][switch]$Hover,
        [Parameter(ParameterSetName="Table",Mandatory=$false)][string]$Id,
        [Parameter(ParameterSetName="Table",Mandatory=$false)][switch]$Filter,

        [Parameter(ParameterSetName="Cards",Mandatory=$true)][ValidateRange(1,6)][int]$Cards,

        [Parameter(ParameterSetName="Raw",Mandatory=$true)][switch]$Raw

    )
    
    # Initializes variable that will contain the output of the pipeline command
    Begin{
        $result=@()
    }

    # Store each command output
    Process{
        $result+=$InputObject
    }


    End{
        
        # If -Raw parameter is set, displays the command output directly
        if ($Raw){
            $result


        #region Process and stylize command output
        <#
        ===================================================================
                          Process and stylize command output
        ===================================================================
        #>
        }else{

            # Get all properties of the object passed
            $objs=$result | Select-Object -Property *

            # Get only property names (headers)
            $headers=$objs[0] | ForEach-Object {$_.psobject.properties.name}

            #region Process switch parameters
            <#
            ===================================================================
                                  Process switch parameters
            ===================================================================
            #>
            $tableClass="table"

            if ($Darktable){
                $tableClass+=" table-dark"

            }elseif ($Darkheader){
                $theaddark="class='thead-dark'"
            }

            if ($Striped){
                $tableClass+=" table-striped"
            }

            if ($Hover){
                $tableClass+=" table-hover"
            }

            if ($Id){
                $idTag="id='$id'"
            }
            #endregion



            #region Card layout
            <#
            ===================================================================
                                      Card layout
            ===================================================================
            #>
            if (($cards -ge 1) -and ($Cards -le 6)){
                              
                "<div class='row row-cols-$Cards'>"

                # For each row in CSV displays a bootstrap card
                foreach ($obj in $objs){
                    
                    "<div class='card col'>
		                <div class='card-body'>
			                <h5 class='card-title'>"+$obj.($headers[0])+"</h5>
			                <p class='card-text'>"+$obj.($headers[1])+"</p>
		                </div>
		            </div>"  

                }

                "</div>"
                
            }
            #endregion



            #region Table layout
            <#
            ===================================================================
                                      Table layout
            ===================================================================
            #>
            else{
                if ($Filter){
                    Get-Content "$PSScriptRoot\Assets\tableFilter.html"
                    
                }
                "<table class='$tableClass' $idTag>"
                "<thead $theaddark>"
                "<tr>"

                # Get all property names for table headers
                foreach ($header in $headers){
                    "<th>"+$header+"</th>"
                }
                "</tr>"
                "</thead>"

                "<tbody>"

                # For each row in CSV add a table row
                foreach ($obj in $objs){
                    "<tr>"

                    # For each CSV property name gets associated value (within a row)
                    foreach ($header in $headers){
                        "<td>"+$obj.$header+"</td>"
                    }
                    "</tr>"

                }
                "</tbody>"
                "</table>"
            }
            #endregion
        }
        #endregion
    }
}