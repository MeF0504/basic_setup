echoenvall()
{
    if which python3 > /dev/null 2>&1; then
        cmd=python3
    else
        cmd=python
    fi
    ${cmd} -c 'import os;[print("{} :\t{}".format(k, v)) for k,v in os.environ.items()]'
}

