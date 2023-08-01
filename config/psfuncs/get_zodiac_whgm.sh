_get_zodiac_whgm()
{
    # 星座 - 和風月名
    case "$(date '+%m')" in
        01)
            if [[ $(date '+%-d') -lt 19 ]]; then
                # CAPRICORN, 山羊座
                num=9
            else
                # AQUARIUS, 水瓶座
                num=10
            fi
            whgm=睦月
            ;;
        02)
            if [[ $(date '+%-d') -lt 18 ]]; then
                # AQUARIUS, 水瓶座
                num=10
            else
                # PISCES, 魚座
                num=11
            fi
            whgm=如月
            ;;
        03)
            if [[ $(date '+%-d') -lt 20 ]]; then
                # PISCES, 魚座
                num=11
            else
                # ARIES, 牡羊座
                num=0
            fi
            whgm=弥生
            ;;
        04)
            if [[ $(date '+%-d') -lt 19 ]]; then
                # ARIES, 牡羊座
                num=0
            else
                #TAURUS, 牡牛座
                num=1
            fi
            whgm=卯月
            ;;
        05)
            if [[ $(date '+%-d') -lt 20 ]]; then
                #TAURUS, 牡牛座
                num=1
            else
                # GEMINI, 双子座
                num=2
            fi
            whgm=皐月
            ;;
        06)
            if [[ $(date '+%-d') -lt 21 ]]; then
                # GEMINI, 双子座
                num=2
            else
                # CANCER, 蟹座
                num=3
            fi
            whgm=水無月
            ;;
        07)
            if [[ $(date '+%-d') -lt 22 ]]; then
                # CANCER, 蟹座
                num=3
            else
                # LEO, 獅子座
                num=4
            fi
            whgm=文月
            ;;
        08)
            if [[ $(date '+%-d') -lt 22 ]]; then
                # LEO, しし座
                num=4
            else
                # VIRGO, 乙女座
                num=5
            fi
            whgm=葉月
            ;;
        09)
            if [[ $(date '+%-d') -lt 23 ]]; then
                # VIRGO, 乙女座
                num=5
            else
                # LIBRA, てんびん座
                num=6
            fi
            whgm=長月
            ;;
        10)
            if [[ $(date '+%-d') -lt 23 ]]; then
                # LIBRA, てんびん座
                num=6
            else
                # SCORPIUS, 蠍座
                num=7
            fi
            whgm=神無月
            ;;
        11)
            if [[ $(date '+%-d') -lt 22 ]]; then
                # SCORPIUS, 蠍座
                num=7
            else
                # SAGITTARIUS, 射手座
                num=8
            fi
            whgm=霜月
            ;;
        12)
            if [[ $(date '+%-d') -lt 21 ]]; then
                # SAGITTARIUS, 射手座
                num=8
            else
                # CAPRICORN, 山羊座
                num=9
            fi
            whgm=師走
            ;;
    esac
    code=$(printf "%X\n" $((num+9800)))
    echo "\U${code}[${whgm}]"
}

