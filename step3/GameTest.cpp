//
// Created by Yohsuke Murase on 2017/06/06.
//
#include <iostream>
#include "Strategy.hpp"
#include "Game.hpp"

void test_Game() {
  std::cout << "testing Game" << std::endl;
  const std::array<Action,40> acts = {
      C,C,C,C,D,D,D,D,
      C,C,C,C,D,D,D,D,
      C,C,C,C,D,D,D,D,
      C,C,C,C,D,D,D,D,
      C,C,C,C,D,D,D,D
  };
  Strategy sa(acts), sb(acts), sc(acts);

  Game g(sa,sb,sc);
  FullState initC(C,C,C,C,C,C);
  FullState updated = g.Update( initC );
  std::cout << "  updated from C: " << updated.toString() << std::endl;

  FullState initD(D,D,D,D,D,D);
  FullState s = g.Update( initD );
  std::cout << "  updated from D: " << s.toString() << std::endl;

  FullState init3(C,D,D,C,D,D);
  FullState s3= g.Update( init3 );
  std::cout << "  updated from init3: " << s3.toString() << std::endl;
}

int main() {
  std::cout << "GameTest" << std::endl;

  test_Game();

  return 0;
}
