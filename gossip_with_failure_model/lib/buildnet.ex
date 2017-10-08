defmodule Gossip.Buildnet do 
  
  def build_topology(numNodes, :line) do
      build_n_nodes(numNodes)
      update_neighbor_for_all_nodes_line(numNodes, numNodes) 
  end

  def build_topology(numNodes, :full) do
      build_n_nodes(numNodes)
      update_neighbor_for_all_nodes_full(numNodes, numNodes)
  end

  def build_topology(numNodes, :twoD) do
      numNodes = round_to_square(numNodes)
      build_n_nodes(numNodes)
      numRows = :math.sqrt(numNodes) |> round()
      update_neighbor_for_all_nodes_twoD(numNodes, numRows)
  end

  def build_topology(numNodes, :imptwoD) do
      numNodes = round_to_square(numNodes)
      build_n_nodes(numNodes)
      numRows = :math.sqrt(numNodes) |> round()
      update_neighbor_for_all_nodes_imptwoD(numNodes,numRows)
  end
  
  def shut_down_nodes(numnodes,n) do
      shut_down_list = generate_shut_down_list(numnodes,n)
      execute_shut_down_nodes(shut_down_list)
  end

  ########### start up all nodes in a required topology ############
  def build_n_nodes(1) do
      Gossip.Node.start(:node1,1)
  end
  def build_n_nodes(n) when n>1 do
      "node"<>Integer.to_string(n) |> String.to_atom() |> Gossip.Node.start(n)
      build_n_nodes(n-1)
  end

  ########### line topology #########################################
  def update_neighbor_for_all_nodes_line(_cur, n) when n==1 do  # cur: current node number, n: total node number
      nil
  end
  def update_neighbor_for_all_nodes_line(cur, n) when cur==n do
      curnode = "node"<>Integer.to_string(cur) |> String.to_atom()
      prevnode = "node"<>Integer.to_string(cur-1) |> String.to_atom()
      Gossip.Node.update_neighbor(curnode, {prevnode}) 
      update_neighbor_for_all_nodes_line(cur-1, n)
  end
  def update_neighbor_for_all_nodes_line(cur, _n) when cur==1 do
      Gossip.Node.update_neighbor(:node1, {:node2}) 
  end
  def update_neighbor_for_all_nodes_line(cur, n) when n>1 do 
      curnode = "node"<>Integer.to_string(cur) |> String.to_atom()
      prevnode = "node"<>Integer.to_string(cur-1) |> String.to_atom()
      nxtnode = "node"<>Integer.to_string(cur+1) |> String.to_atom()
      Gossip.Node.update_neighbor(curnode, {prevnode,nxtnode})
      update_neighbor_for_all_nodes_line(cur-1, n) 
  end

  ############# full topology #######################################
  def update_neighbor_for_all_nodes_full(_cur, n) when n==1, do: nil
  def update_neighbor_for_all_nodes_full(cur, _n) when cur==0, do: nil
  def update_neighbor_for_all_nodes_full(cur, n) when n>1 do
      neighbortuple = create_node_tuples(1,n,{})
      neighbortuple = Tuple.delete_at(neighbortuple,cur-1)
      curnode = "node"<>Integer.to_string(cur) |> String.to_atom()
      Gossip.Node.update_neighbor(curnode, neighbortuple)
      update_neighbor_for_all_nodes_full(cur-1, n)
  end
      # create a tuple from cur to n {:nodecur,:nodecur+1,:nodecur+2,...,:noden}
  def create_node_tuples(cur, n, tup) when cur==n do
      tup = Tuple.append(tup, "node"<>Integer.to_string(cur) |> String.to_atom())
      tup
  end
  def create_node_tuples(cur, n, tup) when cur<n do
      tup = Tuple.append(tup, "node"<>Integer.to_string(cur) |> String.to_atom())
      create_node_tuples(cur+1, n, tup)
  end

  ############## Two Dimension Grid topology ###########################
  def update_neighbor_for_all_nodes_twoD(_cur,rows) when rows==1, do: nil
  def update_neighbor_for_all_nodes_twoD(cur,_rows) when cur==0,  do: nil 
  def update_neighbor_for_all_nodes_twoD(cur,rows) when cur>0 do
      neighbortuple = {}
      currentnode = "node"<>Integer.to_string(cur) |> String.to_atom()
      neighbortuple = Tuple.append(neighbortuple, up_in_bound?(cur,rows)    && "node"<>Integer.to_string(cur-rows) |> String.to_atom())
      neighbortuple = Tuple.append(neighbortuple, left_in_bound?(cur,rows)  && "node"<>Integer.to_string(cur-1)    |> String.to_atom())
      neighbortuple = Tuple.append(neighbortuple, right_in_bound?(cur,rows) && "node"<>Integer.to_string(cur+1)    |> String.to_atom())
      neighbortuple = Tuple.append(neighbortuple, down_in_bound?(cur,rows)  && "node"<>Integer.to_string(cur+rows) |> String.to_atom())
      neighbortuple = tuple_delete_nil(neighbortuple)
      Gossip.Node.update_neighbor(currentnode, neighbortuple)
      update_neighbor_for_all_nodes_twoD(cur-1,rows)
  end

    # Because our node starts from 1 (up to rows*rows), to make sure node and node-1 is in one line, we should -1 on node first, and then 
    # node -> node-1, node-1 -> node-2; originally node/rows and node-1/rows should be same, for our implementation node-1/rows and node-2/rows should be same
  def left_in_bound?(nodenum, rows) do
      if nodenum-1>0 && div(nodenum-1,rows)===div(nodenum-2,rows)  do
        true
      else 
        nil
      end
  end
  def right_in_bound?(nodenum, rows) do
      if nodenum+1<rows*rows+1 && div(nodenum-1,rows)===div(nodenum,rows)  do
        true
      else 
        nil
      end
  end
  def up_in_bound?(nodenum, rows) do
      if nodenum-rows>0  do
        true
      else 
        nil
      end
  end
  def down_in_bound?(nodenum, rows) do
      if nodenum+rows<rows*rows+1  do
        true
      else 
        nil
      end
  end
      # floor number n to number which can build a grid 
  def round_to_square(n) do
      n |> :math.sqrt() |> :math.floor() |>  :math.pow(2) |> round()
  end
      # delete all nils in tuple
  def tuple_delete_nil(tuple) do
      list = Tuple.to_list(tuple)
      list = [nil|list] |> Enum.uniq() |> Enum.sort() |> List.delete_at(0) #append nil at first so every tuple has nil so that we can delete at 0
      List.to_tuple(list)
  end

  ####################### Imperfect 2D topology ###########################
  def update_neighbor_for_all_nodes_imptwoD(cur,rows) do
      update_neighbor_for_all_nodes_twoD(cur,rows)
      nodenum = rows * rows
      add_random_neighbor(cur,nodenum)
  end

  def add_random_neighbor(_cur,nodenum) when nodenum==1, do: nil
  def add_random_neighbor(cur,_nodenum) when cur==0, do: nil
  def add_random_neighbor(cur,nodenum)  when cur>0 do
      curnodename = "node"<>Integer.to_string(cur) |> String.to_atom()
      curneighbor = Gossip.Node.get_neighbors(curnodename)
      newneighbor = generate_new_neighbor(cur,nodenum,curneighbor)
      # update newneighbor into current nodes neighbortuple
      add_new_neighbor(curnodename,newneighbor)
      # update current neighbor into newneighbor's neighbortuple
      add_new_neighbor(newneighbor,curnodename)
      # recursive call
      add_random_neighbor(cur-1,nodenum)
  end

  def add_new_neighbor(cur,new) do
      neighborlist = Gossip.Node.get_neighbors(cur) |> Tuple.to_list 
      newneighbortuple = [new] ++ neighborlist |> Enum.uniq() |> List.to_tuple()
      Gossip.Node.update_neighbor(cur,newneighbortuple)
  end

  def generate_new_neighbor(cur,nodenum,curneighbors) do
      cannotchoose = Tuple.to_list(curneighbors) ++ ["node"<>Integer.to_string(cur) |> String.to_atom()]
      neighborpool = Enum.map(1..nodenum, fn num -> "node"<>Integer.to_string(num) |> String.to_atom() end)  
      neighborpool = neighborpool -- cannotchoose
      idx = neighborpool |> length() |> :rand.uniform()
      Enum.at(neighborpool, idx-1)
  end

  ################ functions used for shutting down nodes ##################
  # generate a list of n different numbers from range 1 ~ numnodes
  def generate_shut_down_list(numnodes,n) do
      generate_shut_down_set(MapSet.new([]),0,numnodes,n) |> MapSet.to_list()
  end

  def generate_shut_down_set(set, setsize, _numnodes, n) when setsize==n, do: set
  def generate_shut_down_set(set, _setsize, numnodes, n) do 
      newset = MapSet.put(set, :rand.uniform(numnodes)) 
      newsetsize = MapSet.size(newset)
      generate_shut_down_set(newset, newsetsize, numnodes, n)
  end

  def execute_shut_down_nodes(shut_down_list) when length(shut_down_list)==0, do: nil
  def execute_shut_down_nodes(shut_down_list) do 
      [head|shut_down_list] = shut_down_list
      "node"<>Integer.to_string(head) |> String.to_atom() |> Gossip.Node.shut_down_node()
      execute_shut_down_nodes(shut_down_list)
  end
end