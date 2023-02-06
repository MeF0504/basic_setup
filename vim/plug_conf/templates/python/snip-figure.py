fig{{_input_:fignum}} = plt.figure()
{{_expr_:map(range(1, {{_input_:row}}*{{_input_:col}}), "printf('ax{{_input_:fignum}}%d = fig{{_input_:fignum}}.add_subplot({{_input_:row}}{{_input_:col}}%d)', v:val, v:val)")}}{{_cursor_}}
