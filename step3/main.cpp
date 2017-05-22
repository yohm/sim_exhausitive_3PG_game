#include <iostream>
#include "strategy.hpp"

int main() {
  std::cout << "Hello, World!" << std::endl;

  ShortState s( C, D, 1, -1);
  std::cout << "state: " << s.toString() << std::endl;

  FullState fs(C,D,D,D,C,C);
  std::cout << "fullState: " << fs.toString() << std::endl;
  std::cout << "from B: " << fs.FromB().toString() << std::endl;
  std::cout << "from C: " << fs.FromC().toString() << std::endl;

  const std::array<Action,40> acts = {
      C,C,C,C,D,D,D,D,
      C,C,C,C,D,D,D,D,
      C,C,C,C,D,D,D,D,
      C,C,C,C,D,D,D,D,
      C,C,C,C,D,D,D,D
  };
  Strategy str(acts);
  std::cout << "strategy :" << str.toString() << std::endl;

  Strategy str2("ccccddddccccddddccccddddccccddddccccdddd");
  std::cout << "strategy2:" << str2.toString() << std::endl;


  return 0;
}