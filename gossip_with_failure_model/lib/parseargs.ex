defmodule Gossip.Parseargs do 
  
  def parse_args(args) do
    unless length(args) == 4 do
      IO.puts "Ussage: ./gossipf numNodes failurenodes topology(full,2D,line,imp2D) algorithm(gossip,push-sum)" 
    else
      numNodes  =  Enum.at(args,0) |> String.to_integer()
      failNodes =  Enum.at(args,1) |> String.to_integer()
      topology  =  Enum.at(args,2) |> parse_topology()
      algorithm =  Enum.at(args,3) |> parse_algorithm()
      
      if numNodes < failNodes, do: IO.puts "Error: failure nodes more than total nodes!!!!!"
      if (topology==:twoD || topology==:imptwoD) && round_to_square(numNodes)<failNodes do
        IO.puts "Error: failure nodes more than total nodes, notice that for a grid topology, total nodes is rounded to highest square of an integer less than your input total nodes"
      end
      
      if topology==:twoD || topology==:imptwoD do
        {round_to_square(numNodes),failNodes,topology,algorithm}
      else 
        {numNodes,failNodes,topology,algorithm}
      end
    end
  end
  
  def parse_topology(topstr) do
      case topstr do
        "full"  -> :full
        "2D"    -> :twoD
        "line"  -> :line
        "imp2D" -> :imptwoD
      end
  end

  def parse_algorithm(algstr) do 
      case algstr do 
        "gossip"   -> :gossip
        "push-sum" -> :pushsum
      end
  end

  def round_to_square(n) do
      n |> :math.sqrt() |> :math.floor() |>  :math.pow(2) |> round()
  end




end