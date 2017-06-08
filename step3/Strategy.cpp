//
// Created by Yohsuke Muraes on 2017/05/22.
//

#include <iostream>
#include <set>
#include "Strategy.hpp"


char A2C( Action act ) {
  return act == C ? 'c' : 'd';
}

std::ostream &operator<<(std::ostream &os, const Action &act) {
  os << A2C(act);
  return os;
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

Graph Strategy::TransitionGraphWithoutPositiveStates() const {
  Graph g(64);
  for( size_t i=0; i<64; i++) {
    FullState fs(i);
    if( fs.RelativePayoff() > 0 ) { continue; }
    std::vector<FullState> next_states;
    NextPossibleFullStates( fs, next_states);
    for( auto next_s: next_states) {
      if( next_s.RelativePayoff() > 0 ) { continue; }
      size_t u = fs.ID();
      size_t v = next_s.ID();
      g.AddLink(u,v);
    }
  }
  return std::move(g);
}

std::ostream &operator<<(std::ostream &os, const Strategy &strategy) {
  os << "actions: ";
  for( auto a : strategy.actions ) {
    os << a;
  }
  os << "\n";
  os << "fullActions: ";
  for( auto a : strategy.fullActions ) {
    os << a;
  }

  return os;
}

std::string Strategy::ToDot() const {
  std::stringstream ss;
  ss << "digraph \"\" {\n";
  for( int i=0; i<64; i++) {
    FullState fs(i);
    int p = fs.RelativePayoff();
    std::string color;
    if( p == 2 ) {
      color = "blue";
    }
    else if( p == 1 ) {
      color = "lightblue";
    }
    else if( p == 0 ) {
      color = "black";
    }
    else if( p == -1 ) {
      color = "orange";
    }
    else if( p == -2 ) {
      color = "red";
    }
    ss << "  " << i << " [ label=\"" << fs << "\"; fontcolor = " << color << " ];\n";
  }
  Graph g = TransitionGraph();
  auto printLink = [&ss](long from, long to) {
    ss << "  " << from << " -> " << to << ";\n";
  };
  g.ForEachLink(printLink);
  ss << "}\n";

  return ss.str();
}

std::string Strategy::ToString() const {
  std::ostringstream oss;
  for( auto act : actions) {
    oss << act;
  }
  return oss.str();
}

bool Strategy::IsDefensible1() const {
  long a[24] = {
      1,3,4,5,6,7,9,11,
      12,13,14,15,33,35,36,37,
      38,39,41,43,44,45,46,47
  };

  const std::set<long> RiskyNodeIDs(a,a+24);
  Graph g = TransitionGraphWithoutPositiveStates();
  std::set<long> nodes = g.TransitionNodes();
  if( nodes.size() < 24 ) { return false; }
  std::set<long> diff;
  std::set_difference( RiskyNodeIDs.begin(), RiskyNodeIDs.end(), nodes.begin(), nodes.end(), std::inserter(diff,diff.end()) );
  return diff.size() == 0;
}

FullState FullState::NextState(Action act_a, Action act_b, Action act_c) const {
  return FullState(a_1, act_a, b_1, act_b, c_1, act_c);
}

std::ostream &operator<<(std::ostream &os, const FullState &state) {
  os << state.ID() << '_' << state.a_2 << state.a_1 << state.b_2 << state.b_1 << state.c_2 << state.c_1;
  return os;
}

std::ostream &operator<<(std::ostream &os, const ShortState &state) {
  os << state.ID() << '_' << state.a_2 << state.a_1 << (int)state.bc_2 << (int)state.bc_1;
  return os;
}

