logger = getLogger({{_expr_:empty('{{_input_:logname}}') ? '__file__' : '{{_input_:logname}}'}})
logger.setLevel(logDEBUG)
{{_cursor_}}
