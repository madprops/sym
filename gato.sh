#!/bin/bash
# Source this file in .bashrc
# Then you can 'gato 22' etc

function gato()
{
  path=$(/bin/gat "${@:1}")
  cd "${path}"
}
