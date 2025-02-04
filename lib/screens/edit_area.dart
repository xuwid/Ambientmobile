import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ambient/models/state_models.dart';
import 'package:ambient/widgets/starting_light_widget.dart';
import 'package:provider/provider.dart';
import 'package:ambient/widgets/background_widget.dart';

class EditArea extends StatefulWidget {
  final Area area; // Pass the selected area to this widget

  const EditArea({Key? key, required this.area}) : super(key: key);

  @override
  _EditAreaState createState() => _EditAreaState();
}

class _EditAreaState extends State<EditArea> {
  late List<Segments> segments; // Initialize segments list from selected area
  late int maxLightValue; // Maximum light value for the segments
  List<bool> localPorts = [false, false, false, false];

  @override
  void initState() {
    super.initState();
    segments = widget.area.segments!; // Get segments from the selected area
    localPorts = widget.area.ports!; // Get ports from the selected area

    maxLightValue =
        widget.area.controller!.portlength?.reduce((a, b) => a + b) ?? 0;

    // Initialize the segments list with a single segment

    print('Max Light Value: $maxLightValue');
  }

  void _addSegment() {
    setState(() {
      int startValue = segments.isNotEmpty ? segments.last.endindex + 1 : 1;
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

  void _removeSegment(int index) {
    setState(() {
      segments.removeAt(index); // Remove the segment at the given index
    });
  }

  void _saveChanges() {
    // Save the changes back to the area (You can modify this to fit your data saving logic)
    final homeState = Provider.of<HomeState>(context, listen: false);
    homeState.updateArea(widget.area.id!, segments, localPorts);

    // Navigate back to previous screen
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.black.withOpacity(0.4)),
                  // padding: const EdgeInsets.all(16),

                  child: Column(
                    children: [
                      // Row for Cancel Icon and Starting Light Widget
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            onPressed: () {
                              _removeSegment(index);
                            },
                            icon: Icon(
                              Icons.cancel,
                              color: Colors.white.withOpacity(0.5),
                            ),
                          ),
                          const SizedBox(width: 10),
                        ],
                      ), ////
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: StartingLightWidget(
                              title: "Starting Light for Segment ${index + 1}",
                              initialValue: segments[index].startindex,
                              minValue: index > 0
                                  ? segments[index - 1].endindex + 1
                                  : 1, // Min value is previous segment's end + 1
                              maxValue: segments[index]
                                  .endindex, // Start cannot exceed end
                              onValueChanged: (newStartValue) {
                                _updateSegment(index,
                                    newStartValue: newStartValue);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Ending Light Widget for each segment
                      StartingLightWidget(
                        title: "Ending Light for Segment ${index + 1}",
                        initialValue: segments[index].endindex,
                        minValue: segments[index]
                            .startindex, // End cannot be less than start
                        maxValue: maxLightValue, // End cannot exceed max value
                        onValueChanged: (newEndValue) {
                          _updateSegment(index, newEndValue: newEndValue);
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('Add Segment',
                  style: GoogleFonts.montserrat(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: _saveChanges,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: Text('Save Area',
                  style: GoogleFonts.montserrat(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}
