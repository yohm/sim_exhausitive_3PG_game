#include <iostream>
#include <fstream>
#include <string>
#include "strategy.hpp"
#include "Game.hpp"

bool IsEfficient(const Strategy& str, double e) {
  Game g(str, str, str);
  umatrix_t m;

  //double e = 0.01;
  const double r = 2.0;
  const double c = 1.0;
  auto fs = g.AveragePayoffs(e,r,c,1024);
  double fa = std::get<0>(fs);
  std::cerr << fa <<std::endl;

  /*
  e = 0.005;
  fs = g.AveragePayoffs(e,r,c,1024);
  fa = std::get<0>(fs);
  std::cout << fa <<std::endl;
   */

  if( fa < 0.9 /*(c*r-c) - 10*e */ ) { return false; }
  else { return true; }
}

int main(int argc, char** argv) {

  if(argc != 3) {
    std::cerr << "Error: invalid argument" << std::endl;
    std::cerr << "  Usage: " << argv[0] << " <e> <input_strategies.txt>" << std::endl;
    throw "invalid argument";
  }

  double e = atof(argv[1]);
  std::ifstream fin(argv[2]);

  std::string line;
  int count = 0;
  while( std::getline(fin,line) ) {
    //std::cout << line << line.size() << std::endl;

    const Strategy str( line.c_str() );
    //std::cout << str.toString() << std::endl;
    //std::cout << str.toFullString() << std::endl;
    if( IsEfficient(str,e) ) {
      std::cout << str.toString() << std::endl;
    }
    count++;
    if( count % 1000 == 0 ) { std::cerr << "count: " << count << std::endl; }
  }

  return 0;
}

