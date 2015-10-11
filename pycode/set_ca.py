#! /usr/bin/env python

import os

os.system('ls -l $HOME/.globus/certificates/')
#os.system('wget https://www.hpci.nii.ac.jp/ca/hpcica.crl')
os.system('curl -O https://www.hpci.nii.ac.jp/ca/hpcica.crl')
os.system('mv hpcica.crl $HOME/.globus/certificates/`openssl crl -in hpcica.crl -noout -hash`.r0')
os.system('ls -l $HOME/.globus/certificates/')
