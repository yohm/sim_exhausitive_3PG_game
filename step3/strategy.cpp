//
// Created by Yohsuke Muraes on 2017/05/22.
//

#include <iostream>
#include "strategy.hpp"

Strategy::Strategy(std::string actions) {
  std::cout << actions << std::endl;
}

char A2C( Action act ) {
  return act == C ? 'c' : 'd';
}

const Action State::A_STATES[4][2] = {
      {C,C},
      {C,D},
      {D,C},
      {D,D}
  };

const int8_t State::BC_STATES[10][2] = {
    {0, 0},
    {0, 1},
    {0, 2},
    {1, 0},
    {1, 1},
    {1,-1},
    {1, 2},
    {2, 0},
    {2, 1},
    {2, 2}
};

const State State::ALL_STATES[40] = {
    State( C, C, 0, 0 ),
    State( C, C, 0, 1 ),
    State( C, C, 0, 2 ),
    State( C, C, 1, 0 ),
    State( C, C, 1, 1 ),
    State( C, C, 1, -1 ),
    State( C, C, 1, 2 ),
    State( C, C, 2, 0 ),
    State( C, C, 2, 1 ),
    State( C, C, 2, 2 ),
    State( C, D, 0, 0 ),
    State( C, D, 0, 1 ),
    State( C, D, 0, 2 ),
    State( C, D, 1, 0 ),
    State( C, D, 1, 1 ),
    State( C, D, 1, -1 ),
    State( C, D, 1, 2 ),
    State( C, D, 2, 0 ),
    State( C, D, 2, 1 ),
    State( C, D, 2, 2 ),
    State( D, C, 0, 0 ),
    State( D, C, 0, 1 ),
    State( D, C, 0, 2 ),
    State( D, C, 1, 0 ),
    State( D, C, 1, 1 ),
    State( D, C, 1, -1 ),
    State( D, C, 1, 2 ),
    State( D, C, 2, 0 ),
    State( D, C, 2, 1 ),
    State( D, C, 2, 2 ),
    State( D, D, 0, 0 ),
    State( D, D, 0, 1 ),
    State( D, D, 0, 2 ),
    State( D, D, 1, 0 ),
    State( D, D, 1, 1 ),
    State( D, D, 1, -1 ),
    State( D, D, 1, 2 ),
    State( D, D, 2, 0 ),
    State( D, D, 2, 1 ),
    State( D, D, 2, 2 )
};
