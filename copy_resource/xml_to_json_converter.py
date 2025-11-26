#!/usr/bin/env python3
"""
XML到JSON转换脚本
从Db.xml文件中提取game_items标签下的record元素，并转换为JSON格式
"""

import xml.etree.ElementTree as ET
import json
import os

def convert_xml_to_json():
    # 定义文件路径
    xml_file_path = "/Users/liguozheng/sky_hill_godot/copy_resource/Db.xml"
    output_file_path = "/Users/liguozheng/sky_hill_godot/resources/static_data/game_items_from_xml.json"
    
    # 解析XML文件
    try:
        tree = ET.parse(xml_file_path)
        root = tree.getroot()
    except Exception as e:
        print(f"解析XML文件失败: {e}")
        return
    
    # 查找game_items标签
    game_items_element = root.find('.//game_items')
    if game_items_element is None:
        print("未找到game_items标签")
        return
    
    # 提取所有record元素
    records = game_items_element.findall('record')
    if not records:
        print("game_items标签下没有找到record元素")
        return
    
    # 转换为JSON格式
    json_data = []
    
    for idx, record in enumerate(records, 1):
        # 获取所有属性
        attributes = record.attrib
        
        # 创建JSON对象，按照目标格式
        json_item = {
            "id": idx,
            "identity": attributes.get("identity", ""),
            "canUse": attributes.get("canUse", "0") == "1",  # 转换为布尔值
            "storage": attributes.get("storage", ""),
            "sprite": attributes.get("sprite", ""),
            "dysplay_name": attributes.get("dysplay_name", ""),
            "type": attributes.get("type", ""),
            "can_drop": attributes.get("can_drop", "False") == "True",  # 转换为布尔值
            "drop_percent": int(attributes.get("drop_percent", "0")) if attributes.get("drop_percent", "0").isdigit() else 0,
            "description": attributes.get("description", ""),
            "size": attributes.get("size", "")
        }
        
        json_data.append(json_item)
    
    # 写入JSON文件
    try:
        with open(output_file_path, 'w', encoding='utf-8') as f:
            json.dump(json_data, f, ensure_ascii=False, indent=2)
        print(f"成功转换 {len(json_data)} 条记录到 {output_file_path}")
    except Exception as e:
        print(f"写入JSON文件失败: {e}")

if __name__ == "__main__":
    convert_xml_to_json()