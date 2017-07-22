cmake_minimum_required(VERSION 3.7)
project(cpp)

set(CMAKE_CXX_STANDARD 11)

#set(CMAKE_VERBOSE_MAKEFILE 1)

set(SOURCE_FILES_M2 Action.cpp Action.hpp Strategy.cpp Strategy.hpp Game.cpp Game.hpp Graph.cpp Graph.hpp)
set(SOURCE_FILES_M3 Action.cpp Action.hpp GameM3.cpp GameM3.hpp StrategyM3.cpp StrategyM3.hpp Graph.cpp Graph.hpp)
find_package(MPI)
include_directories(SYSTEM ${MPI_INCLUDE_PATH})

add_executable(test_Strategy test_Strategy.cpp ${SOURCE_FILES_M2})
add_executable(test_StrategyM3 test_StrategyM3.cpp ${SOURCE_FILES_M3})
add_executable(test_Graph test_Graph.cpp Graph.cpp Graph.hpp)
add_executable(test_Game test_Game.cpp ${SOURCE_FILES_M2})
add_executable(test_GameM3 test_GameM3.cpp ${SOURCE_FILES_M3})

add_executable(main_defensible main_defensible.cpp ${SOURCE_FILES_M2})
target_link_libraries(main_defensible ${MPI_LIBRARIES})

add_executable(main_distinguishable main_distinguishable.cpp ${SOURCE_FILES_M2})
target_link_libraries(main_distinguishable ${MPI_LIBRARIES})

add_executable(main_efficiency main_efficiency.cpp ${SOURCE_FILES_M2})
target_link_libraries(main_efficiency ${MPI_LIBRARIES})

add_executable(main_m3_defensible main_m3_defensible.cpp ${SOURCE_FILES_M3})
target_link_libraries(main_m3_defensible ${MPI_LIBRARIES})

add_executable(main_m3_efficiency main_m3_efficiency.cpp ${SOURCE_FILES_M3})
target_link_libraries(main_m3_efficiency ${MPI_LIBRARIES})

