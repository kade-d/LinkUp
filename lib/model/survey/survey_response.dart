class Response {

  String question;
  String answer;

  Response(this.question, this.answer);

  Response.fromNothing();

  Response.fromJson(dynamic json){
    assert (json != null);

    question = json['question'];
    answer = json['answer'];

  }

  dynamic toJson(){
    return Map.of(
      {
        "question" : question,
        "answer" : answer
      }
    );
  }

}