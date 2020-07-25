import 'package:techpointchallenge/model/survey/survey_question.dart';

class SurveyQuestions {


  static List<SurveyQuestion> getSurveyQuestions(){

    return [
      SurveyQuestion("What is your favorite sport?", ["Football", "Basketball", "Baseball", "Soccer"]),
      SurveyQuestion("What would be your favorite vacation?", ["Beach", "Mountains", "City", "Cruise"])
    ];

  }
}