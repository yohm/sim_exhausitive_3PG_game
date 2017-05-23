cmake_minimum_required(VERSION 3.7)
project(step3)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES strategy.cpp strategy.hpp Game.cpp Game.hpp)
add_executable(runTest test.cpp ${SOURCE_FILES})
add_executable(filterEfficiency main.cpp ${SOURCE_FILES})

