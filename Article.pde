/*
Article Object
 Comment[] comments;
 String ArticleID
 Date PubDate
 String Headline
 String Url
 String SectionName
 String CategoryName[] //eg "sports", "hockey"
 String 
 */


class Article {
  String filename;
  Comment[] comments;
  String articleID;
  float commentMin, commentMax; // min and max number of comments being shown in the graph
  Date pubDate;
  Date maxDate; // maximum date on the timeline (assuming this is animated to show 24hrs of comments in a minute)
  String Headline;
  String Url;
  String SectionName;
  String CategoryName[]; //eg "sports", "hockey"

  String [] columnNames;
  // int columnCount; // do I need this? I'm using objects with variables instead of multidimensional arrays...
  Date commentDate;

  float aPlotX1; 
  float aPlotY1; // corners of the Article plot
  float aPlotX2; 
  float aPlotY2;
  float aLabelX; 
  float aLabelY; // x = time, y = # of comments

  Date dateMin, dateMax;
  DateFormat df;

  Article(String _filename, float _aPlotY1, float _aPlotY2) {
    filename = _filename;
    aPlotY1 = _aPlotY1; // defines vertical position on the chart
    aPlotY2 = _aPlotY2;    

    // load comments into an array of comment objects with metadata
    // could be put into a method to compartmentalize the code 
    // Comment[] comments = loadComments(filename);
    String[] rows = loadStrings(filename);
    String[] columnNames = split(rows[0], TAB);
    println("Column names: " + columnNames[0] + ", " + columnNames[1] + ", " + columnNames[2] + ", " + columnNames[3] + ", " + columnNames[4]);
    println("rows.length: " + rows.length);
    // columnCount = columnNames.length;
    int rowCount = 0;

    // scrubQuotes(columnNames); // no need to overcomplicate this yet
    comments = new Comment[rows.length-1];

    // start reading at row 1 bc the first row is col names
    for(int i = 1; i < rows.length; i++) {

      if(trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if(rows[i].startsWith("#")) {
        continue;
      }

      // split the rows on the tabs
      String[] pieces = split(rows[i], TAB);
      // scrubQuotes(pieces); // maybe later

      // if((isValidInt(i,1) && isNotNullOrBlank(i,2) && isNotNullOrBlank(i,3) && isValidInt(i,4) && isNotNullOrBlank(i,5)){ // not doing this now. maybe implement later. too complicated for just a demo app
      // check to see that all the data is present and accounted for

      // convert this type of date formatted string Wed Feb 02 2011 15:31:55 GMT-0500 (EST) to a Java date class
      String cdate = pieces[2].substring(0,24) + " EST";
      df = new SimpleDateFormat("EEE MMM dd yyyy HH:mm:ss zzz");

      try {
        commentDate = df.parse(cdate);
      }
      catch(ParseException e) {
        println(e);
      }

      int thumbsUpCount = parseInt(pieces[4]);

      comments[rowCount] = new Comment(pieces[1], commentDate, pieces[3], thumbsUpCount, pieces[5]);
      // (String _articleID, Date _commentDate, String _username, int _thumbsUpCount, String _body
      rowCount++;
    }
    println("Finished loading comments into Comment objects"); 

    // resize the Comment array to reflect accurate size
    comments = (Comment[]) subset(comments, 0, rowCount);


    int maxThumbsUp = getThumbsUpMax(comments);
    println("Max number of thumbs up for a comment is: " + maxThumbsUp );

    commentMax = getThumbsUpMax(comments);  // got rid of this. not sure what I was using it for

    // need to grab real article meta data. right now just using first and last comment date.
    pubDate = comments[0].commentDate; 
    maxDate = comments[comments.length-1].commentDate;
  }




  int getRowCount() {
    return comments.length;
  }

  void drawThumbsUp() {
    int rowCount = comments.length;
  }

  int getThumbsUpMax(Comment[] _comments) {
    Comment[] comments = _comments;
    int m = -Integer.MAX_VALUE; // m equals the max value found

    for (int i = 0; i < comments.length; i++) {
      if (comments[i].thumbsUpCount > m) {
        m = comments[i].thumbsUpCount;
      }
    }
    return m;
  }

  void render() {
    // article meta data
    float pubTime = pubDate.getTime();
    float maxTime = maxDate.getTime();

    // println("pubTime, startCal.getTimeInMillis(), endCal.getTimeInMillis(), plotX1, plotX2: " + pubTime + ", " + startCal.getTimeInMillis() + ", " + endCal.getTimeInMillis() + ", " + plotX1 + ", " + plotX2);
    aPlotX1 = map(pubTime, startCal.getTimeInMillis(), endCal.getTimeInMillis(), plotX1, plotX2);
    aPlotX2 = map(maxTime, startCal.getTimeInMillis(), endCal.getTimeInMillis(), plotX1, plotX2);
    // println("aPlotX1, aPlotX2, aPlotY1, aPlotY2: " + aPlotX1 + ", " + aPlotX2 + ", " + aPlotY1 + ", " + aPlotY2);

    drawArticleTitle();
    // drawAxisLabels();
    // drawVolumeLabels();

    // fill(#5679C1); // need to be here?

    drawDataCommentThumbsUpCountBar();

    // drawDataHighlight();
    // drawYearLabels();
  }
  void drawDataCommentThumbsUpCountBar() {
    for(int i=0; i<comments.length; i++) {
      int tuValue = comments[i].thumbsUpCount;
      float commentTime = comments[i].commentDate.getTime();
      float pubTime = pubDate.getTime();
      float maxTime = maxDate.getTime();
      // in psudeo code below, maxDate is the current timeline date. designed with animation in mind. eventually maxDate ends up being current. 
      // building towards displaying 24hrs of comments in 1min.
      float x = map(commentTime, pubTime, maxTime, aPlotX1, aPlotX2);  // need to figure out dates
      // println("i, tuValue, commentMin, commentMax, aPlotY1, aPlotY2: \n" + i + ", " + tuValue + ", " + commentMin + ", " + commentMax + ", " + aPlotY1 + ", " + aPlotY2);
      // float y = map(tuValue, commentMin, commentMax, aPlotY1, aPlotY2-5); // the -5 is so that comments w/o thumbsUp still show a stub to indicate a comment was made
      float y = map(tuValue, commentMin, maxNumThumbsUp, aPlotY2, aPlotY1+25); // added +25 to fit the article title.

      smooth();
      fill(0);
      ellipseMode(CENTER);
      noStroke();
      // ellipse(x,aPlotY2, 1, 1);
      stroke(0,255);
      line(x,aPlotY2, x, y); // draw a line from the bottom of the timelne to the value #
      //println("line data, i, x, aPlotY2, y: " + i + ", " + x + ", " + aPlotY2 + ", " + y);
    }
  }


  void drawArticleTitle() {
    fill(0);
    textSize(15);
    textAlign(LEFT);
    String title = "\"Tory lead over Liberals grows: poll\"";
    text(title, aPlotX1, aPlotY1+20);
  }

  /* 
   // Not using this. Easier to just run through each article and get the pubDate and maxDate 
   Date getStartDate() {
   float startDateTime = -Float.MAX_VALUE;
   for(int i=0; i<articles.length; i++) { // cycle through all the articles
   for(int j=0; j<comments.length; j++) { // cycle through all the comments
   long currentDateTime = articles[i].comments[j].commentDate.getTime();
   if(currentDateTime < startDateTime) {
   startDateTime = currentDateTime;
   }
   }
   }
   Date startDate = new Date(startDateTime);
   return startDate;
   }
   */

  /*
  void drawArticleDateLabels() {  
   fill(0);
   textSize(10);
   textAlign(CENTER, TOP);
   
   // Use thin, gray lines to draw the grid.
   stroke(255);
   strokeWeight(1);
   
   // figure out min and max dates
   // draw label for start, end date/times plus the labels for 6a, 12p, 6p, 12a over the course of the articles timeline
   
   for (int i = 0; i < comments.length; i++) { // I fear this will require a lot of messing with Dates...
   if(comments[i] % yearInterval == 0) {
   float x = map(years[row], yearMin, yearMax, aPlotX1, aPlotX2);
   text(years[row], x, aPlotY2 + 10);
   line(x, aPlotY1, x, aPlotY2);
   }
   }
   }
   */





















  Article(String _filename, float _aPlotX1, float _aPlotY1, float _aPlotX2, float _aPlotY2) {
    filename = _filename;
    aPlotX1 = _aPlotX1; 
    aPlotY1 = _aPlotY1;
    aPlotX2 = _aPlotX2; 
    aPlotY2 = _aPlotY2;    

    // load comments into an array of comment objects with metadata
    // could be put into a method to compartmentalize the code 
    // Comment[] comments = loadComments(filename);
    String[] rows = loadStrings(filename);
    String[] columnNames = split(rows[0], TAB);
    println("Column names: " + columnNames[0] + ", " + columnNames[1] + ", " + columnNames[2] + ", " + columnNames[3] + ", " + columnNames[4]);
    println("rows.length: " + rows.length);
    // columnCount = columnNames.length;
    int rowCount = 0;

    // scrubQuotes(columnNames); // no need to overcomplicate this yet
    comments = new Comment[rows.length-1];

    // start reading at row 1 bc the first row is col names
    for(int i = 1; i < rows.length; i++) {

      if(trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if(rows[i].startsWith("#")) {
        continue;
      }

      // split the rows on the tabs
      String[] pieces = split(rows[i], TAB);
      // scrubQuotes(pieces); // maybe later

      // if((isValidInt(i,1) && isNotNullOrBlank(i,2) && isNotNullOrBlank(i,3) && isValidInt(i,4) && isNotNullOrBlank(i,5)){ // not doing this now. maybe implement later. too complicated for just a demo app
      // check to see that all the data is present and accounted for

      // convert this type of date formatted string Wed Feb 02 2011 15:31:55 GMT-0500 (EST) to a Java date class
      String cdate = pieces[2].substring(0,24) + " EST";
      df = new SimpleDateFormat("EEE MMM dd yyyy HH:mm:ss zzz");

      try {
        commentDate = df.parse(cdate);
      }
      catch(ParseException e) {
        println(e);
      }

      int thumbsUpCount = parseInt(pieces[4]);

      comments[rowCount] = new Comment(pieces[1], commentDate, pieces[3], thumbsUpCount, pieces[5]);
      // (String _articleID, Date _commentDate, String _username, int _thumbsUpCount, String _body
      rowCount++;
    }
    println("Finished loading comments into Comment objects"); 

    // resize the Comment array to reflect accurate size
    comments = (Comment[]) subset(comments, 0, rowCount);


    int maxThumbsUp = getThumbsUpMax(comments);
    println("Max number of thumbs up for a comment is: " + maxThumbsUp );

    // article meta data
    // need to grab real article meta data. right now just using first and last comment date.
    pubDate = comments[0].commentDate;
    float pubTime = pubDate.getTime();
    println("getting pubDate in Article constructor: " + pubDate);
    maxDate = comments[comments.length-1].commentDate;
    float maxTime = maxDate.getTime();
    commentMax = getThumbsUpMax(comments);
  }
}

