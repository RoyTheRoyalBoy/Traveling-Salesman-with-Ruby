require('sinatra')
require('sinatra/reloader')
require('pry')

get('/') do
  erb(:input)
end

get('/output') do
  @length = params.fetch("length")
  @width = params.fetch("width")
  puts @width

  	graphs = Struct.new(:num_vertex, :weight, :currentDist) 

	vertices = Struct.new(:x, :y, :weight, :connect, :visited, :node)

	def calcDistance (first, second) #this function works as intended
		x = second.x - first.x
		y = second.y - first.y
		distance = x*x+y*y
		return distance
	end

=begin //testing if calcDistance works
	first = vertex.new(1, 1, Float::INFINITY, -1, 0, 0)
	second = vertex.new(5, 5, Float::INFINITY, -1, 0, 0)
	puts calcDistance(first, second)
=end

	#nearest insertion method for traveling salesman
	def FASTTSPoption (graph, vertex_list)
		distance = 0
		min_weight = Float::INFINITY
		closest = 0
		count = 0

		i = 1
		while i < vertex_list.size #finding the closest point to the first point
			potential_distance = calcDistance(vertex_list[0], vertex_list[i])
			if potential_distance < min_weight 
				min_weight = potential_distance
				closest = i
			end
			i = i + 1
		end
		vertex_list[closest].visited = 1
		vertex_list[0].visited = 1
		vertex_list[closest].connect = 0
		vertex_list[0].connect = closest
		vertex_list[closest].weight = min_weight
		vertex_list[0].weight = min_weight

		distance = distance + 2 * Math.sqrt(min_weight)

		count = 2

		while count < graph.num_vertex
			insertion = Float::INFINITY
			last = 0
			visiting = 0
			while vertex_list[visiting].visited == 1 #makes sure that we skip vertices already visited
				visiting = visiting + 1
			end

			i = 0
			while i < vertex_list.size #find spot to insert new node
				if vertex_list[i].visited == 1 #if it's visited, check whether this is closest visited point
					kpotential_distance = Math.sqrt(calcDistance(vertex_list[i], vertex_list[visiting])) +
					Math.sqrt(calcDistance(vertex_list[visiting], vertex_list[vertex_list[i].connect])) - 
					Math.sqrt(vertex_list[i].weight);

					if  insertion > kpotential_distance #checking if our new distance is smaller than current distance
						insertion = kpotential_distance 
						last = i
					end
				end
				i = i + 1
			end

			distance = distance - Math.sqrt(vertex_list[last].weight); #update distance by square rooting
			vertex_list[visiting].weight = calcDistance(vertex_list[vertex_list[last].connect], vertex_list[visiting])
			vertex_list[last].weight = calcDistance(vertex_list[last], vertex_list[visiting])

			#update our distance by connecting last point back to first
			distance = distance + Math.sqrt(vertex_list[last].weight) + Math.sqrt(vertex_list[visiting].weight)
			vertex_list[visiting].connect = vertex_list[last].connect
			vertex_list[last].connect = visiting

			#mark this new node as visited
			vertex_list[visiting].visited = 1

			#increment count
			count = count + 1
		end

		#update our final distance
		graph.weight = distance
	end

	def TSPprint(graph, vertex_list)
		puts "Total distance = #{graph.weight}" #print out final distance
		connecting = 0
		print "Pathway: "
		i = 0
		while i < vertex_list.size #print out the nodes and their connection in order
			print vertex_list[connecting].node
			connecting = vertex_list[connecting].connect
			i = i + 1
		end
		puts vertex_list[connecting].node
		connecting = 0
		i = 0
		path = ""
		while i < vertex_list.size #print out the nodes and their connection in order
			path = path + vertex_list[connecting].node.to_s
			connecting = vertex_list[connecting].connect
			i = i + 1
		end
		path = path + vertex_list[connecting].node.to_s
		return path
	end


	input_num_vertex = @length.to_i
	count = 0
	vertex_list = []
	@width = @width.split(" ")
	i = 0
	while i < input_num_vertex * 2
		x = @width[i].to_i
		y = @width[i+1].to_i
		puts @width
		vertex = vertices.new(x, y, Float::INFINITY, -1, 0, i/2)
		vertex_list.push(vertex)
		i = i+2
	end

	graph = graphs.new(input_num_vertex, 0, 0) #declaring new graph

	i = 0
	while i < graph.num_vertex #confirming what was submitted/read in
		print vertex_list[i].to_a 
		puts 
		i = i + 1
	end

	FASTTSPoption(graph, vertex_list)
	TSPprint(graph, vertex_list)
	total_distance = graph.weight
	path_taken = TSPprint(graph, vertex_list)
	puts total_distance
	puts path_taken

	@rectangle = total_distance
	@path_way = path_taken
	erb(:output)
end