# SPDX-License-Identifier: Apache-2.0

#list(APPEND ZEPHYR_EXTRA_MODULES
#	/project/fun/tiny-soc/tiny-soc/packages/fwpit/sw
#  )

cmake_minimum_required(VERSION 3.13.1)

find_package(Zephyr REQUIRED HINTS $ENV{ZEPHYR_BASE})
project(hello_world)

target_sources(app PRIVATE src/main.c)
