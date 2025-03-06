import 'package:ambient/widgets/background_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ambient/widgets/starting_light_widget.dart';
import 'package:ambient/models/state_models.dart';
import 'package:provider/provider.dart';
import 'package:ambient/models/state_models.dart';

class SegmentsScreen extends StatefulWidget {
  @override
  _SegmentScreenState createState() => _SegmentScreenState();
}

class _SegmentScreenState extends State<SegmentsScreen> {
  List<Segments> segments = [];
  late int maxLightValue;
  List<bool> localPorts = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeState = Provider.of<HomeState>(context, listen: false);
      // Calculate the sum of port lengths
      maxLightValue =
          homeState.currentController?.portlength?.reduce((a, b) => a + b) ?? 0;

      // Initialize segments list if necessary (here, starting empty)
      print('Max Light Value: $maxLightValue');
    });
  }

  void _addSegment() {
    setState(() {
      int startValue = segments.isNotEmpty ? segments.last.endindex + 1 : 0;
      int endValue = startValue + 10;

      if (endValue > maxLightValue) endValue = maxLightValue;
      if (startValue > maxLightValue) startValue = maxLightValue;

      segments.add(Segments(startindex: startValue, endindex: endValue));
    });
  }

  void _updateSegment(int index, {int? newStartValue, int? newEndValue}) {
    setState(() {
      int start = newStartValue ?? segments[index].startindex;
      int end = newEndValue ?? segments[index].endindex;

      // Ensure start <= end and end <= maxLightValue
      if (start > end) start = end;
      if (end > maxLightValue) end = maxLightValue;

      // Update the current segment
      segments[index] = Segments(startindex: start, endindex: end);

      // If the current segment's endValue overlaps with the next segment, adjust the next segment
      if (index < segments.length - 1) {
        int nextStart = end + 1;
        if (nextStart > segments[index + 1].endindex) {
          nextStart = segments[index + 1].endindex;
        }
        segments[index + 1] = Segments(
            startindex: nextStart, endindex: segments[index + 1].endindex);
      }

      // Sort segments by start index to maintain correct ordering
      segments.sort((a, b) => a.startindex.compareTo(b.startindex));
    });
  }

  void _printSegments() {
    for (var segment in segments) {
      print(
          'Segment: Start = ${segment.startindex}, End = ${segment.endindex}');
    }

    print('Ports: $localPorts');

    // Access the HomeState to create the area
    final homeState = Provider.of<HomeState>(context, listen: false);

    // Create the area with the current segments, controller, and ports
    homeState.createArea(homeState.currentAreaName,
        segments: segments,
        controller: homeState.currentController,
        ports: localPorts);

    // Check if the current controller already exists in homeState.controllers by ID
    final controllerExists = homeState.controllers
        .any((controller) => controller.id == homeState.currentController?.id);

    // Add the current controller if it doesn't already exist
    if (!controllerExists && homeState.currentController != null) {
      homeState.controllers.add(homeState.currentController!);
      print('Controller added to homeState.controllers.');
    } else {
      print('Controller already exists in homeState.controllers.');
    }

    // Navigate back to homeTab
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BackgroundWidget(
        child: Column(
          children: [
            const SizedBox(height: 60),
            AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color.fromARGB(255, 66, 64, 64).withOpacity(0.9),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 18,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              title: Row(
                children: [
                  const Spacer(),
                  Text(
                    'Segments',
                    style: GoogleFonts.montserrat(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Spacer()
                ],
              ),
              centerTitle: true,
            ),
            // Port Checkboxes Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ports',
                        style: GoogleFonts.montserrat(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: List.generate(4, (portIndex) {
                            return Row(
                              children: [
                                Text(
                                  '${portIndex + 1}',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                Checkbox(
                                  value: localPorts[portIndex],
                                  onChanged: (bool? value) {
                                    setState(() {
                                      localPorts[portIndex] = value ?? false;
                                    });
                                  },
                                  checkColor: Colors.white,
                                  activeColor: Colors.blue,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Segments Section
            Expanded(
              child: ListView.builder(
                itemCount: segments.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Column(
                      children: [
                        // Starting Light Widget for each segment
                        StartingLightWidget(
                          title: "Starting Light for Segment ${index + 1}",
                          initialValue: segments[index].startindex,
                          minValue: index > 0
                              ? segments[index - 1].endindex + 1
                              : 0, // Changed from 1 to 0 for the first segment
                          maxValue: segments[index]
                              .endindex, // Start cannot exceed end
                          onValueChanged: (newStartValue) {
                            _updateSegment(index, newStartValue: newStartValue);
                          },
                        ),
                        const SizedBox(height: 10),
                        // Ending Light Widget for each segment
                        StartingLightWidget(
                          title: "Ending Light for Segment ${index + 1}",
                          initialValue: segments[index].endindex,
                          minValue: segments[index]
                              .startindex, // End cannot be less than start
                          maxValue:
                              maxLightValue, // End cannot exceed max value
                          onValueChanged: (newEndValue) {
                            _updateSegment(index, newEndValue: newEndValue);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addSegment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: Text('Add Segment',
                      style: GoogleFonts.montserrat(color: Colors.white)),
                ),
                ElevatedButton(
                  onPressed: _printSegments,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                  ),
                  child: Text('Add Area',
                      style: GoogleFonts.montserrat(color: Colors.white)),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
