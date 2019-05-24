/* 
 create an array of articles with meta data that includes things like publish date, url, and all comments (with body, author, thumbsUp...)
 
 draw each article as a timeline showing when comments are made with a vertical bar indicating how many thumbs up they're getting,
 on rolloever (or roll-within 1px of the top of the bar) show comment body, author, date/time, etc...
 
 load the comments into an array
 create a timeline similar to the one in milk tea coffee example
 
 -------
 Things to be done.
 Error check when importing comment info Comment objects to ensure that the data isn't null or have errors
 Figure out how to query the pluck api via java.  
 
 */

Article[] articles;

PFont plotFont;


int dateInterval = 60*60*6; // 6hrs = 60secs * 60mins * 6
int commentInterval = 5; // aiming for something between 5 and 10

// variables for the entire display
float plotX1; 
float plotY1; // corners of the plot
float plotX2; 
float plotY2;
float labelX; 
float labelY; // x = time, y = # of comments

Calendar startCal; // used for displaying the x axis timeline labels
Calendar endCal;

int maxNumThumbsUp;


void setup() {
  size(1600,988);

  plotX1 = 120;
  plotX2 = width - 80;
  labelX = 50;
  plotY1 = 80;
  plotY2 = height - 80; 
  labelY = height - 25;

  articles = new Article[4];
  float aHeight = (plotY2-plotY1)/articles.length;
  // articles[0] = new Article("2000413712-e.tsv", plotY1, plotY2-aHeight); // the "-e" stands for Excel, where I had to save the file to get the tabs to register.
  // articles[1] = new Article("2000415568.tsv", plotY1+aHeight, plotY2); // the "-e" stands for Excel, where I had to save the file to get the tabs to register.
  articles[0] = new Article("2000415867.tsv", plotY1, plotY2-aHeight*3); // the "-e" stands for Excel, where I had to save the file to get the tabs to register.
  articles[1] = new Article("2000415948.tsv", plotY1+aHeight, plotY2-aHeight*2); // the "-e" stands for Excel, where I had to save the file to get the tabs to register.
  articles[2] = new Article("2000415974.tsv", plotY1+aHeight*2, plotY2-aHeight); // the "-e" stands for Excel, where I had to save the file to get the tabs to register.
  articles[3] = new Article("2000415835.tsv", plotY1+aHeight*3, plotY2); // the "-e" stands for Excel, where I had to save the file to get the tabs to register.

  // get start and end dates
  startCal = getStartCal(articles);
  // println("startCal = " + startCal);
  endCal = getEndCal(articles);
  // println("endCal = " + endCal);

  // get maxNumThumbsUp
  maxNumThumbsUp = getMaxNumThumbsUp(articles);

  // println("processing time for loading articles = " + (millis()-s));
  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);
  smooth();
}


void draw() {
  background(255);
  // draw chart titles, labels
  drawTitle();
  drawAxisLabels();

  // draw articles
  for(int i=0; i<articles.length; i++) {
    articles[i].render();
  }
}


void drawTitle() {
  fill(0);
  textSize(20);
  textAlign(LEFT);
  String title = "Number of Thumbs Up on a News Story";
  text(title, plotX1, plotY1 - 20);
}



void drawAxisLabels() {
  // this should display the labels that span all article graphs such as calendar date divisions on the chart
  // the individual articles will show the times of the day in 6hr divisions on the 12
  fill(0);
  textSize(13);
  textLeading(15);

  textAlign(CENTER, CENTER);
  text("Number of \nThumbs Up", labelX, (plotY1+plotY2)/2);
  textAlign(CENTER);
  text("Time", (plotX1 + plotX2)/2, labelY);
}


int getMaxNumThumbsUp(Article[] _articles) {
  Article[] articles = _articles;
  int mntu = 0;
  for(int i = 0; i < articles.length; i++) { // cycle through all the articles
    if(mntu < articles[i].commentMax) { 
      mntu = (int)articles[i].commentMax;
    }
  }
  return mntu;
}

/* 
 This method grabs the earliest artice (comment atm) publish date and then
 returns a Calendar object set to be the start of that day. 
 EG. if the earliest (oldest) pub date is Feb 11 at 17:08, the returned Calendar is
 Feb 11 00:00
 */
Calendar getStartCal(Article[] _articles) {
  Article[] articles = _articles;
  Date startDate = new Date(Long.MAX_VALUE); //set a date super far into the future

  for(int i = 0; i < articles.length; i++) { // cycle through all the articles
    Date currArticlePubDate = articles[i].pubDate; // the current article's publish date
    // println("getting currArticlePubDate in getStartCal(): " + currArticlePubDate);
    // println("getting articles[0].pubDate in getStartCal(): " + articles[0].pubDate);

    if(currArticlePubDate.before(startDate)) { // if the current article's pubDate is before startDate...
      startDate = currArticlePubDate;
    }
  }

  Date beginningOfDay = new Date(startDate.getYear(), startDate.getMonth(), startDate.getDate(), 0, 0);
  Calendar startCal = Calendar.getInstance();
  startCal.setTime(beginningOfDay); 
  return startCal;
}

/* 
 This method grabs the earliest artice (comment atm) publish date and then
 returns a Calendar object set to be the start of that day. 
 EG. if the earliest (oldest) pub date is Feb 11 at 17:08, the returned Calendar is
 Feb 11 00:00
 */
Calendar getEndCal(Article[] _articles) {
  Article[] articles = _articles;
  Date endDate = new Date(-Long.MAX_VALUE); //set a date super far into the future

  for(int i=0; i<articles.length; i++) { // cycle through all the articles
    Date currArticleMaxDate = articles[i].maxDate; // the current article's max date (is that right? maxDate?)

    if(currArticleMaxDate.after(endDate)) { // if the current article's pubDate is before startDate...
      endDate = currArticleMaxDate;
    }
  }

  Date endOfDay = new Date(endDate.getYear(), endDate.getMonth(), endDate.getDate(), 23, 59, 59);
  Calendar endCal = Calendar.getInstance();
  endCal.setTime(endOfDay); 
  return endCal;
}

void drawTimelineLabels() {
  //get Calendar of first article publish time (or first comment in this case)
  // get a Calendar that is at the start of that day
  // convert to millis since Epoch
  // map to an x, y on the whole time line and display "Feb 13, 2011"
  // do the same for time but place closer up to the timeline "Midnight"
  // add 3hrs and print a minor tick mark
  // add 3hrs and print 6am
  // ...
}


void stringFilter(String[] _names, String txt){

}




/* 
 boolean isValidInt(int row, int col) {
 if (row < 0) return false;
 if (row >= rowCount) return false;
 //if (col >= columnCount) return false;
 if (col >= comments[row].length) return false;
 if (col < 0) return false;
 return !Integer.isNaN(data[row][col]);
 }
 */

/*
boolean isNotNullOrBlank(int row, int col) {
 return !(data[row][col] == null || data[row][col].trim().equals(""));
 }
 */
