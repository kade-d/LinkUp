import 'package:techpointchallenge/model/survey/survey_question.dart';

class SurveyQuestions {


  static List<SurveyQuestion> getSurveyQuestions(){

    return [
      SurveyQuestion("What is your favorite color?", ["Blue", "Green", "Red", "Yellow"]),
      SurveyQuestion("What is your favorite number?", ["1", "2", "5", "7"])
    ];

  }
}