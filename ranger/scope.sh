#!/usr/bin/env bash

## Copyright (C) 2020-2021 Aditya Shakya <adi1090x@gmail.com>
## Everyone is permitted to copy and distribute copies of this file under GNU-GPL3

set -o noclobber -o noglob -o nounset -o pipefail
IFS=$'\n'

# If the option `use_preview_script` is set to `true`,
# then this script will be called and its output will be displayed in ranger.
# ANSI color codes are supported.
# STDIN is disabled, so interactive scripts won't work properly

# This script is considered a configuration file and must be updated manually.
# It will be left untouched if you upgrade ranger.
import
# Meanings of exit codes:
# code | meaning    | action of ranger
# -----+------------+-------------------------------------------
# 0    | success    | Display stdout as preview
# 1    | no preview | Display no preview at all
# 2    | plain text | Display the plain content of the file
# 3    | fix width  | Don't reload when width changes
# 4    | fix height | Don't reload when height changes
# 5    | fix both   | Don't ever reload
# 6    | image      | Display the image `$IMAGE_CACHE_PATH` points to as an image preview
# 7    | image      | Display the file directly as an image

# Script arguments
FILE_PATH="${1}"        # Full path of the highlighted file
PV_WIDTH="${2}"         # Width of the preview pane (number of fitting characters)
PV_HEIGHT="${3}"        # Height of the preview pane (number of fitting characters)
IMAGE_CACHE_PATH="${4}" # Full path that should be used to cache image preview
PV_IMAGE_ENABLED="${5}" # 'True' if image previews are enabled, 'False' otherwise.

FILE_EXTENSION="${FILE_PATH##*.}"
FILE_EXTENSION_LOWER="$(printf "%s" "${FILE_EXTENSION}" | tr '[:upper:]' '[:lower:]')"

# Settings
HIGHLIGHT_SIZE_MAX=262143 # 256KiB
HIGHLIGHT_TABWIDTH=2
HIGHLIGHT_STYLE=$("${HOME}/.config/highlight/themes/norddark.theme")
PYGMENTIZE_STYLE=${PYGMENTIZE_STYLE:-autumn}
OPENSCAD_IMGSIZE=${RNGR_OPENSCAD_IMGSIZE:-1000,1000}
OPENSCAD_COLORSCHEME=${RNGR_OPENSCAD_COLORSCHEME:-Tomorrow Night}

handle_extension() {
	case "${FILE_EXTENSION_LOWER}" in
	# use AVFS for archive exploration
	# VIZ: $ grep /path/to/src/avfs -hroP '\.from = "\K[^"]+' |sort -u| sed 's/^\./|/' | paste -sd ''
	Z | a | apk | bz | bz2 | deb | ear | gz | jar | lzma | rar | sfx | tar | tar.bz2 | tar.xz | tar.zst | taz | tbz | tbz2 | tgz | tpz | txz | tz | tzst | war | xz | zip | zst)
		# MAYBE:BAD:(errpipe=141): | head -n "$PV_HEIGHT"
		local vdir=$XDG_RUNTIME_DIR/avfs$FILE_PATH'#/'
		[[ -d $vdir ]] && tree --noreport -xaCL 3 --dirsfirst -- "$vdir" && exit 5
		atool --list -- "${FILE_PATH}" && exit 5
		bsdtar --list --file "${FILE_PATH}" && exit 5
		exit 1
		;;

	# # Archive
	# a | ace | alz | arc | arj | bz | bz2 | cab | cpio | deb | gz | jar | lha | lz | lzh | lzma | lzo | \
	# 	rpm | rz | t7z | tar | tbz | tbz2 | tgz | tlz | txz | tZ | tzo | war | xpi | xz | Z | zip)
	# 	atool --list -- "${FILE_PATH}" && exit 5
	# 	bsdtar --list --file "${FILE_PATH}" && exit 5
	# 	exit 1
	# 	;;

	rar)
		# Avoid password prompt by providing empty password
		unrar lt -p- -- "${FILE_PATH}" && exit 5
		exit 1
		;;
	7z)
		# Avoid password prompt by providing empty password
		7z l -p -- "${FILE_PATH}" && exit 5
		exit 1
		;;
	md)
		glow -s auto -- "${FILE_PATH}" && exit 5
		exit 1
		;;
	# PDF
	pdf)
		# Preview as text conversion
		pdftotext -l 10 -nopgbrk -q -- "${FILE_PATH}" - && exit 5
		exiftool "${FILE_PATH}" && exit 5
		exit 1
		;;

	# BitTorrent
	torrent)
		transmission-show -- "${FILE_PATH}" && exit 5
		exit 1
		;;

	# OpenDocument
	odt | ods | odp | sxw)
		# Preview as text conversion
		odt2txt "${FILE_PATH}" && exit 5
    (pandoc -s -t markdown -- "${FILE_PATH}" | glow -s auto -) && exit 5
		exit 1
		;;

	## XLSX
	xlsx)
		## Preview as csv conversion
		## Uses: https://github.com/dilshod/xlsx2csv
		xlsx2csv -- "${FILE_PATH}" && exit 5
		exit 1
		;;
	#csv
	csv)
		local table_columns="$(head -1 "${FILE_PATH}")"
		cat "${FILE_PATH}" | column --table-columns "${table_columns}" -d -T ${table_columns} -t -s, | less -S && exit 5
		exit 1
		;;

	## JSON
	json)
		jq --color-output . "${FILE_PATH}" && exit 5
		python -m json.tool -- "${FILE_PATH}" && exit 5
		;;

	# HTML
	htm | html | xhtml)
		# Preview as text conversion
		w3m -dump "${FILE_PATH}" && exit 5
		lynx -dump -- "${FILE_PATH}" && exit 5
		elinks -dump "${FILE_PATH}" && exit 5
    # (pandoc -s -t markdown -- "${FILE_PATH}" | glow -s auto -)  && exit 5
		;; # Continue with next handler on failure

	## Direct Stream Digital/Transfer (DSDIFF) and wavpack aren't detected
	## by file(1).
	dff | dsf | wv | wvc)
		mediainfo "${FILE_PATH}" && exit 5
		exiftool "${FILE_PATH}" && exit 5
		;; # Continue with next handler on failure
	esac
}

handle_image() {
	local mimetype="${1}"
	case "${mimetype}" in
	# SVG
	image/svg+xml)
		convert "$FILE_PATH" "$IMAGE_CACHE_PATH" && exit 6
		exit 1
		;;

	# Image
	image/*)
		local orientation
		orientation="$(identify -format '%[EXIF:Orientation]\n' -- "${FILE_PATH}")"
		# If orientation data is present and the image actually
		# needs rotating ("1" means no rotation)...
		if [[ -n "$orientation" && "$orientation" != 1 ]]; then
			# ...auto-rotate the image according to the EXIF data.
			convert -- "${FILE_PATH}" -auto-orient "${IMAGE_CACHE_PATH}" && exit 6
		fi

		# `w3mimgdisplay` will be called for all images (unless overriden as above),
		# but might fail for unsupported types.
		exit 7
		;;

	# Video
	video/*)
    # Max size to render thumbnail.
		# if [[ $(du -s "${FILE_PATH}" | awk '{ print $1}') -ge 1048576 ]]; then
		# 	exit 1
		# fi
		# Thumbnail
		ffmpegthumbnailer -i "${FILE_PATH}" -o "${IMAGE_CACHE_PATH}" -s 0 && exit 6
		exit 1
		;;

	## Font
	application/font* | application/*opentype | font/*)
		fontpreview -i "${FILE_PATH}" -o "${IMAGE_CACHE_PATH}" && exit 6
		exit 1
		;;

	## ePub, MOBI, FB2 (using Calibre)
	application/epub+zip | application/x-mobipocket-ebook | \
		application/x-fictionbook+xml)
		# ePub (using https://github.com/marianosimone/epub-thumbnailer)
		epub-thumbnailer "${FILE_PATH}" "${IMAGE_CACHE_PATH}" \
			"${DEFAULT_SIZE%x*}" && exit 6
		ebook-meta --get-cover="${IMAGE_CACHE_PATH}" -- "${FILE_PATH}" \
			>/dev/null && exit 6
		exit 1
		;;
	# PDF
	application/pdf)
		pdftoppm -f 1 -l 1 \
			-scale-to-x 1920 \
			-scale-to-y -1 \
			-singlefile \
			-jpeg -tiffcompression jpeg \
			-- "${FILE_PATH}" "${IMAGE_CACHE_PATH%.*}" &&
			exit 6 || exit 1
		;;
	esac
}

handle_mime() {
	local mimetype="${1}"
	case "${mimetype}" in
	text/rtf | *msword)
		## Preview as text conversion
		## note: catdoc does not always work for .doc files
		## catdoc: http://www.wagner.pp.ru/~vitus/software/catdoc/
		catdoc -- "${FILE_PATH}" && exit 5
		exit 1
		;;

	## DOCX, ePub, FB2 (using markdown)
	## You might want to remove "|epub" and/or "|fb2" below if you have
	## uncommented other methods to preview those formats
	*wordprocessingml.document)
		## Preview as markdown conversion
    (pandoc -s -t markdown -- "${FILE_PATH}" | glow -s auto -)  && exit 5
		exit 1
		;;

	## XLS
	*ms-excel)
		## Preview as csv conversion
		## xls2csv comes with catdoc:
		##   http://www.wagner.pp.ru/~vitus/software/catdoc/
		xls2csv -- "${FILE_PATH}" && exit 5
		exit 1
		;;

	# Text
	text/* | */xml | application/x-subrip)
		# Syntax highlight
		if [[ "$(stat --printf='%s' -- "${FILE_PATH}")" -gt "${HIGHLIGHT_SIZE_MAX}" ]]; then
			exit 2
		fi
		if [[ "$(tput colors)" -ge 256 ]]; then
			local pygmentize_format='terminal256'
			local highlight_format='xterm256'
		else
			local pygmentize_format='terminal'
			local highlight_format='ansi'
		fi
		# env TERMCOLOR=16bit bat -f "${FILE_PATH}" && exit 5
		highlight --replace-tabs="${HIGHLIGHT_TABWIDTH}" --out-format="${highlight_format}" \
			--style="${HIGHLIGHT_STYLE}" --force -- "${FILE_PATH}" && exit 5
		# pygmentize -f "${pygmentize_format}" -O "style=${PYGMENTIZE_STYLE}" -- "${FILE_PATH}" && exit 5
		exit 2
		;;

	# Image
	image/*)
		# Preview as text conversion
		# img2txt --gamma=0.6 --width="${PV_WIDTH}" -- "${FILE_PATH}" && exit 4
		exiftool "${FILE_PATH}" && exit 5
		exit 1
		;;

	# Video and audio
	video/* | audio/*)
		mediainfo "${FILE_PATH}" && exit 5
		exiftool "${FILE_PATH}" && exit 5
		exit 1
		;;
	esac
}

handle_fallback() {
	echo '----- File Type Classification -----' && file --dereference --brief -- "${FILE_PATH}" && exit 5
	exit 1
}

MIMETYPE="$(file --dereference --brief --mime-type -- "${FILE_PATH}")"
if [[ "${PV_IMAGE_ENABLED}" == 'True' ]]; then
	handle_image "${MIMETYPE}"
fi
handle_extension
handle_mime "${MIMETYPE}"
handle_fallback

exit 1
