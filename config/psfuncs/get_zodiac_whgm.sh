_get_zodiac_whgm()
{
    # 星座 - 和風月名
    case "$(date '+%m')" in
        01)
            if [[ $(date '+%-d') -lt 19 ]]; then
                num=9
            else
                num=A
            fi
            whgm=睦月
            ;;
        02)
            if [[ $(date '+%-d') -lt 18 ]]; then
                num=A
            else
                num=B
            fi
            whgm=如月
            ;;
        03)
            if [[ $(date '+%-d') -lt 20 ]]; then
                num=B
            else
                num=0
            fi
            whgm=弥生
            ;;
        04)
            if [[ $(date '+%-d') -lt 19 ]]; then
                num=0
            else
                num=1
            fi
            whgm=卯月
            ;;
        05)
            if [[ $(date '+%-d') -lt 20 ]]; then
                num=1
            else
                num=2
            fi
            whgm=皐月
            ;;
        06)
            if [[ $(date '+%-d') -lt 21 ]]; then
                num=2
            else
                num=3
            fi
            whgm=水無月
            ;;
        07)
            if [[ $(date '+%-d') -lt 22 ]]; then
                num=3
            else
                num=4
            fi
            whgm=文月
            ;;
        08)
            if [[ $(date '+%-d') -lt 22 ]]; then
                num=4
            else
                num=5
            fi
            whgm=葉月
            ;;
        09)
            if [[ $(date '+%-d') -lt 23 ]]; then
                num=5
            else
                num=6
            fi
            whgm=長月
            ;;
        10)
            if [[ $(date '+%-d') -lt 23 ]]; then
                num=6
            else
                num=7
            fi
            whgm=神無月
            ;;
        11)
            if [[ $(date '+%-d') -lt 22 ]]; then
                num=7
            else
                num=8
            fi
            whgm=霜月
            ;;
        12)
            if [[ $(date '+%-d') -lt 21 ]]; then
                num=8
            else
                num=9
            fi
            whgm=師走
            ;;
    esac
    code=$(printf "%X\n" $((num+9800)))
    echo "\U${code}[${whgm}]"
}

