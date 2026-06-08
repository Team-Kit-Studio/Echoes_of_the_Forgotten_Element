extends Resource
class_name Rewards

enum RewardType {
	COINS,
	ITEM,
	EXPERIENCE,
	CUSTOM
}

# ═══════════════════ НАГРАДА ═══════════════════
@export_category("Награда")
## Тип награды: COINS (монеты), ITEM (предмет), EXPERIENCE (опыт), CUSTOM (особая).
@export var reward_type: RewardType = RewardType.COINS
## Количество (монет, опыта или предметов).
@export var reward_amount: int = 1
## Для ITEM – путь к ресурсу предмета (например "res://items/sword.tres"). Для остальных типов не используется.
@export var custom_id: String = ""
