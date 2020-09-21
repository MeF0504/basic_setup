
import os

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

if __name__ == '__main__':
    test_class = TestClass()
    test_class.chk_test()
