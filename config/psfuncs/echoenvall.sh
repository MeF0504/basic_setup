echoenvall()
{
    python -c 'import os;[print("{} :\t{}".format(k, v)) for k,v in os.environ.items()]'
}

