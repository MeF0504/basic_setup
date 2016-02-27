#! /usr/bin/env python

import os
import subprocess
import glob
import argparse

def linux(files,force=False):
    if not force:
        yn = raw_input('open files: %d\tOK? {y n}' % len(files))
        if yn == 'y': ok=True
        else: return 0
    for f in files:
        """
        if f[f.rfind('.'):] in ('.png','.jpg','.PNG','.JPG','.MIFF','pdf','.PDF'):
            if not force:
                yn = raw_input('file ls %s. OK? {y n}' % f)
                if yn=='y': ok = True
                else: ok = False
            else:
                ok = True
        """

        if (f[f.rfind('.'):] in ('.png','.jpg','.PNG','.JPG','.MIFF')) and ok:
            judge = subprocess.call('display %s &' % f,shell=True)
        elif (f.endswith('.pdf') or f.endswith('.PDF')) and ok:
            judge = subprocess.call('evince %s &' % f,shell=True)
        else:
            continue

        if judge != 0:
            break

def mac(files):
    f2 = ''
    for f in files:
        if f[f.rfind('.'):] in ('.png','.jpg','.PNG','.JPG','.MIFF','pdf','.PDF'):
            f = f.replace(' ','\ ')
            f2 += ' '+f

    #print f2
    subprocess.call('open -a Preview '+f2,shell=True)


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('figs',help="figures: file type=('.png','.jpg','.PNG','.JPG','.MIFF','pdf','.PDF')",nargs='*')
    parser.add_argument('-f','--force',help='show images w/o no check',action='store_true')
    args = parser.parse_args()
    files = args.figs
    if len(args.figs)==0:
        files = glob.glob('./*')
    elif os.path.isdir(args.figs[0]):
        files = glob.glob(os.path.join(args.figs[0],'*'))
    print 'all files:',len(files)
    #print files,'\n'
    #exit()

    if os.uname()[0] == 'Linux': linux(files,args.force)
    if os.uname()[0] == 'Darwin': mac(files)

