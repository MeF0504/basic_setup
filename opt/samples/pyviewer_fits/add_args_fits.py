def main(cursor):
    cursor.add_argument('--projection', help='(healpy) specify the projection',
                        choices=['mollweide', 'gnomonic',
                                 'cartesian', 'orthographic'],
                        )
    cursor.add_argument('--norm', help='(healpy) specify color normalization',
                        choices=['hist', 'log', 'None'])
    cursor.add_argument('--cl', help='(healpy) show cl', action='store_true')
    cursor.add_argument('--coord', help='(healpy) Either one of' +
                        ' ‘G’, ‘E’ or ‘C’' +
                        ' to describe the coordinate system of the map, or' +
                        ' a sequence of 2 of these to rotate the map from' +
                        ' the first to the second coordinate system.',
                        nargs='*')
    cursor.add_argument('--log_scale', help='(astropy) scale color in log.',
                        action='store_true')
