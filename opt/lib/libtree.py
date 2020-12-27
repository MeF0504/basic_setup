# library that supports to show files in tree form.

import os
from pathlib import PurePath

debug = True
branch_str  = '|__ '
branch_str2 = '|   '

class tree_viewer():
    def __init__(self, tree_list, root):
        self.tree = tree_list
        self.root = root    # root path
        self.current = None     # current dir's list-contents
        self.parents = []       # list of parents' list-contents
        self.next = None        # next dir's list-contents
        self.cpath = None       # current path
        self.cnt = 0
        self.is_finish = False

    def __iter__(self):
        return self

    def __next__(self):
        if self.is_finish or (self.cnt == -1):
            if debug:
                print('finish: cur:{}, cnt:{}'.format(self.current, self.cnt))
            raise StopIteration()
        self.cnt += 1
        if self.current is None:
            # return root directory
            if debug:
                print('pattern 1')
            self.current = self.tree
            self.cpath = PurePath(self.root)
        else:
            # other directories
            files, dirs = self.get_contents(self.current)
            if len(dirs) != 0:
                # go to a directory in this directory
                self.parents.append(self.current)
                if debug:
                    print('pattern 2')
                    print('from {}, to dirs:{}[0]'.format(self.cpath.name, dirs))
                self.current = self.current[0][dirs[0]]
                self.cpath /= dirs[0]
            else:
                # no dirs in this directory
                # -> search the parent directories
                for i in range(len(self.parents)):
                    files, dirs = self.get_contents(self.parents[-1])
                    if debug:
                        print('pattern 3-{}'.format(i))
                        print('\n parents:{},\n dirs:{}'.format(self.parents, dirs))
                    index = dirs.index(self.cpath.name)+1
                    if index < len(dirs):
                        # not a last directory in parent directory
                        self.current = self.parents[-1][0][dirs[index]]
                        self.cpath = self.cpath.parent / dirs[index]
                        if debug:
                            print('return current:{}, cpath:{}, parents:{}'.format(self.current, self.cpath, self.parents))
                        if (len(self.parents) == 1) and (index+1 == len(dirs)):
                            # at the directory just under the root  and the last directory
                            self.is_finish = True
                        break
                    else:
                        # go up to parents
                        self.current = self.parents.pop()
                        self.cpath = self.cpath.parent
                        if debug:
                            print('cur: {},\n cpath:{}'.format(self.current, self.cpath))
                            print(self.parents)
        files, dirs = self.get_contents(self.current)
        return self.cpath, files, dirs

    def get_contents(self, tree_list):
        if len(tree_list) == 0:
            return [], []
        files = tree_list[1:]
        files.sort()
        dirs = list(tree_list[0].keys())
        dirs.sort()

        return files, dirs

def show_contents(cpath, files, dirs):
    dnum = str(cpath).count(os.sep)
    if dnum == 0:
        # root
        print('{}/'.format(cpath.name))
    else:
        print('{}{} {}/'.format(branch_str2*(dnum-1), branch_str, cpath.name))
    for f in files:
        print('{}{} {}'.format(branch_str2*dnum, branch_str, f))

def show_tree(tree, root='.'):
    tree_view = tree_viewer(tree, root)
    for cpath, files, dirs in tree_view:
        if debug:
            print(cpath, files, dirs)
        show_contents(cpath, files, dirs)

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

