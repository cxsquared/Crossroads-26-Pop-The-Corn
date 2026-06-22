class_name RunState

var wave: int = 0
var current_customers: Array[Customer] = []
var previous_customers: Array[Customer] = []
var previous_target = 0
var popped = 0
var money: int = 0
var flavors_bought: Array[FlavorShopData] = []


func next_wave():
	wave += 1
	previous_customers = previous_customers + current_customers
	current_customers.clear()

	match wave:
		1:
			current_customers = [Customer.new(0), Customer.new(0), Customer.new(0)]
		2:
			current_customers = [Customer.new(2)]
		3:
			current_customers = [Customer.new(1), Customer.new(1), Customer.new(1)]
		4:
			current_customers = [Customer.new(0), Customer.new(0), Customer.new(1), Customer.new(2)]

	if current_customers.is_empty():
		for _i in range(randi_range(3, wave)):
			current_customers.push_back(Customer.new(randi_range(0, 2)))

	return current_customers


func get_current_wave_target() -> int:
	return current_customers.reduce(func(total, customer): return total + customer.popcorn_needed, 0)


class Customer:
	var size: int = 0
	var popcorn_needed: int = -1


	func _init(init_size) -> void:
		size = init_size
		popcorn_needed = get_popcorn_for_size(init_size)


	func get_popcorn_for_size(customer_size: int) -> int:
		match customer_size:
			0:
				return 3
			1:
				return 7
			2:
				return 13

		return 5 # default if we don't know what to return for size
