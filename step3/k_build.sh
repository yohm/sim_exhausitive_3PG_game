mpiFCCpx -Kfast -std=c++11 -o mpi_main.out mpi_main.cpp Strategy.cpp Game.cpp Graph.cpp
mpiFCCpx -Kfast -DNDEBUG -std=c++11 -o defense1.out main_defense1.cpp Strategy.cpp Graph.cpp

