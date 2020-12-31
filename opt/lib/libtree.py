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
        self.cpath = None       # current path
        self.cnt = 0
        self.is_finish = False

    def __iter__(self):
        return self

    def __next__(self):
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
            if len(dirs) != 0:
                # go to a directory in this directory
                if debug:
                    print('pattern 2 @ {}'.format(self.cpath))
                    print('from {}, to dirs:{}[0]'.format(self.cpath.name, dirs))
                self.cpath /= dirs[0]
            else:
                # no dirs in this directory
                # -> search the parent directories
                for i in range(len(self.cpath.parents)):
                    files, dirs = self.get_contents(self.cpath.parent)
                    if debug:
                        print('pattern 3-{}/{} @ {}'.format(i, len(self.cpath.parents)-1, self.cpath))
                        print('parent:{}, dirs:{}'.format(self.cpath.parent, dirs))
                    index = dirs.index(self.cpath.name)+1
                    if index < len(dirs):
                        # not a last directory in parent directory
                        self.cpath = self.cpath.parent / dirs[index]
                        if debug:
                            print('return cpath:{}, index:{}, parent:{}, len(parents):{}'.format(self.cpath, index, self.cpath.parent, len(self.cpath.parents)))
                        if (len(self.cpath.parents)==1) and (index+1 == len(dirs)):
                            # at the directory just under the root  and the last directory
                            self.is_finish = True
                        break
                    else:
                        # go up to parents
                        self.cpath = self.cpath.parent
                        if debug:
                            print('continue; cpath:{}, index:{}'.format(self.cpath, index))
        files, dirs = self.get_contents(self.cpath)
        return self.cpath, files, dirs

    def get_contents(self, path):
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

def show_contents(root, cpath, files, dirs):
    if str(cpath) == '.':
        # root
        print('{}/'.format(root))
        for f in files:
            print('{} {}'.format(branch_str, f))
    else:
        dnum = str(cpath).count(os.sep)
        print('{}{} {}/'.format(branch_str2*(dnum), branch_str, cpath.name))
        for f in files:
            print('{}{} {}'.format(branch_str2*(dnum+1), branch_str, f))

def show_tree(tree, root='.'):
    tree_view = tree_viewer(tree, root)
    for cpath, files, dirs in tree_view:
        if debug:
            print(cpath, files, dirs)
        show_contents(root, cpath, files, dirs)

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

