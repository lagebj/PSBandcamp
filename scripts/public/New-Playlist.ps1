function New-Playlist {
    [OutputType([void],[BandcampSearch])]
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact = 'Medium',DefaultParameterSetName = 'Url')]

    Param (
        [Parameter(
            ParameterSetName = 'Url',
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = 'URL of artist/label to create playlist from. Currently only supports artist/label URLs.'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Url,

        [Parameter(
            ParameterSetName = 'Search',
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = 'Query to use for search.'
        )]
        [ValidateNotNullOrEmpty()]
        [string[]] $SearchQuery,

        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = 'Full path to new playlist.'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $FilePath,

        [Parameter(
            ParameterSetName = 'Search',
            Mandatory = $true,
            Position = 2,
            HelpMessage = 'What type of item you are searching for. Accepts values Artists, Albums and Tracks.'
        )]
        [ValidateSet('Artists','Albums','Tracks')]
        [BandcampSearchType] $SearchType,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open and play playlist after creation.'
        )]
        [switch] $StartPlaylist,

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return Bandcamp search as object.'
        )]
        [switch] $AsObject
    )

    [System.Management.Automation.ActionPreference] $ErrorActionPreference = [System.Management.Automation.ActionPreference]::Stop
    [System.Management.Automation.ActionPreference] $InformationPreference = [System.Management.Automation.ActionPreference]::Continue

    if (-not $PSBoundParameters.ContainsKey('Verbose')) { $VerbosePreference = $PSCmdlet.SessionState.PSVariable.GetValue('VerbosePreference') }
    if (-not $PSBoundParameters.ContainsKey('Confirm')) { $ConfirmPreference = $PSCmdlet.SessionState.PSVariable.GetValue('ConfirmPreference') }
    if (-not $PSBoundParameters.ContainsKey('WhatIf')) { $WhatIfPreference = $PSCmdlet.SessionState.PSVariable.GetValue('WhatIfPreference') }
    Write-Verbose -Message ('[{0}] Confirm={1} ConfirmPreference={2} WhatIf={3} WhatIfPreference={4}' -f $MyInvocation.MyCommand.Name, $Confirm, $ConfirmPreference, $WhatIf, $WhatIfPreference)

    if ($PSCmdlet.ShouldProcess($FilePath,'Creates new Xspf playlist from bandcamp')) {
        try {
            if ($PSBoundParameters.ContainsKey('Url')) {
                [BandcampSearch] $BandcampSearch = [BandcampSearch]::new($Url,$FilePath)
            } elseif ($PSBoundParameters.ContainsKey('SearchQuery')) {
                [BandcampSearch] $BandcampSearch = [BandcampSearch]::new($Query,$SearchType,$FilePath)
            }

            if ($PSBoundParameters.ContainsKey('StartPlaylist')) {
                Start-BandcampPlaylist -FilePath $FilePath -Random
            }

            if ($PSBoundParameters.ContainsKey('AsObject')) {
                return $BandcampSearch
            }
        } catch {
            $PSCmdlet.throwTerminatingError($PSItem)
        }
    }
}
