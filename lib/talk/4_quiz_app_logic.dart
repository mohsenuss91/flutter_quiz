// Copyright 2018 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import '../questions.dart';

class QuizAppLogic extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Quiz',
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Flutter Quiz'),
        ),
        body: new QuizPage(),
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  @override
  createState() => new QuizPageState();
}
  
class QuizPageState extends State<QuizPage> {
  var score = 0;
  var questions = <Question>[];

  @override
  initState() {
    super.initState();
    _loadQuestions();
  }

  _loadQuestions() async {
    final loadedQuestions = await loadQuestionsLocally();
    setState(() => questions = loadedQuestions);
  }

  _resetGame() {
    _loadQuestions();
    score = 0;
  }

  _answerQuestion(Question question, bool answer) async {
    setState(() {
      question.answer == answer ? score++ : score--;
      questions.remove(question);
    });
    if (questions.isEmpty) {
      await _gameOverDialog();
      _resetGame();
    }
  }

  _gameOverDialog() async {
    return showDialog<Null>(
      context: context,
      child: new AlertDialog(
        title: new Text('Game Over'),
        content: new Text('You scored $score'),
        actions: <Widget>[
          new FlatButton(
            child: new Text('Play Again'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return 
    new Column(
      children: [
        new Text('Score: $score',
          style: Theme.of(context).textTheme.display1,
        ),
        new Expanded(
          child: new Questions(questions, _answerQuestion),
        ),
      ],
    );
  }
}

class Questions extends StatelessWidget {
  Questions(this.questions, this.answerQuestion);
  final List<Question> questions;
  final Function(Question, bool) answerQuestion;

  @override
  Widget build(BuildContext context) {
    final listTiles = questions.map((question) {

      final controls = new Row(
      children: [
        new GestureDetector(
          child: new Icon(Icons.check, size: 30.0),
          onTap: () => answerQuestion(question, true),
        ),
        new GestureDetector(
          child: new Icon(Icons.clear, size: 30.0),
          onTap: () => answerQuestion(question, false),
        ),
      ]
    );

      return new ListTile(
        leading: new CircleAvatar(
          child: const Text('Q'),
        ),
        title: new Text(question.question),
        trailing: controls,
      );
    }).toList();

    final dividedTiles = ListTile.divideTiles(
      context: context,
      tiles: listTiles
    ).toList();

    return new ListView(children: dividedTiles);
  }
}