#include <iostream>
#include <fstream>
#include <string>
#include <cassert>
#include "mpi.h"
#include "Strategy.hpp"
#include "Game.hpp"

double AveragePayoff( const Strategy& str, double e) {
  Game g(str, str, str);

  const double r = 2.0;
  const double c = 1.0;
  auto fs = g.AveragePayoffs(e,r,c,1024);
  double fa = std::get<0>(fs);
  return fa;
}

bool IsEfficient(const Strategy& str, double e, double th) {
  double fa = AveragePayoff(str,e);
  return (fa >= th);
}

int main(int argc, char** argv) {

  MPI_Init(&argc, &argv);

  if( argc != 3 && argc != 4 ) {
    std::cerr << "Error : invalid argument" << std::endl;
    std::cerr << "  Usage : " << argv[0] << " <e> <strategy>" << std::endl;
    std::cerr << "     or : " << argv[0] << " <e> <infile_pattern> <outfile_pattern>" << std::endl << std::endl;
    std::cerr << "    example : " << argv[0] << " 0.01 in_%04d out_%04d" << std::endl;
    MPI_Finalize();
    return 1;
  }

  int my_rank = 0;
  MPI_Comm_rank( MPI_COMM_WORLD, &my_rank );

  double e = std::atof( argv[1] );

  if( argc == 4 ) {
    std::string in_format = argv[2];
    std::string out_format = argv[3];

    char in_filename[256], out_filename[256];
    sprintf(in_filename, in_format.c_str(), my_rank);
    sprintf(out_filename, out_format.c_str(), my_rank);
    std::cerr << in_filename << " > " << out_filename << " @rank: " << my_rank << std::endl;

    std::ifstream fin(in_filename);
    std::ofstream fout(out_filename);

    std::string line;
    int count = 0, filtered_count = 0;
    while( std::getline(fin,line) ) {
      const Strategy str( line.c_str() );
      double payoff = AveragePayoff(str, e);
      fout << str.ToString() << ' ' << payoff << "\n";
      count++;
#ifndef NDEBUG
      if( count % 1000 == 0 ) { std::cerr << "count: " << count << " @rank: " << my_rank << std::endl; }
#endif
    }
    std::cerr << count << " strategies were processed at rank " << my_rank << std::endl;
    fout.close();
  }
  else {
    assert( my_rank == 0 );
    const Strategy str( argv[2] );
    double payoff = AveragePayoff(str, e);
    std::cout << "efficiency: " << payoff << std::endl;
  }

  MPI_Finalize();

  return 0;
}

