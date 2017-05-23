#include <iostream>
#include <fstream>
#include <string>
#include "strategy.hpp"
#include "Game.hpp"

bool IsEfficient(const Strategy& str) {
  Game g(str, str, str);
  umatrix_t m;

  double e = 0.01;
  const double r = 2.0;
  const double c = 1.0;
  auto fs = g.AveragePayoffs(e,r,c,1024);
  double fa = std::get<0>(fs);
  std::cout << fa <<std::endl;

  e = 0.005;
  fs = g.AveragePayoffs(e,r,c,1024);
  fa = std::get<0>(fs);
  std::cout << fa <<std::endl;

  if( fa < 0.98 ) { return false; }
  else { return true; }
}

int main(int argc, char** argv) {

  if(argc != 2) {
    std::cerr << "Error: invalid argument" << std::endl;
    std::cerr << "  Usage: " << argv[0] << " <input_strategies.txt>" << std::endl;
  }

  std::ifstream fin(argv[1]);

  std::string line;
  while( std::getline(fin,line) ) {
    std::cout << line << line.size() << std::endl;

    const Strategy str( line.c_str() );
    std::cout << str.toString() << std::endl;
    std::cout << str.toFullString() << std::endl;
    std::cout << IsEfficient(str) << std::endl;


  }

  return 0;
}

