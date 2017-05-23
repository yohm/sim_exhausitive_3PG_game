//
// Created by Yohsuke Muraes on 2017/05/22.
//

#include "Game.hpp"

FullState Game::Update(FullState fs) {
  Action act_a = sa.ActionAt( fs );
  Action act_b = sb.ActionAt( fs.FromB() );
  Action act_c = sc.ActionAt( fs.FromC() );
  return FullState( fs.a_1, act_a, fs.b_1, act_b, fs.c_1, act_c);
}

void Game::MakeUMatrix( double e, umatrix_t &m) {
  for( size_t i=0; i<64; i++ ) {
    FullState si(i);
    FullState next = Update(si);
    for( size_t j=0; j<64; j++) {
      FullState sj(j);
      FullState next = Update(sj);
      int d = next.NumDiffInT1(si);
      if( d == -1 ) { m[i][j] = 0.0; }
      else if( d == 3 ) { m[i][j] = e*e*e; }
      else if( d == 2 ) { m[i][j] = e*e*(1.0-e); }
      else if( d == 1 ) { m[i][j] = e*(1.0-e)*(1.0-e); }
      else { m[i][j] = (1.0-e)*(1.0-e)*(1.0-e); }
    }
  }
}

void Game::MakePayoffVector(double r, double cost, payoffv_t &va, payoffv_t &vb, payoffv_t &vc) {
  for( size_t i=0; i<64; i++) {
    FullState fs(i);
    const Action a = fs.a_1, b = fs.b_1, c = fs.c_1;
    size_t num_C = 0;
    if( a == C ) { num_C++;}
    if( b == C ) { num_C++;}
    if( c == C ) { num_C++;}
    double g = num_C * cost * r / 3.0;

    va[i] = ( a == C ) ? g-cost : g;
    vb[i] = ( b == C ) ? g-cost : g;
    vc[i] = ( c == C ) ? g-cost : g;
  }
}
