//
// Created by Yohsuke Muraes on 2017/05/22.
//

#include <iostream>
#include "Strategy.hpp"


char A2C( Action act ) {
  return act == C ? 'c' : 'd';
}

const Action ShortState::A_STATES[4][2] = {
      {C,C},
      {C,D},
      {D,C},
      {D,D}
  };

const int8_t ShortState::BC_STATES[10][2] = {
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

const ShortState ShortState::ALL_STATES[40] = {
    ShortState( C, C, 0, 0 ),
    ShortState( C, C, 0, 1 ),
    ShortState( C, C, 0, 2 ),
    ShortState( C, C, 1, 0 ),
    ShortState( C, C, 1, 1 ),
    ShortState( C, C, 1, -1 ),
    ShortState( C, C, 1, 2 ),
    ShortState( C, C, 2, 0 ),
    ShortState( C, C, 2, 1 ),
    ShortState( C, C, 2, 2 ),
    ShortState( C, D, 0, 0 ),
    ShortState( C, D, 0, 1 ),
    ShortState( C, D, 0, 2 ),
    ShortState( C, D, 1, 0 ),
    ShortState( C, D, 1, 1 ),
    ShortState( C, D, 1, -1 ),
    ShortState( C, D, 1, 2 ),
    ShortState( C, D, 2, 0 ),
    ShortState( C, D, 2, 1 ),
    ShortState( C, D, 2, 2 ),
    ShortState( D, C, 0, 0 ),
    ShortState( D, C, 0, 1 ),
    ShortState( D, C, 0, 2 ),
    ShortState( D, C, 1, 0 ),
    ShortState( D, C, 1, 1 ),
    ShortState( D, C, 1, -1 ),
    ShortState( D, C, 1, 2 ),
    ShortState( D, C, 2, 0 ),
    ShortState( D, C, 2, 1 ),
    ShortState( D, C, 2, 2 ),
    ShortState( D, D, 0, 0 ),
    ShortState( D, D, 0, 1 ),
    ShortState( D, D, 0, 2 ),
    ShortState( D, D, 1, 0 ),
    ShortState( D, D, 1, 1 ),
    ShortState( D, D, 1, -1 ),
    ShortState( D, D, 1, 2 ),
    ShortState( D, D, 2, 0 ),
    ShortState( D, D, 2, 1 ),
    ShortState( D, D, 2, 2 )
};

Strategy::Strategy(std::array<Action,40> acts): actions(acts) { ConstructFullActions(); }

Strategy::Strategy(const char *acts) {
  for( size_t i=0; i<40; i++) {
    actions[i] = (acts[i] == 'c' ? C : D);
  }
  ConstructFullActions();
}

void Strategy::ConstructFullActions() {
  for( size_t i=0; i<64; i++) {
    FullState fs(i);
    ShortState ss = fs.ToShortState();
    fullActions[i] = actions[ss.ID()];
  }
}

Graph Strategy::TransitionGraph() const {
  Graph g(64);
  for( size_t i=0; i<64; i++) {
    FullState fs(i);
    std::vector<FullState> next_states;
    NextPossibleFullStates( fs, next_states);
    for( auto next_s: next_states) {
      size_t u = fs.ID();
      size_t v = next_s.ID();
      g.AddLink(u,v);
    }
  }
  return std::move(g);
}

void Strategy::NextPossibleFullStates(FullState current, std::vector<FullState> &next_states) const {
  Action act_a = ActionAt(current);
  next_states.push_back( current.NextState(act_a,C,C) );
  next_states.push_back( current.NextState(act_a,C,D) );
  next_states.push_back( current.NextState(act_a,D,C) );
  next_states.push_back( current.NextState(act_a,D,D) );
}

FullState FullState::NextState(Action act_a, Action act_b, Action act_c) const {
  return FullState(a_1, act_a, b_1, act_b, b_2, act_c);
}

