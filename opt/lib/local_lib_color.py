#! /usr/bin/env python3

from __future__ import print_function

BG = {'k':'\033[40m','w':'\033[47m','r':'\033[41m','g':'\033[42m','b':'\033[44m','m':'\033[45m','c':'\033[46m','y':'\033[43m'}
FG = {'k':'\033[30m','w':'\033[37m','r':'\033[31m','g':'\033[32m','b':'\033[34m','m':'\033[35m','c':'\033[36m','y':'\033[33m'}
END = '\033[0m'

def BG256(n):
    if (0 <= n < 256):
        return '\033[48;5;%dm' % n
    else:
        return ''

def FG256(n):
    if (0 <= n < 256):
        return '\033[38;5;%dm' % n
    else:
        return ''

# for vim color test
def isdark(r,g,b):
    # cond = (r+g+b<7) and (max([r,g,b])<4)

    # cond = (r**2+g**2+b**2 < 5**2)

    # if r < 4:
    #     cond = (g==0 or g*g+b*b < 3**2)
    #     cond = (g<3 and g+b < 6)
    # else:
    #     cond = g*g+b*b < (7-r)**2

    w_r, w_g, w_b = (0.299,0.587,0.114)
    cond = (r*w_r+g*w_g+b*w_b)/(w_r+w_g+w_b) < 2.1

    w_r_old, w_g_old, w_b_old = (0.299,0.587,0.114)
    cond_old = (r*w_r+g*w_g+b*w_b)/(w_r+w_g+w_b) < 2.1

    return cond, cond_old

col_list = None
def convert_color_name(color_name, color_type, verbose=False):
    if color_type not in ['256', 'full']:
        if verbose:
            print('incorrect color type ({}).'.format(color_type))
            print('selectable type: "256" or "full". return None.')
        return None

    global col_list
    if col_list is None:
        col_list = { \
                "black"               : {'256':0   , 'full': '#000000'}, \
                "maroon"              : {'256':1   , 'full': '#800000'}, \
                "green"               : {'256':2   , 'full': '#008000'}, \
                "olive"               : {'256':3   , 'full': '#808000'}, \
                "navy"                : {'256':4   , 'full': '#000080'}, \
                "purple"              : {'256':5   , 'full': '#800080'}, \
                "teal"                : {'256':6   , 'full': '#008080'}, \
                "silver"              : {'256':7   , 'full': '#c0c0c0'}, \
                "gray"                : {'256':8   , 'full': '#808080'}, \
                "grey"                : {'256':8   , 'full': '#808080'}, \
                "red"                 : {'256':9   , 'full': '#ff0000'}, \
                "lime"                : {'256':10  , 'full': '#00ff00'}, \
                "yellow"              : {'256':11  , 'full': '#ffff00'}, \
                "blue"                : {'256':12  , 'full': '#0000ff'}, \
                "fuchsia"             : {'256':13  , 'full': '#ff00ff'}, \
                "aqua"                : {'256':14  , 'full': '#00ffff'}, \
                "white"               : {'256':15  , 'full': '#ffffff'}, \
                "gray0"               : {'256':16  , 'full': '#000000'}, \
                "grey0"               : {'256':16  , 'full': '#000000'}, \
                "navyblue"            : {'256':17  , 'full': '#00005f'}, \
                "darkblue"            : {'256':18  , 'full': '#000087'}, \
                "blue3"               : {'256':19  , 'full': '#0000af'}, \
                "blue3"               : {'256':20  , 'full': '#0000d7'}, \
                "blue1"               : {'256':21  , 'full': '#0000ff'}, \
                "darkgreen"           : {'256':22  , 'full': '#005f00'}, \
                "deepskyblue4"        : {'256':23  , 'full': '#005f5f'}, \
                "deepskyblue4"        : {'256':24  , 'full': '#005f87'}, \
                "deepskyblue4"        : {'256':25  , 'full': '#005faf'}, \
                "dodgerblue3"         : {'256':26  , 'full': '#005fd7'}, \
                "dodgerblue2"         : {'256':27  , 'full': '#005fff'}, \
                "green4"              : {'256':28  , 'full': '#008700'}, \
                "springgreen4"        : {'256':29  , 'full': '#00875f'}, \
                "turquoise4"          : {'256':30  , 'full': '#008787'}, \
                "deepskyblue3"        : {'256':31  , 'full': '#0087af'}, \
                "deepskyblue3"        : {'256':32  , 'full': '#0087d7'}, \
                "dodgerblue1"         : {'256':33  , 'full': '#0087ff'}, \
                "green3"              : {'256':34  , 'full': '#00af00'}, \
                "springgreen3"        : {'256':35  , 'full': '#00af5f'}, \
                "darkcyan"            : {'256':36  , 'full': '#00af87'}, \
                "lightseagreen"       : {'256':37  , 'full': '#00afaf'}, \
                "deepskyblue2"        : {'256':38  , 'full': '#00afd7'}, \
                "deepskyblue1"        : {'256':39  , 'full': '#00afff'}, \
                "green3"              : {'256':40  , 'full': '#00d700'}, \
                "springgreen3"        : {'256':41  , 'full': '#00d75f'}, \
                "springgreen2"        : {'256':42  , 'full': '#00d787'}, \
                "cyan3"               : {'256':43  , 'full': '#00d7af'}, \
                "darkturquoise"       : {'256':44  , 'full': '#00d7d7'}, \
                "turquoise2"          : {'256':45  , 'full': '#00d7ff'}, \
                "green1"              : {'256':46  , 'full': '#00ff00'}, \
                "springgreen2"        : {'256':47  , 'full': '#00ff5f'}, \
                "springgreen1"        : {'256':48  , 'full': '#00ff87'}, \
                "mediumspringgreen"   : {'256':49  , 'full': '#00ffaf'}, \
                "cyan2"               : {'256':50  , 'full': '#00ffd7'}, \
                "cyan1"               : {'256':51  , 'full': '#00ffff'}, \
                "darkred"             : {'256':52  , 'full': '#5f0000'}, \
                "deeppink4"           : {'256':53  , 'full': '#5f005f'}, \
                "purple4"             : {'256':54  , 'full': '#5f0087'}, \
                "purple4"             : {'256':55  , 'full': '#5f00af'}, \
                "purple3"             : {'256':56  , 'full': '#5f00d7'}, \
                "blueviolet"          : {'256':57  , 'full': '#5f00ff'}, \
                "orange4"             : {'256':58  , 'full': '#5f5f00'}, \
                "gray37"              : {'256':59  , 'full': '#5f5f5f'}, \
                "grey37"              : {'256':59  , 'full': '#5f5f5f'}, \
                "mediumpurple4"       : {'256':60  , 'full': '#5f5f87'}, \
                "slateblue3"          : {'256':61  , 'full': '#5f5faf'}, \
                "slateblue3"          : {'256':62  , 'full': '#5f5fd7'}, \
                "royalblue1"          : {'256':63  , 'full': '#5f5fff'}, \
                "chartreuse4"         : {'256':64  , 'full': '#5f8700'}, \
                "darkseagreen4"       : {'256':65  , 'full': '#5f875f'}, \
                "paleturquoise4"      : {'256':66  , 'full': '#5f8787'}, \
                "steelblue"           : {'256':67  , 'full': '#5f87af'}, \
                "steelblue3"          : {'256':68  , 'full': '#5f87d7'}, \
                "cornflowerblue"      : {'256':69  , 'full': '#5f87ff'}, \
                "chartreuse3"         : {'256':70  , 'full': '#5faf00'}, \
                "darkseagreen4"       : {'256':71  , 'full': '#5faf5f'}, \
                "cadetblue"           : {'256':72  , 'full': '#5faf87'}, \
                "cadetblue"           : {'256':73  , 'full': '#5fafaf'}, \
                "skyblue3"            : {'256':74  , 'full': '#5fafd7'}, \
                "steelblue1"          : {'256':75  , 'full': '#5fafff'}, \
                "chartreuse3"         : {'256':76  , 'full': '#5fd700'}, \
                "palegreen3"          : {'256':77  , 'full': '#5fd75f'}, \
                "seagreen3"           : {'256':78  , 'full': '#5fd787'}, \
                "aquamarine3"         : {'256':79  , 'full': '#5fd7af'}, \
                "mediumturquoise"     : {'256':80  , 'full': '#5fd7d7'}, \
                "steelblue1"          : {'256':81  , 'full': '#5fd7ff'}, \
                "chartreuse2"         : {'256':82  , 'full': '#5fff00'}, \
                "seagreen2"           : {'256':83  , 'full': '#5fff5f'}, \
                "seagreen1"           : {'256':84  , 'full': '#5fff87'}, \
                "seagreen1"           : {'256':85  , 'full': '#5fffaf'}, \
                "aquamarine1"         : {'256':86  , 'full': '#5fffd7'}, \
                "darkslategray2"      : {'256':87  , 'full': '#5fffff'}, \
                "darkslategrey2"      : {'256':87  , 'full': '#5fffff'}, \
                "darkred"             : {'256':88  , 'full': '#870000'}, \
                "deeppink4"           : {'256':89  , 'full': '#87005f'}, \
                "darkmagenta"         : {'256':90  , 'full': '#870087'}, \
                "darkmagenta"         : {'256':91  , 'full': '#8700af'}, \
                "darkviolet"          : {'256':92  , 'full': '#8700d7'}, \
                "purple"              : {'256':93  , 'full': '#8700ff'}, \
                "orange4"             : {'256':94  , 'full': '#875f00'}, \
                "lightpink4"          : {'256':95  , 'full': '#875f5f'}, \
                "plum4"               : {'256':96  , 'full': '#875f87'}, \
                "mediumpurple3"       : {'256':97  , 'full': '#875faf'}, \
                "mediumpurple3"       : {'256':98  , 'full': '#875fd7'}, \
                "slateblue1"          : {'256':99  , 'full': '#875fff'}, \
                "yellow4"             : {'256':100 , 'full': '#878700'}, \
                "wheat4"              : {'256':101 , 'full': '#87875f'}, \
                "gray53"              : {'256':102 , 'full': '#878787'}, \
                "grey53"              : {'256':102 , 'full': '#878787'}, \
                "lightslategray"      : {'256':103 , 'full': '#8787af'}, \
                "lightslategrey"      : {'256':103 , 'full': '#8787af'}, \
                "mediumpurple"        : {'256':104 , 'full': '#8787d7'}, \
                "lightslateblue"      : {'256':105 , 'full': '#8787ff'}, \
                "yellow4"             : {'256':106 , 'full': '#87af00'}, \
                "darkolivegreen3"     : {'256':107 , 'full': '#87af5f'}, \
                "darkseagreen"        : {'256':108 , 'full': '#87af87'}, \
                "lightskyblue3"       : {'256':109 , 'full': '#87afaf'}, \
                "lightskyblue3"       : {'256':110 , 'full': '#87afd7'}, \
                "skyblue2"            : {'256':111 , 'full': '#87afff'}, \
                "chartreuse2"         : {'256':112 , 'full': '#87d700'}, \
                "darkolivegreen3"     : {'256':113 , 'full': '#87d75f'}, \
                "palegreen3"          : {'256':114 , 'full': '#87d787'}, \
                "darkseagreen3"       : {'256':115 , 'full': '#87d7af'}, \
                "darkslategray3"      : {'256':116 , 'full': '#87d7d7'}, \
                "darkslategrey3"      : {'256':116 , 'full': '#87d7d7'}, \
                "skyblue1"            : {'256':117 , 'full': '#87d7ff'}, \
                "chartreuse1"         : {'256':118 , 'full': '#87ff00'}, \
                "lightgreen"          : {'256':119 , 'full': '#87ff5f'}, \
                "lightgreen"          : {'256':120 , 'full': '#87ff87'}, \
                "palegreen1"          : {'256':121 , 'full': '#87ffaf'}, \
                "aquamarine1"         : {'256':122 , 'full': '#87ffd7'}, \
                "darkslategray1"      : {'256':123 , 'full': '#87ffff'}, \
                "darkslategrey1"      : {'256':123 , 'full': '#87ffff'}, \
                "red3"                : {'256':124 , 'full': '#af0000'}, \
                "deeppink4"           : {'256':125 , 'full': '#af005f'}, \
                "mediumvioletred"     : {'256':126 , 'full': '#af0087'}, \
                "magenta3"            : {'256':127 , 'full': '#af00af'}, \
                "darkviolet"          : {'256':128 , 'full': '#af00d7'}, \
                "purple"              : {'256':129 , 'full': '#af00ff'}, \
                "darkorange3"         : {'256':130 , 'full': '#af5f00'}, \
                "indianred"           : {'256':131 , 'full': '#af5f5f'}, \
                "hotpink3"            : {'256':132 , 'full': '#af5f87'}, \
                "mediumorchid3"       : {'256':133 , 'full': '#af5faf'}, \
                "mediumorchid"        : {'256':134 , 'full': '#af5fd7'}, \
                "mediumpurple2"       : {'256':135 , 'full': '#af5fff'}, \
                "darkgoldenrod"       : {'256':136 , 'full': '#af8700'}, \
                "lightsalmon3"        : {'256':137 , 'full': '#af875f'}, \
                "rosybrown"           : {'256':138 , 'full': '#af8787'}, \
                "gray63"              : {'256':139 , 'full': '#af87af'}, \
                "grey63"              : {'256':139 , 'full': '#af87af'}, \
                "mediumpurple2"       : {'256':140 , 'full': '#af87d7'}, \
                "mediumpurple1"       : {'256':141 , 'full': '#af87ff'}, \
                "gold3"               : {'256':142 , 'full': '#afaf00'}, \
                "darkkhaki"           : {'256':143 , 'full': '#afaf5f'}, \
                "navajowhite3"        : {'256':144 , 'full': '#afaf87'}, \
                "gray69"              : {'256':145 , 'full': '#afafaf'}, \
                "grey69"              : {'256':145 , 'full': '#afafaf'}, \
                "lightsteelblue3"     : {'256':146 , 'full': '#afafd7'}, \
                "lightsteelblue"      : {'256':147 , 'full': '#afafff'}, \
                "yellow3"             : {'256':148 , 'full': '#afd700'}, \
                "darkolivegreen3"     : {'256':149 , 'full': '#afd75f'}, \
                "darkseagreen3"       : {'256':150 , 'full': '#afd787'}, \
                "darkseagreen2"       : {'256':151 , 'full': '#afd7af'}, \
                "lightcyan3"          : {'256':152 , 'full': '#afd7d7'}, \
                "lightskyblue1"       : {'256':153 , 'full': '#afd7ff'}, \
                "greenyellow"         : {'256':154 , 'full': '#afff00'}, \
                "darkolivegreen2"     : {'256':155 , 'full': '#afff5f'}, \
                "palegreen1"          : {'256':156 , 'full': '#afff87'}, \
                "darkseagreen2"       : {'256':157 , 'full': '#afffaf'}, \
                "darkseagreen1"       : {'256':158 , 'full': '#afffd7'}, \
                "paleturquoise1"      : {'256':159 , 'full': '#afffff'}, \
                "red3"                : {'256':160 , 'full': '#d70000'}, \
                "deeppink3"           : {'256':161 , 'full': '#d7005f'}, \
                "deeppink3"           : {'256':162 , 'full': '#d70087'}, \
                "magenta3"            : {'256':163 , 'full': '#d700af'}, \
                "magenta3"            : {'256':164 , 'full': '#d700d7'}, \
                "magenta2"            : {'256':165 , 'full': '#d700ff'}, \
                "darkorange3"         : {'256':166 , 'full': '#d75f00'}, \
                "indianred"           : {'256':167 , 'full': '#d75f5f'}, \
                "hotpink3"            : {'256':168 , 'full': '#d75f87'}, \
                "hotpink2"            : {'256':169 , 'full': '#d75faf'}, \
                "orchid"              : {'256':170 , 'full': '#d75fd7'}, \
                "mediumorchid1"       : {'256':171 , 'full': '#d75fff'}, \
                "orange3"             : {'256':172 , 'full': '#d78700'}, \
                "lightsalmon3"        : {'256':173 , 'full': '#d7875f'}, \
                "lightpink3"          : {'256':174 , 'full': '#d78787'}, \
                "pink3"               : {'256':175 , 'full': '#d787af'}, \
                "plum3"               : {'256':176 , 'full': '#d787d7'}, \
                "violet"              : {'256':177 , 'full': '#d787ff'}, \
                "gold3"               : {'256':178 , 'full': '#d7af00'}, \
                "lightgoldenrod3"     : {'256':179 , 'full': '#d7af5f'}, \
                "tan"                 : {'256':180 , 'full': '#d7af87'}, \
                "mistyrose3"          : {'256':181 , 'full': '#d7afaf'}, \
                "thistle3"            : {'256':182 , 'full': '#d7afd7'}, \
                "plum2"               : {'256':183 , 'full': '#d7afff'}, \
                "yellow3"             : {'256':184 , 'full': '#d7d700'}, \
                "khaki3"              : {'256':185 , 'full': '#d7d75f'}, \
                "lightgoldenrod2"     : {'256':186 , 'full': '#d7d787'}, \
                "lightyellow3"        : {'256':187 , 'full': '#d7d7af'}, \
                "gray84"              : {'256':188 , 'full': '#d7d7d7'}, \
                "grey84"              : {'256':188 , 'full': '#d7d7d7'}, \
                "lightsteelblue1"     : {'256':189 , 'full': '#d7d7ff'}, \
                "yellow2"             : {'256':190 , 'full': '#d7ff00'}, \
                "darkolivegreen1"     : {'256':191 , 'full': '#d7ff5f'}, \
                "darkolivegreen1"     : {'256':192 , 'full': '#d7ff87'}, \
                "darkseagreen1"       : {'256':193 , 'full': '#d7ffaf'}, \
                "honeydew2"           : {'256':194 , 'full': '#d7ffd7'}, \
                "lightcyan1"          : {'256':195 , 'full': '#d7ffff'}, \
                "red1"                : {'256':196 , 'full': '#ff0000'}, \
                "deeppink2"           : {'256':197 , 'full': '#ff005f'}, \
                "deeppink1"           : {'256':198 , 'full': '#ff0087'}, \
                "deeppink1"           : {'256':199 , 'full': '#ff00af'}, \
                "magenta2"            : {'256':200 , 'full': '#ff00d7'}, \
                "magenta1"            : {'256':201 , 'full': '#ff00ff'}, \
                "orangered1"          : {'256':202 , 'full': '#ff5f00'}, \
                "indianred1"          : {'256':203 , 'full': '#ff5f5f'}, \
                "indianred1"          : {'256':204 , 'full': '#ff5f87'}, \
                "hotpink"             : {'256':205 , 'full': '#ff5faf'}, \
                "hotpink"             : {'256':206 , 'full': '#ff5fd7'}, \
                "mediumorchid1"       : {'256':207 , 'full': '#ff5fff'}, \
                "darkorange"          : {'256':208 , 'full': '#ff8700'}, \
                "salmon1"             : {'256':209 , 'full': '#ff875f'}, \
                "lightcoral"          : {'256':210 , 'full': '#ff8787'}, \
                "palevioletred1"      : {'256':211 , 'full': '#ff87af'}, \
                "orchid2"             : {'256':212 , 'full': '#ff87d7'}, \
                "orchid1"             : {'256':213 , 'full': '#ff87ff'}, \
                "orange1"             : {'256':214 , 'full': '#ffaf00'}, \
                "sandybrown"          : {'256':215 , 'full': '#ffaf5f'}, \
                "lightsalmon1"        : {'256':216 , 'full': '#ffaf87'}, \
                "lightpink1"          : {'256':217 , 'full': '#ffafaf'}, \
                "pink1"               : {'256':218 , 'full': '#ffafd7'}, \
                "plum1"               : {'256':219 , 'full': '#ffafff'}, \
                "gold1"               : {'256':220 , 'full': '#ffd700'}, \
                "lightgoldenrod2"     : {'256':221 , 'full': '#ffd75f'}, \
                "lightgoldenrod2"     : {'256':222 , 'full': '#ffd787'}, \
                "navajowhite1"        : {'256':223 , 'full': '#ffd7af'}, \
                "mistyrose1"          : {'256':224 , 'full': '#ffd7d7'}, \
                "thistle1"            : {'256':225 , 'full': '#ffd7ff'}, \
                "yellow1"             : {'256':226 , 'full': '#ffff00'}, \
                "lightgoldenrod1"     : {'256':227 , 'full': '#ffff5f'}, \
                "khaki1"              : {'256':228 , 'full': '#ffff87'}, \
                "wheat1"              : {'256':229 , 'full': '#ffffaf'}, \
                "cornsilk1"           : {'256':230 , 'full': '#ffffd7'}, \
                "gray100"             : {'256':231 , 'full': '#ffffff'}, \
                "grey100"             : {'256':231 , 'full': '#ffffff'}, \
                "gray3"               : {'256':232 , 'full': '#080808'}, \
                "grey3"               : {'256':232 , 'full': '#080808'}, \
                "gray7"               : {'256':233 , 'full': '#121212'}, \
                "grey7"               : {'256':233 , 'full': '#121212'}, \
                "gray11"              : {'256':234 , 'full': '#1c1c1c'}, \
                "grey11"              : {'256':234 , 'full': '#1c1c1c'}, \
                "gray15"              : {'256':235 , 'full': '#262626'}, \
                "grey15"              : {'256':235 , 'full': '#262626'}, \
                "gray19"              : {'256':236 , 'full': '#303030'}, \
                "grey19"              : {'256':236 , 'full': '#303030'}, \
                "gray23"              : {'256':237 , 'full': '#3a3a3a'}, \
                "grey23"              : {'256':237 , 'full': '#3a3a3a'}, \
                "gray27"              : {'256':238 , 'full': '#444444'}, \
                "grey27"              : {'256':238 , 'full': '#444444'}, \
                "gray30"              : {'256':239 , 'full': '#4e4e4e'}, \
                "grey30"              : {'256':239 , 'full': '#4e4e4e'}, \
                "gray35"              : {'256':240 , 'full': '#585858'}, \
                "grey35"              : {'256':240 , 'full': '#585858'}, \
                "gray39"              : {'256':241 , 'full': '#626262'}, \
                "grey39"              : {'256':241 , 'full': '#626262'}, \
                "gray42"              : {'256':242 , 'full': '#6c6c6c'}, \
                "grey42"              : {'256':242 , 'full': '#6c6c6c'}, \
                "gray46"              : {'256':243 , 'full': '#767676'}, \
                "grey46"              : {'256':243 , 'full': '#767676'}, \
                "gray50"              : {'256':244 , 'full': '#808080'}, \
                "grey50"              : {'256':244 , 'full': '#808080'}, \
                "gray54"              : {'256':245 , 'full': '#8a8a8a'}, \
                "grey54"              : {'256':245 , 'full': '#8a8a8a'}, \
                "gray58"              : {'256':246 , 'full': '#949494'}, \
                "grey58"              : {'256':246 , 'full': '#949494'}, \
                "gray62"              : {'256':247 , 'full': '#9e9e9e'}, \
                "grey62"              : {'256':247 , 'full': '#9e9e9e'}, \
                "gray66"              : {'256':248 , 'full': '#a8a8a8'}, \
                "grey66"              : {'256':248 , 'full': '#a8a8a8'}, \
                "gray70"              : {'256':249 , 'full': '#b2b2b2'}, \
                "grey70"              : {'256':249 , 'full': '#b2b2b2'}, \
                "gray74"              : {'256':250 , 'full': '#bcbcbc'}, \
                "grey74"              : {'256':250 , 'full': '#bcbcbc'}, \
                "gray78"              : {'256':251 , 'full': '#c6c6c6'}, \
                "grey78"              : {'256':251 , 'full': '#c6c6c6'}, \
                "gray82"              : {'256':252 , 'full': '#d0d0d0'}, \
                "grey82"              : {'256':252 , 'full': '#d0d0d0'}, \
                "gray85"              : {'256':253 , 'full': '#dadada'}, \
                "grey85"              : {'256':253 , 'full': '#dadada'}, \
                "gray89"              : {'256':254 , 'full': '#e4e4e4'}, \
                "grey89"              : {'256':254 , 'full': '#e4e4e4'}, \
                "gray93"              : {'256':255 , 'full': '#eeeeee'}, \
                "grey93"              : {'256':255 , 'full': '#eeeeee'}, \
        }

        try:
            import matplotlib.colors as mcolors
        except ImportError as e:
            if verbose:
                print('matplotlib is not imported.')
        else:
            named_colors = mcolors.get_named_colors_mapping()
            col_list.update(named_colors)

        for i in range(101):
            if 'gray{:d}'.format(i) in col_list:
                continue
            gray_level = int(255*i/100+0.5)
            col_list['gray{:d}'.format(i)] = {'256':None, 'full': '#{:02x}{:02x}{:02x}'.format(gray_level, gray_level, gray_level)}
            col_list['grey{:d}'.format(i)] = {'256':None, 'full': '#{:02x}{:02x}{:02x}'.format(gray_level, gray_level, gray_level)}

    if not color_name in col_list:
        if verbose:
            print('no match color name {} found. return None.'.format(color_name))
        return None
    else:
        col = col_list[color_name]
        if type(col) == dict:
            return col[color_type]
        elif type(col) == str:
            if color_type == 'full':
                return col_list[color_name]
            elif color_type == '256':
                r = int(col[1:3], 16)
                g = int(col[3:5], 16)
                b = int(col[5:7], 16)
                return convert_fullcolor_to_256(r, g, b)
        else:
            r, g, b = col
            if color_type == 'full':
                return '#{:02x}{:02x}{:02x}'.format(int(255*r), int(255*g), int(255*b))
            elif  color_type == '256':
                r = int(r*255)
                g = int(g*255)
                b = int(b*255)
                return convert_fullcolor_to_256(r, g, b)

def convert_256_to_fullcolor(color_index):
    if color_index < 16:
        color_list = [ \
                '#000000', \
                '#800000', \
                '#008000', \
                '#808000', \
                '#000080', \
                '#800080', \
                '#008080', \
                '#c0c0c0', \
                '#808080', \
                '#ff0000', \
                '#00ff00', \
                '#ffff00', \
                '#0000ff', \
                '#ff00ff', \
                '#00ffff', \
                '#ffffff', \
        ]
        return color_list[color_index]
    elif color_index < 232:
        r_index = int((color_index-16)/36)
        g_index = int((color_index-16-36*r_index)/6)
        b_index = int( color_index-16-36*r_index-6*g_index)
        if r_index != 0:
            r_index = 55+40*r_index
        if g_index != 0:
            g_index = 55+40*g_index
        if b_index != 0:
            b_index = 55+40*b_index
        return '#{:02x}{:02x}{:02x}'.format(r_index, g_index, b_index)
    elif color_index < 256:
        gray_level = 8+10*(color_index-232)
        return '#{:02x}{:02x}{:02x}'.format(gray_level, gray_level, gray_level)

def convert_fullcolor_to_256(r, g, b):
    r_index = int((r-55)/40+0.5)
    if r_index < 0:
        r_index = 0
    g_index = int((g-55)/40+0.5)
    if g_index < 0:
        g_index = 0
    b_index = int((b-55)/40+0.5)
    if b_index < 0:
        b_index = 0

    return 36*r_index+6*g_index+b_index+16

def main_test(num):
    print('system colors')
    for i in range(8):
        if num == 1:
            if i%2 == 0:    # even
                tmp_st = '{}{:02x}{}'.format(FG['w'], i, END)
            else:           # odd
                tmp_st = '{}{:02x}{}'.format(FG['k'], i, END)
        else:
            tmp_st = '  '
        print('{}{}{}'.format(BG256(i), tmp_st, END), end='')
    print()
    for i in range(8,16):
        if num == 1:
            if i%2 == 0:    # even
                tmp_st = '{}{:02x}{}'.format(FG['w'], i, END)
            else:           # odd
                tmp_st = '{}{:02x}{}'.format(FG['k'], i, END)
        else:
            tmp_st = '  '
        print('{}{}{}'.format(BG256(i), tmp_st, END), end='')
    print('\n')

    print('6x6x6 color blocks')
    for g in range(6):
        for r in range(6):
            for b in range(6):
                i = 36*r+6*g+b+16
                if num == 0:
                    tmp_st = '  '
                elif num == 1:
                    if i%2 == 0:    # even
                        tmp_st = '{}{:02x}{}'.format(FG['w'], i, END)
                    else:           # odd
                        tmp_st = '{}{:02x}{}'.format(FG['k'], i, END)
                else:
                    # tmp_st = '{}{:02x}{}'.format(FG256(36*((r+3)%6)+6*((g+3)%6)+(b+3)%6+16), i, END)
                    dark_new, dark_old = isdark(r, g, b)
                    if dark_new:
                        tmp_st = '{}{:02x}{}'.format(FG256(255), i, END)
                    else:
                        tmp_st = '{}{:02x}{}'.format(FG256(234), i, END)
                print('{}{}{}'.format(BG256(i), tmp_st, END), end='')
            print(' ', end='')
        print()
    print()

    print('gray scales')
    st = 6*6*6+16
    for i in range(st, 256):
        if num == 1:
            tmp_st = '{}{:02x}{}'.format(FG256(255+st-i), i, END)
        else:
            tmp_st = '  '
        print('{}{}{}'.format(BG256(i), tmp_st, END), end='')
    print('\n')

    if num == 2:
        for r in range(6):
            for g in range(6):
                for b in range(6):
                    i = 36*r+6*g+b+16
                    dark_new, dark_old = isdark(r, g, b)
                    if dark_new != dark_old:
                        if dark_new:
                            fg1 = FG256(255)
                            fg2 = FG256(234)
                        else:
                            fg1 = FG256(234)
                            fg2 = FG256(255)
                        print('{}{}{:02x}{} -> {}{}{:03d}{}'.format(BG256(i), fg2, i, END, BG256(i), fg1, i, END), end=' ')
        print()

if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--num', help='0... no fg, 1... show number, 2... is_dark', choices=[0,1,2], type=int, default=0)
    args = parser.parse_args()

    main_test(args.num)

