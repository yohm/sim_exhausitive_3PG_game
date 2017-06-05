cmake_minimum_required(VERSION 3.7)
project(step3)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES strategy.cpp strategy.hpp Game.cpp Game.hpp Graph.cpp Graph.hpp)
find_package(MPI)
include_directories(SYSTEM ${MPI_INCLUDE_PATH})

add_executable(strategyTest StrategyTest.cpp ${SOURCE_FILES})
add_executable(graphTest GraphTest.cpp Graph.cpp Graph.hpp)
add_executable(filterEfficiency main.cpp ${SOURCE_FILES})
add_executable(mpi_main mpi_main.cpp ${SOURCE_FILES})
target_link_libraries(mpi_main ${MPI_LIBRARIES})
