echoenv()
{
    echo -ne "${*//:/\\n}"
    echo ''
}

