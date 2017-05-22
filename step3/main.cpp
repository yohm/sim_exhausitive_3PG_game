#include <iostream>
#include "strategy.hpp"
#include "Game.hpp"

void test_State() {
  ShortState s( C, D, 1, -1);
  std::cout << "state: " << s.toString() << std::endl;
  std::cout << "  id: " << s.ID() << std::endl;
  std::cout << "restored_from_id: " << ShortState::ALL_STATES[ s.ID() ].toString() << std::endl;

  FullState fs(C,D,D,D,C,C);
  std::cout << "fullState: " << fs.toString() << std::endl;
  std::cout << "  toShort: " << fs.ToShortState().toString() << std::endl;
  std::cout << "  id: " << fs.ID() << std::endl;
  std::cout << "restored_from_id: " << FullState(fs.ID()).toString() << std::endl;
  std::cout << "from B: " << fs.FromB().toString() << std::endl;
  std::cout << "  toShortFromB: " << fs.FromB().ToShortState().toString() << std::endl;
  std::cout << "  id: " << fs.FromB().ID() << std::endl;
  std::cout << "from C: " << fs.FromC().toString() << std::endl;
  std::cout << "  toShortFromC: " << fs.FromC().ToShortState().toString() << std::endl;
  std::cout << "  id: " << fs.FromC().ID() << std::endl;
  std::cout << "restored_from_id: " << FullState(fs.FromC().ID()).toString() << std::endl;
}

void test_Strategy() {
  const std::array<Action,40> acts = {
      C,C,C,C,D,D,D,D,
      C,C,C,C,D,D,D,D,
      C,C,C,C,D,D,D,D,
      C,C,C,C,D,D,D,D,
      C,C,C,C,D,D,D,D
  };
  Strategy str(acts);
  std::cout << "strategy :" << str.toString() << std::endl;
  std::cout << "  full actions :" << str.toFullString() << std::endl;
  FullState allC(C,C,C,C,C,C);
  std::cout << " action at:" << allC.ID() << " is " << A2C(str.ActionAt(allC)) << std::endl;
  FullState allD(D,D,D,D,D,D);
  std::cout << " action at:" << allD.ID() << " is " << A2C(str.ActionAt(allD)) << std::endl;
  FullState fs3(C,C,C,C,D,D);
  std::cout << " action at:" << fs3.ID() << " is " << A2C(str.ActionAt(fs3)) << std::endl;

  Strategy str2("ccccddddccccddddccccddddccccddddccccdddd");
  std::cout << "strategy2:" << str2.toString() << std::endl;
}

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
  std::cout << "Hello, World!" << std::endl;

  test_State();
  test_Strategy();
  test_Game();


  return 0;
}