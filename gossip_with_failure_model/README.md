# Gossip

**A gossip eample implementing failure model using elixir**
This program builds up four kinds of topology: 
line :Node only have neighbor before or after it
full :Every node is the neighbor of every other node
2D   :Two dimensional grid
imp2D:Grid arrangement but one random other neighboor is selected from the list of all nodes 

Then kill a certain number of nodes randomly.

At last see how fast (or whether or not) gossip and push sum (s is node number and w is 1 for all nodes) can converge on these four topologies with failure nodes. You can specify your network size and number of fail nodes in command line.

Notice that gossip converged when all alive nodes get the message at least once, push sum converges when sum estimation does not change more than 1.0e-10 in three consecutive rounds. And, for gossip, if you make too many nodes die, some nodes may never get the message if all of its neighbors are killed, so this program will execute forever without convergence.

Input would be:
gossip numNodes failurenodes topology algorithm
Where numNodes is the number of nodes involved (for 2D based topologies it is round up until getting a square), failurenodes is number of nodes to be killed after building the topology, topology is one of full, 2D, line, imp2D, algorithm is one of gossip, push-sum.

Output is the amount of time it took to achieve convergence of the algorithm.

## Ussage
Get into gossip_with_failure_model directory, type "mix escript.build" in terminal to get executable file "gossipf"
Then in your command line, type "./gossipf numNodes failurenodes topology algorithm" and you will get the result


