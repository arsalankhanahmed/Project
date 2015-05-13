package com.example.demodbsql;
import android.content.ContentValues;
import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class DataKamus extends SQLiteOpenHelper {

	public static final String DB_NAME = "Dbkamus"; 
	public static final String ENGLISH = "English";
	public static final String INDONESIA = "Indonesia";
	
	public DataKamus(Context context) {
		super(context, DB_NAME, null,1);
		// TODO Auto-generated constructor stub
	}

	@Override
	public void onCreate(SQLiteDatabase arg0) {
		// TODO Auto-generated method stub
		
	}

	@Override
	public void onUpgrade(SQLiteDatabase arg0, int arg1, int arg2) {
		// TODO Auto-generated method stub
		
	}
	
	public void CreateTable(SQLiteDatabase db)
	{
		db.execSQL("DROP TABLE IF EXISTS dictionary");
		db.execSQL("CREATE TABLE IF NOT EXISTS dictionary(Id INTEGER PRIMARY KEY AUTOINCREMENT, English TEXT, Indonesia TEXT);");
	}
	
	public void GenerateData(SQLiteDatabase db)
	{
		ContentValues objCV = new ContentValues();
		objCV.put(ENGLISH,"Run");
		objCV.put(INDONESIA,"Lari");
		db.insert("dictionary", ENGLISH, objCV);
		objCV.put(ENGLISH,"Read");
		objCV.put(INDONESIA,"Baca");
		db.insert("dictionary", ENGLISH, objCV);
	}

}
