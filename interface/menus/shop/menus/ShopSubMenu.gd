extends "res://interface/menus/Menu.gd"

export(String, "sell_to", "buy_from") var ACTION = ""

onready var items_list = $Column/Row/ShopItemsList
onready var description_panel = $Column/DescriptionPanel
onready var info_panel = $Column/Row/InfoPanel
onready var amount_popup = items_list.get_node("AmountPopup")

func _ready():
	assert ACTION != ""

func initialize(shop, buyer, items):
	for item in items:
		var price = shop.get_buy_value(item) if ACTION == "buy_from" else item.price
		var item_button = items_list.add_item_button(item, price)

		item_button.connect("pressed", self, "_on_ItemButton_pressed", [shop, buyer, item])
		item_button.connect("pressed", info_panel, "_on_focused_Item_amount_changed", [item])
	items_list.connect("focused_button_changed", self, "_on_ItemList_focused_button_changed")
	items_list.initialize()

	info_panel.initialize(buyer.get_node("Purse"))

func _on_ItemList_focused_button_changed(item_button):
	description_panel.display(item_button.description)

func open():
	.open()
	items_list.get_child(0).grab_focus()

func close():
	.close()
	queue_free()

func _on_ItemButton_pressed(shop, buyer, item):
	var focused_item = get_focus_owner()
	amount_popup.initialize(1, item.amount)
	var amount = yield(amount_popup.open(), "completed")
	focused_item.grab_focus()
	if not amount:
		return
	shop.call(ACTION, buyer, item, amount)
