st_hdlr = StreamHandler()
st_hdlr.setLevel(logINFO)
st_frmt = '\033[32m>> %(levelname)-9s %(message)s\033[0m'
st_hdlr.setFormatter(Formatter(st_frmt))
logger.addHandler(st_hdlr)
{{_cursor_}}
