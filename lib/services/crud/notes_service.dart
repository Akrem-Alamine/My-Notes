import 'package:flutter/material.dart';
import 'package:mynote/services/crud/crud_exceptions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' show join;


class NotesService{
  Database? _db;
  Future<DatabaseNote> updateNote({
    required DatabaseNote note,
    required String text,
  }) async {
    final db = _getDatabaseOrThrow();
    await getNote(id: note.id);
    final updatesCount = await db.update(noteTable, {
      textColumn: text,
      isSyncedWithCloudColumn:0,
    });
    if(updatesCount == 0){
      throw CouldNotUpdateNote();
    }else{
      return await getNote(id: note.id);
    }
  }
  Future<Iterable<DatabaseNote>> getAllNotes() async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(noteTable);
    return notes.map((noteRow) => DatabaseNote.fromRow(noteRow));
   }
  Future<DatabaseNote> getNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final notes = await db.query(
      noteTable, 
      limit: 1, 
      where: 'id=?',
      whereArgs: [id]
    );
    if(notes.isEmpty){
      throw CouldNotFindNote();
    }else{
      return DatabaseNote.fromRow(notes.first);
    }
  }
  Future<int> deleteAllNote()async{
    final db = _getDatabaseOrThrow();
    return await db.delete(noteTable);
  }
  Future<void> deleteNote({required int id}) async {
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id =?',
      whereArgs: [id]
    );
    if (deletedCount == 0){
      throw CouldNotDeleteNote();
    }
  }
  Future<DatabaseNote> createNote({required DatabaseUser owner}) async {
    final db = _getDatabaseOrThrow();
    final dbUser = await getUser(email: owner.email);
    if(dbUser != owner){
      throw CouldNotFindUser();
    }
    const text = '';
    final noteId = await db.insert(
      noteTable, 
      {userIdColumn: owner.id, textColumn:text, isSyncedWithCloudColumn:1,}
    );
    final note = DatabaseNote(
      id: noteId, 
      userId: owner.id, 
      text: text, 
      isSyncedWithCloud: true
    );
    return note;
  }
  Future<DatabaseUser> getUser({required String email})async{
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable, 
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if(results.isEmpty){
      throw CouldNotFindUser();
    }else{
      return DatabaseUser.fromRow(results.first);
    }
  }
  Future<DatabaseUser> createUser({required String email})async{
    final db = _getDatabaseOrThrow();
    final results = await db.query(
      userTable, 
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if(results.isNotEmpty){
      throw UserAlreadyExists();
    }
    final userId = await db.insert(
      userTable, 
      {emailColumn: email.toLowerCase()}
    );
    return DatabaseUser(id: userId, email: email);
  }
  Future<void> deleteUser({required String email})async{
    final db = _getDatabaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );
    if (deletedCount != 1){
      throw CouldNotDeleteUser;
    }
  }
  Database _getDatabaseOrThrow(){
    final db = _db;
    if(db == null){
      throw DatabaseIsNotOpen();
    }
    else{
      return db;
    }
  }
  Future<void> close()async{
    final db = _db;
    if(db == null){
      throw DatabaseIsNotOpen();
    }
    else{
      await db.close();
      _db = null;
    }
  }
  Future<void> open()async{
    if(_db != null){
      throw DatabaseAlreadyOpenException();
    }
    try{
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path,dbName);
      final db = await openDatabase(dbPath);
      _db = db;
      await db.execute(createUserTable);
      await db.execute(createNoteTable);
    } on MissingPlatformDirectoryException{
      throw UnableToGetDocumentsDirectory();
    }

  }
}

@immutable
class DatabaseUser{
  final int id;
  final String email;
  const DatabaseUser({
    required this.id,
    required this.email,
  });
  DatabaseUser.fromRow(Map<String,Object?> map):
    id = map[idColumn] as int, 
    email = map[emailColumn] as String;

  @override
  String toString()=>'Person, ID=$id, Email = $email';

  @override
  bool operator ==(covariant DatabaseUser other)=> id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}
@immutable
class DatabaseNote{
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  const DatabaseNote({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });
  DatabaseNote.fromRow(Map<String,Object?> map):
    id = map[idColumn] as int,
    userId = map[userIdColumn] as int,  
    text = map[textColumn] as String,
    isSyncedWithCloud = (map[isSyncedWithCloudColumn] as int)==1?true:false;

  @override
  String toString()=>'Note, ID=$id, userId = $userId, Text = $text, isSyncedWithCloud = $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseNote other)=> id == other.id;
  
  @override
  int get hashCode => id.hashCode;
}
const dbName='notes.db';
const noteTable = 'note';
const userTable = 'user';
const idColumn = 'id';
const emailColumn = 'email';
const userIdColumn ='userId';
const textColumn = 'text';
const isSyncedWithCloudColumn = 'isSyncedWithCloud';
const createUserTable = 
        '''CREATE TABLE IF NOT EXISTS "user"(
	          "id"	INTEGER,
	          "email"	INTEGER NOT NULL UNIQUE, 
            PRIMARY KEY("id" AUTOINCREMENT)
            );''';
const createNoteTable = 
        '''CREATE TABLE IF NOT EXISTS "note" (
	          "id"	INTEGER,
	          "user_id"	INTEGER,
	          "text"	TEXT,
	          "is_synced_with_cloud "	INTEGER NOT NULL DEFAULT 0,
            PRIMARY KEY("id" AUTOINCREMENT),
            FOREIGN KEY("user_id") REFERENCES "user"("id")
            );''';