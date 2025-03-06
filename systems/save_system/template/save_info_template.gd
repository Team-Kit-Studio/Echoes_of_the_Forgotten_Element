extends Object
class_name SavesTemplate

class BaseSaveTemplate:
    var save: Dictionary = {
        "data": {}
    }


class BaseDataSaveTemplate: 
    var data: Dictionary = {
        "metadata": {
            "name": "",
            "last_modified_time": {"date": null, "time": null},
            "missions_text": ""
        },
        "data": {
            "level_scene": "",
            "player": null,
            "enemy": [],
            "allies": [],
            "items": []
        }
    }

# Пока не нужно
# class BaseMetaDataTemplate: 
#     func _init(last_load_save: String):
#         info["last_load_save"] = last_load_save
        
#     var info: Dictionary = {
#         "last_load_save": "No last save",
#         "save_metadata": null
#     }
