
#ifndef test_script_h
#define test_script_h 1

#include <string>
#include <vector>

class ReadFile
{
    public:
        ReadFile(std::string);
        void set_string();
        void set_answer();
        std::string check_word(std::string);

    private:
        std::string filename;
        std::vector<std::string> data = {};
        std::string ans = "hoge";
};

#endif
