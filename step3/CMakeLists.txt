cmake_minimum_required(VERSION 3.7)
project(step3)

set(CMAKE_CXX_STANDARD 11)

#set(CMAKE_VERBOSE_MAKEFILE 1)

set(SOURCE_FILES StrategyM3.cpp StrategyM3.hpp Strategy.cpp Strategy.hpp Game.cpp Game.hpp Graph.cpp Graph.hpp)
find_package(MPI)
include_directories(SYSTEM ${MPI_INCLUDE_PATH})

add_executable(strategyTest StrategyTest.cpp ${SOURCE_FILES})
add_executable(strategyM3Test StrategyM3Test.cpp ${SOURCE_FILES})
add_executable(graphTest GraphTest.cpp Graph.cpp Graph.hpp)
add_executable(gameTest GameTest.cpp ${SOURCE_FILES})

add_executable(main_defense1 main_defense1.cpp ${SOURCE_FILES})
target_link_libraries(main_defense1 ${MPI_LIBRARIES})

add_executable(main_distinguishable main_distinguishable.cpp ${SOURCE_FILES})
target_link_libraries(main_distinguishable ${MPI_LIBRARIES})

add_executable(main main.cpp ${SOURCE_FILES})
add_executable(main_efficiency main_efficiency.cpp ${SOURCE_FILES})
target_link_libraries(main_efficiency ${MPI_LIBRARIES})
