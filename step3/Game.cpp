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

