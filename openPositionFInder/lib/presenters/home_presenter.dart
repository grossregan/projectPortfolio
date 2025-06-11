import 'package:cs_3541_final_project/models/chatbot_model.dart';
import 'package:cs_3541_final_project/models/home_model.dart';
import 'package:cs_3541_final_project/presenters/settings_presenter.dart';
import 'package:cs_3541_final_project/views/career_goals_view.dart';
import 'package:cs_3541_final_project/views/chat_view.dart';
import 'package:cs_3541_final_project/views/job_information_view.dart';
import 'package:cs_3541_final_project/views/settings_page.dart';
import 'package:flutter/material.dart';

class HomePresenter {
  final ChatbotModel _chatbotModel = ChatbotModel();

  List<HomeModel> getTabs({
    required SettingsPresenter settingsPresenter,
  }) {
    return [
      HomeModel(
          title: "Job Information", icon: Icons.work, screen: const JobPage()),
      HomeModel(
        title: "Career Goals",
        icon: Icons.star,
        screen: const CareerGoalsViewPage(),
      ),
      HomeModel(
        title: "Chat",
        icon: Icons.chat,
        screen: ChatView(model: _chatbotModel),
      ),
      HomeModel(
        title: "Settings",
        icon: Icons.settings,
        screen: SettingsPage(settingsPresenter: settingsPresenter),
      ),
    ];
  }
}
