# Gossip

**A gossip eample using elixir** 

This program builds up four kinds of topology: 

line :Node only have neighbor before or after it

full :Every node is the neighbor of every other node

2D   :Two dimensional grid

imp2D:Grid arrangement but one random other neighboor is selected from the list of all nodes 

And test how fast gossip and push sum (s is node number and w is 1 for all nodes) can converge on these four topologies. You can specify your network size in command line.

Input would be:
gossip numNodes topology algorithm
Where numNodes is the number of actors involved (for 2D based topologies it is round up until getting a square), topology is one of full, 2D, line, imp2D, algorithm is one of gossip, push-sum.

Output is the amount of time it took to achieve convergence of the algorithm.

## Ussage
Get into gossip directory, type "mix escript.build" in terminal to get executable file "gossip"
Then in your command line, type "./gossip numNodes topology algorithm" and you will get the result

## Notice 
For gossip, node will start sending message once it has received one, and convergence condition is every node in the network get the message at least onece.
For pushsum, node only send message one time when received message one time, and convergence condition is sum estimation does not change more than 1.0e-10 in three consecutive rounds.
