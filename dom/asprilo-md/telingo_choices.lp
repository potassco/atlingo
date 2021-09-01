{move(robot(N),(0..1,0..1))}:-robot(N).
{position(robot(N),(0..1,0..1))}:-robot(N).
{move(robot(N))}:-robot(N).
{move(robot(N))}:-robot(N).
% {following(robot(N),robot(M)}:-robot(N,M).
{no_move_right(robot(N))}:-robot(N).
{no_move_left(robot(N))}:-robot(N).
{no_move_up(robot(N))}:-robot(N).
{no_move_down(robot(N))}:-robot(N).
{move_horizontally(robot(N))}:-robot(N).
{no_move_vertically(robot(N))}:-robot(N).
{no_move_horizontally(robot(N))}:-robot(N).