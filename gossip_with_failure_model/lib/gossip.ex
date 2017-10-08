defmodule Gossip do
  def main(args) do 
    
    # numnodes failurenodes topology(full,2D,line,imp2D) algorithm(gossip,push-sum)
    # if topology is 2D or imp2D, numnodes would be round to highest number less than numnodes that can build a grid
    # failnodes will not be rounded
    {numnodes,failnodes,topology,algorithm} = Gossip.Parseargs.parse_args(args) 
   
    IO.puts "start building topology"
    Gossip.Buildnet.build_topology(numnodes, topology)
    
    IO.puts "let some nodes fail :)"
    Gossip.Buildnet.shut_down_nodes(numnodes, failnodes)  

    IO.puts "start algorithm:"
    Gossip.Startalg.start_protocol_f(numnodes, failnodes, algorithm)
    
  end
end