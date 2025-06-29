function Show-Menu {
	<#
	.SYNOPSIS
		Generates a dynamic console menu featuring a list of options, allowing users to
		navigate and select choices using their keyboard arrows.
	.DESCRIPTION
		The Show-Menu function is used to display a dynamic menu in the console. It takes
		a title and a list of options as parameters. The title is optional and defaults to
		"Please make a selection...". The list of options is mandatory. The function will
		display the title in green, followed by the list of options. The user can then make
		a selection from the options provided.
	.EXAMPLE
		$MenuData += [PSCustomObject]@{Id = 1; DisplayName = "Menu Option 1"}, `
		             [PSCustomObject]@{Id = 2; DisplayName = "Menu Option 2"}, `
		             [PSCustomObject]@{Id = 3; DisplayName = "Menu Option 3"}
		Show-Menu -DynamicMenuTitle "Main Menu" -DynamicMenuList $MenuData
		This example shows how to use the Show-Menu function to display a menu with a custom title and three options.
	.NOTES
		Version: 20231115.01
		Author:  Ryan Dunton https://github.com/ryandunton
	#>

	[cmdletbinding()]
	param (
		[parameter( mandatory = $false )]
		[string]
		$caption = "Please make a selection...",
		[parameter( mandatory = $false )]
		[string]
		$message = "",
		[parameter( mandatory = $false )]
		[array]
		$dynamicmenulist,
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
		write-host "$([char]27)[1m$caption$([char]27)[0m"

		if ( $message -ne "" ) {
			write-host "$([char]27)[1;30m$message$([char]27)[0m"
		}

		# Create space for the menu
		$index = 0
		while ( $index -lt $dynamicmenulist.count ) {
			$index++
			write-host ""
		}
	}

	process {
		# Set initial selection index
		$selectedvalueindex = 0
		$break = 0

		# Display the menu and handle user input
		while ( $break -ne $true ) {
			# Move cursor to top of menu area
			[console]::setcursorposition( 0, [console]::cursortop - $dynamicmenulist.count )

			for ( $i = 0; $i -lt $dynamicmenulist.count; $i++ ) {
				if ( $i -eq $selectedvalueindex ) {
					write-host "$yselect $( $dynamicmenulist[$i] )" -nonewline


					if ( $keyinfo.virtualkeycode -eq 13 -and $i -eq $selectedvalueindex ) {
						write-host " $([char]27)[0;32mSelected$([char]27)[0m" -nonewline
						$break = $true
					}
					if ( $i -eq $default ) {
						write-host " $([char]27)[1;30mDefault$([char]27)[0m" -nonewline
					}
				}

				else {
					write-host "$nselect $( $dynamicmenulist[$i] )" -nonewline
				}

				# Clear any extra characters from previous lines
				$spacestoclear = [math]::max( 0, ( $dynamicmenulist[0].length - $dynamicmenulist[$i].length ))
				write-host ( ' ' * $spacestoclear ) -nonewline
				write-host ''
			}

			# Get user input
			# It will exit the loop as soon as the key is lifted
			if ( $keyinfo.virtualkeycode -eq 13 ) {
				$keyinfo = $host.ui.rawui.readkey( 'noecho, includekeyup' )
			}
			else {
				$keyinfo = $host.ui.rawui.readkey( 'noecho, includekeydown' )
			}

			# Process arrow key input
			switch ( $keyinfo.virtualkeycode ) {
				38 {  # Up arrow
					$selectedvalueindex = [math]::max( 0, $selectedvalueindex - 1 )
				}
				40 {  # Down arrow
					$selectedvalueindex = [math]::min( $dynamicmenulist.count - 1, $selectedvalueindex + 1 )
				}
			}
		}

		$selectedvalue = $dynamicmenulist[ $selectedvalueindex ]
	}

	end {
		return $selectedvalueindex
	}
}
