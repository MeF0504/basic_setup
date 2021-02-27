
from __future__ import print_function
import os
import os.path as op

def mkdir(path):
    path = op.expanduser(path)
    if not op.exists(path):
        print('mkdir '+path)
        os.makedirs(path, mode=0o755)
        #os.chmod(path,0755)

def chk_cmd(cmd, verbose=False):   # check the command exists.
    if not 'PATH' in os.environ:
        if verbose: print("PATH isn't found in environment values.")
        return False
    for path in os.environ['PATH'].split(os.pathsep):
        cmd_path = op.join(path, cmd)
        if op.isfile(cmd_path) and os.access(cmd_path, os.X_OK):
            if verbose: print(cmd_path)
            return True

