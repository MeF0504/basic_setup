
import os
#import sys
import argparse
import subprocess
import glob
#if float(sys.version[:3]) < 2.7:
    #import commands


def mkdir(path):
    path = os.path.expanduser(path)
    if not os.path.exists(path):
        print 'mkdir '+path
        os.mkdir(path)
        os.chmod(path,0755)

def fcopy(file1,file2,link=False,force=False,**kwargs):
    def fcopy_main(cmd,comment,test):
        if not test:
            subprocess.call(cmd, shell=True)
            print comment
        else:
            print 'cmd check:: '+cmd+'\n'

    name1 = os.path.basename(file1)
    name2 = os.path.basename(file2)

    if kwargs.has_key('test'):
        test = kwargs['test']
    else:
        test = False

    if kwargs.has_key('condition'):
        condition = kwargs['condition']
    else:
        condition = True

    if link:    #link
        cmd = 'ln -s %s %s' % (file1, file2)
        comment = 'linked '+name1

        if (not os.path.exists(file2)) and condition:
            fcopy_main(cmd,comment,test)
        elif condition:
            print '[  %s  ] is already exist, cannot link!' % name2

    else:       #copy
        cmd = 'cp %s %s' % (file1, file2)
        comment = 'copy %s --> %s\n' % (name1,file2)

        if force and condition:
            fcopy_main(cmd, comment, test)
        elif (not os.path.exists(file2)) and condition:
            fcopy_main(cmd, comment, test)
        elif condition:
            yn = raw_input('[  %s  ] is already exist, are you realy overwite? [y,n]' % name2)
            if (yn == 'y') or (yn == 'yes'):
                fcopy_main(cmd, comment, test)
            else:
                print 'Do not copy '+name2+'\n'

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('--prefix',help='install directory',default=os.path.expanduser('~/opt'))
    parser.add_argument('--download',help='download some files (from git)',action='store_true')
    #parser.add_argument('--copy',help="only copy files instead of link",action='store_true')
    parser.add_argument('--link',help="link files instead of copy",action='store_true')
    parser.add_argument('--test',help="don't copy, just show command",action='store_true')
    parser.add_argument('-f','--force',help="Do not prompt for confirmation before overwriting the destination path",action='store_true')
    args = parser.parse_args()

    #print dir(args)
    #exit()
    if not os.path.exists(args.prefix):
        print "install path %s does not exit" % args.prefix
        exit()

    fpath = os.path.dirname(os.path.abspath(__file__))
    binpath = os.path.join(args.prefix,'bin')
    mkdir(binpath)
    #print fpath
    os.chdir(fpath)

    ############### python script directory ###############
    pydir = os.path.join(fpath,'pycode')
    print '\n@ '+pydir+'\n'
    pyfiles = []
    for pfy in glob.glob(os.path.join(pydir,'*')):
        if os.access(pfy,os.X_OK):
            pyfiles.append(pfy)

    for p in pyfiles:
        #print 'p',p,'p'
        fname = os.path.basename(p)
        fcopy(p,os.path.join(binpath,fname),link=args.link,force=args.force,test=args.test)

    ############### basic setup directory ###############
    setdir = os.path.join(fpath,'setup')
    print '\n@ '+setdir+'\n'
    files_mac = {\
                'zshrc_file':'~/.zshrc', \
                'ssh-host-color.sh':'ssh-host-color.sh', \
                'pdf2jpg':'pdf2jpg'\
                }

    files_linux = {\
                  'zshrc_file':'~/.zshrc', \
                  'terminator_config':'~/.config/terminator/config', \
                }
    if os.uname()[0] == 'Darwin':
        files = files_mac
    elif os.uname()[0] == 'Linux':
        files = files_linux
    else:
        files = {}

    for fy in files:
        spath = os.path.join(setdir,fy)
        if os.path.exists(spath):
            if 'zshrc_file' == fy:
                fcopy(spath,os.path.expanduser(files[fy]),link=bool(args.link),force=args.force,test=args.test)
                if not os.path.exists(os.path.expanduser('~/.zshrc.mine')):
                    with open(os.path.expanduser('~/.zshrc.mine'),'a') as f:
                        print >> f,'## PC dependent zshrc'
                        print >> f,'#'
                        print >> f,'\n'

            elif 'terminator_config' == fy:
                fcopy(spath,os.path.expanduser(files[fy]),link=False,force=args.force,condition=(os.uname()[0]=='Linux') and os.path.exists(os.path.expanduser(files[fy])),test=args.test)

            else:
                fcopy(spath,os.path.join(binpath,files[fy]),force=args.force,test=args.test)

    ############### vim setup directory ###############
    vimdir = os.path.join(fpath,'vim')
    print '\n@ '+vimdir+'\n'

    files = { \
            'vimrc_file':'~/.vimrc', \
            'vimrc_color':'vimrc.color', \
            'vimrc_plugin':'vimrc.plugin', \
            'vimrc_dein':'vimrc.dein', \
            'python.vim':'python.vim'\
            }
    mkdir('~/.vim')
    mkdir('~/.vim/rcdir')
    mkdir('~/.vim/swp')
    rcdir = os.path.expanduser('~/.vim/rcdir')

    if args.download:
        mkdir('tmp')
        os.chdir(os.path.join(fpath,'tmp'))
        #print '\nclone neobundle'
        #mkdir('~/.vim/bundle/')
        #subprocess.call('git clone git://github.com/Shougo/neobundle.vim ~/.vim/bundle/neobundle.vim',shell=True)
        print '\nclone dein'
        mkdir('~/.vim/dein')
        subprocess.call('curl https://raw.githubusercontent.com/Shougo/dein.vim/master/bin/installer.sh > installer.sh && chmod u+x installer.sh && ./installer.sh ~/.vim/dein',shell=True)
        print '\nclone inkpot'
        subprocess.call('git clone https://github.com/ciaranm/inkpot',shell=True)
        subprocess.call('cp -ri ./inkpot/colors ~/.vim',shell=True)
        #print '\nclone seiya'
        #subprocess.call('git clone https://github.com/miyakogi/seiya.vim',shell=True)
        #subprocess.call('cp -ri ./seiya.vim/plugin ~/.vim',shell=True)
        #print '\nclone quickrun'
        #subprocess.call('git clone https://github.com/thinca/vim-quickrun.git',shell=True)
        #subprocess.call('cp -ri ./vim-quickrun/plugin/quickrun.vim ~/.vim/plugin/',shell=True)
        #print '\nclone taglist'
        #subprocess.call('git clone https://github.com/vim-scripts/taglist.vim',shell=True)
        #subprocess.call('cp -ri ./taglist.vim/plugin/taglist.vim ~/.vim/plugin/',shell=True)
        print '\nremove download tmp files'
        subprocess.call('rm -rf %s' % os.path.join(fpath,'tmp','*'),shell=True)
        os.chdir(fpath)

    for fy in files:
        vpath = os.path.join(vimdir,fy)
        if os.path.exists(vpath):

            if 'vimrc_file' in vpath:
                fcopy(vpath,os.path.expanduser(files[fy]),link=bool(args.link),force=args.force,test=args.test)

            else:
                fcopy(vpath,os.path.join(rcdir,files[fy]),link=bool(args.link),force=args.force,test=args.test)

    vim_mine = os.path.expanduser('~/.vim/rcdir/vimrc.mine')
    if not os.path.exists(vim_mine):
        with open(vim_mine,'a') as f:
            print >> f,'"" PC dependent vimrc'
            print >> f,'"'
            print >> f,'\n'

