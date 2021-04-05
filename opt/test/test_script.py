
import os
import sys

# comment
class TestClass():
    def __init__(self):
        self.var = 1.3

    def chk_test(self):
        if self.var == 1:
            is_one = True
        else:
            is_one = False
        if is_one:
            print('Hello, World!!')
        else:
            return

def try_test():
    x = 1
    for i in 'a b c hoge x y z'.split():
        try:
            print('{} = {}'.format(i, locals()[i]))
            break
        except Exception as e:
            print('Error! {} => {}: {}'.format(i,type(e), e), file=sys.stderr)
            continue

if __name__ == '__main__':
    test_class = TestClass()
    test_class.chk_test()
    try_test()
