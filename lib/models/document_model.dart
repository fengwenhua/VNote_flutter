/// [Document] 代表每个文件/文件夹
class Document {
  /// [id] 为该文档的唯一标志
  String id;

  /// [name] 为该文档的名字
  String name;

  /// [isFile] 判断该文档是否是文件
  bool isFile;

  /// [dateModified] 为文档的修改时间
  DateTime dateModified;

  /// [configId] 为文档对应的 _vnote.json 配置文件的 id
  String configId;

  /// [imageFolderId] 为文档对应的 _v_images 文件夹的 id
  String imageFolderId;

  /// [parentId] 在点开文件的时候赋值, 主要用于"笔记"tab 的缓存删除
  String parentId;

  /// [notebookId] 这篇文章所属笔记本的 id，用于文件夹、笔记本删除时候，级联删除笔记 tab
  String notebookId;

  Document(
      {this.id,
      this.configId,
      this.name,
      this.dateModified,
      this.isFile = false,
      this.imageFolderId,
      this.parentId,
      this.notebookId});
}
