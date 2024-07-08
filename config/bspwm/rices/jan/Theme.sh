#!/usr/bin/env bash
#       ██╗ █████╗ ███╗   ██╗    ██████╗ ██╗ ██████╗███████╗
#       ██║██╔══██╗████╗  ██║    ██╔══██╗██║██╔════╝██╔════╝
#       ██║███████║██╔██╗ ██║    ██████╔╝██║██║     █████╗
#  ██   ██║██╔══██║██║╚██╗██║    ██╔══██╗██║██║     ██╔══╝
#  ╚█████╔╝██║  ██║██║ ╚████║    ██║  ██║██║╚██████╗███████╗
#   ╚════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝    ╚═╝  ╚═╝╚═╝ ╚═════╝╚══════╝
#  Author  :  z0mbi3
#  Url     :  https://github.com/gh0stzk/dotfiles
#  About   :  This file will configure and launch the rice.
#

# Set bspwm configuration for Jan
set_bspwm_config() {
	bspc config border_width 0
	bspc config top_padding 50
	bspc config bottom_padding 2
	bspc config left_padding 2
	bspc config right_padding 2
	bspc config normal_border_color "#4C3A6D"
	bspc config active_border_color "#4C3A6D"
	bspc config focused_border_color "#785DA5"
	bspc config presel_feedback_color "#070219"
}

# Set alacritty colorscheme
set_alacritty_config() {
	cat >"$HOME"/.config/alacritty/rice-colors.toml <<EOF
# (CyberPunk) Color scheme for Jan Rice

# Default colors
[colors.primary]
background = "#070219"
foreground = "#27fbfe"

# Cursor colors
[colors.cursor]
cursor = "#fb007a"
text = "#070219"

# Normal colors
[colors.normal]
black = "#626483"
blue = "#19bffe"
cyan = "#43fbff"
green = "#a6e22e"
magenta = "#6800d2"
red = "#fb007a"
white = "#d9d9d9"
yellow = "#f3e430"

# Bright colors
[colors.bright]
black = "#626483"
blue = "#58AFC2"
cyan = "#926BCA"
green = "#a6e22e"
magenta = "#472575"
red = "#fb007a"
white = "#f1f1f1"
yellow = "#f3e430"
EOF
}

# Set kitty colorscheme
set_kitty_config() {
  cat >"$HOME"/.config/kitty/current-theme.conf <<EOF
## This file is autogenerated, do not edit it, instead edit the Theme.sh file inside the rice directory.
## (CyberPunk) Color scheme for Jan Rice


# The basic colors
foreground              #27fbfe
background              #070219
selection_foreground    #070219
selection_background    #27fbfe

# Cursor colors
cursor                  #27fbfe
cursor_text_color       #070219

# URL underline color when hovering with mouse
url_color               #19bffe

# Kitty window border colors
active_border_color     #27fbfe
inactive_border_color   #6800d2
bell_border_color       #f3e430

# Tab bar colors
active_tab_foreground   #27fbfe
active_tab_background   #6800d2
inactive_tab_foreground #070219
inactive_tab_background #626483
tab_bar_background      #070219

# The 16 terminal colors

# black
color0 #626483
color8 #626483

# red
color1 #fb007a
color9 #fb007a

# green
color2  #a6e22e
color10 #a6e22e

# yellow
color3  #f3e430
color11 #f3e430

# blue
color4  #19bffe
color12 #58AFC2

# magenta
color5  #6800d2
color13 #472575

# cyan
color6  #43fbff
color14 #926BCA

# white
color7  #d9d9d9
color15 #f1f1f1
EOF

killall -USR1 kitty
}

# Set compositor configuration
set_picom_config() {
	sed -i "$HOME"/.config/bspwm/picom.conf \
		-e "s/normal = .*/normal =  { fade = true; shadow = false; }/g" \
		-e "s/shadow-color = .*/shadow-color = \"#000000\"/g" \
		-e "s/corner-radius = .*/corner-radius = 0/g" \
		-e "s/\".*:class_g = 'Alacritty'\"/\"96:class_g = 'Alacritty'\"/g" \
		-e "s/\".*:class_g = 'kitty'\"/\"96:class_g = 'kitty'\"/g" \
		-e "s/\".*:class_g = 'FloaTerm'\"/\"96:class_g = 'FloaTerm'\"/g"
}

# Set dunst notification daemon config
set_dunst_config() {
	sed -i "$HOME"/.config/bspwm/dunstrc \
		-e "s/transparency = .*/transparency = 8/g" \
		-e "s/frame_color = .*/frame_color = \"#070219\"/g" \
		-e "s/separator_color = .*/separator_color = \"#fb007a\"/g" \
		-e "s/font = .*/font = JetBrainsMono NF Medium 9/g" \
		-e "s/foreground='.*'/foreground='#27fbfe'/g"

	sed -i '/urgency_low/Q' "$HOME"/.config/bspwm/dunstrc
	cat >>"$HOME"/.config/bspwm/dunstrc <<-_EOF_
		[urgency_low]
		timeout = 3
		background = "#070219"
		foreground = "#27fbfe"

		[urgency_normal]
		timeout = 6
		background = "#070219"
		foreground = "#27fbfe"

		[urgency_critical]
		timeout = 0
		background = "#070219"
		foreground = "#27fbfe"
	_EOF_
}

# Set eww colors
set_eww_colors() {
	cat >"$HOME"/.config/bspwm/eww/colors.scss <<EOF
// Eww colors for Jan rice
\$bg: #070219;
\$bg-alt: #09021f;
\$fg: #c0caf5;
\$black: #626483;
\$lightblack: #262831;
\$red: #fb007a;
\$blue: #58AFC2;
\$cyan: #926BCA;
\$magenta: #583794;
\$green: #a6e22e;
\$yellow: #f3e430;
\$archicon: #0f94d2;
EOF
}

# Set jgmenu colors for Jan
set_jgmenu_colors() {
	sed -i "$HOME"/.config/bspwm/jgmenurc \
		-e 's/color_menu_bg = .*/color_menu_bg = #070219/' \
		-e 's/color_norm_fg = .*/color_norm_fg = #c0caf5/' \
		-e 's/color_sel_bg = .*/color_sel_bg = #09021f/' \
		-e 's/color_sel_fg = .*/color_sel_fg = #c0caf5/' \
		-e 's/color_sep_fg = .*/color_sep_fg = #626483/'
}

# Set rofi colors
set_launcher_config() {
	cat >"$HOME"/.config/bspwm/src/rofi-themes/shared.rasi <<EOF
// Rofi colors for Jan

* {
    font: "Terminess Nerd Font Mono Bold 10";
    background: #070219F0;
    background-alt: #070219E0;
    foreground: #27fbfe;
    selected: #fb007af0;
    active: #a6e22e;
    urgent: #fb007a;
    
    img-background: url("~/.config/bspwm/rices/jan/rofi.webp", width);
}
EOF
}

# Launch the bar
launch_bars() {

	for mon in $(polybar --list-monitors | cut -d":" -f1); do
		MONITOR=$mon polybar -q main -c "${rice_dir}"/config.ini &
	done

}

### ---------- Apply Configurations ---------- ###

set_bspwm_config
set_alacritty_config
set_kitty_config
set_picom_config
set_dunst_config
set_eww_colors
set_jgmenu_colors
set_launcher_config
launch_bars
