#!/usr/bin/env python3
"""
提取XML文件中的武器数据并转换为JSON格式
"""

import xml.etree.ElementTree as ET
import json
import os

def extract_weapons_from_xml(xml_file_path, output_dir):
    """
    从XML文件中提取武器数据并保存为JSON
    """
    try:
        # 解析XML文件
        tree = ET.parse(xml_file_path)
        root = tree.getroot()
        
        # 查找weapons节点
        weapons_node = root.find('weapons')
        if weapons_node is None:
            print("未找到weapons节点")
            return False
        
        # 提取所有武器记录
        weapons_list = []
        
        for record in weapons_node.findall('record'):
            weapon_data = {
                'name': record.get('name', ''),
                'skill': record.get('skill', ''),
                'skill_border': int(record.get('skill_border', 0)),
                'weapon_type': record.get('weapon_type', ''),
                'damage_min': int(record.get('damage_min', 0)),
                'damage_max': int(record.get('damage_max', 0)),
                'dex': int(record.get('dex', 0)),
                'str': int(record.get('str', 0)),
                'spd': int(record.get('spd', 0))
            }
            weapons_list.append(weapon_data)
        
        # 确保输出目录存在
        os.makedirs(output_dir, exist_ok=True)
        
        # 保存为JSON文件
        output_file = os.path.join(output_dir, 'weapons.json')
        with open(output_file, 'w', encoding='utf-8') as f:
            json.dump(weapons_list, f, ensure_ascii=False, indent=2)
        
        print(f"成功提取 {len(weapons_list)} 个武器数据")
        print(f"保存到: {output_file}")
        return True
        
    except ET.ParseError as e:
        print(f"XML解析错误: {e}")
        return False
    except Exception as e:
        print(f"处理错误: {e}")
        return False

def main():
    # XML文件路径
    xml_file = "/Users/liguozheng/sky_hill_godot/copy_resource/Db.xml"
    
    # 输出目录
    output_directory = "/Users/liguozheng/sky_hill_godot/resources/static_data"
    
    # 提取武器数据
    if extract_weapons_from_xml(xml_file, output_directory):
        print("武器数据提取完成！")
    else:
        print("武器数据提取失败！")

if __name__ == "__main__":
    main()