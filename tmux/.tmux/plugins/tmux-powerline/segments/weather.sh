# shellcheck shell=bash
# Prints the current weather in Celsius, Fahrenheits or lord Kelvins. The forecast is cached and updated with a period.
# To configure your location, set TMUX_POWERLINE_SEG_WEATHER_LOCATION in the tmux-powerline config file.

TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER_DEFAULT="yrno"
TMUX_POWERLINE_SEG_WEATHER_JSON_DEFAULT="jq"
TMUX_POWERLINE_SEG_WEATHER_UNIT_DEFAULT="c"
TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT="600"

if shell_is_bsd && [ -f /user/local/bin/grep ]; then
	TMUX_POWERLINE_SEG_WEATHER_GREP_DEFAULT="/usr/local/bin/grep"
else
	TMUX_POWERLINE_SEG_WEATHER_GREP_DEFAULT="grep"
fi

generate_segmentrc() {
	read -r -d '' rccontents <<EORC
# The data provider to use. Currently only "yahoo" is supported.
export TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER="${TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER_DEFAULT}"
# What unit to use. Can be any of {c,f,k}.
export TMUX_POWERLINE_SEG_WEATHER_UNIT="${TMUX_POWERLINE_SEG_WEATHER_UNIT_DEFAULT}"
# How often to update the weather in seconds.
export TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT}"
# Name of GNU grep binary if in PATH, or path to it.
export TMUX_POWERLINE_SEG_WEATHER_GREP="${TMUX_POWERLINE_SEG_WEATHER_GREP_DEFAULT}"
# Location of the JSON parser, jq
export TMUX_POWERLINE_SEG_WEATHER_JSON="${TMUX_POWERLINE_SEG_WEATHER_JSON_DEFAULT}"
# Your location
# Latitude and Longtitude for use with yr.no
TMUX_POWERLINE_SEG_WEATHER_LAT=""
TMUX_POWERLINE_SEG_WEATHER_LON=""
EORC
	echo "$rccontents"
}

run_segment() {
	__process_settings
	local tmp_file="${TMUX_POWERLINE_DIR_TEMPORARY}/temp_weather_file.txt"
	local weather
	case "$TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER" in
	"yrno") weather=$(__yrno) ;;
	"wttr") weather=$(__wttr) ;;
	*)
		echo "Unknown weather provider [$TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER]"
		return 1
		;;
	esac
	if [ -n "$weather" ]; then
		echo "$weather"
	fi
}

__process_settings() {
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER" ]; then
		export TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER="${TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_UNIT" ]; then
		export TMUX_POWERLINE_SEG_WEATHER_UNIT="${TMUX_POWERLINE_SEG_WEATHER_UNIT_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD" ]; then
		export TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD="${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_GREP" ]; then
		export TMUX_POWERLINE_SEG_WEATHER_GREP="${TMUX_POWERLINE_SEG_WEATHER_GREP_DEFAULT}"
	fi
	if [ -z "$TMUX_POWERLINE_SEG_WEATHER_JSON" ]; then
		export TMUX_POWERLINE_SEG_WEATHER_JSON="${TMUX_POWERLINE_SEG_WEATHER_JSON_DEFAULT}"
	fi
	# yr.no needs explicit coords; wttr.in accepts a city/zip/airport string or
	# falls back to IP geolocation when empty, so it never requires lat/lon.
	if [ "$TMUX_POWERLINE_SEG_WEATHER_DATA_PROVIDER" = "yrno" ] \
		&& [ -z "$TMUX_POWERLINE_SEG_WEATHER_LON" ] && [ -z "$TMUX_POWERLINE_SEG_WEATHER_LAT" ]; then
		echo "No location defined."
		exit 8
	fi
}

# wttr.in provider: location is a city name, zip/postal code, airport code, or
# empty for IP-based geolocation. Parses the j1 JSON so we can pick a day- or
# night-appropriate condition glyph (wttr's own %c emoji is day/night-agnostic —
# it shows ☀️ even at night). Returns "<condition-emoji> <temp>°<unit> <wind-arrow><speed>".
__wttr() {
	local location unit_field unit_sym out code temp rise set is_day emoji
	local wspeed wdeg pad feels thr delta hum humglyph extra
	location="${TMUX_POWERLINE_SEG_WEATHER_LOCATION:-}"
	if [ "$TMUX_POWERLINE_SEG_WEATHER_UNIT" = "f" ]; then
		unit_field="temp_F"; unit_sym="F"
	else
		unit_field="temp_C"; unit_sym="C"
	fi

	# Serve from cache if still fresh (don't hit the network every redraw).
	if [ -f "$tmp_file" ]; then
		local last_update time_now up_to_date
		if shell_is_osx || shell_is_bsd; then
			last_update=$(stat -f "%m" "${tmp_file}")
		elif shell_is_linux; then
			last_update=$(stat -c "%Y" "${tmp_file}")
		fi
		time_now=$(date +%s)
		up_to_date=$(echo "(${time_now}-${last_update}) < ${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD}" | bc)
		if [ "$up_to_date" -eq 1 ]; then
			__read_tmp_file
		fi
	fi

	out=$(curl --max-time 4 -s "https://wttr.in/${location}?format=j1")
	curl_rc=$?
	# TEMPORARY DEBUG (see ~/.config/tmux-powerline/DEBUG): record every live wttr fetch.
	if [ -d /tmp/tmux-powerline-debug ]; then
		echo "$(date '+%F %T') wttr location='${location}' curl_rc=${curl_rc} bytes=${#out}" >> /tmp/tmux-powerline-debug/weather.log
	fi
	if [ "$curl_rc" -eq 0 ]; then
		code=$(printf '%s' "$out" | "$TMUX_POWERLINE_SEG_WEATHER_JSON" -r '.current_condition[0].weatherCode // empty' 2>/dev/null)
		temp=$(printf '%s' "$out" | "$TMUX_POWERLINE_SEG_WEATHER_JSON" -r ".current_condition[0].${unit_field} // empty" 2>/dev/null)
		if [ -z "$code" ] || [ -z "$temp" ]; then
			# Not a valid forecast (error page / network hiccup) → keep last good value.
			[ -f "${tmp_file}" ] && __read_tmp_file
			return
		fi
		rise=$(printf '%s' "$out" | "$TMUX_POWERLINE_SEG_WEATHER_JSON" -r '.weather[0].astronomy[0].sunrise // empty' 2>/dev/null)
		set=$(printf '%s' "$out" | "$TMUX_POWERLINE_SEG_WEATHER_JSON" -r '.weather[0].astronomy[0].sunset // empty' 2>/dev/null)
		is_day=$(__wttr_is_day "$rise" "$set")
		emoji=$(__wttr_symbol "$code" "$is_day")
		# Adaptive extra metric, chosen by how "feels like" compares to actual temp:
		#   notably colder (wind chill) -> wind     (downwind arrow + speed)
		#   notably warmer (mugginess)  -> humidity (💧 + percent)
		#   about the same              -> nothing
		# Threshold is in the active unit (degF default 3; C users may prefer 2).
		# Disable entirely with TMUX_POWERLINE_SEG_WEATHER_SHOW_EXTRA=false.
		# Wind speed is superscript; humidity is plain digits + %. A hair space (U+200A)
		# keeps them off the glyph (swap pad to U+2009 thin, U+202F, or a plain space).
		extra=""
		pad=$'\u200a'
		humglyph="💧"; [ -n "$TMUX_POWERLINE_SEG_WEATHER_HUMIDITY_GLYPH" ] && humglyph="$TMUX_POWERLINE_SEG_WEATHER_HUMIDITY_GLYPH"
		if [ "${TMUX_POWERLINE_SEG_WEATHER_SHOW_EXTRA:-true}" = "true" ]; then
			feels=$(printf '%s' "$out" | "$TMUX_POWERLINE_SEG_WEATHER_JSON" -r ".current_condition[0].FeelsLike${unit_sym} // empty" 2>/dev/null)
			thr="${TMUX_POWERLINE_SEG_WEATHER_FEELS_THRESHOLD:-3}"
			if [ -n "$feels" ] && [ -n "$temp" ]; then
				delta=$((feels - temp))
				if [ "$delta" -le $((-thr)) ]; then
					if [ "$TMUX_POWERLINE_SEG_WEATHER_UNIT" = "f" ]; then
						wspeed=$(printf '%s' "$out" | "$TMUX_POWERLINE_SEG_WEATHER_JSON" -r '.current_condition[0].windspeedMiles // empty' 2>/dev/null)
					else
						wspeed=$(printf '%s' "$out" | "$TMUX_POWERLINE_SEG_WEATHER_JSON" -r '.current_condition[0].windspeedKmph // empty' 2>/dev/null)
					fi
					wdeg=$(printf '%s' "$out" | "$TMUX_POWERLINE_SEG_WEATHER_JSON" -r '.current_condition[0].winddirDegree // empty' 2>/dev/null)
					[ -n "$wspeed" ] && [ -n "$wdeg" ] && extra=" $(__wttr_wind_arrow "$wdeg")${pad}$(__wttr_superscript "$wspeed")"
				elif [ "$delta" -ge "$thr" ]; then
					hum=$(printf '%s' "$out" | "$TMUX_POWERLINE_SEG_WEATHER_JSON" -r '.current_condition[0].humidity // empty' 2>/dev/null)
					[ -n "$hum" ] && extra=" ${humglyph}${pad}${hum}%"
				fi
			fi
		fi
		printf '%s %s°%s%s' "$emoji" "$temp" "$unit_sym" "$extra" | tee "${tmp_file}"
	elif [ -f "${tmp_file}" ]; then
		__read_tmp_file
	fi
}

# Render an integer as Unicode superscript digits (⁰¹²³⁴⁵⁶⁷⁸⁹), via ANSI-C escapes
# so they survive editing. Lets the wind speed sit compactly against the arrow.
__wttr_superscript() {
	local n="$1" out="" i c
	for ((i = 0; i < ${#n}; i++)); do
		case "${n:i:1}" in
		0) c=$'\u2070' ;; 1) c=$'\u00b9' ;; 2) c=$'\u00b2' ;; 3) c=$'\u00b3' ;;
		4) c=$'\u2074' ;; 5) c=$'\u2075' ;; 6) c=$'\u2076' ;; 7) c=$'\u2077' ;;
		8) c=$'\u2078' ;; 9) c=$'\u2079' ;; *) c="${n:i:1}" ;;
		esac
		out="${out}${c}"
	done
	printf '%s' "$out"
}

# Compass arrow pointing downwind (the way wttr renders it) for a "from" bearing in degrees.
__wttr_wind_arrow() {
	local deg="$1" toward idx
	case "$deg" in ''|*[!0-9]*) return ;; esac
	toward=$(( (deg + 180) % 360 ))
	idx=$(( ((toward + 22) / 45) % 8 ))
	case "$idx" in
	0) printf '↑' ;; 1) printf '↗' ;; 2) printf '→' ;; 3) printf '↘' ;;
	4) printf '↓' ;; 5) printf '↙' ;; 6) printf '←' ;; 7) printf '↖' ;;
	esac
}

# Parse a "HH:MM AM/PM" clock into minutes-since-midnight.
__wttr_clock_to_min() {
	local t="$1" hh mm ap
	hh="${t%%:*}"; t="${t#*:}"; mm="${t%% *}"; ap="${t##* }"
	hh=$((10#$hh % 12)); [ "$ap" = "PM" ] && hh=$((hh + 12))
	echo $((hh * 60 + 10#$mm))
}

# Day if the *local system* clock is between the location's sunrise and sunset.
# Accurate for local/IP weather (system tz == location tz); for a far-away city
# near dawn/dusk it may be off, which only ever swaps a sun/moon glyph.
__wttr_is_day() {
	local rise="$1" set="$2" r s now
	[ -z "$rise" ] || [ -z "$set" ] && { echo 1; return; }
	r=$(__wttr_clock_to_min "$rise"); s=$(__wttr_clock_to_min "$set")
	now=$((10#$(date +%H) * 60 + 10#$(date +%M)))
	if [ "$now" -ge "$r" ] && [ "$now" -lt "$s" ]; then echo 1; else echo 0; fi
}

# Map a WWO weather code (https://www.worldweatheronline.com/weather-api) to a glyph.
# Only clear (113) and partly-cloudy (116) differ by day/night; the rest don't.
__wttr_symbol() {
	local code="$1" day="$2"
	case "$code" in
	113) [ "$day" = 1 ] && echo "☀️ " || echo "🌙" ;;
	116) [ "$day" = 1 ] && echo "⛅" || echo "🌗" ;;
	119 | 122) echo "☁️ " ;;
	143 | 248 | 260) echo "🌫 " ;;
	176 | 263 | 266 | 281 | 284 | 293 | 296 | 299 | 302 | 305 | 308 | 311 | 314 | 353 | 356 | 359) echo "🌧 " ;;
	182 | 185 | 317 | 320 | 350 | 362 | 365 | 374 | 377) echo "🌨 " ;;
	179 | 227 | 230 | 323 | 326 | 329 | 332 | 335 | 338 | 368 | 371) echo "❄️ " ;;
	200 | 386 | 389 | 392 | 395) echo "⛈️ " ;;
	*) echo "?" ;;
	esac
}

__yrno() {
	degree=""
	if [ -f "$tmp_file" ]; then
		if shell_is_osx || shell_is_bsd; then
			last_update=$(stat -f "%m" "${tmp_file}")
		elif shell_is_linux; then
			last_update=$(stat -c "%Y" "${tmp_file}")
		fi
		time_now=$(date +%s)

		up_to_date=$(echo "(${time_now}-${last_update}) < ${TMUX_POWERLINE_SEG_WEATHER_UPDATE_PERIOD}" | bc)
		if [ "$up_to_date" -eq 1 ]; then
			__read_tmp_file
		fi
	fi

	if [ -z "$degree" ]; then
		if weather_data=$(curl --max-time 4 -s "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=${TMUX_POWERLINE_SEG_WEATHER_LAT}&lon=${TMUX_POWERLINE_SEG_WEATHER_LON}"); then
			grep=$TMUX_POWERLINE_SEG_WEATHER_GREP_DEFAULT
			error=$(echo "$weather_data" | $grep -i "error")
			if [ -n "$error" ]; then
				echo "error"
				exit 1
			fi

			jsonparser="${TMUX_POWERLINE_SEG_WEATHER_JSON}"
			degree=$(echo "$weather_data" | $jsonparser -r .properties.timeseries[0].data.instant.details.air_temperature)
			condition=$(echo "$weather_data" | $jsonparser -r .properties.timeseries[0].data.next_1_hours.summary.symbol_code)
		elif [ -f "${tmp_file}" ]; then
			__read_tmp_file
		fi
	fi

	if [ -n "$degree" ]; then
		if [ "$TMUX_POWERLINE_SEG_WEATHER_UNIT" == "k" ]; then
			degree=$(echo "${degree} + 273.15" | bc)
		fi
		if [ "$TMUX_POWERLINE_SEG_WEATHER_UNIT" == "f" ]; then
			degree=$(echo "${degree} * 9 / 5 + 32" | bc)
		fi
		# condition_symbol=$(__get_yrno_condition_symbol "$condition" "$sunrise" "$sunset")
		condition_symbol=$(__get_yrno_condition_symbol "$condition")
		echo "${condition_symbol} ${degree}°$(echo "$TMUX_POWERLINE_SEG_WEATHER_UNIT" | tr '[:lower:]' '[:upper:]')" | tee "${tmp_file}"
	fi
}

# Get symbol for condition. Available symbol names: https://api.met.no/weatherapi/weathericon/2.0/documentation#List_of_symbols
__get_yrno_condition_symbol() {
	# local condition=$(echo "$1" | tr '[:upper:]' '[:lower:]')
	# local sunrise="$2"
	# local sunset="$3"
	local condition=$1
	case "$condition" in
	"clearsky_day")
		echo "☀️ "
		;;
	"clearsky_night")
		echo "🌙"
		;;
	"fair_day")
		echo "🌤 "
		;;
	"fair_night")
		echo "🌜"
		;;
	"fog")
		echo "🌫 "
		;;
	"cloudy")
		echo "☁️ "
		;;
	"rain" | "lightrain" | "heavyrain" | "sleet" | "lightsleet" | "heavysleet")
		echo "🌧 "
		;;
	"heavyrainandthunder" | "heavyrainshowersandthunder_day" | "heavyrainshowersandthunder_night" | "heavysleetandthunder" | "heavysleetshowersandthunder_day" | "heavysnowandthunder" | "heavysnowshowersandthunder_day" | "heavysnowshowersandthunder_night" | "lightrainandthunder" | "lightrainshowersandthunder_day" | "lightrainshowersandthunder_night" | "lightsleetandthunder" | "lightsnowandthunder" | "lightssleetshowersandthunder_day" | "lightssleetshowersandthunder_night" | "lightssnowshowersandthunder_day" | "lightssnowshowersandthunder_night" | "rainandthunder" | "rainshowersandthunder_day" | "rainshowersandthunder_night" | "sleetandthunder" | "sleetshowersandthunder_day" | "sleetshowersandthunder_night" | "snowandthunder" | "snowshowersandthunder_day" | "snowshowersandthunder_night")
		echo "⛈️ "
		;;
	"heavyrainshowers_day" | "heavysleetshowers_day" | "heavysleetshowersandthunder_night" | "lightrainshowers_day" | "lightsleetshowers_day" | "rainshowers_day" | "sleetshowers_day")
		echo "🌦️ "
		;;
	"heavyrainshowers_night" | "heavysleetshowers_night" | "lightrainshowers_night" | "lightsleetshowers_night" | "rainshowers_night" | "sleetshowers_night")
		echo "☔"
		;;
	"snow" | "lightsnow" | "heavysnow")
		echo "❄️ "
		;;
	"lightsnowshowers_day" | "lightsnowshowers_night" | "heavysnowshowers_day" | "heavysnowshowers_night" | "snowshowers_day" | "snowshowers_night")
		echo "🌨 "
		;;
	"partlycloudy_day")
		echo "⛅"
		;;
	"partlycloudy_night")
		echo "🌗"
		;;
	*)
		echo "?"
		;;
	esac
}

__read_tmp_file() {
	if [ ! -f "$tmp_file" ]; then
		return
	fi
	cat "${tmp_file}"
	exit
}
