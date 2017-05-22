//
// Created by Yohsuke Muraes on 2017/05/22.
//

#include <string>
#include <array>
#include <sstream>
#include <cstdint>

#ifndef STEP3_STRATEGY_HPP
#define STEP3_STRATEGY_HPP

enum Action {
  C,
  D
};

char A2C( Action act );

// ShortState: in short notation
//   cc11, cd1-1, dd22 etc...
class ShortState {
public:
  ShortState( Action _a_2, Action _a_1, int8_t _bc_2, int8_t _bc_1 ):
      a_2(_a_2), a_1(_a_1), bc_2(_bc_2), bc_1(_bc_1) {};
  const Action a_2, a_1;
  const int8_t bc_2, bc_1;

  std::string toString() const {
    std::ostringstream oss;
    oss << A2C(a_2) << A2C(a_1) << (int)bc_2 << (int)bc_1;
    return oss.str();
  }

  static const Action A_STATES[4][2];
  static const int8_t BC_STATES[10][2];
  static const ShortState ALL_STATES[40];
private:
};

// FullState: state in the standard si notation
//   cccccc, cdcdcd, cddccd etc....
class FullState {
public:
  FullState(Action _a_2, Action _a_1, Action _b_2, Action _b_1, Action _c_2, Action _c_1):
      a_2(_a_2), a_1(_a_1), b_2(_b_2), b_1(_b_1), c_2(_c_2), c_1(_c_1) {};
  const Action a_2, a_1, b_2, b_1, c_2, c_1;

  std::string toString() const {
    std::ostringstream oss;
    oss << A2C(a_2) << A2C(a_1)
        << A2C(b_2) << A2C(b_1)
        << A2C(c_2) << A2C(c_1);
    return oss.str();
  }

  FullState FromB() const { return FullState(b_2, b_1, a_2, a_1, c_2, c_1); } // full state from B's viewpoint
  FullState FromC() const { return FullState(c_2, c_1, a_2, a_1, b_2, b_1); } // full state from B's viewpoint
};

class Strategy {
public:
  Strategy( std::array<Action,40> acts ); // construct a strategy from a list of actions
  Strategy( const char acts[40] );
  ~Strategy() {};
  std::array<Action,40> actions;

  std::string toString() const {
    std::ostringstream oss;
    for( auto act : actions ) {
      oss << A2C(act);
    }
    return oss.str();
  }

private:

};


#endif //STEP3_STRATEGY_HPP
