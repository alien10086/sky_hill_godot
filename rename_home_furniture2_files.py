#!/usr/bin/env python3
import os
import shutil

# 设置基础目录路径
base_dir = "/Users/liguozheng/sky_hill_godot/assets/sprites/world_items/home_furniture2"

# 需要处理的文件夹列表
folders = [
    "Cabinet",
    "Chair", 
    "decoration",
    "electronics",
    "flower",
    "light",
    "Shelf",
    "Sofa",
    "vending_machine"
]

# 处理每个文件夹
for folder in folders:
    folder_path = os.path.join(base_dir, folder)
    
    if not os.path.exists(folder_path):
        print(f"警告: 文件夹 {folder_path} 不存在，跳过")
        continue
        
    print(f"\n处理文件夹: {folder}")
    
    # 获取所有PNG文件
    png_files = [f for f in os.listdir(folder_path) if f.endswith('.png')]
    png_files.sort()  # 按名称排序，确保一致性
    
    print(f"找到 {len(png_files)} 个PNG文件")
    
    # 重命名文件
    for i, old_name in enumerate(png_files):
        old_path = os.path.join(folder_path, old_name)
        new_name = f"{folder}_{i}.png"
        new_path = os.path.join(folder_path, new_name)
        
        # 如果新文件名已存在，先删除
        if os.path.exists(new_path) and old_path != new_path:
            os.remove(new_path)
            print(f"删除已存在的文件: {new_name}")
            
        # 重命名文件
        if old_path != new_path:
            os.rename(old_path, new_path)
            print(f"重命名: {old_name} -> {new_name}")
            
            # 处理对应的.import文件
            old_import = f"{old_name}.import"
            new_import = f"{new_name}.import"
            old_import_path = os.path.join(folder_path, old_import)
            new_import_path = os.path.join(folder_path, new_import)
            
            if os.path.exists(old_import_path):
                # 如果新.import文件已存在，先删除
                if os.path.exists(new_import_path):
                    os.remove(new_import_path)
                    print(f"删除已存在的文件: {new_import}")
                    
                # 重命名.import文件
                os.rename(old_import_path, new_import_path)
                print(f"重命名: {old_import} -> {new_import}")

print("\n所有文件重命名完成！")