#include <iostream>
#include <fstream>
#include <string>
#include "mpi.h"
#include "strategy.hpp"
#include "Game.hpp"

bool IsEfficient(const Strategy& str, double e, double th) {
  Game g(str, str, str);
  umatrix_t m;

  //double e = 0.01;
  const double r = 2.0;
  const double c = 1.0;
  auto fs = g.AveragePayoffs(e,r,c,1024);
  double fa = std::get<0>(fs);
  // std::cerr << fa <<std::endl;

  /*
  e = 0.005;
  fs = g.AveragePayoffs(e,r,c,1024);
  fa = std::get<0>(fs);
  std::cout << fa <<std::endl;
   */

  if( fa < th /*(c*r-c) - 10*e */ ) { return false; }
  else { return true; }
}

int main(int argc, char** argv) {

  MPI_Init(&argc, &argv);

  if( argc != 3 ) {
    std::cerr << "Error : invalid argument" << std::endl;
    std::cerr << "  Usage : " << argv[0] << " <e> <threshold>" << std::endl;
    MPI_Finalize();
    return 1;
  }

  int my_rank = 0;
  MPI_Comm_rank( MPI_COMM_WORLD, &my_rank );

  double e = std::atof( argv[1] );
  double th = std::atof( argv[2] );

  char myfilename[128], myoutfilename[128];
  sprintf(myfilename, "bits%04d.txt", my_rank);
  sprintf(myoutfilename, "filtered%04d.txt", my_rank);
  std::ifstream fin(myfilename);
  std::ofstream fout(myoutfilename);
  std::cerr << "filtering " << myfilename << " > " << myoutfilename << " @rank: " << my_rank << std::endl;

  std::string line;
  int count = 0, filtered_count = 0;
  while( std::getline(fin,line) ) {
    const Strategy str( line.c_str() );
    //std::cout << str.toString() << std::endl;
    //std::cout << str.toFullString() << std::endl;
    if( IsEfficient(str, e, th) ) {
      fout << str.ToString() << std::endl;
      filtered_count++;
    }
    count++;
    if( count % 1000 == 0 ) { std::cerr << "count: " << count << " @rank: " << my_rank << std::endl; }
  }
  std::cerr << filtered_count << " strategies are found out of " << count << " at rank " << my_rank << std::endl;

  MPI_Finalize();

  return 0;
}

