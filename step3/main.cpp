#include <iostream>
#include "strategy.hpp"

int main() {
  std::cout << "Hello, World!" << std::endl;

  State s( C, D, 2, 0);
  std::cout << s.toString() << std::endl;

  FullState fs(C,D,D,D,C,C);
  std::cout << fs.toString() << std::endl;

  Strategy str("ccddc");

  return 0;
}