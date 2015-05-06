#This file creates a few html files from all the fonts found in a folder (and subfolders)
#This is used as a reference to know which font to use when editing images etc..
#There is a folder which contains other subfolders, in those subfolders we have the fonts
package require fileutil


set text "The quick brown fox jumps over the lazy dog.  0123456789 ?! *"

proc runThroughFontFiles {dir} {
	set fontFolders 	[glob -type d -directory $dir  -- *]
	foreach fontFolder $fontFolders {
		processFontsInFolder $fontFolder
	}
}

proc processFontsInFolder {fontFolder} {
	global css body
	puts "In font folder $fontFolder"
	set allFontFiles [::fileutil::findByPattern $fontFolder  -- {*.ttf}]
	set css ""
	set body ""
	set htmlName [file tail $fontFolder] 
	set htmlFile [open [file dirname $fontFolder]/${htmlName}.html w]
	foreach  fontFile $allFontFiles {
		generateHtmlForFont $fontFile
	}
	puts $htmlFile  [processHtml]
	close $htmlFile
	puts "created $htmlName.html ...."
}

proc processHtml {} {
	global css body
	set data <html><head><style>
	append data ".myfonts {
	 font-size:4em;
	 margin: 15px 0;
	}"
	append data $css
	append data </style></head><body>
	append data $body
	append data </body> </html>
	return $data
}

proc generateHtmlForFont {fontFile} {
	global css body text
	set fontName [file rootname [file tail $fontFile]]
	#replace all non alphanumeric things with underline
	set fontName font[regsub  -all {\W} $fontName _]
	append css "
	@font-face {
		font-family: $fontName;
		src: url(\"$fontFile\");
	}
	"
	append body "<div style='font-family: $fontName;' class='myfonts'> $fontName : $text</div>"
}
puts "Starting"
runThroughFontFiles "/media/lostone/LostOneHdd/Computer things/Font Collection/"
