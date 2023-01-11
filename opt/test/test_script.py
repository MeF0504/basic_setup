import random
from pathlib import Path


class TestClass():
    def __init__(self):
        self.txt_file = Path(__file__).parent/'four_strings.txt'

    def set_string(self):
        txt_list = []
        try:
            with open(self.txt_file, 'r') as f:
                for line in f:
                    txt_list.append(line)
            rand = int(random.random()*len(txt_list))
            self.txt = txt_list[rand]
        except IOError as e:
            print(e)
            self.txt = "hoge"


def main():
    tc = TestClass()
    # set string
    tc.set_string()
    while True:
        comp = ''
        in_txt = input('4 letters:\n')
        if len(in_txt) != 4:
            continue

        for i, char in enumerate(in_txt):
            if tc.txt[i] == char:
                comp += 'o'
            elif char in tc.txt:
                comp += '~'
            else:
                comp += 'x'
        print('----')
        print(comp)
        if comp == 'oooo':
            print('Great!')
            break


if __name__ == '__main__':
    main()
