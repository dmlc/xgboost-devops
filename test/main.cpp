#include <iostream>
#include "utils.h"

int main() {
    std::cout << "Hello, World!" << std::endl;
    std::cout << "Sum of 1 to 10: " << utils::sum(1, 10) << std::endl;
    std::cout << "Factorial of 5: " << utils::factorial(5) << std::endl;
    return 0;
}
