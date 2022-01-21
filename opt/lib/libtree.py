# library that supports to show files in tree form.

import os
from pathlib import PurePath

debug = False
branch_str  = '|__ '
branch_str2 = '|   '

class tree_viewer():
    def __init__(self, tree_list, root):
        self.tree = tree_list
        self.root = root    # root path
        self.cpath = None   # current path
        self.cnt = 0
        self.is_finish = False

    def __iter__(self):
        return self

    def __next__(self):
        if debug:
            print('\n__next__ start')
        if self.is_finish or (self.cnt == -1):
            if debug:
                print('finish: cur:{}, cnt:{}'.format(self.cpath, self.cnt))
            raise StopIteration()
        self.cnt += 1
        if self.cpath is None:
            # return root directory
            if debug:
                print('pattern 1 @ {}'.format(self.cpath))
            self.cpath = PurePath(self.root).relative_to(self.root)
        else:
            # other directories
            files, dirs = self.get_contents(self.cpath)
            if (str(self.cpath)=='.') and (len(dirs)==0):
                self.is_finish = True
            if len(dirs) != 0:
                # go to a directory in this directory
                if debug:
                    print('pattern 2 @ {}'.format(self.cpath))
                    print('from {}, to dirs:{}[0]'.format(self.cpath.name, dirs))
                self.cpath /= dirs[0]
            else:
                # no dirs in this directory
                # -> search the parent directories
                for par in self.cpath.parents:
                    files, dirs = self.get_contents(par)
                    if debug:
                        print('pattern 3 @ {}->{}'.format(self.cpath, par))
                        print('parent:{}, dirs:{}'.format(self.cpath.parent, dirs))
                    index = dirs.index(self.cpath.name)+1
                    if index < len(dirs):
                        # not a last directory in parent directory
                        self.cpath = self.cpath.parent / dirs[index]
                        if debug:
                            print('return cpath:{}, index:{}, parent:{}, len(parents):{}'.format(self.cpath, index, self.cpath.parent, len(self.cpath.parents)))
                        break
                    else:
                        # go up to parents
                        self.cpath = self.cpath.parent
                        if debug:
                            print('continue; cpath:{}, index:{}'.format(self.cpath, index))
                        if (str(self.cpath)=='.') and (index>=len(dirs)):
                            # at root directory and no contents after this
                            if debug:
                                print('is_finish')
                            self.is_finish = True

        files, dirs = self.get_contents(self.cpath)
        return self.cpath, files, dirs

    def get_contents(self, path):
        if self.is_finish:
            return None, None
        if type(path) != type(PurePath('.')):
            path = PurePath(path)

        if str(path) == '.':
            if debug:
                print('get_contents @ root:{}'.format(self.root))
            tree_list = self.tree
        else:
            if debug:
                print('get_contents @ {}'.format(path))
            tree_list = self.tree
            for p in path.parts:
                if (str(p)==self.root): continue
                else: tree_list = tree_list[0][str(p)]
        if debug:
            print('get tree_list:{}'.format(tree_list))

        if len(tree_list) == 0:
            return [], []
        files = tree_list[1:]
        files.sort()
        dirs = list(tree_list[0].keys())
        dirs.sort()

        return files, dirs

def show_contents(root, cpath, files, dirs, add_info=None):
    if str(cpath) == '.':
        # root
        print('{}/'.format(root))
        for f in files:
            if add_info is None:
                add_info_str = ''
            else:
                add_info_str = add_info(root/cpath/f)

            print('{}{}{}'.format(branch_str, f, add_info_str))
    else:
        if add_info is None:
            add_info_str = ''
        else:
            add_info_str = add_info(root/cpath)

        dnum = str(cpath).count(os.sep)
        print('{}{}{}/{}'.format(branch_str2*(dnum), branch_str, cpath.name, add_info_str))
        for f in files:
            if add_info is None:
                add_info_str = ''
            else:
                add_info_str = add_info(root/cpath/f)

            print('{}{}{}{}'.format(branch_str2*(dnum+1), branch_str, f, add_info_str))

def show_tree(tree, root='.', add_info=None):
    tree_view = tree_viewer(tree, root)
    for cpath, files, dirs in tree_view:
        if debug:
            print(cpath, files, dirs)
        if (files is not None) and (dirs is not None):
            show_contents(root, cpath, files, dirs, add_info)

def get_list(tree, root='.'):
    tree_view = tree_viewer(tree, root)
    res_dirs = []
    res_files = []
    for cpath, files, dirs in tree_view:
        if (files is not None) and (dirs is not None):
            res_dirs.append(str(root/cpath))
            for f in files:
                res_files.append(str(root/cpath/f))
    return res_files, res_dirs

if __name__ == '__main__':
    test_data = [\
            { \
            'dir2':[ \
                { \
                'dir3':[ \
                    {}, 'file3-1'], \
                'dir4':[ \
                    {}, 'file4-1']}, \
                'file2-1', 'file2-2',], \
            'dir5':[ \
                {}, 'file5-1'], \
            }, \
            'file1-1',]
    if debug:
        print(test_data)
    show_tree(test_data, 'dir1')
    '''
    dir1/
    |__ file1-1
    |__ dir2/
    |   |__ file2-1
    |   |__ file2-2
    |   |__ dir3/
    |   |   |__ file3-1
    |   |__ dir4/
    |   |   |__ file4-1
    |__ dir5/
    |   |__ file5-1
    '''

