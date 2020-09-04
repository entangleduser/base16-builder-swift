# base16-builder-swift

A builder for base16 themes, written using the swift programming language and built using [these](http://chriskempson.com/projects/base16/) guidelines.

## Installation

	git clone https://github.com/neutralradiance/base16-builder-swift
	cd base16-builder-swift
	make init | build
*or use Xcode*
## Usage

		builder <subcommand>

### Options

		--version               Show the version.
		-h, --help              Show help information.

### Subcommands	
  init (default)
	  
		Clear schemes and templates, then rebuild in the working directory
	  
 clean 
 
		Delete Builder folders in the current directory
		  
update

		Update existing sources, schemes, and templates

### Considerations
Builder should only run in the **current directory** and themes are always sent to their **template-specific** folders under:
`[current directory]/templates/[template]/[folder]`