package com.example.demodbsql;

import android.os.Bundle;
import android.app.Activity;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.view.Menu;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

public class MainActivity extends Activity {

	private SQLiteDatabase db = null;
	private Cursor KamusCursor = null;
	private DataKamus dKamus = null;
	public static final String ENGLISH = "English";
	public static final String INDONESIA = "Indonesia";
	EditText editIngris;
	TextView txtIndo;
	
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        
        dKamus =new DataKamus(this);
        db = dKamus.getWritableDatabase ();
        dKamus.CreateTable (db); 
        dKamus.GenerateData (db);
        setContentView(R.layout.activity_main);
        editIngris = (EditText)findViewById(R.id.editEnglish);
        txtIndo = (TextView)findViewById(R.id.txtIndonesia);
        /*setContentView(R.layout.activity_main);*/
    }

    public void getTranslation(View view) 
    {  
    String result = ""; 
    String englishWord = editIngris.getText().toString(); 
    KamusCursor = db.rawQuery("SELECT Id, English, Indonesia FROM  dictionary WHERE English = '"+ englishWord +"' ORDER BY English ",null);
    if(KamusCursor.moveToFirst ())
    {
      result = KamusCursor.getString (2);
    	for(;! KamusCursor.isAfterLast ();KamusCursor.moveToNext ())
    	{  
    	result = KamusCursor.getString(2);  
    	}
    }
    if(result.equals ("")) 
    {  
    	result = "not found";  
    } 
    txtIndo.setText(result);  
    }

    @Override
    public boolean onCreateOptionsMenu(Menu menu) {
        // Inflate the menu; this adds items to the action bar if it is present.
        getMenuInflater().inflate(R.menu.main, menu);
        return true;
    }
    
    @Override 
    protected void onDestroy() 
    {  
    	//TODO Auto-generated method stub 
    super.onDestroy(); 
    KamusCursor.close(); 
    db.close ();  
    }    
}
