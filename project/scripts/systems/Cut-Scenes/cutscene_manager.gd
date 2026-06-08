extends Node

signal cutscene_finished

@onready var player = $"../1_floor/Entity/Player"
@onready var cinematic_bars = Global.npc.dialog_manager.cinematic_bars
@onready var dialog_manager = Global.npc.dialog_manager

var is_playing: bool = false
var spawned_actors: Dictionary = {}

func show_bars() -> void:
	cinematic_bars.show_bars()

func hide_bars() -> void:
	cinematic_bars.hide_bars()

func play_cutscene(data: CutsceneData) -> void:
	if is_playing:
		push_warning("Катсцена уже идёт, новая не запущена")
		return
	is_playing = true
	player.can_move = false
	player.is_being_controlled_by_cutscene = true
	if data.show_bars_at_start and cinematic_bars:
		await cinematic_bars.show_bars()
	for action in data.actions:
		match action.type:
			CutsceneAction.ActionType.WAIT:
				await get_tree().create_timer(action.duration).timeout
			CutsceneAction.ActionType.MOVE_ACTOR:
				await _execute_move_actor(action)
			CutsceneAction.ActionType.CALL_METHOD:
				await _execute_call_method(action)
			CutsceneAction.ActionType.SHOW_TEXT_OVER_ACTOR:
				await _execute_show_text_over_actor(action)
			CutsceneAction.ActionType.MOVE_ACTOR_BY_POINTS:
				await _execute_move_actor_by_points(action)
			CutsceneAction.ActionType.SPAWN_ACTOR:
				_execute_spawn_actor(action)
			CutsceneAction.ActionType.REMOVE_ACTOR:
				_execute_remove_actor(action)
			CutsceneAction.ActionType.ADD_ITEM:
				_execute_add_item(action)
			CutsceneAction.ActionType.ADD_QUEST:
				_execute_add_quest(action)
			CutsceneAction.ActionType.COMPLETE_QUEST:
				_execute_complete_quest(action)
	if data.hide_bars_at_end and cinematic_bars:
		await cinematic_bars.hide_bars()
	player.is_being_controlled_by_cutscene = false
	player.can_move = true
	is_playing = false
	cutscene_finished.emit()

func _resolve_actor(path_or_id: String) -> Node:
	if spawned_actors.has(path_or_id):
		return spawned_actors[path_or_id]
	return get_node_or_null(path_or_id)

func _execute_move_actor(action: CutsceneAction) -> void:
	var actor_node = _resolve_actor(action.actor_path)
	var path2d = get_node_or_null(action.path_node)
	if not path2d or not actor_node:
		push_error("MOVE_ACTOR: неверный путь к Path2D или актёру")
		return
	if actor_node.has_method("set_is_controlled"):
		actor_node.set_is_controlled(true)
	var follower = ActorFollower.new()
	follower.speed = action.move_speed
	follower.actor = actor_node
	follower.cutscene_mode = true
	path2d.add_child(follower)
	follower.start()
	await follower.finished
	follower.queue_free()
	if actor_node.has_method("set_is_controlled"):
		actor_node.set_is_controlled(false)

func _execute_call_method(action: CutsceneAction) -> void:
	var target = _resolve_actor(action.target_path)
	if not target:
		push_error("CALL_METHOD: target not found: " + action.target_path)
		return
	if not target.has_method(action.method_name):
		push_error("CALL_METHOD: method not found: " + action.method_name)
		return
	var result = target.callv(action.method_name, action.args)
	if action.wait_for_signal and result is Signal:
		await result

func _execute_show_text_over_actor(action: CutsceneAction) -> void:
	var actor = _resolve_actor(action.text_actor_path)
	if not actor:
		push_error("SHOW_TEXT_OVER_ACTOR: actor not found: " + action.text_actor_path)
		return
	var text_pos = actor.global_position + Vector2(40, 0)
	dialog_manager.show_text_at_position(action.text_to_show, text_pos, action.wait_for_completion)
	if action.wait_for_completion:
		await dialog_manager.dialog_finished

func _execute_move_actor_by_points(action: CutsceneAction) -> void:
	var actor_node = _resolve_actor(action.actor_path)
	if not actor_node:
		push_error("MOVE_ACTOR_BY_POINTS: actor not found: " + action.actor_path)
		return
	if action.points.size() < 2:
		push_error("MOVE_ACTOR_BY_POINTS: need at least 2 points")
		return
	if actor_node.has_method("set_is_controlled"):
		actor_node.set_is_controlled(true)
	var temp_path = Path2D.new()
	var curve = Curve2D.new()
	for point in action.points:
		if point is Vector2:
			curve.add_point(point)
	temp_path.curve = curve
	add_child(temp_path)
	var follower = ActorFollower.new()
	follower.speed = action.points_speed
	follower.actor = actor_node
	follower.cutscene_mode = true
	temp_path.add_child(follower)
	follower.start()
	await follower.finished
	follower.queue_free()
	temp_path.queue_free()
	if actor_node.has_method("set_is_controlled"):
		actor_node.set_is_controlled(false)

func _execute_spawn_actor(action: CutsceneAction) -> void:
	if action.spawn_id.is_empty():
		push_error("SPAWN_ACTOR: spawn_id не задан")
		return
	if action.scene_path.is_empty():
		push_error("SPAWN_ACTOR: scene_path не задан")
		return
	var scene = load(action.scene_path)
	if not scene:
		push_error("SPAWN_ACTOR: не удалось загрузить сцену " + action.scene_path)
		return
	var instance = scene.instantiate()
	if not instance:
		push_error("SPAWN_ACTOR: не удалось создать экземпляр")
		return
	var parent = get_tree().root
	if not action.parent_path.is_empty():
		var p = get_node_or_null(action.parent_path)
		if p:
			parent = p
	parent.add_child(instance)
	if "global_position" in instance:
		instance.global_position = action.spawn_position
	if not action.skin.is_empty() and instance.has_method("set_skin"):
		instance.set_skin(action.skin)
	if action.hide_marker and instance.has_method("set_force_hide_marker"):
		instance.set_force_hide_marker(true)
	spawned_actors[action.spawn_id] = instance

func _execute_remove_actor(action: CutsceneAction) -> void:
	if action.remove_target.is_empty():
		push_error("REMOVE_ACTOR: remove_target не задан")
		return
	var target = _resolve_actor(action.remove_target)
	if not target:
		push_error("REMOVE_ACTOR: target not found: " + action.remove_target)
		return
	if target.has_method("queue_free"):
		target.queue_free()
	else:
		push_error("REMOVE_ACTOR: target does not have queue_free method")
	if spawned_actors.has(action.remove_target):
		spawned_actors.erase(action.remove_target)

func _execute_add_item(action: CutsceneAction) -> void:
	var item_res = load(action.item_resource_path)
	if not item_res or not (item_res is ItemData):
		push_error("ADD_ITEM: неверный путь к ItemData: " + action.item_resource_path)
		return
	var item = item_res.duplicate()
	if action.item_amount > 0:
		item.amount = action.item_amount
	var player_inv = get_tree().root.find_child("PlayerInventory", true, false)
	if player_inv and player_inv.has_method("add_item"):
		player_inv.add_item(item)
	else:
		push_error("ADD_ITEM: PlayerInventory не найден")

func _execute_add_quest(action: CutsceneAction) -> void:
	var quest_res = load(action.quest_resource_path)
	if not quest_res or not (quest_res is Quest):
		push_error("ADD_QUEST: неверный путь к Quest: " + action.quest_resource_path)
		return
	var quest = quest_res.duplicate()
	if quest.state == "not_started":
		quest.state = "in_progress"
	if player and player.quest_manager:
		player.quest_manager.add_quest(quest)
	else:
		push_error("ADD_QUEST: QuestManager не найден у игрока")

func _execute_complete_quest(action: CutsceneAction) -> void:
	if action.complete_quest_id.is_empty():
		push_error("COMPLETE_QUEST: complete_quest_id не задан")
		return
	if not player or not player.quest_manager:
		push_error("COMPLETE_QUEST: QuestManager не найден у игрока")
		return
	var qm = player.quest_manager
	var quest = qm.get_quest(action.complete_quest_id)
	if not quest:
		push_error("COMPLETE_QUEST: квест '" + action.complete_quest_id + "' не найден")
		return
	qm.complete_quest_ex(action.complete_quest_id)
