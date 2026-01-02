#include <cstring>
#include <fstream>
#include <iostream>
#include <string>
#include <vector>
#include <random>
// #include <source_location>

class ReadFile
{
    public:
        ReadFile(std::string filename)
        {
            this->filename = filename;
        }
        void set_string()
        {
            std::ifstream file(filename);
            std::string line;
            while (std::getline(file, line)) {
                // std::cout << line << std::endl;
                this->data.push_back(line);
            }
        }
        void set_answer()
        {
            std::random_device seed_gen;
            unsigned seed = seed_gen();
            std::mt19937_64 engine(seed);
            int datalen = this->data.size();
            std::uniform_int_distribution<int> dist(0, datalen-1);
            this->ans = data[dist(engine)];
            std::cout << "Answer:" << this->ans << std::endl;
        }
        std::string check_word(std::string word)
        {
            if(4 != word.length()) {
                std::cout << "Word length is not 4!!" << std::endl;
                return "error!!";
            }
            std::string res = "";
            for(int i=0; i < 4; i++) {
                char ch = word[i];
                if(ch == this->ans[i]) {
                    res.push_back('o');
                } else if(this->ans.find(ch) != std::string::npos) {
                    res.push_back('~');
                } else {
                    res.push_back('x');
                }
            }
            return res;
        }

    private:
        std::string filename;
        std::vector<std::string> data = {};
        std::string ans = "hoge";
};


int main(int argc, char** argv) {
    auto rfile {ReadFile("opt/samples/code_samples/four_strings.txt")};
    // なんか動かん
    // const std::source_location location = std::source_location::current();
    rfile.set_string();
    rfile.set_answer();
    std::string word;
    std::string ans;
    // int cnt = 0;
    while(1) {
        std::cout << "word? (quit: break) > ";
        std::cin >> word;
        if(word == "quit") {
            break;
        }
        // cnt ++;
        ans = rfile.check_word(word);
        std::cout << "  " << ans << std::endl;
        if(ans == "oooo") {
            std::cout << "Great!!" << std::endl;
            break;
        }
        // if(cnt > 10) {
        //     break;
        // }
    }
    return 0;
}
