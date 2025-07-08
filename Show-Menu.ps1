function Show-Menu {
	<#
	.SYNOPSIS
		Generates a dynamic console menu featuring a list of options, allowing users to
		navigate and select choices using their keyboard arrows.

	.DESCRIPTION
		title  : [string/optional]
			Title for the menu.
			Defaults: "Please make a selection..."
		caption: [string/optional]
			Menu caption (or title).
			Defaults: ""
		choices: [array/required]
			List of choices to display in the menu.
		yselect: [string/optional]
			Text to display when the cursor is on the selected option.
			Defaults: " 🡢 "
		nselect: [string/optional]
			Text to display when the cursor is not on the selected option.
			Defaults: "   "
		default: [int/optional]
			Index of the default option selected from the choices.
			Don't forget that every array starts counting from zero.
			Defaults: 0

	.EXAMPLE
		This example shows how to use the Show-Menu function to display a menu with a custom title and three options.

		$choice = show-menu -title "Main Menu" -caption "Select an option." -default 2 -choices (
			"Menu Option 1",
			"Menu Option 2",
			"Menu Option 3"
		)

	.NOTES
		Version: 20231115.01
		Author Creator: Ryan Dunton https://github.com/ryandunton

		Contributors
			- F4Jonatas

		Version: 20250707.02
		+ Added more arguments, for more customization of the menu.
		+ Added option to start with default option.
		+ Removed ID in the choices options. Returning the ID from the array. This makes usage simpler.
	#>

	[cmdletbinding()]
	param (
		[parameter( mandatory = $false )]
		[string]
		$title = "Please make a selection...",
		[parameter( mandatory = $false )]
		[string]
		$caption = "",
		[parameter( mandatory = $true )]
		[array]
		$choices,
		[parameter( mandatory = $false )]
		[string]
		$yselect = "$([char]27)[1m 🡢 $([char]27)[0m",
		[parameter( mandatory = $false )]
		[string]
		$nselect = "   ",
		[parameter( mandatory = $false )]
		[int]
		$default = 0
	)

	begin {
		if ( $default -gt $choices.count -1 ) {
			$default = $choices.count -1
		}
		elseif ( $default -lt 0 ) {
			$default = 0
		}
		else {
			$default = $default
		}

		write-host $title -foregroundcolor white

		if ( $caption -ne "" ) {
			write-host $caption -foregroundcolor darkgray
		}

		# Create space for the menu
		$index = 0
		while ( $index -lt $choices.count ) {
			$index++
			write-host ""
		}
	}

	process {
		# Set initial selection index
		$selected = $default
		$finally  = $false


		# Display the menu and handle user input
		while ( $finally -ne $true ) {
			# Move cursor to top of menu area
			[console]::setcursorposition( 0, [console]::cursortop - $choices.count )

			for ( $index = 0; $index -lt $choices.count; $index++ ) {
				if ( $index -eq $selected ) {
					write-host "$yselect $( $choices[ $index ] )" -nonewline

					if ( $keyinfo.virtualkeycode -eq 13 -and $index -eq $selected ) {
						write-host " Selected" -foregroundcolor green -nonewline
						$finally = $true
					}
					if ( $index -eq $default ) {
						write-host " Default" -foregroundcolor yellow -nonewline
					}
				}

				else {
					write-host "$nselect $( $choices[ $index ] )" -nonewline

					if ( $index -eq $default ) {
						write-host " Default" -foregroundcolor yellow -nonewline
					}
				}

				# Clear any extra characters from previous lines
				$spacestoclear = [math]::max( 0, ( $choices[0].length - $choices[ $index ].length ))
				write-host ( ' ' * $spacestoclear ) -nonewline
				write-host ''
			}

			# Get user input
			# It will exit the loop as soon as the key is lifted.
			if ( $finally -ne $true ) {
				$keyinfo = $host.ui.rawui.readkey( 'noecho, includekeydown' )

				# Process arrow key input
				switch ( $keyinfo.virtualkeycode ) {
					38 {  # Up arrow
						$selected = [math]::max( 0, $selected - 1 )
					}
					40 {  # Down arrow
						$selected = [math]::min( $choices.count - 1, $selected + 1 )
					}
				}
			}
		}
	}

	end {
		# $selectedvalue = $choices[ $selected ]
		return $selected
	}
}
