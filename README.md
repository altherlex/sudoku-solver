# sudoku-solver
A ruby script that solves your sudoku game

## How run

[Youtube video demo](https://www.youtube.com/watch?v=eW1Ztm_PCfQ&t=5s)

Execute these commands in your terminal:

```shell
    git clone https://github.com/altherlex/sudoku-solver.git
    cd sudoku-solver
    bundle install
    irb
```
```ruby
    require './sudoku-solver'
    game = Sudoku.new
    // You see the building solution frame by frame
    game.next
```

## Requirements

    brew install ruby
    brew install git
    gem install bundle
