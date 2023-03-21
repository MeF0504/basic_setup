fig{{_input_:fignum}} = plt.figure()
ax{{_input_:fignum}}1 = fig{{_input_:fignum}}.add_subplot({{_input_:row}}, {{_input_:col}}, 1)
{{_cursor_}}
{{_expr_:map(range(2, {{_input_:row}}*{{_input_:col}}), "printf('ax{{_input_:fignum}}%d = fig{{_input_:fignum}}.add_subplot({{_input_:row}}, {{_input_:col}}, %d)', v:val, v:val)")}}
