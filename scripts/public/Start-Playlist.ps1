function Start-Playlist {
    [OutputType([void])]
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = 'Low')]

    Param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = 'Path of playlist file to play.'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $FilePath,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Start playlist with random switch.'
        )]
        [switch] $Random
    )

    [System.Management.Automation.ActionPreference] $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    [System.Management.Automation.ActionPreference] $InformationPreference = [System.Management.Automation.ActionPreference]::Continue

    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    Write-Verbose -Message ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand.Name, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)

    if ($PSCmdlet.ShouldProcess($FilePath,'Opens xspf playlist in VLC')) {
        try {
            if ($PSBoundParameters.ContainsKey('Random')) {
                [BandcampSearch]::new().StartVlc($FilePath,$true)
            } else {
                [BandcampSearch]::new().StartVlc($FilePath,$false)
            }
        } catch {
            $PSCmdlet.throwTerminatingError($PSItem)
        }
    }
}
