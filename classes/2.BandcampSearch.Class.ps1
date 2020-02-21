class BandcampSearch {
    hidden [string] $RootUrl = 'https://bandcamp.com'
    [System.Collections.Generic.List[string]] $Artists = @()
    [System.Collections.Generic.List[string]] $Albums = @()
    [System.Collections.Generic.List[string]] $Tracks = @()

    BandcampSearch() {}

    BandcampSearch([string] $Url, [string] $XspfFilePath) {
        $this.PopulateFromUrl($Url)

        [xml] $Xspf = $this.CreateXspf('Artists')

        $Xspf.Save($XspfFilePath)
    }

    BandcampSearch([string[]] $Query, [BandcampSearchType] $SearchType, [string] $XspfFilePath) {
        if ($SearchType -is [BandcampSearchType]) {
            $this.ExecuteSearch($Query)

            [xml] $Xspf = $this.CreateXspf($SearchType)

            $Xspf.Save($XspfFilePath)
        } else {
            throw [System.Management.Automation.ArgumentTransformationMetadataException]::new("Cannot convert value `"$SearchType`" to type `"$([BandcampSearchType].Name)`". Error: `"Unable to match the identifier name arts to a valid enumerator name. Specify one of the following enumerator names and try again: Artists, Albums, Tracks`"")
        }
    }

    hidden [void] Clear() {
        $this.Artists = @()
        $this.Albums = @()
        $this.Tracks = @()
    }

    hidden [void] TrimLinks([string[]] $Hrefs) {
        [regex] $ArtistPattern = [regex]::new('(https:\/\/.*\.bandcamp.com)')
        [regex] $AlbumPattern = [regex]::new('(https:\/\/.*\.bandcamp.com\/album\/.*(?=\?))')
        [regex] $TrackPattern = [regex]::new('(https:\/\/.*\.bandcamp.com\/track\/.*(?=\?))')

        foreach ($Link in $Hrefs) {
            switch -Regex ($Link) {
                $ArtistPattern {
                    foreach ($Match in $Matches.Values) {
                        $this.Artists.Add($Match)
                    }
                }
                $AlbumPattern {
                    foreach ($Match in $Matches.Values) {
                        $this.Albums.Add($Match)
                    }
                }
                $TrackPattern {
                    foreach ($Match in $Matches.Values) {
                        $this.Tracks.Add($Match)
                    }
                }
            }
        }

        $this.RemoveDuplicates()
    }

    hidden [void] RemoveDuplicates() {
        $this.Artists = $this.Artists | Select-Object -Unique
        $this.Albums = $this.Albums | Select-Object -Unique
        $this.Tracks = $this.Tracks | Select-Object -Unique
    }

    hidden [int] GetSearchResultPages([string[]] $Hrefs) {
        [regex] $Pattern = [regex]::new('(?<=\?page\=)\d(?=\&amp;q=.*)')
        [int[]] $PageNumbers = [regex]::Matches($Hrefs, $Pattern).Value

        return ($PageNumbers | Sort-Object -Bottom 1)
    }

    hidden [string] CreateQueryString([string] $Query, [System.Nullable[int]] $Page) {
        [string] $Query = [System.Web.HttpUtility]::UrlEncode($Query)

        if (-not ($null -eq $Page)) {
            return $('/search?q=' + $Query + '&page=' + $Page)
        }

        return $('/search?q=' + $Query)
    }

    hidden [string] TrimBandLink([string] $Href) {
        [regex] $Pattern = [regex]::new('https\:\/\/.*\.com(?=\/.*|)')
        [string] $BandLink = [regex]::Match($Href, $Pattern).Value

        return $BandLink
    }

    [void] ExecuteSearch ([string[]] $Query) {
        [System.Collections.Generic.List[Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject]] $Results = @()
        foreach ($String in $Query) {
            [Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject] $Response = Invoke-WebRequest $($this.RootUrl + $this.CreateQueryString($String, $null))
            [int] $NumberOfSearchPages = $this.GetSearchResultPages($Response.Links.Href)

            $Results.Add($Response)

            if ($NumberOfSearchPages -gt 1) {
                for ($i = 2; $i -le $NumberOfSearchPages; $i++) {
                    $Results.Add((Invoke-WebRequest $($this.RootUrl + $this.CreateQueryString($String, $i))))
                }
            }
        }

        $this.TrimLinks($Results.Links.Href)
    }

    hidden [void] PopulateFromUrl ([string] $Url) {
        $this.Artists.Add($Url)
    }

    hidden [PSCustomObject[]] GetTracks ([string[]] $Links) {
        [System.Collections.Generic.List[PSCustomObject]] $TrackList = @()

        foreach ($Url in $Links) {
            [string] $BandLink = $this.TrimBandLink($Url)

            [Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject] $Response = Invoke-WebRequest -Uri $Url

            if ($Url -like "*/track/*") {
                [regex] $Pattern = [regex]::new('(?<=var\sTralbumData\s\=\s).*package_associated_license_id.*\n\}(?=;.*var\sP)')

                [PSCustomObject[]] $TrackArray = [regex]::Matches($Response.RawContent, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline).Value | ConvertFrom-Json -ErrorAction SilentlyContinue
            } else {
                [regex] $Pattern = [regex]::new('(?<=var\sTralbumData\s\=\s)\{.*tralbum_collect_info.*\}\n\}(?=;)')

                [string] $Json = [regex]::Matches($Response.RawContent, $Pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline).Value

                [regex] $ReplacementPattern = [regex]::new('url\:\s.*')
                [PSCustomObject[]] $TrackArray = $Json -replace $ReplacementPattern,$null | ConvertFrom-Json
            }

            foreach ($Track in $TrackArray) {
                $Track | Add-Member -Name 'band_link' -MemberType NoteProperty -Value $BandLink

                $TrackList.Add($Track)
            }
        }

        return $TrackList
    }

    hidden [string[]] GetAlbums ([string[]] $Links) {
        [regex] $Pattern = [regex]::new('(?<=\<a\shref\=\")\/album\/.*(?=\"\>)')
        [System.Collections.Generic.List[string]] $AlbumList = @()

        foreach ($Url in $Links) {
            [Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject] $Response = Invoke-WebRequest -Uri $Url

            [string[]] $AlbumArray = [regex]::Matches($Response.RawContent, $Pattern).Value
            foreach ($Album in $AlbumArray) {
                $AlbumList.Add(($Url + $Album))
            }
        }

        return $AlbumList
    }

    hidden [System.Xml.XmlDocument] CreateXspf ([BandcampSearchType] $Type) {
        if ($Type -eq [BandcampSearchType]::Artists) {
            [string[]] $AlbumList = $this.GetAlbums($this.$Type)
            [System.Collections.Generic.List[PSCustomObject]] $TrackList = @()

            foreach ($Album in $AlbumList) {
                [PSCustomObject[]] $TrackArray = $this.GetTracks($Album)

                foreach ($Track in $TrackArray) {
                    $TrackList.Add($Track)
                }
            }
        } elseif ($Type -eq [BandcampSearchType]::Albums -or $Type -eq [BandcampSearchType]::Tracks) {
            [System.Collections.Generic.List[PSCustomObject]] $TrackList = $this.GetTracks($this.$Type)
        } else {
            throw [System.Management.Automation.ArgumentTransformationMetadataException]::new("Cannot convert value `"$Type`" to type `"$([BandcampSearchType].Name)`". Error: `"Unable to match the identifier name arts to a valid enumerator name. Specify one of the following enumerator names and try again: Artists, Albums, Tracks`"")
        }

        [xml] $XspfObject = [xml]::new()

        [System.Xml.XmlElement] $TrackListNode = $XspfObject.CreateElement('trackList','http://xspf.org/ns/0/')

        foreach ($Item in $TrackList) {
            foreach ($Track in $Item.trackinfo) {
                [System.Xml.XmlElement] $TrackLocationNode = $XspfObject.CreateElement('location','http://xspf.org/ns/0/')
                $TrackLocationNode.InnerText = $Track.file.'mp3-128'

                [System.Xml.XmlElement] $TrackTitleNode = $XspfObject.CreateElement('title','http://xspf.org/ns/0/')
                $TrackTitleNode.InnerText = $Track.title

                [System.Xml.XmlElement] $TrackCreatorNode = $XspfObject.CreateElement('creator','http://xspf.org/ns/0/')
                $TrackCreatorNode.InnerText = $Item.artist

                [System.Xml.XmlElement] $TrackAlbumNode = $XspfObject.CreateElement('album','http://xspf.org/ns/0/')
                $TrackAlbumNode.InnerText = $Item.current.title

                [System.Xml.XmlElement] $TrackAnnotationNode = $XspfObject.CreateElement('annotation','http://xspf.org/ns/0/')
                $TrackAnnotationNode.InnerText = "$($Item.band_link)$($Track.title_link)"

                [System.Xml.XmlElement] $TrackNode = $XspfObject.CreateElement('track','http://xspf.org/ns/0/')
                $TrackNode.AppendChild($TrackLocationNode)
                $TrackNode.AppendChild($TrackTitleNode)
                $TrackNode.AppendChild($TrackCreatorNode)
                $TrackNode.AppendChild($TrackAlbumNode)
                $TrackNode.AppendChild($TrackAnnotationNode)

                $TrackListNode.AppendChild($TrackNode)
            }
        }

        [System.Xml.XmlElement] $PlaylistNode = $XspfObject.CreateElement('playlist','http://xspf.org/ns/0/')
        $PlaylistNode.SetAttribute('title','PSBandcampPlaylist')
        $PlaylistNode.SetAttribute('version',1)
        $PlaylistNode.SetAttribute('xmlns','http://xspf.org/ns/0/')
        $PlaylistNode.AppendChild($TrackListNode)

        [System.Xml.XmlDeclaration] $XmlNode = $XspfObject.CreateNode([System.Xml.XmlNodeType]::XmlDeclaration, $null, 'xml', $null)
        $XmlNode.Encoding = 'UTF-8'

        $XspfObject.AppendChild($XmlNode)
        $XspfObject.AppendChild($PlaylistNode)

        return $XspfObject
    }

    [void] StartVlc([string] $FilePath, [bool] $Random = $true) {
        if ($Random) {
            [hashtable] $Parameters = @{
                FilePath = "$env:ProgramFiles\VideoLAN\VLC\vlc.exe"
                ArgumentList = @(
                    $FilePath,
                    '--random'
                )
            }
        } else {
            [hashtable] $Parameters = @{
                FilePath = "$env:ProgramFiles\VideoLAN\VLC\vlc.exe"
                ArgumentList = @(
                    $FilePath
                )
            }
        }

        Start-Process @Parameters
    }
}