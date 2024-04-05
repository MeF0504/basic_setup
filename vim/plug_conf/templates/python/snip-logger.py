from logging import getLogger, StreamHandler, NullHandler, Formatter, \
    DEBUG as logDEBUG, INFO as logINFO

logger = getLogger({{_expr_:empty('{{_input_:logname}}') ? '__file__' : '{{_input_:logname}}'}})
logger.setLevel(logDEBUG)
st_hdlr = StreamHandler()
st_hdlr.setLevel(logINFO)
st_frmt = '\033[32m>> %(levelname)-9s %(message)s\033[0m'
st_hdlr.setFormatter(Formatter(st_frmt))
logger.addHandler(st_hdlr)
# null_hdlr = NullHandler()
# logger.addHandler(null_hdlr)
{{_cursor_}}
