cmake_minimum_required(VERSION 3.7)
project(step3)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES main.cpp strategy.cpp strategy.hpp Game.cpp Game.hpp)
add_executable(step3 ${SOURCE_FILES})