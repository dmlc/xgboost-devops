#include "utils.h"

namespace utils {

int sum(int start, int end) {
    int result = 0;
    for (int i = start; i <= end; ++i) {
        result += i;
    }
    return result;
}

long long factorial(int n) {
    if (n <= 1) {
        return 1;
    }
    long long result = 1;
    for (int i = 2; i <= n; ++i) {
        result *= i;
    }
    return result;
}

}  // namespace utils
