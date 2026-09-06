// Welches Konzept welche Hülle bekommt.
//
// Ein Konzept bestimmt nicht nur, was auf dem ersten Bildschirm steht,
// sondern wie die App organisiert ist: ob es Reiter gibt, worüber man an eine
// einzelne Messung kommt, wie die Bereiche heißen. Solange die Hülle drei
// Reiter erzwingt, kann ein Konzept das nicht — deshalb liefert jedes hier
// seine eigene.
import 'package:flutter/material.dart';

import '../../app/app_controller.dart';
import '../../app/concept.dart';
import 'tabbed_home.dart';

Widget conceptHome({
  required AppConcept concept,
  required AppController controller,
}) =>
    switch (concept) {
      // Tagesprofil teilt die Reiter mit dem klassischen Konzept und füllt
      // nur den ersten anders.
      AppConcept.klassisch ||
      AppConcept.tagesprofil ||
      AppConcept.siebenTage ||
      AppConcept.messanlass ||
      AppConcept.phase =>
        TabbedHome(controller: controller),
    };
