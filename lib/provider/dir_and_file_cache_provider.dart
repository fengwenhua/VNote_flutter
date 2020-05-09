import 'package:flutter/material.dart';
import 'package:vnote/models/document_model.dart';

/// [DirAndFileCacheProvider]是目录缓存
/// 在首页 id 为 approot
/// 其他的每点进去一个目录, 记录其 id 和 list
class DirAndFileCacheProvider with ChangeNotifier {
  Map<String, List<Document>> _dirCache = new Map<String, List<Document>>();

  /// [getDirAndFileCache]判断缓存是否存在该 [id]
  /// 存在则返回, 不然返回 null
  List<Document> getDirAndFileCache(String id) {
    if (this._dirCache.containsKey(id)) {
      return this._dirCache[id];
    } else {
      return null;
    }
  }

  /// [addDirAndFileList]
  void addDirAndFileList(String id, List<Document> list) {
    //this._dirCache.putIfAbsent(id, ()=>list);
    this._dirCache[id] = list;
    notifyListeners();
  }

  void removeDirAndFileList(String id) {
    if (this._dirCache.containsKey(id)) {
      this._dirCache.remove(id);
    }
    notifyListeners();
  }

  void updateDirAndFileList(String id, List<Document> list) {
    this._dirCache.update(id, (value) => (value = list), ifAbsent: () => list);
    notifyListeners();
  }

  /// 给某个列表添加一个元素(文件/文件夹)
  void addDirOrFileEle(String parentId, Document newEle) {
    //print("传入 model 的 id 是: " + id);
    List<Document> cur = this._dirCache[parentId];
    if (cur == null) {
      // 根目录没有数据
      print("根目录没有数据");
      cur = new List<Document>();
      cur.add(newEle);
      this._dirCache[parentId] = cur;
      notifyListeners();
    } else {
      if (!cur.contains(newEle)) {
        print("cache 中没有这个元素!");
        cur.add(newEle);
        this._dirCache[parentId] = cur;
        notifyListeners();
      }
    }
  }

  void renameEle(String parentId, String id, String name) {
    List<Document> cur = this._dirCache[parentId];
    List<Document> newList = cur.map((f) {
      if (f.id == id) {
        f.name = name;
        print("DirCache 重命名");
      }
      return f;
    }).toList();
    this._dirCache[parentId] = newList;
    notifyListeners();
  }

  /// 给某个列表删除一个元素(文件/文件夹)
  void delDirOrFileEle(String id, Document delELe) {
    List<Document> cur = this._dirCache[id];
    if (cur != null) {
      cur.remove(delELe);
      this._dirCache[id] = cur;
      notifyListeners();
    }
  }
}
