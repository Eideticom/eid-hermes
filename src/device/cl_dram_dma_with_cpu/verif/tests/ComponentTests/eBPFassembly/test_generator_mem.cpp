// Author: Felipe Cupido
// 2021-01-19
#include <string>
#include <iostream>
#include <filesystem>
#include <fstream>
namespace fs = std::filesystem;


bool isTestSigned(int op){
    bool signedOp;
    switch (op){
        case 0:
        case 1:
        case 2:
        case 3:
        case 4:
        case 5:
            signedOp = false;
            break;
        case 6:
        case 7:
            signedOp = true;
            break;
            //
            //
        case 0xa:
        case 0xb:
            signedOp = false;
            break;
        case 0xc:
        case 0xd:
            signedOp = true;
            break;
        default:
            signedOp = false;
    }
    return signedOp;
}
bool getJumpExpectedValue(int op, uint64_t a, uint64_t b){
    bool jump;
    int64_t signedA = a;
    int64_t signedB = b;
    switch (op){
        case 0: jump = true;
            break;
        case 1: jump = a == b;
            break;
        case 2: jump = a > b;
            break;
        case 3: jump = a >= b;
            break;
        case 4: jump = a & b;
            break;
        case 5: jump = a != b;
            break;
        case 6: jump = signedA > signedB;
            break;
        case 7: jump = signedA >= signedB;
            break;
            //
            //
        case 0xa: jump = a < b;
            break;
        case 0xb: jump = a <= b;
            break;
        case 0xc: jump = signedA < signedB;
            break;
        case 0xd: jump = signedA <= signedB;
            break;
        default: jump = false;
    }
    return jump;
}
void getTestValueAB(uint64_t& a, uint64_t& b, bool isSigned, int testNum){
    int64_t const signed_a_64bit_tests[7] = {15, 0, -1, INT64_MIN, INT64_MAX, INT64_MIN, INT64_MAX};
    int64_t const signed_b_64bit_tests[7] = {-3, 9, -18, INT64_MIN, INT64_MIN, INT64_MAX, INT64_MAX};

    uint64_t const unsigned_a_64bit_tests[7] = {0, 5, 128,  44, 486215, 213, INT64_MAX};
    uint64_t const unsigned_b_64bit_tests[7] = {0, 5,  55, 561, 486215,   1, INT64_MAX};
    if(isSigned){
        a = signed_a_64bit_tests[testNum];
        b = signed_b_64bit_tests[testNum];
    } else {
        a = unsigned_a_64bit_tests[testNum];
        b = unsigned_b_64bit_tests[testNum];
    }
}

void printTest(uint64_t a, uint64_t b, int op, int expected){
    using namespace std;
    std::cout << "a = 64\'h" << std::hex << a << "; "<< std::endl;
    std::cout << "b = 64\'h" << std::hex << b << "; "<< std::endl;
    std::cout << "op = 4\'h" << std::hex << op << "; "<< std::endl;
    std::cout << "expected = \'" << expected << ";" << std::endl;
    std::cout << "#period;" << std::endl;
    std::cout << "mismatch = jump != expected;" << std::endl;
    std::cout << "if(mismatch)" << std::endl;
    std::cout << "     $display(\"test failed for inputs: ";
    std::cout << "a=0x" << std::hex << a << " ";
    std::cout << "b=0x" << std::hex << b << " ";
    std::cout << "op=0x" << std::hex << op << " ";
    std::cout << "expected=" << expected << " ";
    std::cout << "\");" << std::endl<< std::endl;
}

void getFilesPaths(std::string path)
{
    for(const auto & entry : fs::directory_iterator(path))
        std::cout << entry.path() << std::endl;

}

int main() {

    /*
    for(int op = 0; op <= 0xd; op++)
    {
        if(op == 8 || op == 9) continue;
        bool isSigned = isTestSigned(op);
        for(int testNum = 0; testNum < 7; testNum++){
            uint64_t a = 0;
            uint64_t b = 0;
            getTestValueAB(a, b, isSigned, testNum);
            bool jumpExpectedValue = getJumpExpectedValue(op, a, b);

            printTest(a, b, op, jumpExpectedValue);
        }
    }
    */

getFilesPath("bytecode");
    return 0;
}