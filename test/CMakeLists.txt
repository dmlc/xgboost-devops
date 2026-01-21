cmake_minimum_required(VERSION 3.16)
project(hello_world CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

add_executable(hello_world main.cpp utils.cpp)
