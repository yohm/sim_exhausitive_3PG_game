//
// Created by Yohsuke Muraes on 2017/05/22.
//

#include <array>
#include "strategy.hpp"

#ifndef STEP3_GAME_HPP
#define STEP3_GAME_HPP

typedef std::array<std::array<double,64>,64> umatrix_t;
typedef std::array<double,64> payoffv_t;

class Game {
public:
  Game(Strategy _sa, Strategy _sb, Strategy _sc): sa(_sa), sb(_sb), sc(_sc) {};
  ~Game() {};
  FullState Update(FullState fs);
  const Strategy sa, sb, sc;
  void MakeUMatrix( double e, umatrix_t & m );
  static void MakePayoffVector( double r, double c, payoffv_t& va, payoffv_t& vb, payoffv_t& vc);
  // returns payoff vectors. multiplication factor: r, cost: c

};


#endif //STEP3_GAME_HPP
