def main(cursor):
    cursor.add_argument('--projection', help='specify the projection',
                        choices=['mollweide', 'gnomonic',
                                 'cartesian', 'orthographic'],
                        )
    cursor.add_argument('--norm', help='specify color normalization',
                        choices=['hist', 'log', 'None'])
    cursor.add_argument('--cl', help='show cl', action='store_true')
    cursor.add_argument('--coord', help='Either one of ‘G’, ‘E’ or ‘C’' +
                        ' to describe the coordinate system of the map, or' +
                        ' a sequence of 2 of these to rotate the map from' +
                        ' the first to the second coordinate system.',
                        nargs='*')
