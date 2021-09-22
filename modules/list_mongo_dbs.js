for (var i=0; i<db.adminCommand({listDatabases:1,nameOnly:true})["databases"].length; i++){ print(db.adminCommand({listDatabases:1,nameOnly:true})["databases"][i]["name"]);  }
