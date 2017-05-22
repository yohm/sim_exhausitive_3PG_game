//
// Created by Yohsuke Muraes on 2017/05/22.
//

#include "strategy.hpp"

#ifndef STEP3_GAME_HPP
#define STEP3_GAME_HPP

class Game {
public:
  Game(Strategy _sa, Strategy _sb, Strategy _sc): sa(_sa), sb(_sb), sc(_sc) {};
  ~Game() {};
  FullState Update(FullState fs);
  const Strategy sa, sb, sc;
};


#endif //STEP3_GAME_HPP
