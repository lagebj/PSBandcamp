---
external help file: PSBandcamp-help.xml
Module Name: PSBandcamp
online version:
schema: 2.0.0
---

# New-BandcampPlaylist

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Url (Default)
```
New-BandcampPlaylist [-Url] <String> [-FilePath] <String> [-StartPlaylist] [-AsObject] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Search
```
New-BandcampPlaylist [-SearchQuery] <String[]> [-FilePath] <String> [-SearchType] <BandcampSearchType>
 [-StartPlaylist] [-AsObject] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -AsObject
Return Bandcamp search as object.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -FilePath
Full path to new playlist.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -SearchQuery
Query to use for search.

```yaml
Type: String[]
Parameter Sets: Search
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -SearchType
What type of item you are searching for.
Accepts values Artists, Albums and Tracks.

```yaml
Type: BandcampSearchType
Parameter Sets: Search
Aliases:
Accepted values: Artists, Albums, Tracks

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -StartPlaylist
Open and play playlist after creation.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Url
URL of artist/label to create playlist from.
Currently only supports artist/label URLs.

```yaml
Type: String
Parameter Sets: Url
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### System.String

### System.String[]

## OUTPUTS

### System.Void

### BandcampSearch

## NOTES

## RELATED LINKS
