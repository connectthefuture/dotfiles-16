#!/bin/zsh

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Attach to Tmux as early as possible.
[[ -f ${HOME}/.shrc ]] && source ${HOME}/.shrc

# oh-my-zsh
# ZSH_THEME="avit"

# Prezto setup
prezto_file="${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
[[ -s $prezto_file ]] && source $prezto_file
