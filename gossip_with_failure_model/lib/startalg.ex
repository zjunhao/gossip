defmodule Gossip.Startalg do
    
    def start_protocol(numnodes, :gossip) do
        IO.puts "start gossip"
        {time,_} = :timer.tc(fn-> start_gossip(numnodes) end)
        IO.puts "gossip finished, every node gets the rumor, time taken: #{time}"
    end

    def start_protocol(numnodes, :pushsum) do
        IO.puts "start push sum"
        {time,_} = :timer.tc(fn-> start_pushsum(numnodes) end)
        IO.puts "Time taken: #{time}"
    end
    
    # start protocol on a network with failure nodes
    def start_protocol_f(total,failure, :gossip) do
        IO.puts "start gossip(with failure nodes)"
        {time,_} = :timer.tc(fn-> start_gossip_f(total,failure) end)
        IO.puts "gossip with failure nodes finished, every live node gets the rumor, time taken: #{time}"
    end

    # start protocol on a network with failure nodes
    def start_protocol_f(total,failure, :pushsum) do 
        IO.puts "start push sum(with failure nodes)"
        {time,_} = :timer.tc(fn-> start_pushsum_f(total,failure) end)
        IO.puts "Time taken: #{time}"
    end
    ####################### gossip algorithm ################################# 
    # start gossip on a network without failure nodes
    def start_gossip(numnodes) do
        firstnode = :rand.uniform(numnodes) |> num_name()
        Gossip.Node.send_rumor(firstnode,"Big Bad Wolf!",self())
        wait_till_all_nodes_know(0,numnodes)
    end
    
    # start gossip on a network with failure nodes
    def start_gossip_f(total,failure) do 
        firstnode = get_first_node_f(total)
        Gossip.Node.send_rumor(firstnode,"Big Bad Wolf!",self())
        wait_till_all_nodes_know(0,total-failure)
    end

    # convert node number to atom, say 2 -> :node2
    def num_name(nodenum), do: "node"<>Integer.to_string(nodenum) |> String.to_atom()

    def wait_till_all_nodes_know(n,numnodes) when n===numnodes, do: nil # n represents number of nodes knowing the rumor
    def wait_till_all_nodes_know(n,numnodes) when n>=0 do
        receive do 
            {:know_rumor} ->  wait_till_all_nodes_know(n+1,numnodes)
        end 
    end

    ########################## push sum algorithm ############################
    def start_pushsum(numnodes) do
        firstnode = :rand.uniform(numnodes) |> num_name()
        # IO.puts "firstnode #{inspect firstnode}"
        Gossip.Node.do_pushsum(firstnode,0,0,self())
        wait_till_converge(0,1)
    end
    
    def start_pushsum_f(total,_failure) do 
        firstnode = get_first_node_f(total)
        Gossip.Node.do_pushsum(firstnode,0,0,self())
        wait_till_converge(0,1)
    end

    def wait_till_converge(first,second) do
        receive do
          {:sum_estimate,cur} ->
              if converge?(first,second,cur) do
                  IO.puts "Converged! Sum estimate is #{cur}"
              else 
                  wait_till_converge(second,cur) 
              end
        end
    end

    def converge?(first, second, third) do
        abs(first-second) <= :math.pow(10,-10) && abs(second-third) <= :math.pow(10,-10)
    end

    def get_first_node_f(numnodes) do 
        nodename = :rand.uniform(numnodes) |> num_name()
        if Gossip.Node.get_neighbors(nodename)!={} do
            nodename 
        else
            get_first_node_f(numnodes)
        end
    end
end