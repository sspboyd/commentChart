/*
Comment Object
 String CommentID	
 Sting ArticleID	
 Date Date	
 String Name	
 int RecommendationCount	
 String Body
 
 Maybe add Url later..
 or just grab that from the sdk
 
 */

class Comment {
  // class to store comment info
  // ArticleID, Date, Name, RecommendationCount, Body

  String articleID;
  Date commentDate;
  String username;
  int thumbsUpCount;
  String body;

  Comment(String _articleID, Date _commentDate, String _username, int _thumbsUpCount, String _body) {
    articleID = _articleID;
    commentDate = _commentDate;
    username = _username;
    thumbsUpCount = _thumbsUpCount;
    body = _body;
  }
}

