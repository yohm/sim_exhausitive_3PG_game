#include <iostream>
#include <fstream>
#include <string>
#include "Strategy.hpp"
#include "Game.hpp"

double Payoff(const Strategy& str, double e) {
  Game g(str, str, str);

  //double e = 0.01;
  const double r = 2.0;
  const double c = 1.0;
  auto fs = g.AveragePayoffs(e,r,c,1024);
  double fa = std::get<0>(fs);
  return fa;
}

bool IsEfficient(const Strategy& str, double e, double th) {
  double p = Payoff(str,e);
  if( p < th ) { return false; }
  else { return true; }
}

int main(int argc, char** argv) {

  if(argc != 3 && argc != 4) {
    std::cerr << "Error: invalid argument" << std::endl;
    std::cerr << "  Usage : " << argv[0] << " <e> <input_strategy_string>" << std::endl;
    std::cerr << "     or : " << argv[0] << " <e> <th> <input_strategies_file>" << std::endl;
    throw "invalid argument";
  }

  if( argc == 3 ) {
    double e = atof(argv[1]);
    const Strategy str( argv[2] );
    double p = Payoff(str,e);
    std::cout << p << std::endl;
  }
  else if( argc == 4) {
    double e = atof(argv[1]);
    double th = atof(argv[2]);
    std::ifstream fin(argv[3]);
    std::string line;
    int count = 0;
    while( std::getline(fin,line) ) {
      //std::cout << line << line.size() << std::endl;

      const Strategy str( line.c_str() );
      //std::cout << str.toString() << std::endl;
      //std::cout << str.toFullString() << std::endl;
      if( IsEfficient(str,e,th) ) {
        std::cout << str.ToString() << std::endl;
      }
      count++;
      if( count % 1000 == 0 ) { std::cerr << "count: " << count << std::endl; }
    }
  }

  return 0;
}

