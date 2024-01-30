today_percentage()
{
    if which python3 > /dev/null 2>&1; then
        python3 -c "
from datetime import datetime
tdy = datetime.today()
year = tdy.year
st = datetime(year=year, month=1, day=1, hour=0, minute=0, second=0)
end = datetime(year=year, month=12, day=31, hour=23, minute=59, second=59)
print('{:.2f}'.format(100*(tdy-st)/(end-st)))
"
    fi
}

