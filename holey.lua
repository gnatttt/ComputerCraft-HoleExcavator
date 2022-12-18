local coal_name = "minecraft:coal"

function end_pos(length, width)
	local at_diagonal = false
	local on_surface = false

	if (length % 2 == 0 and width % 2 == 1) then
		at_diagonal = true
		on_surface = true
	elseif (length % 2 == 1 and width % 2 == 0) then
		on_surface = true
	elseif (length % 2 == 1 and width % 2 == 1) then
		at_diagonal = true
	elseif (length % 2 == 0 and width % 2 == 0) then
		on_surface = true
	end

	return at_diagonal, on_surface
end

function holify(length, width, depth)
	local at_diagonal, on_surface = end_pos(length, width)
	for w=1, width do
		for l=1, length do
			for d=1, depth do
				if (w % 2 == 1 and l % 2 == 1) then
					turtle.digDown()
					turtle.down()
				elseif (w % 2 == 1 and l % 2 == 0) then
					turtle.digUp()
					turtle.up()
				elseif (w % 2 == 0 and l % 2 == 1) then
					turtle.digUp()
					turtle.up()
				elseif (w % 2 == 0 and l % 2 == 0) then
					turtle.digDown()
					turtle.down()
				end
			end
			if (l == length) then
				if (w == width) then
					-- ends at opposite diagonal corner on surface
					if (at_diagonal and on_surface) then
						turtle.turnRight()
						turtle.turnRight()
						for block = 2, length do
							turtle.forward()
						end
					--ends at opposite diagonal but not on surface
					elseif (at_diagonal and not on_surface) then
						turtle.turnRight()
						turtle.turnRight()
						for block = 1, depth do
							turtle.up()
						end
						for block = 2, length do
							turtle.forward()
						end
					elseif (not at_diagonal and not on_surface) then
						for block = 1, depth do
							turtle.up()
						end
					end
					turtle.turnRight()

					for block = 2, width do
						turtle.forward()
					end
					turtle.turnRight()
				else
					if (w % 2 == 1) then
						turtle.turnRight()
						turtle.dig()
						turtle.forward()
						turtle.turnRight()
					else
						turtle.turnLeft()
						turtle.forward()
						turtle.turnLeft()
					end
				end
			else
				turtle.dig()
				turtle.forward()
			end
		end
	end
	turtle.back()
end

function get_coal_slot()
	for slot = 1, 16 do
		turtle.select(slot)
		local item = turtle.getItemDetail()
		if (item ~= nil) then
			if (item.name == coal_name) then
				return slot
			end
		end
	end
	return 17
end

function clear_inv()
	for slot = 1, 16 do
		turtle.select(slot)
		local item = turtle.getItemDetail()
		if (item ~= nil) then
			if (item.name ~= coal_name) then
				turtle.drop()
			end
		end
	end
end

function main()
	local length = 0
	local width = 0
	local depth = 0
	if #arg == 3 then
		length = tonumber(arg[1])
		width = tonumber(arg[2])
		depth = tonumber(arg[3])
	else
		print("Rerun program with 'length x width x depth' parameters at commandline...")
		print("EXAMPLE (5x5x5 hole): 'hole_excavation 5 5 5'")
		return
	end

	local current_fuel = turtle.getFuelLevel()
	local volume = length * width * depth
	if (current_fuel < volume) then
		local amt_coal = math.ceil(((volume - current_fuel) + (volume / 2)) / 80)
		slot = get_coal_slot()
		if (slot < 16) then
			turtle.select(slot)
			turtle.refuel(amt_coal)
			print("Current Fuel Level: " .. turtle.getFuelLevel())
		else
			print("Not sufficient fuel to satisfy the volume...")
			return
		end
	end
	holify(length, width, depth)
	clear_inv()
end

main()
