

/////////////////////////////////////////////////////////////////


class QuickDraw {
  String[] source;
  String path;

  JSONObject object;
  JSONArray array;

  /* an integer CORNER, CORNERS, CENTER (0, 1, or 3)
   that specifies what how to interpret the x1, y1,
   x2, and y2 data from the "create" function */

  int mode;

  /* An integer not found in any the Google
   QuickDraw data */

  int marker = -1;

  QuickDraw (String p) {  

    /* A Google QuickDraw data file path*/
    path = p;

    /* Load all the lines in the file as strings so
     that each object can be processed indivdually. */

    source = loadStrings(p);

    /* makes noFill the default drawing mode if no
     no other is specified in the sketch*/

    noFill();

    /* */

    mode = CENTER;

    /*Load the data for the default index; */

    load(0);
  } 


  /////////////////////////////////////////////////////////////////


  /* (In either CENTER or CORNER mode)
   
   .        x1 - the x coordinate of the drawing 
   .        y1 - the y coordinate of the drawing
   .        x2 - the width of the drawing
   .        y2 - the height of the drawing 
   .     index - the index of the drawing you wish to create
   .             the max index of the data can be checked by
   .             using the "length" function.
   .  startAmt - a float between 0.0 and 1.0 representing
   .             the percentage of drawing you want to
   .             begin from.
   .    endAmt - a float between 0.0 and 1.0 representing
   .             the percentage of drawing you want to
   .             end at. */

  void create(float x1, float y1, float x2, float y2, int index, float startAmt, float endAmt) { 

    /*Load the data for the specified index of the
     QuickDraw data */

    load(index);

    /* update the x1, x2, y1, and y2 values adjust for
     different drawing modes. The default mode is CENTER. */

    if (mode != CENTER) {
      if (mode == CORNER) {
        x1 += x2/2;
        y1 += y2/2;
      } else if (mode == CORNERS) {
        x2 = x2 - x1; 
        y2 = y2 - y1;
        x1 += x2/2;
        y1 += y2/2;
        println(x1, x2);
      }
    }

    /* Create arrays to store the combined
     coordinates of a drawing. This allows the drawing
     loop to simulate a more natural drawing process:
     One complete line at a time at a time instead of
     piece by piece of every line all at once. */

    int[] xConcat = new int[0];
    int[] yConcat = new int[0];

    /* Loop through all the strokes of an individual
     drawing */

    for (int j=0; j < array.size(); j++) {

      /* Create an JSONarray containting the x and y
       values of a specified stroke within
       of the the outer array data, "array". */

      JSONArray values = array.getJSONArray(j);

      /* create an integer array out of the x values
       (0 index) and the y values (1 index) of the JSON
       array "values" */

      int[] xint = values.getJSONArray(0).getIntArray();
      int[] yint = values.getJSONArray(1).getIntArray();

      /* Add an identifiying charater/int after every
       stroke's completion. This charater acts as a marker
       for splitting the drawing of the concatinated array
       into multiple lines. */

      xint = append(xint, marker);
      yint = append(yint, marker);

      /* Add the finished data to the unitializied 
       "xConcat" and "yConcat" array */

      xConcat = concat(xConcat, xint);
      yConcat = concat(yConcat, yint);
    }

    /* modify the start and end position of the drawing
     based on a 0.0 - 1.0 float value percentage provided
     by the user. */

    int start = int(round(map(startAmt, 0, 1, 0, xConcat.length)));
    int end = int(round(map(endAmt, 0, 1, 0, xConcat.length)));

    /* Itterate a continuous shapes from every point of
     the concatinated arrays. */

    beginShape();

    for (int k = start; k < end; k++) { 

      /* Store the x and y values and remap them, centered
       to the input scale. The default data is comes
       stored in 256px by 256px coordiate squares. */

      float x;
      x = xConcat[k];
      if (x != -1) {
        x = map(x, 0, 256, -x2/2, x2/2);
      }

      /* store the y value and remap it to a different scale */

      float y; 
      y = yConcat[k];
      y = map(y, 0, 256, -y2/2, y2/2);


      /* When x coordinate or y coordinate is the marker
       character/int do not draw that point. Close the current
       drawing and begin a new one for the next line.*/

      if (xConcat[k] != marker || yConcat[k] != marker) {
        vertex(x + x1, y + y1);
      } else {
        endShape();
        beginShape();
      }
    }

    /* Finish drawing whatever the last stoke was */
    endShape();
  }


  /////////////////////////////////////////////////////////////////


  /* The 5 overload additional functions below provide more conventient
   options for the user so that not every input of the main
   "create" function is required. They take the same types of
   inputs as the main function*/

  /* The minimum input one can provide in any circumstance is
   x1, y1, x2 (width), and y2 (height)*/

  void create(float x1, float y1, float x2, float y2, 
    int index, float endAmt) {
    create(x1, y1, x2, y2, index, 0, endAmt);
  }

  void create(float x1, float y1, float x2, float y2, 
    float startAmt, float endAmt) {
    create(x1, y1, x2, y2, 0, startAmt, endAmt);
  }

  void create(float x1, float y1, float x2, float y2, 
    int index) {
    create(x1, y1, x2, y2, index, 0, 1);
  }

  void create(float x1, float y1, float x2, float y2, 
    float endAmt) {
    create(x1, y1, x2, y2, 0, 0, endAmt);
  }

  void create(float x1, float y1, float x2, float y2) {
    create(x1, y1, x2, y2, 0, 0, 1);
  }


  ////////////////////////////////////////////////////////////////


  /* returns the amount of lines in the source data
   which is also amount of drawings available in a
   Google QuickDraw file */

  int length() {
    return(source.length -1);
  }

  /*returns the amount of points that make up the
   input drawing
   .  i - an integer between 0 and the amount of drawings
   .      in the the source data. That number can be
   .      determined by subtracting 1 from the number of
   .      lines in the data file, or by using the provided
   .      length function. */

  int length(int i) {

    /* repeats logic from the "create" function in order
     to build arrays of x coordinates that can be used
     to measure the lenghth of drawing "i" without
     actually rendering it on screen. */

    load(i);

    int[] concat = new int[0];

    for (int j=0; j < array.size(); j++) {

      JSONArray values = array.getJSONArray(j);
      int[] xint = values.getJSONArray(0).getIntArray();
      xint = append(xint, marker);
      concat = concat(concat, xint);
    }


    /* subtract the appended markers from the size of the*/
    return concat.length - array.size();
  }


  /////////////////////////////////////////////////////////////////


  /* A function that updates the mode of the drawing to
   change how the x1, y1, x2, and y2 are interpreted and
   where the drawing is created from.
   
   .  m - the type of mode you wish to use
   .      accepts CORNER (int 0), CORNERS (int 1)
   .      and CENTER (int 3), which are built in
   .      Processing variables.
   .        
   .      mode is CENTER by default
   */

  void mode(int m) {
    mode = m;
  }


  /////////////////////////////////////////////////////////////////


  /* return information on the drawing from the dataset's
   "word", "countrycode", and "timestamp" objects
   
   
   .        i - the index of the data set you want to obtain
   .            data from
   .  request - a string input dictating
   .
   */

  String info(int i, String request) {

    /* load the data information of the input index */

    object = parseJSONObject(source[i]);

    String word = object.getString("word");
    String countrycode = object.getString("countrycode");
    String timestamp = object.getString("timestamp");

    if (request == " "
      || request == ""
      || request == "all") {
      return ("source: " + path
        + "\nindex: " + i
        + "\nlength: " + length(i)
        + "\nword: " + word
        + "\ncountrycode: " + countrycode
        + "\ntimestamp: " + timestamp);
    } else if (request == "index" 
      || request == "Index"
      || request == "INDEX"
      || request == "line"
      || request == "line"
      || request == "LINE"
      || request == "0") {
      return(str(i));
    } else if (request == "source"
      || request == "Source"
      || request == "SOURCE"
      || request == "path"
      || request == "Path"
      || request == "PATH"
      || request == "file"
      || request == "File"
      || request == "FILE"
      || request == "1") {
      return(path);
    } else if (request == "word"
      || request == "Word"
      || request == "WORD"
      || request == "2") {
      return(word);
    } else if (request == "countrycode"
      || request == "CountryCode"
      || request == "countryCode"
      || request == "Countrycode"
      || request == "COUNTRYCODE"
      || request == "country"
      || request == "Country"
      || request == "COUNTRY"
      || request == "code"
      || request == "Code"
      || request == "CODE"
      || request == "3") {
      return(countrycode);
    } else if (request == "timestamp"
      || request == "TimeStamp"
      || request == "timeStamp"
      || request == "Timestamp"
      || request == "TIMESTAMP"
      || request == "time"
      || request == "Time"
      || request == "TIME"
      || request == "stamp"
      || request == "Stamp"
      || request == "STAMP"
      || request == "4") {
      return(timestamp);
    } else if (request == "length"
      || request == "Length"
      || request == "LENGTH"
      || request == "5") {
      return(str(length((i))));
    } else {
      return ("Unrecognized String parameter."
        + "\nTry using \"source\", "
        + "\"index\", "
        + "\"length\", "
        + "\"word\", "
        + "\"countrycode\", "
        + "or \"timestamp\".");
    }
  }

  String info(int i) {
    return(info(i, " "));
  }

  /////////////////////////////////////////////////////////////////

  private void load(int index) {

    /* load the data information of the input index */

    object = parseJSONObject(source[index]);

    /* process each line's JSON object and isolate the "drawing"
     data from the array */

    array = object.getJSONArray("drawing");
  }
}


/////////////////////////////////////////////////////////////////